---
name: feedback-smallest-path
description: Take the smallest path that delivers the thing asked for; no tooling, generators, or doc pipelines around the config — comment the Lua instead
metadata:
  type: feedback
---

**Do the smallest thing that delivers what he asked for. Don't build scaffolding
around the config.**

2026-09-14: he asked whether the staged `wezterm.lua.candidate` could be paired
with a friendlier `.md`. I proposed annotated bindings, a generator script, a
`CHEATSHEET.md`, and a proof step tying it to `show-keys`. His answer: *"ok too
much work. my fault. ill learn to read the .candidate its fine."* Then he
immediately named the real want: colors.

**Why:** He is not afraid of the Lua — he would rather read one commented file
than maintain a second artifact and a pipeline keeping them honest. Machinery
around the config is overhead he did not ask for, and it delays the thing he
actually wants to see on screen.

**How to apply:**
- The config file *is* the documentation. Put the explanation in comments, at
  the line it explains, in plain words — that satisfies the readability want
  with zero new files.
- When he asks an open question about structure, give the short answer and one
  option, not a staged plan. If the plan runs past a few lines, it is too big.
- Ship the visible change first; polish is his call afterwards.

Related: [[feedback-terse-and-ask]], [[user-michael]]
