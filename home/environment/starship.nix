# ./home/environment/starship.nix

#-------------------#
#  Starship Prompt  #
#-------------------#

{ ... }:

{
  programs.starship = {
    enable = true;
    settings = {
      "$schema" = "https://starship.rs/config-schema.json";

      add_newline = true;

      character = {
        success_symbol = "[└─➜](bold green)";
        error_symbol = "[└─✗](bold red)";
      };
    };
  }; 
}
