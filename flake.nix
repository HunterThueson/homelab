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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

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

  outputs = inputs @ { self, nixpkgs, sops-nix, home-manager, nixvim, stylix, ... }:

  let
    inherit (nixpkgs) lib;
    flakeRoot = ./.;
    inherit (import ./lib { inherit inputs lib flakeRoot; })
      mkHosts mkHomes keyboardPresets monitorPresets gpuPresets;

    #--------------------#
    #  User Definitions  #
    #--------------------#

    userDefs = {
      hunter = {
        nickname      = "Hunter";
        fullName      = "Hunter Thueson";
        email         = "hunter.thueson@gmail.com";
        administrator = true;
        role          = [ "wizard" "developer" "gamer" "writer" ];
        shell         = "bash";
        editor        = { terminal = "vim"; gui = "emacs"; };
        desktop       = { environment = "hyprland"; colorScheme = "electro-swing"; };
        browser.name  = "firefox";
      };

      ash = {
        nickname      = "Ash";
        fullName      = "Ashley Ellison";
        email         = "ash.ellison@proton.me";
        administrator = true;
        role          = [ "wizard" "developer" "writer" ];
        shell         = "bash";
        desktop       = { environment = "plasmax11"; colorScheme = "electro-swing"; };
        browser.name  = "firefox";
      };
    };

    #--------------------#
    #  Host Definitions  #
    #--------------------#

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

      artemis = {
        users = [ "hunter" ];
        stateVersion = "25.11";

        hostSettings = {
          system = "x86_64-linux";
          type = "laptop";
          role = [ "workstation" "writing" ];
          loginManager = "sddm";
          hardware = {
            boot = {
              loader = "systemd-boot";
              device = "/dev/disk/by-uuid/F28D-FD6D";
            };
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
    nixosConfigurations = mkHosts { hosts = hostDefs; users = userDefs; } // {
      installer = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.stylix.nixosModules.stylix
          inputs.hyprland.nixosModules.default
          inputs.nixvim.nixosModules.nixvim
          ./hosts/installer
        ];
      };
    };
    homeConfigurations  = mkHomes { hosts = hostDefs; users = userDefs; };
  };
}
