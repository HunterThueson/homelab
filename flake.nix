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
    mkHosts = import ./lib/mkHosts.nix { inherit inputs lib flakeRoot; };
    mkHomes = import ./lib/mkHomes.nix { inherit inputs lib flakeRoot; };
    keyboardPresets = import ./lib/presets/keyboards.nix;
    monitorPresets  = import ./lib/presets/monitors.nix { inherit lib; };
    gpuPresets      = import ./lib/presets/gpus.nix;

    # Shared host definitions — consumed by both mkHosts and mkHomes
    hostDefs = {
      hephaestus = {
        users = [ "hunter" "ash" ];
        stateVersion = "21.11";

        hostSettings = {
          system = "x86_64-linux";
          type = "desktop";
          role = [ "workstation" "gaming" "writing" ];
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
            display = {
              alignment = "center";
              monitors = [
                {
                  name = "Gigabyte M28U";
                  resolution = "3840x2160@144";
                  orientation = "landscape";
                  placement = "primary";
                }

                {
                  name = "Dell S2417DG";
                  resolution = "2560x1440@144";
                  orientation = "portrait";
                  placement = {
                    position = "right-of"; 
                    relativeTo = "primary";
                  };
                }
              ];
            };
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
          role = [ "workstation" "gaming" "writing" ];
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
