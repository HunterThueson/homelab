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
    parted                                                  # CLI partition management
    unzip                                                   # extract stuff / unzip file archive
    ffmpeg_6-full                                           # video transcoding utility (and a dependency for many other programs)
    instaloader                                             # utility for downloading photos & videos from Instagram

  # System info/monitoring
    neofetch                                                # display system info
    gtop                                                    # graphical `top`
    btop                                                    # another fancy `top`

  # GUI
    gparted                                                 # GUI partition management

  # the Rust programming language 
    cargo                                                   # downloads your Rust project's dependencies and builds your project
    rustup                                                  # the Rust toolchain installer
    rustc                                                   # the Rust language itself
    rustfmt                                                 # a tool for formatting Rust code according to style guidelines

  # Networking
    wget                                                    # download files from the command line
    iw                                                      # show & manipulate wireless devices
    openvpn                                                 # connect to VPN
  
  # Hardware utilities
    openrgb                                                 # open source RGB lighting control utility
    parted
    cryptsetup

  # Misc dependencies
    libsecret                                               # dependency for mailspring
    binutils                                                # dependency for `make`
    xorriso                                                 # dependency for `make iso`
    libsForQt5.qtstyleplugin-kvantum                        # dependency for Kvantum (KDE themes)

  # Graphics management software
    nvtopPackages.full
    lact                                                    # Linux GPU Control Application (LACT)

  # AI image upscaling software (Real-ESRGAN)
    realesrgan-ncnn-vulkan
    upscayl-ncnn

    wineWow64Packages.full                                  # fix dependency issue with bolt launcher
    jdk17                                                   # fix dependency issue with bolt launcher

  # Bolt Launcher (Old School Runescape)                    -- overrides a few session variables for this program to reduce flickering
    (bolt-launcher.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ makeWrapper ];
      postInstall = (old.postInstall or "") + ''
        wrapProgram $out/bin/bolt-launcher \
          --set _JAVA_AWT_WM_NONREPARENTING 1 \
          --set MESA_VK_DEVICE_SELECT_FORCE_DEFAULT_DEVICE 1
      '';
    }))

    python313Packages.beautifulsoup4
    python313Packages.types-beautifulsoup4
  ];
}

