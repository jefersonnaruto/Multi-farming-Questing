-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Viridian School'
local description = 'from Route 1 to Route 2'

local dialogs = {
	jacksonDefeated = Dialog:new({
		"You will not take my spot!",
		"Sorry, the young boy there doesn't want to give his spot, I'm truly sorry..."
	})
}

local ViridianSchoolQuest = Quest:new()
function ViridianSchoolQuest:new()
	return Quest.new(ViridianSchoolQuest, name, description, 80, dialogs)
end

function ViridianSchoolQuest:isDoable()
	if  self:hasMap() then
		return true
	end
	return false
end

function ViridianSchoolQuest:isDone()
	return getMapName() == "Route 22"
end

-- necessary, in case of black out we come back to the bedroom
function ViridianSchoolQuest:PlayerBedroomPallet()
	return moveToMap("Player House Pallet")
end

function ViridianSchoolQuest:PlayerHousePallet()
	return moveToMap("Link")
end

function ViridianSchoolQuest:PalletTown()
	return moveToMap("Route 1")
end

function ViridianSchoolQuest:Route1()
	if self:needPokecenter() and getTeamSize() == 1 then
		if useItemOnPokemon("Potion", 1) then
			return true
		end
	end
	if getTeamSize() == 1 and getPokemonName(1) == "Bulbasaur" and hasItem("Pokeball") then 
	return moveToRectangle(23,11,26,13) 
	elseif not hasItem("Pokeball") or getTeamSize() >= 2 then
	
	return moveToMap("Route 1 Stop House")
	end
end

function ViridianSchoolQuest:Route1StopHouse()
	if getTeamSize() == 1 and hasItem("Pokeball") then
	return moveToMap("Route 1")
	elseif  not hasItem("Pokeball") then
	return moveToMap("Viridian City")
	else
	return moveToMap("Viridian City")
	end
end


function ViridianSchoolQuest:ViridianCity()
	if not game.isTeamFullyHealed()
		or self.registeredPokecenter ~= "Pokecenter Viridian" then
		return moveToMap("Pokecenter Viridian")
	elseif self:needPokemart() then
		return moveToMap("Viridian Pokemart")
	elseif getTeamSize() == 1 and getPokemonName(1) == "Bulbasaur" then
		return moveToMap("Route 1 Stop House")
	else
		return moveToMap("Route 22")
	end
end


function ViridianSchoolQuest:PokecenterViridian()
	return self:pokecenter("Viridian City")
end

function ViridianSchoolQuest:ViridianPokemart()
	return self:pokemart("Viridian City")
end

return ViridianSchoolQuest