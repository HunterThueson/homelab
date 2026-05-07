# environment/editor/emacs/default.nix

#-----------------------#
#  Emacs Configuration  #
#-----------------------#

# Pure HM module — works in both NixOS-managed and standalone HM.
# Enables Emacs when userSettings.editor.gui == "emacs".
# System-level enabling (services.emacs) is in environment/editor/default.nix.

{ config, lib, pkgs, ... }:

let
  user = config.userSettings;

in {
  config = lib.mkIf (user.editor.gui == "emacs") {
    programs.emacs = {
      enable = true;
      package = pkgs.emacs;
    };

    # Native dependencies for org-roam and other packages
    home.packages = with pkgs; [
      sqlite        # org-roam database
      ripgrep       # faster searching (used by various packages)
      graphviz      # org-roam graph visualization
      fd            # faster find (projectile, etc.)
    ];

    # Emacs config files
    xdg.configFile."emacs/init.el".source = ./emacs.el;
    xdg.configFile."emacs/org-roam-templates.el".source = ./org-roam-templates.el;

    # Ensure org-roam directory exists
    home.file."docs/.keep".text = "";
  };
}
