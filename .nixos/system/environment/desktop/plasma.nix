# ./system/environment/desktop/plasma.nix

  #----------------------------#
  #  KDE Plasma Configuration  #
  #----------------------------#

{ config, lib, ... }:

let
  cfg = config;
  inherit lib;
in

{
  config = lib.mkIf (cfg.specialisation != {}) {
    services.desktopManager.plasma6.enable = lib.mkDefault true;
    services.desktopManager.plasma6.enableQt5Integration = lib.mkDefault true;
    services.displayManager.defaultSession = "plasmax11";                         # Launch an X11 session by default (rather than Wayland)
  };
}
