# ./system/services/mouse-and-keyboard.nix

#------------------------------------#
#  Mouse and Keyboard Configuration  #
#------------------------------------#

{ config, pkgs, ... }:

{
  services.xserver = {
    enable = true;                                            # Enable the X11 windowing system
    exportConfiguration = true;                               # Symlink the X server configuration under /etc/X11/xorg.conf
    xkb = {
      layout = "us";                                          # Configure X11 keymap layout
    };
  };

  services.libinput = {
    enable = true;                                            # Enable touchpad support
    mouse.accelProfile = "flat";                              # Disable mouse acceleration (bad for gaming)
  };

  services.ratbagd.enable = true;                             # Enable ratbagd, a daemon for configuring gaming mice

  services.upower.enable = true;                              # Enable UPower, a DBus service that provides power management support

  environment.systemPackages = with pkgs; [
    piper                                                     # Mouse configuration software
    xclip                                                     # using `xclip -selection c` adds standard input to the clipboard
  ];
}
