# environment/editor/vim/treesitter.nix

#--------------#
#  Treesitter  #
#--------------#

# Treesitter configuration for nixvim.
# This is imported by nixvim.nix, so no conditional needed here -
# the parent module handles the mkIf.

{ config, lib, ... }:

{
  programs.nixvim.plugins.treesitter = {
    enable = true;
    settings = {
      highlight.enable = true;
      incremental_selection = {
        enable = true;
        keymaps = {
          init_selection = "<Enter>";
          node_incremental = "<Enter>";
          node_decremental = "<Backspace>";
        };
      };
    };
  };

  programs.nixvim.plugins.treesitter-textobjects = {
    enable = true;
    settings = {
      select = {
        enable = true;
        keymaps = {
          "af" = "@function.outer";
          "if" = "@function.inner";
          "ac" = "@class.outer";
          "ic" = "@class.inner";
          "aa" = "@parameter.outer";
          "ia" = "@parameter.inner";
          "ai" = "@conditional.outer";
          "ii" = "@conditional.inner";
          "al" = "@loop.outer";
          "il" = "@loop.inner";
        };
      };
      move = {
        enable = true;
        goto_next_start = {
          "]f" = "@function.outer";
          "]c" = "@class.outer";
          "]a" = "@parameter.inner";
        };
        goto_previous_start = {
          "[f" = "@function.outer";
          "[c" = "@class.outer";
          "[a" = "@parameter.inner";
        };
      };
    };
  };
}
