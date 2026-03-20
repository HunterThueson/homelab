# lib/mkHost.nix

#----------#
#  mkHost  #
#----------#

# Map over hosts defined in flake.nix outputs and create nixosSystems for each
# based on the value of [host].hostSettings; create all users assigned to given
# [host] from those listed in [host].users

{ inputs, lib, flakeRoot, ... }:

hostDefinitions: lib.mapAttrs (hostname: hostConfig:
  inputs.nixpkgs.lib.nixosSystem {
    system = hostConfig.hostSettings.system;
    specialArgs = { inherit inputs lib flakeRoot; };
    modules = [

    # Flake inputs as modules
      inputs.home-manager.nixosModules.home-manager
      inputs.nixvim.nixosModules.nixvim
      inputs.stylix.nixosModules.stylix
      inputs.hyprland.nixosModules.default

    # Custom modules and configuration
      "${flakeRoot}/modules"                # Custom modules
      "${flakeRoot}/environment"            # User-level configuration backend
      "${flakeRoot}/system"                 # System-level configuration backend
      "${flakeRoot}/hosts/${hostname}"      # Per-host custom settings & hardware config

    # Set hostSettings
      { config.hostSettings = hostConfig.hostSettings; }

    # Set up Home Manager with sharedModules
      { home-manager = { useGlobalPkgs = true; useUserPackages = true; ... }; }

    # Import user configuration files for users assigned to this host
      { imports = map (u: "${flakeRoot}/users/${u}.nix") hostConfig.users; }
    ];
  }
) hostDefinitions
