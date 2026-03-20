# environment/editor/vim/treesitter.nix

#--------------#
#  Treesitter  #
#--------------#

{ config, lib, ... }:

let
  cfg = config.userSettings;
in

{
  plugins.treesitter = lib.mkIf (cfg.editor == "vim";) {
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

  plugins.treesitter-textobjects = lib.mkIf (cfg.editor == "vim";) {
    enable = true;
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
      gotoNextStart = {
        "]f" = "@function.outer";
        "]c" = "@class.outer";
        "]a" = "@parameter.inner";
      };
      gotoPreviousStart = {
        "[f" = "@function.outer";
        "[c" = "@class.outer";
        "[a" = "@parameter.inner";
      };
    };
  };
}
