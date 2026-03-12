# ./system/hardware/inputDevices/default.nix

{ ... }:

{
  imports = [
    ./mouse-and-keyboard.nix
    ./zsa-keyboards.nix                 # Enable udev rules for keyboards from ZSA (Moonlander, Voyager, ErgoDox EZ, etc.)
  ];
}
