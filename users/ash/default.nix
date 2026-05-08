# users/ash/
#
# User-specific HM modules for Ash.

{ pkgs, ... }:

{
  imports = [
    ./packages.nix
    ./services.nix
  ];
}
