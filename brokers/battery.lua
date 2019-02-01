
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local file = require("yaawl.util.file")

local function factory(args)

    args                        = args or { }
    local ps_path               = args.ps_path or "/sys/class/power_supply/"
    local battery               = args.battery or nil
    local ac                    = args.ac or nil
    local critical              = args.critical or 10

    local notify                = args.notify or false
    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 15
    local notification_title    = args.notification_timeout or "Battery"
    local _notification         = nil

    if not battery or not ac then
        gears.debug.print_warning("yaawl.battery: Using io.popen to read battery data.")
        -- OK, since only executed for initialization
        local lines = gears.string.split(io.popen("ls -1 " .. ps_path):read("*all"), '\n')
        for _, line in ipairs(lines) do
            battery = battery or string.match(line, "BAT%w+")
            ac = ac or string.match(line, "A%w+")
        end
    end

    local files = {
        capacity = ps_path .. battery .. "/capacity",
        status   = ps_path .. battery .. "/status",
        current  = ps_path .. battery .. "/current_now",
        voltage  = ps_path .. battery .. "/voltage_now",
        power    = ps_path .. battery .. "/power_now",
        ac       = ps_path .. ac      .. "/online",
    }

    local broker                = require("yaawl.broker")()

    function broker:_update(context)
        local t = file.first_line(files)

        context.percent = tonumber(t.capacity) or "N/A"
        context.status = t.status or "N/A"
        context.charging = t.status == "Charging"
        context.current = tonumber(t.current) or "N/A"
        context.voltage = tonumber(t.voltage) or "N/A"
        context.power = tonumber(t.power) or "N/A"
        context.ac = tonumber(t.ac) == 1

        self:_apply(context)
    end

    broker:add_callback(function(x)
        if x._auto and (not notify or x.percent > critical) then return end

        awful.spawn.easy_async_with_shell("acpi | grep -Po 'Battery 0: \\K.*'", function(stdout)
            naughty.destroy(_notification)
            _notification = naughty.notify {
                preset = preset,
                screen = preset.screen or awful.screen.focused(),
                title = preset.title or notification_title,
                timeout = preset.timeout or notification_timeout,
                text = stdout:gsub('[\r\n%s]*$', ''),
            }
        end)
    end)

    ---------------
    --  buttons  --
    ---------------

    broker.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            broker:show()
        end)
    )

    broker:update()
    return broker

end

return factory
