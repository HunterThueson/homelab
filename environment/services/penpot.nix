# environment/services/penpot.nix

#----------#
#  Penpot  #
#----------#

# Self-hosted Penpot — the open-source design tool — for anyone with the
# developer role.
# nixos: upstream's container stack under podman, on whichever host hosts it
# home:  the desktop client, for every developer-role user
#
# Penpot ships neither a NixOS module nor a server package in nixpkgs: the
# only deployment upstream supports is a set of OCI images. This file is their
# docker-compose.yaml translated into virtualisation.oci-containers, dropping
# the mailcatcher and adding healthcheck-gated ordering. [1]
# Credit: https://github.com/penpot/penpot/blob/main/docker/images/docker-compose.yaml

let
  version = "2.18";                                                             # upstream compose's default tag [1]

  images = {
    frontend     = "docker.io/penpotapp/frontend:${version}";
    backend      = "docker.io/penpotapp/backend:${version}";
    exporter     = "docker.io/penpotapp/exporter:${version}";
    adminConsole = "docker.io/penpotapp/admin-console:${version}";
    mcp          = "docker.io/penpotapp/mcp:${version}";
    postgres     = "docker.io/postgres:15";                                     # major is pinned; moving it needs a dump [1]
    valkey       = "docker.io/valkey/valkey:8.1";
  };

  dataDir    = "/var/lib/penpot";
  network    = "penpot";                                                        # the bridge whose DNS resolves the container names [2]
  penpotUid  = "1001";                                                          # uid:gid every penpot image runs as
  postgresUid = "999";                                                          # …and the one postgres:15 runs as [10]

  # Instance-wide feature flags. Three of these are only defensible because the
  # UI is published on loopback — see the footnote before exposing it. [3]
  flags = [
    "enable-registration"                                                       # the first accounts still have to be created
    "disable-email-verification"                                                # nothing here can send mail [3]
    "enable-log-emails"                                                         # …so invite/reset links land in the backend log
    "disable-secure-session-cookies"                                            # plain http [3]
    "enable-prepl-server"                                                       # what `penpot-manage` connects to [4]
    "enable-admin-console"
    "enable-mcp"
  ];

  containers = [
    "penpot-frontend"
    "penpot-backend"
    "penpot-exporter"
    "penpot-admin-console"
    "penpot-mcp"
    "penpot-postgres"
    "penpot-valkey"
  ];
