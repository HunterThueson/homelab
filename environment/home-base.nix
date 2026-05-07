# environment/home-base.nix

#-----------------------#
#  Home Manager Base    #
#-----------------------#

# Base home-manager configuration applied to every user.
# Pure HM module — works in both NixOS-managed and standalone HM.

{ config, lib, pkgs, ... }:

let
  user = config.userSettings;

in {
  home.stateVersion = "24.05";

  home.packages = user.packages;

  programs.home-manager.enable = true;

  programs.git = lib.mkIf user.enableGit {
    enable = true;
    settings.user = {
      name = user.fullName;
      email = user.email;
    };
  };
}
