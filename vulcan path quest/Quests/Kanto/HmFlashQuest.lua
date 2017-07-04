-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name        = 'Quest: HM05 - Flash '
local description = 'Route 11 to Route 9'

local HmFlashQuest = Quest:new()

function HmFlashQuest:new()
	return Quest.new(HmFlashQuest, name, description, 100)
end

function HmFlashQuest:isDoable()
	if self:hasMap()  then
		return true
	end
	return false
end

function HmFlashQuest:isDone()
	if getMapName() == "Route 99" then
		return true
	else
		return false
	end
end

function HmFlashQuest:randomZoneExp()
	if self.zoneExp == 1 then
			return moveToRectangle(28,7,32,7)
		
	elseif self.zoneExp == 2 then
			return moveToRectangle(22,9,34,9)
		
	elseif self.zoneExp == 3 then
			return moveToRectangle(31,19,37,19)
		
	elseif	self.zoneExp == 4 then
			return moveToRectangle(32,21,37,21)
	elseif	self.zoneExp == 5 then
			return moveToRectangle(14,30,18,30)	
	else	
			return moveToRectangle(12,31,18,31)
	end
end




function HmFlashQuest:VulcanicTown()
		
	if not self.registeredPokecenter == "Pokecenter Vulcanic Town"
		
	then
		return moveToMap("Pokecenter Vulcanic Town")
	elseif getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return moveToMap("Pokemart Vulcanic Town")
	else
		self.zoneExp = math.random(1,5)
		return moveToMap("Vulcan Forest")
	end
end

function HmFlashQuest:PokecenterVulcanicTown()
	if not game.isTeamFullyHealed() then 
	return talkToNpcOnCell(8,14)
	else
	return moveToMap("Vulcanic Town")
	end
end

function HmFlashQuest:PokemartVulcanicTown()
if getMoney() >= 200 and  getItemQuantity("pokeball") <= 49 then
		if not isShopOpen() then
			return talkToNpcOnCell(3,4) 
		else
			return buyItem("Pokeball", 30)
		end
	else
		return moveToMap("Vulcanic Town")
	end
end

function HmFlashQuest:VulcanForest()
		return moveToMap("Vulcan Path")
end

function HmFlashQuest:VulcanPath()
		return self:randomZoneExp()
end


	


return HmFlashQuest




