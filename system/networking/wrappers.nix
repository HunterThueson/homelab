# system/networking/wrappers.nix

#-----------------------------------#
#  User-facing wrapper commands     #
#-----------------------------------#

# The privilege machinery for the IVPN privacy stack:
#   - `vpn-users` group (auto-assigned to anyone with vpn or torrent enabled)
#   - polkit rule allowing vpn-users to manage the IVPN systemd units
#   - sudoers NOPASSWD for `ip netns exec ivpn *` (used by ns-run)
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

  netnsName = "ivpn";

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
  # Uses the setuid sudo wrapper (passwordless for vpn-users) to enter the
  # namespace, then runuser drops privileges back to the original user.
  ns-run = pkgs.writeShellApplication {
    name = "ns-run";
    runtimeInputs = with pkgs; [ iproute2 util-linux coreutils ];
    text = ''
      if [ $# -lt 1 ]; then
        echo "usage: ns-run <command> [args...]" >&2
        exit 2
      fi
      target_user="$(id -un)"
      exec /run/wrappers/bin/sudo \
        --preserve-env=DISPLAY,WAYLAND_DISPLAY,XDG_RUNTIME_DIR,XAUTHORITY \
        -- ${pkgs.iproute2}/bin/ip netns exec ${netnsName} \
           ${pkgs.util-linux}/bin/runuser -u "$target_user" -- "$@"
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
    runtimeInputs = with pkgs; [ systemd curl iproute2 ns-run ];
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
        /run/wrappers/bin/sudo ${pkgs.iproute2}/bin/ip netns exec ${netnsName} \
          ${pkgs.iproute2}/bin/ip -brief addr || true
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
    users.users = lib.mapAttrs (_: user:
      lib.mkIf (user.networking.privacy.vpn.enable
             || user.networking.privacy.torrent.enable) {
        extraGroups = [ "vpn-users" ];
      }
    ) cfg;

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

    # Passwordless sudo for vpn-users entering the namespace.
    # SETENV is required so ns-run can pass DISPLAY/WAYLAND_DISPLAY/etc.
    # through to GUI apps (e.g. qBittorrent) launched inside the namespace.
    security.sudo.extraRules = [{
      groups = [ "vpn-users" ];
      commands = [{
        command = "${pkgs.iproute2}/bin/ip netns exec ${netnsName} *";
        options = [ "NOPASSWD" "SETENV" ];
      }];
    }];

    environment.systemPackages = [
      pkgs.openvpn pkgs.nftables vpn-status
    ] ++ lib.optionals anyVpn [
      vpn-up vpn-down
    ] ++ lib.optionals anyTorrent [
      torrent-up torrent-down ns-run ns-shell
    ];
  };
}
