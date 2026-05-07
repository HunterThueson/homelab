# Hunter's NixOS Configuration

Personal NixOS flake managing two hosts, multiple users, and a shared pool of system and environment modules. Designed around a hub-and-spoke architecture where hosts and users declare *what* they want and the backend figures out *how*.

## Hosts

| Host | Type | Role | Hardware |
|------|------|------|----------|
| **hephaestus** | Desktop | Workstation, gaming, writing | RTX 3090, ZSA Moonlander, dual monitors |
| **artemis** | Laptop | Workstation, gaming, writing | Lenovo ThinkPad |

---

## Architecture

### Hub-and-spoke

`flake.nix` is the hub. It defines each host's users and settings, then hands them to two builder functions:

- **`mkHosts`** builds full NixOS systems (`nixos-rebuild switch`) — system config + Home Manager for all users
- **`mkHomes`** builds standalone Home Manager configs (`home-manager switch`) — just one user's environment, no root required, much faster iteration

Both consume the same host definitions and the same pool of modules. The difference is scope: `mkHosts` wires everything; `mkHomes` only wires the user-facing parts.

### The two layers

Configuration is split into two directories based on a simple question: **does the user perceive the change?**

| Layer | Contents | Examples |
|-------|----------|----------|
| **`system/`** | Invisible plumbing the user never directly sees | Bootloader, GPU drivers, kernel params, user account creation, printer drivers |
| **`environment/`** | Things the user sees, feels, or interacts with | Color scheme, keybinds, editor config, terminal, shell prompt, window rules |

Some features straddle both layers — Hyprland needs a NixOS module enabled *and* per-user keybinds configured. These use the **dual-export pattern**: a single file returns `{ nixos = <module>; home = <module>; }`, and the builder functions extract the right part for each context. One file per feature, no duplication.

### Schemas vs backends

The `modules/` directory contains **option schemas only** — it defines *what* can be configured (GPU type, desktop environment, editor preference, etc.) but doesn't *do* anything. The actual implementation lives in `system/` and `environment/`, which read the schema values and configure the system accordingly. This separation means you can read `modules/` to understand the interface and `system/`/`environment/` to understand the implementation.

---

## Directory Structure

```
.
├── flake.nix                  # Hub: defines hosts and users with simple syntax
│                                and wires everything together
├── lib/
│   ├── mkHosts.nix            # Builds nixosSystem for each host; detects dual-export modules
│   ├── mkHomes.nix            # Builds standalone homeConfigurations for fast HM iteration
│   └── presets/               # Hardware preset attrsets (GPUs, keyboards, monitors)
│
├── modules/                   # Option schemas only (no implementation)
│   ├── hostSettings/          # Host-level options (type, role, hardware, display)
│   └── userSettings/          # User-level options (editor, shell, desktop, packages)
│
├── system/                    # System-level backend implementation via hostSettings + userSettings
│   ├── boot/                  # Bootloader: GRUB or systemd-boot (via hostSettings.hardware.boot)
│   ├── display/               # Display server (Wayland, Xorg)
│   ├── hardware/              # GPU, input devices, printers
│   │   └── gpu/               # Generic multi-GPU support (Nvidia, AMD, Intel)
│   ├── login-manager/         # greetd or SDDM (via hostSettings.loginManager)
│   ├── nix/                   # Nix daemon settings, garbage collection
│   └── users.nix              # Creates user accounts from userSettings
│
├── environment/               # User-level backends (HM modules or dual-export)
│   ├── desktop/               # Hyprland, Plasma (dual-export)
│   ├── dev/                   # Development tools: Git (HM module)
│   ├── editor/                # Emacs + Nixvim (dual-export)
│   ├── games/                 # Steam, OSRS (dual-export, enabled by "gaming" role)
│   ├── shell/                 # Bash, Zsh/Fish enabling, Starship (dual-export)
│   ├── terminal/              # Alacritty (HM module)
│   └── themes/                # Fonts, Stylix (dual-export)
│
├── users/                     # Plain functions returning user data attrsets
│   ├── hunter.nix
│   └── ash.nix
│
└── hosts/                     # Per-host hardware config and overrides
    ├── hephaestus/
    └── artemis/
```

---

## How It Works

### Adding a host

Define it in `flake.nix` with its users and settings:

```nix
hostDefs = {
  my-new-host = {
    users = [ "hunter" ];
    hostSettings = {
      system = "x86_64-linux";
      type = "laptop";
      role = [ "workstation" ];
      hardware = {
        gpu = [ gpuPresets."integrated-intel" ];
        keyboard.layout = "qwerty";
      };
    };
  };
};
```

