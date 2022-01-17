
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local yaawl = {

    audio = require("yaawl.subject.audio"),
    battery = require("yaawl.subject.battery"),
    brightness = require("yaawl.subject.brightness"),
    cpu = require("yaawl.subject.cpu"),
    drive = require("yaawl.subject.drive"),
    loadavg = require("yaawl.subject.loadavg"),
    lock = require("yaawl.subject.lock"),
    memory = require("yaawl.subject.memory"),
    net = require("yaawl.subject.net"),
    ping = require("yaawl.subject.ping"),
    temperature = require("yaawl.subject.temperature"),
    udev = require("yaawl.subject.udev"),
    updates = require("yaawl.subject.updates"),
    users = require("yaawl.subject.users"),
    weather = require("yaawl.subject.weather"),

}

return yaawl
