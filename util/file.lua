
--[[

     Licensed under GNU General Public License v2
      * (c) 2019, Alphonse Mariyagnanaseelan

--]]

local _util = { }

-- Read lines from file into table
function _util.lines(path)
    local lines = { }
    for line in io.lines(path) do
        table.insert(lines, line)
    end
    return lines
end

-- Read lines from file matching regex into table
function _util.lines_match(path, regex)
    local lines = {}
    for line in io.lines(path) do
        if string.match(line, regex) then
            table.insert(lines, line)
        end
    end
    return lines
end

-- File exists and is readable
function _util.exists(path)
    local file = io.open(path, "rb")
    if file then file:close() end
    return file ~= nil
end

-- Read first line of files
function _util.first_line(path)
    if type(path) ~= "table" then
        local content
        local file = io.open(path, "rb")
        if file then
            content = file:read("*l")
            file:close()
        end
        return content
    end

    local content = { }
    for k, p in pairs(path) do
        local file = io.open(p, "rb")
        if file then
            content[k] = file:read("*l")
            file:close()
        end
    end
    return content
end

-- Read first non-empty line from files
function _util.first_nonempty_line(path)
    if type(path) ~= "table" then
        for line in io.lines(path) do
            if #line then return line end
        end
        return nil
    end

    local content = { }
    for k, p in pairs(path) do
        for line in io.lines(p) do
            if #line then
                content[k] = line
                break
            end
        end
    end
    return content
end

-- Write string to file
function _util.write(path, text)
    local out = io.open(path, 'w')
    out:write(text)
    out:close()
end

return _util
