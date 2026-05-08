# users/ash.nix

#-------#
#  Ash  #
#-------#

# Plain function returning user data attrset.
# Consumed by both mkHosts.nix (NixOS) and mkHomes.nix (standalone HM).

{ pkgs, ... }:

{
  description = "Ash";
  fullName = "Ash";

  administrator = true;
  extraGroups = [ "wizard" ];
  hashedPassword = "$6$rounds=9999999$FThVWftaj3S0ShgC$C2HOgr7dst7/rnTy2NhLt5aiOOifhZ4cvg1XZ513VBMvxNg3fUGdH/ajdlnSHSKoxSpfoN84EqD3f6cOSL2/y.";

  shell = "bash";
  enableGit = false;

  desktop = {
    environment = "plasmax11";
    colorScheme = "electro-swing";
  };

  browser.name = "firefox";

  packages = with pkgs; [

    # Media & entertainment
    spotify                                                 # music
    mailspring                                              # email client
      libsecret                                             # dependency for mailspring
    discord                                                 # chat client
    gimp-with-plugins                                       # GNU Image Manipulation Program
      gimpPlugins.gmic                                      # GIMP plugin for the G'MIC image processing framework
    mpv                                                     # video playback
    imagemagick                                             # image editing tools for the command line
    yt-dlp                                                  # `youtube-dl` fork; download videos from websites like YouTube
    ffmpeg_6-full                                           # video transcoding utility (and a dependency for many other programs)
    instaloader                                             # download photos & videos from Instagram
    speedcrunch                                             # calculator

    # Terminal utilities
    gh                                                      # GitHub CLI
    tldr                                                    # quickly summarize command usage
    killall                                                 # kill programs with ease
    wget                                                    # download files from the command line
    unzip                                                   # extract / unzip file archives

  # System info/monitoring
    neofetch                                                # display system info
    gtop                                                    # graphical `top`
    btop                                                    # another fancy `top`

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
    rustup                                                  # the Rust toolchain installer (manages cargo, rustc, rustfmt)

    # Build tools
    binutils                                                # dependency for `make`
    xorriso                                                 # dependency for `make iso`

  # Networking
    openvpn                                                 # connect to VPN

  # Misc dependencies
    binutils                                                # dependency for `make`
    xorriso                                                 # dependency for `make iso`

  # Version control
    git                                                     # version control utility
    gh                                                      # GitHub CLI

  # X11 tools
    xorg.xdpyinfo                                           # get information about X display(s)

  # Terminal
    alacritty                                               # GPU-accelerated terminal emulator
    starship                                                # blazing fast, highly customizable prompt for any shell
    tldr                                                    # quickly summarize command usage
    eza                                                     # modern replacement for `ls` written in Rust
    ripgrep                                                 # modern replacement for `grep` written in Rust
    killall                                                 # kill programs with ease
    fd                                                      # modern replacement for `find` written in Rust

   ];

  extraSysConfig = {};
  extraHomeConfig = {};
}
