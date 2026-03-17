# environment/games/old-school-runescape.nix

#------------------------#
#  Old School Runescape  #
#------------------------#

{ config, pkgs, lib, ... }:

let
  cfg = config;
in

{
  environment.systemPackages = with pkgs; [
    (bolt-launcher.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/bolt-launcher \
          --set _JAVA_AWT_WM_NONREPARENTING 1 \
          --set MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE 1
      '';
    }))
  ];
}
