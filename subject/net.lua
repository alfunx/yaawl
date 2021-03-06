
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan
      * (c) 2013, Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local awful = require("awful")
local gears = require("gears")

local file = require("yaawl.util.file")

local function factory(args)

    args                        = args or { }
    local iface                 = args.iface or nil
    local timeout               = args.timeout or nil

    if not iface then
        gears.debug.print_warning("yaawl.net: Using io.popen to read net interfaces.")
        -- OK, since only executed for initialization
        local lines = gears.string.split(io.popen("ip link"):read("*all"), '\n')
        for _, line in ipairs(lines) do
            iface = iface or (not line:match("LOOPBACK") and line:match(" (%w+): "))
        end
    end

    local subject               = require("yaawl.subject")()
    local _last_t               = 0
    local _last_r               = 0

    function subject:_update(context)
        local now_t = tonumber(file.first_line(string.format("/sys/class/net/%s/statistics/tx_bytes", iface)) or 0)
        local now_r = tonumber(file.first_line(string.format("/sys/class/net/%s/statistics/rx_bytes", iface)) or 0)

        context.carrier = file.first_line(string.format("/sys/class/net/%s/carrier", iface)) or "0"
        context.state   = file.first_line(string.format("/sys/class/net/%s/operstate", iface)) or nil

        context.sent     = (now_t - _last_t) / timeout
        context.received = (now_r - _last_r) / timeout

        _last_t = now_t
        _last_r = now_r

        local devtype = file.first_line(string.format("/sys/class/net/%s/uevent", iface)):match("DEVTYPE=(%a+)")
        if context.carrier:match("1") then
            if devtype == "wlan" then
                context.wifi = true
                context.signal = tonumber(file.lines("/proc/net/wireless")[3]:match("(%-%d+%.)")) or nil
            else
                context.ethernet = true
            end
        end

        self:_apply(context)
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
    subject.timer = subject:add_timer { timeout = timeout }
    subject.add_timer = nil
    return subject

end

return factory
