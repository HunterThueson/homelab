# environment/services/syncthing.nix

#-------------#
#  Syncthing  #
#-------------#

# Continuous file sync between hosts, driven by userSettings.sync flags.
# nixos: sops-provisioned device identity + firewall, when any user syncs
# home:  per-user syncthing service, peer devices, and synced folders
#
# Device identities are pre-generated so both machines deploy fully
# declaratively: the private cert/key pairs live in the per-host sops files
# (system/security/secrets/<host>.yaml) and the device IDs below are public
# key fingerprints, safe to commit. [1]

let
  devices = {
    hephaestus = "Y6EA347-3W4AXYH-XFS3VXX-XATU6NH-HQY3SGB-IDNNI6C-3Y62PPU-OVCOHQ7";
    artemis    = "6JKTH3M-X5IFOCW-QDDHWUA-JOJHOL2-UMU7553-VI3B6H7-BNBOAQW-LBRR5AL";
  };

  syncsAnything = u: u.sync.osrs;
in
{
  nixos = { config, lib, flakeRoot, ... }:
  let
    hostName  = config.networking.hostName;
    syncUsers = lib.filterAttrs (_: u: syncsAnything u) config.userSettings;
  in {
    config = lib.mkIf (devices ? ${hostName} && syncUsers != {}) {

      # One pre-generated identity per syncing user, from this host's sops file [2]
      sops.secrets = lib.concatMapAttrs (username: _: {
        "${username}-syncthing-cert" = {
          sopsFile = "${flakeRoot}/system/security/secrets/${hostName}.yaml";
          owner    = username;
        };
        "${username}-syncthing-key" = {
          sopsFile = "${flakeRoot}/system/security/secrets/${hostName}.yaml";
          owner    = username;
        };
      }) syncUsers;

      # Syncthing defaults: transfers + local discovery broadcasts
      networking.firewall = {
        allowedTCPPorts = [ 22000 ];
        allowedUDPPorts = [ 22000 21027 ];
      };
    };
  };

  home = { config, lib, hostName, ... }:
  let
    user     = config.userSettings;
    username = config.home.username;
    peers    = lib.filterAttrs (h: _: h != hostName) devices;
    runelite = "${config.home.homeDirectory}/.local/share/bolt-launcher/.runelite";

    # Hosts listed here are held receive-only while they converge [5]
    folderType = if lib.elem hostName [ ] then "receiveonly" else "sendreceive";
  in {
    config = lib.mkIf (devices ? ${hostName} && syncsAnything user) {

      services.syncthing = {
        enable = true;
        cert   = "/run/secrets/${username}-syncthing-cert";                     # provisioned by nixos-rebuild [2]
        key    = "/run/secrets/${username}-syncthing-key";

        settings = {
          devices = lib.mapAttrs (_: id: { inherit id; }) peers;

          folders = lib.mkIf user.sync.osrs {
            osrs-runelite = {
              id          = "osrs-runelite";
              label       = "OSRS RuneLite";
              path        = runelite;                                           # Bolt launcher's RuneLite home [3]
              devices     = lib.attrNames peers;
              type        = folderType;
              versioning  = {
                type        = "simple";
                params.keep = "5";
              };
            };
          };
        };
      };

      # Keep machine-local churn out of the OSRS sync [4]
      home.file.".local/share/bolt-launcher/.runelite/.stignore" = lib.mkIf user.sync.osrs {
        text = ''
          /cache
          /jagexcache
          /logs
          /repository2
          /jagex_cl_oldschool_LIVE.dat
          /random.dat
        '';
      };
    };
  };
}

#-------------#
#  Footnotes  #
#-------------#

# 1: To add a host to the mesh: `syncthing generate --home=<tmpdir>`, put the
#    resulting cert.pem/key.pem into system/security/secrets/<host>.yaml as
#    <user>-syncthing-cert / <user>-syncthing-key (sops -e), and add the
#    printed device ID to `devices` above. Ports are syncthing's defaults, so
#    only one syncing user per host works as-is; a second would need distinct
#    listen/GUI ports.

# 2: The /run/secrets/* paths exist only after a `nixos-rebuild switch` on
#    that host — a standalone `home-manager switch` config still evaluates,
#    but the service can't start until the system path has provisioned the
#    secrets once.

# 3: Bolt sandboxes RuneLite with HOME=~/.local/share/bolt-launcher, so the
#    live config is its inner .runelite; the top-level ~/.runelite is a stale
#    remnant of running RuneLite directly (untouched since Feb 2026). Bolt's
#    own creds/settings.json are not synced: Jagex session tokens rotate, and
#    sharing them between machines risks logging both out.

# 4: The ignored entries are regenerated game/plugin caches and logs; what
#    syncs is what carries state worth keeping (profiles2 = all RuneLite
#    settings, plugin data dirs, screenshots). Graphics settings live in
#    profiles2 too, so they currently sync between machines — if the laptop
#    ever needs weaker GPU settings, switch it to its own RuneLite profile
#    via the in-client profile panel rather than unsyncing profiles2.

# 5: Both sides default to `sendreceive`, so the first convergence after this
#    module landed merged two already-populated copies file by file instead of
#    seeding one from the other. On 2026-10-18 artemis' profiles.json won and
#    hephaestus' RuneLite started with its real profile unregistered — the
#    settings file itself survived, as did the `.sync-conflict-*` siblings, which
#    were the whole safety net back when this folder configured no `versioning`.
#    Syncthing has no "seed once, then go bidirectional" mode; folder type is the
#    lever. The list is empty because that convergence finished the same day; it
#    is the resting state, and a host goes in it only while being seeded.
#
#    A host listed above cannot push, so the authority's copy wins while that
#    host catches up. Receive-only does not discard what the host already has:
#    those files become "Locally Changed Items" and need a "Revert Local Changes"
#    in its GUI (or deleting the folder before first start) before authority
#    really transfers. Removing a host from the list restores `sendreceive`,
#    which is where both hosts should end up — a host left in the list keeps
#    working, but its local edits silently never reach the other machine.

# EOF
