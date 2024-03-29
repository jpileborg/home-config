-- Standard awesome library
require("awful")
require("awful.autofocus")
require("awful.rules")
require("awful.remote")
-- Theme handling library
require("beautiful")
-- Notification library
require("naughty")

-- Widget library
require("vicious")
require("obvious.volume_alsa")

require("myweather")

-- Load Debian menu entries
require("debian.menu")


-- {{{ Variable definitions
local confdir = awful.util.getdir("config")

-- Themes define colours, icons, and wallpapers
beautiful.init(confdir.."/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "urxvt -name normal "
editor = os.getenv("EDITOR") or "editor"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"
local altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
layouts =
{
    awful.layout.suit.floating,        --  1
    awful.layout.suit.tile,            --  2
    awful.layout.suit.tile.left,       --  3
    awful.layout.suit.tile.bottom,     --  4
    awful.layout.suit.tile.right,      --  5
    awful.layout.suit.tile.top,        --  6
    awful.layout.suit.fair,            --  7
    awful.layout.suit.fair.horizontal, --  8
    awful.layout.suit.spiral,          --  9
    awful.layout.suit.spiral.dwindle,  -- 10
    awful.layout.suit.max,             -- 11
    awful.layout.suit.max.fullscreen,  -- 12
    awful.layout.suit.magnifier        -- 13
}
-- }}}

-- {{{ Tags
tags = {}

-- First screen
tags[1] = awful.tag(
    { "web", "emacs", "terminals", "games", "vbox", 6, 7, 8, "trans" },
    1,
    { layouts[11], layouts[11], layouts[ 2], layouts[11], layouts[11],
	  layouts[ 1], layouts[ 1], layouts[ 1], layouts[11] }
)

-- Second screen
tags[2] = awful.tag(
    { "mail", "build", "terminals", "spotify", 5, 6, 7, 8, "top" },
    2,
    { layouts[11], layouts[ 2], layouts[ 2], layouts[11], layouts[ 1],
      layouts[ 1], layouts[ 1], layouts[ 1], layouts[11] }
)
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = image(beautiful.awesome_icon),
                                     menu = mymainmenu })
-- }}}

function clone(t)            -- return a copy of the table t
    local new = {}             -- create a new table
    local i, v = next(t, nil)  -- i is an index of t, v = t[i]
    while i do
        if type(v)=="table" then
            v=clone(v)
        end
        new[i] = v
        i, v = next(t, i)        -- get next index
    end
    return new
end

