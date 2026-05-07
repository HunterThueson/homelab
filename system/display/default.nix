# system/display/default.nix

#-----------#
#  Display  #
#-----------#

{ ... }:

{
  imports = [
    ./wayland.nix
    ./xorg.nix
  ];
}
