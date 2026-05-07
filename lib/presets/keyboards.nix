# lib/presets/keyboards.nix

#-------------#
#  Keyboards  #
#-------------#

{
  zsa = {
    moonlander = {
      manufacturer = "zsa";
      size = "large";
      connector = "usb";
    };
    voyager = {
      manufacturer = "zsa";
      size = "micro";
      connector = "usb";
    };
  };

  lenovoThinkPad = {
    "built-in" = {
      manufacturer = "lenovo";
      size = "standard";
      connector = "builtin";
    };
  };
}
