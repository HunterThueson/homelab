# ./system/environment/editor/vim.nix

  #---------------------#
  #  Vim Configuration  #
  #---------------------#

{ config, pkgs, ... }: 

let
  cfg = config;
  inherit (pkgs) lib;
in

with lib;
{
  mkIf (cfg.userEnvironment.editor == "vim") {
    environment = {
      variables = { EDITOR = "vim"; };
      shells = with pkgs; [ bash ];
    };
  };
}
