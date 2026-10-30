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
- No `/mnt/c` means the Linux seat. CLAUDE.md's "What is true now" and
  [[windows-wsl-boundary]] still describe Windows; rewriting them is an open
  port item.
- Check GNOME's own shortcuts before binding keys. Alt+H is already his
  pane-left key, and Super+N belongs to GNOME.
- On Linux, auto-reload depends on free inotify watches (see the ledger).
  If a save doesn't show, suspect that before suspecting the config.
- Keep brights slot 12 ([[inline-code-blue]]).
