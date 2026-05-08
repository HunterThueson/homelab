# environment/browser/firefox.nix

#----------------------------#
#  Firefox Configuration     #
#----------------------------#

# Pure HM module — works in both NixOS-managed and standalone HM.
# Configures Firefox when userSettings.browser.name == "firefox".
#
# Future: extensions, about:config settings, toolbar layout, and
# color schemes can be added via userSettings.browser.extensions,
# userSettings.browser.settings, and userSettings.browser.extraConfig.

{ config, lib, ... }:

let
  user = config.userSettings;
  browser = user.browser;
in {
  config = lib.mkIf (browser.name == "firefox") {
    programs.firefox = {
      enable = true;

      # Default profile — managed by Home Manager
      profiles.default = {
        isDefault = true;

        # about:config settings from userSettings.browser.settings
        settings = browser.settings;

        # Extension installation will go here once browser.extensions is wired.
        # Firefox extensions are installed via NUR or manual addon IDs.
        # Example future usage in users/hunter.nix:
        #   browser.extensions = [ "uBlock0@raymondhill.net" ];
      };

    } // browser.extraConfig;

    # Tell Stylix which Firefox profiles to theme
    stylix.targets.firefox.profileNames = [ "default" ];
  };
}
