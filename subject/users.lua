
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local function factory(args)

    args                        = args or { }
    local command               = args.command or "users"

    local notify                = args.notify or false
    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or nil
    local notification_title    = args.notification_title or "Users"
    local _notification         = nil

    local subject               = require("yaawl.subject")()

    function subject:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                context.users = gears.string.split(stdout, ' ')
                context.count = #context.users
                context.text = table.concat(context.users, "\n"):gsub('[\r\n%s]*$', '')
                self:_apply(context)
            end
        )
    end

    subject:add_callback(function(x)
        if x._auto and (not notify or x.count <= 1) then return end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = preset,
            screen = preset.screen or awful.screen.focused(),
            title = preset.title or notification_title,
            timeout = preset.timeout or notification_timeout,
            text = x.count > 0 and x.text or "None",
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

    subject:update()
    return subject

end

return factory
