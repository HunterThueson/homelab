# environment/games/steam.nix

#---------#
#  Steam  #
#---------#

# Enables the Steam runtime when any user on the host has the "gamer" role.

{ config, lib, ... }:

let
  users = lib.attrValues config.userSettings;
  anyGamer = lib.any (u: builtins.elem "gamer" u.role) users;
in {
  config = lib.mkIf anyGamer {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
  };
}
