# Agents inside tmux: spec

**Status: NOT BUILT.** Waiting on Michael's ruling. Viper wrote this on
2026-09-29 at celox's request. Every "measured" line was run on this box that
day (tmux 3.4, WezTerm nightly `20260929-043349-cab25161`).

## Goal

An agent survives WezTerm freezing, crashing or being closed. Reopen WezTerm,
reattach, and every agent is still mid-task. A frozen WezTerm stops reading a
pane's output. Without tmux, that can stall the agent itself. With tmux, the
agent writes to the tmux server, not to WezTerm (see T1b).

**Out of scope:** WSL crashes, `wsl --shutdown`, and Windows reboots. The tmux
server lives in the WSL VM and dies with it.

**Risk that could defeat the goal.** `.wslconfig [general] instanceIdleTimeout`
defaults to 15000 ms: "the number of milliseconds that a distro is idle, before
it is shut down" (learn.microsoft.com/windows/wsl/wsl-config). The docs don't
say whether a running tmux server counts as activity. If WezTerm's wsl.exe
processes were the last ones on the box, a crash could take the distro, and
tmux with it, 15 s later. Today 12 other wsl.exe run (Cursor and others),
which would hide the problem. Test T2 decides. The fix, if needed, is
`instanceIdleTimeout=-1`: celox's file, on Michael's word.

## 1. Launch

The agent command is wrapped. This goes after the existing icon and folder
preamble, which is still printed *outside* tmux, straight to WezTerm:

```sh
base='<Repo>-<agent>'; n=$base; i=1
while tmux has-session -t "=$n" 2>/dev/null &&
      [ "$(tmux display -p -t "=$n" '#{session_attached}')" != 0 ]; do
  i=$((i+1)); n="$base-$i"
done
tmux new-session -A -s "$n" '<cmd>' \; set @agent '<repo>/<agent>'
exec bash -l        # the tab's fallback shell stays OUTSIDE tmux
```

| Situation when ALT+A / ALT+R is pressed | Result |
|---|---|
| No session yet | New session running `<cmd>`, fresh or `--resume` |
| Session exists, no tab shows it | Attaches to the running agent. `-A` ignores `<cmd>` (measured), so fresh and resume both mean "reattach" |
| Session exists and is open in a tab | Opens `<base>-2` (or `-3`, …), a second, independent agent, same as pressing ALT+A twice today |

**Naming.** Sessions are named `<Repo>-<agent>`, e.g. `Tiferet-azael` or
`universal-celox`. tmux turns `.` and `:` into `_` (measured:
`Repo.x:agent-2` became `Repo_x_agent-2`). The real key rides on the session
option `@agent`, so nothing ever parses the name. `=name` makes tmux match
the name exactly.

## 2. Recovery: ALT+SHIFT+R (unbound today)

1. Run `wsl.exe -d Ubuntu-24.04 --exec tmux list-sessions -F
   '#{session_name} #{session_attached} #{@agent}'` with `run_child_process`.
   It is async, so a slow WSL delays the list but never freezes the window. On
   failure, the tab bar shows it in red.
2. Keep the sessions with 0 clients: those are the agents whose window died.
   Group them by repo, taken from `@agent`.
3. For each repo, start `wezterm-gui.exe start --always-new-process --
   __reattach__ <name> <name> …`, which gives one process per repo. A
   `gui-startup` handler (since 20220624) sees `__reattach__` and opens one
   tab per name: preamble, then `exec tmux attach -t =<name>`. When the
   handler spawns panes, no default shell opens. Normal starts are
   unaffected.
4. If nothing is detached, the tab bar says so in red.

**Finished sessions don't pile up.** An agent that exits with status 0 ends
its session, because the shell tail is outside tmux, and its tab drops back
to a plain shell. An agent that exits non-zero keeps its pane, with the error
on screen (`remain-on-exit failed`).

**The real pile-up source: closing a tab (ALT+W) now only detaches.** The
agent keeps running. To spot these, ALT+SHIFT+R reopens them all, or run
`tmux ls` in any shell. To end one, type `/exit` in the agent, or run
`tmux kill-session -t =<name>`.

## 3. `~/.tmux.conf` (Viper drafts it, celox lands it on Michael's word)

```tmux
# WezTerm owns tabs, splits, keys and the status line; tmux keeps agents alive.
set -g  prefix None             # CTRL+B is Claude Code's (background a task)
unbind  C-b
set -g  status off              # WezTerm's tab bar already says who is where
set -s  escape-time 10          # not 0 -- see below; tmux default is 500
set -s  extended-keys on
set -as terminal-features ',xterm-256color:RGB:extkeys'
set -g  default-terminal tmux-256color   # terminfo present (checked)
setenv -g COLORTERM truecolor   # Claude and Codex choose truecolor from this
set -g  focus-events on
set -g  history-limit 10000     # section 5
set -g  remain-on-exit failed
set -g  mouse on                # section 4
bind -T copy-mode    MouseDragEnd1Pane send -X copy-pipe
bind -T copy-mode-vi MouseDragEnd1Pane send -X copy-pipe
unbind -n MouseDown3Pane        # no tmux menu; WezTerm pastes on right-click
set -s  set-clipboard on        # a copy reaches Windows through OSC 52
set -g  set-titles on           # Claude's status title still reaches WezTerm
set -g  set-titles-string '#T'
# allow-passthrough stays off: the icon and folder reports are printed before
# tmux starts. Turn it on only if something INSIDE a session must reach
# WezTerm.
```

**escape-time 10, not 0.** WezTerm sends SHIFT+ENTER as ESC CR. With 0, if
those two bytes ever arrive in separate reads, tmux delivers Escape, which
interrupts Claude's turn, and then Enter, which submits. 10 ms keeps the pair
together, and Esc still feels instant.

