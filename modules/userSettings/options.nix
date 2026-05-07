# modules/userSettings/options.nix

#-----------#
#  Options  #
#-----------#

# Shared option definitions for userSettings.
# Used by both schema.nix (NixOS, attrsOf submodule) and hm-schema.nix (HM, single submodule).

{ lib, ... }:

{
  name        = lib.mkOption { type = lib.types.str; default = ""; };
  description = lib.mkOption { type = lib.types.str; };
  fullName    = lib.mkOption { type = lib.types.str; };
  email       = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };

  administrator  = lib.mkOption { type = lib.types.bool; default = false; };
  extraGroups    = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
  hashedPassword = lib.mkOption { type = lib.types.str; default = ""; };

  # TODO: switch from hashedPassword to hashedPasswordFile once we enable `sops-nix` integration
  # hashedPasswordFile  = lib.mkOption { type = lib.types.path; };

  terminal  = lib.mkOption { type = lib.types.enum [ "alacritty" ]; default = "alacritty"; };
  shell     = lib.mkOption { type = lib.types.enum [ "bash" "fish" "zsh" ]; default = "bash"; };
  enableGit = lib.mkOption { type = lib.types.bool; default = false; };

  editor = lib.mkOption {
    type = lib.types.submodule {
      options = {
        terminal = lib.mkOption { type = lib.types.enum [ "vim" "nano" ]; default = "vim"; };
        gui      = lib.mkOption { type = lib.types.enum [ "emacs" "kate" "vs-code" ]; default = "emacs"; };
      };
    };
    default = {};
  };

  desktop = lib.mkOption {
    type = lib.types.submodule {
      options = {
        environment = lib.mkOption {
          type        = lib.types.enum [ "hyprland" "niri" "plasma" "plasmax11" ];
          default     = "hyprland";
          description = "Set the user's desktop environment";
        };
        theme = lib.mkOption {
          type        = lib.types.nullOr (lib.types.enum [ "default" ]);
          default     = null;
          description = "Set the user's theme (for window decorations, border styles, etc.)";
        };
        colorScheme = lib.mkOption {
          type        = lib.types.nullOr (lib.types.enum [ "electro-swing" ]);
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

  browser = lib.mkOption { type = lib.types.enum [ "firefox" ]; default = "firefox"; };

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
  extraSysConfig    = lib.mkOption { type = lib.types.attrs; default = {}; };
}
