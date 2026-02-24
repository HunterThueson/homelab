# ./system/environment/login-manager/sddm.nix

#----------------------#
#  SDDM Configuration  #
#----------------------#

{ config, pkgs, ... }:

let
  inherit (pkgs) lib;
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
      defaultSession = "";
    };
  };
}
