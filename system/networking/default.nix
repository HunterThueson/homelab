# system/networking/default.nix

{ ... }:

{
  imports = [
    ./netns.nix
    ./ivpn-torrent.nix
    ./ivpn-host.nix
    ./wrappers.nix
    ./tor.nix
  ];
}
