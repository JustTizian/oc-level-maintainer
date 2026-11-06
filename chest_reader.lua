local component = require("component")
local inventory_controller = component.inventory_controller

local chest_reader = {}

function chest_reader.get_stacks(direction)
    local stack_slot = inventory_controller.getAllStacks(direction)

    if (not stack_slot) then
        return {}
    end

    local stack = stack_slot()

    local stacks = {}
    while stack do
        if (stack.name) then
            table.insert(stacks, stack)
        end
        stack = stack_slot()
    end

    return stacks
end

local output = chest_reader.get_stacks(1)
for index, stack in ipairs(output) do
    for key, value in pairs(stack) do
        print(key, value)
    end
end

return chest_reader
