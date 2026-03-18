# hosts/hephaestus/default.nix

{
    (import ./configuration.nix)
    (import ./hardware.nix)
}
