---
name: project-icon-font-drop
description: No font install needed on the nightly — its built-in Symbols Nerd Font draws codicons past U+EBEB (proven 2026-10-09); the CODICONS table in wezterm.lua is the stale part, regen is his call
metadata:
  type: project
---

**The font drop he was going to do "eventually" (ruled 2026-09-29) is no longer
needed.** The nightly he runs (`20260929-043349-cab25161`) bundles a newer
Symbols Nerd Font Mono than the 20240203 build did. Proven 2026-10-09 with
`ls-fonts --text`: U+EBF8 `cod-target`, U+EC05 `cod-map`, U+EC16 `cod-snake`
all come from `<built-in>`. The changelog's nightly section says "Bundled Nerd
Font Symbols font to v3.3.0".

**Why it matters:** He picks icons by name from
microsoft.github.io/vscode-codicons and asked why some didn't work. The cause
was the old build's font, which stopped at U+EBEB (388 of ~540 codicons). The
`CODICONS` table in wezterm.lua still stops there, and its comment still says
newer names "would draw as an empty box" — true of the rollback build, false of
the nightly. So today the gap is in the table, not the font. EXTRA_ICONS still
carries the substitutes: snake → md, strikethrough → oct, map → fa,
target → crosshairs, vr → cube, hammer → gavel, zap → bolt.

**How to apply:** Told him 2026-10-09; no ruling yet. Don't regenerate unasked.
If he says go:
1. Regenerate CODICONS over the full range. Names from Nerd Fonts
   glyphnames.json (`cod-*`), each proven with `ls-fonts --text`. Output cuts
   off around 350 glyphs per call, so batch it.
2. Offer to swap the substitutes back to the real codicons (sofer's pencil is
   `edit` either way).
3. Say plainly that the rollback build in `C:\Program Files\WezTerm` would draw
   the newer names as empty boxes.

Adding one icon needs none of this: prove the glyph with `ls-fonts --text`,
add a line to EXTRA_ICONS (as with `flask`, fa U+F0C3, 2026-10-09).

Related: [[project-conpty-flicker]] (another bundled-component limit of the old build), [[windows-wsl-boundary]].
