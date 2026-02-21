# ./home/environment/hyprland.nix

{ config, pkgs, lib, osConfig, inputs, self, ... }:

let
  cfg = osConfig;
  inherit self;
in

{
  imports = [
    inputs.hyprland.homeManagerModules.default
  ];

  config = lib.mkIf (cfg.programs.hyprland.enable == true) {

    xdg.portal = {                                          # I don't really know what XDG portals are or why I need them, but apparently I do
      #enable = true;
      config.common.default = "*";
      extraPortals = [ inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland ];
    };

    #xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh"; 

    wayland = {
      windowManager.hyprland = {
        enable = true;
        xwayland.enable = true;                             # Enable XWayland. Overrides the enableXWayland option of the package. Default value
        systemd = {
          enable = true;                                    # conflicts with UWSM?
          enableXdgAutostart = true;                       # Enable autostart of applications using systemd-xdg-autostart-generator (disabled for now because I don't know what it does and that's the default)
          variables = [ "--all" ];
        };
        package = null;                                     # According to the Home Manager manual, this should be null if I used the NixOS module to install Hyprland
        portalPackage = null;

        settings = {
          "$mod" = "SUPER";
        };

        extraConfig = builtins.readFile ../config/hypr/hyprland.conf;

      };
      systemd.target = "hyprland-session.target";           # Autostart Hyprland upon login
    };

    programs.hyprlock.enable = true;
    programs.hyprshot = {
      enable = true;
      saveLocation = "$HOME/images/screenshots";
    };

    home.packages = [
      inputs.hyprland.packages.${pkgs.system}.xdg-desktop-portal-hyprland
    ];

  };
}
