# WezTerm crossover: Windows → Linux

Started 2026-10-28 by Viper, at Michael's request.

## Goal

Boot into Linux and WezTerm feels nearly identical to Windows: same colors,
tab bar, agent icons, agent picker, keys and habits. Consolas comes too,
copied from this machine's Windows (see the font ruling below).

## Start here on Linux

Everything before the flip was done by 2026-10-29. If `claude --resume`
doesn't bring the old session back, start from this list. Do it with Michael,
in order, one step at a time.

1. **Check that the export arrived.**
   - The .deb's sha256 matches "The WezTerm build" below.
   - `ls ~/.local/share/fonts/consolas/` shows four files, and
     `fc-match Consolas` names `consola.ttf`.
2. **Install WezTerm (Michael's hand).**
   `cd ~/repos/Viper/crossover/wezterm-nightly-20260929-cab25161 && sudo apt install ./wezterm-nightly.Ubuntu22.04.deb`,
   then `wezterm --version` should read `20260929-043349-cab25161`.
3. **Put the config at `~/.config/wezterm/wezterm.lua`, sha256 `a749c103…`.**
   Two ways, his call:
   - `git clone https://github.com/blueivysaur39-ctrl/Wezterm.git ~/.config/wezterm`
     (commit `5baae32` is this exact file, and the clone keeps the history);
   - or copy `crossover/wezterm.lua` there.
4. **Port the Windows-shaped spots below,** one at a time. Prove each with
   `ls-fonts`, then have him look.
5. **Run "Checks on Linux".**

`/mnt/c` missing means the flip has happened. From then on, `CLAUDE.md`'s
"What is true now" and the WSL-boundary memory describe the old seat.
Rewriting them is part of the port.

## The snapshot

`crossover/wezterm.lua` is a byte-exact copy of the live config,
`C:\Users\Michael\.config\wezterm\wezterm.lua`.

| Copied | Lines | sha256 | Live repo at the time |
|---|---|---|---|
| 2026-10-28 | 1142 | `a749c103a1fca19449dac553833ae4e0b89d55c921cefb64c3d29eeb11642f7a` | last commit `6a96083` (2026-09-29), plus 135+/35− uncommitted |
| 2026-10-29 (re-checked, unchanged) | 1142 | same | committed and pushed as `5baae32` "pre flip commit"; GitHub's file has this same sha256 |

- **Never edit the snapshot.** The live file stays the truth until the
  crossover, and edits keep going there. The port happens on Linux, on its
  own copy at `~/.config/wezterm/wezterm.lua`.
- **Re-copy before crossing**, and whenever live has moved on. Then compare:
  `sha256sum crossover/wezterm.lua /mnt/c/Users/Michael/.config/wezterm/wezterm.lua`
- **Why it exists:** the `Wezterm` repo lives on the Windows disk, outside the
  WSL export. On 2026-10-28, GitHub had only `133b2ff` (2026-09-14). Michael
  pushed everything as `5baae32` on 2026-10-29 (checked with `git ls-remote`).
  So the config now has two copies that leave the machine: this snapshot,
  which rides the WSL export, and GitHub.

## Carries over unchanged (all inside wezterm.lua)

- **Colors.** The content palette (Cursor's terminal) and the chrome palette
  (Claude's Chrome theme) are written out in full, with no color scheme.
- **Tab bar, window frame, and tab titles** with the agent icons and colors.
  The icons come from Symbols Nerd Font Mono, which ships with WezTerm on
  every platform.
- **Agent picker:** ALT+A (new tab), ALT+SHIFT+A (split), ALT+R (resume).
  This is `read_roster` / `pick_agent`, which reads the agent files when a
  picker opens.
- **Window naming:** ALT+SHIFT+N.
- **Habits:**
  - highlighting copies (WezTerm's own default, nothing bound);
  - CTRL+V pastes;
  - CTRL+C copies if text is selected, interrupts if not;
  - right-click pastes;
  - SHIFT+ENTER is a newline.

## Windows-shaped spots

Line numbers are from the 2026-10-28 snapshot.

| # | Lines | What | On Linux |
|---|---|---|---|
| 1 | 7 | `default_domain = 'WSL:Ubuntu-24.04'` | Delete it: panes run locally. |
| 2 | 18–21, 159 | Consolas: terminal 12 pt, tab bar 11 pt | No change. Consolas is in `~/.local/share/fonts/consolas/` (ruling below). Check the size once the display scale is set. |
| 3 | 143–145 | Title buttons `'Windows'` | WezTerm draws these itself on any platform (wezterm.org integrated_title_button_style). Keep `'Windows'` for the same look, or switch to `'Gnome'`. |
| 4 | 215–217, 741, 748 | Roster paths: `\\wsl.localhost\...`, backslashes | Use `/home/bm/` and `/`. The match patterns already accept both separators. |
| 5 | 931–932, 1001 | `wezterm.exe` / `wezterm-gui.exe` for the CLI calls and ALT+N | `/usr/bin/wezterm` and `/usr/bin/wezterm-gui` (from the pinned .deb's file list). |
| 6 | 45 | `mux_output_parser_coalesce_delay_ms = 0`, the ConPTY flicker fix | Linux has no ConPTY. Harmless either way: keep it or drop it. |
| 7 | 987–1010 | One process per window, decided 2026-09-29 for Windows reasons | Re-check on Linux before keeping it. |

Comment-only mentions of Windows (the log path at 703, the taskbar at 862)
just need their text updated.

## Outside the lua, still part of "feels identical"

| Thing | Where | Note |
|---|---|---|
| Claude Code theme | `~/.claude/themes/chrome.json`; `"theme": "custom:chrome"` in `~/.claude/settings.json` | In the WSL home, so it travels with the export. |
| Inline-code sky blue | Palette `brights` slot 12, `#9EDBFF` | Claude Code's `dark-ansi` gives `permission` the terminal's bright blue, and the theme's olive override doesn't reach inline code. Measured `#9edbff` from Michael's screenshot, 2026-10-28. Keep slot 12. |
| Agents the picker reads | `~/repos/*/.claude/agents`, `~/Gungnir/.claude/agents`, `~/repos/*/.codex/config.toml` | Same paths, as long as home stays `/home/bm`. |
| WezTerm itself | `crossover/wezterm-nightly-20260929-cab25161/` (gitignored) | The same build as Windows, downloaded 2026-10-28. See "The WezTerm build" below. |
| Display scale | Ubuntu: Settings → Displays → Scale | Windows runs at **100%** (`AppliedDPI` = 96) on two 2560×1440 monitors, read 2026-10-28. Set Ubuntu to 100% too. |
| Window size | `initial_cols = 107`, `initial_rows = 42` (lines 194–195) | 107×42 cells: 986×857 px on Windows at 100%. The cell count carries over; the pixel size follows the font and scale. Position is the desktop's choice. |

## The WezTerm build

- **Pinned: `20260929-043349-cab25161`, the build Windows runs.** Celox's
  no-pre-release rule has exactly one exception of record, this build. "A
  newer nightly, or any other pre-release, is a fresh greenlight." A plain
  `sudo apt install wezterm-nightly` would pull the newest nightly instead
  (`20261026-082628-e68a8ec2` was the newest in the apt index on 2026-10-28).
- **Downloaded 2026-10-28** from WezTerm's apt repo, which keeps old builds:
  `https://apt.fury.io/wez/files/ver_2h7pV3/wezterm-nightly.Ubuntu22.04.deb`
  - 35,985,610 bytes. sha256
    `e7bc96d31ce845a0cdae46a625cbbd05174b1cc577f5c4b5bbe5dec94c23e9d7`, which
    matches the repo's `Packages` index.
  - `dpkg-deb -f` reads: `wezterm-nightly`, `20260929-043349-cab25161`, amd64.
  - It is the Ubuntu 22.04 build: the repo kept no 24.04 build of this commit.
    It is the same commit and version as the Windows zip, compiled against
    22.04's libraries. Dependencies proven 2026-10-28 by
    `apt-get -s install ./wezterm-nightly.Ubuntu22.04.deb` on Ubuntu 24.04.4
    (WSL): everything resolves from Ubuntu 24.04's own archive, adding four
    small X libraries (`libxcb-xkb1`, `libxkbcommon-x11-0`, `libxcb-util1`,
    `libxcb-image0`). That was a simulation; it runs for real once installed
    on the desktop.
- **Install (Michael's hand, celox prepares it):**
  `sudo apt install ./wezterm-nightly.Ubuntu22.04.deb`, from that folder. apt
  pulls the dependencies from Ubuntu. Leaving WezTerm's apt source out keeps
  upgrades from moving the pin; if the source is added anyway, run
  `apt-mark hold wezterm-nightly`.
- The GitHub `nightly` tag keeps only the latest build, so this file is the
  copy to keep. Nothing was installed in WSL.

## Rulings for Michael

- [x] Commit and push the `Wezterm` repo. Michael did, 2026-10-29: `5baae32`,
  which is on GitHub.
- [x] **The Linux font: Consolas, copied from Windows.** Michael's ruling,
  2026-10-28. This machine's Windows is OEM (its key is in the firmware), the
  same key will run a Windows VM on the Linux install, and the fonts stay on
  this machine and are never shared.
  - Copied to `~/.local/share/fonts/consolas/`, outside any git repo.
    **Never commit these files.**
  - Byte-identical to `C:\Windows\Fonts` (sha256):
    - `consola.ttf` `cf00b507b3286870cc5064ebd0633c303f70b491a4af25eec2d32df413db0179`
    - `consolab.ttf` `7e8de70c92a891722bd3fbd623db005caab2bfe267e5dab5be46b95a44e0c7f1`
    - `consolai.ttf` `0b5b0484cf69ae973bd39380069f141271a4c9299b8885fa2d13f42aadbefef9`
    - `consolaz.ttf` `9bc225ec52aa8f4b88b98bb735b1908bd72c9e31a12139fafcc1bd6c86bed3b4`
  - In WSL, `fc-match 'Consolas'` resolves Regular, Bold and Italic to these
    files.
  - The crossover must bring `~/.local/share/fonts` along. A whole-distro WSL
    export does; a copy of only `~/repos` would not.
  - Considered and set aside: buying it (MyFonts, $129 for the family), or a
    free font (Inconsolata, Cascadia Mono).
- [ ] Title buttons: `'Windows'` or `'Gnome'`.
- [ ] Install the pinned `cab25161` .deb (see "The WezTerm build").

## Checks on Linux, after the port

- [ ] `wezterm --config-file ~/.config/wezterm/wezterm.lua ls-fonts` exits 0.
  A file that fails to parse is silently replaced by WezTerm's defaults.
- [ ] Inline code is sky blue. Swatch: `printf '\e[94m  sky #9EDBFF  \e[0m\n'`
- [ ] `fc-match Consolas` names `consola.ttf`, and `ls-fonts --text Ag` shows
  the letters coming from `~/.local/share/fonts/consolas/`.
- [ ] Colors, tab bar, and agent icons all look right.
- [ ] ALT+A lists every agent. ALT+R opens the resume list.
- [ ] Highlight-to-copy, CTRL+V, CTRL+C, right-click and SHIFT+ENTER all work.
- [ ] SUPER+N is bound to a new window; check it against GNOME's own Super
  shortcuts. Unverified.

## For celox (flip/README.md §9)

Viper can't message celox; Michael carries this, or celox reads this file.

- **The Wezterm repo has no agent memory.** It tracks only `wezterm.lua`. The
  `.claude/agent-memory/viper/` folder beside it is empty, left over from
  2026-09-14. Viper's memory is `~/repos/Viper/.claude/`, which rides
  `/home/bm`.
- **Install the pinned .deb, not `apt install wezterm-nightly`.** See "The
  WezTerm build" above. It keeps WezTerm inside your exception of record.
- **The config also rides `/home/bm`** as `~/repos/Viper/crossover/wezterm.lua`,
  a byte-exact snapshot that gets re-copied before the export. GitHub's
  `Wezterm` has the same file: commit `5baae32`, pushed 2026-10-29.
- **Consolas** is in `~/.local/share/fonts/consolas/` (Michael's ruling,
  2026-10-28). It rides `~/.local`, which your spec already carries.
- **Display scale:** Windows is at 100%. Ubuntu should be set to match.

## Log

- **2026-10-28:** Ledger started. Snapshot copied (sha256 above). Inline-code
  blue confirmed as `#9edbff` from Michael's screenshot. Font confirmed with
  `ls-fonts`: ordinary text draws from `C:\WINDOWS\FONTS\CONSOLA.TTF`
  (Consolas, via DirectWrite), italics from Consolas Italic; only the icons
  come from the built-in font. Ruling: copy Consolas from Windows; the four
  files are in `~/.local/share/fonts/consolas/`, checksums match, and
  fontconfig sees them.
- **2026-10-28:** Pinned WezTerm `cab25161` .deb downloaded and verified
  (sha256 matches the apt index; the version read from the package). Windows
  scale read as 100%. Handoff for celox written.
- **2026-10-29:** Pre-flip check. Live, the snapshot and GitHub `5baae32` all
  have sha256 `a749c103…`. The .deb checksum and the four font files were
  re-checked. Wrote "Start here on Linux" and a memory pointing to this file,
  in case `--resume` fails. Michael's ruling: no second copy of the .deb or
  the fonts. The whole WSL distro comes across, and both can be recovered
  anyway (fonts from the Windows VM, the .deb from the apt.fury.io URL).
- **2026-10-30, on Linux** (Ubuntu 24.04.5, GNOME 46, Wayland). The .deb is
  installed. The config is cloned from `Wezterm` `5baae32` into
  `~/.config/wezterm`. Uncommitted edits there:
  - **Spot #1:** the WSL domain line is deleted.
  - **`enable_wayland = false`:** under native Wayland the window couldn't be
    moved (WezTerm bug on GNOME's compositor: #5332, #6025, #6296).
  - **`window_decorations = 'NONE'`:** under X11, `INTEGRATED_BUTTONS|RESIZE`
    made GNOME 46 add its white title bar, with buttons doubled. There is no
    X11 setting that keeps the tab-bar buttons without that bar.
  - **Spot #4:** the roster paths are now `wezterm.home_dir` with `/`.
    WezTerm's own glob reads 67 Claude agents and 14 Codex repos.
  - **Spot #5:** WezTerm now runs from `/usr/bin` (`executable_dir` reads
    `/usr/bin`). This covers ALT+N's new window and the gather picker's
    `wezterm cli`. Super+N is GNOME's (`focus-active-notification`), so
    WezTerm never sees it. ALT+N and CTRL+SHIFT+N work.
  - **The window keys** are Super+H or ALT+M to minimize, Super+Up and
    Super+Down to maximize and restore (Ubuntu's tiling extension), and
    Alt+F4 to close.
  - **Dropped:** building WezTerm with PR #8145 (an unmerged Wayland
    move/frame fix) was started, then dropped at Michael's word. The source
    checkout was deleted, and nothing was installed. He also ruled that it
    didn't need celox. Revisit if WezTerm merges #8145.
  - **Also tried and rejected:** native Wayland with `'TITLE'`. That gets
    WezTerm's own frame, a 24 px #3a3a3a strip with buttons and edge resize.
    Michael didn't like the strip. Chosen: X11 with `'NONE'`. Resizing is
    Super + right-drag: `gsettings set org.gnome.desktop.wm.preferences
    resize-with-right-button true`, set at his word. Undo with `gsettings
    reset` on the same key.
  - **Dock:** `dash-to-dock click-action 'previews'`, at his word. One
    click on the WezTerm icon shows thumbnails of its windows. It was
    `'focus-or-appspread'`, which he disliked. Not yet tried: Dash to Panel,
    for hover previews; it needs the Extension Manager install.
  - **Fonts:** terminal 13 (Windows 12), tab bar 12 (Windows 11), at his
    word.
  - **Closing:** `skip_close_confirmation_for_processes_named = {}`, so
    closing any tab or pane asks first, as on Windows.
  - **OPEN, his sudo:** auto-reload misses saves because the inotify watches
    are used up. Cursor holds 65,110 of the 65,536 allowed (that cap comes
    from `/usr/lib/sysctl.d/30-tracker.conf`). Fix:
    `/etc/sysctl.d/60-inotify-watches.conf` with
    `fs.inotify.max_user_watches = 524288`, then `sudo sysctl --system`.
    Until then, CTRL+SHIFT+R.
  - **Keyboard window switching** is Ubuntu's default: Alt+Tab for every
    window, Alt+` for one app's windows. He likes Alt+`.
  - **Minimize:** WezTerm's X11 Hide is an empty function in `cab25161`, so
    ALT+M did nothing. GNOME now does it:
    `wm.keybindings minimize ['<Super>h', '<Alt>m']`, at his word. Undo with
    `gsettings reset` on the same key.
