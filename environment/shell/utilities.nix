# ./environment/shell/utilities.nix

#-------------------#
#  Shell Utilities  #
#-------------------#

{ pkgs, ... }:

{
  home.packages = [

    # *top / process monitoring utilities
    pkgs.gotop
    pkgs.bottom

    # system info
    pkgs.fastfetch
  ];
}
