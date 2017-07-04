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
	if getMapName() == "Route 7" then
		return true
	else
		return false
	end
end

function HmFlashQuest:Route11()
	if isNpcOnCell(10, 13) then -- NPC Block Diglet's Entrance
		return talkToNpcOnCell(10, 13) 
	else
		return moveToMap("Digletts Cave Entrance 2")
	end
end

function HmFlashQuest:DiglettsCaveEntrance2()
		return moveToMap("Digletts Cave")
end

function HmFlashQuest:DiglettsCave()
	
		return moveToMap("Digletts Cave Entrance 1")
end



function HmFlashQuest:DiglettsCaveEntrance1()
	if not self:isTrainingOver() and not self:needPokecenter() and self.registeredPokecenter == "Pokecenter Pewter"  then 
		return self:useZoneExp()
	elseif self:needPokemart() or  self:needPokecenter() or not self.registeredPokecenter == "Pokecenter Pewter" then
		return moveToMap("Route 2")
	else
		return moveToMap("Route 2")
	end
end

function HmFlashQuest:useZoneExp()
	
		if self.zoneExp == 1 then
			return moveToRectangle(11,15,19,15) --Road1F
		elseif self.zoneExp == 2 then
			return moveToRectangle(22,16,26,17) --Road1F
		elseif self.zoneExp == 3 then
			return moveToRectangle(11,24,18,24) --Road2F
		elseif self.zoneExp == 4 then
			return moveToRectangle(12,26,18,26) --Road2F
		end
	
end

function HmFlashQuest:Route2()
	if not self:isTrainingOver() and not self:needPokecenter() and self.registeredPokecenter == "Pokecenter Pewter" then 
		self.zoneExp = math.random(1,4)
		return moveToMap("Digletts Cave Entrance 1")
	else
		return moveToMap("Pewter City")
	end
end


function HmFlashQuest:PewterCity() -- BlackOut FIX
	if self:needPokemart() then
		return moveToMap("Pewter Pokemart")
	elseif self.registeredPokecenter ~= "Pokecenter Pewter"
		or not game.isTeamFullyHealed()
	then
		return moveToMap("Pokecenter Pewter")
	elseif getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return moveToMap("Pewter Pokemart")
	elseif not self:isTrainingOver() then 
		return moveToMap("Route 2")
	end
end

function HmFlashQuest:PokecenterVermilion() -- BlackOut FIX
	self:pokecenter("Vermilion City")
end

function HmFlashQuest:VermilionCity()
		return moveToMap("Route 6")
end

function HmFlashQuest:Route6()
		return moveToMap("Route 6 Stop House")
end

function HmFlashQuest:Route6StopHouse()
return moveToMap("Saffron City")
end

function HmFlashQuest:SaffronCity()
return moveToMap("Route 7 Stop House")
end

function HmFlashQuest:Route7StopHouse()
return moveToMap("Route 7")
end

function HmFlashQuest:PokecenterPewter()
	self:pokecenter("Pewter City")
end

function HmFlashQuest:PewterPokemart()
	self:pokemart("Pewter City")
end


return HmFlashQuest




