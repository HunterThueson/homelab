# ./system/display/wayland.nix

  ######################################
  #  Wayland Compositor Configuration  #
  ######################################

# TODO: Configure Wayland lol

{ config, pkgs, inputs, ... }:

{

  environment.systemPackages = with pkgs; [
    egl-wayland                                   # EGL is an interface between OpenGL and the underlying windowing system.
  ];

}
