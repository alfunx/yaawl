
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan
      * (c) 2013, Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local file = require("yaawl.util.file")

local function factory(args)

    args                        = args or { }
    local sl_path               = args.sl_path or "/proc/loadavg"

    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 10
    local notification_title    = args.notification_timeout or "Load Average"
    local _notification         = nil

    local subject               = require("yaawl.subject")()

    function subject:_update(context)
        local line = file.first_line(sl_path)
        local a, b, c = string.match(line, "(%S+) (%S+) (%S+)")
        context.load_1 = tonumber(a)
        context.load_5 = tonumber(b)
        context.load_15 = tonumber(c)
        self:_apply(context)
    end

    subject:add_callback(function(x)
        if x._auto then return end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = preset,
            screen = preset.screen or awful.screen.focused(),
            title = preset.title or notification_title,
            timeout = preset.timeout or notification_timeout,
            text = table.concat {
                string.format(" 1min: %.2f\n", x.load_1 ),
                string.format(" 5min: %.2f\n", x.load_5 ),
                string.format("15min: %.2f"  , x.load_15),
            },
        }
    end)

    ---------------
    --  buttons  --
    ---------------

    subject.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            subject:show()
        end)
    )

    subject:update()
    return subject

end

return factory
