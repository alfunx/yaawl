
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan
      * (c) 2013, Luca CPZ

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local file = require("yaawl.util.file")

local function factory(args)

    args                        = args or { }
    local path                  = args.path or "/sys/class/thermal/thermal_zone0/temp"

    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or nil
    local notification_title    = args.notification_timeout or "Temperature"
    local _notification         = nil

    local subject               = require("yaawl.subject")()

    function subject:_update(context)
        local line = file.first_line(path)
        context.temp = tonumber(line) / 1000
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
            text = string.format("%.1f°C", x.temp),
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
