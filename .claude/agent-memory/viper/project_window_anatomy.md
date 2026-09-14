---
name: project-window-anatomy
description: Proven map of which WezTerm option governs which part of the window on Windows — window_padding vs window_frame vs colors.tab_bar — plus dead ends
metadata:
  type: project
---

Verified on Michael's machine 2026-09-14, WezTerm `20240203-110809-5046fc22`,
Windows host. Top of the window, outermost first:

1. `window_frame.border_top_height` / `border_top_color` — space **above the
   tab bar**. Docs call borders "primarily for Wayland client-side
   decorations"; they work on Windows anyway. Currently `6px`, colored to the
   bar so it reads as one surface.
2. `window_frame.active_titlebar_bg` / `inactive_titlebar_bg` / `font_size` —
   the **fancy** tab bar itself. `font_size` sets its height.
3. `colors.tab_bar.*` — the tabs drawn on that bar (active/inactive bg+fg).
4. `window_padding.top` — gap **between the tab bar and the terminal content**.
   It does *not* push the tab bar down. Default `0.5cell`.

**Why:** Michael asked for "padding above the tabs" and the obvious lever
(`window_padding.top`) is the wrong one — it pads the content, not the frame.
Two increments were spent discovering this.

**How to apply:**
- Frame/bar → `window_frame`. Content → `window_padding`. Tabs → `colors.tab_bar`.
- Dead ends, do not retry: `window_padding.top` for space above tabs;
  `use_fancy_tab_bar = true` **together with**
  `window_decorations = 'INTEGRATED_BUTTONS|RESIZE'` on Windows (tab bar and
  buttons both vanish — fancy bar draws in the titlebar region).
- Working combination: `use_fancy_tab_bar = true` + `window_decorations =
  'RESIZE'`. The fancy bar brings a per-tab ✕ and a `+` for free — the
  `show_close_tab_button_in_tabs` option is nightly-only and applies to the
  retro bar, not this one.
- The retro bar is welded to the window's top edge and is one terminal row tall.

Related: [[windows-wsl-boundary]], [[feedback-dont-capitulate]]
