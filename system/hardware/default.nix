# system/hardware/default.nix

{ ... }:

{
  imports = [
    ./gpu
    ./input-devices
  ];
}
