# environment/dev/default.nix

#---------------------#
#  Development Tools  #
#---------------------#

# Per-user development tool configuration.
# Pure HM module — no system-level concerns.

{ ... }:

{
  imports = [
    ./git.nix
  ];
}
