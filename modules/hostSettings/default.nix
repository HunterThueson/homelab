# modules/hostSettings/default.nix

#-----------------#
#  Host Settings  #
#-----------------#

# Schema only - backend implementation lives in system/

{ ... }:

{
  imports = [
    ./schema.nix
    ./types
  ];
}
