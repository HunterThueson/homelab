# lib/presets/gpus.nix

#--------#
#  GPUs  #
#--------#

# GPU presets define hardware configurations.
# Package names are strings - the backend resolves them to actual packages
# for both 64-bit and 32-bit architectures.

{
  rtx3090 = {
    enable = true;
    description = "NVIDIA GeForce RTX 3090";
    manufacturer = "nvidia";
    mode = "discrete";

    enable32Bit = true;
    extraDrivers = [
      "nvidia-vaapi-driver"
      "intel-vaapi-driver"
      "libvdpau-va-gl"
      "libva-vdpau-driver"
    ];

    extraPackages = [
      "pciutils"
    ];

    kernelParams = [
      "nvidia-drm.modeset=1"
      "nvidia-drm.fbdev=1"
    ];

    sessionVariables = {
      _JAVA_AWT_WM_NONREPARENTING = "1";
      NIXOS_OZONE_WL = "1";
    };
  };

  # Intel integrated graphics (common on laptops)
  intelUHD = {
    enable = true;
    description = "Intel UHD Graphics";
    manufacturer = "intel";
    mode = "onboard";

    enable32Bit = false;
    extraDrivers = [
      "intel-vaapi-driver"
      "libvdpau-va-gl"
    ];

    extraPackages = [];
    kernelParams = [];
    sessionVariables = {};
  };
}
