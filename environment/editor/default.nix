# environment/editor/default.nix

#-----------#
#  Editors  #
#-----------#

# Dual-export: system-level enabling + per-user HM config in one place.
# nixos: enables emacs service and nixvim system-wide based on userSettings
# home:  per-user emacs config (keybinds, packages, init.el)

{
  nixos = { config, lib, pkgs, ... }:
  let
    users = lib.attrValues config.userSettings;
    anyWantsEmacs = lib.any (u: u.editor.gui == "emacs") users;
  in {
    # Vim/nixvim handles its own conditional via anyUserWantsVim
    imports = [ ./vim ];

    config = lib.mkIf anyWantsEmacs {
      environment.systemPackages = [ pkgs.emacs ];
      services.emacs = {
        enable = true;
        package = pkgs.emacs;
      };
    };
  };

  home = { ... }: {
    imports = [ ./emacs ];
  };
}
