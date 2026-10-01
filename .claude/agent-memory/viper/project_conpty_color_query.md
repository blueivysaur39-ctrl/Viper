---
name: project-conpty-color-query
description: Codex paints no prompt background in WezTerm WSL panes because ConPTY (bundled AND inbox) swallows OSC 10/11 color queries; NuGet ConPTY 1.24 forwards them (measured 2026-09-21)
metadata:
  type: project
---

**Codex draws its prompt panel only if the terminal answers the OSC 10/11 color
queries. In his WezTerm WSL panes nothing answers, so Codex draws no panel.**
Measured 2026-09-21 on Codex 0.155.1 and WezTerm 20240203.

**Codex side (source at tag rust-v0.155.1):**
- `tui/src/style.rs`: the prompt background is 12% white blended over the
  terminal background. On his `#1E1E1E` that is `#393939`. Unreleased `main`
  uses 16% (`#424242`) for submitted prompts.
- If the probe gets no reply, Codex falls back to *no background at all*.
  `terminal_probe.rs` needs both replies within 100 ms.
- No config key controls this. The `[tui]` struct has none, and `tui.theme`
  (`.tmTheme` files in `~/.codex/themes/`) only changes syntax highlighting.
  The open requests are openai/codex#21130 and #15736.

**Proof.** `wezterm cli get-text --escapes` on a live Codex pane showed zero
background SGR codes. I then ran a Python probe under a headless
`wezterm-mux-server.exe` copy in `%TEMP%` (invisible, cleaned up after):
- **Bundled ConPTY:** DA1 got `?61;6;7;22;23;24;28;32;42c`, which is ConPTY
  answering. The OSC 10/11 queries got nothing in 2 s.
- **Inbox ConPTY (no conpty.dll beside the exe):** the same result.
- **NuGet ConPTY 1.24.260710001:** DA1 got `?65;4;6;18;22c`, which is WezTerm's
  own reply. OSC 10/11 were answered in 3 ms.
- WezTerm stable answers OSC 11 itself (`term/src/terminalstate/performer.rs`
  around line 995).

**Why:** he wanted Codex's prompt background to match his Claude theme
(`userMessageBackground #2c2c2a`) so he can tell his prompts from replies.
**How to apply:** the only lever is the ConPTY swap, which is his hand and was
refused once as "too dramatic". It now has two payoffs: this issue and
[[project-conpty-flicker]]. Even after the swap, Codex's color is hardcoded
(`#393939`), not `#2c2c2a`. Codex reads the colors once at startup, so restart
it after the swap. This probe method (a mux-server copy in temp, no GUI) is the
clean way to test any ConPTY behaviour.

**2026-09-29: he moved to nightly**, which bundles ConPTY 1.22.250204002
(changelog). These measurements were taken on 20240203's bundle, so re-measure
before acting on them.
