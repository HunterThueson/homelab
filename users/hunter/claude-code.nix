# users/hunter/claude-code.nix
#
# Hunter's per-user Claude Code config: keybindings and skills.
# Shared install (developer-gated `enable`) lives in
# environment/services/claude-code.nix.
#
# The actual content is sourced from the private `claude-config` flake input,
# so personal settings/prompts stay out of this public repo. This file is only
# wiring — it reads from the input and hands the pieces to Home Manager. [1]

{ config, lib, inputs, ... }:

let
  isDeveloper = builtins.elem "developer" config.userSettings.role;
  src = inputs.claude-config;
in {
  config = lib.mkIf isDeveloper {

    # Runtime-immutable content only; settings.json is deliberately absent. [2]
    programs.claude-code.skills = "${src}/skills";

    # keybindings.json has no HM option, so place it directly.
    home.file.".claude/keybindings.json".source = "${src}/keybindings.json";
  };
}

#-------------#
#  Footnotes  #
#-------------#

# 1: `claude-config` is a `git+file` input (/home/wizard/claude-config), so it
#    locks to a commit — an edit there isn't picked up until it's committed and
#    the input is re-locked:
#      cd /home/wizard/claude-config && git commit -am "…"
#      nix flake update claude-config    # in /etc/nixos
#      sudo nixos-rebuild switch --flake .#<host>
#    The tradeoff bought by the input is privacy (content off the public repo);
#    switching the URL to a private `github:HunterThueson/claude-config` would
#    add portability across hosts but needs a GitHub token in Nix's
#    access-tokens (sops-managed) because `nixos-rebuild` fetches as root.
#
#    On a host's first switch, HM replaces any pre-existing ~/.claude files it
#    owns with store symlinks. Under nixos-rebuild the originals are saved as
#    *.bak (mkHosts' backupFileExtension); a standalone `home-manager switch`
#    (mkHomes sets no backup extension) aborts on the collision instead, so
#    move the originals aside first.

# 2: `programs.claude-code.settings` is left undeclared so that Claude Code can
#    write ~/.claude/settings.json itself. HM's only output is a read-only
#    /nix/store symlink, and Claude Code persists runtime state into that exact
#    path: `/effort <level>` and the `/model` picker's save both write
#    `effortLevel` / `modelSettings` / `model` there. Against a store symlink
#    the write fails with EACCES and the command aborts without applying, so
#    declaring *any* key here costs `/effort` entirely — the breakage is caused
#    by the file being HM-owned, not by which keys it contains.
#
#    Consequences of the split, if it's ever revisited:
#      - skills/ and keybindings.json are never mutated at runtime, so store
#        symlinks suit them and they stay declarative above.
#      - Static, shareable settings (permissions, hooks) can be version
#        controlled per-project instead: .claude/settings.json in a repo is an
#        ordinary committed file, one precedence level above user settings.
#      - A declared default is still reachable without a writable file via the
#        `--model` / `--effort` launch flags.
#      - CLAUDE_CODE_EFFORT_LEVEL looks like a declarative substitute but takes
#        precedence over `/effort` itself, so exporting it pins effort for the
#        session rather than seeding it.
#      - Making the file writable would need an activation-script copy instead
#        of home.file; each switch would then revert whatever was tuned at
#        runtime.

# EOF
