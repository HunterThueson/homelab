# ./system/hardware/inputDevices/zsa-keyboards.nix

#-----------------------------#
#  ZSA Keyboard Configuration #
#-----------------------------#

{ config, pkgs, ... }:

{
  hardware.keyboard.zsa.enable = true;                      # enable udev rules that allow ZSA keyboards to function

  environment.systemPackages = with pkgs; [
    keymapp                                                 # configure ZSA keyboards (like my Moonlander)
    kontroll                                                # work with the Keymapp API from the CLI
  ];
}
