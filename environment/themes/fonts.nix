# environment/themes/fonts.nix

#----------------------#
#  Font Configuration  #
#----------------------#

# Fonts are perceptual — the user sees them everywhere.

{
  nixos = { pkgs, ... }: {
    console.font = "Lat2-Terminus16";

    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        nerd-fonts.fira-code
        nerd-fonts.droid-sans-mono
        nerd-fonts.fira-mono
        nerd-fonts.hack
        nerd-fonts.arimo
        nerd-fonts.im-writing
      ];
      fontconfig.defaultFonts = {
        monospace = [ "FiraCode Nerd Font" ];
      };
    };
  };

  home = { ... }: {
    # Per-user font config goes here (e.g. fontconfig overrides)
  };
}
