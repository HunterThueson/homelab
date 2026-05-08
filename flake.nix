# flake.nix

#----------------------------------#
#  Hunter Thueson's NixOS Homelab  #
#----------------------------------#

# for high-level management of my NixOS homelab and its dependencies

{
  description = "Hunter Thueson's NixOS System Configuration(s)";

  #----------#
  #  Inputs  #
  #----------#

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  #-----------#
  #  Outputs  #
  #-----------#

  outputs = inputs @ { self, nixpkgs, home-manager, nixvim, stylix, ... }:

  let
    inherit (nixpkgs) lib;
    flakeRoot = ./.;
    inherit (import ./lib { inherit inputs lib flakeRoot; })
      mkHosts mkHomes keyboardPresets monitorPresets gpuPresets;

    # Shared host definitions — consumed by both mkHosts and mkHomes
    hostDefs = {
      hephaestus = {
        users = [ "hunter" "ash" ];
        stateVersion = "21.11";
        hmStateVersion = "25.11";

        hostSettings = {
          system = "x86_64-linux";
          type = "desktop";
          role = [ "workstation" "writing" ];
          loginManager = "sddm";
          hardware = {
            boot = {
              loader = "systemd-boot";
              device = "/dev/disk/by-id/nvme-eui.0025384141427eb8";
            };
            gpu = [ gpuPresets."rtx3090" ];
            keyboard = {
              layout = "qwerty";
              model = keyboardPresets.zsa.moonlander;
            };
            display = monitorPresets.layouts."m28u-landscape--s2417dg-portrait-right";
          };
        };
      };

      # for comparison:
      artemis = {
        users = [ "hunter" ];
        stateVersion = "25.11";

        hostSettings = {
          system = "x86_64-linux";
          type = "laptop";
          role = [ "workstation" "writing" ];
          loginManager = "sddm";
          hardware = {
            boot.loader = "systemd-boot";
            touchpad.enable = true;                   # assigning the role "laptop" should do this by default, this just shows it's overrideable
            bluetooth = true;
            keyboard = {
              layout = "qwerty";
              model = keyboardPresets.lenovoThinkPad."built-in";
            };
            display = {
              monitors = [ monitorPresets.lenovoThinkPad."built-in" ];
            };
          };
        };
      };
    };

  in
  {
    nixosConfigurations = mkHosts hostDefs;
    homeConfigurations  = mkHomes hostDefs;
  };
}
