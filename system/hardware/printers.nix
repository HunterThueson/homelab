# system/hardware/printers.nix

#------------#
#  Printing  #
#------------#

# Shared printer configuration for all hosts.

{ pkgs, lib, ... }:

{
  services.printing = {
    enable = lib.mkDefault true;
    drivers = with pkgs; [
      cups-filters                                          # Additional backends, filters, and other software
      cups-browsed                                          # Daemon for browsing Bonjour broadcasts of shared printers
      gutenprint                                            # Open source drivers for a large variety of printers
      gutenprint-bin                                        # Additional CUPS drivers including Canon drivers
      gtklp                                                 # GTK-based graphical frontend for CUPS
    ];
  };

  # Enable auto-discovery of network printers
  services.avahi = {
    enable = lib.mkDefault true;
    nssmdns4 = true;                                        # mDNS NSS plugin for IPv4
    openFirewall = true;                                    # Open firewall for UDP port 5353
  };
}
