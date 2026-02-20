# ./system/hardware/inputDevices/default.nix

{ config, ... }:

{
  imports = [
    ./xserver-libinput.nix
    ./zsa-keyboards.nix                 # Enable udev rules for keyboards from ZSA (Moonlander, Voyager, ErgoDox EZ, etc.)
  ];
}
