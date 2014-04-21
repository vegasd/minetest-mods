player = {}

-- Player animation blending
-- Note: This is currently broken due to a bug in Irrlicht, leave at 0
local animation_blend = 0

player.registered_models = { }

-- Local for speed.
local models = player.registered_models

function player.register_model(name, def)
	models[name] = def
end

-- Default player appearance
player.register_model("character.x", {
	animation_speed = 30,
	textures = {"character.png", },
	animations = {
		-- Standard animations.
		stand     = { x=  0, y= 79, },
		lay       = { x=162, y=166, },
		walk      = { x=168, y=187, },
		mine      = { x=189, y=198, },
		walk_mine = { x=200, y=219, },
		-- Extra animations (not currently used by the game).
		sit       = { x= 81, y=160, },
	},
})

-- Player stats and animations
local player_model = {}
local player_textures = {}
local player_anim = {}
local player_sneak = {}

function player.get_animation(p)
	local name = p:get_player_name()
	return {
		model = player_model[name],
		textures = player_textures[name],
		animation = player_anim[name],
	}
end

-- Called when a player's appearance needs to be updated
function player.set_model(p, model_name)
	local name = p:get_player_name()
	local model = models[model_name]
	if model then
		if player_model[name] == model_name then
			return
		end
		p:set_properties({
			mesh = model_name,
			textures = player_textures[name] or model.textures,
			visual = "mesh",
			visual_size = model.visual_size or {x=1, y=1},
		})
		player.set_animation(p, "stand")
	else
		p:set_properties({
			textures = { "player.png", "player_back.png", },
			visual = "upright_sprite",
		})
	end
	player_model[name] = model_name
end

function player.set_textures(p, textures)
	local name = p:get_player_name()
	player_textures[name] = textures
	p:set_properties({textures = textures,})
end

function player.set_animation(p, anim_name, speed)
	local name = p:get_player_name()
	if player_anim[name] == anim_name then
		return
	end
	local model = player_model[name] and models[player_model[name]]
	if not (model and model.animations[anim_name]) then
		return
	end
	local anim = model.animations[anim_name]
	player_anim[name] = anim_name
	p:set_animation(anim, speed or model.animation_speed, animation_blend)
end

-- Update appearance when the player joins
minetest.register_on_joinplayer(function(p)
	player.set_model(p, "character.x")
end)

minetest.register_on_leaveplayer(function(p)
	local name = p:get_player_name()
	player_model[name] = nil
	player_anim[name] = nil
	player_textures[name] = nil
end)

-- Localize for better performance.
local player_set_animation = player.set_animation

-- Check each player and apply animations
minetest.register_globalstep(function(dtime)
	for _, p in pairs(minetest.get_connected_players()) do
		local name = p:get_player_name()
		local model_name = player_model[name]
		local model = model_name and models[model_name]
		if model then
			local controls = p:get_player_control()
			local walking = false
			local animation_speed_mod = model.animation_speed or 30

			-- Determine if the player is walking
			if controls.up or controls.down or controls.left or controls.right then
				walking = true
			end

			-- Determine if the player is sneaking, and reduce animation speed if so
			if controls.sneak then
				animation_speed_mod = animation_speed_mod / 2
			end

			-- Apply animations based on what the player is doing
			if p:get_hp() == 0 then
				player_set_animation(p, "lay")
			elseif walking then
				if player_sneak[name] ~= controls.sneak then
					player_anim[name] = nil
					player_sneak[name] = controls.sneak
				end
				if controls.LMB then
					player_set_animation(p, "walk_mine", animation_speed_mod)
				else
					player_set_animation(p, "walk", animation_speed_mod)
				end
			elseif controls.LMB then
				player_set_animation(p, "mine")
			else
				player_set_animation(p, "stand", animation_speed_mod)
			end
		end
	end
end)
