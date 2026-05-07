# users/ash.nix

#-------#
#  Ash  #
#-------#

# Plain function returning user data attrset.
# Consumed by both mkHosts.nix (NixOS) and mkHomes.nix (standalone HM).

{ pkgs, ... }:

{
  description = "Ash";
  fullName = "Ash";

  administrator = true;
  extraGroups = [ "wizard" ];
  hashedPassword = "$6$rounds=9999999$FThVWftaj3S0ShgC$C2HOgr7dst7/rnTy2NhLt5aiOOifhZ4cvg1XZ513VBMvxNg3fUGdH/ajdlnSHSKoxSpfoN84EqD3f6cOSL2/y.";

  shell = "bash";
  enableGit = false;

  desktop = {
    environment = "hyprland";
  };

  browser = "firefox";
  packages = [];

  extraSysConfig = {};
  extraHomeConfig = {};
}
