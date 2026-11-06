local component = require("component")
local gpu = component.gpu
local filesystem = require("filesystem")

local settings = require("config.settings")

local logger = {}

local function getRealTime()
    local tempfile = "/tmp/timefile"
    local file = filesystem.open(tempfile, "a")

    if not file then
        return os.time()
    end

    file:close()

    local timestamp = filesystem.lastModified(tempfile)
    filesystem.remove(tempfile)

    if not timestamp then
        return os.time()
    end

    return timestamp / 1000
end

local function get_timestamp()
    local timestamp = getRealTime()

    return os.date("%H:%M:%S", timestamp + 3600)
end

local function print_timestamp()
    gpu.setForeground(0x888888)

    io.write("[" .. get_timestamp() .. "]")

    gpu.setForeground(0xFFFFFF)
end

local colors = {
    INFO  = 0xCCCCCC, -- Light Gray
    WARN  = 0xFFAA00, -- Orange
    PROC  = 0x00BFFF, -- Deep Sky Blue
    FULL  = 0x6699CC, -- Blue Gray
    OKAY  = 0x00FF00, -- Lime
    FAIL  = 0xFF6666, -- Light Red
    ERROR = 0x990000, -- Dark Red
    DEBUG = 0x888888  -- Gray
}

function logger.fancy_log(text, level)
    if (level == "DEBUG" and not settings["show_debug_logs"]) then
        return
    end
    local color = colors[level] or 0xFFFFFF

    print_timestamp()

    gpu.setForeground(color)
    io.write("[" .. level .. "] ")

    gpu.setForeground(0xFFFFFF)
    io.write(text)

    print()
end

function logger.log(text)
    print(text)
end

return logger
