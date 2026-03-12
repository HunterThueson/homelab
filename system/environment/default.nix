# ./system/environment/default.nix

{ config, ... }:

{
  imports = [ 
    ./desktop 
    ./userEnvironment.nix
    ./nix-config.nix
    ./packages.nix
  ];
}
