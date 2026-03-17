# ./system/display/wayland.nix

#------------------------------------#
#  Wayland Compositor Configuration  #
#------------------------------------#

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    egl-wayland                                   # EGL is an interface between OpenGL and the underlying windowing system.
  ];

  environment.sessionVariables = {

    # XWayland / Java (should fix Runelite's rendering issues)
    #_JAVA_AWT_WM_NONREPARENTING = "1";
    #_JAVA_OPTIONS = "-Dsun.java2d.opengl=false";  # test whether OpenGL context creation through XWayland is the culprit
    #_JAVA_OPTIONS = "-Dsun.java2d.xrender=true";  # force Java's software renderer

    # Run programs natively on Wayland
    NIXOS_OZONE_WL = "1";                         # Electron apps
    MOZ_ENABLE_WAYLAND = "1";                     # Firefox

    # XWayland scaling
    GDK_SCALE = "2";                              # Scale window up 2x for sharpness
    GDK_DPI_SCALE = "0.5";                        # Scale text back down so it stays the same size
    QT_SCALE_FACTOR = "1.25";

    # Cursor
    XCURSOR_SIZE = "32";

<<<<<<< Updated upstream
=======
    # Force XWayland to use the Nvidia EGL backend
    LIBGL_ALWAYS_SOFTWARE = "0";
    __EGL_VENDOR_LIBRARY_FILENAMES = "${pkgs.mesa}/share/glvnd/egl_vendor.d/50_mesa.json";

>>>>>>> Stashed changes
  };

}
