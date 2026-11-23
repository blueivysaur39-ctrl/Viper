---
name: reference-looks-method
description: "How to pick a new seat's tab icon (glyph by name from the font) and color (CIELAB gap + contrast) so the numbers match the AGENT_LOOKS comments"
metadata:
  node_type: memory
  type: reference
  originSessionId: 90f04fdf-81e5-4bf0-9967-52b71f8f84a5
  modified: 2026-11-23T17:07:59.588Z
---

**Icon by name.** `wezterm ls-fonts --text "<chars>"` prints `glyph=md-<name>` and the
font for each codepoint, so the bundled Symbols Nerd Font Mono is its own name index.
Dump md U+F0001..F1AF0 (and fa/oct/cod ranges) in chunks of ~500 chars, parse with
Python (grep on that output misbehaved in this shell), search by name. Exits 1 on big
input but still prints. Proven 2026-11-23: metronome, sun_clock, dolphin...

**Color by gap.** CIE76 dE in CIELAB (D65) against every color in AGENT_LOOKS
(named colors resolved via COLOR_NAMES), WCAG contrast against the inactive plate
`#2c2c2a`, floor 4.0. Candidates on an 8-step sRGB grid. Pick inside the seat's theme
hue band, widest min-dE wins, then add it to the pool before the next seat. This
reproduces the recorded numbers (minerva 5.0/23.5, dawn 4.05/18.9), so it is the
method the older comments used. Script lived in scratchpad (gaps.py/pick.py); rebuild
from this note.

Related: [[project_icon_font_drop]]
