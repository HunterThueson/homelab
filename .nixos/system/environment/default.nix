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
  imports = [
    ./nix-config.nix                    # Nix language settings
  ];

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
      };

      config = (import ./loginManager);
    };
  };
}
