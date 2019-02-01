
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local yaawl = {

    audio = require("yaawl.brokers.audio"),
    battery = require("yaawl.brokers.battery"),
    brightness = require("yaawl.brokers.brightness"),
    cpu = require("yaawl.brokers.cpu"),
    drive = require("yaawl.brokers.drive"),
    loadavg = require("yaawl.brokers.loadavg"),
    lock = require("yaawl.brokers.lock"),
    memory = require("yaawl.brokers.memory"),
    net = require("yaawl.brokers.net"),
    temperature = require("yaawl.brokers.temperature"),
    updates = require("yaawl.brokers.updates"),
    users = require("yaawl.brokers.users"),
    weather = require("yaawl.brokers.weather"),

}

return yaawl
