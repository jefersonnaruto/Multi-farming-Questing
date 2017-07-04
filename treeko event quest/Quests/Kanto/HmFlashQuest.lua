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
			return moveToRectangle(22,36,34,41)
		
	elseif self.zoneExp == 2 then
			return moveToRectangle(55,32,59,35)
		
	elseif self.zoneExp == 3 then
			return moveToRectangle(68,34,72,39)
		
	elseif	self.zoneExp == 4 then
			return moveToRectangle(49,9,58,11)
	elseif	self.zoneExp == 5 then
			return moveToRectangle(21,21,29,27)	
	else	
			return moveToRectangle(21,21,29,27)
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
		return moveToMap("Kalijodo Path")
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



function HmFlashQuest:KalijodoPath()
		return self:randomZoneExp()
end


	


return HmFlashQuest




