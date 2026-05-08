# users/ash/services.nix

{ ... }:

{
  services.unclutter = {
    enable = true;
    extraOptions = [ "timeout 1" "ignore-scrolling" ];
  };
}
