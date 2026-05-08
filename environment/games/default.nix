# environment/games/default.nix

#---------#
#  Games  #
#---------#

# Dual-export: system-level game runtimes + per-user game packages.
# nixos: enables Steam runtime, Java — when any user has the "gamer" role
# home:  installs game clients (bolt-launcher, discord) — per-user "gamer" role

{
  nixos = { config, lib, ... }:
  let
    users = lib.attrValues config.userSettings;
    anyGamer = lib.any (u: builtins.elem "gamer" u.role) users;
  in {
    imports = [
      ./steam.nix
      ./old-school-runescape.nix
    ];
  };

  home = { config, pkgs, lib, ... }:
  let
    user = config.userSettings;
    isGamer = builtins.elem "gamer" user.role;
  in {
    config = lib.mkIf isGamer {
      home.packages = with pkgs; [
        discord                                               # chat client
        bolt-launcher                                         # alternative launcher for Runescape
        wineWow64Packages.full                                # Wine compatibility layer (bolt-launcher dep)
      ];
    };
  };
}
