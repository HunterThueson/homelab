# hosts/artemis/default.nix

{ ... }:

{
  imports = [
    ./configuration.nix
    ./hardware.nix
  ];
}
