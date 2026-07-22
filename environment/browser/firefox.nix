# environment/browser/firefox.nix

#-------------------------#
#  Firefox Configuration  #
#-------------------------#

# Shared, cross-user Firefox config. Pure HM module — works in both the
# NixOS-managed and standalone HM build paths. Active when browser.name is
# "firefox"; profile management additionally requires browser.declarative. [2]
#
# Responsibility split:
#   - Shared (here):   enable, profile, toolbar/UI layout, common about:config.
#                      (Extensions will also live here once NUR is wired.)
#   - Per-user (users/<name>/firefox.nix): bookmarks, search engines, userChrome.

{ config, lib, ... }:

let
  browser = config.userSettings.browser;

  # about:config prefs every Firefox user gets; per-user browser.settings win.
  sharedSettings = {
    # Toolbar / widget layout — one opaque JSON blob, captured not hand-written. [1]
    # "browser.uiCustomization.state" = ''PASTE_SNAPSHOT_HERE'';

    # Auto-enable declaratively-installed extensions (no manual prompt).
    "extensions.autoDisableScopes" = 0;

    # Profile-groups service off — it rewrites profiles.ini behind HM's back. [3]
    "browser.profiles.enabled" = false;
  };
in {
  config = lib.mkIf (browser.name == "firefox") (lib.mkMerge [

    # Always install Firefox. The profile stays imperative unless the user
    # opts into declarative management below. [2]
    {
      programs.firefox = {
        enable = true;
        configPath = "${config.xdg.configHome}/mozilla/firefox";              # only honored while ~/.mozilla/firefox is absent [3]
      };

      # Drop the stub ~/.mozilla/native-messaging-hosts link HM creates. [4]
      home.file.".mozilla/native-messaging-hosts".enable = false;
    }

    # Declarative profile — HM owns the `default` profile: UI/toolbar layout,
    # shared about:config, theming. Skipped for deferred users. [2]
    (lib.mkIf browser.declarative {
      programs.firefox = {
        # Default profile — managed by Home Manager
        profiles.default = {
          isDefault = true;
          settings = sharedSettings // browser.settings;
        };
      } // browser.extraConfig;

      # Tell Stylix which Firefox profiles to theme
      stylix.targets.firefox.profileNames = [ "default" ];

      # Warn at activation if the legacy root is back and shadowing XDG. [3]
      home.activation.warnFirefoxLegacyRoot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ -e "$HOME/.mozilla/firefox" ]; then
          warnEcho "~/.mozilla/firefox exists; Firefox will use it and ignore the managed XDG profile root"
        fi
      '';
    })
  ]);
}


#-------------#
#  Footnotes  #
#-------------#

# 1: Firefox stores toolbar/widget placement as one opaque JSON blob in the
#    `browser.uiCustomization.state` pref — there is no per-widget HM option.
#    To capture a layout: arrange the toolbars in a running profile, open
#    about:config, copy the `browser.uiCustomization.state` value, and paste it
#    as the string above. Hand-editing the blob isn't practical, so re-snapshot
#    whenever the layout changes.

# 2: `enable` is split from profile management on purpose. A user whose userDef
#    sets `browser.declarative = false` gets Firefox installed but no declared
#    profile, so Home Manager writes nothing to their profile directory — it
#    stays whatever they arranged by hand. Ash uses this to keep an existing,
#    hand-configured profile intact. Folding `enable` into the `declarative`
#    branch would stop installing Firefox for such a user; moving the *profile*
#    into the always-on branch would make HM take the profile over (and, once
#    uiCustomization.state / force are set, overwrite it). `configPath` is
#    different: with no declared profiles HM writes nothing under it, so it
#    lives in the always-on branch (July 2026) — that silences HM's
#    stateVersion<26.05 default-migration warning for non-declarative users and
#    already points at the XDG root their live profile sits in should they ever
#    flip `declarative` on.

# 3: Firefox ≥147 picks its profile root by checking for ~/.mozilla/firefox:
#    if that directory exists it wins; only when it's absent does Firefox use
#    $XDG_CONFIG_HOME/mozilla/firefox. The XDG configPath above therefore only
#    takes effect while the legacy dir stays gone — anything that recreates it
#    silently flips Firefox back to the legacy root, which presents as "my
#    whole profile reset" (July 2026: bit both users). Known recreator: booting
#    an old NixOS generation, whose home-manager boot service re-runs that
#    generation's activation and rewrites whatever *it* managed there. The
#    activation warning exists to surface that state on the next switch. The
#    browser.profiles.enabled=false pref is defense for the same incident:
#    Firefox's profile-groups service mints salted profiles and rewrites
#    profiles.ini when the roots get confused (HM's copy is a read-only store
#    symlink, so Firefox writes its own elsewhere). Native-messaging-hosts stay
#    at ~/.mozilla regardless (HM hardcodes the vendor path), so ~/.mozilla
#    itself never fully disappears — only ~/.mozilla/firefox must stay absent.
#    (Superseded by footnote 4, which removes even that remnant.)

# 4: HM's mozilla-messaging-hosts module links ~/.mozilla/native-messaging-hosts
#    even when no messaging hosts are configured — the link holds only a .keep
#    stub, and it's the last thing keeping ~/.mozilla around now that profiles
#    live under XDG (footnote 3). Disabling the entry costs nothing while the
#    host list is empty. If a native-messaging host is ever added
#    (programs.firefox.nativeMessagingHosts or a package override), this line
#    will suppress its user-level delivery — remove it then, and check whether
#    XDG-mode Firefox reads this legacy path or an XDG one before relying on it.
