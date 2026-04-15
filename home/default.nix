# home/default.nix

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
    (import ../environment/editor/emacs)
  ];

  # User modules
  home-manager.users.hunter.imports = [
    ./hunter.nix
    ./environment/hyprland.nix
  ];

  home-manager.users.ash.imports = [
    ./ash.nix
    ./environment/hyprland.nix
  ];
}
