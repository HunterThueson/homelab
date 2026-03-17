# ./home/default.nix

{ config, pkgs, home-manager, inputs, ... }:

{
  home-manager.useGlobalPkgs = true;                        # make sure NixOS and Home Manager are using the same `nixpkgs`
  home-manager.useUserPackages = true;                      # enable installation of user packages
  home-manager.extraSpecialArgs = { inherit inputs; };      # pass flake inputs to all modules
  home-manager.backupFileExtension = "backup";              # move existing files by appending ext. instead of throwing errors

  home-manager.sharedModules = [
    (import ./standard-config.nix)
    (import ./programs/alacritty/alacritty.nix)
    (import ./environment/starship.nix)
    (import ../system/services/kanshi.nix)
    (import ./environment/hyprland.nix)
  ];

  # User modules
  home-manager.users.hunter.imports = [
    ./hunter.nix
  ];

  home-manager.users.ash.imports = [
    ./ash.nix
  ];
}
