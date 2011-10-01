----------------------------------------------------------------------
-- File: new-rc.lua                                                 --
--                                                                  --
-- Configuration file for the Awesome window manger.                --
-- http://awesome.naquadah.org/                                     --
--                                                                  --
-- Highly customized, and set up to handle the upcomming release 4. --
-- Created and maintained by Joachim Pileborg <arrow@pileborg.org>  --
----------------------------------------------------------------------

require("awful")

-- Declare all settings
local settings = {}

settings.folders = {
    home   = "/home/joachimp",
    config = awful.util.getdir("config")
}

settings.theme = settings.folders.config .. "/theme.lua"

settings.apps = {
	-- Applications used in menus and keyboard shortcuts
	lock_screen = "xscreensaver-command -lock",
    terminal    = "urxvt -name normal",
    editor      = "urxvt -name normal -e " .. os.getenv("EDITOR") or "nano"
}

settings.layout = {
	-- The layouts that Awesome should use
	-- TODO: Other layouts?
    awful.layout.suit.floating,        --  1
    awful.layout.suit.tile.right,      --  2
    awful.layout.suit.max,             --  3
    awful.layout.suit.fair,            --  4
    awful.layout.suit.spiral           --  5
}

settings.tags = {
	-- The tags for the left screen
	left  = {
		{ "emacs"    , settings.layout[3] },
		{ "web"      , settings.layout[3] },
		{ "mail"     , settings.layout[3] },
		{ "git"      , settings.layout[3] },
		{ "vbox"     , settings.layout[3] },
		{ "terminals", settings.layout[2] },
		{ 7, settings.layout[1] },
		{ 8, settings.layout[1] },
		{ 9, settings.layout[1] },
	},

	-- The tags for the right screen
	right = {
		{ "build"    , settings.layout[2] },
		{ "web"      , settings.layout[3] },
		{ "terminals", settings.layout[2] },
		{ "spotify"  , settings.layout[3] },
		{ 5, settings.layout[1] },
		{ 6, settings.layout[1] },
		{ 7, settings.layout[1] },
		{ 8, settings.layout[1] },
		{ "top"      , settings.layout[3] },
	}
}
settings.tags[1] = settings.tags.left
settings.tags[2] = settings.tags.right

-- TODO: Menu
settings.menu = {
    { "awesome", {
          { "manual", settings.apps.terminal .. " -e man awesome" },
          { "edit config", settings.apps.editor .. " " .. settings.folders.config .. "/rc.lua" },
          { "restart", awesome.restart },
          { "quit", awesome.quit } }
    },
    { "Open terminal", settings.apps.terminal }
}
 
-- TODO: Keybindings
settings.keys = {
	win   = "Mod4",
	alt   = "Mod1",
    meta  = "Mod1",
    altgr = "Mod5"
}

-- Global keyboard shortcuts
settings.keys.global = awful.util.table.join(
    awful.key({ settings.keys.win,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ settings.keys.win,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ settings.keys.win,           }, "Escape", awful.tag.history.restore),

    awful.key({ settings.keys.win,           }, "Return", function () awful.util.spawn(settings.apps.terminal) end),

    awful.key({ settings.keys.win, "Control" }, "r", awesome.restart),
    awful.key({ settings.keys.win, "Shift"   }, "q", awesome.quit)
)

-- Keyboard shortcuts when clients active
settings.keys.client = {
}

-- TODO: Keyboard shortcuts for specific clients

-- TODO: Widgets

-- TODO: Mouse button bindings, both global and for clients

-- TODO: Client rules

-- TODO: Signals

-- TODO: Turn all settings into stuff Awesome can use

-- TODO: When exiting:
--       * loop though all clients
--         * sending client termination signal
--       * wait until all clients are done
--       * exit

-- TODO: Split into several modules
-- TODO: Specialised theme (but inherits from zenburn)


----------------------------------------------------------------------

-- Standard awesome library
require("awful.autofocus")
require("awful.rules")
-- Widget and layout library
require("wibox")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init(settings.theme)

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, 2 do
    local ts = {}  -- All tags for this screen
    local ls = {}  -- All layouts for this screen

    for t = 1, 9 do
        ts[t] = settings.tags[s][1]
        ls[t] = settings.tags[s][2]
    end

    -- Each screen has its own tag table.
    tags[s] = awful.tag(ts, s, ls)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", settings.apps.terminal .. " -e man awesome" },
   { "edit config", settings.apps.editor .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", settings.apps.terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })
-- }}}

-- {{{ Wibox
-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ settings.keys.win }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ settings.keys.win }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mylauncher)
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ settings.keys.win,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ settings.keys.win,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ settings.keys.win,           }, "Escape", awful.tag.history.restore),

    awful.key({ settings.keys.win,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ settings.keys.win,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ settings.keys.win,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ settings.keys.win, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ settings.keys.win, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ settings.keys.win, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ settings.keys.win, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ settings.keys.win,           }, "u", awful.client.urgent.jumpto),
    awful.key({ settings.keys.win,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ settings.keys.win,           }, "Return", function () awful.util.spawn(settings.apps.terminal) end),
    awful.key({ settings.keys.win, "Control" }, "r", awesome.restart),
    awful.key({ settings.keys.win, "Shift"   }, "q", awesome.quit),

    awful.key({ settings.keys.win,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ settings.keys.win,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ settings.keys.win, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ settings.keys.win, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ settings.keys.win, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ settings.keys.win, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ settings.keys.win,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ settings.keys.win, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ settings.keys.win, "Control" }, "n", awful.client.restore),

    -- Prompt
    awful.key({ settings.keys.win },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ settings.keys.win }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end)
)

clientkeys = awful.util.table.join(
    awful.key({ settings.keys.win,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ settings.keys.win, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ settings.keys.win, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ settings.keys.win, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ settings.keys.win,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ settings.keys.win,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ settings.keys.win,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ settings.keys.win,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ settings.keys.win }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ settings.keys.win, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ settings.keys.win, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ settings.keys.win, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ settings.keys.win }, 1, awful.mouse.client.move),
    awful.button({ settings.keys.win }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
