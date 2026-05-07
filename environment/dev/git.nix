# environment/dev/git.nix

#---------#
#  Git    #
#---------#

# Configures git for users with enableGit = true in userSettings.

{ config, lib, ... }:

let
  user = config.userSettings;
in {
  config = lib.mkIf user.enableGit {
    programs.git = {
      enable = true;
      settings = {
        user.name = user.fullName;
        user.email = user.email;
        init.defaultBranch = "master";
      };
    };
  };
}
