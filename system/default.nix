# ./system/default.nix

{ ... }:

{
  imports = [
    ./boot
    ./display
    ./hardware
    ./login-manager
    ./nix
    ./system-programs.nix
    ./users.nix
  ];
}
