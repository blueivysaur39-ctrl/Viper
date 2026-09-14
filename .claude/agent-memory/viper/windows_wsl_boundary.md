---
name: windows-wsl-boundary
description: My Bash tool here is Git Bash (MSYS2), NOT WSL2 — paths are /c/... not /mnt/c/...; the Instruktion's /mnt/c claim is stale
metadata:
  type: project
---

**The Bash tool in this project runs Git Bash (MSYS2), not WSL2.** Verified
2026-09-14: `uname -a` returns `MINGW64_NT-10.0-26200 ... Msys`, `HOME=/c/Users/Michael`,
and `/mnt/c` **does not exist**.

**Why:** The agent's Instruktion (`.claude/agents/viper.md`) states "you run inside the
distro" and gives paths as `/mnt/c/Users/Michael/...`. That was true of an earlier
launch method; it is not true of the current session harness. Acting on it wastes a
turn on `No such file or directory`.

**How to apply:**
- Reach the config as `/c/Users/Michael/.config/wezterm/wezterm.lua`.
- Reach the binary as `/c/Program Files/WezTerm/wezterm.exe` (no `/mnt` prefix).
- Re-run `uname -a` on boot — the harness could change back.
- To touch the *Linux* side, shell out explicitly:
  `/c/Windows/System32/wsl.exe -d Ubuntu-24.04 -e sh -lc '...'` and pipe through
  `tr -d '\0'` (wsl.exe emits UTF-16 nulls that garble output).
- Git Bash mangles Windows/UNC path arguments to .exe files. Prefix commands with
  `MSYS2_ARG_CONV_EXCL='*'` (and/or `MSYS_NO_PATHCONV=1`) when passing `\wsl.localhost\...`
  or `C:\...` to `wezterm.exe`, or the argument silently loses a backslash.

Related: [[project-config-hosting]], [[user-michael]]
