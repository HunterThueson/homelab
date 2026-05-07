# environment/desktop/hyprland.nix

#-----------------------------------------#
#  Hyprland Window Manager Configuration  #
#-----------------------------------------#

# The user perceives keybinds, window rules, and the compositor itself.
# System-level enabling and HM-level config live together here.
# TODO: Wire to userSettings.desktop.environment == "hyprland"

{
  nixos = { config, pkgs, lib, inputs, ... }:
  let
    cfg = config.programs.hyprland;
  in {
    config = lib.mkIf cfg.enable {

      environment.systemPackages = with pkgs; [
        wlr-protocols
        kdePackages.wayland-protocols
        dunst
        kitty
        libnotify
        networkmanagerapplet
        rofi
        swww
        waybar
      ];

      programs.uwsm = {
        enable = false;
        waylandCompositors = {
          hyprland = {
            prettyName = "Hyprland";
            comment = "Hyprland compositor managed by UWSM";
            binPath = "/run/current-system/sw/bin/Hyprland";
            extraArgs = [ ];
          };
        };
      };

      # Enable Cachix so we don't have to build hyprland from source
      nix.settings = {
        substituters = ["https://hyprland.cachix.org"];
        trusted-substituters = ["https://hyprland.cachix.org"];
        trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
      };

      programs.hyprland = {
        xwayland.enable = true;
        withUWSM = false;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
    };
  };

  home = { config, lib, ... }:
  let
    user = config.userSettings;
  in {
    config = lib.mkIf (user.desktop.environment == "hyprland") {
      # Per-user Hyprland config (keybinds, window rules, etc.)
      # wayland.windowManager.hyprland.settings = { ... };
    };
  };
}

# TODO: The Big List
#
# Hyprland ships bare-bones. Things still needed:
#   - Notification daemon (swaync, tiramisu)
#   - XDG Desktop Portal
#   - Authentication Agent (hyprpolkitagent)
#   - Qt Wayland Support (qt5-wayland, qt6-wayland)
#   - Pipewire (for screen sharing)
#   - Status bar (Waybar, ashell, Quickshell)
