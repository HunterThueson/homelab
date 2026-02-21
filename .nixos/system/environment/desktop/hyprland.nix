# ./system/environment/hyprland.nix

  ###########################################
  #  Hyprland Window Manager Configuration  #
  ###########################################

{ config, pkgs, lib, inputs, home, self, ... }:

let
  cfg = config.programs.hyprland;
  inherit inputs;
  inherit home;
  self = inputs.self;
in

{

  config = lib.mkIf (cfg.enable == true) {

  #-------------------------#
  #  NixOS Module Settings  #
  #-------------------------#
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

    # Enable Cachix so I don't have to build `hyprland` from source every time I `nixos-rebuild`
    nix.settings = {
      substituters = ["https://hyprland.cachix.org"];
      trusted-substituters = ["https://hyprland.cachix.org"];
      trusted-public-keys = ["hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="];
    };

    programs.hyprland = {
      xwayland.enable = true;                   # I will probably need this for OSRS or something
      withUWSM = false;
      package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
      portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    };


  };
}
# >EOF

    ########################
    #  TODO: The Big List  #
    ########################

    # Hyprland ships incredibly bare-bones; the idea is to give you control, at the price of needing to do a lot
    # more work. There are a lot of things most DEs ship with that Hyprland does not. Let's make a list of all the
    # things we'll need to configure.

    #--------------------#
    # Must-have software #        (more specifically, stuff I have not yet acquired)
    #--------------------#

      # A notification daemon
      # -- Starting method: automatically via D-Bus activation when a notification is emitted
      # -- Examples: swaync (fancy), tiramisu (unobtrusive)

      # XDG Desktop Portal
      # -- Starting method: automatic when using systemd
      # -- Handles a lot of stuff for your desktop, like file pickers, screen sharing, etc.

      # Authentication Agent
      # -- Starting method: manual (exec-once)
      # -- Pops up a window asking for a password when an app wants to elevate privileges
      # -- Examples: hyprpolkitagent

      # Qt Wayland Support
      # -- Library
      # -- install `qt5-wayland` and `qt6-wayland`

      # Pipewire
      # -- Starting method: automatic when using systemd
      # -- Not required, but screen sharing will not work without it. Bottom of the list for now.

    #---------------#
    # Status Bar(s) #
    #---------------#
    
    # Waybar
    # ashell            (ashell is a boilerplate super-simple bar that just works. Maybe do this one first.)

    # Quickshell        (this one's going to be a beast to learn, but it'll be incredibly rewarding once I do.)

    #####################
    #  Random Bullshit  #
    #####################

    # I haven't the SLIGHTEST FUCKIN CLUE what this does
    #wayland.windowManager.hyprland.settings = {
      #"$mod" = "SUPER";
      #bind = [
        #"$mod, F, exec, firefox"
      #] ++ (
        # workspaces
        # binds $mod + [shift +] {1..9} to [move to] workspace {1..9}
        #builtins.concatLists (builtins.genList (i:
        #let ws = i + 1;
        #in [
          #"$mod, code:1${toString i}, workspace, ${toString ws}"
          #"$mod SHIFT, code:1${toString i}, movetoworkspace, ${toString ws}"
        #]
        #)))
    #};
