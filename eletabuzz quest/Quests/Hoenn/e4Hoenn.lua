-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @WiWi__33[NetPapa]


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'E4 Hoenn'
local description = 'Go at the Hoenn Pokemon League and beat the E4'
local level = 000

local dialogs = {
	sidney = Dialog:new({ 
		"It looks like You are stronger than I expected."
	}),
	glacia = Dialog:new({ 
		"You and your Pokemon... How hot your spirits burn!"
	}),
	drake = Dialog:new({ 
		"You indeed have what is needed as a Pokemon Trainer."
	}),
	phoebe = Dialog:new({ 
		"There's definitely a bond between you and your Pokemons too, I didn't recognize that fact."
	}),
	steven = Dialog:new({ 
		"Now you may go on and continue your journey, champ. I wish you luck!"
	})
}

local templatequest = Quest:new()
local beastteam = false
function templatequest:new()
	local o = Quest.new(templatequest, name, description, level, dialogs)
	o.qnt_revive = 32
	o.qnt_hyperpot = 32
	return o
end

function templatequest:isDoable()
	if self:hasMap() and  hasItem("Rain Badge") then
		return true
	end
	return false
end

function templatequest:isDone()
	if hasItem("xxx") and getMapName() == "xxx" then
		return true
	else
		return false
	end
end



function templatequest:SootopolisCityGymB1F()
	moveToCell(13,41)
end

function templatequest:SootopolisCityGym1F()
	if game.inRectangle(22,39,22,39) then
		moveToCell(21,39)
	else moveToMap("Sootopolis City")
	end
end

function templatequest:SootopolisCity()
	if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Sootopolis City" then
		moveToMap("Pokecenter Sootopolis City")
	else if hasMove(1, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(1)
			moveToCell(50,91)
		elseif hasMove(2, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(2)
			moveToCell(50,91)
		elseif hasMove(3, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(3)
			moveToCell(50,91)
		elseif hasMove(4, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(4)
			moveToCell(50,91)
			elseif hasMove(5, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(5)
			moveToCell(50,91)
		elseif hasMove(6, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(6)
			moveToCell(50,91)
		end
	end
end

function templatequest:SootopolisCityUnderwater()
	moveToMap("Route 126 Underwater")
end

function templatequest:Route126Underwater()
	if hasMove(1, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(1)
			moveToCell(15,71)
		elseif hasMove(2, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(2)
			moveToCell(15,71)
		elseif hasMove(3, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(3)
			moveToCell(15,71)
		elseif hasMove(4, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(4)
			moveToCell(15,71)
			elseif hasMove(5, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(5)
			moveToCell(15,71)
		elseif hasMove(6, "Dive") then
			pushDialogAnswer(1)
			pushDialogAnswer(6)
			moveToCell(15,71)
		end
end

function templatequest:Route126()
	moveToMap("Route 127")
end

function templatequest:Route127()
	moveToMap("Route 128")
end

function templatequest:Route128()
	moveToMap("Ever Grande City")
end

function templatequest:EverGrandeCity()
	if game.inRectangle(0,59,51,114) or game.inRectangle(26,57,35,76) then
		if self:needPokecenter() or self.registeredPokecenter ~= "Pokecenter Ever Grande City" then
			moveToMap("Pokecenter Ever Grande City")
		elseif isNpcOnCell(27,57) then
			talkToNpcOnCell(27,57)
		else moveToMap("Victory Road Hoenn 1F")
		end
	elseif isNpcOnCell(30,35) then
		talkToNpcOnCell(30,35)
	else moveToMap("Pokemon League Hoenn")
	end
end

function templatequest:PokecenterEverGrandeCity()
	return self:pokecenter("Ever Grande City")
end

function templatequest:VictoryRoadHoenn1F()
	if game.inRectangle(4,16,24,54) then
		moveToCell(9,17)
	else moveToMap("Ever Grande City")
	end
end

function templatequest:VictoryRoadHoennB1F()
	moveToCell(46,7)
end

function templatequest:PokemonLeagueHoenn()
	if self:needPokecenter() or not game.isTeamFullyHealed() then
		talkToNpcOnCell(4,22)
	end
	if not isTeamSortedByLevelAscending() then
			sortTeamByLevelAscending()
	elseif getPokemonLevel(1) < 96 and not beastteam then
		if isPCOpen() then
			if isCurrentPCBoxRefreshed() then
				if getCurrentPCBoxSize() ~= 0 then
					for pokemon=1, getCurrentPCBoxSize() do
						if getPokemonLevelFromPC(getCurrentPCBoxId(), pokemon) > 95 then
						return swapPokemonFromPC(getCurrentPCBoxId(),pokemon,1) 	
						end
					end
					return openPCBox(getCurrentPCBoxId()+1)
				else
					beastteam = true
					return
				end
			else
				return
			end
		else
			return usePC()
		end
	elseif getItemQuantity("Revive") < self.qnt_revive or getItemQuantity("Hyper Potion") < self.qnt_hyperpot then
		if not isShopOpen() then
			log("ff")
			return talkToNpcOnCell(16,22)
		else
			if getItemQuantity("Revive") < self.qnt_revive then
				return buyItem("Revive", (self.qnt_revive - getItemQuantity("Revive")))
			end
			if getItemQuantity("Hyper Potion") < self.qnt_hyperpot then
				return buyItem("Hyper Potion", (self.qnt_hyperpot - getItemQuantity("Hyper Potion")))
			end
		end
	else moveToCell(10,3)
	end
		
end

function templatequest:PokecenterSootopolisCity()
	return self:pokecenter("Sootopolis City")
end

function templatequest:EliteFourSidneyRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.sidney.state then
		talkToNpcOnCell(18,17) 
	else
		dialogs.sidney.state = false
		return moveToCell(18,3) 
	end
end

function templatequest:EliteFourPhoebeRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.phoebe.state then
		talkToNpcOnCell(17,22) 
	else
		dialogs.phoebe.state = false
		return moveToCell(17,12) 
	end
end

function templatequest:EliteFourGlaciaRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.glacia.state then
		talkToNpcOnCell(15,16) 
	else
		dialogs.glacia.state = false
		return moveToCell(15,3) 
	end
end

function templatequest:EliteFourDrakeRoom()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.drake.state then
		talkToNpcOnCell(17,16) 
	else
		dialogs.drake.state = false
		return moveToCell(17,2) 
	end
end

function templatequest:EliteFourChampionRoomHoenn()
	if self:useReviveItems() ~= false then
		return
	elseif not dialogs.steven.state then
		talkToNpcOnCell(6,16) 
	else
		return talkToNpcOnCell(6,4)
	end
end


function templatequest:useReviveItems() --Return false if team don't need heal
	if not hasItem("Revive") or not hasItem("Hyper Potion") then
		return false
	end
	for pokemonId=1, getTeamSize(), 1 do
		if getPokemonHealth(pokemonId) == 0 then
			return useItemOnPokemon("Revive", pokemonId)
		end
		if getPokemonHealthPercent(pokemonId) < 70 then
			return useItemOnPokemon("Hyper Potion", pokemonId)
		end		
	end
	return false
end


return templatequest