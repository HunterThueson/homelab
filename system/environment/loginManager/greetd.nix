# ./system/environment/login-manager/greetd.nix

#------------------------#
#  greetd Configuration  #
#------------------------#


{ config, pkgs, ... }:

let 
  cfg = config;
  inherit (pkgs) lib;
  tuiTimeFormat = "\"%A, %Y- %-m- %d -- %-I: %M ... %S\"";
  tuiTheme = "\"border=red;text=magenta;time=red;container=black;prompt=magenta;input=red;greet=magenta;action=magenta;button=red\"";
  tuiGreeting = "\"\"Do not meddle in the affairs of wizards, for they are subtle and quick to anger.\" -J.R.R. Tolkien\"";
in

with lib;
{
  mkIf (cfg.userEnvironment == "greetd") {
    services.greetd = {
      enable = true;
      useTextGreeter = true;                        # for tuigreet -- some systemd configuration will be adjusted to avoid interrupting TUI
      restart = true;                               # usually good to have on "true," but if you ever set up autologin this needs to be turned off
      settings = {
        default_session = {
          command = "${pkgs.greetd.tuigreet}/bin/tuigreet -g ${tuiGreeting} --time --time-format ${tuiTimeFormat} --theme ${tuiTheme} --asterisks --cmd start-hyprland";
          user = "greeter";
        };
      };
    };

    environment.etc."greetd.environments".text = ''
      Hyprland
    '';

  };
}
