# ./system/services/firefly-iii.nix

#-----------------------------#
#  Firefly III Configuration  #
#-----------------------------#

# All values are currently set to default (except enabling Firefly III)

{ config, pkgs, lib, ... }:

let
  cfg = config;
in

with lib;
{ 
  mkIf (cfg.services.firefly-iii.enable == true) {
    services.firefly-iii = {
      virtualHost = "localhost";                                                                              # default
      user = "firefly-iii";                                                                                   # default
      group = "If `services.firefly-iii.enableNginx` is true then `ngnix` else firefly-iii";                  # default
      enableNginx = false;                                                                                    # default
      dataDir = "/var/lib/firefly-iii";
      poolConfig = ''
        {
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 500;
        }
        '';

      settings = {
      };
    };

    # Data Importer

    services.firefly-iii-data-importer = {
      enable = false;                                                                                         # default
      dataDir = "/var/lib/firefly-iii-data-importer";                                                         # default
      user = "firefly-iii-data-importer";
      group = "If `services.firefly-iii.enableNginx` is true then `ngnix` else firefly-iii-data-importer";    # default
      virtualHost = "localhost";
      enableNginx = false;
      poolConfig = ''
        {
          "pm" = "dynamic";
          "pm.max_children" = 32;
          "pm.start_servers" = 2;
          "pm.min_spare_servers" = 2;
          "pm.max_spare_servers" = 4;
          "pm.max_requests" = 500;
        }
        '';

      settings = {
      };
    };
  };
}
