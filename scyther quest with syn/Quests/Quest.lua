-- Copyright © 2016 g0ld <g0ld@tuta.io>
-- This work is free. You can redistribute it and/or modify it under the
-- terms of the Do What The Fuck You Want To Public License, Version 2,
-- as published by Sam Hocevar. See the COPYING file for more details.

local sys  = require "Libs/syslib"
local game = require "Libs/gamelib"

local blacklist = require "blacklist"

local Quest = {}

function Quest:new(name, description, level, dialogs)
	local o = {}
	setmetatable(o, self)
	self.__index     = self
	o.name        = name
	o.description = description
	o.level       = level or 1
	o.dialogs     = dialogs
	o.training    = true
	return o
end

function onStop()
	return relog(1,"Hello")
end

function Quest:isDoable()
	sys.error("Quest:isDoable", "function is not overloaded in quest: " .. self.name)
	return nil
end

function Quest:isDone()
	return self:isDoable() == false
end

function Quest:mapToFunction()
	local mapName = getMapName()
	local mapFunction = sys.removeCharacter(mapName, ' ')
	mapFunction = sys.removeCharacter(mapFunction, '.')
	mapFunction = sys.removeCharacter(mapFunction, '-') -- Map "Fisherman House - Vermilion"
	return mapFunction
end

function Quest:hasMap()
	local mapFunction = self:mapToFunction()
	if self[mapFunction] then
		return true
	end
	return false
end

function Quest:pokecenter(exitMapName) -- idealy make it work without exitMapName
	self.registeredPokecenter = getMapName()
	sys.todo("add a moveDown() or moveToNearestLink() or getLinks() to PROShine")
	if not game.isTeamFullyHealed() then
		return usePokecenter()
	end
	return moveToMap(exitMapName)
end

-- at a point in the game we'll always need to buy the same things
-- use this function then
function Quest:pokemart(exitMapName)
	local pokeballCount = getItemQuantity("Pokeball")
	local money         = getMoney()
	if money >= 200 and pokeballCount < 50 then
		if not isShopOpen() then
			return talkToNpcOnCell(3,5)
		else
			local pokeballToBuy = 50 - pokeballCount
			local maximumBuyablePokeballs = money / 200
			if maximumBuyablePokeballs < pokeballToBuy then
				pokeballToBuy = maximumBuyablePokeballs
			end
			return buyItem("Pokeball", pokeballToBuy)
		end
	else
		return moveToMap(exitMapName)
	end
end


function Quest:isTrainingOver()
	if game.maxTeamLevel() >= self.level then
		if self.training then -- end the training
			self:stopTraining()
		end
		return true
	end
	return false
end



function Quest:useBike()
 if isPrivateMessageEnabled() then
    return disablePrivateMessage() 
 end
	if isTeamInspectionEnabled() then
     return  disableTeamInspection() 
	end
end

function Quest:startTraining()
	self.training = true
end

function Quest:stopTraining()
	self.training = false
	self.healPokemonOnceTrainingIsOver = true
end

function Quest:needPokemart()
	-- TODO: ItemManager
	if getItemQuantity("Pokeball") < 50 and getMoney() >= 200 then
		return true
	end
	return false
end

function Quest:needPokecenter()
	if getTeamSize() == 1 then
		
			return false

	-- else we would spend more time evolving the higher level ones
	elseif not self:isTrainingOver() then
		if getUsablePokemonCount() == 1 or game.getUsablePokemonCountUnderLevel(self.level) == 0 then
			return true
		end
	else
		if not game.isTeamFullyHealed() then
			if self.healPokemonOnceTrainingIsOver then
				return true
			end
		else
			-- the team is healed and we do not need training
			self.healPokemonOnceTrainingIsOver = false
		end
	end
	return false
end

function Quest:message()
	return self.name .. ': ' .. self.description
end

-- I'll need a TeamManager class very soon
local moonStoneTargets = {
	"Clefairy",
	"Jigglypuff",
	"Munna",
	"Nidorino",
	"Nidorina",
	"Skitty"
}



function Quest:evolvePokemon()
	local hasMoonStone = hasItem("Moon Stone")
	for pokemonId=1, getTeamSize(), 1 do
		local pokemonName = getPokemonName(pokemonId)
		if hasMoonStone
			and sys.tableHasValue(moonStoneTargets, pokemonName)
		then
			return useItemOnPokemon("Moon Stone", pokemonId)
		end
	end
	return false
end

function Quest:path()
	if self.inBattle then
		self.inBattle = false
		self:battleEnd()
	end
	if self:evolvePokemon() then
		return true
	end
	--if not isTeamSortedByLevelAscending() then
		--return sortTeamByLevelAscending()
	--end
	

	if self:useBike() then
		return true
	end
	local mapFunction = self:mapToFunction()
	assert(self[mapFunction] ~= nil, self.name .. " quest has no method for map: " .. getMapName())
	self[mapFunction](self)
end

function Quest:isPokemonBlacklisted(pokemonName)
	return sys.tableHasValue(blacklist, pokemonName)
end

