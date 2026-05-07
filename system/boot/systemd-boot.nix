# system/boot/systemd-boot.nix

#----------------#
#  systemd-boot  #
#----------------#

# Enables systemd-boot when hostSettings.hardware.boot.loader = "systemd-boot".

{ config, lib, ... }:

let
  cfg = config.hostSettings.hardware.boot;
in {
  config = lib.mkIf (cfg.loader == "systemd-boot") {
    boot.loader.systemd-boot = {
      enable = true;
      memtest86.enable = true;
      configurationLimit = 25;
      editor = false;                   # Disable editing kernel cmd line — security risk
    };
  };
}
