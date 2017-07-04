-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'Elite 4 - Kanto'
local description = 'Exp in Victory Road (4 Zones)'
local level = 55

local dialogs = {
	leagueKantoNotDone = Dialog:new({ 
		"you are not ready to go to johto yet"
	})
}

local ExpForElite4Kanto = Quest:new()

function ExpForElite4Kanto:new()
	local o = Quest.new(ExpForElite4Kanto, name, description, level, dialogs)
	o.qnt_revive = 32
	o.qnt_hyperpot = 32
	o.registeredPokecenter_ = ""
	o.zoneExp = 1
	o.timeSeed = 0
	o.minuteZones = 5
	return o
end

function ExpForElite4Kanto:isDoable()
	if self:hasMap()  and not hasItem("Zephyr Badge") then
		return true
	end
	return false
end

function ExpForElite4Kanto:isDone()
	if getMapName() == "Route 26" or getMapName() == "Route 2" or getMapName() == "Elite Four Lorelei Room" then --Fix Blackout
		return true
	end
	return false
end

function ExpForElite4Kanto:changeZoneExp() --False if is not necessary
	if os.clock() > (self.timeSeed + (self.minuteZones * 60)) then
		self.timeSeed = os.clock()
		self.zoneExp = math.random(1,1)
		log("LOG:  Changing with ExpZone N*: " .. self.zoneExp)
		return false
	end
	return false
end

function ExpForElite4Kanto:useZoneExp()
	if self:changeZoneExp() == false then
		if self.zoneExp == 1 then
			return moveToRectangle(36,36,42,41) --Road1F
		elseif self.zoneExp == 2 then
			return moveToRectangle(23,22,39,24) --Road1F
		elseif self.zoneExp == 3 then
			return moveToRectangle(12,27,28,30) --Road2F
		elseif self.zoneExp == 4 then
			return moveToRectangle(40,23,55,26) --Road2F
		else
		    fatal("Error zone exp")
		end
	end
end

function ExpForElite4Kanto:buyReviveItems() --return false if all items are on the bag (32x Revives 32x HyperPotions)
	if getItemQuantity("Revive") < self.qnt_revive or getItemQuantity("Hyper Potion") < self.qnt_hyperpot then
		if not isShopOpen() then
			return talkToNpcOnCell(16,22)
		else
			if getItemQuantity("Revive") < self.qnt_revive then
				return buyItem("Revive", (self.qnt_revive - getItemQuantity("Revive")))
			end
			if getItemQuantity("Hyper Potion") < self.qnt_hyperpot then
				return buyItem("Hyper Potion", (self.qnt_hyperpot - getItemQuantity("Hyper Potion")))
			end
		end
	else
		return false
	end
end

function ExpForElite4Kanto:canBuyReviveItems()
	local bag_revive = getItemQuantity("Revive")
	local bag_hyperpot = getItemQuantity("Hyper Potion")
	local cost_revive = (self.qnt_revive - bag_revive) * 1500
	local cost_hyperpot = (self.qnt_hyperpot - bag_hyperpot) * 1200
	return getMoney() > (cost_hyperpot + cost_revive)
end

function ExpForElite4Kanto:Route22()
	if self:needPokecenter() then 
		return moveToMap("Viridian City") 
	elseif isNpcOnCell(10,8) and getMoney() <= 5000 and not self:needPokecenter() then
		return moveToMap("Pokemon League Reception Gate")
	else 
		return moveToMap("Viridian City") 
	end
end

function ExpForElite4Kanto:ViridianCity()
	if self:needPokecenter() then 
		return moveToMap("Pokecenter Viridian") 
	elseif  getMoney() <= 5000 and not self:needPokecenter()  then
		return moveToMap("Route 22") 
	else 
		return moveToMap("Route 2")
	end
end
function ExpForElite4Kanto:PokecenterViridian()
	if not game.isTeamFullyHealed() then
		return usePokecenter()
	end
	return moveToMap("Viridian City")
end

function ExpForElite4Kanto:PokemonLeagueReceptionGate()
	if self:needPokecenter() then 
		return moveToMap("Route 22") 
	elseif isNpcOnCell(22,3) then
		return talkToNpcOnCell(22,3)
	elseif getMoney() <= 5000 and not self:needPokecenter() then
		return moveToMap("Victory Road Kanto 1F")
	else
		return moveToMap("Route 22") 
	end
end

function ExpForElite4Kanto:VictoryRoadKanto1F()
	if self:needPokecenter()  then
		return moveToMap("Pokemon League Reception Gate")
	
	elseif getMoney() <= 5000 and not self:needPokecenter() then 
		return self:useZoneExp()
	elseif getUsablePokemonCount() == 1 then
		return moveToMap("Pokemon League Reception Gate")
	else
		return moveToMap("Pokemon League Reception Gate")
	end
end

function ExpForElite4Kanto:VictoryRoadKanto2F()
	if getMoney() <= 5000   then
		return self:useZoneExp()
	elseif self:needPokecenter() then 
		return moveToMap("Victory Road Kanto 1F") 
	else
		return moveToMap("Victory Road Kanto 1F")
	end
end

function ExpForElite4Kanto:VictoryRoadKanto3F()
	if isNpcOnCell(46,14) then --Moltres
		return talkToNpcOnCell(46,14)
	end
	if dialogs.leagueKantoNotDone.state then
		if self:needPokecenter() or self.registeredPokecenter_ ~= "Indigo Plateau Center" then
			return moveToMap("Indigo Plateau")
		elseif not self:isTrainingOver() or not self:canBuyReviveItems() then
			return moveToCell(29,17) --Road2F
		else
			return moveToMap("Indigo Plateau")
		end
	else
		return moveToCell(29,17) --Road2F
	end
end

function ExpForElite4Kanto:IndigoPlateau()
	if dialogs.leagueKantoNotDone.state then
		if self:needPokecenter() or self.registeredPokecenter_ ~= "Indigo Plateau Center" then
			return moveToMap("Indigo Plateau Center")
		elseif not self:isTrainingOver() or not self:canBuyReviveItems() then
			return moveToMap("Victory Road Kanto 3F") --Road2F
		else
			return moveToMap("Indigo Plateau Center")
		end
	else
		return moveToMap("Victory Road Kanto 3F")
	end
end

function ExpForElite4Kanto:IndigoPlateauCenter()
	if dialogs.leagueKantoNotDone.state then
		if self:needPokecenter() or not game.isTeamFullyHealed() or self.registeredPokecenter_ ~= "Indigo Plateau Center" then
			self.registeredPokecenter_ = getMapName()
			return talkToNpcOnCell(4,22)
		elseif not self:isTrainingOver() or not self:canBuyReviveItems() then
			return moveToMap("Indigo Plateau") --Road2F
		elseif self:buyReviveItems() ~= false then
			return 
		else
			return moveToCell(10,3) --Start E4
		end
	else
		return moveToMap("Indigo Plateau")
	end
end

function ExpForElite4Kanto:MapName()
	
end

return ExpForElite4Kanto