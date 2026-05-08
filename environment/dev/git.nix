# environment/dev/git.nix

#---------#
#  Git    #
#---------#

# Configures git for users with enableGit = true or git enabled by a role.
# Settings apply whenever programs.git.enable is true, regardless of source.

{ config, lib, pkgs, ... }:

let
  user = config.userSettings;
in {
  config = lib.mkMerge [
    (lib.mkIf user.enableGit {
      programs.git.enable = true;
    })
    (lib.mkIf config.programs.git.enable {
      home.packages = [ pkgs.gh ];
      programs.git.settings = {
        user.name = user.fullName;
        user.email = user.email;
        init.defaultBranch = "master";
        pull.rebase = false;
        safe.directory = "/etc/nixos";
        credential."https://github.com".helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
        credential."https://gist.github.com".helper = [
          ""
          "!${pkgs.gh}/bin/gh auth git-credential"
        ];
      };
    })
  ];
}
