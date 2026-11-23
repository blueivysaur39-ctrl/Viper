---
name: project-config-hosting
description: Where wezterm.lua lives and why — Windows-hosted at ~/.config/wezterm is proven and load-bearing; WSL2-hosting works over UNC but is rejected on reload/availability risk
metadata:
  type: project
---

**The live config is `C:\Users\Michael\.config\wezterm\wezterm.lua`, read by a
Windows process, and it should stay Windows-hosted.**

**Why:** Verified 2026-09-14 by experiment, not assertion —
- Nothing shadows it: `WEZTERM_CONFIG_FILE` and `XDG_CONFIG_HOME` are unset in both
  `HKCU\Environment` and the machine environment; there is no `wezterm.lua` beside
  `wezterm.exe` (thumb-drive mode). Discovery lands on the `.config` path.
- **WSL2-hosting is technically possible** — contra a prior agent's claim that it is
  "just wrong." A probe config written to `/home/bm` loaded successfully via
  `wezterm.exe --config-file '//wsl.localhost/Ubuntu-24.04/home/bm/probe.lua'`
  (font visibly changed in `ls-fonts`). The claim of impossibility is **false**.
- It is nevertheless rejected on **risk, not capability**: (a) the GUI is a Windows
  process and will never *auto-discover* a WSL path, so it requires a permanent
  `WEZTERM_CONFIG_FILE` env var; (b) save-triggered auto-reload likely dies over the
  9P share, since Windows change notifications are unreliable there — **unverified,
  needs Michael's eye**; (c) if the distro is down at GUI launch the read fails, and
  a failed config read means silent fallback to stock defaults.

**How to apply:** Keep discovery on the `.config` path. If Michael wants the file
*out* of `~/.config` (raised 2026-09-14, e.g. to put it in a git repo), prefer a
**Windows directory junction** `C:\Users\Michael\.config\wezterm -> <target>` over
setting env vars — it keeps the zero-fragility discovery path while relocating the
bytes. `XDG_CONFIG_HOME` would work but leaks into other tools. Never suggest
thumb-drive mode (needs admin, wiped on upgrade).

Related: [[windows-wsl-boundary]], [[user-michael]]
