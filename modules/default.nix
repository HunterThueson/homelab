# ./modules/default.nix

{ ... }:

{
  imports = [
    ./userSettings
    ./hostSettings
  ];
}
