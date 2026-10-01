---
name: user-michael
description: Michael — operator running 16+ concurrent Claude Code agents daily (was 3-12) on Windows 11 + WSL2; owns installs and naming; wants mental models, not just fixes
metadata:
  type: user
---

Michael is the Operator on the WezTerm config. He came to this project drowning in
eight-plus Cursor terminal windows, running 3 to 12 Claude Code agents a day. **As of
2026-09-29 he runs 16 at once** and calls this setup "way more weight bearing than it
seems". 13 Cursor windows proved unrunnable (see [[project-wsl-spawn-timeout]]), so
WezTerm now carries his agent teams. Design for 16 or more, not 12. Goal: tabs, splits,
workspaces, keyboard-first.

**Environment he works in:** Windows 11 Pro host, WSL2 Ubuntu-24.04 (user `bm`,
`/home/bm`). WezTerm **nightly** 20260929-043349-cab25161 pinned at
`%LOCALAPPDATA%\Programs\WezTerm-20260929\` since 2026-09-29. The 20240203 stable build in
`C:\Program Files\WezTerm` is the rollback. wezterm.org documents nightly, so its pages now apply.

**How he works with me:**
- He holds the eye. I cannot see the rendered window; he looks and reports.
- He owns installs, upgrades, font drops, and the coin on every name.
- He **checks lore against proof** — he asked for a "sanity check" on a prior agent's
  claim rather than accepting it. Prefer running an experiment over citing authority.
- He says when he is lost ("im confused", "im lost on how this is a windows directory
  but run through wsl shell"). When he does, give the **mental model**, not just the
  answer — name the moving parts and how they relate.
- He leans toward working in WSL2 by preference, but the Windows/WSL boundary is
  the part he finds genuinely murky. See [[windows-wsl-boundary]].

Related: [[project-config-hosting]]
