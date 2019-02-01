
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local awful = require("awful")
local gears = require("gears")
local naughty = require("naughty")
local file = require("yaawl.util.file")
local json = require("yaawl.util").json

local function factory(args)

    args                        = args or { }
    local APPID                 = args.APPID

    if not APPID then
        gears.debug.print_error("yaawl.weather: No APPID provided.")
        return
    end

    local url_current           = "http://api.openweathermap.org/data/2.5/weather?APPID=%s&units=%s&lang=%s&id=%s&q=%s"
    local url_forecast          = "http://api.openweathermap.org/data/2.5/forecast/daily?APPID=%s&units=%s&lang=%s&id=%s&q=%s&cnt=%s"
    local url                   = args.url or args.forecast and url_forecast or url_current

    local units                 = args.units or "metric"
    local unit                  = units == "metric" and "°C" or "°F"
    local lang                  = args.lang or "en"
    local cnt                   = args.cnt or 5
    local city_id               = args.city_id or ""
    local query                 = args.query or ""
    local timeout               = args.timeout or 3600

    local preset                = args.preset or naughty.config.presets.normal
    local notification_timeout  = args.notification_timeout or 30
    local notification_title    = args.notification_timeout or "Weather"
    local _notification         = nil

    local broker                = require("yaawl.broker")()
    local _ts                   = "/tmp/awesomewm-yaawl-weather-ts"
    local _data                 = "/tmp/awesomewm-yaawl-weather-data"
    local _last                 = nil

    function broker:_update(context)
        if file.exists(_ts) and tonumber(file.first_line(_ts)) + timeout > os.time() then
            if not _last and file.exists(_data) then
                _last = json.decode(file.first_line(_data))
            elseif not _last and not file.exists(_data) then
                -- Should not happen, async call is probably being processed
                gears.debug.print_warning("yaawl.weather: Async call is probably being processed.")
                return
            end

            context.data = _last
            self:_apply(context)
            return
        end

        -- Write new timestamp
        file.write(_ts, os.time())

        local u = string.format(url, APPID, units, lang, city_id, query, cnt)
        awful.spawn.easy_async(string.format("curl -s '%s'", u),
            function(stdout, stderr, reason, exit_code) --luacheck: no unused
                if exit_code == 0 then
                    file.write(_data, stdout)
                    _last = json.decode(stdout)
                end

                context.data = _last
                self:_apply(context)
            end
        )
    end

    function broker:is_error()
        return not _last or _last.cod ~= 200
    end

    local cardinal_direction
    do
        local dir = {
            "N",
            "NNE",
            "NE",
            "ENE",
            "E",
            "ESE",
            "SE",
            "SSE",
            "S",
            "SSW",
            "SW",
            "WSW",
            "W",
            "WNW",
            "NW",
            "NNW",
            "N",
        }

        cardinal_direction = function(degrees)
            if not degrees then return "N/A" end
            return dir[math.floor((degrees % 360) / 22.5) + 1]
        end
    end

    broker:add_callback(function(x)
        if x._auto then return end

        naughty.destroy(_notification)
        _notification = naughty.notify {
            preset = preset,
            screen = preset.screen or awful.screen.focused(),
            title = preset.title or notification_title,
            timeout = preset.timeout or notification_timeout,
            text = string.format("%s <i>(%s)</i>\n\n", x.data.weather[1].main, x.data.weather[1].description)
                .. string.format("Temperature: %s%s\n", x.data.main.temp, unit)
                .. string.format("Range:       %s - %s%s\n", x.data.main.temp_min, x.data.main.temp_max, unit)
                .. string.format("Humidity:    %s%%\n", x.data.main.humidity)
                .. string.format("Pressure:    %shPa\n", x.data.main.pressure)
                .. string.format("Clouds:      %s%%\n", x.data.clouds.all)
                .. string.format("Wind:        %sm/s (%s)\n\n", x.data.wind.speed, cardinal_direction(x.data.wind.deg))
                .. string.format("Sunrise:     %s\n", os.date("%H:%M", x.data.sys.sunrise))
                .. string.format("Sunset:      %s", os.date("%H:%M", x.data.sys.sunset)),
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
