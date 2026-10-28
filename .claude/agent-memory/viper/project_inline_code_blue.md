---
name: inline-code-blue
description: The sky blue of inline `code` in Claude Code is WezTerm palette slot 12 (#9EDBFF) via dark-ansi's permission color; Michael likes it — don't "fix" it away
metadata:
  type: project
---

Inline code (backticks) in Claude Code renders in the theme's `permission`
color — the only codespan color rule in Claude Code 2.1.311 (read from the
binary 2026-10-27). His theme `~/.claude/themes/chrome.json` (base `dark-ansi`,
unchanged since 2026-09-03) overrides `permission` to olive `#a6a487`, yet he
sees sky blue. A swatch test (2026-10-27) matched `\e[94m` = ANSI bright blue =
WezTerm `brights[5]` `#9EDBFF` — his own hand-set Cursor color — over the
built-in dark theme's periwinkle `#b1b9f9`. So on the inline-code path the
override does not land and dark-ansi's `permission: ansi:blueBright` does.
Why the override is skipped there is unproven.

He likes that blue (2026-10-27).

**Why:** the color he likes depends on two things nobody chose for it:
palette slot 12 in wezterm.lua, and Claude Code not applying the override
on that path.

**How to apply:** leave `brights` slot 12 at `#9EDBFF`, including in the
Linux port. If inline code ever turns olive after a Claude Code update, the
override started landing. Pinning `permission` to `#9EDBFF` would also recolor
permission prompts, so that's his call. Related: [[user-michael]]
