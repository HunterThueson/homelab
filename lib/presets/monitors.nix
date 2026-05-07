# lib/presets/monitors.nix

#------------#
#  Monitors  #
#------------#

{ lib, ... }:

{
  gigabyte = {
    m28u = {
      name = "Gigabyte M28U";
      resolution  = lib.mkDefault "3840x2160@144";
      orientation = lib.mkDefault "landscape";
      placement   = lib.mkDefault "primary";
    };
  };

  dell = {
    s2417dg = {
      name = "Dell S2417DG";
      resolution = lib.mkDefault "2560x1440@144";
      orientation = lib.mkDefault "landscape";
      placement = lib.mkDefault "primary";
    };
  };

  lenovoThinkPad = {
    "built-in" = {
      name = "Lenovo ThinkPad X1 Carbon Gen 13 built-in screen";
      resolution = lib.mkDefault "";
      orientation = lib.mkDefault "landscape";
      placement = lib.mkDefault "primary";
    };
  };
}
