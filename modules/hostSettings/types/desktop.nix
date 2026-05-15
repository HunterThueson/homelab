# modules/hostSettings/types/desktop.nix

#-----------#
#  Desktop  #
#-----------#

# Defaults for desktop hosts: full GUI, sound, printing, bluetooth.

{ config, lib, ... }:

{
  config = lib.mkIf (config.hostSettings.type == "desktop") {

    # PipeWire — audio/video pipeline (replaces PulseAudio)
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    # Bluetooth
    hardware.bluetooth.enable = lib.mkDefault true;

    # Printing (system/hardware/printers.nix sets mkDefault;
    # we confirm it here at normal priority)
    services.printing.enable = true;

    # XDG portal plumbing
    environment.pathsToLink = [ "/share/xdg-desktop-portal" "/share/applications" ];
  };
}
