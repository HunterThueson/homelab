# ./system/default.nix

{ ... }:

{
  imports = [
    ./boot
    ./display
    ./hardware
    ./login-manager
    ./networking
    ./nix
    ./security
    ./users.nix
  ];
}
