# system/nix/default.nix

#----------------------------------------#
#  Nix Language & Nixpkgs Configuration  #
#----------------------------------------#

{ config, pkgs, inputs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.permittedInsecurePackages = [
    "mbedtls-2.28.10"
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];                       # Enable Flakes
      auto-optimise-store = true;                                               # Automatically optimise nix-store
      allow-dirty = true;                                                       # Allow dirty Git/Mercurial trees
    };

    gc = {                                                                      # Automatic garbage collection
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 90d";
    };

    # Pull the GitHub token in by reference so it never reaches the store. [1]
    extraOptions = ''
      !include ${config.sops.secrets."nix-access-tokens".path}
    '';
  };

  nix.settings.allowed-users = [
    "@wheel"
    "@wizard"
  ];

  # Ensure the Wizard group can edit /etc/nixos/ across reboots
  systemd.tmpfiles.rules = [
    "d /etc/nixos 2770 root wizard - -"
    "d /home/wizard 2775 root wizard - -"
    "d /home/wizard/bin 2775 root wizard - -"
    "d /home/wizard/bin/medialib 2775 root wizard - -"
    "d /home/wizard/claude-config 2775 root wizard - -"
  ];
}

#-------------#
#  Footnotes  #
#-------------#

# 1: `extraOptions` is interpolated into /etc/nix/nix.conf, which is a
#    world-readable store file — writing `access-tokens` here literally would
#    publish the token to every user and to this repo. `!include` emits only
#    the path; sops-nix decrypts the content to /run/secrets at activation.
#
#    The leading `!` makes the include non-fatal when the file is absent, which
#    it is until the first successful activation. Plain `include` would make
#    evaluation unrecoverable on a fresh host — bootstrapping one means placing
#    the fragment by hand before the first switch.

# EOF
