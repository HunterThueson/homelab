#  ./.nixos/sys/nvidia.nix
#
#  ---------------------------------
#  |  Nvidia Configuration Options |
#  ---------------------------------
#

{ config, pkgs, ... }:

{

services.xserver.videoDrivers = [ "nvidia" ];
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [ nvidia-vaapi-driver intel-vaapi-driver libvdpau-va-gl libva-vdpau-driver ];
  enable32Bit = true;
  extraPackages32 = with pkgs.pkgsi686Linux; [ nvidia-vaapi-driver intel-vaapi-driver libvdpau-va-gl libva-vdpau-driver ];
};

hardware.nvidia = {
  prime = {
    intelBusId = "PCI:0@0:2:0";
    nvidiaBusId = "PCI:1@0:0:0";
    sync.enable = true;
  };
  modesetting.enable = true;            # Fix screen tearing w/ Optimus via PRIME
  nvidiaSettings = true;                # Add `nvidia-settings` to system packages
  open = true;                          # Use open-source kernel modules instead of proprietary
  powerManagement.enable = true;        # Should solve suspend/wakeup issues (which I've had on rare occasions)
};

systemd.services.nvidia-control-devices = {
  wantedBy = [ "multi-user.target" ];
  serviceConfig.ExecStart = "${pkgs.linuxPackages.nvidia_x11.bin}/bin/nvidia-smi";
};

boot = {
  extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  kernelParams =
    [
      "acpi_rev_override"
      "mem_sleep_default=deep"
      "intel_iommu=igfx_off"
      "nvidia-drm.modeset=1"
    ];
};

# Below: packages I previously marked as "NVIDIA driver config dependencies"
#   I'm not sure if they're necessary on NixOS considering the driver itself
#   should come with its own dependencies, but I don't know and I don't care
#   right now. I just want to get Hyprland working and then I'll come back to this.

environment.systemPackages = with pkgs; [
  pciutils
  file
  gnumake
  gcc
  cudatoolkit
];

} # EOF

