# ./system/environment/default.nix

{ config, ... }:

{
  imports = [ 
    ./desktop 
    ./userEnvironment.nix
    ./nix-config.nix
  ];
}
