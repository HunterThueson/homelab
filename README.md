# Hunter's NixOS Homelab

Personal NixOS flake managing two hosts, multiple users, and a shared pool of system and environment modules. Designed around a hub-and-spoke architecture where hosts and users are declared in simple syntax and the backend enables opinionated defaults automatically; per-user and per-host overrides are supported for edge cases where the default settings should not apply.

## Hosts

| Host | Type | Role | Hardware |
|------|------|------|----------|
| **hephaestus** | Desktop | Workstation, gaming, writing | RTX 3090, ZSA Moonlander, dual monitors |
| **artemis** | Laptop | Workstation, writing | Lenovo ThinkPad X1 Carbon Gen 12 |

---

## Design Principles & Core Values

1. **Simplicity**
    - Deploying a new user or host should be easy. Declare what you want in just a few lines and let the backend take care of the rest.
    - Sensible defaults are applied automatically, reducing the time each new user or host must spend configuring their own system.
2. **Flexibility**
    - Everything is overrideable. Users and hosts with special requirements or different preferences retain the ability to override the default settings with relative ease.
3. **Extensibility**
    - Certain types of users have shared requirements; for example, developers need access to version control and support for programming languages. Instead of declaring those needs in each user's personal config over and over, the system administrator can assign each user a `role` and add functionality to every relevant user at the same time from just one file.
4. **Transparency**
    - Extensive documentation is extremely important. The codebase and design decisions will (eventually) be thoroughly documented in the project wiki. **This is still a work in progress.** Documentation is next on the to-do list.
    - AI was used to help rework this project during a short period of time in early 2026. See the AI Disclosure section below for more details.

---

## Architecture

### Hub-and-spoke

`flake.nix` is the hub. It defines each host and user as pure data, then hands them to two builder functions:

- **`mkHosts`** builds full NixOS systems (`nixos-rebuild switch`) — system config + Home Manager for all users
- **`mkHomes`** builds standalone Home Manager configs (`home-manager switch`) — just one user's environment, no root required, much faster iteration

Both consume the same host and user definitions and the same pool of modules. The difference is scope: `mkHosts` wires everything; `mkHomes` only wires the user-facing parts.

### The two layers

Configuration is split into two directories based on a simple question: **does the user perceive the change?**

| Layer | Contents | Examples |
|-------|----------|----------|
| **`system/`** | Invisible plumbing the user never directly sees | Bootloader, GPU drivers, kernel params, user account creation, printer drivers |
| **`environment/`** | Things the user sees, feels, or interacts with | Color scheme, keybinds, editor config, terminal, shell prompt, window rules |

Some features straddle both layers — Hyprland needs a NixOS module enabled *and* per-user keybinds configured. These use the **dual-export pattern**: a single file returns `{ nixos = <module>; home = <module>; }`, and the builder functions extract the right part for each context. One file per feature, no duplication.

### Schemas vs backends

The `modules/` directory contains **option schemas only** — it defines *what* can be configured (GPU type, desktop environment, editor preference, user roles, etc.) but doesn't *do* anything. The actual implementation lives in `system/` and `environment/`, which read the schema values and configure the system accordingly. This separation means you can read `modules/` to understand the interface and `system/`/`environment/` to understand the implementation.

### Roles

Users can be assigned roles (`wizard`, `developer`, `gamer`, `filmmaker`, `writer`) which automatically enable relevant features. Role modules live in `modules/userSettings/roles/` and use the dual-export pattern:

- **wizard** — creates the `wizard` group, manages `/etc/nixos` permissions, auto-enables git, adds the `cdn` shell function for quick navigation to `/etc/nixos/`
- **gamer** — enables Steam runtime, installs game clients (Discord, Bolt Launcher)

*Note: the role system is a work in progress. Some roles are defined in the schema but have not yet been implemented on the backend.*

---

## Directory Structure

