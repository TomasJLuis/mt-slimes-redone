-- sounds
local green_sounds = {
	damage = { file = "green_slime_damage", gain = 0.25},
	death = { file = "green_slime_death", gain = 0.25},
	jump = { file = "green_slime_jump", gain = 0.25},
	land = { file = "green_slime_land", gain = 0.25},
	attack = { file = "green_slime_attack", gain = 0.25},
	random = {}
}
-- textures: top, bottom, front, back, left, right
local green_textures = {"green_slime_top.png", "green_slime_bottom.png", "green_slime_front.png", "green_slime_sides.png", "green_slime_sides.png", "green_slime_sides.png"}

slimes:register_slime ("slimes:greenbig", {
	name = "slimes:greenbig",
	type = "monster",
	class = "green",
	passive = false,
	size = 2,
	textures = green_textures,
	blood = "green_slime_blood.png",
	gravity = 9.8,
	min_hp = 4,
	max_hp = 6,
	damage = 2,
	sounds = green_sounds,
	drops = {	
		type = "entity",
		name = "slimes:greenmedium",
		chance = 0, min = 1, max = 2},
	-- damage by
	water_damage = 0,
	lava_damage = 10,
	light_damage = 0,
	fall_damage = 0,
	-- spawn block
	spawn = "default:junglegrass"
})
slimes:register_slime ("slimes:greenmedium", {
	name = "slimes:greenmedium",
	type = "monster",
	class ="green",
	passive = false,
	size = 1,
	min_hp = 3,
	max_hp = 4,
	damage = 1,
	sounds = green_sounds,
	textures = green_textures,
	blood = "green_slime_blood.png",
	gravity = 9.8,
	drop = "",
	drops = {
		type = "entity",
		name = "slimes:greensmall",
		chance = 0, min = 2, max = 4},
	-- damage by
	water_damage = 0,
	lava_damage = 10,
	light_damage = 0,
	fall_damage = 0,
	spawn = "default:junglegrass"
})
slimes:register_slime ("slimes:greensmall", {
	name = "slimes:greensmall",
	type = "monster",
	class ="green",
	passive = false,
	size = 0.5,
	min_hp = 1,
	max_hp = 2,
	damage = 1,
	sounds = green_sounds,
	textures = green_textures,
	blood = "green_slime_blood.png",
	gravity = 9.8,
	drop = "mesecons_materials:glue 1",
	drops = {
		type = "item",
		name = "mesecons_materials:glue 1",
		chance = 4, min = 1, max = 2},
	-- damage by
	water_damage = 0,
	lava_damage = 10,
	light_damage = 0,
	fall_damage = 0,
	spawn = "default:junglegrass"
})

slimes:register_spawn("slimes:greenbig", {"default:junglegrass"},{"air","default:junglegrass"}, 20, 4, 5000, 8, 32000)
slimes:register_spawn("slimes:greenmedium", {"default:junglegrass"},{"air","default:junglegrass"}, 20, 4, 10000, 8, 32000)
slimes:register_spawn("slimes:greensmall", {"default:junglegrass"},{"air","default:junglegrass"}, 20, 4, 15000, 8, 32000)
slimes:register_spawn("slimes:greenmedium", {"default:mossycobble"},{"air"}, 20, 4, 10000, 8, 32000)
slimes:register_spawn("slimes:greensmall", {"default:mossycobble"},{"air"}, 20, 4, 10000, 8, 32000)

