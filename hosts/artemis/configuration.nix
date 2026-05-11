# hosts/artemis/configuration.nix

#-----------#
#  Artemis  #     AKA     Hunter's Laptop
#-----------#

# Host-specific configuration. Module imports now come from system/ and environment/
# via mkHosts.nix. This file only contains config unique to this host.

{ config, pkgs, lib, ... }:

{
  #----------------------------#
  #  Time/clock configuration  #
  #----------------------------#

  time = {
    timeZone = "America/Denver";
    hardwareClockInLocalTime = true;  # For Windows dual boot compatibility
  };

  #----------------------#
  #  Networking options  #
  #----------------------#

  networking = {
    hostName = "artemis";
    networkmanager.enable = true;
    useDHCP = false;
  };

  services.openssh = {
    enable = true;
  };

  #-----------------------------------#
  #  Internationalisation properties  #
  #-----------------------------------#

  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  #------------#
  #  Services  #
  #------------#

  services.printing.enable = true;
  hardware.bluetooth.enable = true;

  #---------#
  #  Steam  #
  #---------#

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  #---------------#
  #  Environment  #
  #---------------#

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
}
