# ./system/environment/login-manager/sddm.nix

#----------------------#
#  SDDM Configuration  #
#----------------------#

{ config, pkgs, lib, ... }:

let
  cfg = config;
in

with lib;
{
  mkIf (cfg.userEnvironment.loginManager == "sddm") {
    services.displayManager.sddm = {
      enable = true;
      enableHidpi = true;
      autoNumlock = true;
      wayland.enable = true;
      defaultSession = lib.mkDefault "";
    };
  };
}
