
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local function factory(args)

    args                        = args or { }
    local signals               = args.signals or false
    local on                    = args.on or "xset s on && xautolock -enable"
    local off                   = args.off or "xset s off && xautolock -disable"
    local lock                  = args.lock or "sync && xautolock -locknow"
    local command               = args.command or "xset q"

    local preset                = args.preset or naughty.config.presets.normal
    local notification_title    = args.notification_timeout or "Lock"
    local _notification         = nil

    local broker                = require("yaawl.broker")()
    local enabled               = true
    local manual                = false

    function broker:_update(context)
        awful.spawn.easy_async(command,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                context.enabled = tonumber(string.match(stdout, "timeout:%s*(%d+)")) ~= 0
                enabled = context.enabled

                if exit_code ~= 0 or (stderr and stderr ~= "") then
                    naughty.destroy(_notification)
                    _notification = naughty.notify {
                        preset = naughty.config.presets.critical,
                        screen = preset.screen or awful.screen.focused(),
                        title = notification_title,
                        timeout = 0,
                        text = "Failed!\n" .. stderr,
                    }
                end

                self:_apply(context)
            end
        )
    end

    -----------------
    --  functions  --
    -----------------

    function broker:on(m)
        if manual and not m then return end
        manual = false
        if enabled then return end
        awful.spawn.easy_async_with_shell(on, function() self:update() end)
    end

    function broker:off(m)
        if manual and not m then return end
        manual = m and true
        if not enabled then return end
        awful.spawn.easy_async_with_shell(off, function() self:update() end)
    end

    function broker:lock()
        awful.spawn.easy_async_with_shell(lock, function() self:update() end)
    end

    ---------------
    --  buttons  --
    ---------------

    broker.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            if enabled then broker:off(true) else broker:on(true) end
        end)
    )

    ---------------
    --  signals  --
    ---------------

    if signals then
        client.connect_signal("focus", function(c)
            if c.fullscreen then
                broker:off()
            else
                broker:on()
            end
        end)

        client.connect_signal("property::fullscreen", function(c)
            if c.fullscreen then
                broker:off()
            else
                broker:on()
            end
        end)

        screen.connect_signal(("tag::history::update"), function()
            if not client.focused then
                broker:on()
            end
        end)
    end

    broker:update()
    return broker

end

return factory
