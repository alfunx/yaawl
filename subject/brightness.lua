
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

    local subject               = require("yaawl.subject")(commands)

    function subject:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                context.percent = math.floor(stdout)
                self:_apply(context)
            end
        )
    end

    ---------------
    --  buttons  --
    ---------------

    subject.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            subject:show_popup()
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
            subject:set_min()
        end),
        awful.button({ "Control"          }, 3, function()
            subject:set_max()
        end)
    )

    subject:update()
    return subject

end

return factory
