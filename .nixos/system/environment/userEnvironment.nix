# ./system/environment/default.nix

  #-----------------------#
  #  Environment Modules  #
  #-----------------------#

{ config, pkgs, ... }:

let
  cfg = config;
  inherit (pkgs) lib;
in

with lib;
{
  options.userEnvironment = mkOption {
    description = "User environment submodule";
    type = types.attrsOf types.enum {
      options = {
        loginManager = mkOption {
          description = "Set the login manager";
          type = types.enum [ "sddm" "greetd" ];
          default = "sddm";
          example = "greetd";
        };
        editor = mkOption {
          description = "Set the editor";
          type = types.enum [ "vim" "emacs" ];
          default = "vim";
          example = "emacs";
        };
      };

      config = mkMerge [
        (import ./loginManager)
        (import ./editor)
      ];
    };
  };
}
