# ./home/programs/alacritty/alacritty.nix

#---------------------------#
#  Alacritty Configuration  #
#---------------------------#

{ config, pkgs, lib, inputs, ... }:

{
  programs.alacritty.settings = {

    general.import = [
      "./colors/electro-swing.toml"               # import color scheme
    ];

    window = {                                    # window options
      decorations = "none";
      dynamic_padding = true;
      opacity = lib.mkForce 0.97;
      title = "Alacritty";
      class = {
        general = "Alacritty";
        instance = "Alacritty";
      };
      padding = {
        x = 5;
        y = 4;
      };
    };

    cursor = {                                    # cursor options
      blink_interval = 600;
      blink_timeout = 30;
      thickness = 0.1;
      unfocused_hollow = true;
      style = {
        blinking = "On";
        shape = "Beam";
      };
      vi_mode_style = {
        blinking = "Off";
        shape = "Block";
      };
    };

    font = {                                      # font options
      size = 9;
      bold = {
        family = "FiraCode Nerd Font";
        style = lib.mkForce "Retina Bold";
      };
      italic = {
        family = "FiraCode Nerd Font";
        style = lib.mkForce "Retina Italic";
      };
      normal = {
        family = "FiraCode Nerd Font";
        style = lib.mkForce "Retina";
      };
    };
  };
}
