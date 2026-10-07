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

# EOF
