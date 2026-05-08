# system/login-manager/sddm.nix

#--------#
#  SDDM  #
#--------#

# Enables SDDM when hostSettings.loginManager = "sddm".

{ config, lib, ... }:

let
  cfg = config.hostSettings;
in {
  config = lib.mkIf (cfg.loginManager == "sddm") {
    services.displayManager.sddm = {
      enable = true;
      enableHidpi = true;
      autoNumlock = true;
      wayland.enable = true;
    };
  };
}
