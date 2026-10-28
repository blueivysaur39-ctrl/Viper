local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ===========================================================================
-- Domain: panes spawn inside WSL2; this config itself is read by Windows.
-- ===========================================================================
config.default_domain = 'WSL:Ubuntu-24.04'

-- ===========================================================================
-- FONT -- Consolas, which is what Cursor's terminal has always used: VS Code
-- leaves terminal.integrated.fontFamily unset, so it inherits editor.fontFamily,
-- whose Windows default is "Consolas, 'Courier New', monospace".
--
-- VS Code sizes in pixels, WezTerm in points: 14px = 10.5pt at 96dpi.
-- Symbols Nerd Font Mono is bundled with WezTerm and catches the glyphs
-- Consolas lacks -- the spinners and icons Claude Code draws.
-- ===========================================================================
config.font = wezterm.font_with_fallback {
  'Consolas',
  'Symbols Nerd Font Mono',
}
config.font_size = 12.0

-- ===========================================================================
-- CURSOR
--
-- WezTerm eases the cursor in and out rather than blinking it outright, and
-- that fade compounds with an agent redrawing its spinner into visible
-- flicker. animation_fps = 1 with Constant easing is the documented cure:
-- instant on, instant off, no tweening. Kill blinking altogether with
-- cursor_blink_rate = 0.
-- ===========================================================================
config.animation_fps = 1
config.cursor_blink_ease_in = 'Constant'
config.cursor_blink_ease_out = 'Constant'
config.cursor_blink_rate = 0     -- no blinking at all; steady block

-- The cursor flash while Claude thinks is NOT blinking. Measured 2026-09-16:
-- the conpty.dll bundled with this build rewrites every Claude frame as
--   hide-cursor, sync-begin, sync-end, draw, show-cursor
-- and WezTerm puts everything before a sync-begin on screen at once, so
-- the hidden cursor is drawn; the rest, show-cursor included, then waits out
-- this coalescing delay (default 3ms). 0 = no wait, no visible gap.
-- Since 20220903 (changelog). Revert = delete this line.
config.mux_output_parser_coalesce_delay_ms = 0

-- ===========================================================================
-- COLORS -- two palettes, on purpose.
--
--   CONTENT (what programs print) = Michael's Cursor terminal, exactly.
--     Source: Cursor settings.json workbench.colorCustomizations for the four
--     he overrode, plus Cursor's own built-in defaults for the twelve he never
--     set (read out of workbench.desktop.main.js, 2026-09-14).
--
--   CHROME (tab bar, cursor, selection, split lines) = Claude Code's
--     "Chrome (Side7 Warm Theater)" theme, ~/.claude/themes/chrome.json.
--     The frame matches the agent UI living inside it.
--
-- No color_scheme line: every color below is stated outright, so nothing
-- arrives from a scheme we did not choose.
-- ===========================================================================
config.colors = {
  foreground = '#D4D4D4',  -- Cursor: terminal.foreground
  background = '#1E1E1E',  -- Cursor: editor background, dark theme

  --        MINE = set by hand in Cursor    VSC = Cursor's built-in default
  ansi = {
    '#000000',  -- 0 black        VSC
    '#cc4040',  -- 1 red          MINE
    '#80d467',  -- 2 green        MINE
    '#e5e510',  -- 3 yellow       VSC
    '#2472c8',  -- 4 blue         VSC
    '#bc3fbc',  -- 5 magenta      VSC
    '#7f95b8',  -- 6 cyan         MINE
    '#e5e5e5',  -- 7 white        VSC
  },
  brights = {
    '#666666',  -- 8  bright black    VSC
    '#f14c4c',  -- 9  bright red      VSC
    '#23d18b',  -- 10 bright green    VSC
    '#f5f543',  -- 11 bright yellow   VSC
    '#9EDBFF',  -- 12 bright blue     MINE
    '#d670d6',  -- 13 bright magenta  VSC
    '#29b8db',  -- 14 bright cyan     VSC
    '#e5e5e5',  -- 15 bright white    VSC
  },

  -- Cursor block: warm sand, from Claude's claudeShimmer.
  -- PROVEN 2026-09-16: no hollow cursor in the active pane on this build.
  -- cursor_border only colors the outline in INACTIVE panes; the active
  -- block is all cursor_bg, so cursor_bg = background makes it vanish.
  cursor_bg = '#bbbda4',
  cursor_fg = '#171817',
  cursor_border = '#bbbda4',

  -- Leader-key cue: the cursor turns olive while LEADER is armed.
  compose_cursor = '#a6a487',  -- Claude: permission

  selection_bg = '#3a3a32',  -- Claude: selectionBg
  selection_fg = '#e2ded6',  -- Claude: suggestion

  split = '#716e69',           -- Claude: bashBorder -- the line between panes
  scrollbar_thumb = '#3c3b38', -- Claude: rate_limit_empty

  -- Tab bar. Active tab is deliberately the lightest thing in the bar.
  tab_bar = {
    background = '#171817',                              -- Claude: inverseText
    -- Flipped: the active tab sits flush with the bar, unlit. The grey plate
    -- is what marks a tab as NOT the one you are in.
    active_tab   = { bg_color = '#171817', fg_color = '#e2ded6', intensity = 'Bold' },
    inactive_tab = { bg_color = '#2c2c2a', fg_color = '#85827d' },
    inactive_tab_hover = { bg_color = '#2c2c2a', fg_color = '#aaa69f', italic = false },
    new_tab       = { bg_color = '#20211f', fg_color = '#5d5b58' },
    new_tab_hover = { bg_color = '#353532', fg_color = '#e2ded6' },
    inactive_tab_edge = '#2c2c2a',                       -- seam between tabs
  },
}

-- ===========================================================================
-- WINDOW FRAME
--
-- RETRO tab bar + no title bar.
--
-- The retro bar is drawn as a row of the terminal's own grid, inside the
-- window. The FANCY bar is drawn in the titlebar region -- so on Windows,
-- removing the titlebar left it nowhere to draw and it vanished, taking the
-- integrated buttons with it (tried twice, 2026-09-14).
--
-- RESIZE = keep resizable edges, drop the Windows title bar. That bar is
-- painted white by Windows itself (Light app mode, AppsUseLightTheme = 0x1)
-- and no option on this stable build can recolor it -- so it goes.
--
-- With no title bar there are no window buttons. Use:
--   CTRL+SHIFT+M   minimize        ALT+ENTER      full screen
--   CTRL+SHIFT+drag anywhere       move the window
-- ===========================================================================
-- EXPERIMENT 2026-09-14: fancy bar + plain RESIZE. The two earlier failures
-- (tab bar invisible) both had INTEGRATED_BUTTONS as well, so the buttons were
-- never ruled out as the cause. The fancy bar draws tabs as rounded buttons
-- with vertical space around them -- breathing room the retro bar cannot give.
-- Revert = set this back to false.
config.use_fancy_tab_bar = true
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.integrated_title_button_style = 'Windows'
config.integrated_title_buttons = { 'Hide', 'Maximize', 'Close' }
-- Resting color of those three glyphs. Default 'Auto' computes its own (white
-- on a dark bar) and ignores window_frame.button_fg, which only covers hover.
config.integrated_title_button_color = '#85827d'
config.tab_max_width = 28          -- retro bar only; no effect while fancy

-- Belt and braces: the tab bar is always on, even at a single tab.
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false

