name = "Catch and Release v1.1"
author = "Zonz"
description = "This script hunts for a set of user-defined Pokémon and releases the \"bad\" ones. See config for details."

pf = require "Pathfinder/MoveToApp"
dofile "config.lua"

function onStart()
	
	-- Converting strings to Title Case so they can be non-case sensitive
	sturdy = false
	weakMove = toTitleCase(weakMove)
	statusMove = toTitleCase(statusMove)
	catchList = toTitleCase(catchList)
	exceptionCatches = toTitleCase(exceptionCatches)
	natures = toTitleCase(natures)
	abilities = toTitleCase(abilities)
	hpTypes = toTitleCase(hpTypes)
	items = toTitleCase(items)
	rod = toTitleCase(rod)
	ballType = toTitleCase(ballType)
	morningSync = toTitleCase(morningSync)
	daySync = toTitleCase(daySync)
	nightSync = toTitleCase(nightSync)
	if not stringContains(morningMap, "mansion") then morningMap = toTitleCase(morningMap) end -- "Cinnabar mansion" - error with the m
	if not stringContains(dayMap, "mansion") then dayMap = toTitleCase(dayMap) end
	if not stringContains(nightMap, "mansion") then nightMap = toTitleCase(nightMap) end
	if not stringContains(farmMap, "mansion") then farmMap = toTitleCase(farmMap) end
	
	evToTrain = evToTrain:upper()
	farmingEV = farmingEV:upper()
	
	validNatures  = {"Hardy", "Lonely", "Brave", "Adamant", "Naughty", "Bold", "Docile", "Relaxed", "Impish", "Lax", "Timid", "Hasty", "Serious", 
					 "Jolly", "Naive", "Modest", "Mild", "Quiet", "Bashful", "Rash", "Calm", "Gentle", "Sassy", "Careful", "Quirky"}
					 
	validHPTypes = {"Fighting", "Flying", "Poison", "Ground", "Rock", "Bug", "Ghost", "Steel", "Fire", "Water", "Grass", "Electric", "Psychic", "Ice", "Dragon", "Dark"}
	
	validEVs = {"HP", "HEALTH", "ATK", "ATTACK", "DEF", "DEFENCE", "DEFENSE", "SPATK", "SPATTACK", "SPDEF", "SPDEFENCE", "SPDEFENSE", "SPD", "SPEED"}
	
	--------------------------------------------------------------------- ERROR HANDLING ---------------------------------------------------------------------
	
	if weakMove and weakMove != "" then
		if findMove(weakMove) then
			weakMoveUser = findMove(weakMove)
			weakMoveUserID = getPokemonUniqueId(weakMoveUser)
		else
			return fatal("Error: " .. weakMove .. " user not found - please check config")
		end
	else
		weakMoveUser = 0
	end
	
	if statusMove and statusMove != "" then
		if findMove(statusMove) then
			statusMoveUser = findMove(statusMove)
			statusMoveUserID = getPokemonUniqueId(statusMoveUser)
		else
			return fatal("Error: " .. statusMove .. " user not found - please check config")
		end
	else
		statusMoveUser = 0
	end
	
	if useRolePlay then
		if findMove("Role Play") then
			rolePlayUser = findMove("Role Play")
			rolePlayUserID = getPokemonUniqueId(rolePlayUser)
		elseif not rolePlayAsWell then
			return fatal("Error: Role Play user not found - please check config")
		end
	else
		rolePlayUser = 0
	end
	
	if tossWrongNature and not natures[1] then return fatal("Error: Please define at least 1 nature") end
	if (tossWrongAbility or rolePlayUser > 0) and not abilities[1] then return fatal("Error: Please define at least 1 ability") end
	if tossWrongHP and not hpTypes[1] then return fatal("Error: Please define at least 1 HP Type") end
	
	if ballMin > 0 and buyAmount < 1 then return fatal("Error: Invalid buyAmount - please check config") end
	
	if (type(morningArea) == "table" and #morningArea != 2 and #morningArea % 4 != 0)
	or (type(morningArea) == "string" and morningArea:upper() != "GRASS" and morningArea:upper() != "WATER") then
		return fatal("Error: Invalid morningArea - please check config")
	end
	
	if (type(dayArea) == "table" and #dayArea != 2 and #dayArea % 4 != 0)
	or (type(dayArea) == "string" and dayArea:upper() != "GRASS" and dayArea:upper() != "WATER")
		then return fatal("Error: Invalid dayArea - please check config")
	end
	
	if (type(nightArea) == "table" and #nightArea != 2 and #nightArea % 4 != 0)
	or (type(nightArea) == "string" and nightArea:upper() != "GRASS" and nightArea:upper() != "WATER")
		then return fatal("Error: Invalid nightArea - please check config")
	end
	
	if minMoney > 0 then
		if (type(farmArea) == "table" and #farmArea != 2 and #farmArea % 4 != 0)
		or (type(farmArea) == "string" and farmArea:upper() != "GRASS" and farmArea:upper() != "WATER")
			then return fatal("Error: Invalid farmArea - please check config")
		end
	end
	
	if ((type(morningArea) == "table" and #morningArea == 2)
	or (type(dayArea) == "table" and #dayArea == 2)
	or (type(nightArea) == "table" and #nightArea == 2)
	or (type(farmArea) == "table" and #farmArea == 2 and minMoney > 0))
	and not hasItem(rod) then
		return fatal("Error: " .. rod .. " not in inventory - please check config")
	end
	
	if useItems and #items != 5 then return fatal("Error: Invalid items list - please check config") end
	if useItems then for i = 1, 5 do if type(items[i]) != "string" then return fatal("Error: items[" .. i .. "] (" .. tostring(items[i]) .. ") is invalid - please check config") end end end
	
	if #minIVs != 6 then return fatal("Error: Invalid IV set - please check config") end
	for i = 1, 6 do if minIVs[i] > 31 then return fatal("Error: One or more IV's are set above 31 - please check config") end end
	
	if tossWrongNature and invalidTable(natures, validNatures) then return fatal("Error: '" .. invalidTable(natures, validNatures) .. "' is not a valid Nature - please check config") end
	if tossWrongHP and invalidTable(hpTypes, validHPTypes) then return fatal("Error: '" .. invalidTable(hpTypes, validHPTypes) .. "' is not a valid HP Type - please check config") end
	
	if not inTable(validNatures, morningSync) then return fatal("Error: morningSync (" .. morningSync .. ") is not a valid nature - please check config") end
	if not inTable(validNatures, daySync) then return fatal("Error: daySync (" .. daySync .. ") is not a valid nature - please check config") end
	if not inTable(validNatures, nightSync) then return fatal("Error: nightSync (" .. nightSync .. ") is not a valid nature - please check config") end
	
	if farm and evToTrain and evToTrain != "" and not inTable(validEVs, evToTrain) then return fatal("Error: '" .. evToTrain .. "' is not a valid EV type - please check config") end
	if minMoney > 0 and farmingEV and farmingEV != "" and not inTable(validEVs, farmingEV) then return fatal("Error: '" .. farmingEV .. "' is not a valid EV type - please check config") end
	
	if tossWrongNature then
		if not inTable(natures, morningSync) then log("Warning: morningSync (" .. morningSync .. ") is not present in the given list of natures") end
		if not inTable(natures, daySync) then log("Warning: daySync (" .. daySync .. ") is not present in the given list of natures") end
		if not inTable(natures, nightSync) then log("Warning: nightSync (" .. nightSync .. ") is not present in the given list of natures") end
	end
	
	if ballType != "Pokeball" and ballType != "Great Ball" and ballType != "Ultra Ball" then return fatal("Error: Invalid ballType - please check config") end
	
	----------------------------------------------------------------------------------------------------------------------------------------------------------
	
	
	if autoEvolve then enableAutoEvolve() else disableAutoEvolve() end
	if enableMessages then enablePrivateMessage() else disablePrivateMessage() end
	
	checkCatchList = array(catchList)
	checkExceptions = array(exceptionCatches)
	checkNatures = array(natures)
	checkAbilities = array(abilities)
	checkHPTypes = array(hpTypes)
	
	currentBoxId = 1 -- Used for everything except releasing
	releaseBoxId = 1 -- The box we were in the last time we checked for Pokémon to release
	pcUsed = false
	usableCount = 0
	releasedCount = 0
	caughtCount = 0
	wildCount = 0
	shinyCount = 0
	pokecenterVisits = 0
	killedCount = 0
	lineSwitch = false -- Used in moveToLine()
	rand = 0 -- The rectangle we're using in updateTargetRect()
	tmpRand = 0	-- Used in updateTargetRect()
	pokemonHealth = 0 -- Used in onBattleAction()
	opponentHealth = 0
	releasing = false
	withdrawing = false
	timerSwitch = false
	rolePlayed = false
	abilityFound = false -- For use during Role Play
	location = "" -- Will change according to what time of day it is
	needReleased = true -- Whether or not we need check our PC for Pokémon to release
	farming = false -- Only occurs when getMoney() < minMoney
	surfChecked = false -- Looked for a Pokémon with Surf and couldn't find one
	cutChecked = false
	usables = {}
	timerRoot = os.time() -- For use in timer()
	startTime = os.time() -- For use in runningTime()
	rectTimer = os.time() -- For use in updateTargetRect()
	startMoney = getMoney()
	statusMoveUserDefault = statusMoveUser -- This is used to reset the statusMoveUser value in case we used Spore on a Grass-type - see onBattleMessage()
	
	catchCounter = {} -- Holds the name of each Pokémon and the amount we've caught of them
	for _, value in pairs(catchList) do
		catchCounter[value] = 0
	end
	for _, value in pairs(exceptionCatches) do
		catchCounter[value] = 0
	end	
	
	if farmerId > 0 then farmerID = getPokemonUniqueId(farmerId) else farmerID = nil end	
	if getTeamSize() == 6 then sixthPoke = getPokemonUniqueId(6) else sixthPoke = nil end
	
	tmpID = 0 -- When we start farming, we save the Pokémon we switch from as this value, so we can switch back to it when we're done farming
	
	if catchList[1] and (tossWrongNature or tossWrongAbility or tossWrongHP or (minIVs[1] + minIVs[2] + minIVs[3] + minIVs[4] + minIVs[5] + minIVs[6] > 0)) then
		log("Hunting for " .. formattedTable(catchList) .. ".")
		log("======== !! WARNING !! ========")
		if tossWrongNature then log("Will release " .. formattedTable(catchList) .. " with a nature other than " .. formattedTable(natures, "or") .. "!") end
		if tossWrongAbility then log("Will release " .. formattedTable(catchList) .. " without the " .. formattedTable(abilities, "or") .. " ability!") end
		if tossWrongHP then log("Will release " .. formattedTable(catchList) .. " without a " .. formattedTable(hpTypes, "or") .. " HP type!") end
		if minIVs[1] > 0 then log("Will release " .. formattedTable(catchList) .. " with an Attack IV lower than " .. minIVs[1] .. "!") end
		if minIVs[2] > 0 then log("Will release " .. formattedTable(catchList) .. " with a Defence IV lower than " .. minIVs[2] .. "!") end
		if minIVs[3] > 0 then log("Will release " .. formattedTable(catchList) .. " with a Special Attack IV lower than " .. minIVs[3] .. "!") end
		if minIVs[4] > 0 then log("Will release " .. formattedTable(catchList) .. " with a Special Defence IV lower than " .. minIVs[4] .. "!") end
		if minIVs[5] > 0 then log("Will release " .. formattedTable(catchList) .. " with a Speed IV lower than " .. minIVs[5] .. "!") end
		if minIVs[6] > 0 then log("Will release " .. formattedTable(catchList) .. " with an HP IV lower than " .. minIVs[6] .. "!") end
		log("Please be sure to check the config!")
		if exceptionCatches[1] then log("Pokémon to hunt for that will not get released: " .. formattedTable(exceptionCatches) .. ".") end
	else
		if catchList[1] or exceptionCatches[1] then 
			log("Hunting for " .. formattedTable(tableConcat(catchList, exceptionCatches)) .. ".")
		else
			log("Script will not catch any Pokémon except shinies.")
		end
		log("Script will not release any Pokémon.")
		needReleased = "Never"
	end
	
end


function onPathAction()
	
	statusMoveUser = statusMoveUserDefault -- Resetting statusMoveUser in case we used Spore on a Grass-type
	rolePlayed = false
	abilityFound = false
	pokemonHealth = 0
	opponentHealth = 0
	sturdy = false
	
	if not findMove("Surf") and hasItem("HM03 - Surf") and not surfChecked then
		logOnce("Retrieving a Pokémon with Surf")
		return retrievePokemon("Surf")
	end
	
	if not findMove("Cut") and hasItem("HM01 - Cut") and not cutChecked then
		logOnce("Retrieving a Pokémon with Cut")
		return retrievePokemon("Cut")
	end
	
	if getItemQuantity(ballType) == 0 then
		fatal("Out of " .. ballType .. "s - stopping script")
	end
	
	if not farming then		
		-- Getting weakMoveUser, statusMoveUser, and rolePlayUser off of slot 1 to make way for our Sync Pokémon
		if weakMoveUser == 1 then
			if statusMoveUser == 2 then
				if rolePlayUser == 3 then
					if farmerId == weakMoveUser then farmerId = 4 end
					log("Moving " .. getPokemonName(1) .. " to slot 4")
					weakMoveUser = 4
					return swapPokemon(1, 4)
				else
					if farmerId == weakMoveUser then farmerId = 3 end
					log("Moving " .. getPokemonName(1) .. " to slot 3")
					weakMoveUser = 3
					return swapPokemon(1, 3)
				end
			else
				if rolePlayUser == 2 then
					if statusMoveUser == 3 then
						if farmerId == weakMoveUser then farmerId = 4 end
						log("Moving " .. getPokemonName(1) .. " to slot 4")
						weakMoveUser = 3
						return swapPokemon(1, 4)
					else
						if farmerId == weakMoveUser then farmerId = 3 end
						if statusMoveUser == weakMoveUser then statusMoveUser = 3 end
						statusMoveUserDefault = statusMoveUser
						log("Moving " .. getPokemonName(1) .. " to slot 3")
						weakMoveUser = 3
						return swapPokemon(1, 3)
					end
				else
					if farmerId == weakMoveUser then farmerId = 2 end
					if statusMoveUser == weakMoveUser then statusMoveUser = 2 end
					statusMoveUserDefault = statusMoveUser
					log("Moving " .. getPokemonName(1) .. " to slot 2")
					weakMoveUser = 2
					return swapPokemon(1, 2)
				end
			end
		end
		
		if statusMoveUser == 1 then
			if weakMoveUser == 2 then
				if rolePlayUser == 3 then
					if farmerId == statusMoveUser then farmerId = 4 end
					log("Moving " .. getPokemonName(1) .. " to slot 4")
					statusMoveUser = 4
					statusMoveUserDefault = statusMoveUser
					return swapPokemon(1, 4)
				else
					if farmerId == statusMoveUser then farmerId = 3 end
					log("Moving " .. getPokemonName(1) .. " to slot 3")
					statusMoveUser = 3
					statusMoveUserDefault = statusMoveUser
					return swapPokemon(1, 3)
				end
			else
				if rolePlayUser == 2 then
					if weakMoveUser == 3 then
						if farmerId == statusMoveUser then farmerId = 4 end
						log("Moving " .. getPokemonName(1) .. " to slot 4")
						statusMoveUser = 4
						statusMoveUserDefault = statusMoveUser
						return swapPokemon(1, 4)
					else
						if farmerId == statusMoveUser then farmerId = 3 end
						log("Moving " .. getPokemonName(1) .. " to slot 3")
						statusMoveUser = 3
						statusMoveUserDefault = statusMoveUser
						return swapPokemon(1, 3)
					end
				else
					if farmerId == statusMoveUser then farmerId = 2 end
					log("Moving " .. getPokemonName(1) .. " to slot 2")
					statusMoveUser = 2
					statusMoveUserDefault = statusMoveUser
					return swapPokemon(1, 2)
				end
			end
		end
		
		if rolePlayUser == 1 and (getPokemonAbility(1) != "Synchronize"
		or (isMorning() and getPokemonNature(1) != morningSync)
		or (isNoon() and getPokemonNature(1) != daySync)
		or (isNight() and getPokemonNature(1) != nightSync)) then
			if weakMoveUser == 2 then
				if statusMoveUser == 3 then
					if farmerId == rolePlayUser then farmerId = 4 end
					log("Moving " .. getPokemonName(1) .. " to slot 4")
					rolePlayUser = 4
					return swapPokemon(1, 4)
				else
					if farmerId == rolePlayUser then farmerId = 3 end
					log("Moving " .. getPokemonName(1) .. " to slot 3")
					rolePlayUser = 3
					return swapPokemon(1, 3)
				end
			else
				if statusMoveUser == 2 then
					if weakMoveUser == 3 then
						if farmerId == rolePlayUser then farmerId = 4 end
						log("Moving " .. getPokemonName(1) .. " to slot 4")
						rolePlayUser = 4
						swapPokemon(1, 4)
					else
						if farmerId == rolePlayUser then farmerId = 3 end
						log("Moving " .. getPokemonName(1) .. " to slot 3")
						rolePlayUser = 3
						return swapPokemon(1, 3)
					end
				else
					if farmerId == rolePlayUser then farmerId = 2 end
					log("Moving " .. getPokemonName(1) .. " to slot 2")
					rolePlayUser = 2
					return swapPokemon(1, 2)
				end
			end
		end
	elseif getMoney() >= moneyStop or minMoney == 0 then
		if isMorning() then
			log("Done farming - returning to " .. morningMap .. ".")
			lastMessage2 = "Heading to " .. morningMap .. "."
		elseif isNoon() then
			log("Done farming - returning to " .. dayMap .. ".")
			lastMessage2 = "Heading to " .. dayMap .. "."
		else
			log("Done farming - returning to " .. nightMap .. ".")
			lastMessage2 = "Heading to " .. nightMap .. "."
		end
		farming = false
		if farmerID then
			if weakMoveUser == 1 then weakMoveUser = tmpID end
			if statusMoveUser == 1 then statusMoveUser = tmpID end
			statusMoveUserDefault = statusMoveUser
			return swapPokemon(tmpID, 1)
		end
	else
		if farmerID then
			if getPokemonUniqueId(1) != farmerID then
				if findUniqueIdInParty(farmerID) then
					tmpID = findUniqueIdInParty(farmerID)
					if weakMoveUser == tmpID then weakMoveUser = 1 end
					if statusMoveUser == tmpID then statusMoveUser = 1 end
					statusMoveUserDefault = statusMoveUser
					return swapPokemon(tmpID, 1)
				else
					logOnce("Heading to the nearest PC to get our farmer Pokémon.")
					return retrievePokemon(farmerID)
				end
			end
		end
	end
	
	if isMorning() then
		logOnce("It is now Morning.")
	elseif isNoon() then
		logOnce("It is now Daytime.")
	else
		logOnce("It is now Nighttime.")
	end
	
	if weakMoveUser > 0 and not findMove(weakMove) then -- If we stored our weakMove user when moving Syncs around (it shouldn't happen, but just in case)
		logOnce("Retrieving our " .. weakMove .. " user.")
		return retrievePokemon(weakMoveUserID)
	elseif statusMoveUser > 0 and not findMove(statusMove) then
		logOnce("Retrieving our " .. statusMove .. " user.")
		return retrievePokemon(statusMoveUserID)
	elseif useRolePlay and not rolePlayAsWell and not findMove("Role Play") then -- If we stored our Role Play user when moving Syncs around
		logOnce("Retrieving our Role Play user.")
		return retrievePokemon(rolePlayUserID)
	elseif getMoney() < minMoney and not stringContains(getMapName(), "Safari") and getMapName() != "Moon" then
		if not farming then
			log("Money is too low.")
			farming = true
		end
		location = farmMap
		if farmerID then
			if getPokemonUniqueId(1) != farmerID then
				if findUniqueIdInParty(farmerID) then
					tmpID = findUniqueIdInParty(farmerID)
					if weakMoveUser == tmpID then weakMoveUser = 1 end
					if statusMoveUser == tmpID then statusMoveUser = 1 end
					statusMoveUserDefault = statusMoveUser
					return swapPokemon(tmpID, 1)
				else
					logOnce("Heading to the nearest PC to get our farmer Pokémon.")
					return retrievePokemon(farmerID)
				end
			end
		end
		if getMapName() != farmMap then
			logOnce("Heading to " .. farmMap .. " until we have at least " .. moneyStop .. " PokeDollars.")
		else
			logOnce("Farming until we have at least " .. moneyStop .. " PokeDollars.")
		end
	elseif isMorning() then
		location = morningMap
		if getPokemonNature(1) != morningSync or getPokemonAbility(1) != "Synchronize" or (rolePlayAsWell and not hasMove(1, "Role Play")) then
			if findPokemonWithSync(morningSync) then
				if rolePlayAsWell and rolePlayUser > 0 then
					rolePlayUser = 1
				elseif rolePlayUser == 1 then
					rolePlayUser = findPokemonWithSync(morningSync)
				end
				return swapPokemon(findPokemonWithSync(morningSync), 1)
			else
				logOnce2("Heading to the nearest PC to get a" .. vowelCheck(morningSync) .. " Sync.")
				return retrievePokemon(morningSync)
			end
		else
			if getMapName() != morningMap then
				logOnce2("Heading to " .. morningMap .. ".")
			end
		end
	elseif isNoon() then
		location = dayMap
		if getPokemonNature(1) != daySync or getPokemonAbility(1) != "Synchronize" or (rolePlayAsWell and not hasMove(1, "Role Play")) then
			if findPokemonWithSync(daySync) then
				if rolePlayAsWell and rolePlayUser > 0 then
					rolePlayUser = 1
				elseif rolePlayUser == 1 then
					rolePlayUser = findPokemonWithSync(daySync)
				end
				return swapPokemon(findPokemonWithSync(daySync), 1)
			else
				logOnce2("Heading to the nearest PC to get a" .. vowelCheck(daySync) .. " Sync.")
				return retrievePokemon(daySync)
			end
		else
			if getMapName() != dayMap then
				logOnce2("Heading to " .. dayMap .. ".")
			end
		end
	elseif isNight() then
		location = nightMap
		if getPokemonNature(1) != nightSync or getPokemonAbility(1) != "Synchronize" or (rolePlayAsWell and not hasMove(1, "Role Play")) then
			if findPokemonWithSync(nightSync) then
				if rolePlayAsWell and rolePlayUser > 0 then
					rolePlayUser = 1
				elseif rolePlayUser == 1 then
					rolePlayUser = findPokemonWithSync(nightSync)
				end
				return swapPokemon(findPokemonWithSync(nightSync), 1)
			else
				logOnce2("Heading to the nearest PC to get a" .. vowelCheck(nightSync) .. " Sync.")
				return retrievePokemon(nightSync)
			end
		else
			if getMapName() != nightMap then
				logOnce2("Heading to " .. nightMap .. ".")
			end
		end
	end
	
	if getItemQuantity(ballType) < ballMin then
		return pf.useNearestPokemart(getMapName(), ballType, buyAmount)
	else
	
		if useItems then
			for i = 1, getTeamSize() do
				if getPokemonHealth(i) == 0 and items[1] != "" and hasItem(items[1]) then -- Reviving
					log("Using " .. items[1] .. " on " .. getPokemonName(i))
					return useItemOnPokemon(items[1], i)
				end
				if getPokemonHealthPercent(i) < 30 and items[2] != "" and hasItem(items[2]) then -- Healing
					log("Using " .. items[2] .. " on " .. getPokemonName(i))
					return useItemOnPokemon(items[2], i)
				end
				for m = 1, 4 do
					if getPokemonMoveName(i, m) then -- In case it has less than 4 moves
						if getRemainingPowerPoints(i, getPokemonMoveName(i, m)) == 0 and items[3] != "" and hasItem(items[3]) then -- Restoring PP
							log("Using " .. items[3] .. " on " .. getPokemonName(i) .. "'s " .. toTitleCase(getPokemonMoveName(i, m)))
							pushDialogAnswer(m)
							return useItemOnPokemon(items[3], i)
						end
					end
				end
				if getPokemonStatus(i) == "PARALIZE" and items[4] != "" and hasItem(items[4]) then -- Curing Paralysis
					log("Using " .. items[4] .. " on " .. getPokemonName(i))
					return useItemOnPokemon(items[4], i)
				end
				if getPokemonStatus(i) == "POISON" and items[5] != "" and hasItem(items[5]) then -- Curing Poison
					log("Using " .. items[5] .. " on " .. getPokemonName(i))
					return useItemOnPokemon(items[5], i)
				end
			end
		end
		
		if getPokemonHealthPercent(1) > 30
		and (farmer == 0 or hasGoodMoves(farmer))
		and (not farming or hasGoodMoves(1))
		and (weakMoveUser == 0 or (getRemainingPowerPoints(weakMoveUser, weakMove) > 0 and getPokemonHealthPercent(weakMoveUser) > 30))
		and (statusMoveUser == 0 or (getRemainingPowerPoints(statusMoveUser, statusMove) > 0 and getPokemonHealthPercent(statusMoveUser) > 30))
		and (rolePlayUser == 0 or (getRemainingPowerPoints(rolePlayUser, "Role Play") > 0 and getPokemonHealthPercent(rolePlayUser) > 30))
		and checkStatus() then
			if stringContains(getMapName(), "Pokecenter") then
				if not pcUsed and needReleased and needReleased != "Never" then
					usePC()
				elseif not releasing and not withdrawing then
					return pf.moveTo(getMapName(), location)
				end
			elseif not pf.moveTo(getMapName(), location) then
				pcUsed = false
				if farming then
					return moveToArea(farmArea)
				elseif isMorning() then
					return moveToArea(morningArea)
				elseif isNoon() then
					return moveToArea(dayArea)
				elseif isNight() then
					return moveToArea(nightArea)
				end
			end
			
		else
			return pf.useNearestPokecenter(getMapName())
		end
	end
	
	if isPCOpen() then
		if isCurrentPCBoxRefreshed() then
			if releasing then
				timer(1)
				return releaseFromTeam()
			elseif withdrawing then
				return withdrawPokemon()
			elseif not pcUsed then
				return checkPC()
			end
		else
			return
		end
	end
	
end


function moveToArea(area)
	
	if type(area) == "string" then
		if area:upper() == "GRASS" then
			return moveToGrass()
		else
			return moveToWater()
		end
	else
		if #area == 2 then
			return updateFishing(area)
		elseif #area > 4 then
			return updateTargetRect(area)
		elseif area[1] == area[3] or area[2] == area[4] then
			return moveToLine(area)
		else
			return moveToRectangle(area[1], area[2], area[3], area[4])
		end
	end		
	
end


function updateFishing(list)
	
	-- Moves to a position and uses rod
	
	if getPlayerX() == list[1] and getPlayerY() == list[2] then
		return useItem(rod)
	else
		return moveToCell(list[1], list[2])
	end
	
end


function updateTargetRect(list)

	-- Every minutesToMove minutes, picks a random integer between 1 and #list / 4 to get a number corresponding to each rectangle in list
	
	if os.difftime(os.time(), rectTimer) > minutesToMove * 60 or rand == 0 or rand > #list / 4 or rand == tmpRand then
		rectTimer = os.time()
		tmpRand = rand
		rand = math.random(#list / 4)
	end
	
	local n = (rand - 1) * 4
	
	if list[n + 1] == list[n + 3] or list[n + 2] == list[n + 4] then
		return moveToLine(list[n + 1], list[n + 2], list[n + 3], list[n + 4])
	else
		return moveToRectangle(list[n + 1], list[n + 2], list[n + 3], list[n + 4])
	end
	
end


function moveToLine(x1, y1, x2, y2) -- Works with a table or 4 integers
	
	-- Alternates between 2 positions
	
	if type(x1) == "table" then
		if lineSwitch then
			if getPlayerX() == x1[1] and getPlayerY() == x1[2] then
				lineSwitch = not lineSwitch
			else
				return moveToCell(x1[1], x1[2])
			end
		else
			if getPlayerX() == x1[3] and getPlayerY() == x1[4] then
				lineSwitch = not lineSwitch
			else
				return moveToCell(x1[3], x1[4])
			end
		end
	else
		if lineSwitch then
			if getPlayerX() == x1 and getPlayerY() == y1 then
				lineSwitch = not lineSwitch
			else
				return moveToCell(x1, y1)
			end
		else
			if getPlayerX() == x2 and getPlayerY() == y2 then
				lineSwitch = not lineSwitch
			else
				return moveToCell(x2, y2)
			end
		end
	end
	
end


function retrievePokemon(var)
	
	if not pf.moveToPC(getMapName()) then usePC() else return end
	
	if isPCOpen() then
		if isCurrentPCBoxRefreshed() then
			boxCount = getPCBoxCount()
			currentBoxSize = getCurrentPCBoxSize()
			
			if currentBoxId > boxCount then
				if type(var) == "string" then
					if inTable(validNatures, var) then
						if rolePlayAsWell then
							fatal("Error: Could not find a" .. vowelCheck(var) .. " Sync in the PC that's at least level " .. minSyncLevel .. " and knows Role Play.")
						else
							fatal("Error: Could not find a" .. vowelCheck(var) .. " Sync in the PC that's at least level " .. minSyncLevel .. ".")
						end
					else
						log("Warning: Could not find a Pokémon with " .. var .. " - continuing without it.")
						currentBoxId = 1
						if var == "Surf" then
							surfChecked = true
							return
						elseif var == "Cut" then
							cutChecked = true
							return
						else
							log("Unknown Error with string")
							return
						end
					end
				else
					if var == weakMoveUserID then
						fatal("Error: Could not find the weakMove User.")
					elseif var == statusMoveUserID then
						fatal("Error: Could not find the statusMove User.")
					elseif var == rolePlayUserID then
						fatal("Error: Could not find the Role Play User.")
					elseif var == farmerID then
						fatal("Error: Could not find farmerId.")
					else
						log("Unknown Error with uniqueID")
						return
					end
				end
			end
			
			if getCurrentPCBoxId() == currentBoxId then
				log("Checking box " .. currentBoxId .. ":")
				for i = 1, currentBoxSize do					
					if type(var) == "string" then
						if inTable(validNatures, var) then -- A nature
							if getPokemonNatureFromPC(currentBoxId, i) == var
							and getPokemonAbilityFromPC(currentBoxId, i) == "Synchronize"
							and getPokemonLevelFromPC(currentBoxId, i) >= minSyncLevel
							and (not rolePlayAsWell or hasMoveInPC(currentBoxId, i, "Role Play")) then
								swapPokemonFromPC(currentBoxId, i, 1)
								currentBoxId = 1
								return
							end
						else -- Surf or Cut
							if hasMoveInPC(currentBoxId, i, var) then
								if var == "Surf" then
									if getTeamSize() >= 5 then
										swapPokemonFromPC(currentBoxId, i, 5)
									else
										withdrawPokemonFromPC(currentBoxId, i)
									end
								else
									if rolePlayUser == 4 then
										if getTeamSize() == 6 then
											sixthPoke = getPokemonUniqueIdFromPC(currentBoxId, i)
											swapPokemonFromPC(currentBoxId, i, 6)
										else
											withdrawPokemonFromPC(currentBoxId, i)
										end
									else
										if getTeamSize() >= 4 then
											swapPokemonFromPC(currentBoxId, i, 4)
										else
											withdrawPokemonFromPC(currentBoxId, i)
										end
									end
								end
								currentBoxId = 1
								return
							end
						end
					else -- Unique ID
						if getPokemonUniqueIdFromPC(currentBoxId, i) == var then
							if var == weakMoveUserID then
								weakMoveUser = 2
								swapPokemonFromPC(currentBoxId, i, 2)
							elseif var == statusMoveUserID then
								if statusMoveUserID == weakMoveUserID then
									statusMoveUser = 2
									swapPokemonFromPC(currentBoxId, i, 2)
								else
									statusMoveUser = 3
									swapPokemonFromPC(currentBoxId, i, 3)
								end
							elseif var == rolePlayUserID then
								if statusMoveUser == 3 then
									rolePlayUser = 4
									swapPokemonFromPC(currentBoxId, i, 4)
								else
									rolePlayUser = 3
									swapPokemonFromPC(currentBoxId, i, 3)
								end
							elseif var == farmerID then
								if weakMoveUserID == farmerID then weakMoveUser = 1 end
								if statusMoveUserID == farmerID then statusMoveUser = 1 end
								if rolePlayUserID == farmerID then rolePlayUser = 1 end
								swapPokemonFromPC(currentBoxId, i, 1)
							end
							currentBoxId = 1
							return
						end
					end
				end
				currentBoxId = currentBoxId + 1
				return openPCBox(currentBoxId)
			else
				return openPCBox(currentBoxId)
			end
		else
			return
		end
	end	
end


function checkPC()

	boxCount = getPCBoxCount()
	currentBoxSize = getCurrentPCBoxSize()
	
	if releaseBoxId > boxCount then
		releaseBoxId = releaseBoxId - 1
		needReleased = false
		pcUsed = true
		if getTeamSize() != 6 then withdrawing = true end
		return
	end
	
	if getCurrentPCBoxId() == releaseBoxId then
		log("Checking box " .. releaseBoxId .. ":")
		for i = 1, currentBoxSize do
			if checkCatchList[getPokemonNameFromPC(releaseBoxId, i)] then
				if not usables[getPokemonUniqueIdFromPC(releaseBoxId, i)] then
					log("Checking " .. getPokemonNameFromPC(releaseBoxId, i) .. " in box " .. releaseBoxId .. " at slot " .. i .. "...")
					log("HP Type: " .. calculateHPType(releaseBoxId, i))
					log("Nature: " .. getPokemonNatureFromPC(releaseBoxId, i))
					log("Ability: " .. tostring(getPokemonAbilityFromPC(releaseBoxId, i)))
					log("IV's --- " .. logIVs(releaseBoxId, i))
					if getPokemonHeldItemFromPC(releaseBoxId, i) then
						log("Held Item: " .. getPokemonHeldItemFromPC(releaseBoxId, i))
					end
					if keepPokemon(releaseBoxId, i) then
						log("This " .. getPokemonNameFromPC(releaseBoxId, i) .. " is usable!")
						usables[getPokemonUniqueIdFromPC(releaseBoxId, i)] = true
						usableCount = usableCount + 1
					else
						log("This " .. getPokemonNameFromPC(releaseBoxId, i) .. " is not usable. Attempting to release...")
						if getTeamSize() == 6 then
							if not sixthPoke then sixthPoke = getPokemonUniqueId(6) end
							swapPokemonFromPC(releaseBoxId, i, 6)
						else
							withdrawPokemonFromPC(releaseBoxId, i)
						end
						releasing = true
						return
					end
				end
			end
		end
		releaseBoxId = releaseBoxId + 1
		return openPCBox(releaseBoxId)
	else
		return openPCBox(releaseBoxId)
	end	
end


function releaseFromTeam()
	
	if not timerSwitch then return end
	if getTeamSize() == 6 then	
		if getPokemonHeldItem(6) then
			log("Retrieving " .. getPokemonHeldItem(6) .. " from " .. getPokemonName(6) .. "...")
			return takeItemFromPokemon(6)
		end
		if checkCatchList[getPokemonName(6)] then -- Just to make sure nothing funky happened when switching Pokémon from the PC
			log("...")
			timerSwitch = false
			return releasePokemonFromTeam(6)
		else
			releasing = false
			return
		end
	else
		log("Release succesful")
		releasedCount = releasedCount + 1
		if pcUsed then withdrawing = true end
		releasing = false
		return
	end
	
end


function timer(seconds)
	if os.difftime(os.time(), timerRoot) >= seconds then
		timerRoot = os.time() + seconds
		timerSwitch = true
	end
end


function withdrawPokemon()
	
	if getTeamSize() == 6 then
		withdrawing = false
		if checkCatchList[getPokemonName(6)] then
			releasing = true
		end
		return
	end
	
	boxCount = getPCBoxCount()
	currentBoxSize = getCurrentPCBoxSize()
	
	if currentBoxId > boxCount then
		withdrawing = false
		currentBoxId = 1
		return
	end
	
	if getCurrentPCBoxId() == currentBoxId then
		log("Withdrawing a Pokémon...")
		for i = 1, currentBoxSize do
			if getPokemonUniqueIdFromPC(currentBoxId, i) == sixthPoke or (not sixthPoke and not checkCatchList[getPokemonNameFromPC(currentBoxId, i)]) then
				withdrawPokemonFromPC(currentBoxId, i)
				currentBoxId = 1
				withdrawing = false
				return
			end
		end
		currentBoxId = currentBoxId + 1
		return openPCBox(currentBoxId)
	else
		return openPCBox(currentBoxId)
	end
	
end


function onBattleAction()

	if pokemonHealth == 0 then pokemonHealth = getPokemonHealth(getActivePokemonNumber()) end
	if opponentHealth == 0 then opponentHealth = getOpponentHealth() end
	
	if getPokemonHealth(getActivePokemonNumber()) < pokemonHealth then
		log(getPokemonName(getActivePokemonNumber()) .. " took " .. pokemonHealth - getPokemonHealth(getActivePokemonNumber()) .. " damage!")
		pokemonHealth = getPokemonHealth(getActivePokemonNumber())
	end
	
	if getOpponentHealth() < opponentHealth then
		log("The wild " .. getOpponentName() .. " took " .. opponentHealth - getOpponentHealth() .. " damage!")
		opponentHealth = getOpponentHealth()
	end
	
	if isWildBattle() and (isOpponentShiny() or getOpponentForm() != 0 or not sturdy or checkCatchList[getOpponentName()] or checkExceptions[getOpponentName()] or (catchNotCaught and not isAlreadyCaught())) then
		
		if rolePlayUser > 0 and not checkExceptions[getOpponentName()] and not isOpponentShiny() and not farming and getOpponentForm() == 0 then -- Gonna use Role Play, unless opponent is one of our exceptionCatches or is shiny
			if getActivePokemonNumber() != rolePlayUser and not rolePlayed then
				pokemonHealth = 0
				return sendPokemon(rolePlayUser) or run() or sendUsablePokemon()
			elseif not rolePlayed then
				rolePlayed = true
				return useMove("Role Play") or run() or sendUsablePokemon()
			elseif abilityFound then
			
				if weakMoveUser > 0 then
					if getOpponentHealthPercent() > 30 then
						if getActivePokemonNumber() != weakMoveUser then
							pokemonHealth = 0
							return sendPokemon(weakMoveUser) or run() or sendUsablePokemon()
						else
							return useMove(weakMove) or run() or sendUsablePokemon()
						end
					elseif statusMoveUser > 0 then
						if getActivePokemonNumber() != statusMoveUser then
							pokemonHealth = 0
							return sendPokemon(statusMoveUser) or run() or sendUsablePokemon()
						elseif getOpponentStatus() != "SLEEP" and getOpponentStatus() != "PARALIZE" then
							return useMove(statusMove) or run() or sendUsablePokemon()
						else
							return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
						end
					else
						return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
					end
					
				elseif statusMoveUser > 0 then
					if getActivePokemonNumber() != statusMoveUser then
						pokemonHealth = 0
						return sendPokemon(statusMoveUser) or run() or sendUsablePokemon()
					elseif getOpponentStatus() != "SLEEP" and getOpponentStatus() != "PARALIZE" then
						return useMove(statusMove) or run() or sendUsablePokemon()
					else
						return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
					end
					
				else
					return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
				end
				
			else																		-- Opponent had the wrong ability
			
				if farm and (not evToTrain or evToTrain == "" or isOpponentEffortValue(evToTrain)) and hasGoodMoves(getActivePokemonNumber()) then	-- We're gonna kill it
					if farmer > 0 and getActivePokemonNumber() != farmer then
						pokemonHealth = 0
						return sendPokemon(farmer) or sendUsablePokemon() or run()		-- Sending farmer
					else
						return attack() or run() or sendUsablePokemon()					-- Murdering the cute little Pokémon
					end
				else																	-- Gonna let it live
					return run() or attack() or sendUsablePokemon()
				end
				
			end
			
		elseif not farming or checkExceptions[getOpponentName()] or isOpponentShiny() or getOpponentForm() != 0 then -- Not gonna use Role Play, or opponent is one of our exceptionCatches, or is shiny
		
			if weakMoveUser > 0 then
				if getOpponentHealthPercent() > 30 then
					if getActivePokemonNumber() != weakMoveUser then
						pokemonHealth = 0
						return sendPokemon(weakMoveUser) or run() or sendUsablePokemon()
					else
						return useMove(weakMove) or run() or sendUsablePokemon()
					end
				elseif statusMoveUser > 0 then
					if getActivePokemonNumber() != statusMoveUser then
						pokemonHealth = 0
						return sendPokemon(statusMoveUser) or run() or sendUsablePokemon()
					elseif getOpponentStatus() != "SLEEP" and getOpponentStatus() != "PARALIZE" then
						return useMove(statusMove) or run() or sendUsablePokemon()
					else
						return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
					end
				else
					return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
				end
				
			elseif statusMoveUser > 0 then
				if getActivePokemonNumber() != statusMoveUser then
					pokemonHealth = 0
					return sendPokemon(statusMoveUser) or run() or sendUsablePokemon()
				elseif getOpponentStatus() != "SLEEP" and getOpponentStatus() != "PARALIZE" then
					return useMove(statusMove) or run() or sendUsablePokemon()
				else
					return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
				end
				
			else
				return useItem(ballType) or useItem("Pokeball") or useItem("Great Ball") or useItem("Ultra Ball") or run() or sendUsablePokemon()
			end
			
		else 																	-- We're farming for money, and opponent is not in our exceptionCatches and is not shiny
			if (not farmingEV or farmingEV == "" or isOpponentEffortValue(farmingEV)) and hasGoodMoves(1) then
				return attack() or sendUsablePokemon() or run()
			else
				return run() or sendUsablePokemon() or attack()
			end
		end
		
	else																		-- Opponent is not part of catchList or exceptionCatches
		if farming then															-- Farming for money
			if (not farmingEV or farmingEV == "" or isOpponentEffortValue(farmingEV)) and hasGoodMoves(1) then
				return attack() or sendUsablePokemon() or run()
			else
				return run() or sendUsablePokemon() or attack()
			end
		else
			if farm and (not evToTrain or evToTrain == "" or isOpponentEffortValue(evToTrain)) and hasGoodMoves(farmer) then -- We're gonna kill it
				if farmer > 0 and getActivePokemonNumber() != farmer then
					pokemonHealth = 0
					return sendPokemon(farmer) or sendUsablePokemon() or run()						-- Sending farmer
				else
					return attack() or run() or sendUsablePokemon()									-- Murdering the cute little Pokémon
				end
			else																					-- Gonna let it live
				return run() or attack() or sendUsablePokemon()
			end
		end
	end
end


function array(list)
    local array = {}
	
    for key, value in ipairs(list) do
		array[value] = true
	end
	
    return array
end


function keepPokemon(boxIndex, pokeIndex)

	if ((not tossWrongNature or checkNatures[getPokemonNatureFromPC(boxIndex, pokeIndex)])
	and (not tossWrongAbility or checkAbilities[getPokemonAbilityFromPC(boxIndex, pokeIndex)] or not getPokemonAbilityFromPC(boxIndex, pokeIndex))
	and (not tossWrongHP or checkHPTypes[calculateHPType(boxIndex, pokeIndex)])
	and getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "Attack") >= minIVs[1]
	and getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "Defence") >= minIVs[2]
	and getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "SpAttack") >= minIVs[3]
	and getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "SpDefence") >= minIVs[4]
	and getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "Speed") >= minIVs[5]
	and getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "HP") >= minIVs[6])
	or isPokemonFromPCShiny(boxIndex, pokeIndex) then
		return true
	else
		return false
	end
	
end


function logIVs(boxIndex, pokeIndex)
	return ("Attack: " .. getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "Attack") .. " - "
		.. "Defence: " .. getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "Defence") .. " - "
		.. "SpAttack: " .. getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "SpAttack") .. " - "
		.. "SpDefence: " .. getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "SpDefence") .. " - "
		.. "Speed: " .. getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "Speed") .. " - "
		.. "HP: " .. getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "HP"))
