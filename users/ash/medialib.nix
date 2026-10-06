# users/ash/medialib.nix
#
# Ash's media management CLI (WIP), installed from its own flake.

{ pkgs, inputs, ... }:

{
  home.packages = [
    inputs.medialib.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
