# ./hosts/artemis/configuration.nix

    #-----------#             ---------------------
    #  Artemis  #     AKA     |  Hunter's Laptop  |
    #-----------#             ---------------------

# This file acts as an entry-point for host-specific configuration options.

# Continues with the theme of naming hosts after Greek gods & goddesses

{ config, pkgs, inputs, ... }:

let
  host = "artemis";
  inherit (pkgs) lib;
in

{
  imports = [

    inputs.hyprland.nixosModules.default                # Hyprland NixOS module

    ./hardware/inputDevices

    ./boot/loader.nix                                   # Bootloader configuration

    ./environment                                       # User environment modules

    ../users                                            # User management

  ];

  #-------------------#
  #  Desktop Manager  #
  #-------------------#

  specialisation = {
    hyprTest.configuration = {
      system.nixos.tags = [ "hyprTest" ];
      services.desktopManager.plasma6.enable = false;
      services.desktopManager.plasma6.enableQt5Integration = false;
      programs.hyprland.enable = true;

      environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };

      userEnvironment.loginManager = "sddm";
    };
  };

  # My custom module designed for switching configs easily
  userEnvironment = {
    loginManager = lib.mkDefault "sddm";
    editor = "vim";
  };

  #----------------------------#
  #  Time/clock configuration  #
  #----------------------------#

  time = {
    timeZone = "America/Denver";                                                # Set your time zone.
    hardwareClockInLocalTime = true;                                            # Keep the hardware clock in local time instead of UTC
  };                                                                            # for compatibility with Windows Dual Boot

  #----------------------#
  #  Networking options  #
  #----------------------#

  networking = {
    networkmanager.enable = true;
    hostName = "${host}";
    useDHCP = false;
  };

  #-----------------------------------#
  #  Internationalisation properties  #
  #-----------------------------------#

  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    useXkbConfig = true;                                                        # Use X keyboard config in TTY, etc. (for disabling CAPS)
  };

  #----------------------#
  #  User configuration  #                                                      # Only hard-coding users here for the time being until I figure out a better way
  #----------------------#

  users = {
    mutableUsers = false;
    users = {
      hunter = {
        description = "Hunter";
        isNormalUser = true;
        home = "/home/hunter";
        createHome = true;
        extraGroups = [ "wheel" "video" "networkmanager" "wizard" ];
        hashedPassword = "$6$rounds=500000$ilzR8OoFwfvEOzfO$iJ9QJzjIINDW8ON33jTIIxe/B2XcB3MnCR7/qaA6NC2Sw6efZvX2HJ4l3vif8/ggmAv/4GutT8Xt4/wAgLW0H.";
      };
    };
  };

  #------------#
  #  Services  #
  #------------#

  services.printing.enable = true;                          # Enable printer support

  hardware.bluetooth.package = pkgs.bluezFull;              # Enable bluetooth

  services.lact.enable = true;                              # Enable LACT GPU monitoring daemon

  #---------#
  #  Steam  #
  #---------#

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;                         # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true;                    # Open ports in the firewall for Source Dedicated Server
    localNetworkGameTransfers.openFirewall = true;          # Open ports in the firewall for Steam Local Network Game Transfers
  };

  #---------------#
  #  Environment  #
  #---------------#

  environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];

  ###############
  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).

  # Did you read the comment?
  system.stateVersion = "25.11";

}
