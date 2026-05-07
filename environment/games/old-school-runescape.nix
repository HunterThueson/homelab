# environment/games/old-school-runescape.nix

#------------------------#
#  Old School Runescape  #
#------------------------#

# Installs Bolt Launcher (alternative OSRS client) and dependencies.
# Enabled on hosts with the "gaming" role.

{ config, pkgs, lib, ... }:

let
  hasGamingRole = builtins.elem "gaming" config.hostSettings.role;
in {
  config = lib.mkIf hasGamingRole {
    programs.java = {
      enable = true;
      package = pkgs.jdk17;
    };

    environment.systemPackages = with pkgs; [
      bolt-launcher                                           # alternative launcher for Runescape
      wineWow64Packages.full                                  # Wine compatibility layer (bolt-launcher dep)
    ];
  };
}
