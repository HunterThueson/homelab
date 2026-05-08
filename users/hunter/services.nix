# users/hunter/services.nix

{ ... }:

{
  services.unclutter = {
    enable = true;
    extraOptions = [ "timeout 5" "ignore-scrolling" ];
  };
}