-- {{{ Wibox
local function show_calendar()
    -- TODO: Integrate with emacs org-mode
    -- TODO: Highlight dates with org entries, different colors depending on
    --       the type and state of the 'event'
    -- TODO: Clicking on a date will bring up that day in emacs

    local function is_leap_year(year)
        return (year % 4 == 0 and (year % 100 ~= 0 or year % 400 == 0))
    end

    local info  = os.date("*t")
    local month = os.date("%B")
    local year  = os.date("%Y")
    local today = os.date("%d")

    local days_per_month = {
        31, is_leap_year(year) and 29 or 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
    }

    local info_first = clone(info)
    local days = {}

    info_first.day = 1
    local time_first = os.time(info_first)

    local weeks = {}
    local week = 1
    local days = { 0, 0, 0, 0, 0, 0, 0 }
    local weeknum
    for d = 1, days_per_month[info.month] do
        info.day = d

        local t = os.date("*t", os.time(info))
        weeknum = os.date("%W", os.time(info))

        t.wday = t.wday - 1
        if t.wday == 0 then
            t.wday = 7  -- Sunday is last day of week, not first
        end

        days[t.wday] = t.day

        if t.wday == 7 then
            days.week = weeknum
            weeks[week] = days
            days =  { 0, 0, 0, 0, 0, 0, 0 }
            week = week + 1
        end
    end
    days.week = weeknum
    weeks[week] = days

    local weeks_text = "<span color='#a6a6e6'>Week</span> <span color='#a6e6a6'>Mo Tu We Th Fr</span> <span color='#e6a6a6'>Sa Su</span>"
    for i = 1, #weeks do
        local s = string.format("<span color='#9595f7'>%-2d</span>   ", weeks[i].week)
        local w = false
        for j = 1, #weeks[i] do
            if weeks[i][j] == 0 then
                s = s.."   "
            else
                local d = string.format("%02d", weeks[i][j])
                if d == today then
                    s = s..'<span weight="bold" color="#95f795">'..d..'</span>'
                    w = true
                else
                    s = s..d
                end
                s = s.." "
            end
        end

        -- if w then
        --     s = '<span weight="bold">'..s..'</span>'
        -- end

        weeks_text = weeks_text.."\r\n"..s
    end

    -- return naughty.notify({ title = month.." "..year,
    --                         text = '<span face="monospace">'..weeks_text..'</span>',
    --                         timeout = 0,
    --                         screen = mouse.screen,
    --                         right = 1900 })
    return '<span size="larger" weight="bold">'..month..' '..year..'</span>\r\n'..weeks_text
end

-- Create a textclock widget
mytextclock = awful.widget.textclock({ align = "right" }, '<span font="monospace">%a %b %d, %H:%M</span>', 5)
-- mytextclock_notification = nil
-- -- mytextclock:buttons(awful.util.table.join(
-- --                         awful.button({ }, 1,
-- --                                      function(w)
-- --                                          if mytextclock_notification ~= nil then
-- --                                              naughty.destroy(mytextclock_notification)
-- --                                              mytextclock_notification = nil
-- --                                          else
-- --                                              mytextclock_notification = show_calendar()
-- --                                          end
-- --                                      end)
-- --                 ))
-- -- mytextclock:add_signal("mouse::enter", show_calendar)
-- mytextclock:add_signal("mouse::enter",
--                        function(w)
--                            mytextclock_notification = show_calendar(w)
--                        end)
-- mytextclock:add_signal("mouse::leave",
--                        function(w)
--                            if mytextclock_notification ~= nil then
--                                naughty.destroy(mytextclock_notification)
--                                mytextclock_notification = nil
--                            end
--                        end)
mytextclock_tooltip = awful.tooltip({ objects = { mytextclock }, timer_function =
                                  function()
                                      return show_calendar()
                                  end })
                                      
                                        
-- Create a systray
mysystray = widget({ type = "systray" })

separator      = widget({ type = "textbox", name = "separator", align = "right" })
separator.text = '<span font="monospace"> </span>'

separator2      = widget({ type = "textbox", name = "separator", align = "right" })
separator2.text = '<span font="monospace"> | </span>'

function get_mail_count()
    local mails   = awful.util.pread("python "..confdir.."/imap.py")

    local _, _, messages = mails:find("MESSAGES ([0-9]+)")
    local _, _, unread   = mails:find("UNSEEN ([0-9]+)")

    if messages == nil then messages = '<span color="#ffa6a6">0</span>' end
    if unread   == nil then unread   = '<span color="#ffa6a6">0</span>' end

    if unread ~= "0" then
        unread = '<span color="#a6e6a6" weight="bold">'..unread..'</span>'
    end
    return '<span font="monospace">'..unread.."/"..messages..'</span>'
end

mailwidget = widget({ type = "textbox" })
mailwidget.text = get_mail_count()
mailwidget:buttons(awful.util.table.join(
					  awful.button({ }, 1, function () mailwidget.text = get_mail_count() end)
			  ))

mailwidgettimer = timer({ timeout = 60 })
mailwidgettimer:add_signal("timeout", function() mailwidget.text = get_mail_count() end)
mailwidgettimer:start()

volwidget = widget({ type = "textbox" })
vicious.register(volwidget, vicious.widgets.volume,
				 function(w, a)
					 local mixer_state = {
						 ["♫"] = true,  -- not muted
						 ["♩"] = false  -- muted
					 }
					 local state, color

					 if mixer_state[a[2]] == false then
						 color = "a6a6e6"
						 state = "  M "
					 else
						 if a[1] > 80 then
							 color = "e6a6a6"
						 elseif a[1] > 20 then
							 color = "a6e6a6"
						 else
							 color = "a6a6e6"
						 end
						 state = string.format("%3d%%", a[1])
					 end
				 return '<span font="monospace">♫<span color="#'..color..'">'..state..'</span></span>'
				 end,
				 0.1, "Master")
volwidget:buttons(awful.util.table.join(
					  awful.button({ }, 1, function () awful.util.spawn(terminal .. " -e alsamixer") end),
					  awful.button({ }, 2, function () awful.util.spawn("amixer -q set Master toggle")   end),
					  awful.button({ }, 4, function () awful.util.spawn("amixer -q set Master 1+", false) end),
					  awful.button({ }, 5, function () awful.util.spawn("amixer -q set Master 1-", false) end)
			  ))

netstatuswidget = widget({ type = "textbox" })
vicious.register(netstatuswidget, vicious.widgets.net,
				 function(w, a)
					 local eth0, eth1
					 if a["{eth0 carrier}"] == 1 then
						 eth0 = "<span color='#a6e6a6'>U</span>"
					 else
						 eth0 = "<span color='#e6a6a6'>D</span>"
					 end
					 if a["{eth1 carrier}"] == 1 then
						 eth1 = "<span color='#a6e6a6'>U</span>"
					 else
						 eth1 = "<span color='#e6a6a6'>D</span>"
					 end
					 return '<span font="monospace">eth0:'..eth0..' eth1:'..eth1..'</span>'
				 end, 10)

loadavgwidget = widget({ type = "textbox" })
vicious.register(loadavgwidget, vicious.widgets.uptime,
				 function (w, a)
					 local colors = {
						 "ffa6a6", "e6a6a6", "aa8400", "a6e6a6", "a6faa6"
					 }
					 local c1, c2, c3

					 if tonumber(a[4]) >= 3 then
						 c1 = colors[1]
					 elseif tonumber(a[4]) >= 2 then
						 c1 = colors[2]
					 elseif tonumber(a[4]) >= 1 then
						 c1 = colors[3]
					 elseif tonumber(a[4]) >= 0.1 then
						 c1 = colors[4]
					 else
						 c1 = colors[5]
					 end

					 if tonumber(a[5]) >= 3 then
						 c2 = colors[1]
					 elseif tonumber(a[5]) >= 2 then
						 c2 = colors[2]
					 elseif tonumber(a[5]) >= 1 then
						 c2 = colors[3]
					 elseif tonumber(a[4]) >= 0.1 then
						 c2 = colors[4]
					 else
						 c2 = colors[5]
					 end

					 if tonumber(a[6]) >= 3 then
						 c3 = colors[1]
					 elseif tonumber(a[6]) >= 2 then
						 c3 = colors[2]
					 elseif tonumber(a[6]) >= 1 then
						 c3 = colors[3]
					 elseif tonumber(a[4]) >= 0.1 then
						 c3 = colors[4]
					 else
						 c3 = colors[5]
					 end

					 local v1 = "<span color='#"..c1.."'>"..a[4].."</span>"
					 local v2 = "<span color='#"..c2.."'>"..a[5].."</span>"
					 local v3 = "<span color='#"..c3.."'>"..a[6].."</span>"

					 return '<span font="monospace">'..v1.."/"..v2.."/"..v3..'</span>'
				 end, 2)

memwidget = awful.widget.progressbar()
memwidget:set_width(8)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
memwidget:set_border_color(nil)
memwidget:set_color("#ff7676")
memwidget:set_gradient_colors({ "#ff7676", "#e6a6a6", "#b6b6a6", "#a6e6a6", "#a6faa6" })
vicious.register(memwidget, vicious.widgets.mem,
				 function (w, a)
					 return (100 - a[1])
				 end, 5)

swapwidget = awful.widget.progressbar()
swapwidget:set_width(8)
swapwidget:set_vertical(true)
swapwidget:set_background_color("#494B4F")
swapwidget:set_border_color(nil)
swapwidget:set_color("#ff7676")
swapwidget:set_gradient_colors({ "#ff7676", "#e6a6a6", "#b6b6a6", "#a6e6a6", "#a6faa6" })
vicious.register(swapwidget, vicious.widgets.mem,
				 function (w, a)
					 return (100 - a[5])
				 end, 5)

cpuwidget = awful.widget.graph()
cpuwidget:set_width(25)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_border_color(nil)
cpuwidget:set_color("#ff7676")
cpuwidget:set_gradient_colors({ "#ff7676", "#e6a6a6", "#b6b6a6", "#a6e6a6", "#a6faa6" })
cpuwidget:set_gradient_angle(0)
vicious.register(cpuwidget, vicious.widgets.cpu, "$1", 2)

--sunicon = widget({ type = "imagebox" })
--sunicon.image = "http://api.yr.no/weatherapi/weathericon/1.0/?symbol=1;content_type=image/png"
weatherwidget = widget({ type = "textbox" })
vicious.register(weatherwidget, vicious.widgets.weather,
				 "☁ ${sky} ${tempc}°", 60, "ESMS")

home_p = awful.widget.progressbar()
home_p:set_width(8)
home_p:set_vertical(true)
home_p:set_background_color("#494B4F")
home_p:set_border_color(nil)
home_p:set_color("#a6e6a6")
home_p:set_gradient_colors({ "#ff7676", "#e6a6a6", "#b6b6a6", "#a6c6a6", "#a6e6a6" })
vicious.register(home_p, vicious.widgets.fs,
                 function (w, a)
                     return (100 - a["{/home used_p}"])
                 end, 60)

home_a = widget({ type = "textbox" })
vicious.register(home_a, vicious.widgets.fs,
				 function (a, a)
					 local color

					 if a["{/home avail_p}"] < 5 then
						 color = "#faa6a6"
					 elseif a["{/home avail_p}"] < 10 then
						 color = "#e6a6a6"
					 elseif a["{/home avail_p}"] > 90 then
						 color = "#a6e6a6"
					 elseif a["{/home avail_p}"] > 95 then
						 color = "#a6faa6"
					 end

					 if color == nil then
						 return '<span font="monospace">/home:'..a["{/home avail_gb}"]..'</span>'
					 else
						 return '<span font="monospace">/home:<span color="'..color..'">'..a["{/home avail_gb}"]..'</span></span>'
					 end
				 end, 10)

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, awful.tag.viewnext),
                    awful.button({ }, 5, awful.tag.viewprev)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if not c:isvisible() then
                                                  awful.tag.viewonly(c:tags()[1])
                                              end
                                              client.focus = c
                                              c:raise()
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

-- Testing another weather widget
--require("weather")
--ww1 = widget({ type = "textbox" })
--ww2 = widget({ type = "imagebox" })
--weather.addWeather(ww1, "malmo")
--weather.addWeather(ww2, "malmo")

myweatherwidget = myweather.create("malmö")


for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(function(c)
                                              return awful.widget.tasklist.label.currenttags(c, s)
                                          end, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Add widgets to the wibox - order matters
    mywibox[s].widgets = {
        {
            mylauncher,
            mytaglist[s],
            mypromptbox[s],
            layout = awful.widget.layout.horizontal.leftright
        },
        mylayoutbox[s],
        separator,
        mytextclock,
        separator2,
        s == 1 and mysystray or nil,
        s == 1 and separator2 or nil,
        volwidget,
        separator2,
        netstatuswidget,
        separator2,
        loadavgwidget,
        separator,
        cpuwidget.widget,
        separator2,
        swapwidget.widget,
        separator,
        memwidget.widget,
        separator2,
        home_p.widget,
        separator,
        home_a,
        separator2,
        myweatherwidget:get_widgets(),
		separator2,
        mailwidget,
		separator,
        mytasklist[s],
        layout = awful.widget.layout.horizontal.rightleft
    }
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
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "w", function () mymainmenu:show({keygrabber=true}) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

	awful.key({ modkey, "Mod1"   }, "l"    , function () awful.util.spawn("xscreensaver-command -lock") end),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                                   mypromptbox[mouse.screen].widget,
                                   awful.util.eval, nil,
                                   awful.util.getdir("cache") .. "/history_eval")
              end),

    awful.key({        }, "XF86AudioRaiseVolume", function() awful.util.spawn("amixer -q set Master 2+", false) end),
    awful.key({        }, "XF86AudioLowerVolume", function() awful.util.spawn("amixer -q set Master 2-", false) end),
    awful.key({        }, "XF86AudioMute"       , function() awful.util.spawn("amixer -q set Master toggle", false) end),
    awful.key({        }, "XF86HomePage"        , function() awful.tag.viewonly(tags[1][1]) end),
    awful.key({        }, "XF86Mail"            , function() awful.tag.viewonly(tags[2][1]) end)

)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",      function (c) c.minimized = not c.minimized    end),
    awful.key({ modkey,           }, "m",
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
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

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
                     buttons = clientbuttons,
					 float = true } },

    { rule = { class = "Chromium" },
      properties = { tag = tags[1][1] } },

    { rule = { class = "Iceweasel" },
      properties = { tag = tags[1][1] } },

    { rule = { class = "Spotify" },
      properties = { tag = tags[2][4] } },

    { rule = { class = "Emacs", instance = "emacs" },
      properties = { tag = tags[1][2] } },
    -- { rule = { class = "Emacs", instance = "Calendar" },
    --   properties = { tag = tags[2][3] } },

    { rule = { class = "URxvt", instance = "build" },
      properties = { tag = tags[2][2] } },

    { rule = { class = "URxvt", instance = "terminal1" },
      properties = { tag = tags[1][3] } },

    { rule = { class = "URxvt", instance = "terminal2" },
      properties = { tag = tags[2][3] } },

    { rule = { class = "URxvt", instance = "top" },
      properties = { tag = tags[2][9] } },

    -- { rule = { class = "URxvt", instance = "mail" },
    --   properties = { tag = tags[2][1] } },
    { rule = { class = "Icedove" },
      properties = { tag = tags[2][1] } },

    { rule = { class = "URxvt", instance = "normal" },
      properties = { float = true } },

    { rule = { class = "VirtualBox", instance = "Qt-subapplication" },
      properties = { tag = tags[1][5] } },

    { rule = { class = "Transmission" },
      properties = { tag = tags[1][9] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.add_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:add_signal("mouse::enter", function(c)
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

client.add_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.add_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}


-- ----------------------------------------------------------------------
-- -- TODO: New settings file!

-- -- Declare all settings
-- local settings = {}

-- settings.keys = {
-- 	mod = "Mod4",
-- 	alt = "Mod1"
-- }

-- settings.apps = {
-- 	-- Applications used in menus and keyboard shortcuts
-- 	lock_screen = "gnome-screensaver-command --lock"
-- }

-- settings.layout = {
-- 	-- The layouts that Awesome should use
-- 	-- TODO: The layouts!
--     awful.layout.suit.floating,        --  1
--     awful.layout.suit.tile.right,      --  2
--     awful.layout.suit.max              --  3
-- }

-- settings.tags = {
-- 	-- The tags for the left screen
-- 	left  = {
-- 		{ "emacs"    , settings.layout[3] },
-- 		{ "web"      , settings.layout[3] },
-- 		{ "mail"     , settings.layout[3] },
-- 		{ "gitk"     , settings.layout[3] },
-- 		{ "vbox"     , settings.layout[3] },
-- 		{ "terminals", settings.layout[2] },
-- 		{ 7, settings.layout[1] },
-- 		{ 8, settings.layout[1] },
-- 		{ 9, settings.layout[1] },
-- 	},

-- 	-- The tags for the right screen
-- 	right = {
-- 		{ "build"    , settings.layout[2] },
-- 		{ "web"      , settings.layout[3] },
-- 		{ "terminals", settings.layout[2] },
-- 		{ "remote"   , settings.layout[1] },
-- 		{ "spotify"  , settings.layout[3] },
-- 		{ 6, settings.layout[1] },
-- 		{ 7, settings.layout[1] },
-- 		{ 8, settings.layout[1] },
-- 		{ 9, settings.layout[1] },
-- 	}
-- }

-- -- TODO: Menu
-- settings.menu = {
--     { "awesome", {
--           { "manual", terminal .. " -e man awesome" },
--           { "edit config", editor_cmd .. " " .. awful.util.getdir("config") .. "/rc.lua" },
--           { "restart", awesome.restart },
--           { "quit", awesome.quit }
--       }
--     },
--     { "Open terminal", terminal }
-- }
 
-- -- TODO: Keybindings
-- settings.keys = {}

-- -- Global keyboard shortcuts
-- settings.keys.global = awful.util.table.join(
--     awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
--     awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
--     awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

--     awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),

--     awful.key({ modkey, "Control" }, "r", awesome.restart),
--     awful.key({ modkey, "Shift"   }, "q", awesome.quit)
-- )

-- -- Keyboard shortcuts when clients active
-- settings.keys.client = {
-- }

-- -- TODO: Keyboard shortcuts for specific clients

-- -- TODO: Widgets

-- -- TODO: Mouse button bindings, both global and for clients

-- -- TODO: Client rules

-- -- TODO: Signals

-- -- TODO: Turn all settings into stuff Awesome can use

-- -- TODO: When exiting:
-- --       * loop though all clients
-- --         * sending client termination signal
-- --       * wait until all clients are done
-- --       * exit

-- -- TODO: Split into several modules
-- -- TODO: Specialised theme (but inherits from zenburn)
