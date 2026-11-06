-- ["label"] = {batch_size, threshold, {name, damage}}
return {
    ["ULV Machine Casing"] = { 16, 1000 },
    ["LV Machine Casing"] = { 16, 250 },
    ["MV Machine Casing"] = { 16, 1000 },
    ["HV Machine Casing"] = { 16, 1000 },
    ["EV Machine Casing"] = { 1, 1000 },
    ["IV Machine Casing"] = { 16, 1000, {"gregtech:gt.blockcasings", 5} },
    ["LuV Machine Casing"] = { 16, 1000 },
    ["ZPM Machine Casing"] = { 16, 1000 },
    ["UV Machine Casing"] = { 16, 1000 },
    ["Molten Polyethylene"] = { 1000, 10000 },
    ["TV Mahie Cain"] = { 160, 1000 }
}

--[[ return {
    -- clean entries
    ["ULV Machine Casing"] = { 100, 1000 },        -- with threshold
    ["LV Machine Casing"] = { 10 },                -- no threshold (allowed)
    ["MV Machine Hull"] = { 10, 1000,
        { "gregtech:gt.blockcasings", 2 } },       -- item with name and damage

    ["Molten Polyethylene"] = { 27648, 100000 },   -- fluid
    ["Molten Polyvinyl Chloride"] = { 13824, 50000,
        { "gregtech:molten.polyvinylchloride" } }, -- fluid with name

    -- trying to register a second entry under a successful label (should fail)
    ["ULV Machine Casing"] = { 100, 3000 },

    -- missformed entries
    ["HV Machine Casing"] = { -1, 1000 },              -- negative batch_size
    ["EV Machine Casing"] = { 10, -1 },                -- negative threshold
    ["IV Machine Casing"] = { 10, 64, { "invalid" } }, -- invalid name
    ["LuV Machine Casing"] = { 10, 1000,
        { "gregtech:blockmachines" } },                -- invalid name (due to item with no damage)

    ["ZPM Machine Casing"] = { 10, -10 },              -- failed due to negative threshold
    -- trying to register a second entry under a failed label (should work)
    ["ZPM Machine Casing"] = { 20, 32 },

    ["UV Machine Casing"] = { 10, 10, 2, 2 },        -- invalid name format
    ["UV Machine Casing"] = { 10, 10, { "2", "2" } } --invalid damage format
} ]]