-- window_frame styles the FANCY bar: its height follows font_size.
config.window_frame = {
  -- Consolas to match the terminal (WezTerm's default here is proportional
  -- Roboto). Symbols Nerd Font Mono behind it carries the agent icons.
  font = wezterm.font_with_fallback { 'Consolas', 'Symbols Nerd Font Mono' },
  font_size = 11.0,                    -- Windows default is 10
  active_titlebar_bg = '#171817',      -- the bar itself, focused
  inactive_titlebar_bg = '#171817',    -- and unfocused -- same, no flicker

  -- Integrated minimize / maximize / close. Smoked grey at rest, lighting up
  -- under the pointer so they are findable without shouting.
  button_fg = '#85827d',               -- Claude: inactive
  button_bg = '#171817',               -- same as the bar: no button plates
  button_hover_fg = '#e2ded6',         -- Claude: suggestion
  button_hover_bg = '#353532',         -- Claude: userMessageBackgroundHover

  -- PROVEN 2026-09-14: this is what buys breathing room ABOVE the tabs on
  -- Windows, despite the docs calling borders "primarily for Wayland client-
  -- side decorations". Colored to match the bar so it reads as one surface.
  border_top_height = '6px',
  border_top_color = '#171817',
}

-- Padding. PROVEN 2026-09-14: top padding lands BETWEEN the tab bar and the
-- terminal content -- it does not push the retro tab bar down. The retro bar
-- is welded to the window's top edge. Left at the defaults; do not retry this
-- lever for breathing room above the tabs.
config.window_padding = {
  left = '1cell',
  right = '1cell',
  top = '0.5cell',
  bottom = '0.5cell',
}

-- Window size at launch, in character cells. 107 x 42 at font_size 12 is a
-- 986 x 857 px window -- measured off Michael's screenshot 2026-09-16 (cells
-- are 9 x 19 px). Every NEW window opens at this size, ALT+N included; open
-- windows are left alone. Change font_size and the pixel size follows.
-- No position: Windows decides where it lands.
config.initial_cols = 107
config.initial_rows = 42

