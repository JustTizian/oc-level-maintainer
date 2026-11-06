local component = require("component")
local me_interface = component.me_interface

local logger = require("src.logger")
local utils = require("utils.utils")
local number_parser = require("utils.number_parser")

local function validate_and_format_entry(label, values)
    local batch_size = number_parser.parse(values[1])
    local threshold = number_parser.parse(values[2])

    local name = values[3] and values[3][1]
    local damage = values[3] and values[3][2]

    local success
    local craftable

    -- validate batch_size
    if (not batch_size or type(batch_size) ~= "number" or batch_size < 1) then
        print("batch_size for " .. label .. " invalid, skipping entry..")
        return false, "invalid batch_size"
    end

    -- validate threshold
    if (threshold and (type(threshold) ~= "number" or threshold < 1)) then
        print("threshold for " .. label .. " invalid, skipping entry..")
        return false, "invalid threshold"
    end

    -- if provided, validate name and damage, and than try to find craftable for item based on it
    if (name and type(name) == "string" and damage and type(damage) == "number") then
        success, craftable = pcall(me_interface.getCraftable, { name = name, damage = damage }, "item")
        if (success) then
            logger.fancy_log("Found craftable for " .. label .. " via name and damage (item)", "DEBUG")
            return true, {
                batch_size = batch_size,
                threshold = threshold,
                name = name,
                damage = damage,
                craftable = craftable,
                uid = utils.concat_uid(name, damage)
            }
        end
        logger.fancy_log("Could not find craftable for " .. label .. " via name and damage (item)", "DEBUG")
    end

    -- if provided, validate name and damage, and than try to find craftable for fluid based on it
    if (name and type(name) == "string") then
        success, craftable = pcall(me_interface.getCraftable, { name = name, damage = damage }, "fluid")
        if (success) then
            logger.fancy_log("Found craftable for " .. label .. " via only name (fluid)", "DEBUG")
            return true, {
                batch_size = batch_size,
                threshold = threshold,
                name = name,
                damage = damage,
                craftable = craftable,
                uid = name
            }
        end
        logger.fancy_log("Could not find craftable for " .. label .. " via only name (fluid)", "DEBUG")
    end

    craftable = me_interface.getCraftables({ label = label })[1]

    if (not craftable) then
        logger.fancy_log("Craftable for " .. label .. " could not be found with the provided information", "DEBUG")
        return false, "no craftable found"
    end

    logger.fancy_log("Craftable for " .. label .. " found by label", "DEBUG")

    local stack = craftable.getStack()

    return true, {
        batch_size = batch_size,
        threshold = threshold,
        name = stack.name,
        damage = stack.damage,
        craftable = craftable,
        uid = utils.concat_uid(stack.name, stack.damage)
    }
end

return function(config)
    local loaded_config = {}
    local successful_labels = {}
    local failed_labels = {}

    for label, values in pairs(config) do
        -- don't let a successful label be overwritten by a second entry
        if (not successful_labels[label]) then
            local success, result = validate_and_format_entry(label, values)
            if (success) then
                loaded_config[label] = result
                successful_labels[label] = true
                -- in case a prior entry with same label failed
                if (failed_labels[label]) then
                    failed_labels[label] = nil
                end
            else
                failed_labels[label] = result
            end
        else

        end
    end

    return loaded_config, successful_labels, failed_labels
end
