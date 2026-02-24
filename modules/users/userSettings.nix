# ./modules/users/userSettings.nix

# Module for making user creation simpler & easier

{ config, pkgs, home-manager, ... }:

let
  cfg = config;
  inherit (pkgs) lib;
in

with lib;
{
  options = {
    userSettings = mkOption {
      description = "A collection of user settings";
      type = 
        with types;
        attrsOf (submodule {
          options = {
            name = mkOption {
              description = "The user's username";
              type = passwdEntry str;
              default = "user";
              example = "myUsername";
            };
            fullName = mkOption {
              description = "The user's full name";
              type = str;
              default = "User Name";
              example = "Bob McBobbinpants";
            };
            hashedPassword = mkOption {
              description = "The user's hashed password";
              type = str;
            };
            email = mkOption {
              description = "The user's email address";
              type = nullOr str;
              default = null;
              example = "email@address.com";
            };
            administrator = mkOption {
              description = "Whether this user has admin privileges";
              type = bool;
              default = false;
              example = true;
            };
            extraGroups = mkOption {
              description = "Extra system groups the user should be added to";
              type = listOf str;
              default = [ ];
              example = [ "wizard" ];
            };
            shell = mkOption {
              description = "The user's default shell";
              type = enum [ "bash" "fish" "zsh" ];
              default = "bash";
              example = "fish";
            };
            enableGit = mkOption {
              description = "Whether to enable Git support";
              type = bool;
              default = true;
              example = false;
            };
            windowManager = mkOption {
              description = "The user's window manager/desktop environment";
              type = enum [ "plasma" "hyprland" "niri" ];
              default = "plasma";
              example = "hyprland";
            };
            browser = mkOption {
              description = "The user's internet browser";
              type = enum [ "firefox" "chrome" "brave" ];
              default = "firefox";
              example = "chrome";
            };
            packages = mkOption {
              description = "A list of packages to install for this user";
              type = listOf pkgs;
            };
            extraSysConfig = mkOption {
              description = "Any NixOS configuration options not available in userSettings can be defined here";
              type = attrsOf anything;
              default = { };
            };
            extraHomeConfig = mkOption {
              description = "Any Home Manager configuration options not available in userSettings can be defined here";
              type = attrsOf anything;
              default = { };
            };
          };
        });
    };
  };

}
