# system/hardware/gpu/default.nix

#---------------------#
#  GPU Configuration  #
#---------------------#

# Configures graphics hardware based on hostSettings.hardware.gpu
# Supports multiple GPUs, automatic 32-bit driver mirroring, and
# manufacturer-specific settings (Nvidia, AMD, Intel).

{ config, lib, pkgs, ... }:

let
  cfg = config.hostSettings;

  #------------------#
  #  GPU Helpers     #
  #------------------#

  # Check if any GPU matches a condition
  hasGpuWith = pred: lib.any pred cfg.hardware.gpu;

  # Specific manufacturer/mode checks
  hasNvidia = hasGpuWith (g: g.enable && g.manufacturer == "nvidia");
  hasAmd = hasGpuWith (g: g.enable && g.manufacturer == "amd");
  hasIntel = hasGpuWith (g: g.enable && g.manufacturer == "intel");
  hasDiscrete = hasGpuWith (g: g.enable && g.mode == "discrete");
  has32Bit = hasGpuWith (g: g.enable && g.enable32Bit);

  # Get all enabled GPUs
  enabledGpus = lib.filter (g: g.enable) cfg.hardware.gpu;

  # Collect values from all enabled GPUs
  allDriverNames = lib.unique (lib.flatten (map (g: g.extraDrivers) enabledGpus));
  allPackageNames = lib.unique (lib.flatten (map (g: g.extraPackages) enabledGpus));
  allKernelParams = lib.unique (lib.flatten (map (g: g.kernelParams) enabledGpus));
  allSessionVars = lib.foldl' (acc: g: acc // g.sessionVariables) {} enabledGpus;

  # Resolve package names to actual packages (64-bit and 32-bit)
  resolvePackages = names: map (name: pkgs.${name}) names;
  resolvePackages32 = names: map (name: pkgs.pkgsi686Linux.${name}) names;

in {
  config = lib.mkMerge [

    #-----------------------#
    #  Base GPU Config      #
    #-----------------------#

    # Enable graphics if any GPU is enabled
    (lib.mkIf (enabledGpus != []) {
      hardware.graphics.enable = true;
      hardware.graphics.extraPackages = resolvePackages allDriverNames;
      boot.kernelParams = allKernelParams;
      environment.sessionVariables = allSessionVars;
      environment.systemPackages = resolvePackages allPackageNames;
    })

    #-----------------------#
    #  32-bit Support       #
    #-----------------------#

    (lib.mkIf has32Bit {
      hardware.graphics.enable32Bit = true;
      hardware.graphics.extraPackages32 = resolvePackages32 allDriverNames;
    })

    #-----------------------#
    #  Discrete GPU Mode    #
    #-----------------------#

    # Force Vulkan to use the discrete GPU
    (lib.mkIf hasDiscrete {
      environment.sessionVariables.MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE = "1";
    })

    #-----------------------#
    #  Nvidia Configuration #
    #-----------------------#

    (lib.mkIf hasNvidia {
      services.xserver.videoDrivers = [ "nvidia" ];

      hardware.nvidia = {
        package = config.boot.kernelPackages.nvidiaPackages.stable;
        modesetting.enable = true;
        nvidiaSettings = true;
        open = false;  # Proprietary drivers, better compatibility
      };
    })

    # Nvidia + laptop = enable power management
    (lib.mkIf (hasNvidia && cfg.type == "laptop") {
      hardware.nvidia.powerManagement.enable = true;
    })

    #-----------------------#
    #  AMD Configuration    #
    #-----------------------#

    (lib.mkIf hasAmd {
      services.xserver.videoDrivers = [ "amdgpu" ];
    })

    #-----------------------#
    #  Intel Configuration  #
    #-----------------------#

    (lib.mkIf hasIntel {
      services.xserver.videoDrivers = [ "modesetting" ];
    })

  ];
}
