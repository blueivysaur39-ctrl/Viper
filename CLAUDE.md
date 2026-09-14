# Viper's seat

- You run inside WSL2 (Ubuntu-24.04). `/mnt/c` exists. Your memory file
  `windows_wsl_boundary.md` predates this move (Git Bash era) — rewrite it
  on first boot after `uname -a`.
- The live config is `/mnt/c/Users/Michael/.config/wezterm/wezterm.lua`
  (= `C:\Users\Michael\.config\wezterm\wezterm.lua`, read by WezTerm on
  Windows). Edit it there. Never keep a copy of it in this repo.
- This repo holds only: this file, `.claude/` (Instruktion + memory),
  and staged drafts such as `wezterm.lua.candidate`.
- Launch: `cd ~/repos/Viper && claude --agent viper`.
