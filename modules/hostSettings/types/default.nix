# modules/hostSettings/types/default.nix

#--------------#
#  Host Types  #
#--------------#

{ ... }:

{
  imports = [
    ./desktop.nix
    ./laptop.nix
    ./server.nix
  ];
}
