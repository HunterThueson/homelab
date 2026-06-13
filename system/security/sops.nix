# system/security/sops.nix

{ config, flakeRoot, ... }:

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

    };
  };
}
