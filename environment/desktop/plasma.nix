# environment/desktop/plasma.nix

#----------------------------#
#  KDE Plasma Configuration  #
#----------------------------#

# The user perceives the full desktop environment.
# Enabled when any user sets desktop.environment to "plasma" or "plasmax11".

{
  nixos = { config, pkgs, lib, ... }:
  let
    users = lib.attrValues config.userSettings;
    anyWantsPlasma = lib.any (u:
      u.desktop.environment == "plasma" || u.desktop.environment == "plasmax11"
    ) users;
  in {
    config = lib.mkIf anyWantsPlasma {
      services.desktopManager.plasma6.enable = true;
      services.desktopManager.plasma6.enableQt5Integration = true;

      environment.systemPackages = with pkgs; [
        wlr-protocols
        kdePackages.plasma-wayland-protocols
        kdePackages.wayland-protocols
        cosmic-protocols
      ];
    };
  };

  home = { config, lib, ... }:
  let
    user = config.userSettings;
  in {
    config = lib.mkIf (user.desktop.environment == "plasma" || user.desktop.environment == "plasmax11") {
      # Per-user Plasma config (themes, panel layout, etc.)
    };
  };
}
