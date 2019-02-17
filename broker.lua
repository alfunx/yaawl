
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]


--[[

    -------------
    --  USAGE  --
    -------------

    Override following functions:

    * broker:_update(context)

        This is the main update function. Calculate the needed values and assign
        them to the table `broker.context`. The table `context` must be passed
        to `broker:_apply()` after the values that should be available to the
        client have been assigned to it.

    * commands

        The required commands must be passed as an array in the `commands`
        table. Defined commands will be mapped to methods of the broker object.
        When calling any of those methods, the broker will, as a side effect,
        trigger an update and thus call all registered callbacks.

--]]

local awful = require("awful")
local gears = require("gears")

local function factory(commands)

    commands                    = commands or { }

    local broker                = { }
    broker.show_popup           = function() end
    broker.callbacks            = { }
    broker._notification        = nil

    local increase    = commands.increase or nil
    local decrease    = commands.decrease or nil
    local set_min     = commands.set_min or nil
    local set_max     = commands.set_max or nil
    local toggle      = commands.toggle or nil
    local on          = commands.on or nil
    local off         = commands.off or nil

    ----------------
    --  override  --
    ----------------

    function broker:_update(context) --luacheck: no unused
        -- override
    end

    --------------
    --  public  --
    --------------

    function broker:update(callback)
        local context = { }
        context._auto = true
        context._callback = callback
        self:_update(context)
    end

    function broker:show(callback)
        local context = { }
        context._auto = false
        context._callback = callback
        self:_update(context)
    end

    function broker:add_timer(timer_args)
        return gears.timer (gears.table.crush({
            autostart = true,
            callback = function()
                self:update()
            end,
        }, timer_args))
    end

    function broker:add_callback(callback)
        table.insert(self.callbacks, callback)
        return callback
    end

    function broker:remove_callback(callback)
        for i, c in ipairs(self.callbacks) do
            if c == callback then
                table.remove(self.callbacks, i)
                return c
            end
        end
        return nil
    end

    function broker:set_popup(popup_function)
        self.show_popup = popup_function
    end

    ---------------
    --  private  --
    ---------------

    function broker:_apply(context)
        for _, c in ipairs(self.callbacks) do
            c(context)
        end

        if context._callback then
            context._callback(context)
        end
    end

    -----------------
    --  functions  --
    -----------------

    if increase then
        function broker:increase()
            awful.spawn.easy_async(increase,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused args
                self:update()
                self.show_popup()
            end)
        end
    end

    if decrease then
        function broker:decrease()
            awful.spawn.easy_async(decrease,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused args
                self:update()
                self.show_popup()
            end)
        end
    end

    if set_min then
        function broker:set_min()
            awful.spawn.easy_async(set_min,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused args
                self:update()
                self.show_popup()
            end)
        end
    end

    if set_max then
        function broker:set_max()
            awful.spawn.easy_async(set_max,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused args
                self:update()
                self.show_popup()
            end)
        end
    end

    if toggle then
        function broker:toggle()
            awful.spawn.easy_async(toggle,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused args
                self:update()
                self.show_popup()
            end)
        end
    end

    if on then
        function broker:on()
            awful.spawn.easy_async(on,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused args
                self:update()
                self.show_popup()
            end)
        end
    end

    if off then
        function broker:off()
            awful.spawn.easy_async(off,
            function(stdout, stderr, reason, exit_code) --luacheck: no unused args
                self:update()
                self.show_popup()
            end)
        end
    end

    -----------
    --  end  --
    -----------

    return broker

end

return factory
