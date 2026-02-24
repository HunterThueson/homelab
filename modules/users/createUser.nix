# ./modules/users/createUser.nix

# Function for creating a user

username: { config, pkgs, home-manager, ... }:

let
  cfg = config;
  inherit (pkgs) lib;
in

with lib;
{
  imports = [
    ./userSettings.nix
  ];

  config = {

  };

}
