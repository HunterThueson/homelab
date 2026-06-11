# system/networking/ivpn-host.nix

#----------------------------#
#  IVPN host-wide tunnel     #
#----------------------------#

# Toggleable OpenVPN tunnel that redirects ALL host traffic through IVPN.
# When active:
#   - tun-host is created in the host network namespace
#   - openvpn installs `redirect-gateway def1` routes (default → tun-host)
#   - IVPN DNS is registered via resolvconf (coexists with NetworkManager)
#   - IPv6 is disabled system-wide (sysctl) to prevent v6 leaks
#   - nftables killswitch installed: all egress dropped unless via tun-host,
#     lo, the IVPN gateway IP, or LAN ranges
#
# Killswitch trade-offs:
#   - LAN ranges (10/8, 172.16/12, 192.168/16) are allowed so local services
#     keep working (SSH from another box, printers, etc.). Acceptable for a
#     personal homelab.
#   - $trusted_ip (the resolved IVPN gateway IP) is captured at --up time.
#     If openvpn reconnects to a different IP, the up/down cycle re-captures
#     it — small unprotected window during reconnect is acceptable for the
#     threat model.

{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings;
  vpnUsers = lib.filter (u: u.networking.privacy.vpn.enable) (lib.attrValues cfg);
  anyVpn = vpnUsers != [];
  hostAutostart = config.hostSettings.networking.privacy.vpn.autostart or false;

  # Phase 1: first vpn-enabled user's server wins.
  hostServerName =
    let raw = (lib.head vpnUsers).networking.privacy.vpn.server;
    in if builtins.isString raw then raw else raw.name;

  hostConfigPath = ./ivpn/configs + "/${hostServerName}.ovpn";

  upScript = pkgs.writeShellScript "ivpn-host-up" ''
    set -eu

    # (1) DNS — feed pushed DNS to resolvconf so NetworkManager doesn't
    # clobber it. openvpn exposes pushed options as foreign_option_N env vars.
    for var in $(env | grep -E '^foreign_option_[0-9]+=' | sed 's/=.*//'); do
      val="''${!var}"
      case "$val" in
        "dhcp-option DNS "*)
          dns="''${val#dhcp-option DNS }"
          printf 'nameserver %s\n' "$dns" \
            | ${pkgs.openresolv}/bin/resolvconf -a tun-host -m 0 -x
          ;;
      esac
    done

    # (2) IPv6 — disable system-wide
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.disable_ipv6=1
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.default.disable_ipv6=1

    # (3) Killswitch — drop all egress except via tun-host, lo, IVPN gw, LAN.
    # Idempotent: tear down any leftover table first (handles crash-restart).
    if [ -z "''${trusted_ip:-}" ]; then
      echo "ivpn-host-up: trusted_ip not set; refusing to install killswitch" >&2
      exit 1
    fi
    ${pkgs.nftables}/bin/nft delete table inet ivpn-killswitch 2>/dev/null || true
    ${pkgs.nftables}/bin/nft -f - <<NFEOF
    table inet ivpn-killswitch {
      chain output {
        type filter hook output priority filter; policy drop;
        oifname "lo" accept
        oifname "tun-host" accept
        ip daddr $trusted_ip accept
        ip daddr 10.0.0.0/8 accept
        ip daddr 172.16.0.0/12 accept
        ip daddr 192.168.0.0/16 accept
      }
    }
    NFEOF
  '';

  downScript = pkgs.writeShellScript "ivpn-host-down" ''
    set -e

    # Remove DNS entry — resolvconf rebuilds /etc/resolv.conf from remaining sources
    ${pkgs.openresolv}/bin/resolvconf -d tun-host || true

    # Re-enable IPv6
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.all.disable_ipv6=0
    ${pkgs.procps}/bin/sysctl -w net.ipv6.conf.default.disable_ipv6=0

    # Remove killswitch
    ${pkgs.nftables}/bin/nft delete table inet ivpn-killswitch 2>/dev/null || true
  '';

  ivpnHostStart = pkgs.writeShellScript "ivpn-host-start" ''
    set -eu
    exec ${pkgs.openvpn}/bin/openvpn \
      --config ${hostConfigPath} \
      --auth-user-pass ${config.sops.secrets."ivpn-auth".path} \
      --auth-nocache \
      --dev tun-host \
      --dev-type tun \
      --redirect-gateway def1 \
      --script-security 2 \
      --up ${upScript} \
      --down ${downScript} \
      --pull-filter ignore "ifconfig-ipv6" \
      --pull-filter ignore "route-ipv6"
  '';

in {
  config = lib.mkIf anyVpn {
    systemd.services.ivpn-host = {
      description = "IVPN OpenVPN tunnel (host-wide)";
      wantedBy = lib.optional hostAutostart "multi-user.target";
      after    = [ "network-online.target" "sops-install-secrets.service" ];
      wants    = [ "network-online.target" ];
      path = with pkgs; [ iproute2 openvpn nftables openresolv procps ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${ivpnHostStart}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
