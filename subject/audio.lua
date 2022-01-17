
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local signal = require("yaawl.util.signal")

local function factory(args)

    args                        = args or { }
    local step                  = args.step or 1
    local subscribe             = args.subscribe or true

    local command               = string.format("pulsemixer --get-volume --get-mute")
    local commands              = { }
    commands.increase           = string.format("pulsemixer --change-volume +%d", step)
    commands.decrease           = string.format("pulsemixer --change-volume -%d", step)
    commands.increase_10        = string.format("pulsemixer --change-volume +%d", step * 10)
    commands.decrease_10        = string.format("pulsemixer --change-volume -%d", step * 10)
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
                local l, r, s = stdout:match("(%d+) (%d+)%c(%d)")
                context.percent = l and r and math.floor((l + r) / 2) or 0
                context.muted = s == "1"
                self:_apply(context)
            end
        )
    end

    -- Subscribe to notification
    if subscribe then
        local subscribe_cmd = [[
            sh -c 'pactl subscribe 2>/dev/null | grep --line-buffered "\(sink\|card\) #[0-9]*"'
        ]]
        awful.spawn.with_line_callback(subscribe_cmd, {
            stdout = function()
                subject:update()
            end
        })
        signal.connect_once {
            signal = "exit",
            on = awesome, --luacheck: ignore
            fn = function()
                awful.spawn("pkill -f 'pactl subscribe'")
            end,
        }
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

    ------------
    --  init  --
    ------------

    subject:update()
    return subject

end

return factory
