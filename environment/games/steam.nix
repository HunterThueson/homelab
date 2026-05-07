# environment/games/steam.nix

#---------#
#  Steam  #
#---------#

# Enables Steam and related settings on hosts with the "gaming" role.

{ config, lib, ... }:

let
  hasGamingRole = builtins.elem "gaming" config.hostSettings.role;
in {
  config = lib.mkIf hasGamingRole {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
