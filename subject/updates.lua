
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local function factory(args)

    args                        = args or { }
    local command               = args.command or "checkupdates"

    -- Example commands:
    -- Arch Linux:  checkupdates | sed 's/->/→/' | sort | column -t -c 70 -T 2,4
    -- Fedora:      dnf check-update --quiet
    -- Debian:      apt-show-versions -u
    -- pip:         pip list --outdated --format=legacy

    local notify                = args.notify or false
    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 20
    local notification_title    = args.notification_timeout or "Updates"
    local _notification         = nil

    local subject               = require("yaawl.subject")()
    local _last                 = -1

    function subject:_update(context)
        awful.spawn.easy_async_with_shell(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                context.text = stdout:gsub('[\r\n%s]*$', '')
                context.count = context.text == "" and 0 or gears.string.linecount(context.text)
                context.last = _last
                _last = context.count
                self:_apply(context)
            end
        )
    end

    subject:add_callback(function(x)
        if x._auto and (not notify or x.count <= x.last) then return end

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