function Quest:battleBegin()
	self.canRun = true
end

function Quest:battleEnd()
	self.canRun = true
end

-- I'll need a TeamManager class very soon
local blackListTargets = { --it will kill this targets instead catch
	 "Caterpie",     
	 "Metapod",      
	 "Butterfree",   
	 "Weedle",       
	 "Kakuna",       
	 "Beedrill",     
	 "Pidgey",       
	 "Pidgeotto",    
	 "Pidgeot",      
	 "Rattata",      
	 "Raticate",     
	 "Spearow",      
	 "Fearow",       
	 "Ekans",     
	 "Arbok",        
	 "Pikachu",      
	 "Raichu",       
	 "Sandshrew",    
	 "Sandslash",    
	 "Nidoran F",    
	 "Nidorina",     
	 "Nidoqueen",    
	 "Nidoran M",    
	 "Nidorino",     
	 "Nidoking",          
	 "Clefable",     
	 "Vulpix",       
	 "Ninetales",    
	 "Jigglypuff",   
	 "Mankey",       
	 "Poliwag",          
	 "Onix",    
	 "Abra",    
	 "Ponyta", 
	  "Doduo",     
	  "Sentret",      
	 "Furret",       
	 "Hoothoot",
	 	 "Spinarak",  
	 "Dodrio",  
	"Zigzagoon"
}

function Quest:wildBattle()
	if isOpponentShiny()  or getOpponentName() == "Scyther"  then
    
        if getActivePokemonNumber() ~= 2 then
            return sendPokemon(2) or run() or sendUsablePokemon() or attack()
        elseif getOpponentHealthPercent() >= 6 then
            return useMove("False Swipe") or run() or sendUsablePokemon() or attack()
        elseif getOpponentHealthPercent() <= 5   then -- Will still catch shiny Magnemite/Magneton even if it detects Sturdy
            return useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon() or attack()
        else
            return run() or attack() or sendUsablePokemon() 
        end
        
    else
        return run() or attack() or sendUsablePokemon()
    end
end
function Quest:trainerBattle()
	-- bug: if last pokemons have only damaging but type ineffective
	-- attacks, then we cannot use the non damaging ones to continue.
	if not self.canRun then -- trying to switch while a pokemon is squeezed end up in an infinity loop
		return attack() or game.useAnyMove()
	end
	return attack() or sendUsablePokemon() or sendAnyPokemon() -- or game.useAnyMove()
end

function Quest:battle()
	if not self.inBattle then
		self.inBattle = true
		self:battleBegin()
	end
	if isWildBattle() then
		return self:wildBattle()
	else
		return self:trainerBattle()
	end
end

function Quest:dialog(message)
	if self.dialogs == nil then
		return false
	end
	for _, dialog in pairs(self.dialogs) do
		if dialog:messageMatch(message) then
			dialog.state = true
			return true
		end
	end
	return false
end

function Quest:battleMessage(message)
	if sys.stringContains(message, "You can not run away!") then
		sys.canRun = false
	elseif self.pokemon ~= nil and self.forceCaught ~= nil then
		if sys.stringContains(message, "caught") and sys.stringContains(message, self.pokemon) then --Force caught the specified pokemon on quest 1time
			log("Selected Pokemon: " .. self.pokemon .. " is Caught")
			self.forceCaught = true
			return true
		end
	elseif sys.stringContains(message, "black out") and self.level < 100 and self:isTrainingOver() then
		self.level = self.level + 1
		self:startTraining()
		log("Increasing " .. self.name .. " quest level to " .. self.level .. ". Training time!")
		return true
	elseif sys.stringContains(message, "You can not switch this Pokemon!") then
		return relog(1,"Hello")
		

	end
	return false
end

function Quest:systemMessage(message)	
	return false
end

local hmMoves = {
	"cut",
	"surf",
	"flash"
}

function Quest:chooseForgetMove(moveName, pokemonIndex) -- Calc the WrostAbility ((Power x PP)*(Accuract/100))
	local ForgetMoveName
	local ForgetMoveTP = 9999
	for moveId=1, 4, 1 do
		local MoveName = getPokemonMoveName(pokemonIndex, moveId)
		if MoveName == nil or MoveName == "cut" or MoveName == "surf" or MoveName == "rock smash" or MoveName == "dive" or (MoveName == "sleep powder" and not hasItem("Plain Badge")) then
		else
		local CalcMoveTP = math.modf((getPokemonMaxPowerPoints(pokemonIndex,moveId) * getPokemonMovePower(pokemonIndex,moveId))*(math.abs(getPokemonMoveAccuracy(pokemonIndex,moveId)) / 100))
			if CalcMoveTP < ForgetMoveTP then
				ForgetMoveTP = CalcMoveTP
				ForgetMoveName = MoveName
			end
		end
	end
	log("[Learning Move: " .. moveName .. "  -->  Forget Move: " .. ForgetMoveName .. "]")
	return ForgetMoveName
end

function Quest:learningMove(moveName, pokemonIndex)
	return forgetMove(self:chooseForgetMove(moveName, pokemonIndex))
end

return Quest
