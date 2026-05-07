# system/users.nix

#-----------------------#
#  User Account Setup   #
#-----------------------#

# Creates system-level user accounts from userSettings.
# Home-manager configuration is handled in environment/.

{ config, lib, pkgs, ... }:

let
  cfg = config.userSettings;

  shellMap = {
    bash = pkgs.bash;
    zsh = pkgs.zsh;
    fish = pkgs.fish;
  };

in {
  config.users.users = lib.mapAttrs (username: user: {
    isNormalUser = true;
    description = user.fullName;
    hashedPassword = user.hashedPassword;
    shell = shellMap.${user.shell} or pkgs.bash;
    extraGroups = lib.optionals user.administrator [ "wheel" "networkmanager" ]
                  ++ user.extraGroups;
  } // user.extraSysConfig) cfg;
}
