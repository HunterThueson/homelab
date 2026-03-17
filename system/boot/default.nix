# system/boot/default.nix

{ ... }:

{
  imports = [
    ./grub.nix
    ./systemd-boot.nix
  ];

  config = {
    boot = {
      kernelPackages = pkgs.linuxPackages;                                    # Use the default, stable Linux kernel
      loader = {
        efi = {
          efiSysMountPoint = "/boot";
          canTouchEfiVariables = true;
        };
      };
    };
  };
}
