
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan
      * (c) 2013, Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local function factory(args)

    args                        = args or { }
    local mem_path              = args.mem_path or "/proc/meminfo"

    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 10
    local notification_title    = args.notification_timeout or "Memory"
    local _notification         = nil

    local broker                = require("yaawl.broker")()

    function broker:_update(context)
        for line in io.lines(mem_path) do
            for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
                if     k == "MemTotal"     then context.total = math.floor(v / 1024 + 0.5)
                elseif k == "MemFree"      then context.free  = math.floor(v / 1024 + 0.5)
                elseif k == "Buffers"      then context.buf   = math.floor(v / 1024 + 0.5)
                elseif k == "Cached"       then context.cache = math.floor(v / 1024 + 0.5)
                elseif k == "SwapTotal"    then context.swap  = math.floor(v / 1024 + 0.5)
                elseif k == "SwapFree"     then context.swapf = math.floor(v / 1024 + 0.5)
                elseif k == "SReclaimable" then context.srec  = math.floor(v / 1024 + 0.5)
                end
            end
        end

        context.used = context.total - context.free - context.buf - context.cache - context.srec
        context.swapused = context.swap - context.swapf
        context.percent = math.floor(context.used / context.total * 100)

        self:_apply(context)
    end

    broker:add_callback(function(x)
        if x._auto then return end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = preset,
            screen = preset.screen or awful.screen.focused(),
            title = preset.title or notification_title,
            timeout = preset.timeout or notification_timeout,
            text = table.concat {
                string.format("Total:  %.2fGB\n", x.total / 1024 + 0.5),
                string.format("Used:   %.2fGB\n", x.used  / 1024 + 0.5),
                string.format("Free:   %.2fGB\n", x.free  / 1024 + 0.5),
                string.format("Buffer: %.2fGB\n", x.buf   / 1024 + 0.5),
                string.format("Cache:  %.2fGB\n", x.cache / 1024 + 0.5),
                string.format("Swap:   %.2fGB\n", x.swap  / 1024 + 0.5),
                string.format("Swapf:  %.2fGB\n", x.swapf / 1024 + 0.5),
                string.format("Srec:   %.2fGB"  , x.srec  / 1024 + 0.5),
            },
        }
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
