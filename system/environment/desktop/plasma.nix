# ./system/environment/desktop/plasma.nix

#----------------------------#
#  KDE Plasma Configuration  #
#----------------------------#

{ config, pkgs, lib, ... }:

let
  cfg = config;
in

{
  config = lib.mkIf (cfg.specialisation != {}) {
    services.desktopManager.plasma6.enable = lib.mkDefault true;
    services.desktopManager.plasma6.enableQt5Integration = lib.mkDefault true;
    services.displayManager.defaultSession = "plasma";
    environment.systemPackages = with pkgs; [
      wlr-protocols
      kdePackages.plasma-wayland-protocols
      kdePackages.wayland-protocols
      cosmic-protocols
    ];
  };
}
