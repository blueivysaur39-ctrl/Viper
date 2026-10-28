# Viper — Memory Index

- [Michael (the Operator)](user_michael.md) — runs 16+ Claude Code agents at once (2026-09-29); holds the eye, owns installs; wants mental models and proof over lore.
- [Windows / WSL boundary](windows_wsl_boundary.md) — WSL2 seat; nightly wezterm.exe by full path (WezTerm-20260929 pin); stage structural edits, then prove.
- [Window anatomy, proven](project_window_anatomy.md) — window_frame = the bar and space above it; window_padding = content gap; plus dead ends not to retry.
- [Config hosting decision](project_config_hosting.md) — why wezterm.lua stays Windows-hosted; WSL2-hosting proven possible but rejected on reload/availability risk.
- [Terseness + ask before building](feedback_terse_and_ask.md) — short answers; a question is not a work order, confirm before creating anything.
- [Smallest path, no scaffolding](feedback_smallest_path.md) — comment the Lua instead of building docs/generators around it; ship the visible change first.
- [Isolate the variable, don't capitulate](feedback_dont_capitulate.md) — a failed UI attempt means my approach was wrong, not that the tool cannot do it.
- [ConPTY cursor flicker](project_conpty_flicker.md) — Claude cursor flash measured to the byte: bundled ConPTY + 3ms coalesce; fix = coalesce_delay_ms 0 (confirmed 2026-09-16).
- [WSL spawn timeouts](project_wsl_spawn_timeout.md) — blank tabs = WSL RAM exhaustion + order-7 fragmentation (both, his ruling); why agent teams leave Cursor.
- [ConPTY eats color queries](project_conpty_color_query.md) — why Codex has no prompt bg in WezTerm; bundled+inbox ConPTY drop OSC 11, NuGet 1.24 passes it.
- [Codicon table stale, font fine](project_icon_font_drop.md) — nightly's built-in font draws codicons past U+EBEB (2026-10-09); no install needed, CODICONS regen is his call.
- [WezTerm log files + Lua timing](reference_wezterm_logs.md) — ~\.local\share\wezterm\wezterm-gui.exe-log-<pid>.txt, lazy, no date; epoch-ms via format('%s%3f').
- [Config-load hazard + process per window](project_config_load_hazard.md) — windows re-run the config on the GUI thread; load reads only wezterm.lua; ALT+N = new process.
- [Inline-code sky blue](project_inline_code_blue.md) — Claude inline code = WezTerm bright blue #9EDBFF via dark-ansi; he likes it, keep slot 12.