Then create `hosts/my-new-host/` with a `default.nix`, `configuration.nix` (host-specific overrides), and `hardware.nix` (generated by `nixos-generate-config`).

### Adding a user

Create `users/my-user.nix` as a plain function:

```nix
{ pkgs, ... }:
{
  description = "My User";
  fullName = "My Name";
  email = "me@example.com";
  shell = "bash";
  editor.terminal = "vim";
  desktop.environment = "hyprland";
  packages = with pkgs; [ firefox spotify ];
}
```

Then add the username to a host's `users` list in `flake.nix`. The system automatically creates the user account, sets up Home Manager, and applies all environment modules based on the user's preferences.

### Two rebuild paths

```bash
# Full system + all users' Home Manager (requires root)
sudo nixos-rebuild switch --flake .#hephaestus

# Just one user's Home Manager (no root, fast)
home-manager switch --flake .#hunter@hephaestus
```

---

## What's Next

- Wire remaining `environment/` module stubs to `userSettings` (desktop, themes)
- Wire remaining `system/` modules to `hostSettings` (login manager, display, boot)
- Customize Hyprland workspaces, window rules, and keybinds
- Implement `roleSettings` and `groupSettings` for role-based defaults
- Automate garbage collection, flake updates, and file backups
- Set up `sops-nix` for secrets management
- Build a custom desktop environment with Quickshell
- Create a live ISO for deploying new hosts
- Update artemis `hardware.nix` with real UUIDs and deploy
- Write documentation for all features, options, and modules (project wiki)
- Test on real hardware and iterate

---

## Project History

This configuration has been my daily driver and learning project since **July 2022**. The commit history tells the story:

**2022-2025** — Built the initial configuration from scratch: GRUB and systemd-boot setup, Nvidia GPU configuration, Hyprland and Plasma desktop environments, SDDM and greetd login managers, Xorg dual-monitor support, Home Manager integration, Starship shell prompt, Alacritty terminal, package management, and all the iterative debugging that comes with learning NixOS. All of this work was done manually.

**Early 2026** — Added Emacs configuration (Evil mode, Org-Roam, Magit, capture templates), printer support, hardware monitoring tools (LACT, nvtop), development toolchains (Rust, Python), and continued refining the system. Also began planning a structural rework to support multi-host deployment and faster iteration — the configuration had grown organically and needed a more principled architecture. All of this work was done manually.

**April-May 2026** — Executed the structural rework on the `structural-rework` branch. This is where AI was used — see disclosure below.

### AI Usage Disclosure

The structural rework (the `rework(...)` commits) was done with assistance from Claude, an AI assistant by Anthropic. I want to be transparent about what that means and doesn't mean.

**What I did:**
- Designed the hub-and-spoke architecture and the separation between `modules/`, `system/`, and `environment/`
- Made all architectural decisions: the dual-export pattern (my preference over splitting config across directories), the perceptual boundary principle for `environment/` vs `system/`, standalone Home Manager separation, and the coupled+fast-path rebuild strategy
- Defined the option schemas and decided what should be configurable vs hardcoded
- Reviewed all generated code and directed revisions
- Built the entire pre-rework codebase (4 years of commits) without AI assistance
- Continued adding features on `master` during the rework period (Emacs overhaul, printer support, hardware tools) without AI assistance

**What the AI did:**
- Implemented the architectural decisions I made — writing the Nix module code for `mkHosts`, `mkHomes`, dual-export modules, schema definitions, and system backends
- Helped debug evaluation errors during the rework (unfree package resolution, NixOS vs HM option conflicts, module detection logic)
- Helped me understand Nix patterns I wasn't familiar with (like `attrsOf submodule`, `lib.mkMerge`, and the mechanics of standalone Home Manager)

**Why I used AI for this:**
I'm learning NixOS with the goal of working with it professionally. The rework involved restructuring dozens of interdependent files simultaneously — the kind of change where a single syntax error in one file breaks evaluation of everything, and where the feedback loop of "change, rebuild, debug, repeat" across that many files would have taken weeks of evenings. I used AI to accelerate the implementation so I could focus on understanding the design patterns and architectural tradeoffs rather than fighting Nix syntax for every line. Now that the structure is in place, future development will be manual — the whole point of this rework was to make the codebase easier to understand and extend, and I intend to do that myself.

The foundational work — the hardware configurations, desktop environments, editor setups, display server configs, and everything else that makes this a functional daily-driver system — was built by hand over four years of learning NixOS.
