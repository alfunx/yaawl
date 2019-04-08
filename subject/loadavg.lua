
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan
      * (c) 2013, Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local gtop = require("lgi").GTop

local function factory(args)

    args                        = args or { }

    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 10
    local notification_title    = args.notification_timeout or "Load Average"
    local _notification         = nil

    local subject               = require("yaawl.subject")()
    local struct                = gtop.glibtop_loadavg()

    function subject:_update(context)
        gtop.glibtop_get_loadavg(struct)
        context.load_1 = tonumber(struct.loadavg[1])
        context.load_5 = tonumber(struct.loadavg[2])
        context.load_15 = tonumber(struct.loadavg[3])
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

    ------------
    --  init  --
    ------------

    subject:update()
    return subject

end

return factory
