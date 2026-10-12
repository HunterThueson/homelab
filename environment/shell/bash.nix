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

        # Drop-in replacements
        find = "fd";

        # Terminal clearing
        cl   = "clear";
        cls  = "clear && eza -G --color=auto --icons=auto --group-directories-first";
        clsa = "clear && eza -Gau --git --time-style long-iso --color=always --icons";
      };

      bashrcExtra = ''
        # tree view; leading integer sets the depth, `-d` lists directories only
        lst () {
          local opts=(-T)
          local depth=""
          while (( $# )); do                                                    # leading depth and `-d` in either order
            if [[ $1 =~ ^[[:digit:]]+$ ]]; then
              depth="$1"
            elif [[ $1 == "-d" ]]; then
              opts+=(-D)
            else
              break
            fi
            shift
          done
          if [[ -n $depth ]]; then
            opts+=(-L "$(( depth + 1 ))")                                       # `lst 3` becomes `eza -L 4` [1]
          fi
          command eza "''${opts[@]}" --color=auto --icons=auto \
            --group-directories-last "$@"
        }

        # same as `lst` function, but directories only; bare `lsd` stays flat [2]
        lsd () {
          if [[ $1 =~ ^[[:digit:]]+$ ]]; then
            lst -d "$@"
          else
            lst -d 0 "$@"
          fi
        }

        # same as `lst` function, but clear the terminal first
        clst () {
          clear; lst "$@"
        }

        # same as `lsd` function, but clear the terminal first
        clsd () {
          clear; lsd "$@"
        }

        # cd wrapper for quick home teleports
        cd () {
          if [[ $# -eq 0 ]]; then
            command cd $HOME
            clear
            eza -DG --icons=auto --group-directories-first
          else
            command cd "$@"
          fi
        }

        # Teleport to config directory
        cdc () {
          cd $XDG_CONFIG_HOME
          clear
          eza -DG --icons=auto --group-directories-first
        }

        # Teleport to ~/docs (org-roam directory)
        cdd () {
          cd $HOME/docs
          clear
          eza -DG --icons=auto --group-directories-first
        }
      '';
    };

  };
}

#-------------#
#  Footnotes  #
#-------------#

# 1: `lst N` passes `eza -L $((N + 1))`, so the number counts levels of *nesting*
#    — how many directories get expanded — rather than levels of output. `lst 1`
#    shows the cwd plus one expanded sublevel, which is the shallowest listing
#    that is actually a tree. eza's own `-L` counts the flat listing as level 1,
#    so its `-L 1` recurses into nothing (functionally `ls`) and every value is
#    one lower than the equivalent `lst` argument. The shift exists so that no
#    accepted argument wastes itself on a non-tree: under eza's counting the
#    useful range starts at 2, here it starts at 1. `lst 0` still degrades to
#    the flat `-L 1` listing rather than erroring, which is why the arithmetic
#    needs no floor — `-L 0` (a bare `.` with no entries) is unreachable. If the
#    preference ever flips back to matching eza's counting, the whole mapping is
#    the one arithmetic expression above.
#
# 2: `lsd` and `lst -d` differ deliberately in the no-argument case. `lst -d`
#    sets no depth, so it recurses without limit; bare `lsd` injects a depth of
#    0 — the flat `-L 1` from footnote 1 — to stay in the cwd, preserving the
#    behavior of the old `lsd` alias (`eza -D`). Given an explicit depth the two
#    are identical: `lsd 3` is `lst -d 3`. The depth is injected only when the
#    first argument is an integer, so `lsd /etc` lists that path flat rather
#    than recursing into it.
#
# 3: `lsd` and `clsd` are functions here rather than entries in `shellAliases`
#    because they take arguments. Home Manager emits `bashrcExtra` at the top of
#    `~/.bashrc` and `shellAliases` near the bottom, so a same-named alias does
#    not break the function definition at parse time — but alias expansion
#    happens first at the prompt, so the alias would win and the function would
#    never run. Keeping both names in `shellAliases` would silently shadow them.
