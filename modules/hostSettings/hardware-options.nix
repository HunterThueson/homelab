# modules/hostSettings/hardware-options.nix

#--------------------#
#  Hardware Options  #
#--------------------#

{ lib, ... }:

{
  options = {
    boot = lib.mkOption {
      type = lib.types.submodule {
        options = {
          loader = lib.mkOption {
            type = lib.types.enum [ "grub" "systemd-boot" ];
            default = "systemd-boot";
          };
          device = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Disk device for GRUB installation (e.g. /dev/disk/by-id/...). Required when loader = grub.";
          };
        };
      };
      default = {};
    };

    bluetooth = lib.mkOption { type = lib.types.bool; default = false; };

    gpu = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
        # Whether to enable support for the GPU
          enable   = lib.mkOption { type = lib.types.bool; default = false; };

        # Device information
          description = lib.mkOption { type = lib.types.str; default = ""; };
          manufacturer = lib.mkOption { type = lib.types.enum [ "amd" "intel" "nvidia" ]; default = "intel"; };
          mode = lib.mkOption { type = lib.types.enum [ "onboard" "discrete" "hybrid" ]; default = "onboard"; };

        # Graphics settings
          enable32Bit = lib.mkOption { type = lib.types.bool; default = false; };
          extraDrivers = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Package attribute names for graphics drivers (resolved to both 64-bit and 32-bit)";
          };
          extraPackages = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Package attribute names for extra system packages";
          };
          kernelParams = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
          sessionVariables = lib.mkOption { type = lib.types.attrs; default = {}; };

        # Extra system-level configuration to set when this GPU is active
          extraSysConfig = lib.mkOption { type = lib.types.attrs; default = {}; };
        };
      });
      default = [];
    };

    touchpad = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption { type = lib.types.bool; default = false; };
          # TODO: add ability to declaritively set the touchpad sensitivity
          # TODO: add option for allowing taps on the pad to act as a mouse click
        };
      };
      default = {};
    };

    keyboard = lib.mkOption {
      type = lib.types.submodule {
        options = {
          layout = lib.mkOption { type = lib.types.enum [ "qwerty" "workman" "dvorak" "colemak" ]; default = "qwerty"; };
          model  = lib.mkOption {
            type = lib.types.submodule {
              options = {
                manufacturer = lib.mkOption { type = lib.types.str; default = "generic"; };
                size      = lib.mkOption { type = lib.types.enum [ "micro" "compact" "standard" "large" ]; default = "standard"; };
                connector = lib.mkOption { type = lib.types.enum [ "builtin" "usb" "bluetooth" ]; default = "usb"; };
              };
            };
            default = {};
          };
          steno = lib.mkOption {
            type = lib.types.submodule {
              options = {
                enable = lib.mkOption { type = lib.types.bool; default = false; };
                engine = lib.mkOption { type = lib.types.enum [ "plover" ]; default = "plover"; };
              };
            };
            default = {};
          };
        };
      };
      default = {};
    };

    display = lib.mkOption {
      type = lib.types.either (lib.types.enum [ "headless" ]) (lib.types.submodule {
        options = {
          alignment = lib.mkOption { type = lib.types.enum [ "center" "top" "bottom" "left" "right" ]; default = "center"; };
          monitors = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption { type = lib.types.str; };
                resolution = lib.mkOption {
                  type = lib.types.strMatching "^\\d{3,5}[x]\\d{3,4}[@]\\d{2,3}$";
                  default = "1920x1080@60";
                };
                orientation = lib.mkOption { type = lib.types.enum [ "landscape" "portrait" ]; default = "landscape"; };
                placement = lib.mkOption {
                  type = lib.types.either lib.types.str (lib.types.submodule {
                    options = {
                      position = lib.mkOption { type = lib.types.enum [ "right-of" "left-of" "above" "below" ]; };
                      relativeTo = lib.mkOption { type = lib.types.str; };
                    };
                  });
                  default = "primary";
                };
              };
            });
            default = [];
          };

          xorg = lib.mkOption {
            type = lib.types.submodule {
              options = {
                dpi = lib.mkOption { type = lib.types.nullOr lib.types.int; default = null; };
                virtualScreen = lib.mkOption {
                  type = lib.types.nullOr (lib.types.submodule {
                    options = {
                      x = lib.mkOption { type = lib.types.int; };
                      y = lib.mkOption { type = lib.types.int; };
                    };
                  });
                  default = null;
                };
                screenSection = lib.mkOption { type = lib.types.lines; default = ""; };
                xrandrHeads = lib.mkOption {
                  type = lib.types.listOf (lib.types.submodule {
                    options = {
                      output = lib.mkOption { type = lib.types.str; };
                      primary = lib.mkOption { type = lib.types.bool; default = false; };
                      monitorConfig = lib.mkOption { type = lib.types.lines; default = ""; };
                    };
                  });
                  default = [];
                };
              };
            };
            default = {};
          };
        };
      });
    };
  };
}
