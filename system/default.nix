# ./system/default.nix

{ ... }:

{
  (import ./boot);
  (import ./display);
  (import ./environment);
  (import ./hardware);
  (import ./services);
}
