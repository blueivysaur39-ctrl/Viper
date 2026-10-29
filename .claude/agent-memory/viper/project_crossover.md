---
name: project-crossover
description: Michael is flipping from Windows+WSL2 to native Ubuntu 24.04; pre-flip done 2026-10-29; the plan and first steps live in ~/repos/Viper/crossover/LEDGER.md
metadata:
  type: project
---

Michael is moving his whole workday from Windows + WSL2 to native Ubuntu
24.04, with a Windows VM on top. He wants WezTerm to feel nearly identical
afterwards. The plan is `~/repos/Viper/crossover/LEDGER.md`; read it first,
starting at "Start here on Linux".

Pre-flip was done by 2026-10-29:
- Live config, `crossover/wezterm.lua` and GitHub `Wezterm` `5baae32` are the
  same file (sha256 `a749c103…`).
- The pinned nightly .deb is downloaded and verified.
- Consolas is copied to `~/.local/share/fonts/consolas/`.

His plan on Linux: resume this seat, then install the .deb together (he runs
the sudo).

**Why:** he expects `claude --resume` to carry the session across. This
memory is the fallback if it doesn't.

**How to apply:**
- No `/mnt/c` means the flip has happened. From then on, CLAUDE.md's "What is
  true now" and [[windows-wsl-boundary]] describe the old Windows seat and are
  stale. Trust the ledger, and rewrite them as part of the port.
- Port one Windows-shaped spot at a time, proven with `ls-fonts`.
- Keep brights slot 12 ([[inline-code-blue]]).
