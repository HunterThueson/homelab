# modules/userSettings/schema.nix

#----------#
#  Schema  #
#----------#

{ lib, pkgs, ... }:

{
  options.userSettings = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule {
      options = {
        name        = lib.mkOption { type = lib.types.str; };
        fullName    = lib.mkOption { type = lib.types.str; };
        email       = lib.mkOption { type = lib.types.str; };

        administrator  = lib.mkOption { type = lib.types.bool; default = false; };
        extraGroups    = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
        hashedPassword = lib.mkOption { type = lib.types.str; };

        terminal   = lib.mkOption { type = lib.types.str; default = "alacritty"; };
        shell      = lib.mkOption { type = lib.types.str; default = "bash"; };
        enableGit  = lib.mkOption { type = lib.types.bool; default = false; };

        windowManager = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        theme         = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };
        colorScheme   = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; };

        packages   = lib.mkOption { type = lib.types.listOf lib.types.package; default = []; };

        browser    = lib.mkOption { type = lib.types.str; default = "firefox"; };

        editor = lib.mkOption {
          type = lib.types.submodule {
            options = {
              terminal = lib.mkOption { type = lib.types.str; default = "vim"; };
              gui      = lib.mkOption { type = lib.types.str; default = "emacs"; };
            };
          };
          default = {};
        };

        services = lib.mkOption {
          type = lib.types.submodule {
            options = {
              vpn        = lib.mkOption { type = lib.types.str; default = "openvpn"; };
              database   = lib.mkOption { type = lib.types.str; default = "ngnix"; };
            };
          };
          default = {};
        };

        extraSysConfig  = lib.mkOption { type = lib.types.attrs; default = {}; };
        extraHomeConfig = lib.mkOption { type = lib.types.attrs; default = {}; };
      };
    });
    default = {};
  };
}
