# ./modules/userSettings/roles/writer.nix

#----------#
#  Writer  #
#----------#

# Dual-export module for the writer role.
# nixos: 
# home:  

{
  nixos = { config, ... }: {
    users.groups.writer.gid = 1003;
  };

  home = { config, lib, pkgs, ... }:
  let
    isWriter = builtins.elem "writer" config.userSettings.role;
  in {
    config = lib.mkIf isWriter {

      #
      # Note: we're using Obsidian for now because I've been procrastinating for far too long on switching over to
      #   Emacs. Emacs is still the long-term goal (once I've built and gotten used to a config that lends itself
      #   well to the actual process and feel of writing prose), but Obsidian seems to be a reasonably well-crafted
      #   alternative that is more usable for prose out-of-the-box than Emacs will be for a while yet.
      #
      # Still...
      #   TODO: switch over to Emacs, goddamn it Hunter
      #

      programs.obsidian.enable = lib.mkDefault true;                            # If you use a different PKM tool, change this

      programs.git.enable = lib.mkDefault true;                                 # Git is a good tool for writers, too

      programs.bash.bashrcExtra = ''
        # Teleport to $HOME/wiki
        cdw () {
          cd $HOME/wiki
          clear
          eza --icons=auto --group-directories-first
        }
      '';

    };
  };
}
