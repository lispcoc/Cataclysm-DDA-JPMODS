local MOD = {}

mods["StatsDopeChems"] = MOD

local take_count = 0

function MOD.on_new_player_created()
    player:set_value("SDC_COUNT", tostring(take_count))
    player:set_value("SDC_REB", tostring(take_count))
    player:set_value("SDC_STR_GAIN", tostring(take_count))
    player:set_value("SDC_DEX_GAIN", tostring(take_count))
    player:set_value("SDC_INT_GAIN", tostring(take_count))
    player:set_value("SDC_PER_GAIN", tostring(take_count))
end

