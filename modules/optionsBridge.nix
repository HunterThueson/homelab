# ./modules/optionsBridge.nix

#
# Bridges the gap between NixOS system configuration settings and Home Manager
# configuration settings by creating a namespace `home` that automatically
# forwards Home Manager settings to the appropriate user
#
# All credit for this approach goes to AlexAntonik
# Source: https://discourse.nixos.org/t/search-for-best-dotfiles-structure-dendritic-edition/75134
#

{ config, lib, options, ... }:

{
  options = {
    userSettings = lib.mkOption {
      type = lib.types.attrs;
      default = { };
      description = "User settings accessible in all modules";
    };
    home = lib.mkOption {
      type = lib.types.deferredModule;
      default = { };
      description = "Alias for home-manager.users.<username>";
    };
  };

  config = lib.mkMerge [
    {
      _module.args = {
        home = config.home;
      };
    }
    (lib.optionalAttrs (options ? home-manager) {
      # Only apply when home-manager is imported
      home-manager = {
        users."${config.userSettings.username}" = config.home;
        extraSpecialArgs = config.userSettings;
      };
    })
  ];
}
