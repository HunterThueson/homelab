# system/hardware/inputDevices/zsa-keyboards.nix

#-----------------------------#
#  ZSA Keyboard Configuration #
#-----------------------------#

# Enables udev rules and tools for ZSA keyboards (Moonlander, Voyager, etc.)
# when hostSettings.hardware.keyboard.model.manufacturer = "zsa".

{ config, pkgs, lib, ... }:

let
  cfg = config.hostSettings.hardware.keyboard;
in {
  config = lib.mkIf (cfg.model.manufacturer == "zsa") {
    hardware.keyboard.zsa.enable = true;

    environment.systemPackages = with pkgs; [
      keymapp                                                 # Configure ZSA keyboards
      kontroll                                                # CLI for the Keymapp API
    ];
  };
}
