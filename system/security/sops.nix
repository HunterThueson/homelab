# system/security/sops.nix

{ config, lib, flakeRoot, ... }:

{
  sops = {
    defaultSopsFile = "${flakeRoot}/system/security/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";

    # Use the host's SSH key to decrypt
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    #-----------#
    #  Secrets  #
    #-----------#

    secrets = {

      # -- User Passwords -- #

      "hunter-hashed-password" = {
        neededForUsers = true;
      };
      "ash-hashed-password" = {
        neededForUsers = true;
      };

      # -- Wifi Passwords -- #

      "wifi-auth" = {
        mode  = "0400";
        owner = "root";
      };

      # -- Miscellaneous -- #

      # IVPN OpenVPN auth: two lines (account ID, then any non-empty password).
      "ivpn-auth" = {
        mode  = "0400";
        owner = "root";
      };

      # A nix.conf fragment, not a bare token — `!include`d by system/nix. [2]
      "nix-access-tokens" = {
        mode  = "0440";
        owner = "root";
        group = "wizard";
      };

      # -- Private Shell Fragments -- #

      # Sourced by users/<name>/, so content stays off the public repo. Gated
      # per-host: `owner` must name a user that exists here. [1]
    } // lib.optionalAttrs (config.userSettings ? ash) {
      "ash-bashrc-extra" = {
        mode  = "0400";
        owner = "ash";
      };
    };
  };
}

#-------------#
#  Footnotes  #
#-------------#

# 1: `config.userSettings` holds only the users on *this* host (mkHosts builds
#    it from hostDefs.<host>.users), so `? ash` is the per-host gate — the same
#    one environment/services/syncthing.nix uses. Declaring this
#    unconditionally would break activation on artemis, where `ash` has no
#    account for sops-install-secrets to chown to.

# 2: Authenticates the private `claude-config` flake input. The decrypted file
#    is a nix.conf fragment, since `!include` splices config lines, not a value:
#      access-tokens = github.com=github_pat_…
#    `group = "wizard"` rather than root-only 0400 because flake fetching runs
#    as whoever evaluates — root under `sudo nixos-rebuild`, but hunter/ash
#    under `nix flake update`, and `!include` only tolerates a *missing* file,
#    not an unreadable one. The cost is that the token is readable by every
#    wizard, so scope the PAT to this one repo.

# EOF