end


function calculateHPType(boxIndex, pokeIndex)

	hp = getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "HP") % 2
	atk = (getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "ATK") % 2) * 2
	def = (getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "DEF") % 2) * 4
	spd = (getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "SPD") % 2) * 8
	spatk = (getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "SPATK") % 2) * 16
	spdef = (getPokemonIndividualValueFromPC(boxIndex, pokeIndex, "SPDEF") % 2) * 32
	
	return validHPTypes[math.floor(((hp + atk + def + spd + spatk + spdef) * 15) / 63) + 1]
	
end


function onBattleMessage(message)
	if stringContains(message, "[FF9900]Magnemite[-] held on thanks to Sturdy!")  then
        sturdy = true
	elseif stringContains(message, "A Wild SHINY ") then
		shinyCount = shinyCount + 1
	elseif stringContains(message, "A Wild ") then
		wildCount = wildCount + 1
	elseif stringContains(message, "Success! You caught ") then
		if needReleased != "Never" and checkCatchList[getOpponentName()] then needReleased = true end
		caughtCount = caughtCount + 1
		for key, value in pairs(catchCounter) do
			if stringContains(message, "[FF9900]" .. key .. "[-]") then
				catchCounter[key] = catchCounter[key] + 1
				log(key .. " caught: " .. value)
			end
		end
	elseif stringContains(message, "You have won the battle.") then
		killedCount = killedCount + 1
	elseif stringContains(message, "SLEEP failed to have any effect.") and statusMove == "Spore" then -- Using Spore on a grass-type Pokémon
		statusMoveUserDefault = statusMoveUser
		statusMoveUser = 0
	else
		for _, value in pairs(abilities) do
			if stringContains(message, "ability is now " .. value) then
				abilityFound = true
			end
		end
	end
	
