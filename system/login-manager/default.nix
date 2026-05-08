# system/login-manager/default.nix

#-----------------#
#  Login Manager  #
#-----------------#

{ ... }:

{
  imports = [
    ./sddm.nix
    ./greetd.nix
  ];
}
