# environment/editor/default.nix

{ ... }:

{
  imports = [
    ./emacs.nix
    ./vim
  ];
}
