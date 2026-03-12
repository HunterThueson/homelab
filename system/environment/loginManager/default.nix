# ./system/display/login-manager.nix

{ ... }:

{
  (import ./sddm.nix);
  (import ./greetd.nix);
}
