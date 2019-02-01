
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local _util = { }

-- Normalize date table
function _util.norm(date_table)
    return os.date("*t", os.time(date_table))
end

-- Shift timestamp according to timezone
function _util.adjust(timestamp, timezone)
    local date_table = os.date("*t", timestamp)
    date_table.hour = date_table.hour - timezone
    return os.time(_util.norm(date_table))
end

return _util
