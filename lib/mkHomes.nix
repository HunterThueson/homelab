# lib/mkHomes.nix

#-----------#
#  mkHomes  #
#-----------#

# Creates standalone homeConfigurations for each user on each host.
# Keyed as "username@hostname" (e.g., "hunter@hephaestus").
#
# Uses the same environment/ HM modules and user data as mkHosts.nix,
# so `home-manager switch` and `nixos-rebuild switch` produce identical
# HM output for the same user.

{ inputs, lib, flakeRoot, ... }:

hostDefinitions:

let
  perHostUsers = lib.concatMapAttrs (hostname: hostConfig:
    let
      pkgs = import inputs.nixpkgs {
        system = hostConfig.hostSettings.system;
        config.allowUnfree = true;
      };

      # Import module definition lists (each may contain plain or dual-export modules)
      envModules   = import "${flakeRoot}/environment";
      roleModules  = import "${flakeRoot}/users/roles";
      allModules   = envModules ++ roleModules;

      # Extract HM modules from all files (dual-export → .home, plain → as-is)
      hmFromAll = lib.concatMap (m:
        let mod = import m;
        in if builtins.isAttrs mod && mod ? home then [ mod.home ]
           else if builtins.isFunction mod then [ m ]
           else []
      ) allModules;

      hmModules = [
        "${flakeRoot}/modules/userSettings/hm-schema.nix"
        inputs.hyprland.homeManagerModules.default
        inputs.stylix.homeModules.stylix
      ] ++ hmFromAll;

    in
    lib.listToAttrs (map (username:
      let
        userData = import "${flakeRoot}/users/${username}.nix" { inherit pkgs; };
      in
      lib.nameValuePair "${username}@${hostname}" (
        inputs.home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          extraSpecialArgs = { inherit inputs flakeRoot; };
          modules = hmModules ++ [
            # Set this user's settings
            { config.userSettings = userData; }

            # HM plumbing
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
              home.stateVersion = hostConfig.hmStateVersion or hostConfig.stateVersion;
              home.packages = userData.packages;
              programs.home-manager.enable = true;
            }
          ];
        }
      )
    ) hostConfig.users)
  ) hostDefinitions;

in perHostUsers
