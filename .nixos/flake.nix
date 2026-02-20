#  ~/.nixos/flake.nix

   #--------------------------------------------------#
   #  Hunter Thueson's NixOS System Configuration(s)  #
   #--------------------------------------------------#

#   for high-level management of my NixOS system configuration(s) and their
#   dependencies

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

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
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
        specialArgs = { inherit inputs; };                            # pass flake inputs to all submodules
        modules = [

          ./system/hephaestus.nix                                     # Per-host entrypoint

        # Home Manager
          home-manager.nixosModules.home-manager (import ./home)

        # Nixvim
          nixvim.nixosModules.nixvim (import ./home/programs/nixvim.nix)
        ];
      };
    };
  };
}
