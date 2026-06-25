# Electro-Swing Color Scheme

A glanceable reference for the `electro-swing` palette.

Use this when picking colors for things that don't auto-consume the base16
palette (Firefox Color, Stylus, userChrome.css, GTK overrides, etc.).

## Backgrounds & surfaces

| Slot   | Name       | Hex       | RGB                  | HSL                 | Purpose                                        |
|--------|------------|-----------|----------------------|---------------------|------------------------------------------------|
| base00 | deep-black | `#131313` | `rgb(19, 19, 19)`    | `hsl(0, 0%, 7%)`    | Default background                             |
| base01 | soft-black | `#1c1c1c` | `rgb(28, 28, 28)`    | `hsl(0, 0%, 11%)`   | Lighter background (status bars, line numbers) |
| base02 | slate      | `#5e676a` | `rgb(94, 103, 106)`  | `hsl(196, 6%, 39%)` | Selection background                           |
| base03 | dim-slate  | `#656763` | `rgb(101, 103, 99)`  | `hsl(90, 2%, 40%)`  | Comments, invisibles, line highlight           |

## Foregrounds

| Slot   | Name   | Hex       | RGB                   | HSL                 | Purpose                               |
|--------|--------|-----------|-----------------------|---------------------|---------------------------------------|
| base04 | linen  | `#d3d7cf` | `rgb(211, 215, 207)`  | `hsl(91, 9%, 83%)`  | Dark foreground (status bars)         |
| base05 | bone   | `#cbcec6` | `rgb(203, 206, 198)`  | `hsl(83, 8%, 79%)`  | Default foreground, carets, operators |
| base06 | ivory  | `#eeeeec` | `rgb(238, 238, 236)`  | `hsl(60, 6%, 93%)`  | Light foreground                      |
| base07 | white  | `#ffffff` | `rgb(255, 255, 255)`  | `hsl(0, 0%, 100%)`  | Light background                      |

## Accents

| Slot   | Name            | Hex       | RGB                   | HSL                  | Purpose                                         |
|--------|-----------------|-----------|-----------------------|----------------------|-------------------------------------------------|
| base08 | crimson         | `#c14646` | `rgb(193, 70, 70)`    | `hsl(0, 50%, 52%)`   | Red — variables, errors, diff removed           |
| base09 | amber           | `#be8a00` | `rgb(190, 138, 0)`    | `hsl(44, 100%, 37%)` | Orange — constants, integers, booleans          |
| base0A | electric-yellow | `#fce847` | `rgb(252, 232, 71)`   | `hsl(53, 97%, 63%)`  | Yellow — classes, search highlight              |
| base0B | neon-lime       | `#7cf10a` | `rgb(124, 241, 10)`   | `hsl(90, 92%, 49%)`  | Green — strings, diff added                     |
| base0C | electric-teal   | `#52e9e9` | `rgb(82, 233, 233)`   | `hsl(180, 78%, 62%)` | Cyan — regex, escape chars, support             |
| base0D | sapphire        | `#4c8cde` | `rgb(76, 140, 222)`   | `hsl(214, 69%, 58%)` | Blue — functions, methods, headings             |
| base0E | candy-pink      | `#ed83e2` | `rgb(237, 131, 226)`  | `hsl(306, 75%, 72%)` | Magenta — keywords, storage                     |
| base0F | deep-violet     | `#7e4387` | `rgb(126, 67, 135)`   | `hsl(292, 34%, 40%)` | Brown/dark — deprecated, embedded language tags |

## Terminal extras (Alacritty only)

These fill out the 8-color ANSI table in `electro-swing.toml` and aren't part
of the base16 palette. They're dimmer/brighter siblings of the accents above.

| Source       | Name        | Hex       | RGB                  | HSL                  | Notes                    |
|--------------|-------------|-----------|----------------------|----------------------|--------------------------|
| normal.green | forest-lime | `#4e9a06` | `rgb(78, 154, 6)`    | `hsl(91, 92%, 31%)`  | Dim sibling of base0B    |
| normal.cyan  | deep-teal   | `#1f9294` | `rgb(31, 146, 148)`  | `hsl(181, 65%, 35%)` | Dim sibling of base0C    |
| bright.red   | coral       | `#f56868` | `rgb(245, 104, 104)` | `hsl(0, 88%, 68%)`   | Bright sibling of base08 |
| bright.blue  | sky         | `#729fcf` | `rgb(114, 159, 207)` | `hsl(211, 49%, 63%)` | Bright sibling of base0D |

## Notes

- base04 is intentionally *lighter* than base05 here; the base16 spec
  usually has it darker. If something downstream looks wrong (a status
  bar that's brighter than the surrounding text), that's the likely cause.
- Names above are descriptive aliases for ricing. The canonical identifiers
  remain the base16 slots (`base08`, etc.) and Alacritty keys (`normal.red`).
