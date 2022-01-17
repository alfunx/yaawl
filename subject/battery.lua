
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local upower = require("lgi").UPowerGlib

local const = {}

const.device_state = {
    [upower.DeviceState.UNKNOWN]           = "N/A",
    [upower.DeviceState.CHARGING]          = "Charging",
    [upower.DeviceState.DISCHARGING]       = "Discharging",
    [upower.DeviceState.EMPTY]             = "Empty",
    [upower.DeviceState.FULLY_CHARGED]     = "Full",
    [upower.DeviceState.PENDING_CHARGE]    = "Charging",
    [upower.DeviceState.PENDING_DISCHARGE] = "Discharging",
    [upower.DeviceState.LAST]              = "N/A",
}

local function to_clock(sec)
    if sec <= 0 then
        return "00:00:00"
    else
        local h = string.format("%02.f", math.floor(sec/3600))
        local m = string.format("%02.f", math.floor(sec/60 - 60 * h))
        local s = string.format("%02.f", math.floor(sec - 3600 * h - 60 * m))
        return table.concat { h, ":", m, ":", s }
    end
end

local function factory(args)

    local device = upower.Client():get_display_device()

    args                        = args or { }
    local critical              = args.critical or 10
    local subscribe             = args.subscribe or true

    local notify                = args.notify or false
    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 15
    local notification_title    = args.notification_timeout or "Battery"
    local _notification         = nil

    local subject               = require("yaawl.subject")()

    function subject:_update(context)
        context.device = device
        context.const = const

        context.percent = math.floor(device.percentage) or 0
        context.status = const.device_state[device.state]
        context.charging = context.status == "Charging"
        context.full = context.status == "Full"
        context.ac = device.kind == upower.DeviceKind.LINE_POWER

        if context.status == "Charging" then
            context.time = to_clock(device.time_to_full)
        elseif context.status == "Discharging" then
            context.time = to_clock(device.time_to_empty)
        else
            context.time = "N/A"
        end

        self:_apply(context)
    end

    subject:add_callback(function(x)
        if x._auto and (not notify or x.percent > critical) then return end

        local text = { x.status, ", ", x.percent, "%", }
        if x.status == "Charging" then
            table.insert(text, table.concat { ", ", x.time, " until charged" })
        elseif x.status == "Discharging" then
            table.insert(text, table.concat { ", ", x.time, " remaining" })
        end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = preset,
            screen = preset.screen or awful.screen.focused(),
            title = preset.title or notification_title,
            timeout = preset.timeout or notification_timeout,
            text = table.concat(text),
        }
    end)

    -- Subscribe to notification
    if subscribe then
        device.on_notify = function(d)
            device = d
            subject:update()
        end
    end

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
