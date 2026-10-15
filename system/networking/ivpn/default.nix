# networking/ivpn/default.nix

{ ... }:

{
  imports = [
    ./host.nix
    ./torrent.nix
  ];
}
