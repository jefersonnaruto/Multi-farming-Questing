name = "PC Info Dump"
author = "Zonz"
description = "Dumps information about every Pokemon in the PC to a file. Start in a Pokecenter."

setOptionName(1, "Include Moves")
setOptionDescription(1, "Dump data about every move on every Pokemon.")

setTextOptionName(1, "File to write to")
setTextOptionDescription(1, "The name of the file to dump PC data to.\nWill overwrite!\n\nLocated in Logs/[fileName]")
setTextOption(1, "PCLog.txt")

setTextOptionName(2, "Name")
setTextOptionDescription(2, "Will only log data on Pokemon with this name.\nLeave blank to do everything.")

function onStart()
	textToLog = setmetatable({}, {__index = table})
	currentBoxId = 1
end

function onPathAction()
	if not isPCOpen() and not usePC() then
		return fatal("Script must be started in a Pokecenter.")
	end
	if isPCOpen() then
		if isCurrentPCBoxRefreshed() then
			return managePC()
		else
			log("Box not refreshed")
			return
		end
	end
end

bestPokeName = ""
bestPokeIVTotal = 0
bestPokeBox = 1
bestPokeSlot = 1

function managePC()

	boxCount = getPCBoxCount()
	currentBoxSize = getCurrentPCBoxSize()
	
	if currentBoxId > boxCount then
		currentBoxId = 1
		openPCBox(currentBoxId)
		if #textToLog == 0 and getTextOption(2) != "" then
			return fatal("No Pokemon with the name " .. getTextOption(2) .. " were found.")
		end
		logToFile(getTextOption(1), textToLog, true)
		log("Best IV'd Pokemon is " .. bestPokeName .. " in box " .. bestPokeBox .. " slot " .. bestPokeSlot .. " with an IV total of " .. bestPokeIVTotal .. ".")
		return fatal("PC iteration complete. PC data dumped to Logs/" .. getTextOption(1))
	end
	
	if getCurrentPCBoxId() == currentBoxId then
		append("Box " .. currentBoxId .. ":")
		log("Checking Box " .. currentBoxId)
		for i = 1, currentBoxSize do
			if getTextOption(2) == "" or getPokemonNameFromPC(currentBoxId, i) == getTextOption(2) then
				append("	Slot " .. i .. ":")
				append("		Name: " .. getPokemonNameFromPC(currentBoxId, i))
				append("		Level: " .. getPokemonLevelFromPC(currentBoxId, i))
				append("		HP type: " .. getHPType(currentBoxId, i))
				append("		Nature: " .. getPokemonNatureFromPC(currentBoxId, i) .. " (" .. getNatureModifier(getPokemonNatureFromPC(currentBoxId, i)) .. ")")
				append("		Ability: " .. getPokemonAbilityFromPC(currentBoxId, i))
				append("		IVs: " .. getIVs(currentBoxId, i))
				append("		Form: " .. getPokemonFormFromPC(currentBoxId, i))
				if getEVs(currentBoxId, i) then append("		EVs: " .. getEVs(currentBoxId, i)) end
				if getPokemonHeldItemFromPC(currentBoxId, i) then append("		Held Item: " .. getPokemonHeldItemFromPC(currentBoxId, i)) end
				if isPokemonFromPCShiny(currentBoxId, i) then append("		This Pokemon is shiny!") end
				if getOption(1) then getMoves(currentBoxId, i) end
				append("")
			end
		end
		currentBoxId = currentBoxId + 1
	end
	
	openPCBox(currentBoxId)
	
end

function getIVs(boxIndex, pokeIndex)
	
	local iv = {"ATK", "DEF", "SPD", "SPATK", "SPDEF", "HP"}
	local total = 0
	local stats = {}
	
	for i = 1, 6 do
		total = total + getPokemonIndividualValueFromPC(boxIndex, pokeIndex, iv[i])
		stats[i] = iv[i] .. ": " .. getPokemonIndividualValueFromPC(boxIndex, pokeIndex, iv[i])
	end
	
	if total > bestPokeIVTotal then
		bestPokeIVTotal = total
		bestPokeName = getPokemonNameFromPC(boxIndex, pokeIndex)
		bestPokeBox = boxIndex
		bestPokeSlot = pokeIndex
	end
	
	return table.concat(stats, " - ") .. " (Total: " .. total .. ")"
	
