# ./system/services/emacs-daemon.nix

  ################################
  #  Emacs Daemon Configuration  #
  ################################

{ config, pkgs, inputs, ... }:

let
  cfg = config;
  inherit (pkgs) lib;
in

with lib;
{
  mkIf (cfg.userEnvironment.editor == "emacs") {
    environment.systemPackages = with pkgs; [
      emacs
    ];
    services.emacs = {
      enable = true;
      package = pkgs.emacs;
    };
  };
}
