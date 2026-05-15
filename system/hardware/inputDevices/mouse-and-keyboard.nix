# system/hardware/inputDevices/mouse-and-keyboard.nix

#------------------------------------#
#  Mouse and Keyboard Configuration  #
#------------------------------------#

# Configures keyboard layout and input devices based on hostSettings.

{ config, pkgs, lib, ... }:

let
  cfg = config.hostSettings;
  kb = cfg.hardware.keyboard;

  # Map hostSettings keyboard layout names to xkb layout + variant
  xkbMapping = {
    qwerty  = { layout = "us"; variant = "";         };
    workman = { layout = "us"; variant = "workman";   };
    dvorak  = { layout = "us"; variant = "dvorak";    };
    colemak = { layout = "us"; variant = "colemak";   };
  };

  xkb = xkbMapping.${kb.layout};
in {
  services.xserver = {
    enable = lib.mkDefault true;
    exportConfiguration = lib.mkDefault true;
    xkb = {
      layout = xkb.layout;
    } // lib.optionalAttrs (xkb.variant != "") {
      variant = xkb.variant;
    };
  };

  # Touchpad support — enabled by hostSettings or automatically for laptops
  services.libinput = {
    enable = lib.mkDefault true;
    mouse.accelProfile = "flat";                              # Disable mouse acceleration
    touchpad = lib.mkIf (cfg.hardware.touchpad.enable || cfg.type == "laptop") {
      naturalScrolling = false;
    };
  };

  services.ratbagd.enable = lib.mkDefault true;                # Daemon for configuring gaming mice
  services.upower.enable = lib.mkDefault true;                # Power management support

  environment.systemPackages = with pkgs; [
    piper                                                     # Mouse configuration software
    xclip                                                     # Clipboard CLI tool
  ];
}
