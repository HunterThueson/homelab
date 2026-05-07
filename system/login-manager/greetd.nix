# system/login-manager/greetd.nix

#----------#
#  greetd  #
#----------#

# Enables greetd with tuigreet when hostSettings.loginManager = "greetd".

{ config, pkgs, lib, ... }:

let
  cfg = config.hostSettings;
  tuiTimeFormat = "\"%A, %Y-%m-%d -- %-I:%M ... %S\"";
  tuiTheme = "\"border=red;text=magenta;time=red;container=black;prompt=magenta;input=red;greet=magenta;action=magenta;button=red\"";
  tuiGreeting = "\"\\\"Do not meddle in the affairs of wizards, for they are subtle and quick to anger.\\\" -J.R.R. Tolkien\"";
in {
  config = lib.mkIf (cfg.loginManager == "greetd") {
    services.greetd = {
      enable = true;
      restart = true;
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -g ${tuiGreeting} --time --time-format ${tuiTimeFormat} --theme ${tuiTheme} --asterisks --cmd Hyprland";
          user = "greeter";
        };
      };
    };

    environment.etc."greetd.environments".text = ''
      Hyprland
    '';
  };
}
