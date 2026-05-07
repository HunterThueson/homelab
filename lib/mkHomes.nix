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

      # Import environment module definitions
      envModules = import "${flakeRoot}/environment";

      # Extract HM modules (dual-export → .home, plain → as-is)
      hmFromEnv = map (m:
        let mod = import m;
        in if builtins.isAttrs mod && mod ? home then mod.home else m
      ) envModules;

      hmModules = [
        "${flakeRoot}/modules/userSettings/hm-schema.nix"
      ] ++ hmFromEnv;

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

            # Set username and home directory
            {
              home.username = username;
              home.homeDirectory = "/home/${username}";
            }
          ];
        }
      )
    ) hostConfig.users)
  ) hostDefinitions;

in perHostUsers
