# users/hunter/services.nix

{ pkgs, ... }:

{

  # Only works on X11 -- figure out a workaround for Wayland when possible
  services.unclutter = {
    enable = true;
    extraOptions = [ "timeout 5" "ignore-scrolling" ];
  };

  programs.bash.shellAliases = {
        claude = "${pkgs.claude-code}/bin/claude --append-system-prompt $HOME/docs/reference/claude/CLAUDE.md";
  };

}
