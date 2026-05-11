# system/security/sops.nix

{ config, flakeRoot, ... }:

{
  sops = {
    defaultSopsFile = "${flakeRoot}/system/security/secrets/secrets.yaml";
    defaultSopsFormat = "yaml";

    # Use the host's SSH key to decrypt
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    # Declare which secrets to decrypt
    secrets = {
      "hunter-hashed-password" = {
        neededForUsers = true;
      };
      "ash-hashed-password" = {
        neededForUsers = true;
      };
    };
  };
}
