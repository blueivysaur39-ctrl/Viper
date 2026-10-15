---
name: reference-wezterm-logs
description: Where the Windows nightly writes its logs (per-process file, lazy, time-only stamps, Info and up) and how to time things from Lua
metadata:
  type: reference
---

**Log files:** `C:\Users\Michael\.local\share\wezterm\wezterm-gui.exe-log-<pid>.txt`
(`/mnt/c/Users/Michael/.local/share/wezterm/`). Not `%LOCALAPPDATA%\wezterm`, which
holds only blob-lease dirs. The same folder holds the `gui-sock-<pid>` sockets.

Read in `env-bootstrap/src/ringlog.rs` (main, 2026-10-08) and matched against the
files on disk:
- One file per process, named `<exe>-log-<pid>.txt`, **created on the first line
  logged**. A window that has logged nothing has no file; that is normal.
- Default filter is Info: Error, Warn and Info reach the file, stderr and the
  CTRL+SHIFT+L overlay alike. `WEZTERM_LOG` changes it.
- Lines are stamped `HH:MM:SS.mmm` local time, **no date**. Put the date in the
  message when it matters.
- The overlay keeps only 16 lines per level; the file keeps everything.
- Lua lines appear as `logging > lua: ...`.

**Timing from Lua:** a Time object has no subtraction.
`tonumber(wezterm.time.now():format('%s%3f'))` gives epoch milliseconds as an
integer (proven on cab25161). The roster globs use it; a healthy glob over
`\\wsl.localhost` took 20 ms for 47 files.

Related: [[project-config-load-hazard]], [[project-wsl-spawn-timeout]]
