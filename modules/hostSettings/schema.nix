# modules/hostSettings/schema.nix

#----------#
#  Schema  #
#----------#

{ lib, pkgs, ... }:

{
  options.hostSettings = lib.mkOption {
    type = lib.types.submodule {
      options = {
        system = lib.mkOption { type = lib.types.enum [ "x86_64-linux" "aarch64-linux" ]; };
        type   = lib.mkOption { type = lib.types.enum [ "desktop" "laptop" "server" ]; };
        role   = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "workstation" "gaming" "writing" "media" "server" ]); };

        loginManager = lib.mkOption {
          type = lib.types.enum [ "greetd" "sddm" ];
          default = "sddm";
        };

        hardware = lib.mkOption { type = lib.types.submodule (import ./hardware-options.nix); };
      };
    };
  };
}
