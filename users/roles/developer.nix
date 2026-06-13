# users/roles/developer.nix

#-------------#
#  Developer  #
#-------------#

# Dual-export module for the developer role.
# nixos: defines the developer group, gives access to work in /usr/local/bin
#        (applied to any host with at least one developer user)
# home:  adds the `cdb` shell function for quick access to /usr/local/bin,
#        gives access to Python, Rust, and developer tooling packages,
#        and enables git automatically unless explicitly disabled
#
# conjure only injects the home part into users with the developer role,
# so no mkIf guard is needed.

{
  nixos = { config, ... }: {
    users.groups.developer.gid = 1002;

    system.activationScripts.developerPermissions = ''
      chown -R root:developer /usr/local/bin
      chmod -R a+rx,g+w,o-w /usr/local/bin
    '';
  };

  home = { lib, pkgs, ... }: {
    programs.git.enable = lib.mkDefault true;

    programs.bash.bashrcExtra = ''
      # Teleport to $HOME/bin
      cdb () {
        cd /usr/local/bin
        clear
        eza --icons=auto --group-directories-first
      }
    '';

    home.sessionPath = [
      "$HOME/bin/"
      "$HOME/.cargo/bin/"
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
}