in
{
  nixos = { config, lib, pkgs, ... }:
  let
    cfg = config.hostSettings.services.penpot;

    sharedEnv = {
      PENPOT_FLAGS      = lib.concatStringsSep " " flags;
      PENPOT_PUBLIC_URI = cfg.publicUri;
    };

    databaseEnv = {
      PENPOT_DATABASE_URI      = "postgresql://penpot-postgres/penpot";
      PENPOT_DATABASE_USERNAME = "penpot";
    };

    adminConsoleUri = "http://penpot-admin-console:3000";

    # Both written by penpot-secrets.service, never by this repo [5]
    secretsEnv  = "${dataDir}/secrets.env";
    postgresEnv = "${dataDir}/postgres.env";
  in {
    config = lib.mkIf cfg.enable {

      virtualisation.oci-containers.backend = "podman";                         # not the default on this host [2]

      systemd.tmpfiles.rules = [
        "d ${dataDir} 0750 root root -"
        "d ${dataDir}/assets 0750 ${penpotUid} ${penpotUid} -"
        "d ${dataDir}/postgres 0700 ${postgresUid} ${postgresUid} -"            # re-applied on every switch [10]
      ];

      networking.firewall.allowedTCPPorts =
        lib.optional (cfg.listenAddress != "127.0.0.1") cfg.port;

      systemd.services = {

        penpot-network = {
          description = "Podman network for Penpot";
          path = [ pkgs.podman ];
          serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
          script = ''
            podman network inspect ${network} >/dev/null 2>&1 \
              || podman network create ${network}
          '';
        };

        penpot-secrets = {
          description = "Generate Penpot's master key and database password";
          path = [ pkgs.openssl ];
          serviceConfig = { Type = "oneshot"; RemainAfterExit = true; };
          script = ''
            set -eu
            umask 077
            if [ ! -e ${secretsEnv} ]; then
              password=$(openssl rand -hex 32)
              printf 'PENPOT_SECRET_KEY=%s\nPENPOT_DATABASE_PASSWORD=%s\n' \
                "$(openssl rand -hex 64)" "$password" > ${secretsEnv}.tmp
              printf 'POSTGRES_PASSWORD=%s\n' "$password" > ${postgresEnv}
              mv ${secretsEnv}.tmp ${secretsEnv}
            fi
          '';
        };

      } // lib.genAttrs (map (name: "podman-${name}") containers) (_: {
        after    = [ "penpot-network.service" "penpot-secrets.service" ];
        requires = [ "penpot-network.service" "penpot-secrets.service" ];
      });

      # ---- CONTAINERS ---- #

      virtualisation.oci-containers.containers = {

        # nginx: serves the app bundle, proxies the rest by container name [2]
        penpot-frontend = {
          image       = images.frontend;
          networks    = [ network ];
          dependsOn   = [ "penpot-backend" "penpot-exporter" "penpot-admin-console" "penpot-mcp" ];
          ports       = [ "${cfg.listenAddress}:${toString cfg.port}:8080" ];
          volumes     = [ "${dataDir}/assets:/opt/data/assets" ];
          environment = sharedEnv // {
            PENPOT_ADMIN_CONSOLE_URI   = adminConsoleUri;
            PENPOT_DISABLE_IPV6_LISTEN = "true";                                # unused here, and not always safe [2]
          };
        };

        penpot-backend = {
          image            = images.backend;
          networks         = [ network ];
          dependsOn        = [ "penpot-postgres" "penpot-valkey" ];
          volumes          = [ "${dataDir}/assets:/opt/data/assets" ];
          environmentFiles = [ secretsEnv ];
          environment      = sharedEnv // databaseEnv // {
            PENPOT_ADMIN_CONSOLE_URI            = adminConsoleUri;              # omitting it 503s every RPC [4]
            PENPOT_REDIS_URI                    = "redis://penpot-valkey/0";
            PENPOT_OBJECTS_STORAGE_BACKEND      = "fs";
            PENPOT_OBJECTS_STORAGE_FS_DIRECTORY = "/opt/data/assets";
            PENPOT_TELEMETRY_ENABLED            = "false";                      # upstream ships this on [6]
          };
        };

        # Headless chromium, for PDF/PNG export and shared-link thumbnails
        penpot-exporter = {
          image            = images.exporter;
          networks         = [ network ];
          dependsOn        = [ "penpot-valkey" ];
          environmentFiles = [ secretsEnv ];
          environment      = sharedEnv // {
            PENPOT_INTERNAL_URI = "http://penpot-frontend:8080";
            PENPOT_REDIS_URI    = "redis://penpot-valkey/0";
          };
        };

        # Reached at <publicUri>/admin — the only user management without mail [4]
        penpot-admin-console = {
          image            = images.adminConsole;
          networks         = [ network ];
          dependsOn        = [ "penpot-postgres" ];
          environmentFiles = [ secretsEnv ];
          environment      = databaseEnv // {
            PENPOT_PUBLIC_URI   = cfg.publicUri;
            PENPOT_INTERNAL_URI = "http://penpot-frontend:8080";
          };
        };

        # Penpot's own MCP server, proxied at <publicUri>/mcp [7]
        penpot-mcp = {
          image    = images.mcp;
          networks = [ network ];
        };

        penpot-postgres = {
          image            = images.postgres;
          networks         = [ network ];
          volumes          = [ "${dataDir}/postgres:/var/lib/postgresql/data" ];
          environmentFiles = [ postgresEnv ];
          environment      = {
            POSTGRES_DB          = "penpot";
            POSTGRES_USER        = "penpot";
            POSTGRES_INITDB_ARGS = "--data-checksums";
          };
          podman.sdnotify = "healthy";                                          # holds the backend back until ready [8]
          extraOptions    = [
            "--health-cmd=pg_isready -U penpot"
            "--health-interval=2s"
            "--health-retries=5"
            "--health-start-period=2s"
          ];
        };

        # Websocket notifications and the export queue; nothing durable
        penpot-valkey = {
          image       = images.valkey;
          networks    = [ network ];
          environment = {
            VALKEY_EXTRA_FLAGS = "--maxmemory 128mb --maxmemory-policy volatile-lfu";
          };
          podman.sdnotify = "healthy";
          extraOptions    = [
            "--health-cmd=valkey-cli ping"
            "--health-interval=2s"
            "--health-retries=5"
            "--health-start-period=3s"
          ];
        };
      };

      # Admin CLI: `sudo penpot-manage create-profile`, `… --help`, … [4]
      environment.systemPackages = [
        (pkgs.writeShellScriptBin "penpot-manage" ''
          exec ${pkgs.podman}/bin/podman exec -it penpot-backend ./manage.sh "$@"
        '')
      ];
    };
  };

  home = { config, lib, pkgs, ... }:
  let
    isDeveloper = builtins.elem "developer" config.userSettings.role;
  in {
    config = lib.mkIf isDeveloper {
      home.packages = [ pkgs.penpot-desktop ];                                  # unofficial native client [9]
    };
  };
}

