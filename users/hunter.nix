# ./users/hunter.nix

  #------------------#
  #  Hunter Thueson  #
  #------------------#

{ config, pkgs, ... }:

{
  userSettings.hunter = {
    name = "Hunter";
    fullName = "Hunter Thueson";
    email = "hunter.thueson@gmail.com";

    administrator = true;
    extraGroups = [ "wizard" ];
    hashedPassword = "$6$rounds=500000$ilzR8OoFwfvEOzfO$iJ9QJzjIINDW8ON33jTIIxe/B2XcB3MnCR7/qaA6NC2Sw6efZvX2HJ4l3vif8/ggmAv/4GutT8Xt4/wAgLW0H.";

    editor = {
      terminal = "vim";
      gui = "emacs";
    };
    shell = "bash";
    enableGit = true;

    windowManager = "hyprland";
    browser = "firefox";

    packages = with pkgs; [
      firefox                                                 # web browser
      spotify                                                 # music
      mailspring                                              # email client
      discord                                                 # chat client
      calibre                                                 # ebook client
      gimp-with-plugins                                       # GNU Image Manipulation Program
        gimpPlugins.gmic                                      # GIMP plugin for the G'MIC image processing framework
      cmatrix                                                 # look like freakin' HACKERMAN (so powerful he could hack time itself)
      neo-cowsay                                              # `cowsay` rewritten in Go (with bonus features!)
      mpv                                                     # video playback
      imagemagick                                             # image editing tools for the command line
      yt-dlp                                                  # `youtube-dl` fork; download videos from websites like YouTube
      speedcrunch                                             # calculator
    ];

    extraSysConfig = {
      # System configuration not available in userSettings goes here
    };
    extraHomeConfig = {
      # User configuration not available in userSettings goes here
    };
  };
}
