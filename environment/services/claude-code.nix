# environment/services/claude-code.nix

#---------------#
#  Claude Code  #
#---------------#

# Anthropic's official CLI, installed for anyone with the developer role.
#
# The home half installs the CLI and seeds per-user memory; the nixos half writes
# one host-wide policy file. Both carry the same guard text: no Claude session
# should edit /etc/nixos without the repo's rules loaded first. [1]
#
# This module writes nothing else under ~/.claude. Per-user declarative config
# layers on top from users/<name>/ (e.g. users/hunter/claude-code.nix). [4]

let

  # Loaded in every directory, so it stays a short trigger — the rules
  # themselves live in /etc/nixos/.claude/rules/ and are read on demand.
  nixosGuard = ''
    Any work that adds to, modifies, or wires anything into /etc/nixos — including
    work begun from another project's directory — must load the `nixos` skill before
    editing. /etc/nixos is a hub-and-spoke flake whose wiring is not inferable from
    the file tree: there is no central imports list, and a new file does nothing
    until it is registered in its directory's default.nix.

    Placement rules, comment conventions and known gotchas live in
    /etc/nixos/.claude/rules/. Sessions rooted in /etc/nixos load those
    automatically as project memory; sessions rooted anywhere else must read them
    before proposing a location.
  '';

in
{
  nixos = { pkgs, ... }: {

    # Managed-tier memory — every user on the host, developer role or not. [2]
    environment.etc."claude-code/managed-settings.json".source =
      (pkgs.formats.json { }).generate "claude-code-managed-settings.json" {
        claudeMd = nixosGuard;
      };
  };

  home = { config, lib, ... }:
  let
    isDeveloper = builtins.elem "developer" config.userSettings.role;
  in {
    config = lib.mkIf isDeveloper {
      programs.claude-code.enable = true;

      # User-level memory via rules/, deliberately not CLAUDE.md. [3]
      programs.claude-code.rules."nixos-config" = nixosGuard;
    };
  };
}

#-------------#
#  Footnotes  #
#-------------#

# 1: The guard is stated once and consumed by both halves because the two tiers
#    cover different gaps, and neither covers all of them:
#      - Project memory (/etc/nixos/.claude/rules/) covers sessions whose working
#        directory is /etc/nixos. Nothing needs to be declared for it; the files
#        are committed and Claude Code discovers them.
#      - The per-user rules/ entry covers a developer-role user working from
#        anywhere, including a sibling project that wires itself into the system.
#      - The managed file covers users this module never touches — anyone who
#        installed the CLI outside Home Manager, or a non-developer account.
#    If one tier is ever considered redundant, the managed file is the one that
#    subsumes the other two; the per-user entry is kept because it survives a host
#    whose /etc is not managed by this flake.

# 2: Managed settings are Claude Code's policy tier, read on Linux from
#    /etc/claude-code/managed-settings.json (plus a managed-settings.d/ fragment
#    directory). `claudeMd` is honored *only* from this tier — setting it in user
#    or project settings does nothing — which is what makes it reach accounts this
#    module has no other hook into.
#
#    Deliberately not gated on any user having the developer role: the point is to
#    cover accounts this flake doesn't configure, so gating it on configured users
#    would defeat it. The cost is a small JSON file on hosts where nobody runs
#    Claude Code at all.
#
#    Only `claudeMd` is set. The tier can also restrict permissions, pin a minimum
#    version and force login behavior; those are left alone so the file stays a
#    memory injection rather than a policy lever.
#
#    This is guidance, not a technical gate — it loads instructions, it does not
#    block edits. A genuine block would be a PreToolUse hook in this same file
#    denying Edit/Write under /etc/nixos until the skill has run, at the cost of
#    maintaining matcher logic and an escape hatch for when the guard is wrong.
#
#    Not yet verified end to end: the key and the path were read out of the CLI
#    binary, not confirmed against a running session. Check with /memory from a
#    directory outside /etc/nixos after the first switch.

# 3: `programs.claude-code.context` would write ~/.claude/CLAUDE.md, which is the
#    file the save-to-user-memory flow writes to. Home Manager's output is a
#    read-only /nix/store symlink, so declaring `context` costs that flow the same
#    way declaring `settings` costs `/effort` (see [4]) — the breakage comes from
#    the file being HM-owned, not from its contents.
#
#    `rules` has neither problem: it writes ~/.claude/rules/<name>.md, the same
#    loader picks those up as memory alongside CLAUDE.md, and the writable
#    CLAUDE.md is left for the CLI to own. It also keeps the per-user config inside
#    a directory rather than as a bare file in $HOME.
#
#    `rules` and `rulesDir` are mutually exclusive — the module asserts on both
#    being set — so a future per-user rules *directory* means moving this entry,
#    not adding beside it.

# 4: `programs.claude-code.settings` is left undeclared so that Claude Code can
#    write ~/.claude/settings.json itself. HM's only output is a read-only
#    /nix/store symlink, and Claude Code persists runtime state into that exact
#    path: `/effort <level>` and the `/model` picker's save both write
#    `effortLevel` / `modelSettings` / `model` there. Against a store symlink the
#    write fails with EACCES and the command aborts without applying, so declaring
#    *any* key here costs `/effort` entirely.
#
#    Note that `marketplaces` writes settings.json too — the module emits the file
#    when either option is non-empty — so declaring a marketplace would cost
#    `/effort` by a side door.
#
#    Consequences of the split, if it's ever revisited:
#      - skills/ and keybindings.json are never mutated at runtime, so store
#        symlinks suit them and they stay declarative.
#      - Static, shareable settings (permissions, hooks) can be version controlled
#        per-project instead: .claude/settings.json in a repo is an ordinary
#        committed file, one precedence level above user settings.
#      - MCP and LSP servers do *not* go through settings.json — the module
#        compiles them into a generated plugin directory passed via --plugin-dir —
#        so those can be declared without making settings.json read-only.
#      - A declared default is still reachable without a writable file via the
#        `--model` / `--effort` launch flags.
#      - CLAUDE_CODE_EFFORT_LEVEL looks like a declarative substitute but takes
#        precedence over `/effort` itself, so exporting it pins effort for the
#        session rather than seeding it.

# EOF
