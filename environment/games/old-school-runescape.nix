# environment/games/old-school-runescape.nix

#------------------------#
#  Old School Runescape  #
#------------------------#

# System-level dependencies for OSRS (Java runtime).
# The client itself (bolt-launcher) is installed per-user via the "gamer" role.

{ config, pkgs, lib, ... }:

let
  users = lib.attrValues config.userSettings;
  anyGamer = lib.any (u: builtins.elem "gamer" u.role) users;
in {
  config = lib.mkIf anyGamer {
    programs.java = {
      enable = true;
      package = pkgs.jdk17;
    };
  };
}
