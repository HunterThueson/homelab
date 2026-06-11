# system/networking/ivpn-torrent.nix

#---------------------------#
#  IVPN torrent tunnel      #
#---------------------------#

# Always-on, namespace-isolated OpenVPN tunnel for the torrent client. The
# OpenVPN process runs in the host network namespace (it needs internet to
# reach IVPN's gateway), but the resulting `tun-torrent` device is moved
# into the `ivpn` namespace via the --up script. Inside that namespace the
# only interfaces are `lo` and `tun-torrent` — so apps in the namespace
# physically cannot reach the network through any path other than IVPN.

{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings;
  torrentUsers = lib.filter (u: u.networking.privacy.torrent.enable) (lib.attrValues cfg);
  anyTorrent = torrentUsers != [];
  hostAutostart = config.hostSettings.networking.privacy.torrent.autostart or true;

  # Phase 1 server selection: first torrent-enabled user's torrent.server,
  # or that user's vpn.server when torrent.server is null.
  torrentServerName =
    let
      user = lib.head torrentUsers;
      torrentServer = user.networking.privacy.torrent.server;
      vpnServer     = user.networking.privacy.vpn.server;
      raw = if torrentServer != null then torrentServer else vpnServer;
    in if builtins.isString raw then raw else raw.name;

  torrentConfigPath = ./ivpn/configs + "/${torrentServerName}.ovpn";

  netnsName = "ivpn";

  # --up: openvpn invokes this with $1 = tun device name and exports env vars
  # ifconfig_local, ifconfig_remote (net30 topology) or ifconfig_netmask
  # (subnet topology). We move the tun device into the ivpn namespace and
  # configure addresses + default route inside.
  moveScript = pkgs.writeShellScript "ivpn-torrent-move" ''
    set -eu
    TUN="$1"

    ${pkgs.iproute2}/bin/ip link set "$TUN" netns ${netnsName}

    if [ -n "''${ifconfig_remote:-}" ]; then
      # net30 / p2p topology
      ${pkgs.iproute2}/bin/ip -n ${netnsName} addr add \
        "$ifconfig_local" peer "$ifconfig_remote" dev "$TUN"
    elif [ -n "''${ifconfig_netmask:-}" ]; then
      # subnet topology — convert dotted netmask to CIDR prefix
      prefix=0
      IFS=. read -r o1 o2 o3 o4 <<< "$ifconfig_netmask"
      for o in "$o1" "$o2" "$o3" "$o4"; do
        case "$o" in
          255) prefix=$((prefix + 8));;
          254) prefix=$((prefix + 7));;
          252) prefix=$((prefix + 6));;
          248) prefix=$((prefix + 5));;
          240) prefix=$((prefix + 4));;
          224) prefix=$((prefix + 3));;
          192) prefix=$((prefix + 2));;
          128) prefix=$((prefix + 1));;
          0)   ;;
        esac
      done
      ${pkgs.iproute2}/bin/ip -n ${netnsName} addr add \
        "$ifconfig_local/$prefix" dev "$TUN"
    else
      echo "ivpn-torrent: openvpn didn't provide ifconfig info" >&2
      exit 1
    fi

    ${pkgs.iproute2}/bin/ip -n ${netnsName} link set "$TUN" up
    ${pkgs.iproute2}/bin/ip -n ${netnsName} route add default dev "$TUN"
  '';

  ivpnTorrentStart = pkgs.writeShellScript "ivpn-torrent-start" ''
    set -eu
    exec ${pkgs.openvpn}/bin/openvpn \
      --config ${torrentConfigPath} \
      --auth-user-pass ${config.sops.secrets."ivpn-auth".path} \
      --auth-nocache \
      --dev tun-torrent \
      --dev-type tun \
      --script-security 2 \
      --route-noexec --ifconfig-noexec \
      --up ${moveScript} \
      --pull-filter ignore "ifconfig-ipv6" \
      --pull-filter ignore "route-ipv6"
  '';

in {
  config = lib.mkIf anyTorrent {
    systemd.services.ivpn-torrent = {
      description = "IVPN OpenVPN tunnel (torrent / ${netnsName} namespace)";
      wantedBy = lib.optional hostAutostart "multi-user.target";
      requires = [ "netns-ivpn.service" ];
      after    = [ "netns-ivpn.service" "sops-install-secrets.service" "network-online.target" ];
      wants    = [ "network-online.target" ];
      path = with pkgs; [ iproute2 openvpn ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${ivpnTorrentStart}";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };
  };
}
