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

{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings;
  anyTor = lib.any (u: u.networking.privacy.tor.enable) (lib.attrValues cfg);
in {
  config = lib.mkIf anyTor {
    services.tor = {
      enable = true;
      # SOCKSPort is provided automatically by client.enable. [1]
      client.enable = true;
    };
    environment.systemPackages = with pkgs; [
      file          # verify filetypes
      gnupg         # verify GPG signatures
      clamav        # scan for known malware with freshclam & clamscan
      p7zip         # inspect archives without extracting
      exiftool      # read, write, and edit EXIF metadata
      firejail      # light sandbox for quick & easy isolation
    ];
  };
}


#-------------#
#  Footnotes  #
#-------------#

# 1: `client.enable` emits `SOCKSPort 127.0.0.1:9050 IsolateDestAddr` from
#    `client.socksListenAddress`. `SOCKSPort` is a list option, so also setting
#    `settings.SOCKSPort` appends a second entry instead of replacing the first —
#    the resulting duplicate `SOCKSPort` line passes `torrc --verify` but fails to
#    bind at runtime.
