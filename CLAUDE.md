# Viper — the terminal seat's ground

This repo is the seat: viper's file, its memory and this page. The work
itself is one file in another repo, `/home/bm/.config/wezterm/wezterm.lua`
(repo `Wezterm`, `github.com/blueivysaur39-ctrl/Wezterm`, checked out at
`~/.config/wezterm`). It is the WezTerm config that puts all of Michael's
agents in one window, and every seat on the box starts from its roster. Edit
it in place, and keep no copy of it in this repo.

- **The box.** Native Ubuntu 24.04 since 2026-10-30. WezTerm is the pinned
  nightly `20260929-043349-cab25161` at `/usr/bin/wezterm`. The Windows and
  WSL2 years are history, and `crossover/` is the record of the move.
- **A config that fails to load is ignored without a word.** WezTerm then
  runs on its defaults. Every open window reloads the file on save, so one
  bad save takes the whole layout down at once.
- **Proof of a good save**, naming the file so that a fallback cannot pass
  for a pass:
  `wezterm --config-file /home/bm/.config/wezterm/wezterm.lua ls-fonts`
  exits 0 and prints no error. For a structural change, prove a copy under
  `/tmp` the same way before it replaces the live file.
- **The docs describe the newest nightly.** Each option page on wezterm.org
  has a `Since:` line, and anything newer than the pinned build does not
  exist here.
- **Commits.** A finished, proven change to the config is committed in the
  config's own repo, and memory in this one. Subject `viper — <what>` in
  both. Michael pushes.

Where this file and the tree disagree, the tree is right and the file gets
fixed.