#-------------#
#  Footnotes  #
#-------------#

# 1: Upgrading is a tag bump: `pull = "missing"` (the oci-containers default)
#    only fetches an image it doesn't already have locally, and a new tag is by
#    definition not present, so changing `version` pulls the new images on the
#    next switch. The old ones stay in podman's storage until
#    `podman image prune` runs. Two caveats: the backend applies irreversible
#    schema migrations on first start, so roll-forward only — snapshot
#    /var/lib/penpot/postgres before a major bump; and `postgres:15` is a
#    separate pin, because bumping a postgres major leaves the old cluster
#    unreadable (upstream names the volume penpot_postgres_v15 for the same
#    reason). That one needs a pg_dump/restore, not a tag edit.
#
#    What was dropped from upstream's compose: the mailcatcher container (a
#    throwaway SMTP sink whose only purpose is reading mail Penpot tried to
#    send — see [3]), and the commented-out traefik example, which is only
#    relevant when terminating TLS for an internet-facing instance.

# 2: Two podman facts this depends on. First, `virtualisation.oci-containers`
#    picks its backend from system.stateVersion — docker below 22.05, podman
#    at or above — and hephaestus is on 21.11, so without the explicit
#    `backend = "podman"` this would silently pull in the docker daemon.
#    Second, podman only runs its DNS resolver (aardvark) on *user-defined*
#    networks, so the shared `penpot` bridge isn't cosmetic: the frontend's
#    nginx template resolves `penpot-backend:6060`, `penpot-exporter:6061`,
#    `penpot-admin-console:3000` and `penpot-mcp:4401` by name, and the backend
#    reaches postgres and valkey the same way. That makes the attribute names
#    under `oci-containers.containers` load-bearing — podman uses them verbatim
#    as `--name`, which is what the DNS names come from. Renaming one breaks
#    resolution unless the matching PENPOT_*_URI override is set too.
#
#    `podman system prune` deletes unused networks, so if autoPrune is ever
#    switched on it can take `penpot` out from under a stopped stack;
#    `systemctl restart penpot-network.service` puts it back.
#
#    PENPOT_DISABLE_IPV6_LISTEN drops nginx's `listen [::]:8080` directive in
#    the frontend container. Nothing reaches that socket as things stand —
#    podman publishes the port by DNATing to the container's IPv4 address on a
#    v4-only bridge — and leaving it in place is a live failure mode here,
#    because ivpn-host.service sets net.ipv6.conf.{all,default}.disable_ipv6
#    while the host tunnel is up, and nginx exits rather than starting when it
#    can't bind the address it was told to. Giving the penpot network IPv6
#    (`podman network create --ipv6`) is the case where it would want removing.

# 3: The instance is published on loopback (hostSettings.services.penpot
#    .listenAddress), and three flags trade security for convenience on that
#    basis: `disable-secure-session-cookies` because cookies marked Secure
#    aren't sent over plain http; `disable-email-verification` and
#    `enable-registration` because with no SMTP configured an account that had
#    to confirm an address could never finish signing up. Upstream's own
#    compose warns about exactly the first two before exposing an instance.
#    Reaching this from another machine therefore means more than flipping
#    listenAddress: it wants a real PENPOT_SMTP_* block (or the admin console
#    for account creation), the verification and cookie flags removed, and TLS
#    in front — at which point publicUri has to change to the https URI, since
#    Penpot bakes it into the frontend bundle and into every link it mails.
#
#    `enable-log-emails` is the stopgap meanwhile: Penpot writes the mail it
#    would have sent into the backend log, so an invite or password-reset link
#    is recoverable with `journalctl -u podman-penpot-backend`.

