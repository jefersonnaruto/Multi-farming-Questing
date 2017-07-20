-- Copyright � 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.
-- Quest: @Rympex


local sys    = require "Libs/syslib"
local game   = require "Libs/gamelib"
local Quest  = require "Quests/Quest"
local Dialog = require "Quests/Dialog"

local name		  = 'HM Surf'
local description = 'Kanto Safari'
local level = 4

local HmSurfQuest = Quest:new()

function HmSurfQuest:new()
local o= Quest.new(HmSurfQuest, name, description, level)
o.zoneExp = 1
return o
end

function HmSurfQuest:isDoable()
	return self:hasMap()	
end

function HmSurfQuest:isDone()
	if  getMapName() == "Safari Stop" or getMapName() == "Pokecenter Fuchsia" then --Fix Blackout
		return true		
	end
	return false
end

function HmSurfQuest:randomZoneExp()
	if self.zoneExp == 1 then
			return moveToRectangle(25,29,30,29)
		
	elseif self.zoneExp == 2 then
			return moveToRectangle(36,13,40,13)
		
	elseif self.zoneExp == 3 then
			return moveToRectangle(17,29,23,29)
		
	elseif	self.zoneExp == 4 then
			return moveToRectangle(6,22,8,25)
		
	end
end

function HmSurfQuest:SafariStop()
	if hasItem("HM03 - Surf") then
	fatal("Hoc duoc surf cmnr")
	end
end

function HmSurfQuest:SafariEntrance()
	if not hasItem("HM03 - Surf") then
		return moveToMap("Safari Area 1")
	else
		return talkToNpcOnCell(27,25)
	end
end

function HmSurfQuest:SafariArea1()
	if not hasItem("HM03 - Surf") then
		return moveToMap("Safari Area 2")
	else
		return moveToMap("Safari Entrance")
	end
end

function HmSurfQuest:SafariArea2()
	if not hasItem("HM03 - Surf") then
		self.zoneExp = math.random(1,4)
		return moveToMap("Safari Area 3")
	else
		return moveToMap("Safari Area 1")
	end
end

function HmSurfQuest:SafariArea3()
	if not hasItem("HM03 - Surf") then
		 return self:randomZoneExp()
	else
		return moveToMap("Safari Area 2")
	end
end



return HmSurfQuest