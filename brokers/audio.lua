
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")

local function factory(args)

    args                        = args or { }
    local step                  = args.step or 1
    local channel               = args.channel or "Master"

    local command               = string.format("amixer get %s", channel)
    local commands              = { }
    commands.increase           = string.format("amixer -q set %s %d%%+", channel, step)
    commands.decrease           = string.format("amixer -q set %s %d%%-", channel, step)
    commands.set_min            = string.format("amixer -q set %s 0%%", channel)
    commands.set_max            = string.format("amixer -q set %s 100%%", channel)
    commands.toggle             = string.format("amixer -q set %s toggle", channel)
    commands.on                 = string.format("amixer -q set %s unmute", channel)
    commands.off                = string.format("amixer -q set %s mute", channel)
    commands                    = gears.table.crush(commands, args.commands or { })

    local broker                = require("yaawl.broker")(commands)

    function broker:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                local l, s = string.match(stdout, "(%d+)%%.*%[(%l*)%]")
                context.percent = tonumber(l)
                context.muted = s == "off"
                self:_apply(context)
            end
        )
    end

    ---------------
    --  buttons  --
    ---------------

    broker.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            broker:toggle()
        end),
        awful.button({                    }, 4, function()
            broker:decrease()
        end),
        awful.button({                    }, 5, function()
            broker:increase()
        end),
        awful.button({ "Control"          }, 4, function()
            broker:set_min()
        end),
        awful.button({ "Control"          }, 5, function()
            broker:set_max()
        end),
        awful.button({ "Control"          }, 1, function()
            broker:off()
        end),
        awful.button({ "Control"          }, 3, function()
            broker:on()
        end)
    )

    broker:update()
    return broker

end

return factory
