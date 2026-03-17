# ./system/environment/nix-config.nix

#----------------------------------------#
#  Nix Language & Nixpkgs Configuration  #
#----------------------------------------#

{ config, pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "mbedtls-2.28.10"
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];                       # Enable Flakes
      auto-optimise-store = true;                                               # Automatically optimise nix-store
      allow-dirty = true;                                                       # Allow dirty Git/Mercurial trees
    };

    gc = {                                                                      # Automatic garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };
  };

  nix.settings.allowed-users = [
    "@wheel"
    "@wizard"
  ];

  # Ensure the Wizard group can edit /etc/nixos/ across reboots
  systemd.tmpfiles.rules = [
    "d /etc/nixos 0770 root wizard - -"
  ];
}
