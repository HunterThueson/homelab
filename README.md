# Hunter's NixOS Homelab

Note: this README reflects an idealized version of the repository rather than the reality of where this repo stands now (which is why it's on the `structural-rework` branch rather than `master`; until the rework is merged, this README is **inaccurate.**).

---

## Features
- Flake-based NixOS configuration with support for multi-user, multi-host, multi-function deployment across my entire fleet of devices
- "Hub-and-spoke" architecture: sets opinionated defaults for packages, services, etc. which each host and/or user can opt into and optionally override
- Allows quickly and easily deploying new hosts or creating new users with a single file; automatically handles configuration on the backend
- Helper scripts for quickly creating new modules, hosts, users, roles, and groups

---

## Structure

This configuration is organized as a **hub-and-spoke module library**. `flake.nix` serves as the hub and exposes a shared pool of system and environment modules that any host or user can opt into. Per-host and per-user files declare intent by setting options instead of managing their own imports.

```
.
├── flake.nix               # The Hub; defines hosts and users and wires everything together
├── environment/            # User-level configuration with opinionated defaults
│   ├── desktop/            # Desktop environment modules (Hyprland, Plasma, etc.)
│   ├── editor/             # Editor configuration (Neovim via nixvim, Emacs)
│   ├── games/              # Game-specific configuration and launch options
│   ├── services/           # User-level services (Firefly III, OpenVPN, etc.)
│   ├── shell/              # Shell prompt and environment (Starship, etc.)
│   ├── terminal/           # Terminal emulator configuration (Alacritty, etc.)
│   └── themes/             # Unified theming via Stylix; color schemes and fonts
├── hosts/                  # Per-host entrypoints; each host sets its own options
│   ├── artemis/
│   └── hephaestus/
├── modules/                # Custom NixOS/Home-Manager modules defining the option schema
│   ├── hostSettings/       # Options and backend logic for host-level configuration
│   ├── roleSettings/       # Role and sub-role profiles for hosts (desktop, laptop, server, etc.)
│   ├── userSettings/       # Options and backend logic for user-level configuration
│   └── groupSettings/      # Permission and capability groups for users (wizard, gamer, etc.)
├── scripts/                # Helper scripts for common tasks (newhost, newuser, etc.)
├── system/                 # System-level configuration with opinionated defaults
│   ├── boot/               # Bootloader configuration (GRUB, systemd-boot)
│   ├── display/            # Display server configuration (Wayland, Xorg)
│   ├── hardware/           # Hardware-specific configuration (GPU, input devices, etc.)
│   ├── login-manager/      # Login manager configuration (greetd, SDDM)
│   └── nix/                # Nix daemon settings, garbage collection, etc.
└── users/                  # Per-user entrypoints; each user sets their own options
```

### How It Works

Modules under `./system/` and `./environment/` are imported globally by `flake.nix` and are available to all hosts and users. Modules expose options but don't enable anything by default. Importing a module has no effect until a host or user explicitly enables it. This means `hephaestus` and `artemis` can each be configured completely differently while drawing from the same shared module pool.

`hostSettings` and `roleSettings` work together to configure each host. `hostSettings` handles host-specific details like hostname and hardware. `roleSettings` sets the host's top-level role — `desktop`, `laptop`, or `server` — which automatically applies sensible defaults: laptops get touchpad support and suspend-on-lid-close; servers disable graphical sessions; desktops disable options like touchpad support or suspend-on-lid-close and assume always-on. Each role also exposes opt-in sub-roles that can be combined freely — a desktop can be both `gaming` and `workstation` simultaneously. Sub-roles enable relevant modules and expose additional options; for example, the `multiMonitor` sub-role allows each display's resolution, refresh rate, DPI, and orientation to be defined declaratively.

Desktop environment selection is handled as an enum rather than a set of individual enable flags, ensuring exactly one environment is active at a time:

```nix
userSettings.desktop.environment = "hyprland"; # or "plasma", "plasmax11", "niri", etc.
```

`userSettings` and `groupSettings` work the same way for users. `userSettings` wires together NixOS system-level and Home Manager options so that a new user can be fully declared in a single attribute set without touching multiple files. `groupSettings` defines capability groups that users can be assigned to: `wizard` grants read and write access to the flake configuration directory; `gamer` enables Steam, Lutris, and game-specific settings; and so on.

---

## What's Next?
- Set up Emacs with Evil Mode, Magit, and Org-Mode. Make sure it runs as a server & client so I don't have to perform startup tasks every time I launch a new window
- Personalize my workspaces, window rules, and keybinds so that window management & navigation is as smooth and easy as possible
- Build my own desktop environment with Quickshell
- Automate certain mundane tasks like garbage collection, updating from upstream sources, file backups, etc.
- Utilize `sops-nix` to manage secrets
- Create a live ISO with my preferred settings & utilities for setting up new hosts
