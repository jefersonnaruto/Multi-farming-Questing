------------------------ Config --------------------------

-- Weak move name - False Swipe, Dragon Rage, Sonicboom, etc.   ---   Use "" if you don't wish to damage opponents before catching them
weakMove = "False Swipe"

-- Name of status move - Spore, Hypnosis, Thunder Wave, etc.   ---   Use "" if you don't wish to afflict opponents with a status before catching them
statusMove = ""

-- Use Role Play when catching Pokémon? - Will check the Pokémon in catchList for the abilities listed in the abilities table
useRolePlay = false

-- Do ALL of our Sync Pokémon (morningSync, daySync, and nightSync) have Role Play?   ---   ignore this if useRolePlay = false
rolePlayAsWell = false

-- Sync nature to use during morning
morningSync = "Timid"

-- Sync nature to use during daytime
daySync = "Timid"

-- Sync nature to use during nighttime
nightSync = "Timid"

-- Minimum level for our Sync Pokémon - used when we retrieve it from the PC
minSyncLevel = 2

-- List of Pokémon to catch, and release the bad ones
catchList = {"Magnemite"}

-- List of Pokémon to catch that will not get released under any circumstances
-- Also will not use Role Play on these Pokémon
exceptionCatches = { "Bulbasaur", "Charmander", "Squirtle", "Larvitar" }

-- Release Pokémon with the wrong nature?
tossWrongNature = false

-- The natures you want to keep - ignore this if tossWrongNature = false
natures = { "Timid", "Modest" }

-- Minimum IV's   ---   Order is Attack, Defence, SpAttack, SpDefence, Speed, HP   ---   use 0 to not check against a particular IV
minIVs = {0, 0, 0, 0, 0, 0}

-- Release Pokémon with the wrong ability?
tossWrongAbility = true

-- The abilities to look for - Used for Role Play even if tossWrongAbility = false   ---   if tossWrongAbility = true, Pokémon in catchList without one of these abilities will get released
abilities = { "Magnet Pull", "Synchronize", "Vital Spirit" }

-- Release Pokémon with the wrong Hidden Power type?
tossWrongHP = true

-- Hidden Power types to look for - ignore this if tossWrongHP = false   ---   Remember that any Pokémon in catchList without one of these HP types will get released, so be careful
hpTypes = { "Fire" }

-- Attack Pokémon that we're not catching?
farm = false

-- If farm = true, this is the index of the Pokémon will get sent out to fight, instead of fighting with your Sync Pokémon
-- Set to 0 to just attack with whatever Pokémon happens to be out
farmer = 1

-- If farm = true, we will only attack Pokémon that give this EV - "HP", "ATK", "DEF", "SPATK", "SPDEF", or "SPD"   ---   use "", nil, or false to attack everything
evToTrain = ""

-- Use items to heal our Pokémon instead of going to the Pokécenter to heal? - Useful for the Safari Zone or the Moon
useItems = false

-- Names of items to use   ---   {Reviving, Healing, Restoring PP, Paralysis, Poison}   ---   Use "" for a particular item to never use that type
items = {"Revive", "Hyper Potion", "Leppa Berry", "Lum Berry", "Lum Berry"}

-- Head to the Pokécenter when one of our Pokémon is Paralyzed or Poisoned?
healWhenStatused = false

-- Catch Pokémon we've never caught before?
catchNotCaught = false

-- Auto-evolve Pokémon?
autoEvolve = false

-- Enable private messaging?
enableMessages = false

-- Hunting location for morning time - Hour >= 4 and Hour < 10
morningMap = "Power Plant"

-- The type of hunting area for morning time - use "Grass", "Water", {x1, y1, x2, y2} - use {x, y} to set the cell to go to for fishing
-- If you're using a rectangle, you can set more rectangles to hunt in just by adding 4 more parameters
-- for example: morningArea = {ax1, ay1, ax2, ay2,
--							   bx1, by1, bx2, by2,
--							   cx1, cy1, cx2, cy2} etcetera, as many as you like
morningArea = {11, 27, 19, 27, 
            13, 32, 22, 32,
            12, 38, 25, 38, 
            14, 31, 21, 31, }


-- Daytime location - Hour >= 10 and Hour < 20
dayMap = "Power Plant"

-- Daytime hunting area - "Grass", "Water", {x, y}, or {x1, y1, x2, y2}, multiple rectangles are fine
dayArea = {11, 27, 19, 27, 
            13, 32, 22, 32,
            12, 38, 25, 38, 
            14, 31, 21, 31, }

-- Nighttime location - Hour >= 20 or Hour < 4
nightMap = "Power Plant"

-- Nighttime hunting area - "Grass", "Water", {x, y}, or {x1, y1, x2, y2}, multiple rectangles are fine
nightArea = {11, 27, 19, 27, 
            13, 32, 22, 32,
            12, 38, 25, 38, 
            14, 31, 21, 31, }

-- If you're using multiple rectangles, this is the amount of time in minutes that we'll hunt in one of them before picking the next one at random
minutesToMove = 7

-- Name of the rod you're going to use if you're fishing
rod = "Super Rod"

-- The type of Pokeball to use - "Pokeball", "Great Ball", or "Ultra Ball"
ballType = "Pokeball"

-- Minimum number of balls to keep - if we have less than this number, we go buy some   ---   use 0 to forget about this
ballMin = 10

-- Number of balls to buy when we go to the the mart
buyAmount = 50

-- Minimum amount of money to start farming at - useful if you're using the Safari Zone a lot - set to 0 to never farm for money
minMoney = 100


-- If minMoney = 0, ignore everything below this point


-- Minimum amount of money to stop farming at
moneyStop = 50000

-- Index of Pokémon to farm with when our money gets too low - set to 0 to just fight with anything
farmerId = 2

-- If we have less money than minMoney, we will only attack Pokémon that give this EV - "HP", "ATK", "DEF", "SPATK", "SPDEF", or "SPD"   ---   use "", nil, or false to attack everything
farmingEV = ""

-- Location to farm in when our money gets too low - Not an optional setting - if you won't ever farm, just leave this value alone
farmMap = ""

-- Hunting area for farming - "Grass", "Water", {x, y}, or {x1, y1, x2, y2}, multiple rectangles are fine  - Not an optional setting - if you won't ever farm, just leave this value alone
farmArea = "Grass"

-------------------------------------------------------
