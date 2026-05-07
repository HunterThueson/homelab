# modules/userSettings/default.nix

#-----------------#
#  User Settings  #
#-----------------#

# Schema only - backend implementation lives in:
#   - system/users.nix (user account creation)
#   - environment/ (home-manager configuration)

{ ... }:

{
  imports = [
    ./schema.nix
  ];
}
