# environment/shell/default.nix

#---------#
#  Shell  #
#---------#

# Dual-export: system-level enabling + per-user HM config in one place.
# nixos: enables zsh/fish system-wide if any user on the host wants them
# home:  per-user shell prompt config (starship, etc.)

{
  nixos = { config, lib, ... }:
  let
    users = lib.attrValues config.userSettings;
  in {
    config = lib.mkMerge [
      (lib.mkIf (lib.any (u: u.shell == "zsh")  users) { programs.zsh.enable = true; })
      (lib.mkIf (lib.any (u: u.shell == "fish") users) { programs.fish.enable = true; })
    ];
  };

  home = { ... }: {
    imports = [
      ./bash.nix
      ./starship.nix
    ];
  };
}
