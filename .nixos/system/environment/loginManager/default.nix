# ./system/display/login-manager.nix

  #################################
  #  Login Manager Configuration  #
  #################################

{ ... }:

{
  (import ./sddm.nix);
  (import ./greetd.nix);
}
