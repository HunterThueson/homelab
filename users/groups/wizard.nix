# ./users/groups/wizard.nix

#-----------#
#  Wizards  #
#-----------#

# Defines a group that allows any user added as a "wizard" to
# access & modify the Nix daemon and NixOS settings in /etc/nixos/

{ config, ... }:

{
  users.groups = {
    wizard = {
      gid = 1001;
    };
  };
}
