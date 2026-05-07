# system/hardware/default.nix

{ ... }:

{
  imports = [
    ./gpu
    ./inputDevices
    ./printers.nix
  ];
}
