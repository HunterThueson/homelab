# environment/games/default.nix

#---------#
#  Games  #
#---------#

# Dual-export: game-related system packages and configuration.
# Enabled when hostSettings.role contains "gaming".

{
  nixos = { config, lib, ... }:
  let
    hasGamingRole = builtins.elem "gaming" config.hostSettings.role;
  in {
    imports = [
      ./steam.nix
      ./old-school-runescape.nix
    ];

    config = lib.mkIf hasGamingRole {
      # Shared gaming config that applies to all games goes here
    };
  };

  home = { ... }: {
    # Per-user game config (save locations, launchers, etc.) goes here
  };
}
