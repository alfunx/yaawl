
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")

local function factory(args)

    args                        = args or { }
    local step                  = args.step or 1

    local command               = string.format("light -G")
    local commands              = { }
    commands.increase           = string.format("light -A %d", step)
    commands.decrease           = string.format("light -U %d", step)
    commands.set_min            = string.format("light -Sr 1")
    commands.set_max            = string.format("light -S 100")
    commands                    = gears.table.crush(commands, args.commands or { })

    local broker                = require("yaawl.broker")(commands)

    function broker:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                context.text = math.floor(stdout) .. "%"
                context.percent = math.floor(stdout)
                self:_apply(context)
            end
        )
    end

    ---------------
    --  buttons  --
    ---------------

    broker.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            broker:show_popup()
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
            broker:set_min()
        end),
        awful.button({ "Control"          }, 3, function()
            broker:set_max()
        end)
    )

    broker:update()
    return broker

end

return factory
