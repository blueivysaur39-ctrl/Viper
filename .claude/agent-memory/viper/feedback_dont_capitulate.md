---
name: feedback-dont-capitulate
description: When a UI attempt fails, isolate the variable and keep trying — don't retreat to the safe option or hand the problem back to him
metadata:
  type: feedback
---

**When something doesn't work, isolate the variable and try again. Do not
retreat to the known-good option and ask him to choose.**

2026-09-14: two attempts at removing the Windows title bar left the tab bar
invisible. I reverted and offered him a menu — flip Windows to dark mode, or
give up on it. He answered: *"dont give up yet. i see half a dozen examples with
quick online search of people doing what i want"* and sent a screenshot of
someone's WezTerm doing exactly that. Both my failures had changed **two**
things at once (fancy tab bar **and** integrated title buttons); I had never
tested them apart. Isolating them found the answer in one try, and the feature
he wanted worked.

**Why:** He can see the rendered window and search for prior art; I cannot. If
he says it is possible, it is — my failure is evidence about *my* approach, not
about the tool's limits. Offering him a menu of retreats spends his attention on
a decision he already made.

**How to apply:**
- Never change two variables in one increment; when something breaks, the first
  move is to separate them, not to revert wholesale.
- Before declaring a limit, name the exact combination tested and the one not
  yet tested. If an untested combination exists, try it.
- Experiments he can judge in one look are cheap — he is willing to look. Frame
  them as experiments with a one-line revert and run them.
- Record proven results as comments at the relevant line in `wezterm.lua`, so a
  dead end is never retried.

Related: [[feedback-smallest-path]], [[user-michael]]
