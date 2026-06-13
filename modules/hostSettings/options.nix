# modules/hostSettings/options.nix

#-----------------------------#
#  Host Settings (Extension)  #
#-----------------------------#

# Personal extensions to spellbook's core hostSettings schema.
# Core options (system, type, role) come from flake-wizard; the
# type/role enums are generated from the names declared in flake.nix.

{ lib, ... }:

{
  loginManager = lib.mkOption {
    type = lib.types.enum [ "greetd" "sddm" ];
    default = "sddm";
  };

  hardware = lib.mkOption { type = lib.types.submodule (import ./hardware-options.nix); };

  networking = lib.mkOption {
    type = lib.types.submodule {
      options = {
        privacy = lib.mkOption {
          type = lib.types.submodule {
            options = {
              vpn = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    autostart = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = ''
                        Start the host-wide IVPN tunnel
                        (ivpn-host.service) at boot, before any user
                        logs in. User-level `autostart=false` does not
                        actively veto this when another autostart-user
                        is concurrently logged in.
                      '';
                    };
                  };
                };
                default = {};
              };
              torrent = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    autostart = lib.mkOption {
                      type = lib.types.bool;
                      default = true;
                      description = ''
                        Start the always-on torrent namespace tunnel
                        (ivpn-torrent.service) at boot. Default true:
                        the namespace tunnel comes up whenever any user
                        has `torrent.enable` set.
                      '';
                    };
                  };
                };
                default = {};
              };
            };
          };
          default = {};
        };
      };
    };
    default = {};
  };
}
