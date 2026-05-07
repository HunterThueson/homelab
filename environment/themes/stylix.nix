# environment/themes/stylix.nix

#------------------------#
#  Stylix Configuration  #
#------------------------#

# Color schemes, fonts, and theming — the user perceives all of it.
# TODO: Wire to userSettings.desktop.colorScheme

{
  nixos = { pkgs, ... }: {
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

      targets = {
        nixvim = {
          enable = true;
          plugin = "mini.base16";
        };
      };
    };
  };

  home = { ... }: {
    # Per-user Stylix HM targets go here
  };
}
