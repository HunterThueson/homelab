# system/environment/editor/vim.nix

#---------------------#
#  Vim Configuration  #
#---------------------#

{ config, lib, ... }:

let
  cfg = config;
in

{
  config = lib.mkIf (cfg.userEnvironment.editor == "vim") {
    environment.variables = { EDITOR = "nvim"; };
  };
}
