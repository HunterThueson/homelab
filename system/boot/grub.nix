# system/boot/grub.nix

#--------#
#  GRUB  #
#--------#

# Enables GRUB 2 bootloader when hostSettings.hardware.boot.loader = "grub".
# Requires hostSettings.hardware.boot.device to be set to the boot disk.

{ config, pkgs, lib, ... }:

let
  cfg = config.hostSettings.hardware.boot;
in {
  config = lib.mkIf (cfg.loader == "grub") {
    boot.loader.grub = {
      enable = true;
      device = cfg.device;
      efiSupport = true;
      useOSProber = true;
      configurationLimit = 25;

      # Memtest86 (unfree) EFI-compatible system diagnostics
      extraFiles = {
        "memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
      };
      extraEntries = ''
        menuentry "Memtest86" {
          chainloader @bootRoot@/memtest86.efi
        }
      '';
    };
  };
}