end


function onDialogMessage(pokecenter)
    if stringContains(pokecenter, "heal your Pokemon?") then
        pokecenterVisits = pokecenterVisits + 1
    end
end


function formattedTable(list, condition)
	condition = condition or "and"
	local text = ""
	if #list == 1 then return list[1] end
	if #list == 2 then return table.concat(list, " " .. condition .. " ") end
	for key, value in ipairs(list) do
		if key == #list then
			text = text .. condition .. " " .. value
		else
			text = text .. value .. ", "
		end
	end
	return text    
end


function runningTime()
	local runTime = math.floor(os.difftime(os.time(), startTime))
	if runTime == 1 then
		log("Run Time: 1 second")
	elseif runTime < 60 then
		log("Run Time: " .. runTime .. " seconds")
	elseif math.floor(runTime / 60) == 1 then 
		log("Run Time: 1 minute")
	elseif runTime < 3600 then
		log("Run Time: " .. math.floor(runTime / 60) .. " minutes")
	elseif runTime == 3600 then 
		log("Run Time: 1 hour")
	else
		hour = math.floor(runTime / 3600)
		minute = math.floor(runTime / 60) - (hour * 60)
		if hour == 1 then
			if minute == 1 then
				log("Run Time: 1 hour and 1 minute")
			else
				log("Run Time: 1 hour and " .. minute .. " minutes")
			end
		else
			if minute == 1 then
				log("Run Time: " .. hour .. " hours and 1 minute")
			else
				log("Run Time: " .. hour .. " hours and " .. minute .. " minutes")
			end
		end
	end
	if getMoney() - startMoney > 0 then
		log("Money made: " .. getMoney() - startMoney)
		log("Money per hour: " .. math.floor((getMoney() - startMoney) / (runTime / 3600)))
	end
