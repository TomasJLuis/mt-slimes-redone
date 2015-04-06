slimes = {}
function slimes:register_slime (name, def)
	
	local defbox = def.size/2
	minetest.register_entity(name,{
		initial_properties = {
			name = name,
			hp_max = def.max_hp,
			visual_size = {x = def.size, y = def.size, z = def.size},
			visual = "cube",
			textures = def.textures, -- top, bottom, front, back, left, right
			collisionbox = {-defbox, -defbox, -defbox, defbox, defbox, defbox},
			physical = true,
		},
		alpha = 160,
		timer = 6,
		timer2 = 1,
		timer3 = 0, --regularly check if slime touches ground and possibly set x/z velocity/acceleration to 0
		yaw = 0,
		direction = {},
		status = 2, --1 = jump, 2 = rotate
		found_target = false,

		-- ON ACTIVATE --
		on_activate = function(self)
			self.object:setacceleration({x = 0, y = -def.gravity, z = 0})
		end,

		-- ON PUNCH --
		on_punch = function(self)
			local pos = self.object:getpos()
			minetest.sound_play(def.sounds.damage.file, {pos = pos,gain = (def.sounds.damage.gain or 0.25)})
			effect(pos, 20*math.random(), def.blood)
			check_for_slime_death (self,def)
		end,

		-- ON STEP --
		on_step = function(self, dtime)

			self.timer2 = self.timer2 + dtime
			local pos = self.object:getpos()

			if self.status == 2 and (self.timer2 >= 0.5) then

				self.timer2 = 1.2
				self.status = 1

				-- FIXME
				if slime_lonely(pos) and not minetest.env:find_node_near(pos, 24, def.spawn) then
					self.object:remove()
				end

				-- FIXME improve IA
				local objs = minetest.env:get_objects_inside_radius(pos, 24)
				local ppos = {}
				self.found_target = false
				self.yaw = math.random() * 360
				for i, obj in ipairs(objs) do
					if obj:is_player() and damage_enabled and not def.passive then self.found_target = obj break end
					if self.found_target == false
						and obj:get_luaentity()
						and (obj:get_luaentity().name == "slimes:" .. def.class .. "biga" 
						or obj:get_luaentity().name == "slimes:" .. def.class .. "medium") then
							self.found_target = obj
					end
				end

				if self.found_target  ~= false then
					local target = self.found_target:getpos()
					ppos = {x = target.x - pos.x, z = target.z - pos.z}
					if ppos.x ~= 0 and ppos.z ~= 0 then --found itself as an object
						self.yaw = math.abs(math.atan(ppos.x/ppos.z) - math.pi / 2)
						if ppos.z < 0 then self.yaw = self.yaw + math.pi end
						--self.found_target = true
					end				
				end

				self.object:setyaw(self.yaw)
				self.object:set_properties({automatic_rotate = 0})
				self.direction = {x = math.cos(self.yaw)*2, y = 6, z = math.sin(self.yaw)*2}
				minetest.sound_play(def.sounds.jump.file, {pos = pos,gain = (def.sounds.jump.gain or 0.25)})
				self.object:set_properties({visual_size = {x = def.size, y = def.size - (def.size/8), z = def.size}})
			end

			self.timer = self.timer + dtime
			self.timer3 = self.timer3 + dtime

			if self.timer2 > 1.3 and self.object:getvelocity().y == 0 then

				self.object:setvelocity(self.direction)
				self.object:setacceleration({x = self.direction.x/5, y = -def.gravity, z = self.direction.z/5})
				self.timer2 = 0
				self.object:set_properties({visual_size = {x = def.size, y = def.size + (def.size/8), z = def.size}})

			end

			if (self.timer >= 6
				or (self.timer >= 1 
				and self.found_target ~= false))	
				and self.object:getvelocity().y == 0 then

				self.timer = 0
				self.timer2 = 0
				self.status = 2

				if self.found_target == false then self.object:set_properties({automatic_rotate = math.pi * 8}) end

				minetest.sound_play(def.sounds.land.file, {pos = pos,gain = (def.sounds.land.gain or 0.25)})

				local n = minetest.get_node(pos)
				if def.footprint 
				and  minetest.get_item_group(n.name, "water") == 0
				then minetest.set_node(pos, {name=def.footprint}) end
				effect(pos, 20*math.random(), def.blood)
				self.object:set_properties({visual_size = {x = def.size, y = def.size - (def.size/8), z = def.size}})

				if damage_enabled then
					
					local tod = minetest.get_timeofday()

					--FIXME water and lava damage detection is not working like it should.

					-- sunlight damage
					if def.light_damage and def.light_damage ~= 0
					and minetest.get_item_group(n.name, "water") == 0 -- no sun damage in water
					and pos.y > 0
					and (minetest.get_node_light(pos) or 0) > 10 -- direct sunlight (was 4)
					and tod > 0.2 and tod < 0.8 then
						self.object:set_hp(self.object:get_hp()-def.light_damage)
						effect(pos, 20*math.random(), "tnt_smoke.png")
						minetest.chat_send_all("me derrito ".. (minetest.get_node_light(pos) or 0))
					end

					-- water damage
					if def.water_damage and def.water_damage ~= 0
					and minetest.get_item_group(n.name, "water") ~= 0 then
						self.object:set_hp(self.object:get_hp()-def.water_damage)
						effect(pos, 20*math.random(), "bubble.png")
					end

					-- lava damage
					if def.lava_damage and def.lava_damage ~= 0
					and minetest.get_item_group(n.name, "lava") ~= 0 then
						self.object:set_hp(self.object:get_hp()-def.lava_damage)
						effect(pos, 20*math.random(), "fire_basic_flame.png")
					end

					-- fall damage
					if self.fall_damage == 1 and self.object:getvelocity().y == 0 then
						local d = self.old_y - self.object:getpos().y
						self.old_y = self.object:getpos().y
						if d > 5 then
							self.object:set_hp(self.object:get_hp() - math.floor(d - 5))
						end
					end

					check_for_slime_death (self,def)

					local objs = minetest.env:get_objects_inside_radius(pos, def.size*1.75)
					for i, obj in ipairs(objs) do
						if obj:is_player() and not def.passive then
							obj:punch(self.object, 1.0, {full_punch_interval=1.0,damage_groups = {fleshy=def.damage}})
							minetest.sound_play(def.sounds.attack.file, {pos = pos,gain = (def.sounds.attack.gain or 0.25)})
						end
					end
				end
			end

			if self.timer3 > 0.07 then
				local vel = self.object:getvelocity()
				if vel.y == 0 and (vel.x ~= 0 or vel.z ~= 0) then
					self.object:setvelocity({x = 0, y = 0, z = 0})
					self.object:setacceleration({x = 0, y = -def.gravity, z = 0})
					self.object:set_properties({visual_size = {x = def.size, y = def.size, z = def.size}})
				end
				self.timer3 = 0
			end

		end,
	})
