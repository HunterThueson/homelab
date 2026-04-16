# environment/editor/emacs/default.nix

# Home-manager configuration for Emacs

{ config, pkgs, lib, ... }:

{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  # Start emacs daemon with graphical session
  services.emacs.enable = true;

  # Native dependencies for org-roam and other packages
  home.packages = with pkgs; [
    sqlite        # org-roam database
    ripgrep       # faster searching (used by various packages)
    graphviz      # org-roam graph visualization
    fd            # faster find (projectile, etc.)
  ];

  # Emacs 27+ uses ~/.config/emacs/ if ~/.emacs.d doesn't exist
  xdg.configFile."emacs/init.el".source = ./emacs.el;

  # Ensure org-roam directory exists
  home.file."wiki/.keep".text = "";
}
