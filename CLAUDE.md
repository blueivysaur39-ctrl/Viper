# Viper's seat

## How we got here

Viper began inside the Windows config folder itself — one git repo living in
`C:\Users\Michael\.config\wezterm`, with the agent's Instruktion and memory
sitting next to the live `wezterm.lua` (commit `5fd7ef4`). That put agent
scaffolding on NTFS and ran the session through Git Bash (MSYS2), where
`/mnt/c` does not exist and Windows paths get mangled.

On 2026-09-14 the seat moved to ext4 inside WSL2 and the history split into
two repos, both descended from `5fd7ef4`:

- **`Viper`** → `github.com/blueivysaur39-ctrl/Viper`, checked out at
  `~/repos/Viper` (this repo). The seat: this file, `.claude/` (Instruktion +
  agent memory), `.gitignore`, `.claude/settings.json`. The live `wezterm.lua`
  was deleted here — it survives only in history before `7ffb73e`.
- **`Wezterm`** → `github.com/blueivysaur39-ctrl/Wezterm`, checked out at
  `C:\Users\Michael\.config\wezterm`. The live config, under version control
  in place. Michael owns this repo's commits.

## What is true now (verified 2026-09-14)

- The session runs in **WSL2, Ubuntu-24.04** (`uname -a`: `microsoft-standard-WSL2`,
  host `FireMountain`). `/mnt/c` exists; `/etc/wsl.conf` sets `systemd=true`,
  `automount metadata`, and `interop.appendWindowsPath=false`.
- The live config is `/mnt/c/Users/Michael/.config/wezterm/wezterm.lua`
  (= `C:\Users\Michael\.config\wezterm\wezterm.lua`). Edit it **there**.
  Never keep a copy of it in this repo.
- The binary is reachable **by full path only**:
  `"/mnt/c/Program Files/WezTerm/wezterm.exe"` (build `20240203-110809-5046fc22`).
- Proof of a good save, naming the file explicitly so a silent fallback cannot
  pass for a pass:
  `"/mnt/c/Program Files/WezTerm/wezterm.exe" --config-file 'C:\Users\Michael\.config\wezterm\wezterm.lua' ls-fonts`
  exits 0. A config that fails to parse is ignored and WezTerm runs on defaults.
- Edit the live file directly; the `Wezterm` repo is the undo. The staging file
  `wezterm.lua.candidate` was deleted 2026-09-14 — it drifted from live twice
  and earned nothing.
- Launch: `cd ~/repos/Viper && claude --agent viper`.
