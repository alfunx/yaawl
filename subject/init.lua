
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]


--[[

    -------------
    --  USAGE  --
    -------------

    Override following functions:

    * subject:_update(context)

        This is the main update function. Calculate the needed values and assign
        them to the table `subject.context`. The table `context` must be passed
        to `subject:_apply()` after the values that should be available to the
        client have been assigned to it.

    * commands

        The required commands must be passed as an array in the `commands`
        table. Defined commands will be mapped to methods of the subject object.
        When calling any of those methods, the subject will, as a side effect,
        trigger an update and thus call all registered callbacks.

--]]

local awful = require("awful")
local gears = require("gears")

local function factory(commands)

    commands                    = commands or { }

    local subject                = { }
    subject.callbacks            = { }
    subject.manual_callbacks     = { }
    subject._notification        = nil

    local increase    = commands.increase or nil
    local decrease    = commands.decrease or nil
    local increase_10 = commands.increase_10 or nil
    local decrease_10 = commands.decrease_10 or nil
    local set_min     = commands.set_min or nil
    local set_max     = commands.set_max or nil
    local toggle      = commands.toggle or nil
    local on          = commands.on or nil
    local off         = commands.off or nil

    ----------------
    --  override  --
    ----------------

    function subject:_update(context) --luacheck: no unused
        -- override
    end

    --------------
    --  public  --
    --------------

    function subject:update(context)
        context = context or { }
        context._auto = true
        self:_update(context)
    end

    function subject:show(context)
        context = context or { }
        context._auto = false
        self:_update(context)
    end

    function subject:add_timer(timer_args)
        return gears.timer(gears.table.crush({
            autostart = true,
            callback = function()
                self:update()
            end,
        }, timer_args))
    end

    function subject:add_callback(callback)
        table.insert(self.callbacks, callback)
        return callback
    end

    function subject:remove_callback(callback)
        local i = gears.table.find_first_key(self.callbacks, function(_, v)
            return v == callback
        end, true)
        if i then table.remove(self.callbacks, i) end
    end

    function subject:add_manual_callback(callback)
        table.insert(self.manual_callbacks, callback)
        return callback
    end

    function subject:remove_manual_callback(callback)
        local i = gears.table.find_first_key(self.manual_callbacks, function(_, v)
            return v == callback
        end, true)
        if i then table.remove(self.manual_callbacks, i) end
    end

    ---------------
    --  private  --
    ---------------

    function subject:_apply(context)
        for _, c in pairs(self.callbacks) do
            c(context)
        end

        if not context._auto then
            for _, c in pairs(self.manual_callbacks) do
                c(context)
            end
        end

        if context.callback then
            context.callback(context)
        end
    end

    -----------------
    --  functions  --
    -----------------

    local show = function(stdout, stderr, reason, exit_code) --luacheck: no unused
        subject:show()
    end

    if increase then
        function subject:increase()
            awful.spawn.easy_async(increase, show)
        end
    end

    if decrease then
        function subject:decrease()
            awful.spawn.easy_async(decrease, show)
        end
    end

    if increase_10 then
        function subject:increase_10()
            awful.spawn.easy_async(increase_10, show)
        end
    end

    if decrease_10 then
        function subject:decrease_10()
            awful.spawn.easy_async(decrease_10, show)
        end
    end

    if set_min then
        function subject:set_min()
            awful.spawn.easy_async(set_min, show)
        end
    end

    if set_max then
        function subject:set_max()
            awful.spawn.easy_async(set_max, show)
        end
    end

    if toggle then
        function subject:toggle()
            awful.spawn.easy_async(toggle, show)
        end
    end

    if on then
        function subject:on()
            awful.spawn.easy_async(on, show)
        end
    end

    if off then
        function subject:off()
            awful.spawn.easy_async(off, show)
        end
    end

    -----------
    --  end  --
    -----------

    return subject

end

return factory