end


function onPause()
	
	for key, value in pairs(catchCounter) do
		if value > 0 then log(key .. " caught: " .. value) end
	end
	if caughtCount > 0 then log("Total Pokémon caught: " .. caughtCount) end
	if releasedCount > 0 then log("Pokémon released: " .. releasedCount) end
	if usableCount > 0 then log("Usable Pokémon: " .. usableCount) end
	if killedCount > 0 then log("Pokémon killed: " .. killedCount) end
	if wildCount > 0 then log("Total Pokémon encountered: " .. wildCount) end
	if pokecenterVisits > 0 then log("Pokecenter visits: " .. pokecenterVisits) end
	if shinyCount > 0 then log("Shinies found: " .. shinyCount) end
	runningTime()
	
end


function onStop()
	
	for key, value in pairs(catchCounter) do
		if value > 0 then log(key .. " caught: " .. value) end
	end
	if caughtCount > 0 then log("Total Pokémon caught: " .. caughtCount) end
	if releasedCount > 0 then log("Pokémon released: " .. releasedCount) end
	if usableCount > 0 then log("Usable Pokémon: " .. usableCount) end
	if killedCount > 0 then log("Pokémon killed: " .. killedCount) end
	if wildCount > 0 then log("Total Pokémon encountered: " .. wildCount) end
	if pokecenterVisits > 0 then log("Pokecenter visits: " .. pokecenterVisits) end
	if shinyCount > 0 then log("Shinies found: " .. shinyCount) end
	runningTime()
	
