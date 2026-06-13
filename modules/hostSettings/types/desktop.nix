# modules/hostSettings/types/desktop.nix

#-----------#
#  Desktop  #
#-----------#

# Defaults for desktop hosts: full GUI, sound, printing, bluetooth.
# Networking: dhcpcd on every interface (NixOS default), no NetworkManager.
# A desktop that needs Wi-Fi or multiple connections can enable NM from its
# own configuration.nix — that will override the default below.

{ config, lib, ... }:

{
  config = lib.mkIf (config.hostSettings.type == "desktop") {

    # Enable Wifi
    networking.networkmanager.enable = lib.mkDefault true;

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
