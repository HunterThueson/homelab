# environment/services/privacy.nix

#---------------------------------#
#  Per-user privacy autostart     #
#---------------------------------#

# HM module providing user-systemd units for the IVPN / torrent / Tor
# privacy stack. The system-level VPN services live in
# `system/networking/ivpn-host.nix` and `system/networking/ivpn-torrent.nix`;
# this module wires per-user login triggers on top of them.
#
# Behavior matrix (per user):
#   vpn.enable=false           → no host-tunnel units installed
#   vpn.enable, autostart=true → vpn-autostart.service runs `vpn-up` at login
#   vpn.enable, autostart=false → vpn-veto.service runs the hybrid Meaning
#       A/B veto script at login (see plan).
#
# `vpn` here refers to the HOST-WIDE tunnel (ivpn-host.service). The
# always-on torrent namespace tunnel (ivpn-torrent.service) is governed by
# `hostSettings.networking.privacy.torrent.autostart` (default true) — it
# comes up at boot independent of any user's login state, so there's no
# per-user autostart machinery for it.
#
# torrent.autostart launches qBittorrent at this user's login.
# tor.autostart launches Tor Browser at this user's login.
#
# `vpnAutostartUsers` is computed by the specialArgs hook in flake.nix
# (passed through conjure) — it's the list of usernames on this host whose
# vpn.autostart is true. The veto script uses it to decide whether stopping
# the host tunnel at login would inconvenience another user.

{
  home = { config, lib, pkgs, vpnAutostartUsers ? [], ... }:
    let
      p   = config.userSettings.networking.privacy;
      uid = config.home.username;

      # `qbt` wrapper — launches qBittorrent inside the IVPN namespace. The
      # config directory (~/.config/qBittorrent) is in the user's home and
      # accessible regardless of namespace, since network namespaces only
      # isolate network, not filesystem mounts. Optionally requests an
      # IVPN port-forward before launching when torrent.portForward is on.
      qbtWrapper = pkgs.writeShellApplication {
        name = "qbt";
        runtimeInputs = with pkgs; [ systemd qbittorrent ];
        text = ''
          set -u
          if ! systemctl is-active --quiet ivpn-torrent.service; then
            echo "qbt: torrent tunnel is not running; refusing to launch torrent client" >&2
            echo "qbt: run 'torrent-up' first" >&2
            exit 1
          fi
        '' + lib.optionalString p.torrent.portForward ''
          # TODO(phase-5-followup): request IVPN port-forward via API and
          # write the assigned port into qBittorrent's settings. Stub for now.
          echo "qbt: portForward requested but not yet implemented" >&2
        '' + ''
          # ns-run is provided by the system module; reference by absolute
          # path since this HM-side wrapper can't see the system binary set.
          exec /run/current-system/sw/bin/ns-run qbittorrent "$@"
        '';
      };

      # Other users on this host who would expect the host tunnel running.
      otherAutostartUsers = lib.filter (u: u != uid) vpnAutostartUsers;

      # Veto script: at login, check whether any OTHER autostart-user is
      # currently logged in (via loginctl). If not, stop the host tunnel
      # (Meaning B). If yes, leave it alone and emit a desktop notification
      # (Meaning A with warning).
      vetoScript = pkgs.writeShellApplication {
        name = "vpn-veto-${uid}";
        runtimeInputs = with pkgs; [ systemd libnotify coreutils gnugrep ];
        text = ''
          set -u

          # Wait briefly for the session to settle (login-time race with
          # notification daemon coming up).
          sleep 2

          # List currently-active users (one per line).
          active_users="$(loginctl list-sessions --no-legend 2>/dev/null \
            | awk '{print $3}' | sort -u || true)"

          conflict=""
          # The list is generated at Nix eval time from userDefs; with one
          # other autostart-user, shellcheck flags the loop as one-shot.
          # shellcheck disable=SC2043
          for u in ${lib.concatStringsSep " " otherAutostartUsers}; do
            if printf '%s\n' "$active_users" | grep -qx "$u"; then
              conflict="$u"
              break
            fi
          done

          if [ -n "$conflict" ]; then
            msg="Host VPN left running because $conflict is logged in. Run 'vpn-down' to override."
            notify-send --urgency=normal "VPN" "$msg" 2>/dev/null \
              || echo "vpn-veto: $msg"
          else
            if systemctl is-active --quiet ivpn-host.service; then
              echo "vpn-veto: no other host-VPN users logged in; stopping host tunnel"
              # Goes through polkit (vpn-users group has permission).
              systemctl stop ivpn-host.service
            fi
          fi
        '';
      };

    in
      lib.mkMerge [

        # ---- vpn-autostart (host tunnel) -----------------------------------
        (lib.mkIf (p.vpn.enable && p.vpn.autostart) {
          systemd.user.services.vpn-autostart = {
            Unit = {
              Description = "Bring up host-wide IVPN tunnel on login";
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "/run/current-system/sw/bin/vpn-up";
              RemainAfterExit = true;
            };
            Install.WantedBy = [ "default.target" ];
          };
        })

        # ---- vpn-veto (host tunnel) ----------------------------------------
        (lib.mkIf (p.vpn.enable && !p.vpn.autostart) {
          systemd.user.services.vpn-veto = {
            Unit = {
              Description = "Apply host-VPN veto policy on login";
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "oneshot";
              ExecStart = "${vetoScript}/bin/vpn-veto-${uid}";
              RemainAfterExit = true;
            };
            Install.WantedBy = [ "default.target" ];
          };
        })

        # ---- packages (libnotify for the veto notification) ---------------
        (lib.mkIf p.vpn.enable {
          home.packages = [ pkgs.libnotify ];
        })

        # ---- torrent ------------------------------------------------------
        (lib.mkIf p.torrent.enable {
          home.packages = [ pkgs.qbittorrent qbtWrapper ];
        })

        (lib.mkIf (p.torrent.enable && p.torrent.autostart) {
          systemd.user.services.torrent-autostart = {
            Unit = {
              Description = "Launch qBittorrent inside IVPN namespace at login";
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${qbtWrapper}/bin/qbt";
              Restart = "on-failure";
              RestartSec = "5s";
            };
            Install.WantedBy = [ "default.target" ];
          };
        })

        # ---- tor ----------------------------------------------------------
        # Tor Browser launches on the host network — NOT through the IVPN
        # namespace. Routing Tor through IVPN gives one provider visibility
        # into both ends of every circuit, which weakens Tor's guarantees.
        (lib.mkIf p.tor.enable {
          home.packages = [ pkgs.tor-browser ];
        })

        (lib.mkIf (p.tor.enable && p.tor.autostart) {
          systemd.user.services.tor-autostart = {
            Unit = {
              Description = "Launch Tor Browser at login";
              After = [ "graphical-session.target" ];
            };
            Service = {
              Type = "simple";
              ExecStart = "${pkgs.tor-browser}/bin/tor-browser";
              Restart = "on-failure";
              RestartSec = "5s";
            };
            Install.WantedBy = [ "default.target" ];
          };
        })

      ];
}
