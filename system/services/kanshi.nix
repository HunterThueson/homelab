# system/services/kanshi.nix

#----------#
#  Kanshi  #
#----------#

# Wayland daemon for managing monitor settings

{ config, pkgs, ... }:

{
  services.kanshi = {
    enable = true;
    profiles = {
      main = {
        outputs = [

          # Gigabyte M28U
          {
            criteria = "eDP-4";
            mode = "3840x2160@144";
            position = "0,0";
            scale = 2.0;
            adaptiveSync = true;
          }

          # Dell S2417DG
          {
            criteria = "eDP-2";
            mode = "2560x1440@144";
            position = "3840,0";
            scale = 1.25;
          }

        ];
      };
    };
  };
}
