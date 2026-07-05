# environment/themes/stylix.nix

#------------------------#
#  Stylix Configuration  #
#------------------------#

# Color schemes, fonts, and theming — the user perceives all of it.
# TODO: Wire to userSettings.desktop.colorScheme

{
  nixos = { pkgs, lib, ... }: {
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

        # Plasma-native Qt theming — Breeze + `org.kde.desktop`. [1]
        qt.platform = lib.mkForce "kde";
      };
    };
  };

  home = { ... }: {
    # Per-user Stylix HM targets go here
  };
}


#-------------#
#  Footnotes  #
#-------------#

# 1: `platform` is forced to "kde" for Plasma-native Qt theming (Breeze widget
#    style + the `org.kde.desktop` Quick Controls style). Setting "kde" makes
#    `nixos-rebuild` print a persistent warning that "kde" isn't a fully
#    supported platform value; that warning is knowingly left in place. The
#    obvious way to silence it is to set "qtct" instead — but "qtct" selects the
#    qt5ct/Kvantum path (`recommendedStyle.qtct = "kvantum"`), loading a
#    `kvantum` QtQuick.Controls style into the session. plasmashell ships no such
#    QML module, so its `import QtQuick.Controls` calls fail and the shell renders
#    black (panels, widgets, and wallpaper vanish while kwin still draws normal
#    windows). That is the tradeoff behind tolerating the warning.
