
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan
      * (c) 2018, Uli Schlacter
      * (c) 2018, Otto Modinos
      * (c) 2013, Luca CPZ

--]]

local math = math

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")

local gio = require("lgi").Gio

local query_size = gio.FILE_ATTRIBUTE_FILESYSTEM_SIZE
local query_free = gio.FILE_ATTRIBUTE_FILESYSTEM_FREE
local query_used = gio.FILE_ATTRIBUTE_FILESYSTEM_USED
local query = query_size .. "," .. query_free .. "," .. query_used

local function factory(args)

    args                        = args or { }
    local partition             = args.partition
    local threshold             = args.threshold or 99

    local notify                = args.notify or true
    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 20
    local notification_title    = args.notification_timeout or "Drive"
    local _notification         = nil

    local broker                = require("yaawl.broker")()
    local units                 = { "KB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB" }

    function broker:_update(context)
        local notifytable = { string.format("<i>%-10s %-5s %s\t%s\t</i>", "path", "used", "free", "size") }
        local pathlen = 10

        for _, mount in pairs(gio.unix_mounts_get()) do
            local path = gio.unix_mount_get_mount_path(mount)
            local root = gio.File.new_for_path(path)
            local info = root:query_filesystem_info(query)

            if info then
                local size = info:get_attribute_uint64(query_size)
                local used = info:get_attribute_uint64(query_used)
                local free = info:get_attribute_uint64(query_free)

                if size > 0 then
                    local unit = math.floor(math.log(size)/math.log(1024))

                    context[path] = {
                        units   = units[unit],
                        percent = math.floor(100 * used / size), -- used percent
                        size    = size / math.pow(1024, math.floor(unit)),
                        used    = used / math.pow(1024, math.floor(unit)),
                        free    = free / math.pow(1024, math.floor(unit))
                    }

                    if context[path].percent > 0 then -- don't notify unused file systems
                        notifytable[#notifytable+1] = string.format("\n%-10s %-5s %.2f\t%.2f\t%s", path,
                        context[path].percent .. "%", context[path].free, context[path].size,
                        context[path].units)

                        pathlen = math.max(pathlen, #path)
                    end
                end
            end
        end

        if pathlen > 10 then -- formatting aesthetics
            for i = 1, #notifytable do
                local pathspaces = notifytable[i]:match("/%w*[/%w*]*%s*") or notifytable[i]:match("path%s*")
                notifytable[i] = notifytable[i]:gsub(pathspaces, pathspaces .. string.rep(" ", pathlen - 10) .. "\t")
            end
        end

        if partition then context.percent = context[partition].percent end
        context.text = table.concat(notifytable)

        self:_apply(context)
    end

    broker:add_callback(function(x)
        if x._auto then return end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = preset,
            screen = preset.screen or awful.screen.focused(),
            title = preset.title or notification_title,
            timeout = preset.timeout or notification_timeout,
            text = x.text,
        }
    end)

    broker:add_callback(function(x)
        if not partition or x.percent < threshold or not notify then return end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = naughty.config.presets.critical,
            screen = preset.screen or awful.screen.focused(),
            title = "Drive Full",
            timeout = 0,
            text = string.format("%s is above %d%% (%d%%)", partition, threshold, x[partition].percent),
        }
    end)

    ---------------
    --  buttons  --
    ---------------

    broker.buttons = gears.table.join(
        awful.button({                    }, 1, function()
            broker:show()
        end)
    )

    broker:update()
    return broker

end

return factory
