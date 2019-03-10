
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

    local subject               = require("yaawl.subject")(commands)

    function subject:_update(context)
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

    subject.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            subject:toggle()
        end),
        awful.button({                    }, 4, function()
            subject:decrease()
        end),
        awful.button({                    }, 5, function()
            subject:increase()
        end),
        awful.button({ "Control"          }, 4, function()
            subject:set_min()
        end),
        awful.button({ "Control"          }, 5, function()
            subject:set_max()
        end),
        awful.button({ "Control"          }, 1, function()
            subject:off()
        end),
        awful.button({ "Control"          }, 3, function()
            subject:on()
        end)
    )

    subject:update()
    return subject

end

return factory
