
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local _util = { }

-- {{{ Byte - Bit
function _util.to_bit(x)
    return x * 8
end

function _util.bit_to_byte(x)
    return x / 8
end
-- }}}

-- {{{ Byte - Kilobyte (KB)
function _util.to_kb(x)
    return x / 1000  -- 1000^1
end

function _util.kb_to_byte(x)
    return x * 1000  -- 1000^1
end
-- }}}

-- {{{ Byte - Megabyte (MB)
function _util.to_mb(x)
    return x / 1000000  -- 1000^2
end

function _util.mb_to_byte(x)
    return x * 1000000  -- 1000^2
end
-- }}}

-- {{{ Byte - Gigabyte (GB)
function _util.to_gb(x)
    return x / 1000000000  -- 1000^3
end

function _util.gb_to_byte(x)
    return x * 1000000000  -- 1000^3
end
-- }}}

-- {{{ Byte - Kibibyte (KiB)
function _util.to_kib(x)
    return x / 1024  -- 1024^1
end

function _util.kib_to_byte(x)
    return x * 1024  -- 1024^1
end
-- }}}

-- {{{ Byte - Mebibyte (MiB)
function _util.to_mib(x)
    return x / 1048576  -- 1024^2
end

function _util.mib_to_byte(x)
    return x * 1048576  -- 1024^2
end
-- }}}

-- {{{ Byte - Gigibyte (GiB)
function _util.to_gib(x)
    return x / 1073741824  -- 1024^3
end

function _util.gib_to_byte(x)
    return x * 1073741824  -- 1024^3
end
-- }}}

return _util
