# Overview

Orientation for Claude Code when working in this repository. Loaded as project memory
from `.claude/rules/`; see the sibling files there for conventions and wiring detail.

## What this is

A personal NixOS flake managing two live hosts (`hephaestus` desktop, `artemis`
laptop) and two users (`hunter`, `ash`). `README.md` carries the long-form narrative,
the per-host bring-up procedure (sops/age bootstrap), and the roadmap — read it for
anything this file only summarizes.

There is a `nixos` skill that covers orientation and change placement; prefer invoking
it over re-deriving the wiring.

## Commands

```bash
# Full system + every user's Home Manager (needs root)
sudo nixos-rebuild switch --flake /etc/nixos#hephaestus
sudo nixos-rebuild dry-build --flake /etc/nixos#hephaestus     # cheap eval+build check

# One user's Home Manager only — no root, much faster iteration
home-manager switch --flake /etc/nixos#hunter@hephaestus

# Inspect a resolved option (the real "test" in this repo)
nix eval /etc/nixos#nixosConfigurations.hephaestus.config.<option.path>

# Deployed HM state goes through the host, NOT homeConfigurations
nix eval /etc/nixos#nixosConfigurations.hephaestus.config.home-manager.users.hunter.<...>

# Syntax-check a single file (works even with comment blocks after the final brace)
nix-instantiate --parse <file>.nix

# A `git+file:` input (medialib) only updates after an explicit lock bump;
# committing in the source repo alone changes nothing here
nix flake update medialib
```

There is no test suite, linter, or formatter configured. Verification is
`nix eval` / `dry-build`, not reasoning about what the code should produce.

`scripts/newfile-nix` scaffolds a new `.nix` file with the house banner header.
(Note: `README.md` also references `scripts/bootstrap-access-token`, which does not
currently exist in the tree.)

## Architecture

### Hub and spoke — there is no central imports list

`flake.nix` holds **pure data only**: `inputs`, `userDefs`, and `hostDefs`. It hands
those to two builders from `lib/`:

- `lib/mkHosts.nix` → `nixosConfigurations.<host>`: system config + Home Manager for
  every user on that host.
- `lib/mkHomes.nix` → `homeConfigurations."<user>@<host>"`: standalone HM only.

Both consume the same `userDefs`/`hostDefs` and the same module pool, so the two
rebuild paths are meant to produce identical HM output. They are not automatically
identical: HM under `nixos-rebuild` evaluates with `nixosConfig != null` and standalone
with `nixosConfig = null`, so anything gated on that diverges (`mkHomes.nix:81` opts
`fonts.fontconfig.enable` back on for exactly this reason). Treat a divergence as a
probably-unintended gotcha, not a design choice.

`nixosConfigurations.installer` is the one escape hatch — a hand-rolled
`nixpkgs.lib.nixosSystem` for the live ISO, bypassing `mkHosts` entirely.

**Consequence: a new file does nothing until it is registered in its directory's
`default.nix`.** Nothing is auto-discovered.

### The dual-export pattern

Every entry in `environment/default.nix` and `modules/userSettings/roles/default.nix`
resolves to either:

- a **function** → treated as a plain Home Manager module, injected into HM only; or
- an **attrset** `{ nixos = <module>; home = <module>; }` → the `nixos` half becomes a
  NixOS module, the `home` half an HM module.

The builders sniff this with `builtins.isAttrs mod && mod ? nixos` / `? home`
(`mkHosts.nix:48-59`). Either half may be omitted. Keeping the attrset shape with only
`home` populated is an accepted idiom — see `environment/services/claude-code.nix`,
which documents why its `nixos` half is deliberately absent.

**Never split one program across `system/` and `environment/`.** Use a single
dual-export file.

Two shapes of directory appear in these lists, and the difference matters:
- a directory whose `default.nix` **returns a list of paths** is spliced in with
  `(import ./dir)` — e.g. `environment/services`, `environment/themes`;
- a directory whose `default.nix` **is itself the module** is listed as a bare path —
  e.g. `./editor`, `./shell`, `./games`.

### Layering: does the user perceive it?

| Directory | Holds | Rule |
|---|---|---|
| `modules/hostSettings/`, `modules/userSettings/` | option **schemas** | declares what can be set; must not configure anything |
| `system/<area>/` | invisible plumbing | boot, kernel, GPU, accounts, networking, secrets |
| `environment/<area>/` | anything the user sees or feels | theme, keybinds, editor, shell, terminal, apps |
| `users/<name>/` | applies to one user only | HM modules, imported after the shared pool |
| `hosts/<name>/` | applies to one machine only | `configuration.nix` overrides + generated `hardware.nix` |

