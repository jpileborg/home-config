----------------------------------------------------------------------
-- File: theme.lua                                                  --
----------------------------------------------------------------------

-- This Awesome theme file uses the zenburn theme to get default
-- values, but modifies some of the settings.

local orig_theme_name = "/usr/share/awesome/themes/zenburn/theme.lua"

-- Get the "real" theme
local success, theme = pcall(function() return dofile(orig_theme_name) end)

theme.font = "monospace 8"
theme.wallpaper_cmd = { 'xsetroot -solid "#333333"' }

return theme
