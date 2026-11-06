local config = require("config.config")
local load_config = require("src.load_config")
local settings = require("config.settings")
local ae2_helpers = require("src.ae2_helpers")
local logger = require("src.logger")

local function is_already_crafting(properties, active_crafts_outputs)
    return active_crafts_outputs[properties.uid]
end

local function is_threshold_reached(properties)
    return properties.threshold and properties.threshold <= ae2_helpers.get_stock(properties)
end

local function should_send_craft_request(label, properties, active_crafts_outputs, paused)
    if (is_already_crafting(properties, active_crafts_outputs)) then
        logger.fancy_log(label .. " x" .. properties.batch_size .. " is already crafting", "PROC")
        return false
    end

    if (is_threshold_reached(properties)) then
        logger.fancy_log(label .. " threshold is already reached", "FULL")
        return false
    end

    return true
end

local function start(loaded_config)
    local cycle_counter = 1
    while true do
        local active_crafts_outputs = ae2_helpers.get_active_crafts_outputs()

        logger.fancy_log("Cycle #" ..
            cycle_counter .. " Time in between cycles: " .. settings["sleep_time_in_between_cycles"] .. " seconds",
            "INFO")

        for label, properties in pairs(loaded_config) do
            if (should_send_craft_request(label, properties, active_crafts_outputs)) then
                local craft_job = properties.craftable.request(properties.batch_size)
                while craft_job.isComputing() do
                    os.sleep(1)
                end

                if craft_job.hasFailed() then
                    logger.fancy_log(label .. " x" .. properties.batch_size .. " failed to request ", "FAIL")
                else
                    logger.fancy_log(label .. " x" .. properties.batch_size .. " successfully requested ", "OKAY")
                end
            end
        end
        print(string.rep("=", 100))
        cycle_counter = cycle_counter + 1
        os.sleep(settings["sleep_time_in_between_cycles"])
    end
end

local function init()
    print("Reading config please wait..")
    local loaded_config, successful_labels, failed_labels = load_config(config)

    if (not next(successful_labels)) then
        logger.fancy_log("No valid config entries found, exiting..", "ERROR")
        os.exit()
    end

    logger.log("Summary")
    logger.log(string.rep("=", 50))
    logger.log("Successfully registered:")
    for label, _ in pairs(successful_labels or {}) do
        logger.log(label)
    end
    logger.log(string.rep("=", 50))
    logger.log("Failed to register:")
    for label, reason in pairs(failed_labels or {}) do
        logger.log(label .. " (" .. reason .. ")")
    end
    logger.log(string.rep("=", 50))

    if (next(failed_labels) and not settings["skip_failed_entry_reads"]) then
        logger.log("At least one entry from the config couldn't be read meaning it" ..
            " won't be maintained, do you wanna start with only the successfully read entries?" ..
            " Than type \"yes\"")
        local response = io.read()
        if (response ~= "yes") then os.exit() end
    end

    start(loaded_config)
end

init()
