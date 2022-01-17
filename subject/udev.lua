
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local signal = require("yaawl.util.signal")

local function factory(args)

    args                        = args or { }
    local path                  = args.path or "/media"
    local subscribe             = args.subscribe or true

    local command               = string.format("find %s -maxdepth 1 -mindepth 1 -type d -printf '%%P\n'", path)
    local commands              = { }
    commands.umount             = string.format("udevil umount %s/%%s", path)
    commands                    = gears.table.crush(commands, args.commands or { })

    local subject               = require("yaawl.subject")(commands)

    function subject:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                context.devices = gears.string.split(stdout, '\n')
                self:_apply(context)
            end
        )
    end

    -- Subscribe to notification
    if subscribe then
        local subscribe_cmd = [[
            sh -c 'udevil monitor 2>/dev/null | grep --line-buffered "^changed:"'
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
                awful.spawn("pkill -f 'udevil monitor'")
            end,
        }
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
