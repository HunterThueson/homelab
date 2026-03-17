# ./system/services/emacs-daemon.nix

#-----------------------#
#  Emacs Configuration  #
#-----------------------#

{ config, pkgs, lib, ... }:

let
  cfg = config;
in

with lib;
{
  mkIf (cfg.userEnvironment.editor == "emacs") {
    environment.systemPackages = with pkgs; [
      emacs
    ];

    # Emacs daemon
    services.emacs = {
      enable = true;
      package = pkgs.emacs;
    };

    # Emacs client
    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
    };
  };
}
