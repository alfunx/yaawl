
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")

local function factory(args)

    args                        = args or { }
    local command               = args.command or "ping -c1 -w5 8.8.8.8"

    local subject               = require("yaawl.subject")()

    function subject:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                context.connected = exit_code == 0
                self:_apply(context)
            end
        )
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
    return subject

end

return factory
