
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan
      * (c) 2013, Luca CPZ
      * (c) 2010-2012, Peter Hofmann

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local file = require("yaawl.util.file")

local function factory(args)

    args                        = args or { }
    local cpu_path              = args.cpu_path or "/proc/stat"

    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 10
    local notification_title    = args.notification_timeout or "CPU"
    local _notification         = nil

    local subject               = require("yaawl.subject")()
    local _core                 = { }

    function subject:_update(context)
        local lines = file.lines_match(cpu_path, "^cpu")
        for i, line in ipairs(lines) do
            local core   = _core[i - 1] or { _active = 0 , _total = 0, percent = 0 }
            local at     = 1
            local idle   = 0
            local total  = 0

            for v in string.gmatch(line, "%s+(%S+)") do
                -- 4 = idle, 5 = ioWait
                -- Essentially, the CPUs have done nothing during these times.
                if at == 4 or at == 5 then
                    idle = idle + v
                end
                total = total + v
                at = at + 1
            end

            local active = total - idle

            if core._active ~= active or core._total ~= total then
                -- Read current data and calculate relative values.
                local dactive = active - core._active
                local dtotal  = total - core._total

                core._active = active
                core._total  = total
                core.percent = math.ceil((dactive / dtotal) * 100)

                -- Save current data for the next run.
                _core[i - 1] = core
            end
        end

        context.core = _core
        context.percent = _core[0].percent

        self:_apply(context)
    end

    local function _notification_text(core)
        local lines = { }
        for i, c in ipairs(core) do
            table.insert(lines, string.format("Core %d: %d%%", i, c.percent))
        end
        return table.concat(lines, '\n'):gsub('[\r\n%s]*$', '')
    end

    subject:add_callback(function(x)
        if x._auto then return end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = preset,
            screen = preset.screen or awful.screen.focused(),
            title = preset.title or notification_title,
            timeout = preset.timeout or notification_timeout,
            text = _notification_text(x.core),
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

    ------------
    --  init  --
    ------------

    subject:update()
    return subject

end

return factory
