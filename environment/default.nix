# environment/default.nix

{ ... }:

{
  imports = [
    ./desktop
    ./editor
    ./games
    ./services
    ./shell
    ./terminal
    ./themes
  ];
}