```
.
├── flake.nix                  # Hub: defines hosts and users as pure data,
│                                wires everything together
├── lib/
│   ├── default.nix            # Single import for all lib utilities (mkHosts, mkHomes, presets)
│   ├── mkHosts.nix            # Builds nixosSystem for each host; detects dual-export modules
│   ├── mkHomes.nix            # Builds standalone homeConfigurations for fast HM iteration
│   └── presets/               # Hardware preset attrsets (GPUs, keyboards, monitor layouts)
│
├── modules/                   # Option schemas only (no implementation)
│   ├── hostSettings/          # Host-level options (type, role, hardware, display)
│   └── userSettings/          # User-level options (editor, shell, desktop, browser, roles)
│       └── roles/             # Dual-export role modules (wizard, gamer, writer, etc.)
│
├── system/                    # System-level backend implementation via hostSettings + userSettings
│   ├── boot/                  # Bootloader: GRUB or systemd-boot (via hostSettings.hardware.boot)
│   ├── display/               # Xorg (via hostSettings.hardware.display), Wayland
│   ├── hardware/              # GPU, input devices, networking, printers
│   │   ├── gpu/               # Generic multi-GPU support (Nvidia, AMD, Intel)
│   │   └── inputDevices/      # Keyboard layout, touchpad, ZSA (via hostSettings.hardware)
│   ├── login-manager/         # greetd or SDDM (via hostSettings.loginManager)
│   ├── nix/                   # Nix daemon settings, garbage collection
│   ├── security/              # Security modules & secrets (sops-nix, age keys, etc.)
│   └── users.nix              # Creates user accounts from userSettings (groups, SDDM nickname)
│
├── environment/               # User-level backends (HM modules or dual-export)
│   ├── browser/               # Firefox (HM module, reads userSettings.browser)
│   ├── desktop/               # Hyprland (keybinds, window rules, hyprland.conf), Plasma (dual-export)
│   ├── dev/                   # Developer tooling - Git config, GitHub CLI, Python/Rust support, etc.
│   ├── editor/                # Emacs + Org-Roam, Nixvim (dual-export)
│   ├── games/                 # Steam, OSRS, Discord (dual-export, gated on "gamer" role)
│   ├── services/              # Firefly III, OpenVPN (currently stubs)
│   ├── shell/                 # Bash, Starship prompt (dual-export)
│   ├── terminal/              # Alacritty (HM module)
│   └── themes/                # Colors, fonts, Stylix, wallpaper management, etc. (dual-export)
│
├── users/                     # Per-user HM module directories
│   ├── hunter/                # packages.nix, services.nix, future overrides (Firefox, etc.)
│   └── ash/                   # packages.nix, services.nix
│
└── hosts/                     # Per-host hardware config and overrides
    ├── hephaestus/
    └── artemis/
```

---

## How It Works

### Adding a host

Define it in `flake.nix` with its settings:

```nix
hostDefs = {
  my-new-host = {
    users = [ "hunter" ];
    stateVersion = "25.11";

    hostSettings = {
      system = "x86_64-linux";
      type = "laptop";
      role = [ "workstation" ];
      loginManager = "sddm";
      hardware = {
        boot.loader = "systemd-boot";
        gpu = [ gpuPresets."integrated-intel" ];
        keyboard = {
          layout = "qwerty";
          model = keyboardPresets.lenovoThinkPad."built-in";
        };
      };
    };
  };
};
```

Then create `hosts/my-new-host/` with a `default.nix`, `configuration.nix` (host-specific overrides), and `hardware.nix` (generated by `nixos-generate-config`).

Once the host has been deployed, decrypt the master key with your password to enable editing secrets:

```
nix-shell -p age --run \
  'mkdir -p ~/.config/sops/age && \
  age -d -o ~/.config/sops/age/keys.txt system/security/secrets/master-key.age'
```

Generate an age key using `ssh-to-age`:

```
nix-shell -p ssh-to-age --run \
  'ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub'
```

This outputs an age public key like `age1qx...`. Add the public key to `.sops.yaml` under the top-level `keys:` block:

```
keys:
  # Per-user keys
  - &hunter age1xxxxxxxx...

  # Per-host keys
  - &hephaestus age1yyyyyyy...
  - &artemis age1zzzzzz...
  - &[new-hostname] age1aaaaaa...
```

Then add the new host to the `creation_rules` block.

### Adding a user

Define the user's identity and preferences in `flake.nix`:

```nix
userDefs = {
  my-user = {
    nickname    = "My User";
    fullName    = "My Name";
    email       = "me@example.com";
    role        = [ "wizard" "developer" ];
    shell       = "bash";
    editor      = { terminal = "vim"; gui = "emacs"; };
    desktop     = { environment = "plasmax11"; colorScheme = "electro-swing"; };
    browser.name = "firefox";
  };
};
```

Then create `users/my-user/` with a `default.nix` that imports `packages.nix` and `services.nix` for user-specific packages and HM services. Add the username to a host's `users` list in `flake.nix`. The system automatically creates the user account, sets up Home Manager, and applies all environment modules based on the user's preferences and roles.

Once the user has been created, hash the user's password and add it to `system/security/secrets/secrets.yaml`:

```
nix-shell -p libxcrypt sops age --run bash

# Generate a hashed password (will prompt for input):
mkpasswd -m sha-512 -R 500000

# Add the hashed password to `.../secrets.yaml`
sops system/security/secrets/secrets.yaml
```

Generate a personal age key for the user:

```
nix-shell -p sops age xclip --run bash

# Generate the age key:
mkdir -p ~/.config/sops/age && age-keygen -o ~/.config/sops/age/keys.txt

# Add the public key to the clipboard for easy copy-paste:
awk '/^# public key:/ {print $NF}' ~/.config/sops/age/keys.txt | xclip -selection c
```

Then add the resulting public key to `.sops.yaml` as in the section above ("Adding a host").

Allow the user's key to decrypt existing secrets:

```
nix-shell -p sops age --run \
  'sops updatekeys system/security/secrets/secrets.yaml'
```

