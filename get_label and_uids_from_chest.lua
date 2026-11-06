local chest_reader = require("utils.chest_reader")
local utils = require("utils.utils")

local stacks = chest_reader.get_stacks(1)

local output = {}

for _, stack in ipairs(stacks) do
    if (stack["fluid"] and stack["fluid"].name) then
        output[stack["fluid"].label] = stack["fluid"].name
    else
        output[stack.label] = utils.concat_uid(stack.name, stack.damage)
    end
end

local file = io.open("generated.txt", "w")
if (file) then
    for label, uid in pairs(output) do
        file:write(label .. " = " .. uid .. "\n")
    end

    file:close()
    return
end
print("Couldn't write entries to file")

return output
