# users/hunter.nix

#------------------#
#  Hunter Thueson  #
#------------------#

# Plain function returning user data attrset.
# Consumed by both mkHosts.nix (NixOS) and mkHomes.nix (standalone HM).

{ pkgs, ... }:

{
  description = "Hunter";
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

  desktop = {
    environment = "hyprland";
    colorScheme = "electro-swing";
  };

  browser = "firefox";

  packages = with pkgs; [
    # Media & entertainment
    spotify                                                 # music
    mailspring                                              # email client
    discord                                                 # chat client
    calibre                                                 # ebook client
    gimp-with-plugins                                       # GNU Image Manipulation Program
      gimpPlugins.gmic                                      # GIMP plugin for the G'MIC image processing framework
    mpv                                                     # video playback
    imagemagick                                             # image editing tools for the command line
    yt-dlp                                                  # `youtube-dl` fork; download videos from websites like YouTube
    speedcrunch                                             # calculator

    # Fun
    cmatrix                                                 # look like freakin' HACKERMAN (so powerful he could hack time itself)
    neo-cowsay                                              # `cowsay` rewritten in Go (with bonus features!)

    # AI tools
    claude-code                                             # AI helper Claude
    realesrgan-ncnn-vulkan                                  # AI image upscaler (Real-ESRGAN)
    upscayl-ncnn                                            # AI image upscaler

    # Python
    python314                                               # Python release 3.14
    python313Packages.beautifulsoup4                        # Python web scraping utility
    python313Packages.types-beautifulsoup4                  # Typing stubs for beautifulsoup4

    # Rust
    cargo                                                   # Downloads dependencies and builds your Rust projects
    rustup                                                  # the Rust toolchain installer
    rustc                                                   # the Rust language itself
    rustfmt                                                 # a tool for formatting Rust code according to style guidelines
  ];

  extraSysConfig = {};
  extraHomeConfig = {};
}
