# ./modules/userSettings/backend.nix

#-----------#
#  Backend  #
#-----------#

{ config, lib, pkgs, flakeRoot, ... }:

let
  users = config.userSettings;
  shellMap = {
    bash = pkgs.bash;
    zsh = pkgs.zsh;
    fish = pkgs.fish;
  };
in

{
  config = {
    # System level -- one entry per user, generated automatically
    users.users = lib.mapAttrs (username: cfg: {
      isNormalUser    = true;
      description     = cfg.fullName;
      hashedPassword  = cfg.hashedPassword;
      shell           = shellmap.${cfg.shell} or pkgs.bash;
      extraGroups     = lib.optionals cfg.administrator [ "wheel" "networkmanager" ]
                     ++ cfg.extraGroups;
    } // cfg.extraSysConfig) users;

    # Home Manager level -- one entry per user, generated automatically
    home-manager.users = lib.mapAttrs (username: cfg: {
      home.username       = username;
      home.homeDirectory  = "/home/${username}";
      home.packages       = cfg.packages;

      programs.git = lib.mkIf cfg.enableGit {
        enable    = true;
        userName  = cfg.fullName;
        userEmail = cfg.email;
      };
    } // cfg.extraHomeConfig) users;
  };
}
