# modules/userSettings/options.nix

#-----------------------------#
#  User Settings (Extension)  #
#-----------------------------#

# Personal extensions to spellbook's core userSettings schema.
# Core options (name, nickname, fullName, email, administrator,
# extraGroups, role) come from flake-wizard; the role enum is
# generated from the role names declared in flake.nix.

{ lib, ... }:

{
  hashedPasswordFile  = lib.mkOption { type = lib.types.nullOr lib.types.path; default = null; };

  terminal  = lib.mkOption { type = lib.types.enum [ "alacritty" ]; default = "alacritty"; };
  shell     = lib.mkOption { type = lib.types.enum [ "bash" "fish" "zsh" ]; default = "bash"; };
  enableGit = lib.mkOption { type = lib.types.bool; default = false; };

  editor = lib.mkOption {
    type = lib.types.submodule {
      options = {
        terminal = lib.mkOption { type = lib.types.enum [ "vim" "nano" ]; default = "vim"; };
        gui      = lib.mkOption { type = lib.types.enum [ "emacs" "kate" "vs-code" ]; default = "emacs"; };
      };
    };
    default = {};
  };

  desktop = lib.mkOption {
    type = lib.types.submodule {
      options = {
        environment = lib.mkOption {
          type        = lib.types.enum [ "hyprland" "niri" "plasma" "plasmax11" ];
          default     = "hyprland";
          description = "Set the user's desktop environment";
        };
        theme = lib.mkOption {
          type        = lib.types.nullOr (lib.types.enum [ "default" ]);
          default     = null;
          description = "Set the user's theme (for window decorations, border styles, etc.)";
        };
        colorScheme = lib.mkOption {
          type        = lib.types.nullOr (lib.types.enum [ "electro-swing" ]);
          default     = null;
          description = "Set the user's color scheme";
        };
        wallpaper = lib.mkOption {
          type        = lib.types.nullOr lib.types.path;
          default     = null;
          description = "Set the user's wallpaper";
        };
      };
    };
  };

  networking = lib.mkOption {
    type = lib.types.submodule {
      options = {
        privacy = lib.mkOption {
          type = lib.types.submodule {
            options = {
              vpn = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = ''
                        Permit this user to start/stop the host-wide IVPN
                        tunnel (ivpn-host.service). When the host tunnel is
                        up, ALL of this machine's traffic goes through IVPN.
                      '';
                    };
                    autostart = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = ''
                        Start the host-wide tunnel at this user's login. When
                        false and `enable` is true, a veto unit fires at
                        login: if no other autostart-enabled user is logged
                        in, the host tunnel is stopped; otherwise it is left
                        alone with a notification.
                      '';
                    };
                    server = lib.mkOption {
                      type = lib.types.either lib.types.str (lib.types.submodule {
                        options = {
                          strategy = lib.mkOption {
                            type = lib.types.enum [ "single" ];
                            default = "single";
                            description = ''
                              Server selection strategy. Phase 1 only accepts
                              "single"; future phases add random / failover /
                              lowest-latency variants.
                            '';
                          };
                          name = lib.mkOption { type = lib.types.str; };
                        };
                      });
                      default = "";
                      description = ''
                        IVPN server config name (without .ovpn extension), e.g.
                        "USA-Denver". Resolved against
                        system/networking/ivpn/configs/<name>.ovpn.
                      '';
                    };
                  };
                };
                default = {};
              };

              torrent = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = ''
                        Install qBittorrent for this user and ensure the
                        always-on, namespace-isolated torrent tunnel
                        (ivpn-torrent.service) is configured on this host.
                      '';
                    };
                    autostart = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Launch qBittorrent at this user's login.";
                    };
                    server = lib.mkOption {
                      type = lib.types.nullOr (lib.types.either lib.types.str (lib.types.submodule {
                        options = {
                          strategy = lib.mkOption {
                            type = lib.types.enum [ "single" ];
                            default = "single";
                          };
                          name = lib.mkOption { type = lib.types.str; };
                        };
                      }));
                      default = null;
                      description = ''
                        IVPN server config name for the torrent tunnel. When
                        null, falls back to this user's vpn.server.
                      '';
                    };
                    portForward = lib.mkOption {
                      type = lib.types.bool;
                      default = false;
                      description = "Request an IVPN port-forward at torrent start (for seeding).";
                    };
                  };
                };
                default = {};
              };

              tor = lib.mkOption {
                type = lib.types.submodule {
                  options = {
                    enable = lib.mkOption { type = lib.types.bool; default = false; };
                    autostart = lib.mkOption { type = lib.types.bool; default = false; };
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

  browser = lib.mkOption {
    type = lib.types.submodule {
      options = {
        name = lib.mkOption {
          type        = lib.types.enum [ "firefox" ];
          default     = "firefox";
          description = "Which browser to install and configure.";
        };
        extensions = lib.mkOption {
          type        = lib.types.listOf lib.types.str;
          default     = [];
          description = "List of browser extension/add-on IDs to install.";
        };
        profiles = lib.mkOption {
          type        = lib.types.attrs;
          default     = {};
          description = "Browser profiles";
        };
        policies = lib.mkOption {
          type        = lib.types.attrs;
          default     = {};
          description = "Policies";
        };
        settings = lib.mkOption {
          type        = lib.types.attrs;
          default     = {};
          description = "Browser-specific settings (about:config for Firefox, etc.)";
        };
        extraConfig = lib.mkOption {
          type        = lib.types.attrs;
          default     = {};
          description = "Extra HM programs.<browser> config to merge in.";
        };
      };
    };
    default = {};
  };

}
