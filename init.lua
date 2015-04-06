-- API
dofile(minetest.get_modpath("slimes").."/api.lua")

-- SLIMES
dofile(minetest.get_modpath("slimes").."/greenslimes.lua")
dofile(minetest.get_modpath("slimes").."/lavaslimes.lua")
--dofile(minetest.get_modpath("slimes").."/waterslimes.lua")

if minetest.setting_get("log_mods") then minetest.log("action", "Slimes loaded") end
damage_enabled = minetest.setting_getbool("enable_damage")