# 4: Penpot's admin CLI lives inside the backend container and talks to the
#    prepl server, which is why `enable-prepl-server` is in the flag list —
#    without it `penpot-manage` can't connect. The prepl socket is bound inside
#    the container network and never published, so it isn't reachable from off
#    the machine.
#
#    `enable-admin-console` is only half the configuration: with that flag set
#    and PENPOT_ADMIN_CONSOLE_URI absent, `app.nitrate/call` raises
#    :nitrate-not-configured on every RPC that touches it, the backend answers
#    503, and the frontend shows "Penpot can't start yet" instead of a login
#    page — a whole-instance outage, not a degraded admin page. The backend has
#    no default for that variable (the frontend's nginx entrypoint does have
#    one, which is why checking only the frontend hides this), so both are set
#    explicitly here as upstream's compose does. Dropping the flag is the other
#    way out, at the cost of the admin console. `sudo penpot-manage` is needed because podman here is
#    rootful; deliberately no sudo rule was added for it (unlike the netns
#    wrappers), since the whole surface is already root-only. The admin console
#    at <publicUri>/admin covers the same ground in a browser.

# 5: PENPOT_SECRET_KEY (the master key every other key is derived from) and the
#    postgres password are generated on first boot into /var/lib/penpot/*.env,
#    0600 root, rather than being sops secrets. They're machine-local values no
#    human ever needs to read, and generating them avoids a manual `sops`
#    step gating the first switch. The tradeoff: they're not in the repo, so
#    they don't survive a reinstall — back up /var/lib/penpot alongside the
#    database, or they become unrecoverable. secrets.env is written once and
#    never rewritten; regenerating it would leave PENPOT_DATABASE_PASSWORD
#    disagreeing with what initdb baked into the cluster, and the backend would
#    fail to authenticate. If this instance ever moves to hestia and the key
#    has to be shared between hosts, that's the point to move it into sops.

# 6: Upstream ships PENPOT_TELEMETRY_ENABLED=true and asks that it be left on;
#    it's off here to match the repo's posture elsewhere (privacy.nix, the IVPN
#    tunnels). Setting it back to "true" is a one-word change and does support
#    the project.

# 7: Penpot's MCP server is proxied at <publicUri>/mcp by the frontend (the
#    `enable-mcp` flag is what writes that nginx location). Nothing in this
#    repo wires it into Claude Code yet; doing so would mean pointing an MCP
#    client at that path, which only works while the stack is running.

# 8: `podman.sdnotify = "healthy"` makes the unit report readiness only once
#    the container's healthcheck passes, which is how compose's
#    `condition: service_healthy` is reproduced here — `dependsOn` alone gives
#    After+Requires, which would let the backend start against a postgres
#    that's still running initdb. Dropping the healthcheck args while leaving
#    sdnotify at "healthy" makes podman refuse to start the container.

# 9: penpot-desktop is a third-party Electron wrapper (author-more/penpot-
#    desktop), not an official Penpot build; the web UI at publicUri is the
#    fully supported path and needs nothing installed. Adding the local
#    instance is a one-time step in the app's own settings. That isn't declared
#    here on purpose: the app persists its instance list in its Electron store
#    under ~/.config, so an HM-managed file there would be a read-only
#    /nix/store symlink the app can't write back to.

# 10: Both bind-mounted data dirs are tmpfiles-created as the uid the image
#     inside them runs as, which is not cosmetic: a `d` rule re-asserts mode
#     and ownership on every `systemd-tmpfiles` run, so a wrong owner here is
#     re-applied on every nixos-rebuild switch and at every boot. Leaving the
#     postgres dir as `root root` on the theory that the image's entrypoint
#     chowns it works exactly once — initdb succeeds, then the next switch
#     takes the directory back and postgres starts answering every connection
#     with `FATAL: could not open file "global/pg_filenode.map": Permission
#     denied` while still appearing to run. The files underneath keep their
#     correct ownership throughout, so fixing the directory is all that's
#     needed. These uids come from the images (`useradd -u 1001` in Penpot's
#     Dockerfiles, `--uid=999` in docker-library/postgres) and would need
#     rechecking if either image changed them; podman named volumes are the
#     alternative that takes ownership from the image instead, at the cost of
#     burying the data under /var/lib/containers.

# EOF
