# modules/userSettings/hm-schema.nix

#-----------------------------#
#  Home Manager User Schema  #
#-----------------------------#

# Single-user version of userSettings for standalone Home Manager.
# Uses the same option definitions as the NixOS schema (./options.nix)
# but wraps them in a single submodule instead of attrsOf submodule.

{ lib, ... }:

let
  userOptions = import ./options.nix { inherit lib; };
in
{
  options.userSettings = lib.mkOption {
    type = lib.types.submodule {
      options = userOptions;
    };
  };
}
