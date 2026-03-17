# system/boot/systemd-boot.nix

#----------------#
#  systemd-boot  #
#----------------#

{ config, pkgs, lib, ... }:

let
  cfg = config;
in

{
  boot.loader.systemd-boot = {                                              # Use the systemd-boot boot loader
    memtest86.enable = true;                                                # Enable Memtest86
    configurationLimit = 25;                                                # Limit the number of systemd-boot menu entries
    editor = false;                                                         # Disable editing kernel cmd line before boot -- security risk (root access)
  };
}
