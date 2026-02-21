#  ~/.nixos/flake.nix

{

#--------------------------------------------------#
#  Hunter Thueson's NixOS System Configuration(s)  #
#--------------------------------------------------#

# for high-level management of my NixOS system configuration(s) and their
# dependencies

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

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };
  };

#-----------#
#  Outputs  #
#-----------#

  outputs = inputs @ { self, nixpkgs, home-manager, nixvim, ... }:

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
        inherit system;
        specialArgs = { inherit inputs; };                                    # pass flake inputs to all submodules
        modules = [

          ./system/hephaestus.nix                                             # Per-host entrypoint

          home-manager.nixosModules.home-manager (import ./home)              # Home Manager

          nixvim.nixosModules.nixvim (import ./home/programs/nixvim.nix)      # Nixvim

        ];

      };

    };

    #homeConfigurations."hunter@hephaestus" = home-manager.lib.homeManagerConfiguration {
      #inherit system;
      #pkgs = nixpkgs.legacyPackages.${system};

      #modules = [
        #{
          #wayland.windowManager.hyprland = {
            #enable = true;
            #package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
            #portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;

          #};
        #}
      #];
    #};

  };

}
