---
name: project-icon-font-drop
description: Pending, his call, not now (2026-09-29) — install current Symbols Nerd Font on Windows so the full codicon set works; built-in font stops at U+EBEB
metadata:
  type: project
---

**Pending: he'll install a current Symbols Nerd Font "eventually, not now"
(ruled 2026-09-29).** It's his hand. Don't push it. When he says it's done, the
goal is that every name on the codicon page
(microsoft.github.io/vscode-codicons) works as written in AGENT_LOOKS.

**Why:** WezTerm 20240203 draws icons from its own built-in Symbols Nerd Font
Mono (early 2024). That copy has codicons U+EA60..U+EBEB only, 388 of the
~540 on today's page. Newer names have no glyph. He picks icons from that
page and asked why some didn't work. Today the gap is patched with EXTRA_ICONS
substitutes: snake → md U+F150E, strikethrough → oct U+F521, map → fa U+F279,
target → crosshairs, vr → cube, and hammer/zap/sun from fa.

**How to apply, once the font is installed:**
1. First prove which font WezTerm actually uses. The docs don't say whether an
   installed font beats the built-in one of the same family name (checked
   fonts.html and font_locator.html, 2026-09-29). Use `ls-fonts --text <glyph>`:
   the path column shows `<built-in>` or the installed .ttf. A glyph past EBEB
   (e.g. U+EC16 snake) is the test.
2. If the built-in copy wins, try the non-Mono family "Symbols Nerd Font" (a
   different name) in font_with_fallback. That also needs window_frame's font,
   because the tab bar draws the icons.
3. Regenerate CODICONS over the full range. Take names from Nerd Fonts
   glyphnames.json (`cod-*`) and prove each one with ls-fonts. ls-fonts output
   cuts off around 350 glyphs per call, so batch it.
4. Offer to swap the substitutes back to the real codicons (sofer's pencil is
   `edit` either way).

Related: [[project-conpty-flicker]] (another bundled-component limit of this build).
