# system/hardware/networking.nix

#--------------------------#
#  Networking Hardware     #
#--------------------------#

# Network-related system configuration: wireless tools, firewalls,
# VPNs, proxies, and other networking plumbing.

{ config, pkgs, lib, ... }:

let
  cfg = config.hostSettings;
in {

  #---------------------#
  #  Laptop Networking  #
  #---------------------#

  environment.systemPackages = lib.optionals (cfg.type == "laptop") [
    pkgs.iw                                                 # show & manipulate wireless devices
  ];

}
