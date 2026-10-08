# system/networking/wrappers.nix

#-----------------------------------#
#  User-facing wrapper commands     #
#-----------------------------------#

# The privilege machinery for the IVPN privacy stack:
#   - `vpn-users` group (auto-assigned to anyone with vpn or torrent enabled)
#   - polkit rule allowing vpn-users to manage the IVPN systemd units
#   - per-user sudoers NOPASSWD for the exact `ip netns exec ivpn runuser -u
#     <self> -- env ...` invocation that ns-run makes (see the rule below for
#     why the privilege-dropping prefix has to live inside the pattern)
#
# Commands installed:
#   vpn-up / vpn-down       — toggle the host-wide tunnel
#   vpn-status              — status + exit IPs of both tunnels
#   torrent-up / torrent-down — toggle the torrent tunnel (rarely needed)
#   ns-run <cmd>            — run <cmd> inside the ivpn namespace
#   ns-shell                — interactive shell inside the ivpn namespace

{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings;
  anyVpn     = lib.any (u: u.networking.privacy.vpn.enable)     (lib.attrValues cfg);
  anyTorrent = lib.any (u: u.networking.privacy.torrent.enable) (lib.attrValues cfg);
  anyPrivacy = anyVpn || anyTorrent;

  # Users on this host who get `vpn-users` membership and a sudoers rule.
  privacyUsers = lib.filterAttrs
    (_: u: u.networking.privacy.vpn.enable || u.networking.privacy.torrent.enable)
    cfg;

  netnsName = "ivpn";

  # Session variables ns-run carries into the namespace. Without them a GUI
  # app launched inside it can't reach the compositor, the session bus or the
  # icon theme. They're passed as explicit `env` ARGUMENTS rather than through
  # sudo, which is what lets the sudoers rule drop the SETENV tag. PATH, HOME,
  # USER, LOGNAME, SHELL and TERM arrive via sudo's own env_reset defaults
  # (runuser resets HOME to the target user), so they're not listed here.
  nsPassEnv = [
    "DISPLAY" "WAYLAND_DISPLAY" "XAUTHORITY" "XDG_RUNTIME_DIR"
    "XDG_SESSION_TYPE" "XDG_CURRENT_DESKTOP" "XDG_DATA_DIRS" "XDG_CONFIG_DIRS"
    "DBUS_SESSION_BUS_ADDRESS" "QT_QPA_PLATFORM" "QT_QPA_PLATFORMTHEME" "LANG"
  ];

  # The exact command prefix the sudoers rule pins, shared between the rule
  # and ns-run so the two can never drift apart (a mismatch would turn into a
  # password prompt from a GUI launcher, i.e. a silent failure).
  nsExecPrefix = user:
    "${pkgs.iproute2}/bin/ip netns exec ${netnsName}"
    + " ${pkgs.util-linux}/bin/runuser -u ${user} --"
    + " ${pkgs.coreutils}/bin/env";

  vpn-up = pkgs.writeShellApplication {
    name = "vpn-up";
    runtimeInputs = with pkgs; [ systemd ];
    text = ''
      systemctl start ivpn-host.service
    '';
  };

  vpn-down = pkgs.writeShellApplication {
    name = "vpn-down";
    runtimeInputs = with pkgs; [ systemd ];
    text = ''
      systemctl stop ivpn-host.service
    '';
  };

  torrent-up = pkgs.writeShellApplication {
    name = "torrent-up";
    runtimeInputs = with pkgs; [ systemd ];
    text = ''
      systemctl start ivpn-torrent.service
    '';
  };

  torrent-down = pkgs.writeShellApplication {
    name = "torrent-down";
    runtimeInputs = with pkgs; [ systemd ];
    text = ''
      systemctl stop ivpn-torrent.service
    '';
  };

  # ns-run <cmd> — runs <cmd> inside the ivpn namespace as the invoking user.
  # Uses the setuid sudo wrapper (passwordless, per-user rule) to enter the
  # namespace, then runuser immediately drops privileges back to the caller.
  #
  # Note the ordering: `ip netns exec` is the only part that runs as root, and
  # the sudoers rule pins everything up to and including `runuser -u <self> --`
  # so the caller cannot substitute a different target user or skip the drop.
  ns-run = pkgs.writeShellApplication {
    name = "ns-run";
    runtimeInputs = with pkgs; [ iproute2 util-linux coreutils ];
    text = ''
      if [ $# -lt 1 ]; then
        echo "usage: ns-run <command> [args...]" >&2
        exit 2
      fi
      target_user="$(id -un)"

      # Rebuild the session environment on the far side of sudo. Passing these
      # as `env` arguments keeps them out of the root-privileged `ip netns
      # exec` step entirely, so the sudoers rule needs no SETENV tag.
      env_args=()
      for v in ${lib.concatStringsSep " " nsPassEnv}; do
        if [ -n "''${!v-}" ]; then
          env_args+=("$v=''${!v}")
        fi
      done

      exec /run/wrappers/bin/sudo -- \
        ${nsExecPrefix "\"$target_user\""} "''${env_args[@]}" "$@"
    '';
  };

  ns-shell = pkgs.writeShellApplication {
    name = "ns-shell";
    runtimeInputs = [ ns-run ];
    text = ''
      exec ns-run "''${SHELL:-/bin/sh}"
    '';
  };

  vpn-status = pkgs.writeShellApplication {
    name = "vpn-status";
    # ns-run is a let-binding, not a nixpkgs attribute — keep it outside the
    # `with pkgs` so it can't be shadowed if nixpkgs ever grows that name.
    runtimeInputs = [ ns-run ] ++ (with pkgs; [ systemd curl iproute2 ]);
    text = ''
      printf '=== host tunnel (ivpn-host.service) ===\n'
      if systemctl is-active --quiet ivpn-host.service; then
        echo "status: active"
        echo "exit IP:"
        curl --silent --max-time 5 https://api.ipify.org || echo "(unreachable)"
        echo
      else
        echo "status: inactive"
      fi
      echo
      printf '=== torrent tunnel (ivpn-torrent.service) ===\n'
      if systemctl is-active --quiet ivpn-torrent.service; then
        echo "status: active"
        echo "namespace interfaces:"
        # Via ns-run: reading link state needs no privileges, and routing it
        # through the one sanctioned entry point keeps this in step with the
        # sudoers rule instead of needing a second, looser one.
        ns-run ${pkgs.iproute2}/bin/ip -brief addr || true
        echo
        echo "namespace default route:"
        ns-run ${pkgs.iproute2}/bin/ip route show default || true
        echo
        echo "exit IP (via ns-run):"
        ns-run curl --silent --max-time 5 https://api.ipify.org || echo "(unreachable)"
        echo
      else
        echo "status: inactive"
      fi
    '';
  };

in {
  config = lib.mkIf anyPrivacy {

    users.groups.vpn-users = {};

    # Anyone using either tunnel goes in vpn-users automatically.
    users.users = lib.mapAttrs (_: _: { extraGroups = [ "vpn-users" ]; }) privacyUsers;

    # Polkit: vpn-users can start/stop both IVPN services + the namespace service.
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-unit-files" ||
            action.id == "org.freedesktop.systemd1.manage-units") {
          if (subject.isInGroup("vpn-users")) {
            var unit = action.lookup("unit");
            if (unit == "ivpn-host.service" ||
                unit == "ivpn-torrent.service" ||
                unit == "netns-ivpn.service") {
              return polkit.Result.YES;
            }
          }
        }
      });
    '';

    # Passwordless sudo for entering the namespace — one rule per user, scoped
    # as tightly as sudoers allows.
    #
    # The pattern pins the privilege-dropping prefix (`runuser -u <user> --`)
    # so the trailing wildcard only ever covers arguments that have already
    # been handed to the invoking user. This matters a great deal: a rule
    # ending at `ip netns exec ivpn *` matches ANY command and runs it as
    # root, because sudoers wildcards are fnmatch-style and match across
    # whitespace and slashes — i.e. it is passwordless root for every member
    # of the group, not namespace access. Nothing obliges a caller to go
    # through ns-run, so the restriction has to live in the rule itself.
    #
    # Per-user rather than group-wide because the runuser target must be a
    # literal; a wildcard there would let one vpn-user run commands as another.
    #
    # No SETENV: ns-run reconstructs the session environment past the
    # root-privileged step instead of asking sudo to carry it through.
    security.sudo.extraRules = lib.mapAttrsToList (name: _: {
      users = [ name ];
      commands = [{
        command = "${nsExecPrefix name} *";
        options = [ "NOPASSWD" ];
      }];
    }) privacyUsers;

    environment.systemPackages = [
      pkgs.openvpn pkgs.nftables vpn-status
    ] ++ lib.optionals anyVpn [
      vpn-up vpn-down
    ] ++ lib.optionals anyTorrent [
      torrent-up torrent-down ns-run ns-shell
    ];
  };
}