Finally, declare the user's secret in `system/security/sops.nix`.

*Note: make sure to use the format `[username]-hashed-password` in `secrets.yaml` and `sops.nix` so the user account creation function can find it properly.*

### Two rebuild paths

```bash
# Full system + all users' Home Manager (requires root)
sudo nixos-rebuild switch --flake .#hephaestus

# Just one user's Home Manager (no root, fast)
home-manager switch --flake .#hunter@hephaestus
```

---

## Project History

This configuration has been my daily driver and learning project since **July 2022**. The commit history tells the story:

**2022 - 2025** — Built the initial configuration from scratch: GRUB and systemd-boot setup, Nvidia GPU configuration, Hyprland and Plasma desktop environments, SDDM and greetd login managers, Xorg dual-monitor support, Home Manager integration, Starship shell prompt, Alacritty terminal, package management, and all the iterative debugging that comes with learning NixOS. All of this work was done manually.

**Early 2026** — Added Emacs configuration (Evil mode, Org-Roam, Magit, capture templates), printer support, hardware monitoring tools (LACT, nvtop), development toolchains (Rust, Python), and continued refining the system. Also began planning a structural rework to support multi-host deployment and faster iteration — the configuration had grown organically and needed a more principled architecture. All of this work was done manually.

**April - May 8, 2026** — Executed the structural rework on the `structural-rework` branch, then merged it back into `master`. This is where AI was used — see disclosure below.

**May 8, 2026 - present** — From this point forward, ongoing work will be implemented manually. AI is still used to help me understand difficult concepts and to review my work.

---

## What's Next

- Finish setting up Emacs keybinds and Org Roam functionality
- Create a project wiki for this repository - write extensive & thorough documentation
- Implement easy-to-use shell wrapper functions for `nixos-rebuild` and `home-manager switch`
- Implement host type modules (desktop, laptop, server) with type-specific defaults
- Implement remaining role modules (gamer, developer, filmmaker, writer) with role-specific defaults
- Create a live ISO for deploying new hosts
- Update artemis `hardware.nix` with real UUIDs and deploy to laptop
- Create & deploy a new server host for use as a personal NAS/web server
- Automate garbage collection, flake updates, and file backups
- Declaratively configure Firefox preferences - default values for all users & user-specific overrides
- Wire remaining environment/ modules to userSettings (remaining shell options, desktop fine-tuning)
- Wire remaining system/ modules to hostSettings (inputDevices, display, login-manager refinements)
- Make monitor config dynamic instead of hardcoded in hyprland.conf, add monitor presets
- Build a custom desktop environment with Quickshell

---

## AI Usage Disclosure

The structural rework (the `rework(...)` and `merge(...)` commits) was done with assistance from Claude Code. I want to be transparent about what that means and doesn't mean.

**What I did:**
- Designed the hub-and-spoke architecture and the logical separation between `modules/`, `system/`, and `environment/`
- Made all architectural decisions: the dual-export pattern (my preference over splitting config across directories), the perceptual boundary principle for `environment/` vs `system/`, standalone Home Manager separation, the coupled+fast-path rebuild strategy, per-user HM module directories, and user identity data in flake.nix
- Defined the option schemas and decided what should be configurable vs hardcoded
- Designed the role system and decided role responsibilities (group permissions, role-specific functionality & features)
- Reviewed all generated code and directed revisions
- Built the entire pre-rework codebase (4 years of commits) without AI assistance
- Continued adding features on `master` during the rework period (Emacs overhaul, printer support, hardware tools) without AI assistance

**What the AI did:**
- Implemented the architectural decisions I made — writing the Nix module code for `mkHosts`, `mkHomes`, dual-export modules, schema definitions, and system backends
- Helped debug evaluation errors during the rework (unfree package resolution, NixOS vs HM option conflicts, module detection logic, infinite recursion in role-based defaults)
- Helped me understand Nix patterns I wasn't familiar with (like `attrsOf submodule`, `lib.mkMerge`, `lib.mkDefault`, and the mechanics of standalone Home Manager)
- Assisted with the merge back into `master` (conflict resolution, preserving master-only features)

**Why I used AI for this:**
I'm learning NixOS with the goal of working with it professionally. The rework involved restructuring dozens of interdependent files simultaneously — the kind of change where a single syntax error in one file breaks evaluation of everything, and where the feedback loop of "change, rebuild, debug, repeat" across that many files would have taken at least several months of working in the evenings. (That may sound like an exaggeration, but even with AI assistance this rework took close to a month and a half to complete.) I used AI to accelerate the implementation so I could focus on understanding the design patterns and architectural tradeoffs rather than fighting Nix syntax for every line. Now that the structure is in place, future development will be manual — the whole point of this rework was to make the codebase easier to understand and extend, and I intend to do that myself.

The foundational work — the hardware configurations, desktop environments, editor setups, display server configs, and everything else that makes this a functional daily-driver system — was built by hand over four years of learning NixOS.
