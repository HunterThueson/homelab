# environment/desktop/plasma.nix

#----------------------------#
#  KDE Plasma Configuration  #
#----------------------------#

# The user perceives the full desktop environment.
# TODO: Wire to userSettings.desktop.environment == "plasma" or "plasmax11"

{
  nixos = { config, pkgs, lib, ... }: {
    config = lib.mkIf (config.specialisation != {}) {
      services.desktopManager.plasma6.enable = lib.mkDefault true;
      services.desktopManager.plasma6.enableQt5Integration = lib.mkDefault true;
      services.displayManager.defaultSession = "plasmax11";
      environment.systemPackages = with pkgs; [
        wlr-protocols
        kdePackages.plasma-wayland-protocols
        kdePackages.wayland-protocols
        cosmic-protocols
      ];
    };
  };

  home = { ... }: {
    # Per-user Plasma config (themes, panel layout, etc.)
  };
}
