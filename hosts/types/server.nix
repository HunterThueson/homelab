# hosts/types/server.nix

#----------#
#  Server  #
#----------#

# Defaults for server hosts: no GUI, no sound, no printing,
# no gaming mice. Headless, lean, secure.
#
# conjure only imports this module into hosts whose type is "server",
# so no mkIf guard is needed.

{ lib, ... }:

{
  # Disable GUI
  services.xserver.enable = false;

  # No sound
  services.pipewire.enable = false;

  # No printing
  services.printing.enable = false;
  services.avahi.enable = false;

  # No gaming mouse daemon
  services.ratbagd.enable = false;

  # SSH hardening defaults
  services.openssh = {
    enable = lib.mkDefault true;
    settings = {
      PermitRootLogin = lib.mkDefault "no";
      PasswordAuthentication = lib.mkDefault false;
    };
  };
}