end

function getEVs(boxIndex, pokeIndex)
	
	local ev = {"ATK", "DEF", "SPD", "SPATK", "SPDEF", "HP"}
	local total = 0
	local stats = {}
	
	for i = 1, 6 do
		local stat = getPokemonEffortValueFromPC(boxIndex, pokeIndex, ev[i])
		if stat > 0 then
			total = total + stat
			stats[#stats + 1] = ev[i] .. ": " .. stat
		end
	end
	
	if total == 0 then return nil end
	
	if #stats > 1 then
		return table.concat(stats, " - ") .. " (Total: " .. total .. ")"
	else
		return stats[1]
	end
	
end

function getHPType(boxIndex, pokeIndex)

	local HPTypes = {"Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark"}	
	local stats = {"HP", "ATK", "DEF", "SPD", "SPATK", "SPDEF"}
	local statTotal = 0
	
	for i = 1, 6 do statTotal = statTotal + ((getPokemonIndividualValueFromPC(boxIndex, pokeIndex, stats[i]) % 2) * (2 ^ (i - 1))) end
	
	return HPTypes[math.floor((statTotal * 15) / 63) + 1]
	
end

function getMoves(boxIndex, pokeIndex)
	
	for i = 1, 4 do
		if getPokemonMoveNameFromPC(boxIndex, pokeIndex, i) then
			append("")
			append("		Move " .. i .. ": " .. getPokemonMoveNameFromPC(boxIndex, pokeIndex, i):title())
			append("			Power: " .. getPokemonMovePowerFromPC(boxIndex, pokeIndex, i))
			append("			Accuracy: " .. getPokemonMoveAccuracyFromPC(boxIndex, pokeIndex, i))
			append("			PP: " .. getPokemonRemainingPowerPointsFromPC(boxIndex, pokeIndex, i) .. "/" .. getPokemonMaxPowerPointsFromPC(boxIndex, pokeIndex, i))
			append("			Move Type: " .. getPokemonMoveTypeFromPC(boxIndex, pokeIndex, i):title())
			append("			Move Damage Type: " .. getPokemonMoveDamageTypeFromPC(boxIndex, pokeIndex, i))
			append("			Status: " .. tostring(getPokemonMoveStatusFromPC(boxIndex, pokeIndex, i)):title())
		end
	end
	
end

function string.title(str)	
	return str:gsub("(%a)([%w_']*)", function(a,b) return a:upper() .. b:lower() end)
end

function getNatureModifier(nature)
	
		if nature == "Lonely" then return "+Attack -Defence"
	elseif nature == "Adamant" then return "+Attack -Sp. Attack"
	elseif nature == "Naughty" then return "+Attack -SpDefence"
	elseif nature == "Brave" then return "+Attack -Speed"
	
	elseif nature == "Bold" then return "+Defence -Attack"
	elseif nature == "Impish" then return "+Defence -SpAttack"
	elseif nature == "Lax" then return "+Defence -SpDefence"
	elseif nature == "Relaxed" then return "+Defence -Speed"
	
	elseif nature == "Modest" then return "+SpAttack -Attack"
	elseif nature == "Mild" then return "+SpAttack -Defence"
	elseif nature == "Rash" then return "+SpAttack -SpDefence"
	elseif nature == "Quiet" then return "+SpAttack -Speed"
	
	elseif nature == "Calm" then return "+SpDefence -Attack"
	elseif nature == "Gentle" then return "+SpDefence -Defence"
	elseif nature == "Careful" then return "+SpDefence -SpAttack"
	elseif nature == "Sassy" then return "+SpDefence -Speed"
	
	elseif nature == "Timid" then return "+Speed -Attack"
	elseif nature == "Hasty" then return "+Speed -Defence"
	elseif nature == "Jolly" then return "+Speed -Sp. Attack"
	elseif nature == "Naive" then return "+Speed -Sp. Defence"
	
	elseif nature == "Hardy" then return "Neutral"
	elseif nature == "Quirky" then return "Neutral"
	elseif nature == "Docile" then return "Neutral"
	elseif nature == "Bashful" then return "Neutral"
	elseif nature == "Serious" then return "Neutral"
	
	else return "Unknown"
	end
	
end


function append(str)
	textToLog:insert(str)	
end
