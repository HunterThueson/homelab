# modules/userSettings/schema.nix

#----------#
#  Schema  #
#----------#

{ lib, pkgs, ... }:

{
  options.userSettings = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, ...}: {
      options = {

        name = lib.mkOption { 
          type    = lib.types.str;
          default = name;
        };
        description = lib.mkOption { type = lib.types.str; };
        fullName    = lib.mkOption { type = lib.types.str; };
        email       = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };

        administrator       = lib.mkOption { type = lib.types.bool; default = false; };
        extraGroups         = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
        hashedPasswordFile  = lib.mkOption { type = lib.types.path; };

        terminal  = lib.mkOption { type = lib.types.str; default = "alacritty"; };
        shell     = lib.mkOption { type = lib.types.enum [ "bash" "fish" "zsh" ]; default = "bash"; };
        editor    = lib.mkOption { type = lib.types.enum [ "vim" "emacs" ]; default = "vim"; };
        enableGit = lib.mkOption { type = lib.types.bool; default = false; };

        desktop = lib.mkOption {
          type = lib.types.submodule {
            options = {
              environment = lib.mkOption {
                type        = lib.types.enum [ "hyprland" "niri" "plasma" "plasmax11" ];
                default     = "hyprland";
                description = "Set the user's desktop environment";
              };
              theme = lib.mkOption {
                type        = lib.types.nullOr lib.types.enum [ "default" ];
                default     = null;
                description = "Set the user's theme (for window decorations, border styles, etc.)";
              };
              colorScheme = lib.mkOption {
                type        = lib.types.nullOr lib.types.enum [ "electro-swing" ];
                default     = null;
                description = "Set the user's color scheme";
              };
              wallpaper = lib.mkOption {
                type        = lib.types.nullOr lib.types.path;
                default     = null;
                description = "Set the user's wallpaper";
              };
            };
          };
        };

        browser = lib.mkOption { type = lib.types.str; default = "firefox"; };

        packages = lib.mkOption { type = lib.types.listOf lib.types.package; default = []; };

        services = lib.mkOption {
          type = lib.types.submodule {
            options = {
              vpn      = lib.mkOption { type = lib.types.str; default = "openvpn"; };
              database = lib.mkOption { type = lib.types.str; default = "ngnix"; };
            };
          };
          default = {};
        };

        extraHomeConfig   = lib.mkOption { type = lib.types.attrs; default = {}; };
        extraShellConfig  = lib.mkOption { type = lib.types.attrs; default = {}; };
        extraSysConfig    = lib.mkOption { type = lib.types.attrs; default = {}; };
      };
    }));

    default = {};
  };
}
