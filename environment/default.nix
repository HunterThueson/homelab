# environment/default.nix

# List of environment module paths.
# Imported by both mkHosts.nix and mkHomes.nix.
#
# Each file is either:
#   - A plain HM module (function)        → injected into HM only
#   - A dual-export { nixos; home; }       → nixos part added to NixOS, home part to HM
#
# Listed individually (not by directory) so mkHosts/mkHomes can detect dual-exports.

[
  # Desktop environments
  ./desktop/hyprland.nix
  ./desktop/plasma.nix

  # Development tools
  ./dev

  # Editors (dual-export: system-level enabling + per-user HM config)
  ./editor

  # Games (enabled by hostSettings.role containing "gaming")
  ./games

  # Shell (dual-export: system-level enabling + per-user prompt config)
  ./shell

  # Terminal
  ./terminal/alacritty.nix

  # Themes
  ./themes/fonts.nix
  ./themes/stylix.nix
]
