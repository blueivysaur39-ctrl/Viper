---
name: windows-wsl-boundary
description: The session runs in WSL2 (Ubuntu-24.04); /mnt/c exists, Windows PATH is not inherited, wezterm.exe is reachable by full path only
metadata:
  type: project
---

**The session runs inside WSL2, Ubuntu-24.04.** Re-verified 2026-09-14 after the
seat moved off NTFS: `uname -a` → `Linux FireMountain 6.18.33.2-microsoft-standard-WSL2`,
`HOME=/home/bm`, `/mnt/c` present with `metadata` mount options.

**Why:** An earlier era of this project ran the Bash tool under Git Bash (MSYS2),
where paths were `/c/...`, `/mnt/c` did not exist, and Windows path arguments to
`.exe` files needed `MSYS2_ARG_CONV_EXCL`. All of that is dead. Acting on it wastes
a turn on `No such file or directory`.

**How to apply:**
- Config: `/mnt/c/Users/Michael/.config/wezterm/wezterm.lua`.
- Binary (since 2026-09-29, his ruling: nightly only):
  `"/mnt/c/Users/Michael/AppData/Local/Programs/WezTerm-20260929/wezterm.exe"`
  (build 20260929-043349-cab25161, portable zip). The folder is the pin: a new
  build goes in a new folder. The 20240203 build stays in `C:\Program Files\WezTerm`
  as rollback. Full path, quoted. It is **not** on `PATH`: `/etc/wsl.conf` sets
  `[interop] appendWindowsPath=false`.
- Proof after every edit: `<binary> --config-file 'C:\Users\Michael\.config\wezterm\wezterm.lua' ls-fonts`
  exits 0; a Lua error surfaces there. Stage structural edits in the scratchpad
  and prove them with `--config-file <wslpath -w stage>` first: every save of the
  live file reloads his GUI, and a broken one shows him an error pop-up.
- No path mangling in WSL — pass `/mnt/c/...` straight through.
- Still re-run `uname -a` on boot; the harness has changed once already.

Related: [[project-config-hosting]], [[user-michael]]
