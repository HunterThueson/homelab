# users/ash/firefox.nix
#
# Ash's per-user Firefox: bookmarks, search engines, and userChrome CSS.
# Shared setup lives in environment/browser/firefox.nix.
#
# Fill each block in as you rebuild the profile, then rebuild to capture it.
# `force = true` hands the underlying file to HM — once set, changes made in the
# running browser are overwritten on the next switch. Leave a block commented
# until you're ready to hand it over, so in-browser setup isn't wiped mid-rebuild.
#
# NOTE: dormant while Ash's userDef sets `browser.declarative = false` — nothing
# here applies (and HM leaves her profile untouched) until that flag is true.

{ config, lib, ... }:

let
  browser = config.userSettings.browser;
in {
  config = lib.mkIf (browser.name == "firefox" && browser.declarative) {
    programs.firefox.profiles.default = {

      # -- Search engines (uncomment when ready) ---------------------------
      # `definedAliases` are the `@keyword`s typed in the URL bar.
      # search = {
      #   force   = true;                    # hand search.json.mozlz4 to HM
      #   default = "google";
      #   engines = { };
      # };

      # -- Bookmarks (uncomment when ready) --------------------------------
      # Folders nest via `bookmarks = [ ... ]`; `keyword` = URL-bar shortcut.
      # bookmarks = {
      #   force    = true;                    # hand places.sqlite to HM
      #   settings = [ ];
      # };

      # -- Chrome CSS (uncomment when ready) -------------------------------
      # userChrome = '''';

    };
  };
}
