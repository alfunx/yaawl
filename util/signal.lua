
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local _util = { }

-- Connect signal for exactly one call
function _util.connect_once(args)
    local kill_fn
    function kill_fn()
        args.fn()
        args.on.disconnect_signal(args.signal, kill_fn)
    end
    args.on.connect_signal(args.signal, kill_fn)
end

return _util
