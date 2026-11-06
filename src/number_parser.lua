local settings = require("config.settings")

local number_parser = {}

-- Settings
local MAX_VALUE = 4.5e15
local FORMAT_THRESHOLD = settings["formatting_threshold"]
local format_option = settings["format_option"]

local multipliers = {
    K = 1e3,
    M = 1e6,
    G = 1e9,
    T = 1e12,
    P = 1e15
}

-- Validate final numeric result
local function validate_result(value)
    if value ~= value or value == math.huge or value == -math.huge then
        return nil, "Number is outside the supported range"
    end

    if value < 0 or value % 1 ~= 0 then
        return nil, "Quantity must be a non-negative integer"
    end

    if value > MAX_VALUE then
        return nil, "Quantity exceeds maximum supported value"
    end

    return value
end

-- Parse input
function number_parser.parse(input)
    if type(input) == "number" then
        return validate_result(input)
    end

    if type(input) ~= "string" then
        return nil, "Input must be a string or number"
    end

    -- Remove whitespace
    input = input:gsub("%s+", "")

    if input == "" then
        return nil, "Input is empty"
    end

    -- Extract optional suffix
    local suffix = input:match("([A-Z])$")
    local multiplier = 1

    if suffix then
        multiplier = multipliers[suffix]

        if not multiplier then
            return nil, "Unknown suffix"
        end

        input = input:sub(1, -2)
    end

    -- Validate underscore placement
    if input:find("__") or
        input:match("^_") or
        input:match("_$") or
        input:find("_%D") or
        input:find("%D_") then
        return nil, "Invalid underscore placement"
    end

    -- Validate number format
    local valid =
        input:match("^%d[%d_]*$") or
        input:match("^%d[%d_]*e[+-]?%d+$") or
        input:match("^%d[%d_]*%.%d[%d_]*e[+-]?%d+$") or
        (suffix and input:match("^%d[%d_]*%.%d[%d_]*$"))

    if not valid then
        return nil, "Invalid number format"
    end

    -- Remove underscores
    input = input:gsub("_", "")

    local value = tonumber(input)

    if not value then
        return nil, "Could not convert number"
    end

    value = value * multiplier

    return validate_result(value)
end

-- Remove unnecessary trailing decimal zeros
local function trim_decimal(value)
    return value:gsub("(%..-)0+$", "%1"):gsub("%.$", "")
end

-- Plain formatting
local function format_plain(value)
    return string.format("%.0f", value)
end

-- Underscore-separated formatting
local function format_separated(value)
    local number = format_plain(value)

    local result = number:reverse():gsub("(%d%d%d)", "%1_")
    result = result:reverse():gsub("^_", "")

    return result
end

-- Scientific formatting
local function format_scientific(value)
    if value < FORMAT_THRESHOLD then
        return format_plain(value)
    end

    local number = string.format("%.2e", value)

    local mantissa, exponent =
        number:match("^(.-)e([+-]?%d+)$")

    mantissa = trim_decimal(mantissa)
    exponent = tostring(tonumber(exponent))

    local formatted = mantissa .. "e" .. exponent

    if tonumber(formatted) ~= value then
        formatted = "~" .. formatted
    end

    return formatted
end

-- Suffix formatting
local function format_suffix(value)
    if value < FORMAT_THRESHOLD then
        return format_plain(value)
    end

    local suffixes = {
        { 1e15, "P" },
        { 1e12, "T" },
        { 1e9,  "G" },
        { 1e6,  "M" },
        { 1e3,  "K" }
    }

    for _, entry in ipairs(suffixes) do
        local multiplier = entry[1]
        local suffix = entry[2]

        if value >= multiplier then
            local formatted = string.format("%.2f", value / multiplier)
            formatted = trim_decimal(formatted)

            local result = formatted .. suffix

            if tonumber(formatted) * multiplier ~= value then
                result = "~" .. result
            end

            return result
        end
    end

    return format_plain(value)
end

-- Public formatter
function number_parser.format(value)
    local valid, reason = validate_result(value)

    if not valid then
        return nil, reason
    end

    local formats = {
        plain = format_plain,
        separated = format_separated,
        scientific = format_scientific,
        suffix = format_suffix
    }

    local formatter = formats[format_option]

    if not formatter then
        return nil, "Unknown format option"
    end

    return formatter(valid)
end

return number_parser
