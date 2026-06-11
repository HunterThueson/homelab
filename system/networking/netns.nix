# system/networking/netns.nix

#---------------------------#
#  IVPN network namespace   #
#---------------------------#

# Creates the `ivpn` Linux network namespace and configures its per-namespace
# /etc/resolv.conf to point at IVPN's anti-tracker DNS resolver. The namespace
# starts empty (only `lo`); `ivpn-torrent.service` injects `tun-torrent` into
# it later via OpenVPN's --up script.
#
# Namespace exists whenever any user has `torrent.enable` set.

{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings;
  anyTorrent = lib.any (u: u.networking.privacy.torrent.enable) (lib.attrValues cfg);

  netnsName = "ivpn";
  ivpnDns   = "10.0.254.2";

  netnsUp = pkgs.writeShellScript "netns-ivpn-up" ''
    set -eu
    ${pkgs.iproute2}/bin/ip netns add ${netnsName} 2>/dev/null || true
    ${pkgs.iproute2}/bin/ip -n ${netnsName} link set lo up

    mkdir -p /etc/netns/${netnsName}
    echo "nameserver ${ivpnDns}" > /etc/netns/${netnsName}/resolv.conf
  '';

  netnsDown = pkgs.writeShellScript "netns-ivpn-down" ''
    set -eu
    ${pkgs.iproute2}/bin/ip netns del ${netnsName} 2>/dev/null || true
    rm -rf /etc/netns/${netnsName}
  '';

in {
  config = lib.mkIf anyTorrent {
    systemd.services."netns-ivpn" = {
      description = "Network namespace: ${netnsName}";
      stopIfChanged = false;
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = "${netnsUp}";
        ExecStop  = "${netnsDown}";
      };
    };
  };
}
