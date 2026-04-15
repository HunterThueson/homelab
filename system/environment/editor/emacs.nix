# system/environment/editor/emacs.nix

#-----------------------#
#  Emacs Configuration  #
#-----------------------#

{ config, lib, ... }:

let
  cfg = config;
in

{
  config = lib.mkIf (cfg.userEnvironment.editor == "emacs") {
    environment.variables = { EDITOR = "emacsclient"; };
  };
}
