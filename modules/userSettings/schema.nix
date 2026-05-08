# modules/userSettings/schema.nix

#----------#
#  Schema  #
#----------#

# NixOS-level userSettings schema (attrsOf submodule).
# Option definitions are shared with the HM schema via ./options.nix.

{ lib, ... }:

let
  userOptions = import ./options.nix { inherit lib; };
in
{
  options.userSettings = lib.mkOption {
    type = lib.types.attrsOf (lib.types.submodule ({ name, ... }: {
      options = userOptions // {
        name = lib.mkOption {
          type    = lib.types.str;
          default = name;
        };
      };
    }));

    default = {};
  };
}
