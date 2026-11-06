local component = require("component")
local gpu = component.gpu
local filesystem = require("filesystem")

local settings = require("settings")

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
    OKAY = 0x00FF00,  -- green
    WARN = 0xFFFF00,  -- yellow
    FAIL = 0xFF5555,  -- light red
    SKIP = 0x00AAAA,  -- persian green
    INFO = 0xFFFFFF,  --white
    DEBUG = 0x800080, -- purple
    ERROR = 0x8B0000  -- dark red
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
