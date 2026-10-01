---
name: project-config-load-hazard
description: Why wezterm.lua must never touch \\wsl.localhost (or anything slow) at load — nightly source shows windows re-run the whole config on the GUI thread; plus the one-process-per-window design (2026-09-29)
metadata:
  type: project
---

**Rule: loading wezterm.lua reads nothing but wezterm.lua.** Slow work (the
agent roster glob over `\\wsl.localhost`) runs inside key callbacks, where
`wezterm.glob` / `run_child_process` are async and don't block the window.
Proven with a probe config that wraps glob/read_dir/io.open: 0 calls at load
(was 6), 2026-09-29.

**Why:** read in the nightly source (cab25161), 2026-09-29:
- `config/src/lib.rs`: `reload()` holds the CONFIG mutex for the whole Lua
  evaluation, and `configuration()` takes the same mutex. The GUI calls that
  constantly.
- `termwindow/mod.rs` `config_was_reloaded` → `overridden_config()` re-runs the
  **entire file on the GUI main thread, once per window**, on every reload.
  `AppearanceChanged`, a Windows theme broadcast, triggers `config::reload()`
  plus that call. So does a tab-bar show/hide.
- The watcher watches the parent dir non-recursively, so a change to any direct
  child (`.git`, `.claude`) triggers a reload.
- A stalled 9P bridge during any of those hangs the window. That's plausible
  for the 16:23 AppHang that killed 10-15 agents, but **the trigger is
  unproven**.
- 16:23 facts from celox: it was the **2024 build**, pid 12204, up since
  10:30. It logged nothing after 11:00, and there was no config save at 16:23
  (saves were at 11:10, 13:47 and 17:08). An appearance-change reload is
  still possible. The 2024 source is unchecked.
- **Capture step if WezTerm freezes again:** Task Manager > Details >
  right-click wezterm-gui.exe > Create memory dump file, BEFORE closing it.
- `set_config_overrides` also re-evaluates the file. Don't use it for dynamic
  data.

**One process per window (his ruling via celox, 2026-09-29):** new-window keys
run `wezterm-gui.exe start --always-new-process` from `executable_dir`. There's
no job object in the source, so a child outlives its parent. Gather's CLI is
pinned to its own process: `WEZTERM_UNIX_SOCKET` is set by each GUI at
main.rs:415. Pane ids are per process.

**How to apply:** any new data source goes in a callback, never at top level.
Show failures with `complain()`, a red right-status for 10 s. Windows toasts
use an unregistered app id on the portable build, so they're untrusted.
Related: [[project-wsl-spawn-timeout]], [[project-config-hosting]].
