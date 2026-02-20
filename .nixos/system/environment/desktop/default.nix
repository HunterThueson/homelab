# ./system/environment/desktop/default.nix

{ config, ... }:

{
  imports = [
    ./plasma.nix
    ./hyprland.nix
  ];
}
