# lib/presets/default.nix

{ ... }:

{
  imports = [
    ./gpus.nix
    ./keyboards.nix
    ./monitors.nix
  ];
}
