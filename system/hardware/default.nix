# system/hardware/default.nix

{ ... }:

{
  imports = [
    ./gpu
    ./inputDevices
    ./networking.nix
    ./printers.nix
  ];
}
