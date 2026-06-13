# users/roles/wizard.nix

#-----------#
#  Wizards  #
#-----------#

# Dual-export module for the wizard role.
# nixos: defines the wizard group, ensures /etc/nixos/ permissions
#        (applied to any host with at least one wizard user)
# home:  adds the `cdn` shell function for quick access to /etc/nixos/
#        and enables git automatically unless explicitly disabled
#
# conjure only injects the home part into users with the wizard role,
# so no mkIf guard is needed.

{
  nixos = { config, ... }: {
    users.groups.wizard.gid = 1001;

    system.activationScripts.wizardPermissions = ''
      chown -R root:wizard /etc/nixos
      chmod -R g+rwX /etc/nixos
    '';
  };

  home = { lib, ... }: {
    programs.git.enable = lib.mkDefault true;

    programs.bash.bashrcExtra = ''
      # Teleport to NixOS configuration directory
      cdn () {
        cd /etc/nixos/
        clear
        eza --icons=auto --group-directories-first
      }
    '';

    home.sessionPath = [
      "/etc/nixos/scripts"
    ];
  };
}
