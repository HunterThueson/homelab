# modules/hostSettings/hardware-options.nix

#--------------------#
#  Hardware Options  #
#--------------------#

{ lib, ... }:

{
  options = {
    bluetooth = lib.mkOption { type = lib.types.bool; default = false; };

    gpu = lib.mkOption {
      type = lib.types.submodule {
        options = {
          enable = lib.mkOption { type = lib.types.bool; default = false; };
          model  = lib.mkOption { type = lib.types.nullOr (lib.types.enum [ "rtx3090" ]); default = null; };
        };
      };
      default = {};
    };

    touchpad = lib.mkOption { type = lib.types.bool; default = false; };

    keyboard = lib.mkOption {
      type = lib.types.submodule {
        options = {
          layout = lib.mkOption { type = lib.types.enum [ "qwerty" "workman" "dvorak" "colemak" ]; default = "qwerty"; };
          model  = lib.mkOption {
            type = lib.types.submodule {
              options = {
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
        };
      });
    };
  };
}
