# TODO

## `README.md` Accuracy Pass

The README has drifted; it hasn't been walked through end-to-end in a while and the
scope of the project has moved on since it was last updated. Go through it section by
section and reconcile it against the actual tree.

The north star to write it around: **switching between machines ought to be as seamless
as possible, and tools of creation should feel like magic.** The current "What's Next"
list still frames the project as "daily-driver Hyprland desktop," which is a means now,
not the end.

Known-stale items found so far:

* `scripts/bootstrap-access-token` is referenced in the directory tree (line ~132) and
  in the whole of "First deployment" (lines ~211-220), but `scripts/` contains only
  `newfile-nix`. Either the script needs writing or those steps need rewriting.
* The "Design Principles & Core Values" list predates the cross-machine goal — nothing
  in it mentions portability or multi-host consistency.
* `hosts/` in the directory tree lists only `hephaestus` and `artemis`; `hestia` exists
  as a stub.

## Host: `hestia`

A Raspberry Pi to run as a personal NAS / backup + web server. Hardware is on hand;
`hosts/hestia/` currently holds only a `default.nix` that imports a `configuration.nix`
and `hardware.nix` which don't exist yet, so it's deliberately absent from `hostDefs`
in `flake.nix` — don't add it there until those files are real.

Blocked on storage, not on config: it needs a drive pilfered from `hephaestus`, which
first needs enough space cleared to free an entire drive. Not difficult, just not yet
a priority.

## Miscellaneous Fixes & Adjustments

### `nvim`

* Color highlighting (i.e. if I type "grey" it highlights the word with the given color) should only ever be active if ALL the following conditions are met:

    a) the current buffer is NOT a Markdown or `org` or `.toml`/`.yaml` file -- those filetypes are the only time color highlighting should ever be active, since the only reason I want color
    highlighting is for reference in READMEs or for easy viewing of changes in config files (which are usually `.toml` or `.yaml` files).

    b) the word is by itself, i.e. if the text is `grey` then enable color highlighting; if it's `"grey"` enable color highlighting; if it's `greyhound` disable color
    highlighting; etc.

    c) (if possible to implement): the word is not currently in the process of being written. For instance, right now, when I write the word `greyhound`, color highlighting is disabled while I begin the
    word, then activates for a split second when I've typed `grey` and am reaching for the `h` key, then is disabled again once I've typed `greyh` -- this is very annoying
    while editing files. I'd much rather have no color highlighting whatsoever until I've written `grey ` (i.e. I've written "grey" with a trailing `SPACE`, signifying that I meant
    to type the word `grey` only and have moved on to the next word). In short: color highlighting should only ever be applied to FINISHED words, not words I'm actively
    typing.

  If I'm not able to meet ALL of those conditions, let's just disable color highlighting entirely outside of configuration files (`*.toml`, `*.yaml`, `*.cfg`, etc.)

* Let's set `textwidth=171` by default for all whitespace-insensitive files (like `*.nix` or `*.md` or `*.org` files). Whitespace-sensitive files should not wrap at all, but I
  DO want to `set linebreak` by default so that if I decide I need to wrap text temporarily, I can just `:set wrap` and get the behavior I want (which is `:set wrap
  linebreak`) without having to type out `:set wrap linebreak` every time. `:set wrap` is much faster and easier.

### SDDM Configuration & Theme

* Clock should be shown in `2:34 PM` format instead of `14:34` format

* Colors should follow the `electro-swing` color palette -- specifically, let's use the dark grey background color defined in the `electro-swing` instead of the current light
  grey

* The username box still auto-fills the last user to log in -- I would prefer that both boxes start empty on every new instance of the greeter. Blank username, blank password
  box, every time (no matter whether cold boot or reboot or logout/switch-user).

* The current configuration has the M28U monitor on the right of the "virtual layout" (or whatever the proper term is), while the Dell S2417DG is on the left -- that's the
  opposite of what I want. I want the monitor layout to always match what I've defined for `hephaestus`. Additionally, the "focus" always starts on the Dell right now (meaning that
  if I start typing my username/password without touching anything, the boxes displayed on the S2417DG are the ones that receive input by default, like it's the "primary"
  monitor or something) -- I'd prefer the focus to start on the M28U (my actual day-to-day "primary" (most-used) monitor) instead.

### Firefox & OSRS Interactions

* The `Lookup Wiki` button in Runelite (under the minimap -- click the button and then an item to look it up on the wiki in a new Firefox window) currently creates its own Firefox profile
  instead of using the user's default Firefox profile. This creates unnecessary bloat with a new window on the screen every time I want to look something up. If there's a way to force
  Runelite/OSRS/Bolt Launcher to use a Firefox profile of my choice instead (I'm not sure which one of the three is the culprit), that'd be a very big annoyance off my shoulders.

### Wallpaper Management

[ ] Switch wallpaper manager to:
    - Frontend: `waypaper`
    - Backend: ??

`wpaperd` looks promising as an intermediate prior to Hyprland switch for Ash

