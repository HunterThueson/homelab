# system/networking/default.nix

{ ... }:

{
  imports = [
    ./netns.nix
    ./ivpn
    ./wrappers.nix
    ./tor.nix
    ./wifi.nix
  ];
}
