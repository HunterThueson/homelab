# lib/mkHosts.nix

#-----------#
#  mkHosts  #
#-----------#

# Map over hosts defined in flake.nix outputs and create nixosSystems for each
# based on the value of [host].hostSettings; create all users assigned to given
# [host] from those listed in [host].users.
#
# User data is loaded as plain attrsets from users/*.nix and assigned to both
# config.userSettings (NixOS-level, for system/users.nix and system-programs)
# and home-manager.users.*.userSettings (HM-level, for environment/ modules).
#
# Environment modules can be either:
#   - A plain HM module (function) → injected into HM only
#   - A dual-export attrset { nixos = <module>; home = <module>; } → nixos part
#     added as a NixOS module, home part injected into HM

{ inputs, lib, flakeRoot, ... }:

hostDefinitions: lib.mapAttrs (hostname: hostConfig:
  let
    pkgs = import inputs.nixpkgs {
      system = hostConfig.hostSettings.system;
      config.allowUnfree = true;
    };

    # Load user data as plain attrsets (users/*.nix are functions, not modules)
    userDataAttrs = lib.listToAttrs (map (username:
      lib.nameValuePair username (import "${flakeRoot}/users/${username}.nix" { inherit pkgs; })
    ) hostConfig.users);

    # Import environment module definitions
    envModules = import "${flakeRoot}/environment";

    # Extract NixOS modules from dual-export files (skip HM-only modules)
    nixosFromEnv = lib.concatMap (m:
      let mod = import m;
      in if builtins.isAttrs mod && mod ? nixos then [ mod.nixos ] else []
    ) envModules;

    # Extract HM modules from all files (dual-export → .home, plain → as-is)
    hmFromEnv = map (m:
      let mod = import m;
      in if builtins.isAttrs mod && mod ? home then mod.home else m
    ) envModules;

    # HM modules: schema + flake HM modules + extracted home modules
    hmModules = [
      "${flakeRoot}/modules/userSettings/hm-schema.nix"
      inputs.hyprland.homeManagerModules.default
    ] ++ hmFromEnv;

  in
  inputs.nixpkgs.lib.nixosSystem {
    system = hostConfig.hostSettings.system;
    specialArgs = { inherit inputs lib flakeRoot; };
    modules = [

    # Flake inputs as NixOS modules
      inputs.home-manager.nixosModules.home-manager
      inputs.nixvim.nixosModules.nixvim
      inputs.stylix.nixosModules.stylix
      inputs.hyprland.nixosModules.default

    # Schemas, system backend, host-specific config
      "${flakeRoot}/modules"
      "${flakeRoot}/system"
      "${flakeRoot}/hosts/${hostname}"

    # NixOS parts from dual-export environment modules
    ] ++ nixosFromEnv ++ [

    # Set hostSettings, userSettings, and stateVersion (NixOS-level)
      { config.hostSettings = hostConfig.hostSettings; }
      { config.userSettings = userDataAttrs; }
      { config.system.stateVersion = hostConfig.stateVersion; }

    # Set up Home Manager — inject HM parts per-user
      {
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = { inherit inputs flakeRoot; };
          users = lib.mapAttrs (username: userData: {
            imports = hmModules;
            userSettings = userData;
            home.stateVersion = hostConfig.stateVersion;
            home.packages = userData.packages;
            programs.home-manager.enable = true;
          }) userDataAttrs;
        };
      }
    ];
  }
) hostDefinitions