-- ===========================================================================
-- AGENT ROSTER
--
-- Truth is ~/repos/*/.claude/agents/*.md, plus the same folder in each of
-- HOME_REPOS -- every agent that exists appears in the ALT+A picker, listed
-- below or not. How its tab looks comes from
-- AGENT_LOOKS: one line per agent, all of them in this one place. An agent
-- with no line gets a plain dot, in a color picked from its own name.
--
-- LOADING THIS FILE READS NOTHING BUT THIS FILE. The agent files sit across
-- the WSL bridge (\\wsl.localhost), and WezTerm holds its config lock for the
-- whole of a load -- the lock every window takes to draw (config/src/lib.rs,
-- nightly cab25161). A bridge that stalls during a reload would freeze the
-- whole process. So the roster is read when a picker opens -- ALT+A,
-- ALT+SHIFT+A, ALT+R -- by wezterm.glob, which runs on a worker thread: a
-- slow bridge delays the picker, never the window. Read once per load; after
-- adding an agent, CTRL+SHIFT+R and the next picker sees it.
-- ===========================================================================
local WSL_HOME = '\\\\wsl.localhost\\Ubuntu-24.04\\home\\bm\\'
local WSL = WSL_HOME .. 'repos\\'
local AGENTS_GLOB = WSL .. '*\\.claude\\agents\\*.md'

-- Repos that live in ~ itself, not ~/repos. Read the same way: every agent
-- in the repo's .claude/agents appears as "<repo>/<agent>" and starts in
-- ~/<repo>. One glob each. Gungnir is celox's, since 2026-10-18 -- before
-- that he was a user-level agent, "universal/celox", started in ~/repos.
local HOME_REPOS = { 'Gungnir' }

-- Codex seats: one resident per repo, defined by that repo's
-- .codex/config.toml. Plain `codex` started in the repo becomes them -- there
-- is no per-agent flag -- so the key names the resident and its repo. Listed
-- only while that config.toml exists. ALT+R runs `codex resume`, whose
-- picker shows this repo's sessions.
local CODEX_SEATS = {
  'AAA_Wunder/sears',
  'Ark/aramaki',
  'Ghostline_02/0xWIRE',
  'Nerv_Branch01/tomcat',
  'Nerv_Branch02/coke',
  'Project2502/caliper',
  'Project2503/neuromancer',
  'Project2505/metron',
  'SEELE_02/anvil',
  'SEELE_03/klinker',
  'SEELE_04/flask',
}

-- Colors by name -- the same hexes as the palette above.
local COLOR_NAMES = {
  red = '#cc4040', green = '#80d467', yellow = '#f5f543', blue = '#9EDBFF',
  magenta = '#d670d6', cyan = '#29b8db', white = '#e5e5e5',
}

-- ---------------------------------------------------------------------------
-- ICONS -- every name here draws exactly its own glyph, and nothing else can.
--
-- CODICONS is VS Code's icon set as it exists in the Symbols Nerd Font Mono
-- bundled with this build: U+EA60..U+EBEB, 388 glyphs, under VS Code's names
-- (hyphens are underscores here; AGENT_LOOKS takes either). Built 2026-09-29
-- from `wezterm ls-fonts --text` over the whole range -- the font's own
-- glyph names -- checked against Nerd Fonts' glyphnames.json. Codicons newer
-- than this font (map, target, vr, ...) are left out on purpose: they would
-- draw as an empty box. Browse the set by name:
-- https://microsoft.github.io/vscode-codicons/dist/codicon.html
-- ---------------------------------------------------------------------------
local CODICONS = {
  account='\u{eb99}', activate_breakpoints='\u{ea97}', add='\u{ea60}',
  archive='\u{ea98}', arrow_both='\u{ea99}', arrow_down='\u{ea9a}',
  arrow_left='\u{ea9b}', arrow_right='\u{ea9c}', arrow_small_down='\u{ea9d}',
  arrow_small_left='\u{ea9e}', arrow_small_right='\u{ea9f}',
  arrow_small_up='\u{eaa0}', arrow_swap='\u{ebcb}', arrow_up='\u{eaa1}',
  azure='\u{ebd8}', azure_devops='\u{ebe8}', beaker='\u{ea79}',
  beaker_stop='\u{ebe1}', bell='\u{eaa2}', bell_dot='\u{eb9a}',
  bold='\u{eaa3}', book='\u{eaa4}', bookmark='\u{eaa5}',
  bracket_dot='\u{ebe5}', bracket_error='\u{ebe6}', briefcase='\u{eaac}',
  broadcast='\u{eaad}', browser='\u{eaae}', bug='\u{eaaf}',
  calendar='\u{eab0}', call_incoming='\u{eb92}', call_outgoing='\u{eb93}',
  case_sensitive='\u{eab1}', check='\u{eab2}', check_all='\u{ebb1}',
  checklist='\u{eab3}', chevron_down='\u{eab4}', chevron_left='\u{eab5}',
  chevron_right='\u{eab6}', chevron_up='\u{eab7}', chrome_close='\u{eab8}',
  chrome_maximize='\u{eab9}', chrome_minimize='\u{eaba}',
  chrome_restore='\u{eabb}', circle='\u{eabc}', circle_filled='\u{ea71}',
  circle_large='\u{ebb5}', circle_large_filled='\u{ebb4}',
  circle_large_outline='\u{ebb5}', circle_outline='\u{eabc}',
  circle_slash='\u{eabd}', circle_small_filled='\u{eb8a}',
  circuit_board='\u{eabe}', clear_all='\u{eabf}', clippy='\u{eac0}',
  close='\u{ea76}', close_all='\u{eac1}', cloud='\u{ebaa}',
  cloud_download='\u{eac2}', cloud_upload='\u{eac3}', code='\u{eac4}',
  collapse_all='\u{eac5}', color_mode='\u{eac6}', combine='\u{ebb6}',
  comment='\u{ea6b}', comment_discussion='\u{eac7}', compass='\u{ebd5}',
  compass_active='\u{ebd7}', compass_dot='\u{ebd6}', copy='\u{ebcc}',
  credit_card='\u{eac9}', dash='\u{eacc}', dashboard='\u{eacd}',
  database='\u{eace}', debug='\u{ead8}', debug_all='\u{ebdc}',
  debug_alt='\u{eb91}', debug_alt_small='\u{eba8}',
  debug_breakpoint_conditional='\u{eaa7}',
  debug_breakpoint_conditional_unverified='\u{eaa6}',
  debug_breakpoint_data='\u{eaa9}',
  debug_breakpoint_data_unverified='\u{eaa8}',
  debug_breakpoint_function='\u{eb88}',
  debug_breakpoint_function_unverified='\u{eb87}',
  debug_breakpoint_log='\u{eaab}', debug_breakpoint_log_unverified='\u{eaaa}',
  debug_breakpoint_unsupported='\u{eb8c}', debug_console='\u{eb9b}',
  debug_continue='\u{eacf}', debug_continue_small='\u{ebe0}',
  debug_coverage='\u{ebdd}', debug_disconnect='\u{ead0}',
  debug_line_by_line='\u{ebd0}', debug_pause='\u{ead1}',
  debug_rerun='\u{ebc0}', debug_restart='\u{ead2}',
  debug_restart_frame='\u{eb90}', debug_reverse_continue='\u{eb8e}',
  debug_stackframe='\u{eb8b}', debug_stackframe_active='\u{eb89}',
  debug_stackframe_dot='\u{eb8a}', debug_start='\u{ead3}',
  debug_step_back='\u{eb8f}', debug_step_into='\u{ead4}',
  debug_step_out='\u{ead5}', debug_step_over='\u{ead6}',
  debug_stop='\u{ead7}', desktop_download='\u{ea78}',
  device_camera='\u{eada}', device_camera_video='\u{ead9}',
  device_mobile='\u{eadb}', diff='\u{eae1}', diff_added='\u{eadc}',
  diff_ignored='\u{eadd}', diff_modified='\u{eade}', diff_removed='\u{eadf}',
  diff_renamed='\u{eae0}', discard='\u{eae2}', edit='\u{ea73}',
  editor_layout='\u{eae3}', ellipsis='\u{ea7c}', empty_window='\u{eae4}',
  error='\u{ea87}', exclude='\u{eae5}', expand_all='\u{eb95}',
  export='\u{ebac}', extensions='\u{eae6}', eye='\u{ea70}',
  eye_closed='\u{eae7}', feedback='\u{eb96}', file='\u{ea7b}',
  file_binary='\u{eae8}', file_code='\u{eae9}', file_media='\u{eaea}',
  file_pdf='\u{eaeb}', file_submodule='\u{eaec}',
  file_symlink_directory='\u{eaed}', file_symlink_file='\u{eaee}',
  file_zip='\u{eaef}', files='\u{eaf0}', filter='\u{eaf1}',
  filter_filled='\u{ebce}', flame='\u{eaf2}', fold='\u{eaf5}',
  fold_down='\u{eaf3}', fold_up='\u{eaf4}', folder='\u{ea83}',
  folder_active='\u{eaf6}', folder_library='\u{ebdf}',
  folder_opened='\u{eaf7}', gear='\u{eaf8}', gift='\u{eaf9}', gist='\u{eafb}',
  gist_secret='\u{eafa}', git_commit='\u{eafc}', git_compare='\u{eafd}',
  git_merge='\u{eafe}', git_pull_request='\u{ea64}',
  git_pull_request_closed='\u{ebda}', git_pull_request_create='\u{ebbc}',
  git_pull_request_draft='\u{ebdb}', github='\u{ea84}',
  github_action='\u{eaff}', github_alt='\u{eb00}', github_inverted='\u{eba1}',
  globe='\u{eb01}', go_to_file='\u{ea94}', grabber='\u{eb02}',
  graph='\u{eb03}', graph_left='\u{ebad}', graph_line='\u{ebe2}',
  graph_scatter='\u{ebe3}', gripper='\u{eb04}', group_by_ref_type='\u{eb97}',
  heart='\u{eb05}', history='\u{ea82}', home='\u{eb06}',
  horizontal_rule='\u{eb07}', hubot='\u{eb08}', inbox='\u{eb09}',
  info='\u{ea74}', inspect='\u{ebd1}', issue_draft='\u{ebd9}',
  issue_reopened='\u{eb0b}', issues='\u{eb0c}', italic='\u{eb0d}',
  jersey='\u{eb0e}', json='\u{eb0f}', kebab_vertical='\u{eb10}',
  key='\u{eb11}', law='\u{eb12}', layers='\u{ebd2}', layers_active='\u{ebd4}',
  layers_dot='\u{ebd3}', layout='\u{ebeb}', library='\u{eb9c}',
  lightbulb='\u{ea61}', lightbulb_autofix='\u{eb13}', link='\u{eb15}',
  link_external='\u{eb14}', list_filter='\u{eb83}', list_flat='\u{eb84}',
  list_ordered='\u{eb16}', list_selection='\u{eb85}', list_tree='\u{eb86}',
  list_unordered='\u{eb17}', live_share='\u{eb18}', loading='\u{eb19}',
  location='\u{eb1a}', lock='\u{ea75}', lock_small='\u{ebe7}',
  magnet='\u{ebae}', mail='\u{eb1c}', mail_read='\u{eb1b}',
  markdown='\u{eb1d}', megaphone='\u{eb1e}', mention='\u{eb1f}',
  menu='\u{eb94}', merge='\u{ebab}', milestone='\u{eb20}', mirror='\u{ea69}',
  mortar_board='\u{eb21}', move='\u{eb22}', multiple_windows='\u{eb23}',
  mute='\u{eb24}', new_file='\u{ea7f}', new_folder='\u{ea80}',
  newline='\u{ebea}', no_newline='\u{eb25}', note='\u{eb26}',
  notebook='\u{ebaf}', notebook_template='\u{ebbf}', octoface='\u{eb27}',
  open_preview='\u{eb28}', organization='\u{ea7e}', output='\u{eb9d}',
  package='\u{eb29}', paintcan='\u{eb2a}', pass='\u{eba4}',
  pass_filled='\u{ebb3}', person='\u{ea67}', person_add='\u{ebcd}',
  pie_chart='\u{ebe4}', pin='\u{eb2b}', pinned='\u{eba0}',
  pinned_dirty='\u{ebb2}', play='\u{eb2c}', play_circle='\u{eba6}',
  plug='\u{eb2d}', preserve_case='\u{eb2e}', preview='\u{eb2f}',
  primitive_square='\u{ea72}', project='\u{eb30}', pulse='\u{eb31}',
  question='\u{eb32}', quote='\u{eb33}', radio_tower='\u{eb34}',
  reactions='\u{eb35}', record='\u{eba7}', record_keys='\u{ea65}',
  redo='\u{ebb0}', references='\u{eb36}', refresh='\u{eb37}',
  regex='\u{eb38}', remote='\u{eb3a}', remote_explorer='\u{eb39}',
  remove='\u{eb3b}', replace='\u{eb3d}', replace_all='\u{eb3c}',
  reply='\u{ea7d}', repo='\u{ea62}', repo_clone='\u{eb3e}',
  repo_force_push='\u{eb3f}', repo_forked='\u{ea63}', repo_pull='\u{eb40}',
  repo_push='\u{eb41}', report='\u{eb42}', request_changes='\u{eb43}',
  rocket='\u{eb44}', root_folder='\u{eb46}', root_folder_opened='\u{eb45}',
  rss='\u{eb47}', ruby='\u{eb48}', run_above='\u{ebbd}', run_all='\u{eb9e}',
  run_below='\u{ebbe}', run_errors='\u{ebde}', save='\u{eb4b}',
  save_all='\u{eb49}', save_as='\u{eb4a}', screen_full='\u{eb4c}',
  screen_normal='\u{eb4d}', search='\u{ea6d}', search_stop='\u{eb4e}',
  server='\u{eb50}', server_environment='\u{eba3}', server_process='\u{eba2}',
  settings='\u{eb52}', settings_gear='\u{eb51}', shield='\u{eb53}',
  sign_in='\u{ea6f}', sign_out='\u{ea6e}', smiley='\u{eb54}',
  sort_precedence='\u{eb55}', source_control='\u{ea68}',
  split_horizontal='\u{eb56}', split_vertical='\u{eb57}', squirrel='\u{eb58}',
  star_empty='\u{ea6a}', star_full='\u{eb59}', star_half='\u{eb5a}',
  stop_circle='\u{eba5}', symbol_array='\u{ea8a}', symbol_boolean='\u{ea8f}',
  symbol_class='\u{eb5b}', symbol_color='\u{eb5c}',
  symbol_constant='\u{eb5d}', symbol_enum='\u{ea95}',
  symbol_enum_member='\u{eb5e}', symbol_event='\u{ea86}',
  symbol_field='\u{eb5f}', symbol_file='\u{eb60}',
  symbol_interface='\u{eb61}', symbol_key='\u{ea93}',
  symbol_keyword='\u{eb62}', symbol_method='\u{ea8c}', symbol_misc='\u{eb63}',
  symbol_namespace='\u{ea8b}', symbol_numeric='\u{ea90}',
  symbol_operator='\u{eb64}', symbol_parameter='\u{ea92}',
  symbol_property='\u{eb65}', symbol_ruler='\u{ea96}',
  symbol_snippet='\u{eb66}', symbol_string='\u{eb8d}',
  symbol_structure='\u{ea91}', symbol_variable='\u{ea88}', sync='\u{ea77}',
  sync_ignored='\u{eb9f}', table='\u{ebb7}', tag='\u{ea66}',
  tasklist='\u{eb67}', telescope='\u{eb68}', terminal='\u{ea85}',
  terminal_bash='\u{ebca}', terminal_cmd='\u{ebc4}',
  terminal_debian='\u{ebc5}', terminal_linux='\u{ebc6}',
  terminal_powershell='\u{ebc7}', terminal_tmux='\u{ebc8}',
  terminal_ubuntu='\u{ebc9}', text_size='\u{eb69}', three_bars='\u{eb6a}',
  thumbsdown='\u{eb6b}', thumbsup='\u{eb6c}', tools='\u{eb6d}',
  trash='\u{ea81}', triangle_down='\u{eb6e}', triangle_left='\u{eb6f}',
  triangle_right='\u{eb70}', triangle_up='\u{eb71}', twitter='\u{eb72}',
  type_hierarchy='\u{ebb9}', type_hierarchy_sub='\u{ebba}',
  type_hierarchy_super='\u{ebbb}', unfold='\u{eb73}',
  ungroup_by_ref_type='\u{eb98}', unlock='\u{eb74}', unmute='\u{eb75}',
  unverified='\u{eb76}', variable_group='\u{ebb8}', verified='\u{eb77}',
  verified_filled='\u{ebe9}', versions='\u{eb78}', vm='\u{ea7a}',
  vm_active='\u{eb79}', vm_connect='\u{eba9}', vm_outline='\u{eb7a}',
  vm_running='\u{eb7b}', wand='\u{ebcf}', warning='\u{ea6c}',
  watch='\u{eb7c}', whitespace='\u{eb7d}', whole_word='\u{eb7e}',
  window='\u{eb7f}', word_wrap='\u{eb80}', workspace_trusted='\u{ebc1}',
  workspace_unknown='\u{ebc3}', workspace_untrusted='\u{ebc2}',
  zoom_in='\u{eb81}', zoom_out='\u{eb82}',
}

-- Extras from the Font Awesome (nf-fa-*), Material Design (nf-md-*) and
-- Octicons (nf-oct-*) sets in the same bundled font, each proven to draw on
-- 2026-09-29. Octicons are GitHub's, closest in style to codicons. To add one:
-- take its name from nerdfonts.com/cheat-sheet, check that
--   wezterm ls-fonts --text <glyph>
-- says it comes from "Symbols Nerd Font Mono", then add a line here.
local EXTRA_ICONS = {
  anchor = '\u{f13d}', ship = '\u{f21a}',
  helm = '\u{f0833}',           -- md ship_wheel
  bolt = '\u{f0e7}', crosshairs = '\u{f05b}', cube = '\u{f1b2}',
  crown = '\u{f01a5}',          -- md
  flask = '\u{f0c3}', gavel = '\u{f0e3}', map = '\u{f279}', sun = '\u{f185}',
  snake = '\u{f150e}',          -- md; the codicon snake is newer than this font
  strikethrough = '\u{f521}',   -- oct; so is the codicon strikethrough
  jet_fighter = '\u{f0fb}',     -- fa
  spider = '\u{f11ea}',         -- md
  soda = '\u{f1071}',           -- md bottle_soda_classic: the contour bottle
  bird = '\u{f15c6}',           -- md; stands in for a raven
  brain = '\u{f09d1}',          -- md
  snowflake = '\u{f0717}',      -- md
  microscope = '\u{f0654}',     -- md
}

local NO_ICON = '\u{ea71}'   -- circle-filled: an agent with no line below
local BAD_ICON = '?'         -- a name found in neither table, drawn in red

-- ---------------------------------------------------------------------------
-- AGENT_LOOKS -- the one list. Key is "repo/agent", as in the ALT+A picker.
--   icon   a name from CODICONS or EXTRA_ICONS
--   color  a name from COLOR_NAMES, or any '#rrggbb'
-- A misspelled icon shows as a red ? on its tab; a bad color falls back to
-- the agent's own. Both are logged -- CTRL+SHIFT+L opens the debug overlay.
--
-- Seeded 2026-09-29 from the Cursor profiles in each repo's .vscode, which
-- are no longer read. Where Cursor's name has no glyph in this font, the
-- nearest one that does: brush -> paintcan, pencil -> edit, star ->
-- star-empty, target -> crosshairs, vr -> cube, hammer -> gavel, zap -> bolt.
-- ---------------------------------------------------------------------------
local AGENT_LOOKS = {
  ['AAA_Wunder/hornet']        = { icon = 'repo-force-push', color = 'yellow' },
  ['AAA_Wunder/saratoga']      = { icon = 'paintcan',        color = 'red' },
  ['AAA_Wunder/sears']         = { icon = 'strikethrough',   color = '#3fbf9f' }, -- codex; sea green
  ['AAA_Wunder/wildcat']       = { icon = 'shield',          color = 'green' },

  -- Chief of Section 9, the Ark's delegation hub: the org chart. Olive for
  -- his army years -- and a gap on this bar, measured 2026-10-13.
  ['Ark/aramaki']              = { icon = 'organization',    color = '#a6b16e' }, -- codex
  ['Ark/cartographer']         = { icon = 'map',             color = 'blue' },
  ['Ark/gendo']                = { icon = 'eye',             color = 'magenta' },

  ['Armament_Grid/hazop']      = { icon = 'radio-tower',     color = 'green' },
  ['Armament_Grid/misato']     = { icon = 'crosshairs',      color = 'red' },
  ['Armament_Grid/venator']    = { icon = 'move',            color = 'yellow' },

  ['Geburah/ritsuko-3']        = { icon = 'flame',           color = 'red' },
  ['Geburah/sofer']            = { icon = 'edit',            color = 'cyan' },

  -- Ghostline_02. Bluebox is the phreaker's box, an in-band tone: a pulse,
  -- in blue. Vblank is the gap between frames: a monitor, in CRT phosphor
  -- green. 0xWIRE takes the plug, and lilac -- the widest gap left on this
  -- bar. Colors measured 2026-10-16. All three moved from Ghostline_01:
  -- 0xWIRE 2026-10-23, Bluebox and Vblank 2026-10-26.
  ['Ghostline_02/0xWIRE']      = { icon = 'plug',            color = '#e2b6fb' }, -- codex
  ['Ghostline_02/bluebox']     = { icon = 'pulse',           color = '#63b0fa' },
  ['Ghostline_02/vblank']      = { icon = 'vm',              color = '#68e9a5' },

  ['Gungnir/celox']            = { icon = 'terminal-bash',   color = '#f0a04b' },
  -- The fleet's supply line, commit to wheel to running process: a package.
  -- Vermilion, the legion's red, and a gap on this bar, measured 2026-10-19.
  ['Gungnir/centurion']        = { icon = 'package',         color = '#fe8c65' },
  -- Odin's raven of memory: the system's memory. Ice, the blue sheen on a
  -- raven's black -- and the widest gap left on this bar, 2026-10-22.
  ['Gungnir/muninn']           = { icon = 'bird',            color = '#65e4e9' },

  ['HALO/orbital']             = { icon = 'telescope',       color = 'cyan' },
  ['HALO/reaper']              = { icon = 'squirrel',        color = 'yellow' },

  ['Magi_1/balthasar-2']       = { icon = 'bold',            color = 'blue' },
  ['Magi_1/casper-3']          = { icon = 'remote',          color = 'magenta' },
  ['Magi_1/melchior-1']        = { icon = 'beaker',          color = 'green' },

  ['Nerv_Branch01/hopper']     = { icon = 'bug',             color = 'cyan' },
  ['Nerv_Branch01/knox']       = { icon = 'anchor',          color = 'yellow' },
  ['Nerv_Branch01/lexington']  = { icon = 'ship',            color = 'blue' },
  ['Nerv_Branch01/phantom']    = { icon = 'circuit-board',   color = 'green' },
  ['Nerv_Branch01/sampson']    = { icon = 'helm',            color = 'magenta' },
  ['Nerv_Branch01/tomcat']     = { icon = 'github',          color = '#f5b731' }, -- codex; ginger tabby

  -- Branch-01's MAGI, the second trinity: each wears its Magi_1 namesake's
  -- hue family, shifted into a gap on this bar (measured 2026-10-25).
  -- Melchior-4 the Scientist, measurement: a microscope. Balthasar-5 the
  -- Mother, the halt: stop. Casper-6 the Woman, the push: play.
  ['Nerv_Branch01/melchior-4'] = { icon = 'microscope',      color = '#b5e850' },
  ['Nerv_Branch01/balthasar-5'] = { icon = 'stop-circle',     color = '#b1c6fa' },
  ['Nerv_Branch01/casper-6']   = { icon = 'play',            color = '#c397fb' },

  -- Hellcat a fighter; Widow the spider the P-61 was named for; Coke the
  -- bottle (first tried as 'verified', his independent check). Colors: the
  -- three widest gaps left on this bar, measured 2026-10-20 -- the sand one
  -- went to Coke, as caramel.
  ['Nerv_Branch02/coke']       = { icon = 'soda',            color = '#f0cd8e' }, -- codex
  ['Nerv_Branch02/hellcat']    = { icon = 'jet-fighter',     color = '#a4b43e' },
  ['Nerv_Branch02/widow']      = { icon = 'spider',          color = '#deb5cf' },

  ['Nerv_Branch03/kyoko']      = { icon = 'star-empty',      color = 'red' },
  ['Nerv_Branch03/langley']    = { icon = 'paintcan',        color = 'green' },
  ['Nerv_Branch03/vashti']     = { icon = 'octoface',        color = 'blue' },

  ['Nerv_HQ/alaya']            = { icon = 'book',            color = 'blue' },
  ['Nerv_HQ/kanuka']           = { icon = 'rocket',          color = 'green' },
  ['Nerv_HQ/ritsuko']          = { icon = 'flame',           color = 'magenta' },

  ['Pribnow_Box/alice']        = { icon = 'cube',            color = 'blue' },
  ['Pribnow_Box/anaheim']      = { icon = 'tools',           color = 'green' },

  -- Caliper, Metron's twin: a span between two jaws, the
  -- dimension line. Copper, the instrument-maker's metal -- and the widest
  -- gap left on this bar once Metron and Aramaki were in, 2026-10-16.
  ['Project2502/caliper']      = { icon = 'arrow-both',      color = '#de9c81' }, -- codex

  -- Gibson's pair, two halves of one AI: Wintermute a snowflake in frost,
  -- Neuromancer a brain in neon pink -- near-opposite hues, both gaps on
  -- this bar, measured 2026-10-23.
  ['Project2503/neuromancer']  = { icon = 'brain',           color = '#fc82c7' }, -- codex
  ['Project2503/wintermute']   = { icon = 'snowflake',       color = '#b1e4b3' },

  -- Metron, Greek for measure: a ruler. The rose was measured too -- of every
  -- color that stays readable on an unfocused tab, the one farthest (CIELAB)
  -- from all the others on this bar, 2026-10-13. Moved from Project2501,
  -- 2026-10-23.
  ['Project2505/metron']       = { icon = 'symbol-ruler',    color = '#fa99b7' }, -- codex

  ['S2_Engine/alkahest']       = { icon = 'flame',           color = 'red' },
  ['S2_Engine/amestris']       = { icon = 'crown',           color = '#6f8ff5' }, -- Achaemenid lapis
  ['S2_Engine/hawkeye']        = { icon = 'eye',             color = 'yellow' },
  ['S2_Engine/hohenheim']      = { icon = 'beaker',          color = 'blue' },
  ['S2_Engine/hummingbird']    = { icon = 'twitter',         color = 'green' },   -- the codicon bird
  ['S2_Engine/sheska']         = { icon = 'book',            color = 'magenta' },
  ['S2_Engine/tensor']         = { icon = 'link',            color = 'cyan' },
  ['S2_Engine/xerxes']         = { icon = 'crown',           color = '#e6b450' }, -- Achaemenid gold; amestris's pair

  ['SEELE_01/keel-lorenz']     = { icon = 'book',            color = 'white' },

  ['SEELE_02/anvil']           = { icon = 'primitive-square', color = '#8fa1bd' }, -- codex; cold steel
  ['SEELE_02/cinder']          = { icon = 'flame',           color = 'yellow' },
  ['SEELE_02/sledge']          = { icon = 'tools',           color = 'red' },

  ['SEELE_03/didymus']         = { icon = 'eye',             color = 'cyan' },
  ['SEELE_03/klinker']         = { icon = 'shield',          color = 'white' },   -- codex

  -- Third of a set with anvil and klinker: steel, white, glass. Anvil's
  -- saturation, a step lighter, the hue turned from steel blue to glass green.
  ['SEELE_04/flask']           = { icon = 'flask',           color = '#a5cac5' }, -- codex; lab glass

  ['Tiferet/azael']           = { icon = 'gavel',           color = 'green' },
  ['Tiferet/baraqiel']         = { icon = 'bolt',            color = 'white' },
  ['Tiferet/kokabiel']         = { icon = 'telescope',       color = 'blue' },
  ['Tiferet/penemue']          = { icon = 'book',            color = 'magenta' },
  ['Tiferet/sariel']           = { icon = 'law',             color = 'cyan' },
  ['Tiferet/shamsiel']         = { icon = 'sun',             color = 'yellow' },

  ['Viper/viper']              = { icon = 'snake',           color = 'cyan' },

  -- No line yet (plain dot): Pribnow_Box/marker.
}

-- Used when an agent has no line, or its color is bad: stable per agent.
local FALLBACK_COLORS = {
  '#80d467', '#9EDBFF', '#d670d6', '#29b8db',
  '#23d18b', '#f5f543', '#cc4040', '#7f95b8',
}

local function color_for(key)
  local sum = 0
  for i = 1, #key do sum = sum + key:byte(i) end
  return FALLBACK_COLORS[(sum % #FALLBACK_COLORS) + 1]
end

-- "repo/agent" -> { icon, color, icon_color? } -- icon_color only for the ?.
local function look_for(key)
  local look = AGENT_LOOKS[key]
  local style = { icon = NO_ICON, color = color_for(key) }
  if type(look) ~= 'table' then return style end

  if look.icon ~= nil then
    local id = (tostring(look.icon):gsub('-', '_'))
    local glyph = CODICONS[id] or EXTRA_ICONS[id]
    if glyph then
      style.icon = glyph
    else
      style.icon, style.icon_color = BAD_ICON, COLOR_NAMES.red
      wezterm.log_warn('AGENT_LOOKS ' .. key .. ': no icon named "'
        .. tostring(look.icon) .. '"')
    end
  end

  if look.color ~= nil then
    local hex = COLOR_NAMES[look.color] or look.color
    if type(hex) == 'string' and hex:match('^#%x%x%x%x%x%x$') then
      style.color = hex
    else
      wezterm.log_warn('AGENT_LOOKS ' .. key .. ': no color named "'
        .. tostring(look.color) .. '"')
    end
  end
  return style
end

-- "repo/agent" -> { icon, color, icon_color? }, worked out the first time the
-- tab bar meets that agent. Needs no roster: AGENT_LOOKS is in this file.
local AGENT_STYLE = {}

local function style_for(key)
  local style = AGENT_STYLE[key]
  if not style then
    style = look_for(key)
    AGENT_STYLE[key] = style
  end
  return style
end

-- One agent into the roster. `key` is "repo/agent", `dir` is the folder under
-- ~ it starts in; `fresh` and `resume` are the two command lines that start
-- it -- `claude --agent x` / `... --resume`, or `codex` / `codex resume`.
--   roster.fresh   "repo/agent" -> argv to spawn it
--   roster.resume  "repo/agent" -> argv to spawn it at its resume list
--   roster.choices { { id = "repo/agent", label = "repo  agent" } }
local function add_agent(roster, key, dir, fresh, resume)
  -- Tag the pane with its identity before handing over to the agent, so
  -- the tab bar knows who lives there. base64 per WezTerm's own
  -- __wezterm_set_user_var; the tail keeps the tab alive after an exit.
  -- Two reports before handing over to the agent:
  --   SetUserVar  who lives in this pane, for the tab bar
  --   OSC 7       where it lives, so ALT+\\ splits land in the repo.
  -- bash -lc is non-interactive, so PROMPT_COMMAND never runs and neither
  -- report would happen on its own -- and Claude Code can hold the pane
  -- for hours without ever drawing a prompt.
  local function argv_for(command)
    return { '/bin/bash', '-lc', string.format(
      "printf '\\033]1337;SetUserVar=wtagent=%%s\\007' \"$(printf '%%s' '%s' | base64 -w0)\"; "
        .. "cd ~/%s && printf '\\033]7;file://%%s%%s\\007' \"$HOSTNAME\" \"$PWD\" && "
        .. '%s; exec bash -l',
      key, dir, command) }
  end
  roster.fresh[key] = argv_for(fresh)
  roster.resume[key] = argv_for(resume)
  table.insert(roster.choices, { id = key, label = (key:gsub('/', '  ', 1)) })
end

-- A fresh session is born named after its agent -- `--name` writes the same
-- custom-title record /rename does (proven 2026-10-01, Claude Code 2.1.287),
-- so there is no /rename to type. Resume passes no name: the session picked
-- there keeps whatever it is already called.
local function add_claude(roster, key, dir, name)
  local claude = 'claude --agent ' .. name
  add_agent(roster, key, dir, claude .. ' --name ' .. name, claude .. ' --resume')
end

-- ---------------------------------------------------------------------------
-- NOTICES -- when a key cannot do its job, say so in this window's tab bar,
-- in red, for ten seconds; and in the debug log (CTRL+SHIFT+L).
-- Not a Windows toast: WezTerm sends those as app id org.wezfurlong.wezterm,
-- which the portable nightly may never have registered -- unproven, so not
-- trusted to carry a failure.
-- ---------------------------------------------------------------------------
local notice_serial = 0

local function complain(window, text)
  wezterm.log_error(text)
  notice_serial = notice_serial + 1
  local mine = notice_serial
  window:set_right_status(wezterm.format {
    { Foreground = { Color = COLOR_NAMES.red } },
    { Text = ' ' .. text .. ' ' },
  })
  wezterm.time.call_after(10, function()
    if notice_serial == mine then window:set_right_status('') end
  end)
end

-- Wall-clock milliseconds since 1970. A Time object cannot be subtracted, so
-- it is formatted: chrono's %s is epoch seconds, %3f the milliseconds.
-- Proven 2026-10-08 on cab25161: a 13-digit integer.
local function now_ms()
  return tonumber(wezterm.time.now():format('%s%3f')) or 0
end

-- Every path a glob finds, or none -- a failure is logged, never raised.
--
-- TIMED, 2026-10-08: each glob crosses the WSL bridge, and a bridge that
-- stalls should be readable after the fact. Two lines per glob, in
--   C:\Users\Michael\.local\share\wezterm\wezterm-gui.exe-log-<pid>.txt
-- (one file per window's process, made on its first line; CTRL+SHIFT+L shows
-- the same lines live):
--   INFO  roster: <date> <pattern> start
--   WARN  roster: <pattern> took <ms> ms, <n> found
-- A "start" with no "took" after it is a glob that never came back. The file
-- stamps time but not date, so "start" carries the date. Healthy is ~20 ms.
local function glob(pattern)
  wezterm.log_info('roster: ' .. wezterm.time.now():format('%Y-%m-%d')
    .. ' ' .. pattern .. ' start')
  local began = now_ms()
  local ok, found = pcall(wezterm.glob, pattern)
  local took = now_ms() - began
  if ok and type(found) == 'table' then
    wezterm.log_warn(string.format('roster: %s took %d ms, %d found',
      pattern, took, #found))
    return found
  end
  wezterm.log_error(string.format('roster: cannot read %s after %d ms: %s',
    pattern, took, tostring(found)))
  return {}
end

-- Only lists what is really there: a seat whose file is gone would open a tab
-- that fails. Globs only -- ~/repos, each of HOME_REPOS, Codex -- no io.open:
-- io.open would block the window.
local function read_roster()
  local roster = { fresh = {}, resume = {}, choices = {} }

  for _, path in ipairs(glob(AGENTS_GLOB)) do
    local repo, name =
      path:match('repos[/\\]([^/\\]+)[/\\]%.claude[/\\]agents[/\\](.+)%.md$')
    if repo and name then
      add_claude(roster, repo .. '/' .. name, 'repos/' .. repo, name)
    end
  end

  for _, repo in ipairs(HOME_REPOS) do
    for _, path in ipairs(glob(WSL_HOME .. repo .. '\\.claude\\agents\\*.md')) do
      local name = path:match('([^/\\]+)%.md$')
      if name then add_claude(roster, repo .. '/' .. name, repo, name) end
    end
  end

  local codex_repos = {}
  for _, path in ipairs(glob(WSL .. '*\\.codex\\config.toml')) do
    local repo = path:match('repos[/\\]([^/\\]+)[/\\]%.codex[/\\]config%.toml$')
    if repo then codex_repos[repo] = true end
  end
  for _, key in ipairs(CODEX_SEATS) do
    local repo = key:match('^(.-)/')
    if repo and codex_repos[repo] then
      add_agent(roster, key, 'repos/' .. repo, 'codex', 'codex resume')
    end
  end

  -- One order for every picker: by repo, then agent. Codex seats land among
  -- their repo's Claude agents.
  table.sort(roster.choices, function(a, b) return a.id < b.id end)
  return roster
end

-- The roster as last read; nil until the first picker opens. An empty read
-- (WSL down) is not kept, so the next press tries again.
local ROSTER = nil

-- One roster, many pickers. The built-in launcher can only ever open a new
-- tab; this is an InputSelector, so where it lands -- and how the agent
-- starts -- is ours. `which` picks the fresh or the resume command lines.
-- No config.launch_menu any more: it must be filled at load, and load no
-- longer reads the roster -- so right-click on + lists no agents.
local function pick_agent(title, which, place)
  return wezterm.action_callback(function(window, pane)
    local roster = ROSTER or read_roster()
    if #roster.choices == 0 then
      complain(window, 'No agents found under ~/repos -- is WSL up?')
      return
    end
    ROSTER = roster
    window:perform_action(wezterm.action.InputSelector {
      title = title,
      fuzzy = true,
      fuzzy_description = 'Agent: ',
      choices = roster.choices,
      action = wezterm.action_callback(function(win, p, id)
        if not id then return end          -- cancelled
        local argv = roster[which][id]
        if argv then place(win, p, argv) end
      end),
    }, pane)
  end)
end

local function in_tab(window, pane, argv)
  window:perform_action(
    wezterm.action.SpawnCommandInNewTab { args = argv }, pane)
end

local AGENT_IN_TAB = pick_agent('Agents', 'fresh', in_tab)

-- Resume without the throwaway: `claude --resume` opens the picker before any
-- session exists, so no empty session is left behind the way a fresh start
-- followed by /resume leaves one.
local AGENT_RESUME_IN_TAB = pick_agent('Resume agent', 'resume', in_tab)

local AGENT_IN_SPLIT = pick_agent('Agents', 'fresh', function(window, pane, argv)
  window:perform_action(
    wezterm.action.SplitPane { direction = 'Right', command = { args = argv } },
    pane)
end)

-- ===========================================================================
-- TAB TITLES
--
-- An agent tab shows its icon and name in its own color. Anything else shows
-- the pane title, trimmed. Titles are kept short deliberately: on Windows a
-- long title overruns the fancy bar and swallows the window buttons
-- (wezterm issue #5014).
-- ===========================================================================
wezterm.on('format-tab-title', function(tab, tabs, panes, conf, hover, max_width)
  local pane = tab.active_pane
  local tag = pane.user_vars and pane.user_vars.wtagent
  local _, name = (tag or ''):match('^(.-)/(.+)$')
  local style = name and style_for(tag)

  local icon, text, color = '', '', nil
  if style then
    icon = style.icon .. ' '
    text = name
    color = style.color
  else
    text = pane.title or ''
    -- Measured and cut in screen cells, never bytes: a byte cut can split a
    -- multibyte character, and invalid UTF-8 makes WezTerm reject the whole
    -- title (1404 warnings in one session, 2026-09-22).
    if wezterm.column_width(text) > 18 then
      text = wezterm.truncate_right(text, 17) .. '\u{2026}'
    end
    color = tab.is_active and '#e2ded6' or '#85827d'
  end
  -- The icon wears the agent's color, except a misspelled one's red ?.
  local icon_color = (style and style.icon_color) or color

  if not tab.is_active then
    color = wezterm.color.parse(color):darken(0.25)
    icon_color = wezterm.color.parse(icon_color):darken(0.25)
  end

  return {
    { Foreground = { Color = '#5d5b58' } },
    { Text = ' ' .. tostring(tab.tab_index + 1) .. ': ' },
    { Foreground = { Color = icon_color } },
    { Text = icon },
    { Foreground = { Color = color } },
    { Text = text .. ' ' },
  }
end)

-- ===========================================================================
-- WINDOW TITLES -- what the Windows taskbar shows when you hover.
--
-- A window names itself after the repos of the agents living in it: all
-- Tiferet agents reads "Tiferet", a mix reads "Magi_1 · Tiferet". ALT+SHIFT+N
-- names it by hand instead -- for a team that isn't one repo. Enter an empty
-- name to hand it back to the automatic one.
--
-- The hand-given name is kept in wezterm.GLOBAL, not in the window's own
-- title: any pane can overwrite that with OSC 0/2, and Claude Code writes its
-- status there constantly (wezterm.org/config/lua/mux-window/get_title.html).
-- GLOBAL survives config reloads but not quitting WezTerm.
-- ===========================================================================
wezterm.GLOBAL.window_names = wezterm.GLOBAL.window_names or {}

wezterm.on('format-window-title', function(tab, pane, tabs, panes, conf)
  local names = wezterm.GLOBAL.window_names
  local named = names and names[tostring(tab.window_id)]
  if named and named ~= '' then return named end

  local seen, repos = {}, {}
  for _, t in ipairs(tabs) do
    for _, p in ipairs(t.panes or { t.active_pane }) do
      local tag = p.user_vars and p.user_vars.wtagent
      local repo = tag and tag:match('^(.-)/')
      if repo and not seen[repo] then
        seen[repo] = true
        table.insert(repos, repo)
      end
    end
  end
  if #repos > 0 then return table.concat(repos, ' · ') end
  return tab.active_pane.title    -- no agents here: WezTerm's usual title
end)

local NAME_WINDOW = wezterm.action.PromptInputLine {
  description = 'Name this window (empty = automatic, from its agents)',
  action = wezterm.action_callback(function(window, pane, line)
    if line == nil then return end   -- Esc
    local mux_window = window:mux_window()
    wezterm.GLOBAL.window_names[tostring(mux_window:window_id())] = line
    -- Setting the mux title makes WezTerm re-run format-window-title now,
    -- rather than at the next title change from a pane.
    mux_window:set_title(line)
  end),
}

-- ===========================================================================
-- GATHER AND SCATTER
--
-- A window shows one tab at a time; panes are the only side-by-side. These two
-- convert between the forms without restarting anything:
--
--   gather   pick another tab, its pane moves in here as a right split
--   scatter  pick a pane here, it leaves as its own tab
--
-- Gather has no Lua API, so it goes through the CLI -- and the CLI always
-- lands in THIS process: each wezterm-gui.exe puts its own socket in
-- WEZTERM_UNIX_SOCKET (wezterm-gui/src/main.rs:415), and a child it starts
-- inherits that. It has to: pane numbers are per process, so another
-- window's process has a "pane 3" too. Gather only ever offers this window's
-- tabs, so across windows there is nothing to gather -- by design, since
-- every window is its own process (see NEW WINDOW below).
--
-- If the move fails -- the tab closed while you picked, the socket is gone --
-- the reason shows in red in the tab bar. --no-auto-start: a lost socket
-- must not quietly start a background mux server instead.
-- On 20240203 `split-pane --move-pane-id` could kill panes; the nightly
-- fixed it (changelog, #6028).
-- ===========================================================================
local WEZTERM_DIR = wezterm.executable_dir or 'C:\\Program Files\\WezTerm'
local WEZTERM_EXE = WEZTERM_DIR .. '\\wezterm.exe'

-- The last line of a CLI's stderr: the error itself, without the log prefix.
-- A server-side refusal reads "... reason: "Error: pane_id 7 invalid" ...";
-- only the part in quotes is kept.
local function last_line(text)
  local line = tostring(text or ''):gsub('%s+$', ''):match('([^\r\n]*)$') or ''
  line = line:gsub('\27%[[%d;]*m', ''):gsub('^.-%s+ERROR%s+%S+%s+>%s+', '')
  line = line:match('reason: "(.-)"') or line
  line = line:gsub('^Error: ', '')
  return line ~= '' and line or 'no reason given'
end

local GATHER_TAB = wezterm.action_callback(function(window, pane)
  local here = pane:pane_id()
  local choices = {}
  for _, tab in ipairs(window:mux_window():tabs()) do
    local target = tab:active_pane()
    if target and target:pane_id() ~= here then
      local vars = target:get_user_vars() or {}
      local label = vars.wtagent or tab:get_title()
      table.insert(choices, {
        id = tostring(target:pane_id()),
        label = string.format('%s  [pane %d]', label, target:pane_id()),
      })
    end
  end
  if #choices == 0 then return end

  window:perform_action(wezterm.action.InputSelector {
    title = 'Gather into this tab',
    fuzzy = true,
    fuzzy_description = 'Tab: ',
    choices = choices,
    action = wezterm.action_callback(function(win, current, id)
      if not id then return end
      -- run_child_process waits for the CLI without holding up the window
      -- (it is async), so its verdict can be read.
      local ok, success, _, stderr = pcall(wezterm.run_child_process, {
        WEZTERM_EXE, 'cli', '--no-auto-start', 'split-pane', '--right',
        '--pane-id', tostring(current:pane_id()),
        '--move-pane-id', id,
      })
      if not ok then
        complain(win, 'Gather failed: ' .. last_line(success))
      elseif not success then
        complain(win, 'Gather failed: ' .. last_line(stderr))
      end
    end),
  }, pane)
end)

-- ===========================================================================
-- NEW WINDOW = NEW PROCESS
--
-- Every tab lives in the wezterm-gui.exe of its window. On 2026-09-29 Windows
-- ended one hung process and 10-15 agents died with it. So a new window is a
-- separate process: a hang costs that window's agents, no one else's.
-- Nothing ties the child to its parent -- no job object anywhere in the
-- nightly source -- so it outlives the window that opened it.
--
-- The price: windows can't trade panes (see GATHER), and each process has
-- its own wezterm.GLOBAL, so window names are per process.
--
-- wezterm-gui.exe from executable_dir: the build that is running opens the
-- next window, never another one.
-- ===========================================================================
local NEW_WINDOW = wezterm.action_callback(function(window, pane)
  local ok, err = pcall(wezterm.background_child_process, {
    WEZTERM_DIR .. '\\wezterm-gui.exe', 'start', '--always-new-process',
  })
  if not ok then
    complain(window, 'New window failed: ' .. last_line(err))
  end
end)

-- A bare launch of wezterm-gui.exe (no arguments) would otherwise hand its
-- window to a running process. The pinned shortcuts already pass the flag.
-- Since 20220101.
config.default_gui_startup_args = { 'start', '--always-new-process' }

-- ===========================================================================
-- KEYS -- ALT ("Option") is the house modifier.
--
-- The CTRL+SHIFT defaults still work; these are added, not swapped. Every
-- ALT+letter taken here stops reaching the shell and Claude Code as a Meta
-- key -- ALT+t, ALT+w, ALT+m, ALT+n, ALT+r are spent. ALT+b / ALT+f (word motion in
-- readline) are deliberately left alone.
-- ===========================================================================
local act = wezterm.action

config.keys = {
  -- Cursor-terminal habits ---------------------------------------------------
  -- Highlighting already copies: WezTerm's default mouse-up action is
  -- CompleteSelection(ClipboardAndPrimarySelection). Nothing to bind.
  { key = 'v', mods = 'CTRL', action = act.PasteFrom 'Clipboard' },

  -- SHIFT+ENTER = newline. Terminals send a plain CR for both Enter and
  -- SHIFT+Enter, so the app cannot tell them apart. This sends ESC+CR --
  -- the same sequence Claude Code's /terminal-setup writes for VS Code.
  { key = 'Enter', mods = 'SHIFT', action = act.SendString '\x1b\r' },

  -- CTRL+C: copy if text is selected, interrupt if not. Copying also clears
  -- the selection, so a second CTRL+C kills the process -- exactly Cursor.
  { key = 'c', mods = 'CTRL', action = wezterm.action_callback(function(window, pane)
      local sel = window:get_selection_text_for_pane(pane)
      if sel and sel ~= '' then
        window:perform_action(act.CopyTo 'ClipboardAndPrimarySelection', pane)
        window:perform_action(act.ClearSelection, pane)
      else
        window:perform_action(act.SendKey { key = 'c', mods = 'CTRL' }, pane)
      end
    end),
  },

  -- Tabs --------------------------------------------------------------------
  { key = 't', mods = 'ALT', action = act.SpawnTab 'CurrentPaneDomain' },
  { key = 'w', mods = 'ALT', action = act.CloseCurrentTab { confirm = true } },
  -- Cycle tabs. CTRL+TAB / CTRL+SHIFT+TAB work too -- WezTerm's own defaults.
  -- ALT+arrows is not available here; it belongs to panes, below.
  { key = ']', mods = 'ALT', action = act.ActivateTabRelative(1) },
  { key = '[', mods = 'ALT', action = act.ActivateTabRelative(-1) },

  -- Panes: split ------------------------------------------------------------
  -- Backslash splits side by side, minus splits stacked -- the keys look like
  -- the cut they make.
  { key = '\\', mods = 'ALT', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
  { key = '-', mods = 'ALT', action = act.SplitVertical { domain = 'CurrentPaneDomain' } },

  -- Panes: move between them. Arrows are the ones to remember; hjkl are there
  -- for the hands that already know them.
  { key = 'LeftArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'h', mods = 'ALT', action = act.ActivatePaneDirection 'Left' },
  { key = 'j', mods = 'ALT', action = act.ActivatePaneDirection 'Down' },
  { key = 'k', mods = 'ALT', action = act.ActivatePaneDirection 'Up' },
  { key = 'l', mods = 'ALT', action = act.ActivatePaneDirection 'Right' },

  -- Panes: resize. No modal state to remember -- hold ALT+SHIFT and steer.
  { key = 'LeftArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Left', 1 } },
  { key = 'RightArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Right', 1 } },
  { key = 'UpArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Up', 1 } },
  { key = 'DownArrow', mods = 'ALT|SHIFT', action = act.AdjustPaneSize { 'Down', 1 } },

  -- Panes: gather a tab in here, or scatter one back out --------------------
  { key = 'g', mods = 'ALT', action = GATHER_TAB },
  { key = 'g', mods = 'ALT|SHIFT', action = act.PaneSelect {
      alphabet = 'asdfghjkl', mode = 'MoveToNewTab' } },
  { key = 'G', mods = 'ALT|SHIFT', action = act.PaneSelect {
      alphabet = 'asdfghjkl', mode = 'MoveToNewTab' } },

  -- Panes: lifecycle ---------------------------------------------------------
  { key = 'z', mods = 'ALT', action = act.TogglePaneZoomState },
  { key = 'x', mods = 'ALT', action = act.CloseCurrentPane { confirm = true } },
  -- Overlays a letter on every pane; type it to jump there. The one that
  -- scales past four panes, when direction keys stop being obvious.
  { key = 'q', mods = 'ALT', action = act.PaneSelect { alphabet = 'asdfghjkl' } },

  -- Agents: same fuzzy roster, two destinations -----------------------------
  { key = 'a', mods = 'ALT', action = AGENT_IN_TAB },
  { key = 'a', mods = 'ALT|SHIFT', action = AGENT_IN_SPLIT },
  { key = 'A', mods = 'ALT|SHIFT', action = AGENT_IN_SPLIT },
  -- ALT+r: same roster, but Claude opens at its resume list. Free in Claude
  -- Code (its Meta keys are p, o, t, v); readline's revert-line is the loss.
  { key = 'r', mods = 'ALT', action = AGENT_RESUME_IN_TAB },

  -- Window ------------------------------------------------------------------
  -- Every new-window key opens a separate process (see NEW WINDOW), the
  -- CTRL+SHIFT+N and SUPER+N defaults included -- left alone they would
  -- still open windows inside this process.
  { key = 'n', mods = 'ALT', action = NEW_WINDOW },
  { key = 'n', mods = 'CTRL|SHIFT', action = NEW_WINDOW },
  { key = 'N', mods = 'CTRL|SHIFT', action = NEW_WINDOW },
  { key = 'N', mods = 'CTRL', action = NEW_WINDOW },
  { key = 'n', mods = 'SUPER', action = NEW_WINDOW },
  -- ALT+SHIFT+N: name this window, for the taskbar. See WINDOW TITLES.
  { key = 'n', mods = 'ALT|SHIFT', action = NAME_WINDOW },
  { key = 'N', mods = 'ALT|SHIFT', action = NAME_WINDOW },
  { key = 'm', mods = 'ALT', action = act.Hide },
}

-- ALT+1..9 jumps straight to a tab.
for i = 1, 9 do
  table.insert(config.keys, {
    key = tostring(i),
    mods = 'ALT',
    action = act.ActivateTab(i - 1),
  })
end

-- ===========================================================================
-- The active pane renders at the configured background, #1E1E1E. Inactive
-- panes are washed LIGHTER, not darker -- a grey filter over the ones you are
-- not in, the way a GUI greys out what is disabled.
--
-- Measured 2026-09-14 from a screenshot: dimming below 1.0 pushed inactive
-- panes to #141414, which read as the cleaner black and made the active pane
-- look murky by comparison. Multipliers above 1.0 lighten instead.
config.inactive_pane_hsb = { saturation = 0.7, brightness = 1.3 }

-- ===========================================================================
-- Mouse
-- ===========================================================================
config.mouse_bindings = {
  { event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard' },
}

return config
