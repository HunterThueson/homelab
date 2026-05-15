# hosts/installer/default.nix

#-------------#
#  Installer  #
#-------------#

# Custom NixOS live installer ISO with Hyprland, Alacritty,
# and the electro-swing color scheme. Boots directly into a
# graphical Hyprland session as the `nixos` user.
#
# Build:
#   nix build .#nixosConfigurations.installer.config.system.build.isoImage
#
# Result:
#   ./result/iso/nixos-*.iso

{ config, pkgs, lib, inputs, ... }:

let
  hyprlandPkg = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;

  # Wrapper script that places config files then launches Hyprland.
  # Runs as the nixos user via greetd, so configs are owned correctly
  # and guaranteed to exist before Hyprland reads them.
  start-hyprland = pkgs.writeShellScript "start-hyprland" ''
    # Hyprland config
    mkdir -p ~/.config/hypr
    cp -f ${./hyprland.lua} ~/.config/hypr/hyprland.lua
    cp -f ${./wallpaper.png} ~/.config/hypr/wallpaper.png

    # Alacritty config
    mkdir -p ~/.config/alacritty
    cp -f ${../../environment/themes/colors/electro-swing.toml} ~/.config/alacritty/colors.toml
    cat > ~/.config/alacritty/alacritty.toml << 'EOF'
    [general]
    import = ["~/.config/alacritty/colors.toml"]

    [window]
    decorations = "none"
    opacity = 0.97
    padding = { x = 5, y = 4 }

    [font]
    size = 9.0

    [font.normal]
    family = "FiraCode Nerd Font"
    EOF

    # Rofi config (electro-swing dark theme)
    mkdir -p ~/.config/rofi
    cat > ~/.config/rofi/config.rasi << 'EOF'
    * {
        bg:    #131313;
        fg:    #cbcec6;
        ac:    #52e9e9;
    }
    window { background-color: @bg; }
    mainbox { background-color: @bg; }
    inputbar { background-color: @bg; text-color: @fg; }
    listview { background-color: @bg; }
    element { background-color: @bg; text-color: @fg; }
    element selected { background-color: @ac; text-color: @bg; }
    EOF

    cat > ~/.bashrc << 'EOF'
      # Teleport to config directory
      cdc () {
        cd ~/.config
        clear
        eza -DG --icons=auto --group-directories-first
      }

      # Teleport to NixOS directory
      cdn () {
        cd /etc/nixos
        clear
        eza -DG --icons=auto --group-directories-first
      }

      # gh wrapper to make listing issues easier
      gh () {
        if [[ $@ == "issue list" ]]; then
          command gh issue list -L 100
        else
          command gh "$@"
        fi
      }
    EOF

    exec ${hyprlandPkg}/bin/start-hyprland
  '';
in
{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-base.nix"
  ];

  # ----------------
  #  ISO metadata
  # ----------------

  image.fileName = lib.mkForce "nixos-installer-hyprland.iso";

  # ----------------
  #  Hyprland
  # ----------------

  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    withUWSM = false;
    package = hyprlandPkg;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    substituters = [ "https://hyprland.cachix.org" ];
    trusted-substituters = [ "https://hyprland.cachix.org" ];
    trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
  };

  programs.bash = {
    enable = true;
    shellAliases = {
      # ls replacements (eza)
      ls  = "eza -G --color=auto --icons=auto --group-directories-first";
      lsa = "eza -Gau --git --time-style long-iso --color=always --icons";
      lsd = "eza -D --color=auto --icons=auto";
      lst = "eza -T --color=auto --icons=auto --group-directories-last";

      # Navigation
      ghs = "git status";

      # Drop-in replacements
      find = "fd";

      # Terminal clearing
      cl   = "clear";
      cls  = "clear && eza -G --color=auto --icons=auto --group-directories-first";
      clsa = "clear && eza -Gau --git --time-style long-iso --color=always --icons";
      clsd = "clear && eza -D --color=auto --icons=auto";
      clst = "clear && eza -T --color=auto --icons=auto --group-directories-last";
    };
  };

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

  # ----------------
  #  Stylix theming
  # ----------------

  stylix = {
    enable = true;
    base16Scheme = ../../environment/themes/colors/electro-swing.yaml;

    fonts = {
      sizes.terminal = 9;
      monospace = {
        package = pkgs.nerd-fonts.fira-code;
        name = "FiraCode Nerd Font";
      };
      serif = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "Source Code Pro Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.sauce-code-pro;
        name = "Source Code Pro Nerd Font";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  # ----------------
  #  Fonts
  # ----------------

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      nerd-fonts.fira-code
      nerd-fonts.sauce-code-pro
    ];
    fontconfig.defaultFonts.monospace = [ "FiraCode Nerd Font" ];
  };

  # ----------------
  #  Packages
  # ----------------

  environment.systemPackages = with pkgs; [
    # Hyprland ecosystem
    dunst
    libnotify
    networkmanagerapplet
    rofi
    swww
    waybar
    wl-clipboard
    grim
    slurp

    # Terminal
    alacritty
    eza
    fd

    # Installation tools
    gparted
    parted
    cryptsetup
    dosfstools
    e2fsprogs
    btrfs-progs
    nix-output-monitor

    # Secrets management
    sops
    age
    ssh-to-age

    # General utilities
    git
    vim
    firefox
    neofetch
    htop
  ];

  # ----------------
  #  Networking
  # ----------------

  networking = {
    networkmanager.enable = true;
    wireless.enable = lib.mkForce false;  # NM handles WiFi
  };

  # ----------------
  #  Auto-login
  # ----------------
  # Boot directly into Hyprland as the nixos user (no display manager).
  # The wrapper script places config files before launching Hyprland.

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${start-hyprland}";
      user = "nixos";
    };
  };

  # Disable any other display manager the graphical-base module enables
  services.displayManager.gdm.enable = lib.mkForce false;
  services.displayManager.sddm.enable = lib.mkForce false;

  # ----------------
  #  TTY access
  # ----------------
  # Ensure TTY2-6 are available for emergency access

  services.getty.autologinUser = lib.mkForce "nixos";

  # ----------------
  #  Nixvim
  # ----------------

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    plugins = {
      nix.enable = true;
      lightline.enable = true;
      lspconfig.enable = true;
      lastplace.enable = true;
      treesitter = {
        enable = true;
        settings.highlight.enable = true;
      };
    };

    opts = {
      clipboard = "unnamedplus";
      number = true;
      relativenumber = true;
      ruler = true;
      wrap = false;
      autoindent = true;
      expandtab = true;
      tabstop = 2;
      shiftwidth = 2;
      incsearch = true;
      hlsearch = true;
    };
  };

  # ----------------
  #  Misc
  # ----------------

  # PipeWire for audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
  };

  time.timeZone = "America/Denver";
  i18n.defaultLocale = "en_US.UTF-8";
}
