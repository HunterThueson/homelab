# system/display/xorg.nix

#------------------------------#
#  XOrg/XServer configuration  #
#------------------------------#

# Configures Xorg from hostSettings.hardware.display.
# Monitor-specific layout (DPI, MetaModes, xrandrHeads) comes from display
# presets defined in lib/presets/monitors.nix.

{ config, pkgs, lib, ... }:

let
  display = config.hostSettings.hardware.display;
  isHeadless = display == "headless";
  xorg = if isHeadless then {} else display.xorg;
in {
  config = lib.mkIf (!isHeadless) {
    services.xserver = {
      enable = lib.mkDefault true;
      verbose = 7;

      displayManager.xserverArgs =
        lib.optional (xorg.dpi != null) "-dpi ${toString xorg.dpi}";

      virtualScreen = lib.mkIf (xorg.virtualScreen != null) {
        inherit (xorg.virtualScreen) x y;
      };

      screenSection = lib.mkIf (xorg.screenSection != "") xorg.screenSection;

      xrandrHeads = map (head: {
        inherit (head) output primary monitorConfig;
      }) xorg.xrandrHeads;
    };
  };
}
