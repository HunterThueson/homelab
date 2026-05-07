# lib/presets/keyboards.nix

#-------------#
#  Keyboards  #
#-------------#

{
  zsa = {
    moonlander = {
      size = "large";
      connector = "usb";
    };
    voyager = {
      size = "micro";
      connector = "usb";
    };
  };

  lenovoThinkPad = {
    "built-in" = {
      size = "standard";
      connector = "builtin";
    };
  };
}
