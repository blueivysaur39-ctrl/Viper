local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_domain = 'WSL:Ubuntu-24.04'

config.color_scheme = 'Catppuccin Mocha'
config.colors = {
  background = '#1E1E1E',
  foreground = '#D4D4D4',
  --         black      red        green      yellow     blue       magenta    cyan       white
  ansi    = { '#1E1E1E', '#cc4040', '#80d467', '#e5c07b', '#61afef', '#c678dd', '#7f95b8', '#d2cbc0' },
  brights = { '#5c6370', '#ff6b6b', '#8fe388', '#f5d67b', '#9EDBFF', '#d7a8ff', '#a0c8e0', '#ffffff' },
}

config.keys = {
  { key = 'v', mods = 'CTRL', action = wezterm.action.PasteFrom 'Clipboard' },
}
config.mouse_bindings = {
  { event = { Down = { streak = 1, button = 'Right' } }, mods = 'NONE',
    action = wezterm.action.PasteFrom 'Clipboard' },
}

return config