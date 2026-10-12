# modules/hostSettings/schema.nix

#----------#
#  Schema  #
#----------#

{ lib, pkgs, ... }:

let
  sessions = import ../../lib/sessions.nix;
in
{
  options.hostSettings = lib.mkOption {
    type = lib.types.submodule {
      options = {
        system = lib.mkOption { type = lib.types.enum [ "x86_64-linux" "aarch64-linux" ]; };
        type   = lib.mkOption { type = lib.types.enum [ "desktop" "laptop" "server" ]; };
        role   = lib.mkOption { type = lib.types.listOf (lib.types.enum [ "workstation" "writing" "media" "server" ]); };

        loginManager = lib.mkOption {
          type = lib.types.enum [ "greetd" "sddm" ];
          default = "sddm";
        };

        availableSessions = lib.mkOption {
          type        = lib.types.listOf (lib.types.enum sessions.all);
          default     = [];
          description = ''
            Desktop sessions always available on this host, regardless of what
            its users request. Unioned with the users' desktop.environments
            lists to decide which sessions the host enables.
          '';
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

        services = lib.mkOption {
          type = lib.types.submodule {
            options = {
              penpot = lib.mkOption {
                type = lib.types.submodule ({ config, ... }: {
                  options = {
                    enable = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = ''
                        Self-host Penpot on this machine. Brings up the
                        upstream container stack (frontend, backend, exporter,
                        admin console, MCP, postgres, valkey) under podman and
                        serves the web UI on listenAddress:port.
                      '';
                    };

                    listenAddress = lib.mkOption {
                      type = lib.types.str;
                      default = "127.0.0.1";
                      description = ''
                        Address the web UI is published on. The default keeps
                        the instance machine-local; "0.0.0.0" exposes it to the
                        LAN and opens the firewall port, which also means the
                        session cookies and email verification left relaxed for
                        a localhost instance start to matter.
                      '';
                    };

                    port = lib.mkOption {
                      type = lib.types.port;
                      default = 9001;
                      description = "Host port the Penpot frontend is published on.";
                    };

                    publicUri = lib.mkOption {
                      type = lib.types.str;
                      default = "http://localhost:${toString config.port}";
                      description = ''
                        URI browsers reach this instance at. Penpot bakes it
                        into the frontend bundle and into the links it mails,
                        so it has to match what users actually type.
                      '';
                    };
                  };
                });
                default = {};
              };
            };
          };
          default = {};
        };
      };
    };
  };
}
