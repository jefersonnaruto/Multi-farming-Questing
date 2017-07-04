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

function HmFlashQuest:Route11()
	if isNpcOnCell(10, 13) then -- NPC Block Diglet's Entrance
		return talkToNpcOnCell(10, 13) 
	else
		return moveToMap("Vermilion City")
	end
end

function HmFlashQuest:VermilionCity()
		if self:needPokemart() then
		return moveToMap("Vermilion Pokemart")
	elseif self.registeredPokecenter ~= "Pokecenter Vermilion"
		or not game.isTeamFullyHealed()
	then
		return moveToMap("Route 6")
	elseif getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return moveToMap("Vermilion Pokemart")
	else
		return moveToMap("Route 6")
	end
end

function HmFlashQuest:PokecenterVermilion()
	self:pokecenter("Vermilion City")
end

function HmFlashQuest:VermilionPokemart()
	self:pokemart("Vermilion City")
end



function HmFlashQuest:Route6()
		return moveToMap("Route 6 Stop House")
end

function HmFlashQuest:Route6StopHouse()
return moveToMap("Saffron City")
end

function HmFlashQuest:SaffronCity()
return moveToMap("Route 8 Stop House")
end

function HmFlashQuest:Route8StopHouse()
return moveToMap("Route 8")
end

function HmFlashQuest:Route8()
	return moveToGrass()
end



return HmFlashQuest




