# users/ash/extraConfig.nix

#---------------#
#  ExtraConfig  #
#---------------#

{ ... }:

{
  # Ash's private shell fragment, decrypted at activation by sops-nix. The
  # content is deliberately not in this repo; the secret is declared in
  # system/security/sops.nix and only exists after a rebuild. [1]
  programs.bash.bashrcExtra = ''
    if [[ -r /run/secrets/ash-bashrc-extra ]]; then
      source /run/secrets/ash-bashrc-extra
    fi
  '';

  programs.obsidian = {
    enable = true;

  };
}

#-------------#
#  Footnotes  #
#-------------#

# 1: The path is hardcoded rather than read from
#    `config.sops.secrets."ash-bashrc-extra".path` because this is an HM module
#    and `sops.secrets` is NixOS-level — under a standalone `home-manager
#    switch` there is no NixOS config to read it from. environment/services/
#    syncthing.nix hardcodes /run/secrets/* for the same reason.
#
#    Edit the fragment with:
#      sops edit system/security/secrets/secrets.yaml
#      sudo nixos-rebuild switch --flake /etc/nixos#hephaestus
#
#    The `-r` guard keeps a fresh/un-switched machine from erroring at shell
#    startup, since /run/secrets is tmpfs and only populated by a rebuild.

# EOF
