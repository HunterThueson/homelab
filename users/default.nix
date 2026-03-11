# ./users/default.nix

{ ... }:

{
  imports = [
    ./groups
  ];
  
  # The following modules are not quite ready yet -- ./hunter.nix exists, but I have not
  # yet enabled the options that would allow it to function. It's on the TODO list.

  #(import ./hunter.nix);
  #(import ./ash.nix);
}
