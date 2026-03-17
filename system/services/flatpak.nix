# system/services/flatpak.nix

#-----------#
#  Flatpak  #
#-----------#

{ ... }:

{
  services.flatpak = {
    enable = true;

    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];

    packages = [
      {
        appId = "com.github.oxos.bolt";
        origin = "flathub";
      }
    ];

    update.onActivation = true;             # auto-update flatpaks on nixos-rebuild
  };
}
