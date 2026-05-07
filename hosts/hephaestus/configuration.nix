# hosts/hephaestus/configuration.nix

#--------------#
#  Hephaestus  #     AKA     Hunter's Home Desktop PC
#--------------#

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
    hostName = "hephaestus";
    networkmanager.enable = true;
    useDHCP = false;
  };

  #-----------------------------------#
  #  Internationalisation properties  #
  #-----------------------------------#

  i18n.defaultLocale = "en_US.UTF-8";
  console.useXkbConfig = true;

  #--------------#
  #  Bluetooth   #
  #--------------#

  hardware.bluetooth.enable = true;

  #---------#
  #  Games  #
  #---------#

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };

  programs.java = {
    enable = true;
    package = pkgs.jdk17;
  };

  #---------------------#
  #  Hardware Packages  #
  #---------------------#

  environment.systemPackages = with pkgs; [
    # Hardware utilities
    lact                                                    # Linux GPU Control Application
    nvtopPackages.full                                      # htop-like task monitor for GPUs
    openrgb                                                 # open source RGB lighting control
    xorg.xdpyinfo                                          # get information about X display(s)

    # Games
    bolt-launcher                                           # alternative launcher for Runescape
    wineWow64Packages.full                                  # Wine compatibility layer (bolt-launcher dep)
  ];

  services.lact.enable = true;

  #---------------#
  #  Environment  #
  #---------------#

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

  # State version - do not change
  system.stateVersion = "21.11";
}
