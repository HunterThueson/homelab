# ./system/default.nix

{ ... }:

{
  imports = [
    ./boot
    ./display
    ./hardware
    ./login-manager
    ./nix
    ./security
    ./users.nix
  ];
}
