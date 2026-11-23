---
name: project-conpty-flicker
description: Claude cursor flash while thinking in WSL panes, measured to the byte on 2026-09-16; fix mux_output_parser_coalesce_delay_ms=0 CONFIRMED by Michael the same day.
metadata:
  type: project
---

On 2026-09-16 I measured why Claude Code's cursor flashes in WezTerm while it thinks. Nothing on his install was changed.

**Method.** A PowerShell/C# harness loads a conpty.dll, spawns wsl.exe, and replays Claude's recorded frames. It logs every read with a timestamp. The harness, replay script and captures sit in that session's scratchpad.

**What Claude emits (2.1.273, both `tui` renderers).** `?2026h ?25l … CUP to the caret ?25h ?2026l`. Hide and show sit inside the sync block, which is correct.

**What each ConPTY hands the terminal:**
- **WezTerm's bundled one (20240203):** `?25l ?2026h ?2026l draw CUP ?25h`, all in one read, on 36 of 37 frames.
- **Windows inbox one (build 26200):** `?2026h?2026l` in one read, then `?25l … ?25h` in the next read. Fine.
- **NuGet ConPTY 1.24.260710001:** Claude's bytes, verbatim. Fine.

**Mechanism.** In the stable source, `mux/src/lib.rs` `parse_buffered_data` flushes all pending actions to the screen when it sees `?2026h`. So the lone `?25l` is drawn. The rest of the frame, including `?25h`, then waits `mux_output_parser_coalesce_delay_ms` (default 3). A bigger delay makes the flash longer, which fits codex#32546, where 20ms did not help.

**Applied.** `config.mux_output_parser_coalesce_delay_ms = 0` in the CURSOR section. `ls-fonts` exits 0. CONFIRMED 2026-09-16: he looked and the flash is gone ("you saved wezterm").

**Why:** he refused the Program Files ConPTY swap as too dramatic and nearly left WezTerm for Windows Terminal over this.
**How to apply:** if 0 does not fully cure it, the next levers are ranked:
1. Swap the ConPTY pair (proven clean in the harness).
2. Move the bundled conpty.dll aside so WezTerm uses the inbox ConPTY. Check first that WezTerm falls back to it.

Both are his hand. Lever 2 does not cure the color-query loss, but lever 1 does; see [[project-conpty-color-query]]. For any other TUI flicker in WSL panes, look at ConPTY first. See [[windows-wsl-boundary]].

**2026-09-29: he moved to nightly**, which bundles ConPTY 1.22.250204002
(changelog). These measurements were taken on 20240203's bundle, so re-measure
before acting on them.