end


function findMove(moveName)
	
	-- Returns the first Pokémon in the team with the move moveName, and the index of the move
	
	for poke = 1, getTeamSize() do
		for move = 1, 4 do
			if getPokemonMoveName(poke, move) then
				if getPokemonMoveName(poke, move):upper() == moveName:upper() then
					return poke, move
				end
			end
		end
	end
	return false, false
	
end


function hasMoveInPC(boxIndex, pokeIndex, moveName)
	
	-- Returns true if Pokémon has the move moveName
	
	for i = 1, 4 do
		if getPokemonMoveNameFromPC(boxIndex, pokeIndex, i) then
			if getPokemonMoveNameFromPC(boxIndex, pokeIndex, i):upper() == moveName:upper() then
				return true
			end
		end
	end
	return false
	
end


function toTitleCase(str)
	if type(str) == "string" then
		if str == "" then return str end
		return str:gsub("(%a)([%w_']*)", function(a,b) return a:upper() .. b:lower() end)
	else
		if not str[1] then return str end
		local list = {}
		for key, value in pairs(str) do
			list[key] = value:gsub("(%a)([%w_']*)", function(a,b) return a:upper() .. b:lower() end)
		end
		return list
	end
end


function invalidTable(list, validList)

	-- Returns the first value in list that is not present in validList
	
	for _, value in pairs(list) do
		if not inTable(validList, value) then
			return value
		end
	end
	return false
	
