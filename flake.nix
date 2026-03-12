#  ~/.nixos/flake.nix

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
  in 

  {

    #---------#
    #  Hosts  #
    #---------#

    nixosConfigurations = {

      hephaestus = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };                                    # pass flake inputs to all submodules
        modules = [

          ./system/hephaestus.nix                                             # Per-host entrypoint

          home-manager.nixosModules.home-manager (import ./home)              # Home Manager

          stylix.nixosModules.stylix (import ./environment/stylix.nix)        # Stylix

          nixvim.nixosModules.nixvim (import ./home/programs/nixvim.nix)      # Nixvim

        ];

      };

      artemis = lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [

          home-manager.nixosModules.home-manager (import ./home)              # Home Manager

          stylix.nixosModules.stylix (import ./environment/stylix.nix)        # Stylix

          nixvim.nixosModules.nixvim (import ./home/programs/nixvim.nix)      # Nixvim

        ];

      };

    };

  };
}
