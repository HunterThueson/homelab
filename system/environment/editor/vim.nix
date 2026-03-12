# ./system/environment/editor/vim.nix

#---------------------#
#  Vim Configuration  #
#---------------------#

{ config, lib, ... }: 

let
  cfg = config;
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