end


function inTable(T, val)
   for k, v in pairs (T) do
       if v == val then
           return true
       end
   end
   return false
end


function tableConcat(t1, t2)
	local tmp = {}
	for i = 1, #t1 do
		tmp[#tmp + 1] = t1[i]
	end
    for i = 1, #t2 do
        tmp[#tmp + 1] = t2[i]
    end
    return tmp
end


function findUniqueIdInParty(ID)

	for i = 1, getTeamSize() do
		if getPokemonUniqueId(i) == ID then
			return i
		end
	end
	return false
	
end


function findPokemonWithSync(nature)

	for i = 1, getTeamSize() do
		if getPokemonAbility(i) == "Synchronize" and getPokemonNature(i) == nature and (not rolePlayAsWell or hasMove(i, "Role Play")) then
			return i
		end
	end
	return false
	
end


lastMessage = ""
function logOnce(msg)
    if lastMessage != msg then
        log(msg)
        lastMessage = msg
    end
end


lastMessage2 = ""
function logOnce2(msg)
    if lastMessage2 != msg then
        log(msg)
        lastMessage2 = msg
    end
end


function vowelCheck(str)
	
	-- Returns "n " if the first letter of str is a vowel
	
	vowels = {"A", "E", "I", "O", "U"}
	
	if inTable(vowels, str:sub(1, 1):upper()) then
		return "n " .. str -- "a .. 'n 'awesome string"
	else
		return " " .. str -- "a ..  ' 'not so awesome string"
	end
	
end


function checkStatus()

	if not healWhenStatused then return true end
	
	-- Returns false if any Pokémon in the party has a status
	
	for i = 1, getTeamSize() do
		if (getPokemonStatus(i) == "POISON" and getPokemonAbility(i) != "Poison Heal") or getPokemonStatus(i) == "PARALIZE" then
			return false
		end
	end
	return true
end


function hasGoodMoves(index)
	
	-- Making sure we're able to kill Pokémon
	
	for i = 1, 4 do
		if getPokemonMoveName(index, i) then
			if getPokemonMoveName(index, i):upper() != "FALSE SWIPE"
			and getRemainingPowerPoints(index, getPokemonMoveName(index, i)) > 0
			and not getPokemonMoveStatus(index, i) then
				return true
			end
		end
	end
	return false
end




















