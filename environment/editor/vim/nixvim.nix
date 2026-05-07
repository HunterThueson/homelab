# environment/editor/vim/nixvim.nix

#------------------------#
#  Nixvim Configuration  #
#------------------------#

# Manage Neovim configuration with Nix syntax.
# Enables when any user has editor.terminal = "vim"

{ config, lib, pkgs, ... }:

let
  users = config.userSettings;

  # Check if any user wants vim as their terminal editor
  anyUserWantsVim = lib.any (u: u.editor.terminal == "vim") (lib.attrValues users);

in {
  imports = [
    ./treesitter.nix
  ];

  config = lib.mkIf anyUserWantsVim {
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
  };
}
