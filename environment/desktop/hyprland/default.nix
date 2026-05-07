# environment/desktop/hyprland/default.nix

#-----------------------------------------#
#  Hyprland Window Manager Configuration  #
#-----------------------------------------#

# The user perceives keybinds, window rules, and the compositor itself.
# System-level enabling and HM-level config live together via dual-export.
#
# hyprland.conf contains the main compositor config (keybinds, animations,
# window rules, monitor layout). It's loaded via extraConfig so it can be
# edited as a plain .conf file without touching Nix.

{
  nixos = { config, pkgs, lib, inputs, ... }:
  let
    users = lib.attrValues config.userSettings;
    anyWantsHyprland = lib.any (u: u.desktop.environment == "hyprland") users;
  in {
    config = lib.mkIf anyWantsHyprland {

      programs.hyprland = {
        enable = true;
        xwayland.enable = true;
        withUWSM = false;
        package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
        portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };

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
    };
  };

  home = { config, pkgs, lib, inputs, ... }:
  let
    user = config.userSettings;
  in {
    config = lib.mkIf (user.desktop.environment == "hyprland") {

      xdg.portal = {
        config.common.default = "*";
        extraPortals = [ inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland ];
      };

      wayland.windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;
        systemd = {
          enable = true;
          enableXdgAutostart = true;
          variables = [ "--all" ];
        };
        package = null;       # Use the NixOS module's package
        portalPackage = null;

        settings = {
          "$mod" = "SUPER";
        };

        extraConfig = builtins.readFile ./hyprland.conf;
      };

      wayland.systemd.target = "hyprland-session.target";

      programs.hyprlock.enable = true;
      programs.hyprshot = {
        enable = true;
        saveLocation = "$HOME/images/screenshots";
      };

      home.packages = [
        inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland
      ];
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
