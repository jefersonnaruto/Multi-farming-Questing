-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Sould Badge'
local description = 'Fuchsia City'
local level = 100

local dialogs = {
	questSurfAccept = Dialog:new({ 
		"There is something there I want you to take",
		"Did you get the HM broseph"
	})
}

local SoulBadgeQuest = Quest:new()

function SoulBadgeQuest:new()
	local o = Quest.new(SoulBadgeQuest, name, description, level, dialogs)
	o.zoneExp = 1
	o.pokemonId = 1
	return o
end

function SoulBadgeQuest:isDoable()	
	if self:hasMap() and not hasItem("Marsh Badge") then
			return true
	
	end
	return false
end

function SoulBadgeQuest:isDone()
	if (hasItem("Soul Badge") and hasItem("HM03 - Surf") and getMapName() == "Route 15") or getMapName() == "Safari Entrance" or getMapName() == "Route 20"then
		return true
	else
		return false
	end
end

function SoulBadgeQuest:pokemart_()
	local pokeballCount = getItemQuantity("Pokeball")
	local money         = getMoney()
	if money >= 200 and pokeballCount < 50 then
		if not isShopOpen() then
			return talkToNpcOnCell(9,8)
		else
			local pokeballToBuy = 50 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
				return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap("Fuchsia City")
	end
end

function SoulBadgeQuest:needPokemart_()
	if getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return true
	end
	return false
end

function SoulBadgeQuest:canEnterSafari()
	return getMoney() > 5000000 and not isNight() 
end

function SoulBadgeQuest:randomZoneExp()
	if self.zoneExp == 1 then
		if game.inRectangle(51,18,54,22) then--Zone 1
			return moveToGrass()
		else
			return moveToCell(53,20)
		end
	elseif self.zoneExp == 2 then
		if game.inRectangle(65,29,70,31) then--Zone 2
			return moveToGrass()
		else
			return moveToCell(68,30)
		end
	elseif self.zoneExp == 3 then
		if game.inRectangle(62,14,66,15) then--Zone 3
			return moveToGrass()
		else
			return moveToCell(64,14)
		end
	else
		if game.inRectangle(89,14,91,18) then--Zone 4
			return moveToGrass()
		else
			return moveToCell(90,16)
		end
	end
end

function SoulBadgeQuest:PokecenterFuchsia()
	self:pokecenter("Fuchsia City")
end

function SoulBadgeQuest:Route18()
	
		return moveToMap("Fuchsia City")
	
end
function SoulBadgeQuest:BikeRoadStop()
	return  moveToCell(10,07)
end
 


function SoulBadgeQuest:FuchsiaCity()
	if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter ~= "Pokecenter Fuchsia" then
		return moveToMap("Pokecenter Fuchsia")

	elseif self:needPokemart_()  then --It buy balls if not have badge, at blackoutleveling no
		return moveToMap("Safari Stop")
	elseif not hasItem("HM03 - Surf") then
			return moveToMap("Route 15 Stop House")
	
	else
		return moveToMap("Fuchsia City Stop House")
	end
end

function SoulBadgeQuest:SafariStop()
	if self:needPokemart_() then
		self:pokemart_()
	else
		return moveToMap("Fuchsia City")
	end
end

function SoulBadgeQuest:Route15StopHouse()

		return moveToMap("Route 15")
end

function SoulBadgeQuest:FuchsiaCityStopHouse()
	if game.minTeamLevel() >= 60 then
		return moveToMap("Fuchsia City")
	elseif not hasItem("HM03 - Surf") then
		if dialogs.questSurfAccept.state then
			return moveToMap("Fuchsia City")
		else
			return moveToMap("Route 19")
		end
	else
		return moveToMap("Route 19")
	end
end

function SoulBadgeQuest:Route19()
	if game.minTeamLevel() >= 60 then
		return moveToMap("Fuchsia City Stop House")
	elseif hasItem("HM03 - Surf") then
		if not game.hasPokemonWithMove("Surf") then
			if self.pokemonId < getTeamSize() then					
				useItemOnPokemon("HM03 - Surf", self.pokemonId)
				log("Pokemon: " .. self.pokemonId .. " Try Learning: HM03 - Surf")
				self.pokemonId = self.pokemonId + 1
				return
			else
				fatal("No pokemon in this team can learn - Surf")
			end
		else
			return moveToMap("Route 20")
		end
	else
		if dialogs.questSurfAccept.state then
			return moveToMap("Fuchsia City Stop House")
		else
			return talkToNpcOnCell(33,19)
		end
	end
end




function SoulBadgeQuest:Route15()
	if self:needPokecenter()  or not self.registeredPokecenter == "Pokecenter Fuchsia" then
		return moveToMap("Route 15 Stop House")
	else
		return  moveToMap("Route 14")
	end
end

function SoulBadgeQuest:Route14()
	return moveToMap("Route 13")
end

function SoulBadgeQuest:Route13()
	moveToMap("Route 12")
end

function SoulBadgeQuest:Route12()
	return moveToGrass()
end

return SoulBadgeQuest