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

  capitalize = s:
    let len = builtins.stringLength s;
    in if len == 0 then s
       else lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (len - 1) s;

in {
  config.users.users = lib.mapAttrs (username: user: {
    isNormalUser = true;
    description = if user.nickname != "" then user.nickname else capitalize username;
    hashedPasswordFile = config.sops.secrets."${username}-hashed-password".path;
    shell = shellMap.${user.shell} or pkgs.bash;
    extraGroups = lib.optionals user.administrator [ "wheel" "networkmanager" ]
                  ++ lib.optionals (builtins.elem "wizard" user.role) [ "wizard" ]
                  ++ user.extraGroups;
  }) cfg;
}
