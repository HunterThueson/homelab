# environment/editor/default.nix

# Vim/nixvim is system-level (in system/system-programs.nix).
# Only HM-level editor config lives here.

{ ... }:

{
  imports = [
    ./emacs
  ];
}
