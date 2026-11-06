local component = require("component")
local me_interface = component.me_interface

local ae2_helpers = {}

function ae2_helpers.get_stock(properties)
    if (properties.damage) then
        local item_in_network = me_interface.getItemInNetwork(properties.name, properties.damage)
        return item_in_network.size
    else
        local fluid_in_network = me_interface.getFluidInNetwork(properties.name)
        return fluid_in_network.amount
    end
end

function ae2_helpers.get_active_crafts_outputs()
    local cpus = me_interface.getCpus()
    local crafts_outputs = {}

    for _, v in pairs(cpus) do
        local cpu_info = v.cpu
        if cpu_info.isBusy() then
            local final_output = cpu_info.finalOutput()

            local uid = final_output.name
            if (final_output.damage) then
                uid = uid .. ":" .. final_output.damage
            end
            crafts_outputs[uid] = true
        end
    end

    return crafts_outputs
end

return ae2_helpers
