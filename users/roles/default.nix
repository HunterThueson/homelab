# ./users/groups/default.nix

# Returns a list of group/role module paths.
# Each may be a plain NixOS module or a dual-export { nixos; home; }.

[
  ./wizard.nix
]
