# system/hardware/gpu/nvidia.nix

#----------------------------#
#  Nvidia GPU Configuration  #
#----------------------------#

# Set up for a Nvidia RTX 3090 on a desktop PC
# Includes support for Wine/Proton

{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    extraPackages = with pkgs; [
      nvidia-vaapi-driver
      intel-vaapi-driver
      libvdpau-va-gl
      libva-vdpau-driver
    ];
    extraPackages32 = with pkgs.pkgsi686Linux; [
      nvidia-vaapi-driver
      intel-vaapi-driver
      libvdpau-va-gl
      libva-vdpau-driver
    ];
  };

  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;                                                   # proprietary modules, better for RTX 3090
    powerManagement.enable = false;                                 # desktop, not needed
  };

  boot.kernelParams = [
    "nvidia-drm.modeset=1"
    "nvidia-drm.fbdev=1"
  ];

  environment.sessionVariables = {

    # XWayland / Java
    _JAVA_AWT_WM_NONREPARENTING = "1";

    # Wayland native hints
    NIXOS_OZONE_WL = "1";

    # Vulkan GPU selection
    MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE = "1";

    # Enable GSync
    __GL_GSYNC_ALLOWED = "1";
    __GL_VRR_ALLOWED = "1";

  };

  environment.systemPackages = with pkgs; [
    pciutils
  ];
}
