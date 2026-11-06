local component = require("component")
local inventory_controller = component.inventory_controller

local utils = require("utils.utils")

local chest_reader = {}

function chest_reader.get_stacks(direction)
    local stack_slot = inventory_controller.getAllStacks(direction)

    if (not stack_slot) then
        return {}, false
    end

    local stack = stack_slot()

    local stacks = {}
    while stack do
        if (stack.name) then
            table.insert(stacks, stack)
        end
        stack = stack_slot()
    end

    return stacks, true
end

function chest_reader.get_uid_lookup_table(direction)
    local stacks, chest_was_found = chest_reader.get_stacks(direction)

    local uid_lookup_table = {}
    for _, stack in pairs(stacks) do
        uid_lookup_table[utils.concat_uid(stack.name, stack.damage)] = true
    end
    return uid_lookup_table, chest_was_found
end

return chest_reader