The documented exception to "schemas only": `modules/hostSettings/types/{desktop,laptop,server}.nix`
*do* set config — they are the type-keyed default bundles, each wrapped in
`lib.mkIf (config.hostSettings.type == "...")`. Real option definitions live in
`modules/userSettings/options.nix` and are wrapped twice: as `attrsOf submodule` for
NixOS (`schema.nix`) and as a single `submodule` for standalone HM (`hm-schema.nix`).
Add a user option in `options.nix` and both paths get it.

Shared defaults use `lib.mkDefault` so host/user settings win without needing `mkForce`.

### Reading settings in a backend module

- NixOS module: `config.hostSettings.…`; all users are
  `lib.attrValues config.userSettings` (an attrset keyed by username), so host-wide
  decisions are usually `lib.any (u: …) users` — see `environment/editor/default.nix`.
- HM module: `config.userSettings.…` is that single user's data.
- Roles gate features: `builtins.elem "developer" config.userSettings.role`.

### `inputs` is already in scope

Do not re-plumb flake inputs, add overlays, or thread `_module.args`. Just name
`inputs` in a module's argument set.

- NixOS modules get `specialArgs = { inherit inputs lib flakeRoot; }` (`mkHosts.nix:70`).
- HM modules get `extraSpecialArgs = { inherit inputs flakeRoot vpnAutostartUsers; hostName = …; }`
  (`mkHosts.nix:99`, `mkHomes.nix:64`).
- `lib` is in `specialArgs` but **not** `extraSpecialArgs` — HM modules receive `lib`
  from Home Manager itself.

### Desktop sessions

`lib/sessions.nix` is the single authority: `all` lists canonical session names, and
`forHost` enables the union of the host's `availableSessions` and every session any of
its users requested in `desktop.environments`. A user's per-session HM config follows
only their own list.

### Secrets

sops-nix with age. Recipients and per-file rules live in `.sops.yaml`; encrypted
payloads in `system/security/secrets/`; option wiring in `system/security/sops.nix`.
Shared secrets go in `secrets.yaml`, host-scoped ones in `<host>.yaml`. User password
secrets must be named `<username>-hashed-password` — `system/users.nix` looks them up
by that exact pattern. After adding a key or a file, re-run
`sops updatekeys <file>`.

`claude-config` is a **private** `github:` input authenticated by the
`nix-access-tokens` secret, which only exists at `/run/secrets/...` after a successful
activation — hence the bootstrap ordering documented in `README.md`.

## Conventions

- **Never `git commit` or `git push`.** Staging is fine; Hunter reviews diffs himself.
  Hunter frequently has uncommitted WIP — check `git status` and report it before
  editing.
- Every `.nix` file opens with a `# path/to/file.nix` comment, then a tight banner box
  (`#---#` / `#  Title  #` / `#---#`), then prose explaining the module's job.
- Inline comments say **what**, briefly. Deep **why** goes in a numbered footnote block
  at the bottom of the file, after the final closing brace, referenced inline as `[1]`.
  Footnotes are complete and neutral — framed as consequences, not imperatives — and
  earn their place only if they inform a *future* decision. One-time historical trivia
  belongs in the commit message. `environment/themes/stylix.nix` and
  `environment/services/claude-code.nix` are the models.
- Trailing comments align to the file's established comment column; where a file has
  none, column 81. Never mix columns among nearby comments.
- Match neighbors: if sibling entries in a list carry no trailing comment, don't add one.
- The `fix-comments` skill applies all of this mechanically.
- Mirror the closest existing feature's skeleton before writing a new module.

## Gotchas

- `hosts/hestia/` is an unfinished stub: its `default.nix` imports `configuration.nix`
  and `hardware.nix`, neither of which exists. It is not in `hostDefs`, so eval is
  unaffected — but don't add it to `flake.nix` until those files exist.
- All Claude Code configuration for this repo lives under `.claude/` — `settings.json`,
  `rules/` (project memory), and `skills/`. There is deliberately no root-level
  `CLAUDE.md`.
- `conventions.md` is the authority on comment and formatting style; the `fix-comments`
  skill applies it mechanically but is a condensed restatement, so the file wins on any
  disagreement. Same relationship holds for `architecture.md` and the `nixos` skill.
- Changes to structure or behavior should be reflected back into `README.md` so it stays
  in step with the code.