**extended-keys.** SHIFT+ENTER doesn't depend on it: tmux passes ESC CR through
as Meta-Enter. ConPTY owns key encoding on Windows, so the setting is probably
inert, but harmless. T3 proves SHIFT+ENTER either way.

## 4. Scrollback, copy, paste

- **A, recommended: tmux `mouse on`.**
  - The wheel scrolls tmux's history, and scrolling back to the bottom
    leaves it.
  - Dragging selects in tmux and copies on release.
  - A CTRL+C after that only leaves copy mode. tmux's default,
    `copy-pipe-and-cancel`, leaves copy mode on release, which would let
    that habitual CTRL+C reach the agent as an interrupt (measured
    defaults). The config above swaps it for `copy-pipe`.
  - Right-click paste stays: WezTerm adds a Right-click binding with
    `mouse_reporting = true` (since 20220807).
  - SHIFT+drag is still WezTerm's own selection of the visible screen, and
    CTRL+C copies it as today.
  - The cost: typing while scrolled up goes to copy mode. Press Esc first,
    or wheel back to the bottom.
- **B: tmux `mouse off`.** Drag, right-click and CTRL+C behave exactly as
  today. But the wheel reaches the agent as arrow keys, because tmux runs on
  the alternate screen, and scrolls Claude's prompt history. Scrollback
  would be keyboard-only.
- **C: no alternate screen (`smcup@`).** tmux's full-screen redraws smear
  into WezTerm's scrollback. Rejected.

**Open question:** OSC 52 has to cross ConPTY, and that is untested (T6). The
fallback is `copy-command` piped to `clip.exe`, which goes through interop
and garbles non-ASCII text.

## 5. Memory

Measured on a private tmux server with 20,000-line floods of 100-column text:
**about 3.5 KB per history line, the same with truecolor.** Killing the
sessions gave back about 1%. The server keeps its peak until it exits.

| history-limit | One agent, history full | 15 agents |
|---|---|---|
| 2,000 (tmux default) | 7 MB | 105 MB |
| **10,000 (pick)** | **35 MB** | **525 MB** |
| 50,000 | 175 MB | 2.6 GB |

10,000 lines is about 3× WezTerm's current depth (the default 3,500;
`wezterm.lua` doesn't set it). At worst that is about 3% of the 16 GB VM.
Note where the memory moves: from wezterm-gui on Windows into the VM, which
is where this week's shortage was. A tmux tab's own WezTerm scrollback stays
near empty, because tmux runs on the alternate screen. The empty server's
baseline is 4.5 MB. `tmux kill-server` returns everything, but only once no
agent is running.

## 6. Rollout and rollback

In `wezterm.lua`:
`local TMUX_FOR = { ['Viper/viper'] = true, … }` plus `local TMUX_ALL = false`.
`add_agent` wraps the command only when `TMUX_ALL or TMUX_FOR[key]`. Start
with 2 or 3 agents. **Rollback:** empty the table. The next launches are plain.
Agents already in tmux run until they exit, and ALT+SHIFT+R still finds them.
`~/.tmux.conf` does nothing while no launch uses tmux.

## 7. Test plan (before anything goes beyond the trial agents)

- **T1, crash.** Open a throwaway window with ALT+N (it is its own process).
  In it, start two trial agents mid-task plus a probe session:
  `tmux new -s probe 'while :; do date +%T; sleep 1; done'`. Then run
  `taskkill /F /PID <that process>`. No other window is touched. Wait 60 s,
  press ALT+SHIFT+R, and check:
  - the probe shows no gap;
  - the agents' PIDs and `#{session_created}` are unchanged;
  - the transcripts carried on.
- **T1b, freeze.** Suspend the test window's process for 2 minutes (Resource
  Monitor > Suspend process). The probe and the agents keep running.
- **T2, last client.** With only trial agents at stake, end every other
  wsl.exe and every WezTerm process. Run `wsl --list --running` at 30 s and
  60 s, then reattach. If the distro stopped, apply the fix in the Goal
  section first.
- **T3, SHIFT+ENTER.** Press it 20 times while an agent is busy. Each press
  is a newline, never a submit or an interrupt. `cat -v` in a tmux pane
  shows `^[^M`.
- **T4, colors.** A truecolor bar in tmux matches a plain tab side by side,
  and so does Claude's theme.
- **T5, icons and folders.** Reattached tabs show the agent's icon and name.
  ALT+\ splits land in the repo.
- **T6, scrollback and clipboard.**
  - The wheel scrolls up, and scrolling to the bottom leaves copy mode.
  - Drag, then CTRL+V in another tab, pastes the text: that proves OSC 52.
  - CTRL+C after a selection doesn't interrupt the agent.
  - Right-click pastes, and SHIFT+drag still works.
- **T7, cursor flicker.** Watch Claude think inside tmux: the ConPTY
  flicker fix (`coalesce_delay_ms = 0`) was measured without tmux.
- **T8, memory.** After a full day, check
  `ps -o rss= -p $(tmux display -p '#{pid}')` against section 5.

## Note: the 16:23 crash (2026-09-29)

There is still no root cause. It was the 2024 build (pid 12204, up since
10:30), which logged nothing after 11:00. There was no config save at 16:23:
the saves were at 11:10, 13:47 and 17:08.

One trigger that doesn't need a save isn't ruled out yet: a Windows
appearance change. It makes every window re-run the config on its own thread.
That was read in the nightly source; the 2024 build's source wasn't checked.
Since `6a96083`, that re-run no longer reads across the WSL bridge.

**If WezTerm freezes again, before closing it:** Task Manager > Details >
right-click `wezterm-gui.exe` > Create memory dump file.
