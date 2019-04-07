
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")

local function factory(args)

    args                        = args or { }
    local step                  = args.step or 1

    local command               = string.format("pulsemixer --get-volume --get-mute")
    local commands              = { }
    commands.increase           = string.format("pulsemixer --change-volume +%d", step)
    commands.decrease           = string.format("pulsemixer --change-volume -%d", step)
    commands.set_min            = string.format("pulsemixer --set-volume 0")
    commands.set_max            = string.format("pulsemixer --set-volume 100")
    commands.toggle             = string.format("pulsemixer --toggle-mute")
    commands.on                 = string.format("pulsemixer --unmute")
    commands.off                = string.format("pulsemixer --mute")
    commands                    = gears.table.crush(commands, args.commands or { })

    local subject               = require("yaawl.subject")(commands)

    function subject:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                local l, r, s = string.match(stdout, "(%d+) (%d+)%c(%d)")
                context.percent = math.floor((l + r) / 2)
                context.muted = s == "1"
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
