
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
local unit = require("yaawl.util.unit")

local function factory(args)

    args                        = args or { }

    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 10
    local notification_title    = args.notification_timeout or "Memory"
    local _notification         = nil

    local subject               = require("yaawl.subject")()
    local struct                = gtop.glibtop_mem()
    local struct_swap           = gtop.glibtop_swap()

    function subject:_update(context)
        gtop.glibtop_get_mem(struct)
        gtop.glibtop_get_swap(struct_swap)

        context.total  = struct.total
        context.free   = struct.free
        context.shared = struct.shared
        context.buffer = struct.buffer
        context.cached = struct.cached
        context.user   = struct.user
        context.locked = struct.locked
        context.swap   = struct_swap

        context.available = struct.total - struct.user
        context.used      = struct.used - struct.buffer - struct.cached
        context.percent   = math.floor(context.used / context.total * 100)

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
                string.format("Total:      %.2fGB\n",   unit.to_gb(x.total     )),
                string.format("Used:       %.2fGB\n",   unit.to_gb(x.used      )),
                string.format("Free:       %.2fGB\n",   unit.to_gb(x.free      )),
                string.format("Available:  %.2fGB\n",   unit.to_gb(x.available )),
                string.format("Shared:     %.2fGB\n",   unit.to_gb(x.shared    )),
                string.format("Buffer:     %.2fGB\n",   unit.to_gb(x.buffer    )),
                string.format("Cached:     %.2fGB\n\n", unit.to_gb(x.cached    )),
                string.format("Swap Total: %.2fGB\n",   unit.to_gb(x.swap.total)),
                string.format("Swap Used:  %.2fGB\n",   unit.to_gb(x.swap.used )),
                string.format("Swap Free:  %.2fGB",     unit.to_gb(x.swap.free )),
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
