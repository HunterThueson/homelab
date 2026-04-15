# ./system/environment/packages.nix

#------------#
#  Packages  #
#------------#

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

  # Version control
    git                                                     # version control utility
    gh                                                      # GitHub CLI

  # Terminal
    alacritty                                               # GPU-accelerated terminal emulator
    starship                                                # blazing fast, highly customizable prompt for any shell
    tldr                                                    # quickly summarize command usage
    eza                                                     # modern replacement for `ls` written in Rust
    ripgrep                                                 # modern replacement for `grep` written in Rust
    killall                                                 # kill programs with ease
    fd                                                      # modern replacement for `find` written in Rust
    unzip                                                   # extract stuff / unzip file archive

  # System info/monitoring
    neofetch                                                # display system info
    gtop                                                    # graphical `top`
    btop                                                    # another fancy `top`

  # Networking
    wget                                                    # download files from the command line
    iw                                                      # show & manipulate wireless devices
    openvpn                                                 # connect to VPN
  
  # Hardware utilities
    parted                                                  # CLI partition management utility
    gparted                                                 # GUI partition management utility
    cryptsetup                                              # LUKS for dm-crypt
    ctmg                                                    # Encrypted container manager for Linux using cryptsetup
    openrgb                                                 # open source RGB lighting control utility

  # Media utilities
    ffmpeg_6-full                                           # video transcoding utility (and a dependency for many other programs)
    instaloader                                             # utility for downloading photos & videos from Instagram

  # Misc dependencies (TODO: review whether this is necessary)
    libsecret                                               # dependency for mailspring
    binutils                                                # dependency for `make`
    xorriso                                                 # dependency for `make iso`
    libsForQt5.qtstyleplugin-kvantum                        # dependency for Kvantum (KDE themes)

  # Graphics monitoring utilities
    nvtopPackages.full                                      # htop-like task monitor for AMD, Adreno, Intel and NVIDIA GPUs
    lact                                                    # Linux GPU Control Application (LACT)
    xorg.xdpyinfo                                           # get information about X display(s)

  # AI 
    claude-code                                             # AI helper Claude
    realesrgan-ncnn-vulkan                                  # AI image upscaler (Real-ESRGAN)
    upscayl-ncnn                                            # AI image upscaler (Real-ESRGAN)

  # Games
    bolt-launcher                                           # Alternative launcher for Runescape
    wineWow64Packages.full                                  # Fix dependency issue with bolt-launcher (I think?)
    jdk17                                                   # TODO: review whether this is necessary)

  # Programming & development tools

    # TODO: rewrite this section into a proper shell.nix and become a REAL Nix developer

    # Python 3
      python314                                             # Python release 3.14.3
      python313Packages.beautifulsoup4                      # Python web scraping utility for development
      python313Packages.types-beautifulsoup4                # Typing stubs for beautifulsoup4

    # Rust
      cargo                                                 # Downloads dependencies and builds your Rust projects
      rustup                                                # the Rust toolchain installer
      rustc                                                 # the Rust language itself
      rustfmt                                               # a tool for formatting Rust code according to style guidelines

  ];
}

