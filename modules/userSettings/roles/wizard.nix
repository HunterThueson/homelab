# ./modules/userSettings/roles/wizard.nix

#-----------#
#  Wizards  #
#-----------#

# Dual-export module for the wizard role.
# nixos: defines the wizard group, ensures /etc/nixos/ permissions
# home:  adds the `cdn` shell function for quick access to /etc/nixos/
#        and enables git automatically unless explicitly disabled

{
  nixos = { config, ... }: {
    users.groups.wizard.gid = 1001;

    system.activationScripts.wizardPermissions = ''
      chown -R root:wizard /etc/nixos
      chmod -R g+rwX /etc/nixos
    '';
  };

  home = { config, lib, ... }:
  let
    isWizard = builtins.elem "wizard" config.userSettings.role;
  in {
    config = lib.mkIf isWizard {
      programs.git.enable = lib.mkDefault true;

      programs.bash.bashrcExtra = ''
        # Teleport to NixOS configuration directory
        cdn () {
          cd /etc/nixos/
          clear
          eza --icons=auto --group-directories-first
        }
      '';
    };
  };
}
