# environment/shell/bash.nix

#--------#
#  Bash  #
#--------#

# Default bash configuration applied to users with shell = "bash".
# Per-user overrides (extra aliases, functions, PATH entries) can be
# set via extraHomeConfig in users/*.nix.

{ config, lib, ... }:

let
  user = config.userSettings;
in {
  config = lib.mkIf (user.shell == "bash") {
    programs.bash = {
      enable = true;

      historyFile = "$HOME/.bash_history";
      historyIgnore = [
        "ls"
        "eza"
        "cd"
        "exit"
        "clear"
      ];

      shellOptions = [
        "histappend"                  # Append to history file rather than replacing it
        "checkwinsize"                # Update LINES and COLUMNS after each command
        "extglob"                     # Extended globbing
        "globstar"                    # Recursive globbing with **
        "checkjobs"                   # Warn if closing shell with running jobs
      ];

      sessionVariables = rec {
        XDG_CONFIG_HOME = "$HOME/.config";
        XDG_CACHE_HOME = "$HOME/.cache";
        STARSHIP_CONFIG = "${XDG_CONFIG_HOME}/starship.toml";
        STARSHIP_CACHE = "${XDG_CACHE_HOME}/starship";
      };

      shellAliases = {
        # ls replacements (eza)
        ls  = "eza -G --color=auto --icons=auto --group-directories-first";
        lsa = "eza -Gau --git --time-style long-iso --color=always --icons";
        lsd = "eza -D --color=auto --icons=auto";
        lst = "eza -T --color=auto --icons=auto --group-directories-last";

        # Navigation
        ghs = "git status";

        # Drop-in replacements
        find = "fd";

        # Terminal clearing
        cl   = "clear";
        cls  = "clear && eza -G --color=auto --icons=auto --group-directories-first";
        clsa = "clear && eza -Gau --git --time-style long-iso --color=always --icons";
        clsd = "clear && eza -D --color=auto --icons=auto";
        clst = "clear && eza -T --color=auto --icons=auto --group-directories-last";
      };

      bashrcExtra = ''
        # Teleport to ~/docs (org-roam directory)
        cdd () {
          cd $HOME/docs
          clear
          sleep 0.01
          eza -DG --icons=auto --group-directories-first
        }

        # Teleport to config directory
        cdc () {
          cd $XDG_CONFIG_HOME
          clear
          eza -DG --icons=auto --group-directories-first
        }

        # gh wrapper to make listing issues easier
        gh () {
          if [[ $@ == "issue list" ]]; then
            command gh issue list -L 100
          else
            command gh "$@"
          fi
        }
      '';
    };

    home.sessionPath = [
      "/usr/local/bin/"
      "/etc/nixos/scripts"
      "$HOME/bin/"
      "$HOME/.cargo/bin/"
    ];
  };
}
