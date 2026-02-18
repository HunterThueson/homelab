# ./system/environment/nix-config.nix

  ##########################################
  #  Nix Language & Nixpkgs Configuration  #
  ##########################################

{ config, pkgs, inputs, ... }:

{

  ###############################
  #  Nix/Nixpkgs/NixOS options  #
  ###############################

  # Allow unfree/proprietary software
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "mbedtls-2.28.10"
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];                       # Enable Flakes
      auto-optimise-store = true;                                               # Automatically optimise nix-store
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };
  };

}
