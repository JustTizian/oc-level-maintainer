local utils = {}

function utils.concat_uid(name, damage)
    if (not damage) then
        return name
    end
    return name .. ":" .. damage
end

return utils