end

-- check if slime is alone
function slime_lonely (pos)
	local objs = minetest.env:get_objects_inside_radius(pos, 32)
	for i, obj in pairs(objs) do
		if obj:is_player() then return false end
	end
	return true
end

-- check for death
function check_for_slime_death(self,def)

	if self.object:get_hp() > 0 then return end

	local pos = self.object:getpos()
	pos.y = pos.y + 0.5

	if (def.sounds.death.file ~= nil ) then minetest.sound_play(def.sounds.death.file, {pos = pos,gain = (def.sounds.death.gain or 0.25)}) end
	self.object:remove()

	local chance = def.drops.chance
	if math.random(1, def.drops.chance+1) == 1 or def.drops.chance == 0 then
		local min = def.drops.min
		local max = def.drops.max
		local num = math.floor(math.random(min, max+1))
		if def.drops.type == "item" then
			for i=1,num do	minetest.env:add_item(pos, def.drop) end
		end
		if def.drops.type == "entity" then
			for i=1,num do	minetest.env:add_entity({x=pos.x, y=pos.y + (def.size*math.random()), z=pos.z + (def.size*math.random())}, def.drops.name)	end
		end
	end
end

-- particle effects
function effect(pos, amount, texture)
	minetest.add_particlespawner({
		amount = amount,
		time = 0.25,
		minpos = pos,
		maxpos = pos,
		minvel = {x=-0, y=-2, z=-0},
		maxvel = {x=2,  y=2,  z=2},
		minacc = {x=-4, y=-4, z=-4},
		maxacc = {x=4, y=4, z=4},
		minexptime = 0.1,
		maxexptime = 1,
		minsize = 0.5,
		maxsize = 1,
		texture = texture,
	})
end

-- spawn slimes
slimes.spawn = {}
function slimes:register_spawn(name, nodes, neighbors, max_light, min_light, chance, active_object_count, max_height)
	slimes.spawn[name] = true	
	minetest.register_abm({
		nodenames = nodes,
		neighbors = neighbors,
		interval = 30,
		chance = chance,
		action = function(pos, node, _, active_object_count_wider)

			-- do not spawn if too many active in area
			if active_object_count_wider > active_object_count
			or not pos then
				return
			end

			-- mobs cannot spawn inside protected areas
			if minetest.is_protected(pos, "") then
				return
			end

			-- spawn above node
			pos.y = pos.y + 1

			-- check if light and height levels are ok to spawn
			local light = minetest.get_node_light(pos)
			if not light or light > max_light or light < min_light
			or pos.y > max_height then
				return
			end

			-- are we spawning inside a solid node?
			local nod = minetest.get_node_or_nil(pos)
			if not nod or not minetest.registered_nodes[nod.name]
			or minetest.registered_nodes[nod.name].walkable == true then
				return
			end
			pos.y = pos.y + 1
			nod = minetest.get_node_or_nil(pos)
			if not nod or not minetest.registered_nodes[nod.name]
			or minetest.registered_nodes[nod.name].walkable == true then
				return 
			end

			-- spawn mob half block higher
			pos.y = pos.y - 0.5
			minetest.add_entity(pos, name)

		end
	})
end

