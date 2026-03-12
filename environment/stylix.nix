# ./environment/stylix.nix

#------------------------#
#  Stylix Configuration  #
#------------------------#

# Manage color schemes, fonts, and themes across the entire system

{ pkgs, ... }:

{
  stylix = {

    enable = true;

    base16Scheme = ./colors/electro-swing.yaml;

    fonts = {
      sizes.terminal = 9;

      serif = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "Source Code Pro Nerd Font";
      };

      sansSerif = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "Source Code Pro Nerd Font";
      };

      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

  #-----------#
  #  Targets  #
  #-----------#

  # Enable/disable Stylix management of certain parts of the system

    targets = {

      nixvim = {
        enable = true;
        plugin = "mini.base16";
      };

    };

  };
}
