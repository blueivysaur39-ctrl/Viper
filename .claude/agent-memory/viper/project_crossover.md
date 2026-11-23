---
name: project-crossover
description: Michael flipped from Windows+WSL2 to native Ubuntu 24.04 on 2026-10-30; WezTerm port in progress; state and open items in ~/repos/Viper/crossover/LEDGER.md
metadata:
  type: project
---

Michael moved his workday from Windows + WSL2 to native Ubuntu 24.04.5
(GNOME 46, Wayland session) on 2026-10-30. He wants WezTerm to feel nearly
identical. The plan, every decision and the open items are in
`~/repos/Viper/crossover/LEDGER.md` (see its Log); read it first.

State as of 2026-10-30:
- The live config is `~/.config/wezterm/wezterm.lua`, a clone of GitHub
  `Wezterm`. Its edits are uncommitted; Michael owns those commits.
- Ported: the WSL domain, the roster paths, and ALT+N (`/usr/bin`).
- The window runs under X11 (`enable_wayland = false`) with no frame
  (`'NONE'`). WezTerm's Wayland backend can't move windows on GNOME, its
  own frame strip was rejected, and its X11 minimize is a no-op.
- GNOME does what WezTerm can't: Super + right-drag resizes, Alt+M
  minimizes, and the dock click shows previews.

**Why:** GNOME + WezTerm gaps get solved in GNOME settings, not by building
WezTerm. He rejected a custom build as too many moving parts.

**How to apply:**
- No `/mnt/c` means the Linux seat. CLAUDE.md was rewritten for Linux on
  2026-11-22 (ritsuko, at Michael's word). The Windows-era memories,
  [[windows-wsl-boundary]] among them, went to `Altbau/memory-2026-11-22/`.
- Since 2026-11-22 viper boots from `.claude/instruktion/viper.md` through
  its own `CLAUDE_SEATS` row (`Viper/viper`, opus/xhigh). It no longer runs
  as `--agent`; Michael approved the row himself.
- Check GNOME's own shortcuts before binding keys. Alt+H is already his
  pane-left key, and Super+N belongs to GNOME.
- On Linux, auto-reload depends on free inotify watches (see the ledger).
  If a save doesn't show, suspect that before suspecting the config.
  Separate limit, 2026-11-18: inotify *instances* (max_user_instances 128)
  ran out (Cursor 38, agy 29); every `wezterm` CLI then panics with EMFILE at
  config/src/lib.rs:513, so ls-fonts can't prove a save. Corrected
  2026-11-19 from source: the panic is `recommended_watcher(tx).unwrap()`
  in watch_path, *after* the config loads, and only when
  automatically_reload_config is true (lib.rs:636). Setting it false avoids
  the crash at the cost of auto-reload. kitty survives the same shortage:
  its watcher is a helper process (`kitten __watch_conf__`) that just fails.
  Recurred 2026-11-19 with only 2 WezTerm windows (1 instance each): agy 40
  (7 per Gemini session, each holding 0-2 watches; 6 open), Cursor 38. The count scales with agy
  sessions, not WezTerm. Watches cap is now 524288 (60-inotify-watches.conf);
  instances raised 128 -> 1024 in the same file, 2026-11-19, after celox
  weighed in. If ALT+N dies again, count holders before anything else.
  ALT+N dies the same way, silently: the spawn succeeds, so complain()
  never fires, and the child panics. Seen 129 of 128 in use the same day.
- Keep brights slot 12 ([[inline-code-blue]]).
