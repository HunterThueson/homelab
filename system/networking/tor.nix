# system/networking/tor.nix

#--------------------------#
#  System Tor daemon       #
#--------------------------#

# Enables the host-level Tor daemon when any user has tor.enable. Provides
# a SOCKS5 proxy on 127.0.0.1:9050 for `torsocks <cmd>` experiments and
# CLI tools. Tor Browser (installed per-user via the HM privacy module)
# bundles its own Tor instance and does NOT use this daemon.
#
# The system daemon is NOT routed through IVPN — keeping Tor and the VPN
# in separate lanes is intentional (see the design plan).

{ config, lib, ... }:

let
  cfg = config.userSettings;
  anyTor = lib.any (u: u.networking.privacy.tor.enable) (lib.attrValues cfg);
in {
  config = lib.mkIf anyTor {
    services.tor = {
      enable = true;
      client.enable = true;
      # SOCKS port defaults to 9050; explicit for clarity.
      settings.SOCKSPort = [ 9050 ];
    };
  };
}
