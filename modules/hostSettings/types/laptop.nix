# modules/hostSettings/types/laptop.nix

#----------#
#  Laptop  #
#----------#

# Defaults for laptop hosts: everything a desktop has, plus
# power management, WiFi power save, lid behavior, backlight.

{ config, lib, ... }:

{
  config = lib.mkIf (config.hostSettings.type == "laptop") {

    # PipeWire
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Power management
    services.thermald.enable = lib.mkDefault true;
    services.tlp = {
      enable = lib.mkDefault true;
      settings = {
        WIFI_PWR_ON_AC = 1;                                     # WiFi power save off on AC
        WIFI_PWR_ON_BAT = 5;                                    # WiFi power save on battery
      };
    };
    services.logind.settings.Login = {
      HandleLidSwitch = "suspend";
      HandleLidSwitchExternalPower = "lock";
    };

    # Bluetooth
    hardware.bluetooth.enable = lib.mkDefault true;

    # Printing
    services.printing.enable = true;

    # Backlight control
    programs.light.enable = lib.mkDefault true;

    # XDG portal plumbing
    environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
  };
}
