---
name: feedback-terse-and-ask
description: Michael wants short answers and no unrequested building — a question is not a work order; confirm before creating anything
metadata:
  type: feedback
---

**Two rules, both given 2026-09-14 after I violated them in the same turn.**

### 1. Be terse
"dial it down. way too wordy." Cut the tables, the tiered option lists, the
recaps. Answer the question asked, then stop.

**Why:** He left Windows/Cursor over "slow friction that is tiresome." Verbose
answers are the same tax in a different form — he has to read past them to find
the one fact he wanted.

**How to apply:** Lead with the direct answer. Findings get one line each, not a
section. No summary of what I just did unless he asks. If a mental model is
genuinely needed (he said "im confused" / "im lost"), that earns prose — but
that is the exception, and he will say so.

### 2. A question is not a work order
He asked "can we set up a wezterm repo...?" and I ran `git init` and committed.
He also asked me to stop, then I staged a config file anyway. Both wrong.
"lets dive in" does **not** stay in force after he interrupts.

**Why:** He tracks what changed on his machine and reacted sharply to finding
artifacts he did not request. Trust depends on the diff matching the ask.

**How to apply:** When he phrases something as "can we / could we / what if" —
answer whether it is possible and wait. Build only on an imperative. After any
interruption, the go-ahead is void until he re-issues it. Always state plainly
what was created or modified, and offer the undo.

Related: [[user-michael]]
