# modules/hostSettings/default.nix

{ ... }:

{
  imports = [
    ./schema.nix        # Option declarations
    ./backend.nix       # Option definitions
  ];
}
