# lib/default.nix

{ ... }:

{
  mkHosts = import ./mkHosts.nix;
  mkHomes = import ./mkHomes.nix;
}
