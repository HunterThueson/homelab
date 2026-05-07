# system/system-programs.nix

#--------------------#
#  System Programs   #
#--------------------#

# Enables system-level programs based on what users on this host need.
# Reads from config.userSettings (attrsOf) to check across all users.

{ config, lib, pkgs, ... }:

let
  users = lib.attrValues config.userSettings;

  anyWantsEmacs = lib.any (u: u.editor.gui == "emacs") users;
  anyWantsVim   = lib.any (u: u.editor.terminal == "vim") users;
  anyWantsZsh   = lib.any (u: u.shell == "zsh") users;
  anyWantsFish  = lib.any (u: u.shell == "fish") users;

in {
  imports = [
    ./vim/treesitter.nix
  ];

  config = lib.mkMerge [

    #---------#
    #  Emacs  #
    #---------#
    (lib.mkIf anyWantsEmacs {
      environment.systemPackages = [ pkgs.emacs ];
      services.emacs = {
        enable = true;
        package = pkgs.emacs;
      };
    })

    #--------#
    #  Vim   #
    #--------#
    (lib.mkIf anyWantsVim {
      programs.nixvim = {
        enable = true;
        defaultEditor = true;
        viAlias = true;
        vimAlias = true;

        plugins = {
          nix.enable = true;
          lightline.enable = true;
          lspconfig.enable = true;
          lastplace.enable = true;
        };

        opts = {
          clipboard = "unnamedplus";

          # Appearance
          number = true;
          relativenumber = true;
          ruler = true;
          wrap = false;

          # Formatting
          autoindent = true;
          expandtab = true;
          tabstop = 2;
          shiftwidth = 2;

          # Search & History
          incsearch = true;
          hlsearch = true;
          history = 700;
        };
      };
    })

    #---------#
    #  Shells #
    #---------#
    (lib.mkIf anyWantsZsh  { programs.zsh.enable = true; })
    (lib.mkIf anyWantsFish { programs.fish.enable = true; })
  ];
}
