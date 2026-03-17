# system/boot/grub.nix

#--------#
#  Grub  #
#--------#

{ config, pkgs, lib, ... }:

let
  cfg = config;
in

{
  boot.loader.grub = {                                                      # Use the GRUB 2 boot loader
    device = "/dev/disk/by-id/nvme-eui.0025384141427eb8";                   # ID of my BOOT (!) DISK (not partition!)
    efiSupport = true;
    useOSProber = true;
    configurationLimit = 25;                                                # Limit the number of GRUB menu entries

    # Enable Memtest86 (unfree) EFI-compatible system diagnostics utility
    extraFiles = {
      "memtest86.efi" = "${pkgs.memtest86-efi}/BOOTX64.efi";
    };
    extraEntries = ''
      menuentry "Memtest86" {
        chainloader @bootRoot@/memtest86.efi
      }
    '';
  };
}
