# hosts/hephaestus/default.nix

{ ... }:

{
  imports = [
    ./configuration.nix
    ./hardware.nix
  ];
}
