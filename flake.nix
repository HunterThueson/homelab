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
    system = "x86_64-linux";
    inherit (nixpkgs) lib;
    flakeRoot = ./.;
    mkHosts = import ./lib/mkHosts.nix { inherit inputs lib flakeRoot; };
    keyboardPresets = import ./lib/presets/keyboards.nix { inherit lib; };
    monitorPresets  = import ./lib/presets/monitors.nix { inherit lib; };
    gpuPresets      = import ./lib/presets/gpus.nix { inherit lib; };
  in 

  {

    nixosConfigurations = mkHosts {
      hephaestus = {
        users = [ "hunter" "ash" ];

        hostSettings = {
          system = "x86_64-linux";
          type = "desktop";
          role = [ "workstation" "gaming" "writing" ];
          hardware = {
            gpu = {
              enable = true;
              model = gpuPresets.nvidia.rtx3090;
            };
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

        hostSettings = {
          system = "x86_64-linux";
          type = "laptop";
          role = [ "workstation" "gaming" "writing" ];
          hardware = {
            touchpad.enable = true;                   # assigning the role "laptop" should do this by default, this just shows it's overrideable
            bluetooth.enable = true;
            keyboard = {
              layout = "qwerty";
              model = keyboardPresets.lenovoThinkPad."built-in";
            };
            monitors = [ monitorPresets.lenovoThinkPad."built-in" ];
          };
        };
      };
    };
  };
}
