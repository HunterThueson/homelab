# ./modules/userSettings/roles/developer.nix

#-------------#
#  Developer  #
#-------------#

# Dual-export module for the developer role.
# nixos: defines the developer group, gives it /usr/local/bin to work in
# home:  adds the `cdb`/`cdB` shell functions for quick access to $HOME/bin and
#        /usr/local/bin, creates the developer's own bin directories,
#        gives access to Python, Rust, and developer tooling packages,
#        and enables git automatically unless explicitly disabled

{
  nixos = { config, ... }: {
    users.groups.developer.gid = 1002;

    # Declared as a tmpfiles rule rather than an activation script [1]
    systemd.tmpfiles.rules = [
      "d /usr/local/bin 2775 root developer - -"
    ];
  };

  home = { config, lib, pkgs, ... }:
  let
    isDeveloper = builtins.elem "developer" config.userSettings.role;
  in {
    config = lib.mkIf isDeveloper {
      programs.git.enable = lib.mkDefault true;

      programs.direnv = {
        enable = true;
        nix-direnv.enable = true;   # caches the devShell so re-entry is instant
      };

      # Silence direnv's "loading/export" chatter so it doesn't clutter the
      # clean terminal produced by the cd* helpers (clear + eza).
      home.sessionVariables = {
        DIRENV_LOG_FORMAT = "";
      };

      programs.bash.bashrcExtra = ''
        # Teleport to $HOME/bin
        cdb () {
          cd $HOME/bin
          clear
          eza --icons=auto --group-directories-first
        }

        cdB () {
          cd /usr/local/bin
          clear
          eza --icons=auto --group-directories-first
        }
      '';

      # The developer's own bin directories; the nixos half cannot create these [2]
      home.activation.developerBinDirs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run mkdir -p "$HOME/bin" "$HOME/.local/bin"
      '';

      home.sessionPath = [
        "$HOME/bin/"              # allow devs to run their own code easily from PATH
        "$HOME/.cargo/bin/"       # get Rust working (for whenever we finally get back to learning that)
      ];

      home.packages = with pkgs; [

        # Python
        python314                                               # Python release 3.14
        python313Packages.beautifulsoup4                        # Python web scraping utility
        python313Packages.types-beautifulsoup4                  # Typing stubs for beautifulsoup4

        # Rust
        rustup                                                  # the Rust toolchain installer (manages cargo, rustc, rustfmt)

        # Build tools
        binutils                                                # dependency for `make`
        xorriso                                                 # dependency for `make iso`

      ];
    };
  };
}


#-------------#
#  Footnotes  #
#-------------#

# 1: /usr/local/bin was previously created and chowned by a
#    `system.activationScripts.developerPermissions` snippet, which failed on any
#    host where the `developer` group did not already exist. Activation snippets
#    that declare no `deps` are emitted in alphabetical order of attribute name,
#    so `developerPermissions` ran before the `users` snippet that creates groups
#    — `chown: invalid group: 'root:developer'`, then "Activation script snippet
#    'developerPermissions' failed (1)". The failure is self-clearing, since the
#    group exists by the next switch, so it only ever surfaced on a host's first
#    rebuild after this role grew its nixos half. `roles/wizard.nix` still has the
#    identical shape and is ordered correctly only because `w` sorts after `u`.
#
#    A tmpfiles rule sidesteps the ordering question entirely —
#    systemd-tmpfiles-setup runs after user and group creation — and matches how
#    the wizard directories are declared in `system/nix/default.nix`. Adding
#    `deps = [ "users" ]` to the activation snippet would have fixed the ordering
#    too; tmpfiles was preferred because it also retires the recursive chown.
#    Consequence of that: the rule asserts mode and owner on the directory alone,
#    so anything already under /usr/local/bin keeps the ownership it has, while
#    the setgid bit puts everything created from now on in the developer group.
#    Reasserting ownership across an existing tree needs
#    `Z /usr/local/bin 2775 root developer - -`, which recurses on every tmpfiles
#    run and will overwrite ownership a user set deliberately.
#
# 2: These two directories live inside a user's home, which is why they moved to
#    the home half. System activation runs as root with no per-user $HOME, and at
#    boot $HOME is unset altogether, so the old `mkdir -p $HOME/.local/bin`
#    expanded to `mkdir -p /.local/bin`. hephaestus still carries the resulting
#    root-owned /.local/bin from 2026-07-05; it is inert and safe to remove.
