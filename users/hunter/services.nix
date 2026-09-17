# users/hunter/services.nix

{ ... }:

{

  # Only works on X11 -- figure out a workaround for Wayland when possible
  services.unclutter = {
    enable = true;
    extraOptions = [ "timeout 5" "ignore-scrolling" ];
  };

}
