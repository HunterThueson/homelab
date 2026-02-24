# ./system/environment/editor/default.nix

{ config, pkgs, ... }:

{
  (import ./vim.nix);
}
