# flake.nix

#----------------------------------#
#  Hunter Thueson's NixOS Homelab  #
#----------------------------------#

# for high-level management of my NixOS homelab and its dependencies
#
# The heavy lifting (schemas, host/user assembly, dual-export module
# loading, type/role selection) is done by flake-wizard's spellbook —
# this file only declares inputs, users, and hosts.

{
  description = "Hunter Thueson's NixOS System Configuration(s)";

  #----------#
  #  Inputs  #
  #----------#

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";

    flake-wizard.url = "path:/home/hunter/projects/flake-wizard";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:nix-community/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  #-----------#
  #  Outputs  #
  #-----------#

  outputs = inputs @ { self, nixpkgs, flake-wizard, ... }:

  let
    inherit (flake-wizard) spellbook;

    presets = spellbook.presets { inherit (nixpkgs) lib; };
    keyboardPresets = presets.keyboards;
    monitorPresets  = presets.monitors;
    gpuPresets      = presets.gpus;

    #--------------------#
    #  User Definitions  #
    #--------------------#

    userDefs = {
      hunter = {
        nickname      = "Hunter";
        fullName      = "Hunter Thueson";
        email         = "hunter.thueson@gmail.com";
        administrator = true;
        role          = [ "wizard" "developer" "gamer" "writer" ];
        shell         = "bash";
        editor        = { terminal = "vim"; gui = "emacs"; };
        desktop       = { environment = "hyprland"; colorScheme = "electro-swing"; };
        browser.name  = "firefox";

        networking.privacy = {
          vpn     = { enable = true; autostart = false; server = "USA-Denver"; };
          torrent = { enable = true; autostart = true;  portForward = false; };
          tor     = { enable = true; autostart = false; };
        };
      };

      ash = {
        nickname      = "Ash";
        fullName      = "Ashley Ellison";
        email         = "ash.ellison@proton.me";
        administrator = true;
        role          = [ "wizard" "developer" "writer" ];
        shell         = "bash";
        desktop       = { environment = "plasmax11"; colorScheme = "electro-swing"; };
        browser.name  = "firefox";

        networking.privacy = {
          vpn     = { enable = true; autostart = true;  server = "USA-Denver"; };
          torrent = { enable = true; autostart = true;  portForward = false; };
          tor     = { enable = true; autostart = false; };
        };
      };
    };

    #--------------------#
    #  Host Definitions  #
    #--------------------#

    hostDefs = {
      hephaestus = {
        users = [ "hunter" "ash" ];
        stateVersion = "21.11";
        hmStateVersion = "25.11";

        hostSettings = {
          system = "x86_64-linux";
          type = "desktop";
          role = [ "workstation" "writing" ];
          loginManager = "sddm";
          hardware = {
            boot = {
              loader = "systemd-boot";
              device = "/dev/disk/by-id/nvme-eui.0025384141427eb8";
            };
            gpu = [ gpuPresets."rtx3090" ];
            keyboard = {
              layout = "qwerty";
              model = keyboardPresets.zsa.moonlander;
            };
            display = monitorPresets.layouts."m28u-landscape--s2417dg-portrait-right";
          };
        };
      };

      artemis = {
        users = [ "hunter" ];
        stateVersion = "25.11";

        hostSettings = {
          system = "x86_64-linux";
          type = "laptop";
          role = [ "workstation" "writing" ];
          loginManager = "sddm";
          hardware = {
            boot = {
              loader = "systemd-boot";
              device = "/dev/disk/by-uuid/F28D-FD6D";
            };
            keyboard = {
              layout = "qwerty";
              model = keyboardPresets.lenovoThinkPad."built-in";
            };
            display = {
              monitors = [ monitorPresets.lenovoThinkPad."built-in" ];
            };
          };
        };
      };
    };

    #-------------------#
    #  The Incantation  #
    #-------------------#

    cast = spellbook.conjure {
      inherit inputs;
      root = ./.;

      hosts = hostDefs;
      users = userDefs;

      # Host types — each host picks exactly one
      types = {
        desktop = ./hosts/types/desktop.nix;
        laptop  = ./hosts/types/laptop.nix;
        server  = ./hosts/types/server.nix;
      };

      # User roles — each user picks any number.
      # null = tag only (no defaults module; environment/ keys off the name)
      roles = {
        wizard    = ./users/roles/wizard.nix;
        developer = ./users/roles/developer.nix;
        gamer     = null;
        filmmaker = null;
        writer    = null;
      };

      # Host roles — tags only, for now
      hostRoles = {
        workstation = null;
        writing     = null;
        media       = null;
        server      = null;
      };

      # Personal extensions to the core hostSettings/userSettings schemas
      hostOptions = ./modules/hostSettings/options.nix;
      userOptions = ./modules/userSettings/options.nix;

      # Flake inputs as NixOS modules (home-manager is added by conjure)
      nixosModules = [
        inputs.sops-nix.nixosModules.sops
        inputs.nixvim.nixosModules.nixvim
        inputs.stylix.nixosModules.stylix
        inputs.hyprland.nixosModules.default
      ];

      # Flake inputs as Home Manager modules
      hmModules = [
        inputs.hyprland.homeManagerModules.default
      ];

      # HM modules needed only by standalone homeConfigurations
      # (the stylix NixOS module covers the integrated path)
      standaloneHmModules = [
        inputs.stylix.homeModules.stylix
      ];

      nixpkgsConfig = { allowUnfree = true; };

      # Users on each host whose vpn.autostart is true. Consumed by the
      # per-user vpn-veto script to detect "is another VPN user logged
      # in?" at login time. See environment/services/privacy.nix.
      specialArgs = { host, users, lib, ... }: {
        vpnAutostartUsers = lib.attrNames (lib.filterAttrs
          (_: u: u.networking.privacy.vpn.autostart or false)
          (lib.getAttrs host.users users));
      };
    };

  in
  {
    nixosConfigurations = cast.nixosConfigurations // {
      installer = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [
          inputs.stylix.nixosModules.stylix
          inputs.hyprland.nixosModules.default
          inputs.nixvim.nixosModules.nixvim
          ./hosts/installer
        ];
      };
    };

    homeConfigurations = cast.homeConfigurations;
  };
}
