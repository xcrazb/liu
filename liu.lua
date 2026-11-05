RS = RS or game:GetService("ReplicatedStorage")
Players = Players or game:GetService("Players")
CollectionService = CollectionService or game:GetService("CollectionService")
HttpService = HttpService or game:GetService("HttpService")
Lighting = Lighting or game:GetService("Lighting")
RunService = RunService or game:GetService("RunService")
player = player or Players.LocalPlayer

local playerDataMod = nil
pcall(function()
    playerDataMod = require(RS:WaitForChild("TS", 30):WaitForChild("state", 10):WaitForChild("player-data", 10))
end)

local function getData()
    if not playerDataMod then return nil end
    local ok, d = pcall(function() return playerDataMod.getPlayerDataById(tostring(player.UserId)) end)
    return ok and d or nil
end

local TS = RS:WaitForChild("TS", 30)
if not TS then return end
local remotes = require(TS:WaitForChild("remotes")).default
local pdm = require(TS:WaitForChild("state"):WaitForChild("player-data"))
local getPlayerData = pdm.getPlayerData
local srm = require(TS:WaitForChild("state"):WaitForChild("shop-restock"))
local shopRestock, ShopType, personalRestockItems = srm.shopRestock, srm.ShopType, srm.personalRestockItems
local tm = require(TS:WaitForChild("state"):WaitForChild("travelling-merchant"))
local travellingMerchants = tm.travellingMerchants
local craftingUtils = nil
pcall(function() craftingUtils = require(TS:WaitForChild("utils"):WaitForChild("crafting.utils")) end)
local petAgeUtils = nil
pcall(function() petAgeUtils = require(TS:WaitForChild("utils"):WaitForChild("pet-age.utils")) end)

local rc = RS:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("remo"):WaitForChild("src"):WaitForChild("container")
local placeRemote       = rc:WaitForChild("ponds.placeBuilding")
local selectCraftRemote = rc:WaitForChild("crafting.selectCraftingItem")
local submitRemote      = rc:WaitForChild("crafting.submitItems")
local startCraftRemote  = rc:WaitForChild("crafting.startCraft")
local collectRemote     = rc:WaitForChild("crafting.collectCraft")
local goldenBuyRemote   = rc:WaitForChild("merchant.purchaseItem")
local purchaseGear      = remotes.shop.purchaseGear
local purchaseBait      = remotes.shop.purchaseBait
local purchaseEgg       = remotes.shop.purchaseEgg

local hwCollectFish = rc:FindFirstChild("bait.collectFish")
local hwFeedAll     = rc:FindFirstChild("halloween.feedTreeAll")
local hwClaimPickup = rc:FindFirstChild("pickup.claimPickup")

local HALLOWEEN_BITMASK = 549755813888
pcall(function()
    local bits = require(TS:WaitForChild("lists"):WaitForChild("game"):WaitForChild("mutation-bits")).MUTATION_BITS
    if bits and bits.Halloween then HALLOWEEN_BITMASK = 2 ^ bits.Halloween end
end)

local LOCKED_MUTATIONS = { diamond = true }
local function isLockedMutation(mutName)
    if not mutName or mutName == "" then return false end
    local n = string.lower(string.gsub(tostring(mutName), "^%s*(.-)%s*$", "%1"))
    return LOCKED_MUTATIONS[n] == true
end
local function normalizeMutation(name)
    if not name or name == "" then return "none" end
    return string.lower(string.gsub(tostring(name), "^%s*(.-)%s*$", "%1"))
end

local BCONFIG = {
    TargetAge = 50, HelperMinAge = 100, JumperInterval = 3, WaitAfterPlace = 0.5,
    JumperCooldown = 1.5, MutationCooldown = 2, MainLoadout = 0, ResetLoadout = 1,
    WaitingLoadout = 1, CollectLoadout = 4, LoadoutSwitchDelay = 1.5, MutationCollectSyncDelay = 1.5,
    MaxCyclesBeforeStop = 999, JumperBeforeSwitch = 3, JumperSwitchDelay = 1.5,
    SpeedupPlaceCount = 10, AntiAfkInterval = 60,
    Interval = 5, BuyAll = true, BaitWL = {}, BaitBL = {}, BuyDelay = 0.15, StockTTL = 1.5,
    GoldenInterval = 3, GoldenIdleInterval = 10, GoldenBuyDelay = 0.25,
    GoldenBulkLoopDelay = 0.4, GoldenMaxPass = 8,
    FoodOn = false, FoodInt = 30,
    FoodList = { "SupremeFoodTray", "AdvancedFoodTray", "BasicFoodTray" },
    FoodCat = "booster",
    FoodPos = Vector3.new(10.86, -0.012, -11),
    CraftOn = false, CraftItem = "TimeJumper", CraftCat = "gear",
    CraftMats = {{n = "TeleportWand", a = 10}, {n = "MagnifyingGlass", a = 25}, {n = "SupremeAutoFeeder", a = 1}},
}
local ALL_MUTATIONS = { "Diamond", "Silver", "Radiant", "Huge", "Lightning", "Guardian", "Gold", "Tiny", "Aquatic", "Tamed" }
local GEAR_LIST = {"NetMover","FoodScoop","MagnifyingGlass","TeleportWand","StarLock","TradingTicket","BasicAutoFeeder","AdvancedAutoFeeder","SupremeAutoFeeder","ExtremeAutoFeeder","GodlyAutoFeeder","BasicFoodTray","AdvancedFoodTray","SupremeFoodTray","XpCookie","PetToy","PetWhistle","GoldenCookie","EggHatcher","EggIncubator","MutationBeacon","StormHorn"}
local EGG_WL = {"Tropical", "Exotic"}

local COOKIE_DIAMOND = "DiamondCookie"
local COOKIE_XP      = "XpCookie"
local GEAR_PET_TOY   = "PetToy"
local COOKIE_REFRESH_TIME = 600
local PET_TOY_REFRESH_TIME = 300

local SPECIES_FILTER = {
    leveling = { "pegazeus", "darkphoenix" },
    speedup  = { "darkphoenix", "eviltrex" },
    collect  = { "darkphoenix", "werewolf" },
}

local B = {
    isRunning = false, currentWave = {}, wavePhase = "idle",
    placedPets = {}, pickedUpPets = {}, selectedMutations = {},
    mutationInProgress = {}, processedMutation = {},
    lastMutationAction = 0, currentLoadout = nil, lastLoadoutSwitch = 0,
    totalBoosted = 0, totalMutated = 0, cycleCount = 0,
    jumperCounter = 0, lastJumperFire = 0,
    boostJumperCount = 0, boostLoadoutSwitching = false,
    selectedPets = {}, petList = {}, petById = {},
    levelingPets = {}, speedupPets = {}, targetPets = {}, collectPets = {},
    placedLeveling = {}, placedSpeedup = {},
    maxPlacePerWave = 0, lastJumperEmptyNotify = 0,
    useAutoPetToy = false, useAutoCookie = false,
    collectSetupDone = false,
}

local S = {
    gOn = false, gTot = 0, bOn = false, bTot = 0, eOn = false, eTot = 0,
    gdOn = false, gdTot = 0, gdActive = false,
    nextGear = 0, nextBait = 0, nextEgg = 0,
    nextGolden = 0, _stockCache = {},
    pRun = false, pCnt = 0, pCd = 0, nextPlace = 0,
    cRun = false, cAtt = 0, cOk = 0, cFail = 0, cCd = 0, cPhase = "idle",
    hwCollect = false, hwFeedPickup = false,
    hwCollectThread = nil, hwFeedPickupThread = nil,
    minimized = false,
}

local petAgeMod = petAgeUtils

local invStateGear = nil
pcall(function()
    invStateGear = require(player.PlayerScripts.TS.ui.features.toolbar["inventory.state"])
end)

local function getRemote(name)
    local ok, remote = pcall(function()
        return RS:WaitForChild("rbxts_include", 10):WaitForChild("node_modules", 10)
            :WaitForChild("@rbxts", 10):WaitForChild("remo", 10)
            :WaitForChild("src", 10):WaitForChild("container", 10):WaitForChild(name, 10)
    end)
    return ok and remote or nil
end

local useTimeWatch          = getRemote("gear.useTimeWatch")
local equipTool             = getRemote("tools.equipTool")
local placePetFromInventory = getRemote("pets.placePetFromInventory")
local requestPosition       = getRemote("pets.requestPosition")
local pickUpPet             = getRemote("pets.pickUpPet")
local switchPetLoadout      = getRemote("pets.switchPetLoadout")
local startMutation         = getRemote("pets.startMutation")
local collectMutation       = getRemote("pets.collectMutation")
local choosePetMutation     = getRemote("pets.choosePetMutation") -- TAMBAHKAN INI
local GRADUATED_PETS        = {}                                  -- TAMBAHKAN INI
local usePetGearOnPet       = getRemote("pets.usePetGearOnPet")

local VIM = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local AntiAfk = { running = false, count = 0, lastFire = 0 }

local function fireAntiAfk()
    pcall(function() VIM:SendKeyEvent(true, Enum.KeyCode.Z, false, game) end)
    task.wait(0.05)
    pcall(function() VIM:SendKeyEvent(false, Enum.KeyCode.Z, false, game) end)
    pcall(function()
        VirtualUser:CaptureController()
        VirtualUser:ClickButton2(Vector2.new(0, 0))
    end)
    AntiAfk.lastFire = os.clock()
    AntiAfk.count = AntiAfk.count + 1
end

local function startAntiAfk()
    if AntiAfk.running then return end
    AntiAfk.running = true
    task.spawn(function()
        task.wait(1)
        fireAntiAfk()
        while AntiAfk.running do
            task.wait(BCONFIG.AntiAfkInterval)
            fireAntiAfk()
        end
    end)
end

local function stopAntiAfk()
    AntiAfk.running = false
end

task.spawn(startAntiAfk)

local WEBHOOK = {
    url = "", enabled = true, notifyJumperEmpty = true,
    username = "Farm A Fish - Mutation Log", lastJumperEmptyNotify = 0,
}

local function sendWebhook(payload)
    if not WEBHOOK.enabled or WEBHOOK.url == "" then return end
    task.spawn(function()
        pcall(function()
            local body = HttpService:JSONEncode(payload)
            local req = (syn and syn.request) or (http and http.request) or http_request or request
            if req then
                req({ Url = WEBHOOK.url, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = body })
            end
        end)
    end)
end

local function getPlayerDisplayName()
    return player.DisplayName or player.Name or "Unknown"
end

local function getFormattedPetWeight(pd)
    if not petAgeUtils or not petAgeUtils.calculatePetWeight then return "0.0kg" end
    local ok, weight = pcall(petAgeUtils.calculatePetWeight, pd)
    if not ok or not weight then return "0.0kg" end
    if petAgeUtils.formatPetWeight then
        local ok2, formatted = pcall(petAgeUtils.formatPetWeight, weight)
        if ok2 and formatted then return formatted end
    end
    if weight >= 1000 then return string.format("%.2ft", weight / 1000)
    else return string.format("%.2fkg", weight) end
end

local function getJumperCount()
    local data = getData()
    if not data or not data.inventory or not data.inventory.gears then return 0 end
    local tj = data.inventory.gears.TimeJumper
    return tj and (tj.amount or 0) or 0
end

local function getGearAmount(gearName)
    local data = getData()
    if not data or not data.inventory or not data.inventory.gears then return 0 end
    local g = data.inventory.gears[gearName]
    return g and (g.amount or 0) or 0
end

local function sendMutationWebhook(petName, petWeightStr, mutationName, jumperLeft)
    local isTarget = false
    local nMut = normalizeMutation(mutationName)
    for target in pairs(B.selectedMutations) do
        if normalizeMutation(target) == nMut then isTarget = true break end
    end
    if not isTarget then return end

    local embed = {
        title = "🧬 Mutation Result (Target Tercapai!)",
        color = 0x9B59B6,
        fields = {
            { name = "👤 Player", value = tostring(getPlayerDisplayName()), inline = true },
            { name = "🐾 Pet", value = tostring(petName), inline = true },
            { name = "⚖️ Berat Pet", value = tostring(petWeightStr), inline = true },
            { name = "✨ Mutasi Didapat", value = tostring(mutationName or "None"), inline = true },
            { name = "⏱️ TimeJumper Sisa", value = tostring(jumperLeft), inline = true },
        },
        footer = { text = "Farm A fish | by bang iqi" },
        timestamp = DateTime.now():ToIsoDate(),
    }
    sendWebhook({ username = WEBHOOK.username, embeds = { embed } })
end

local function sendJumperEmptyWebhook(jumperLeft)
    local embed = {
        title = "⚠️ TIMEJUMPER HABIS",
        description = "TimeJumper di inventory sudah habis. Auto mutasi akan berhenti sampai kamu craft / isi ulang.",
        color = 0xE74C3C,
        fields = {
            { name = "👤 Player", value = tostring(getPlayerDisplayName()), inline = true },
            { name = "⏱️ Sisa TimeJumper", value = tostring(jumperLeft or 0), inline = true },
        },
        footer = { text = "Farm A fish | by bang iqi" },
        timestamp = DateTime.now():ToIsoDate(),
    }
    sendWebhook({ username = WEBHOOK.username, embeds = { embed } })
end

local function getPetAge(pd)
    if not petAgeMod or not pd then return 0 end
    local ok, age = pcall(petAgeMod.getPetAgeFromData, pd)
    return ok and (age or 0) or 0
end

local function getPetMutation(pd)
    if not pd then return "None" end
    local c = { pd.mutation, pd.mutations, pd.mutationType, pd.mutationName, pd.attributes and pd.attributes.mutation }
    for _, m in ipairs(c) do
        if m and m ~= "" and m ~= "None" then
            if type(m) == "table" then
                for _, v in pairs(m) do
                    if v and v ~= "" and v ~= "None" then return tostring(v) end
                end
            else return tostring(m) end
        end
    end
    return "None"
end

local function stockKey(s, t) return s .. "|" .. t end
local function invalidateStock(s, t) S._stockCache[stockKey(s, t)] = nil end

local function getStock(shopType, itemType)
    local k = stockKey(shopType, itemType)
    local now = os.clock()
    local c = S._stockCache[k]
    if c and (now - c.t) < BCONFIG.StockTTL then return c.v end
    local val = 0
    local ok, rs, pi, data = pcall(function()
        return shopRestock(), personalRestockItems(), getPlayerData(player)
    end)
    if ok and rs and data then
        local nowT = os.time()
        local pr = data.personalRestocks and data.personalRestocks[shopType]
        local active = pr and pr.endTime and nowT < pr.endTime
        local uid = tostring(player.UserId)
        local avail
        if active then
            avail = pi[uid] and pi[uid][shopType] and pi[uid][shopType][itemType] or 0
        else
            avail = rs.availableItems and rs.availableItems[shopType] and rs.availableItems[shopType][itemType] or 0
        end
        local bought = 0
        local pur = data.shopPurchases and data.shopPurchases[shopType]
        if pur and pur.purchases then
            if active and pur.currentTimeSlot == pr.timeSlot then
                bought = pur.purchases[itemType] or 0
            elseif not active and pur.currentTimeSlot == rs.currentTimeSlot then
                bought = pur.purchases[itemType] or 0
            end
        end
        val = math.max(0, avail - bought)
    end
    S._stockCache[k] = {v = val, t = now}
    return val
end

local function getAvail(shopType, wl, bl)
    local list = {}
    local rs = shopRestock()
    if not rs then return list end
    local shop = rs.availableItems and rs.availableItems[shopType]
    if not shop then return list end
    local wlSet, blSet
    if wl and #wl > 0 then wlSet = {} for _, v in ipairs(wl) do wlSet[v] = true end end
    if bl and #bl > 0 then blSet = {} for _, v in ipairs(bl) do blSet[v] = true end end
    for t, s in pairs(shop) do
        local inc = true
        if wlSet and not wlSet[t] then inc = false end
        if inc and blSet and blSet[t] then inc = false end
        if inc then list[#list + 1] = {type = t, stock = s} end
    end
    return list
end

local function buyGearSafe(t) local ok = pcall(purchaseGear, t) if ok then invalidateStock(ShopType.Gear, t) end return ok end
local function buyBaitSafe(t) local ok = pcall(purchaseBait, t) if ok then invalidateStock(ShopType.Bait, t) end return ok end
local function buyEggSafe(t) local ok = pcall(purchaseEgg, t) if ok then invalidateStock(ShopType.Eggs, t) end return ok end

local function bulkGear()
    for _, t in ipairs(GEAR_LIST) do
        if not S.gOn then return end
        local rem = getStock(ShopType.Gear, t)
        if rem > 0 then
            local max = BCONFIG.BuyAll and (rem + 2) or 1
            for a = 1, max do
                if not S.gOn then return end
                if not buyGearSafe(t) then break end
                S.gTot += 1
                if a < max then task.wait(BCONFIG.BuyDelay) end
            end
        end
    end
end

local function bulkBait()
    local list = getAvail(ShopType.Bait, BCONFIG.BaitWL, BCONFIG.BaitBL)
    if #list == 0 then return end
    for _, it in ipairs(list) do
        if not S.bOn then return end
        local rem = getStock(ShopType.Bait, it.type)
        if rem > 0 then
            local max = BCONFIG.BuyAll and (rem + 2) or 1
            for a = 1, max do
                if not S.bOn then return end
                if not buyBaitSafe(it.type) then break end
                S.bTot += 1
                if a < max then task.wait(BCONFIG.BuyDelay) end
            end
        end
    end
end

local function bulkEgg()
    local list = getAvail(ShopType.Eggs, EGG_WL, nil)
    if #list == 0 then return end
    for _, it in ipairs(list) do
        if not S.eOn then return end
        local rem = getStock(ShopType.Eggs, it.type)
        if rem > 0 then
            local max = BCONFIG.BuyAll and (rem + 2) or 1
            for a = 1, max do
                if not S.eOn then return end
                if not buyEggSafe(it.type) then break end
                S.eTot += 1
                if a < max then task.wait(BCONFIG.BuyDelay) end
            end
        end
    end
end

local function getGoldenData()
    local d = travellingMerchants()
    if not d then return nil end
    return d.golden
end

local function getGoldenStock()
    local md = getGoldenData()
    if not md or not md.isActive or not md.availableStock then return {}, false end
    local map = {}
    for k, v in pairs(md.availableStock) do map[k] = v end
    return map, true
end

local function goldenBuyOne(itemName)
    return pcall(function() goldenBuyRemote:FireServer("golden", itemName) end)
end

local function goldenBulkBuy()
    local total, pass = 0, 0
    while S.gdOn and pass < BCONFIG.GoldenMaxPass do
        pass += 1
        local map, active = getGoldenStock()
        if not active then break end
        local targets = {}
        for itemName, stock in pairs(map) do
            if stock > 0 then table.insert(targets, itemName) end
        end
        if #targets == 0 then break end
        for _, itemName in ipairs(targets) do
            if not S.gdOn then break end
            if goldenBuyOne(itemName) then
                total += 1
                S.gdTot += 1
            end
            task.wait(BCONFIG.GoldenBuyDelay)
        end
        task.wait(BCONFIG.GoldenBulkLoopDelay)
    end
    return total
end

local function doFood()
    S.pCnt += 1
    local chosen = nil
    for _, foodName in ipairs(BCONFIG.FoodList) do
        if getGearAmount(foodName) > 0 then
            chosen = foodName
            break
        end
    end
    if not chosen then
        chosen = BCONFIG.FoodList[#BCONFIG.FoodList]
    end
    pcall(function()
        placeRemote:InvokeServer(BCONFIG.FoodCat, chosen, BCONFIG.FoodPos)
    end)
end

local CRAFT_TIME_FALLBACK = {DiamondCookie = 300, YolkBreaker = 600, TimeJumper = 600, ShieldLock = 1500, NetRetractor = 1500}

local function getCraftTime(id, cat)
    if craftingUtils and craftingUtils.getCraftingTime then
        local ok, r = pcall(craftingUtils.getCraftingTime, id, cat)
        if ok and r then return r end
    end
    return CRAFT_TIME_FALLBACK[id] or 600
end

local function getCraftData()
    local data = getPlayerData(player)
    if not data or not data.crafting then return nil end
    local c = data.crafting[BCONFIG.CraftCat]
    if not c or not c.id then return nil end
    return c
end

local function getCraftRem()
    local c = getCraftData()
    if not c or not c.timeStarted then return nil end
    local now = os.time()
    local tt = getCraftTime(c.id, BCONFIG.CraftCat)
    local acc = c.accumulatedProgress or 0
    local lu = c.lastProgressUpdate or c.timeStarted
    local dr = c.depletionRate or 1
    return math.max(0, tt - (acc + (now - lu) * dr))
end

local function isCraftActive()
    local c = getCraftData()
    return c and c.timeStarted ~= nil
end

local function doCraftOnce()
    S.cAtt += 1
    S.cPhase = "submitting"
    local ok = pcall(function() selectCraftRemote:FireServer(BCONFIG.CraftItem, BCONFIG.CraftCat) end)
    task.wait(0.3)
    if ok then
        local mats, idx = {}, 1
        for _, m in ipairs(BCONFIG.CraftMats) do
            for _ = 1, m.a do mats[idx] = m.n idx += 1 end
        end
        ok = pcall(function() submitRemote:FireServer(mats, BCONFIG.CraftCat) end)
        task.wait(0.3)
    end
    if ok then
        ok = pcall(function() startCraftRemote:FireServer(BCONFIG.CraftCat) end)
        task.wait(0.3)
    end
    if not ok then S.cFail += 1 S.cPhase = "idle" return false end
    S.cPhase = "crafting"
    return true
end

local function collectCraft()
    S.cPhase = "collecting"
    local ok = pcall(function() collectRemote:FireServer(BCONFIG.CraftCat) end)
    if ok then S.cOk += 1 end
    S.cPhase = "idle"
    return ok
end

-- HALLOWEEN
local antiSpamCollect = {}
local antiSpamFeed = 0

local function isHalloween(mut)
    if not mut then return false end
    if typeof(mut) == "number" then
        return math.floor(mut / HALLOWEEN_BITMASK) % 2 == 1
    end
    if type(mut) == "table" then
        for _, v in pairs(mut) do
            if typeof(v) == "string" and v:lower() == "halloween" then return true end
        end
    end
    return false
end

local function halloweenCollectOnce()
    if not hwCollectFish then return 0 end
    local pd = getPlayerData(player)
    if not pd or not pd.ponds then return 0 end
    local currentPondId = pd.currentPond
    if not currentPondId then return 0 end
    local count = 0
    local pondData = pd.ponds[currentPondId]
    if type(pondData) == "table" and pondData.baits then
        for baitId, baitData in pairs(pondData.baits) do
            if type(baitData) == "table" and baitData.fishes then
                for fishId, fishData in pairs(baitData.fishes) do
                    if type(fishData) == "table" and isHalloween(fishData.mutations) then
                        pcall(function() hwCollectFish:FireServer(baitId, fishId) end)
                        count += 1
                        task.wait(0.05)
                    end
                end
            end
        end
    end
    return count
end

local function halloweenFeedAll()
    if not hwFeedAll then return false end
    local now = os.time()
    if (now - antiSpamFeed) >= 5 then
        antiSpamFeed = now
        return pcall(function() hwFeedAll:FireServer() end)
    end
    return false
end

local function halloweenPickupAll()
    if not hwClaimPickup then return 0 end
    local count = 0
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("BasePart") and obj.Name:sub(1, 7) == "Pickup_" then
            local uuid = obj.Name:sub(8)
            if #uuid > 0 then
                pcall(function() hwClaimPickup:FireServer(uuid) end)
                count += 1
                task.wait(0.05)
            end
        end
    end
    return count
end

local function startHWCollect()
    if S.hwCollectThread then pcall(function() task.cancel(S.hwCollectThread) end) end
    S.hwCollectThread = task.spawn(function()
        while S.hwCollect do
            pcall(halloweenCollectOnce)
            task.wait(1)
        end
    end)
end

local function stopHWCollect()
    S.hwCollect = false
    if S.hwCollectThread then
        pcall(function() task.cancel(S.hwCollectThread) end)
        S.hwCollectThread = nil
    end
end

local function startHWFeedPickup()
    if S.hwFeedPickupThread then pcall(function() task.cancel(S.hwFeedPickupThread) end) end
    S.hwFeedPickupThread = task.spawn(function()
        while S.hwFeedPickup do
            pcall(halloweenFeedAll)
            task.wait(1)
            pcall(halloweenPickupAll)
            task.wait(1)
        end
    end)
end

local function stopHWFeedPickup()
    S.hwFeedPickup = false
    if S.hwFeedPickupThread then
        pcall(function() task.cancel(S.hwFeedPickupThread) end)
        S.hwFeedPickupThread = nil
    end
end

local function tickScheduler()
    local now = os.clock()

    if S.gOn and now >= S.nextGear then S.nextGear = now + BCONFIG.Interval task.spawn(bulkGear) end
    if S.bOn and now >= S.nextBait then S.nextBait = now + BCONFIG.Interval task.spawn(bulkBait) end
    if S.eOn and now >= S.nextEgg then S.nextEgg = now + BCONFIG.Interval task.spawn(bulkEgg) end
    if S.gdOn and now >= S.nextGolden then
        local interval = S.gdActive and BCONFIG.GoldenInterval or BCONFIG.GoldenIdleInterval
        S.nextGolden = now + interval
        task.spawn(function()
            local _, active = getGoldenStock()
            S.gdActive = active
            if active then goldenBulkBuy() end
        end)
    end

    if BCONFIG.FoodOn and now >= S.nextPlace then
        S.nextPlace = now + BCONFIG.FoodInt
        task.spawn(doFood)
    end

    if BCONFIG.CraftOn then
        if isCraftActive() then
            local rem = getCraftRem()
            if rem then
                S.cCd = rem
                S.cPhase = "crafting"
                if rem <= 0 then task.spawn(collectCraft) end
            else
                S.cPhase = "idle"
                S.cCd = 0
            end
        else
            if not S._nextCraftTry or now >= S._nextCraftTry then
                S._nextCraftTry = now + 2
                task.spawn(doCraftOnce)
            end
        end
    else
        S.cCd = 0
    end
end

local function buildNameMap()
    local map = {}
    if not invStateGear then return map end
    local ok, stacked = pcall(function() return invStateGear.inventoryStackedData() end)
    if not ok or not stacked then return map end
    for _, item in pairs(stacked) do
        local tt = tostring(item.toolType):lower()
        if tt:find("pet") and item.items and item.items[1] then
            local pid = item.items[1].id
            if pid then map[pid] = item.displayName or item.itemName or tostring(pid) end
        end
    end
    return map
end

local function switchLoadout(idx)
    if B.currentLoadout == idx then return true end
    if not switchPetLoadout then return false end
    local now = os.clock()
    local elapsed = now - B.lastLoadoutSwitch
    if elapsed < BCONFIG.LoadoutSwitchDelay then task.wait(BCONFIG.LoadoutSwitchDelay - elapsed) end
    local ok = pcall(function() switchPetLoadout:InvokeServer(idx) end)
    if ok then
        B.currentLoadout = idx; B.lastLoadoutSwitch = os.clock()
        task.wait(BCONFIG.LoadoutSwitchDelay)
        return true
    end
    return false
end

local function ensureLoadout(idx)
    if B.currentLoadout == idx then return true end
    return switchLoadout(idx)
end

local function hasSelected()
    for _ in pairs(B.selectedMutations) do return true end
    return false
end

local function isDesired(m)
    if not hasSelected() then return false end
    local n = normalizeMutation(m)
    if n == "none" or n == "" then return false end
    for t in pairs(B.selectedMutations) do
        if normalizeMutation(t) == n then return true end
    end
    return false
end

local function getMachineState()
    local labels = CollectionService:GetTagged("petMutationLabel")
    if #labels == 0 then return "Unknown" end
    local text = labels[1].Text
    if text == "MUTATION" or text == "" then return "Idle"
    elseif text == "READY!" then return "Ready"
    else return "InProgress" end
end

local function gearPetLabel(p, idx)
    local mut = (p.mutation and p.mutation ~= "" and p.mutation ~= "None") and p.mutation or "No Mutation"
    local ageStr = string.format("%.1f", p.age or 0)
    local suffix = idx and string.format("  #%d", idx) or ""
    return string.format("%s | %s | Age %s%s", p.displayName, mut, ageStr, suffix)
end

local function getCookieTimeLeft(petId, pd, cookieName)
    if not pd or not pd.activeGearBuffs then return false, 0 end
    local expireTime = pd.activeGearBuffs[cookieName]
    if expireTime then
        local timeLeft = expireTime - os.time()
        if timeLeft > 0 then return true, timeLeft else return false, 0 end
    end
    return false, 0
end

local function needsCookie(petId, cookieName)
    local data = getData()
    if not data or not data.inventory or not data.inventory.pets[petId] then return false end
    local pd = data.inventory.pets[petId]
    local has, timeLeft = getCookieTimeLeft(petId, pd, cookieName)
    return not has or timeLeft <= COOKIE_REFRESH_TIME
end

local function giveCookie(petId, cookieName)
    local data = getData()
    if not data or not data.inventory or not data.inventory.gears then return false end
    local inv = data.inventory.gears[cookieName]
    if not inv or (inv.amount or 0) <= 0 then return false end
    if equipTool then pcall(function() equipTool:FireServer(cookieName, "gear") end) end
    task.wait(0.5)
    local success = false
    if usePetGearOnPet then success = pcall(function() usePetGearOnPet:FireServer(petId) end) end
    task.wait(0.5)
    return success
end

local function getPetToyTimeLeft(pd)
    if not pd or not pd.activeGearBuffs then return false, 0 end
    local expireTime = pd.activeGearBuffs[GEAR_PET_TOY]
    if expireTime then
        local timeLeft = expireTime - os.time()
        if timeLeft > 0 then return true, timeLeft else return false, 0 end
    end
    return false, 0
end

local function needsPetToy(petId, minTime)
    local data = getData()
    if not data or not data.inventory or not data.inventory.pets[petId] then return false end
    local pd = data.inventory.pets[petId]
    local has, timeLeft = getPetToyTimeLeft(pd)
    return not has or timeLeft <= (minTime or PET_TOY_REFRESH_TIME)
end

local function givePetToy(petId)
    local data = getData()
    if not data or not data.inventory or not data.inventory.gears then return false end
    local inv = data.inventory.gears[GEAR_PET_TOY]
    if not inv or (inv.amount or 0) <= 0 then return false end
    if equipTool then pcall(function() equipTool:FireServer(GEAR_PET_TOY, "gear") end) end
    task.wait(0.5)
    local success = false
    if usePetGearOnPet then success = pcall(function() usePetGearOnPet:FireServer(petId) end) end
    task.wait(0.5)
    return success
end

local function refreshToysInList(petTable, label)
    if not B.useAutoPetToy then return end
    for id in pairs(petTable) do
        if needsPetToy(id, PET_TOY_REFRESH_TIME) then
            givePetToy(id)
        end
    end
end

local function makePetEntry(id, pd, nameMap)
    local age = getPetAge(pd)
    local m = getPetMutation(pd)
    local petType = pd.petType or pd.type or pd.species or pd.model or "Unknown"
    local nick = pd.nickname or pd.name or pd.displayName or pd.petName
    local name = nameMap[id]
    if not name or name == "" or name == tostring(id) then
        if nick and nick ~= "" and string.lower(tostring(nick)) ~= string.lower(tostring(petType)) then
            name = string.format("%s (%s)", tostring(petType), tostring(nick))
        else
            name = tostring(petType)
        end
    end
    return {id=id, age=age, mutation=m, displayName=tostring(name)}
end

local function scanAllPetsForList()
    local data = getData(); if not data then return {} end
    if not data.inventory or not data.inventory.pets then return {} end
    local nameMap = buildNameMap()
    local list = {}
    for id, pd in pairs(data.inventory.pets) do
        if not isLockedMutation(getPetMutation(pd)) then
            table.insert(list, makePetEntry(id, pd, nameMap))
        end
    end
    table.sort(list, function(a, b)
        if a.displayName ~= b.displayName then return a.displayName < b.displayName end
        return a.age < b.age
    end)
    for i, p in ipairs(list) do p.label = gearPetLabel(p, i) end
    return list
end

local function scanPetsForHelper()
    local data = getData(); if not data then return {} end
    if not data.inventory or not data.inventory.pets then return {} end
    local nameMap = buildNameMap()
    local list = {}
    for id, pd in pairs(data.inventory.pets) do
        local age = getPetAge(pd)
        if age >= BCONFIG.HelperMinAge then
            table.insert(list, makePetEntry(id, pd, nameMap))
        end
    end
    table.sort(list, function(a, b)
        if a.displayName ~= b.displayName then return a.displayName < b.displayName end
        return a.age < b.age
    end)
    for i, p in ipairs(list) do p.label = gearPetLabel(p, i) end
    return list
end

local function matchesSpeciesFilter(petType, filterList)
    if not petType then return false end
    local n = string.lower(tostring(petType))
    for _, key in ipairs(filterList) do
        if n:find(key, 1, true) then return true end
    end
    return false
end

local function scanPetsFiltered(filterList)
    local data = getData(); if not data then return {} end
    if not data.inventory or not data.inventory.pets then return {} end
    local nameMap = buildNameMap()
    local list = {}
    for id, pd in pairs(data.inventory.pets) do
        local age = getPetAge(pd)
        if age >= BCONFIG.HelperMinAge then
            local petType = pd.petType or pd.type or pd.species or pd.model or ""
            if matchesSpeciesFilter(petType, filterList) then
                table.insert(list, makePetEntry(id, pd, nameMap))
            end
        end
    end
    table.sort(list, function(a, b)
        if a.displayName ~= b.displayName then return a.displayName < b.displayName end
        return a.age < b.age
    end)
    for i, p in ipairs(list) do p.label = gearPetLabel(p, i) end
    return list
end

local function scanTargetLowAge()
    local data = getData(); if not data or not data.inventory then return {} end
    local list = {}
    for id, pd in pairs(data.inventory.pets) do
        if B.targetPets[id] and not GRADUATED_PETS[id] then
            local m = getPetMutation(pd)
            if not isLockedMutation(m) and not isDesired(m) then
                local age = getPetAge(pd)
                if age < BCONFIG.TargetAge then
                    table.insert(list, { id = id, age = age })
                end
            end
        end
    end
    table.sort(list, function(a,b) return a.age < b.age end)
    return list
end

local function scanForMutation()
    local data = getData(); if not data or not data.inventory then return {} end
    local list = {}
    for id, pd in pairs(data.inventory.pets) do
        if B.targetPets[id] and not GRADUATED_PETS[id] then
            local m = getPetMutation(pd)
            if not isLockedMutation(m) and not isDesired(m)
                and not B.processedMutation[id] and not B.mutationInProgress[id] then
                local age = getPetAge(pd)
                if age >= BCONFIG.TargetAge then
                    table.insert(list, { id = id, age = age })
                end
            end
        end
    end
    table.sort(list, function(a,b) return a.age > b.age end)
    return list
end

local function scanLevelingPets()
    local data = getData(); if not data or not data.inventory then return {} end
    local list = {}
    for id, pd in pairs(data.inventory.pets) do
        if B.levelingPets[id] and not B.placedLeveling[id] then
            if getPetAge(pd) >= BCONFIG.HelperMinAge then
                table.insert(list, { id = id, age = getPetAge(pd) })
            end
        end
    end
    table.sort(list, function(a,b) return a.age < b.age end)
    return list
end

local function scanSpeedupPets()
    local data = getData(); if not data or not data.inventory then return {} end
    local list = {}
    for id, pd in pairs(data.inventory.pets) do
        if B.speedupPets[id] and not B.placedSpeedup[id] then
            if getPetAge(pd) >= BCONFIG.HelperMinAge then
                table.insert(list, { id = id, age = getPetAge(pd) })
            end
        end
    end
    return list
end

local function allTargetsMaxed()
    local data = getData(); if not data or not data.inventory then return false end
    local t, maxed = 0, 0
    for id, pd in pairs(data.inventory.pets) do
        if B.targetPets[id] then
            local m = getPetMutation(pd)
            if not isLockedMutation(m) and not isDesired(m) then
                t = t + 1
                if getPetAge(pd) >= BCONFIG.TargetAge then maxed = maxed + 1 end
            end
        end
    end
    return t > 0 and maxed >= t
end

local function allTargetAchieved()
    local data = getData(); if not data or not data.inventory then return false end
    local t, ok = 0, 0
    for id, pd in pairs(data.inventory.pets) do
        if B.targetPets[id] then
            local m = getPetMutation(pd)
            if not isLockedMutation(m) then
                t = t + 1
                if isDesired(m) then ok = ok + 1 end
            end
        end
    end
    return t > 0 and ok >= t
end

local function hasMoreBoost() return #scanTargetLowAge() > 0 end
local function hasMutationReady() return #scanForMutation() > 0 end

local function countWave()
    local c, t = 0, 0
    local data = getData(); if not data or not data.inventory then return 0, 0 end
    for id in pairs(B.currentWave) do
        t = t + 1
        local pd = data.inventory.pets[id]
        if pd and getPetAge(pd) >= BCONFIG.TargetAge then c = c + 1 end
    end
    return c, t
end

local function placePet(id, force)
    if not force and B.placedPets[id] then return true end
    local data = getData()
    if not data or not data.inventory or not data.inventory.pets[id] then 
        B.placedPets[id] = true
        return true 
    end
    if equipTool then pcall(function() equipTool:FireServer(id, "pet") end) end
    task.wait(BCONFIG.WaitAfterPlace)
    local ok = false
    if placePetFromInventory then ok = pcall(function() placePetFromInventory:InvokeServer(id) end) end
    task.wait(BCONFIG.WaitAfterPlace)
    if ok and requestPosition then pcall(function() requestPosition:InvokeServer(id) end) end
    task.wait(0.3)
    B.placedPets[id] = true; B.pickedUpPets[id] = nil
    return ok
end

local function pickUp(id)
    if B.pickedUpPets[id] then return true end
    if not pickUpPet then return false end
    local ok = pcall(function() pickUpPet:InvokeServer(id) end)
    if not ok then return false end
    B.pickedUpPets[id] = true; B.placedPets[id] = nil
    return true
end

local function fireJumper(force)
    local now = os.clock()
    if not force and (now - B.lastJumperFire) < BCONFIG.JumperCooldown then return "cooldown" end
    if B.currentLoadout ~= BCONFIG.MainLoadout then ensureLoadout(BCONFIG.MainLoadout) end

    local data = getData()
    if not data or not data.inventory or not data.inventory.gears then return "error" end
    local tj = data.inventory.gears.TimeJumper
    local amount = tj and (tj.amount or 0) or 0

    if amount <= 0 then
        if WEBHOOK.notifyJumperEmpty then
            local now2 = os.time()
            if now2 - (WEBHOOK.lastJumperEmptyNotify or 0) > 120 then
                WEBHOOK.lastJumperEmptyNotify = now2
                sendJumperEmptyWebhook(0)
            end
        end
        return "empty"
    end

    if not useTimeWatch then return "error" end
    local ok = pcall(function() useTimeWatch:FireServer("TimeJumper") end)
    if ok then
        B.lastJumperFire = now
        B.jumperCounter = B.jumperCounter + 1
        B.boostJumperCount = B.boostJumperCount + 1

        local data2 = getData()
        local left = 0
        if data2 and data2.inventory and data2.inventory.gears and data2.inventory.gears.TimeJumper then
            left = data2.inventory.gears.TimeJumper.amount or 0
        end
        if left <= 0 and WEBHOOK.notifyJumperEmpty then
            local now2 = os.time()
            if now2 - (WEBHOOK.lastJumperEmptyNotify or 0) > 120 then
                WEBHOOK.lastJumperEmptyNotify = now2
                sendJumperEmptyWebhook(left)
            end
        end
        return "ok"
    end
    return "error"
end

local function doLoadoutCycle()
    if B.boostLoadoutSwitching then return end
    B.boostLoadoutSwitching = true
    ensureLoadout(BCONFIG.ResetLoadout); task.wait(BCONFIG.JumperSwitchDelay)
    ensureLoadout(BCONFIG.MainLoadout);  task.wait(BCONFIG.JumperSwitchDelay)
    B.boostJumperCount = 0
    refreshToysInList(B.levelingPets, "Leveling")
    B.boostLoadoutSwitching = false
end

local function resetWave() B.currentWave = {}; B.wavePhase = "idle" end

local function placeBoostWave()
    ensureLoadout(BCONFIG.MainLoadout)
    local lvlCands = scanLevelingPets()
    for _, p in ipairs(lvlCands) do
        local needToy = B.useAutoPetToy and needsPetToy(p.id, PET_TOY_REFRESH_TIME)
        if placePet(p.id, true) then
            B.placedLeveling[p.id] = true
            if needToy then
                task.wait(0.5)
                givePetToy(p.id)
            end
        end
        task.wait(0.2)
    end

    local tgtCands = scanTargetLowAge()
    if #tgtCands == 0 then B.wavePhase = "done"; return false end
    local limit = #tgtCands
    if B.maxPlacePerWave > 0 then limit = math.min(B.maxPlacePerWave, #tgtCands) end

    B.currentWave = {}; B.wavePhase = "placing"
    local sc = 0
    for i = 1, limit do
        local petId = tgtCands[i].id
        local needDiamond = B.useAutoCookie and needsCookie(petId, COOKIE_DIAMOND)
        local needXP = B.useAutoCookie and needsCookie(petId, COOKIE_XP)
        local ok = placePet(petId)
        if ok ~= false then
            B.currentWave[petId] = true
            sc = sc + 1
            if needDiamond or needXP then
                task.wait(0.5)
                if needDiamond then giveCookie(petId, COOKIE_DIAMOND) end
                if needXP then giveCookie(petId, COOKIE_XP) end
            end
        end
        task.wait(0.2)
    end
    if sc == 0 then B.wavePhase = "done"; return false end
    B.boostJumperCount = 0; B.wavePhase = "boosting"
    return true
end

local function placeSpeedupPets()
    ensureLoadout(BCONFIG.MainLoadout)
    local cands = scanSpeedupPets()
    local placed = 0
    for _, p in ipairs(cands) do
        if placed >= BCONFIG.SpeedupPlaceCount then break end
        local needToy = B.useAutoPetToy and needsPetToy(p.id, PET_TOY_REFRESH_TIME)
        if placePet(p.id, true) then
            B.placedSpeedup[p.id] = true
            placed = placed + 1
            if needToy then
                task.wait(0.5)
                givePetToy(p.id)
            end
        end
        task.wait(0.2)
    end
    return placed
end

local function pickUpSpeedupPets()
    for id in pairs(B.placedSpeedup) do
        pickUp(id); task.wait(0.2)
    end
    B.placedSpeedup = {}
end

local function insertPet(id)
    local data = getData()
    if not data or not data.inventory or not data.inventory.pets[id] then return false end
    if isLockedMutation(getPetMutation(data.inventory.pets[id])) then return false end
    if equipTool then pcall(function() equipTool:FireServer(id, "pet") end) end
    task.wait(0.5)
    if not startMutation then return false end
    local ok = pcall(function() startMutation:InvokeServer(id) end)
    if ok then
        B.mutationInProgress[id] = true; B.processedMutation[id] = true
        return true
    end
    return false
end

local function setupCollectLoadout()
    if B.collectSetupDone then return true end
    if next(B.collectPets) == nil then
        B.collectSetupDone = true
        return true
    end
    if not ensureLoadout(BCONFIG.CollectLoadout) then return false end
    local placedAny = false
    for id in pairs(B.collectPets) do
        local data = getData()
        if data and data.inventory and data.inventory.pets[id] then
            local needToy = B.useAutoPetToy and needsPetToy(id, PET_TOY_REFRESH_TIME)
            if placePet(id, true) then
                placedAny = true
                if needToy then
                    task.wait(0.5)
                    givePetToy(id)
                end
            end
        end
        task.wait(0.2)
    end
    task.wait(0.5)
    B.collectSetupDone = true
    ensureLoadout(BCONFIG.MainLoadout)
    return placedAny
end

local function autoResolveMutationPrompt(newMutFromCollect, petIdInMachine)
    local data = getData()
    if not data or not data.petMutation then return false end

    local oldMut = data.petMutation.petData and data.petMutation.petData.mutation
    local newMut = newMutFromCollect or data.petMutation.rolledMutation

    if not oldMut or not newMut then
        pcall(function() choosePetMutation:InvokeServer(true) end) 
        return false
    end

    -- URUTAN TIER FINAL (Sesuai Screenshot & Pengalaman Lu)
    local tier = {
        ["None"]      = 0,
        ["Tamed"]     = 1,
        ["Guardian"]  = 2,
        ["Tiny"]      = 3,
        ["Aquatic"]   = 4,
        ["Lightning"] = 5,
        ["Radiant"]   = 6,
        ["Huge"]      = 7,
        ["Silver"]    = 8,  
        ["Gold"]      = 9,  
        ["Diamond"]   = 10  
    }
    
    local oldTier = tier[oldMut] or 0
    local newTier = tier[newMut] or 0
    
    local takeNew = false
    local isTargetSelected = false
    
    -- Cek apakah mutasi baru ini ada di list target dropdown lu
    for t in pairs(B.selectedMutations) do
        if string.lower(t) == string.lower(newMut) then isTargetSelected = true break end
    end

    -- LOGIKA KEPUTUSAN
    if string.lower(tostring(newMut)) == "diamond" then
        takeNew = true -- Diamond wajib ambil
    else
        takeNew = newTier > oldTier -- Ambil jika tier baru lebih tinggi
    end

    print(string.format("[AutoResolve] Lama=%s → Baru=%s | %s", tostring(oldMut), tostring(newMut), takeNew and "TAKE" or "KEEP"))

    -- EKSEKUSI (Tembak remote choosePetMutation)
    local args = { not takeNew } 
    local ok = pcall(function() choosePetMutation:InvokeServer(unpack(args)) end)

    -- BARU KIRIM WEBHOOK SETELAH DIPILIH (Dengan Jeda 1 Detik)
    if ok and takeNew and (isTargetSelected or string.lower(tostring(newMut)) == "diamond") then
        task.wait(1) -- Jeda biar server selesai update inventory
        
        local petName = "Unknown"
        local petWeight = "0.0kg"
        
        -- Ambil data ulang setelah di-ambil mutasinya
        local freshData = getData()
        if petIdInMachine and freshData and freshData.inventory and freshData.inventory.pets[petIdInMachine] then
            local pd = freshData.inventory.pets[petIdInMachine]
            petName = pd.petType or pd.type or pd.species or pd.model or "Unknown"
            petWeight = getFormattedPetWeight(pd)
        end
        
        -- Tembak Webhook ke Discord
        sendMutationWebhook(petName, petWeight, newMut, getJumperCount())
        print("📨 [Webhook] Notifikasi terkirim: " .. tostring(petName) .. " | " .. tostring(petWeight) .. " | " .. tostring(newMut))
        
        -- Graduation Logic (Hapus dari target jika Diamond)
        if string.lower(tostring(newMut)) == "diamond" then
            if petIdInMachine and B.targetPets[petIdInMachine] then
                B.targetPets[petIdInMachine] = nil
                GRADUATED_PETS[petIdInMachine] = true
                print("🏆 [GRADUATION] Pet sukses dapat Diamond! Dihapus dari target.")
            end
        end
    end
    
    return ok, takeNew
end

local function doMutation()
    local now = os.clock()
    if (now - B.lastMutationAction) < BCONFIG.MutationCooldown then return end
    local state = getMachineState()

    if state == "Ready" then
        if not ensureLoadout(BCONFIG.CollectLoadout) then return end
        refreshToysInList(B.collectPets, "Collect")
        local col = {}
        for id in pairs(B.mutationInProgress) do table.insert(col, id) end
        if not collectMutation then return end
        
        -- Ambil mutasi & eksekusi otomatis
        local ok, ret = pcall(function() return collectMutation:InvokeServer() end)
        if ok and ret then
            task.wait(0.5) -- Jeda dikit biar server siap
            
            local pm = getData() and getData().petMutation
            local petIdInMachine = pm and pm.petId
            
            -- Tembak fungsi pemilih mutasi
            autoResolveMutationPrompt(ret, petIdInMachine)
            task.wait(1.5)

            -- Webhook & Logging bawaan script
            local data = getData()
            if data and data.inventory and data.inventory.pets then
                for _, id in ipairs(col) do
                    local pd = data.inventory.pets[id]
                    if pd then
                        local petName = pd.petType or pd.type or pd.species or pd.model or tostring(id)
                        local mutName = getPetMutation(pd)
                        local petWeightStr = getFormattedPetWeight(pd)
                        local jumperLeft = getJumperCount()
                        if B.targetPets[id] and isDesired(mutName) then
                            sendMutationWebhook(petName, petWeightStr, mutName, jumperLeft)
                        end
                    end
                end
            end
            for _, id in ipairs(col) do
                B.totalMutated = B.totalMutated + 1
                B.processedMutation[id] = nil
            end
            B.mutationInProgress = {}
            B.lastMutationAction = os.clock()
        end
        ensureLoadout(BCONFIG.MainLoadout)
        return
    end

    if state == "InProgress" then
        if not B.collectSetupDone then
            local okSetup = setupCollectLoadout()
            if okSetup then ensureLoadout(BCONFIG.WaitingLoadout) end
            return
        end
        if B.currentLoadout ~= BCONFIG.WaitingLoadout then ensureLoadout(BCONFIG.WaitingLoadout) end
        return
    end

    if state == "Idle" then
        if next(B.mutationInProgress) ~= nil then B.mutationInProgress = {} end
        local cands = scanForMutation()
        if #cands == 0 then return end
        if not ensureLoadout(BCONFIG.MainLoadout) then return end
        refreshToysInList(B.speedupPets, "Speedup")
        if insertPet(cands[1].id) then
            B.lastMutationAction = now
            task.wait(0.5)
            ensureLoadout(BCONFIG.WaitingLoadout)
        end
    end
end
local function pickUpWave()
    for id in pairs(B.currentWave) do
        if pickUp(id) then B.totalBoosted = B.totalBoosted + 1 end
        task.wait(0.3)
    end
    resetWave()
end

local function pickUpAllLeveling()
    for id in pairs(B.placedLeveling) do
        pickUp(id); task.wait(0.3)
    end
    B.placedLeveling = {}
end

local function boostLoop()
    ensureLoadout(BCONFIG.MainLoadout)
    while B.isRunning do
        task.wait(BCONFIG.JumperInterval)
        local data = getData(); if not data then continue end

        if allTargetAchieved() then
            pickUpSpeedupPets(); pickUpAllLeveling()
            B.wavePhase = "stopped"; B.isRunning = false
            break
        end
        if B.cycleCount >= BCONFIG.MaxCyclesBeforeStop then
            B.wavePhase = "stopped"; B.isRunning = false
            break
        end

        if B.wavePhase == "mutating" then
            if #scanForMutation() > 0 or getMachineState() == "Ready" or getMachineState() == "InProgress" then
                doMutation()
            else
                if next(B.placedSpeedup) ~= nil then
                    pickUpSpeedupPets()
                end
                B.wavePhase = "idle"
            end
            continue
        end

        if B.wavePhase == "idle" or B.wavePhase == "done" then
            if hasMoreBoost() then
                placeBoostWave()
            elseif allTargetsMaxed() then
                pickUpWave(); pickUpAllLeveling()
                placeSpeedupPets(); B.wavePhase = "mutating"
            elseif next(B.currentWave) ~= nil then
                local c, t = countWave()
                if t > 0 and c >= t then pickUpWave() end
            end
        elseif B.wavePhase == "placing" then
            B.wavePhase = "boosting"
        elseif B.wavePhase == "boosting" then
            local c, t = countWave()
            if t > 0 and c >= t then
                pickUpWave(); B.boostJumperCount = 0
                if allTargetsMaxed() then
                    pickUpAllLeveling(); placeSpeedupPets(); B.wavePhase = "mutating"
                end
            else
                if B.boostJumperCount >= BCONFIG.JumperBeforeSwitch and not B.boostLoadoutSwitching then
                    doLoadoutCycle()
                else
                    local result = fireJumper(false)
                    if result == "empty" then
                        if hasMutationReady() then
                            pickUpWave(); B.boostJumperCount = 0
                            pickUpAllLeveling(); placeSpeedupPets()
                            B.wavePhase = "mutating"
                        else
                            pickUpSpeedupPets(); pickUpAllLeveling(); pickUpWave()
                            B.wavePhase = "stopped"; B.isRunning = false
                            break
                        end
                    end
                end
            end
        end
    end
end

local FPS_STATE = {
    boosted = false, originalSettings = {}, hiddenObjects = {},
    terrainSettings = {}, fishHidden = false, hiddenFish = {},
    mutedSounds = {}, materialCache = {},
}
local Terrain = workspace:FindFirstChildOfClass("Terrain")
local function safeGetChildren(p) local ok, c = pcall(function() return p:GetChildren() end) if ok and c then return c end return {} end
local function safeGetDescendants(p) local ok, c = pcall(function() return p:GetDescendants() end) if ok and c then return c end return {} end

local function saveOriginalSettings()
    FPS_STATE.originalSettings = {
        GlobalShadows = Lighting.GlobalShadows, ShadowSoftness = Lighting.ShadowSoftness,
        Brightness = Lighting.Brightness, Ambient = Lighting.Ambient,
        OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd,
        FogStart = Lighting.FogStart, FogColor = Lighting.FogColor,
        EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale,
        EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale,
        ExposureCompensation = Lighting.ExposureCompensation,
        ClockTime = Lighting.ClockTime,
        QualityLevel = UserSettings().GameSettings.SavedQualityLevel.Value,
    }
    if Terrain then
        pcall(function()
            FPS_STATE.terrainSettings = {
                WaterWaveSize = Terrain.WaterWaveSize, WaterWaveSpeed = Terrain.WaterWaveSpeed,
                WaterReflectance = Terrain.WaterReflectance, WaterTransparency = Terrain.WaterTransparency,
                Decoration = Terrain.Decoration,
            }
        end)
    end
end

local function hideHeavyObject(o, char)
    if not o or not o.Parent then return end
    if char and (o == char or o:IsDescendantOf(char)) then return end
    local cls = o.ClassName
    if cls == "ParticleEmitter" or cls == "Trail" or cls == "Beam"
       or cls == "Fire" or cls == "Smoke" or cls == "Sparkles"
       or cls == "PointLight" or cls == "SpotLight" or cls == "SurfaceLight"
       or cls == "Explosion" or cls == "Atmosphere" or cls == "Sky" then
        pcall(function()
            if o.Enabled then
                o.Enabled = false
                table.insert(FPS_STATE.hiddenObjects, {obj = o, prop = "Enabled", val = true})
            end
        end)
    elseif cls == "Decal" or cls == "Texture" then
        pcall(function()
            if o.Transparency < 1 then
                table.insert(FPS_STATE.hiddenObjects, {obj = o, prop = "Transparency", val = o.Transparency})
                o.Transparency = 1
            end
        end)
    elseif cls == "MeshPart" then
        pcall(function()
            if o.TextureID ~= "" then
                table.insert(FPS_STATE.hiddenObjects, {obj = o, prop = "TextureID", val = o.TextureID})
                o.TextureID = ""
            end
            if o.Material ~= Enum.Material.SmoothPlastic then
                table.insert(FPS_STATE.materialCache, {obj = o, prop = "Material", val = o.Material})
                o.Material = Enum.Material.SmoothPlastic
            end
        end)
    elseif cls == "SurfaceAppearance" then
        pcall(function()
            if o.Enabled then
                table.insert(FPS_STATE.hiddenObjects, {obj = o, prop = "Enabled", val = true})
                o.Enabled = false
            end
        end)
    elseif cls == "BasePart" then
        pcall(function()
            if o.Material ~= Enum.Material.SmoothPlastic then
                table.insert(FPS_STATE.materialCache, {obj = o, prop = "Material", val = o.Material})
                o.Material = Enum.Material.SmoothPlastic
            end
            if o.CastShadow then
                table.insert(FPS_STATE.hiddenObjects, {obj = o, prop = "CastShadow", val = true})
                o.CastShadow = false
            end
        end)
    end
end

local function boostFPS()
    if FPS_STATE.boosted then return false end
    local ok = pcall(function()
        saveOriginalSettings()
        FPS_STATE.boosted = true
        FPS_STATE.hiddenObjects = {} FPS_STATE.mutedSounds = {} FPS_STATE.materialCache = {}
        Lighting.GlobalShadows = false
        Lighting.ShadowSoftness = 0
        Lighting.Brightness = 1
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
        Lighting.FogEnd = 1e6
        Lighting.FogStart = 1e6
        Lighting.EnvironmentDiffuseScale = 0
        Lighting.EnvironmentSpecularScale = 0
        Lighting.ExposureCompensation = 0
        Lighting.ClockTime = 14
        for _, e in ipairs(safeGetChildren(Lighting)) do
            pcall(function()
                if e:IsA("PostEffect") or e:IsA("Atmosphere") or e:IsA("Sky") then
                    if e.Enabled ~= nil then
                        e.Enabled = false
                        table.insert(FPS_STATE.hiddenObjects, {obj = e, prop = "Enabled", val = true})
                    end
                end
            end)
        end
        if Terrain then
            pcall(function()
                Terrain.WaterWaveSize = 0
                Terrain.WaterWaveSpeed = 0
                Terrain.WaterReflectance = 0
                Terrain.WaterTransparency = 1
                Terrain.Decoration = false
            end)
        end
        pcall(function()
            UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
        end)
        local char = player.Character
        for _, o in ipairs(safeGetDescendants(workspace)) do hideHeavyObject(o, char) end
        for _, s in ipairs(safeGetDescendants(workspace)) do
            pcall(function()
                if s:IsA("Sound") and s.Playing then
                    s.Playing = false
                    table.insert(FPS_STATE.mutedSounds, s)
                end
            end)
        end
    end)
    if not ok then FPS_STATE.boosted = false return false end
    return true
end

local function unboostFPS()
    if not FPS_STATE.boosted then return false end
    FPS_STATE.boosted = false
    pcall(function()
        local o = FPS_STATE.originalSettings or {}
        Lighting.GlobalShadows = o.GlobalShadows ~= false
        Lighting.ShadowSoftness = o.ShadowSoftness or 0.2
        Lighting.Brightness = o.Brightness or 2
        Lighting.Ambient = o.Ambient or Color3.fromRGB(70, 70, 70)
        Lighting.OutdoorAmbient = o.OutdoorAmbient or Color3.fromRGB(128, 128, 128)
        Lighting.FogEnd = o.FogEnd or 100000
        Lighting.FogStart = o.FogStart or 0
        Lighting.FogColor = o.FogColor or Color3.fromRGB(192, 192, 192)
        Lighting.EnvironmentDiffuseScale = o.EnvironmentDiffuseScale or 1
        Lighting.EnvironmentSpecularScale = o.EnvironmentSpecularScale or 1
        Lighting.ExposureCompensation = o.ExposureCompensation or 0
        Lighting.ClockTime = o.ClockTime or 14
        if Terrain and FPS_STATE.terrainSettings then
            local t = FPS_STATE.terrainSettings
            Terrain.WaterWaveSize = t.WaterWaveSize or 0.15
            Terrain.WaterWaveSpeed = t.WaterWaveSpeed or 10
            Terrain.WaterReflectance = t.WaterReflectance or 0.1
            Terrain.WaterTransparency = t.WaterTransparency or 0.3
            Terrain.Decoration = t.Decoration ~= false
        end
        for _, e in ipairs(FPS_STATE.hiddenObjects) do
            pcall(function() if e.obj and e.obj.Parent then e.obj[e.prop] = e.val end end)
        end
        FPS_STATE.hiddenObjects = {}
        for _, m in ipairs(FPS_STATE.materialCache) do
            pcall(function() if m.obj and m.obj.Parent then m.obj[m.prop] = m.val end end)
        end
        FPS_STATE.materialCache = {}
        for _, s in ipairs(FPS_STATE.mutedSounds) do
            pcall(function() if s and s.Parent then s.Playing = true end end)
        end
        FPS_STATE.mutedSounds = {}
        pcall(function() UserSettings().GameSettings.SavedQualityLevel = o.QualityLevel or Enum.SavedQualitySetting.QualityLevel5 end)
    end)
    return true
end

local function hideFish()
    if FPS_STATE.fishHidden then return 0 end
    FPS_STATE.hiddenFish = {}
    local count = 0
    local gameFolder = workspace:FindFirstChild("Game")
    if gameFolder then
        table.insert(FPS_STATE.hiddenFish, {obj = gameFolder, parent = gameFolder.Parent, type = "folder"})
        pcall(function() gameFolder.Parent = nil end)
        count += 1
    end
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("Model") and obj.Parent then
            if obj.Parent.Name:lower():find("pond") then
                local n = obj.Name:lower()
                if n == "sardine" or n == "cod" or n == "salmon" or n:find("_gold") or n:find("_silver") then
                    table.insert(FPS_STATE.hiddenFish, {obj = obj, parent = obj.Parent, type = "model"})
                    pcall(function() obj.Parent = nil end)
                    count += 1
                end
            end
        end
    end
    FPS_STATE.fishHidden = true
    return count
end

local function showFish()
    if not FPS_STATE.fishHidden then return 0 end
    local count = 0
    for _, entry in ipairs(FPS_STATE.hiddenFish) do
        if entry.obj then
            pcall(function() entry.obj.Parent = entry.parent or workspace; count += 1 end)
        end
    end
    FPS_STATE.hiddenFish = {}
    FPS_STATE.fishHidden = false
    return count
end

-- ====================== UI ======================
-- ====================== UI ======================
local oldGui = game:GetService("CoreGui"):FindFirstChild("CustomAutoMutasiUI")
if oldGui then oldGui:Destroy() end

-- ✅ TAMBAHKAN BLOK INI:
local THEME = {
    bg        = Color3.fromRGB(24, 26, 32),
    panel     = Color3.fromRGB(32, 35, 43),
    panelAlt  = Color3.fromRGB(40, 44, 54),
    accent    = Color3.fromRGB(88, 166, 255),
    accentDim = Color3.fromRGB(60, 110, 180),
    text      = Color3.fromRGB(230, 232, 238),
    textDim   = Color3.fromRGB(150, 155, 170),
    success   = Color3.fromRGB(80, 200, 120),
    danger    = Color3.fromRGB(220, 80, 80),
    border    = Color3.fromRGB(55, 60, 72),
}
-- ✅ SAMPAI SINI

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CustomAutoMutasiUI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game:GetService("CoreGui")

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 600, 0, 450)
MainFrame.Position = UDim2.new(0.5, -300, 0.5, -225)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 8)

local TopBar = Instance.new("Frame")
TopBar.Name = "TopBar"
TopBar.Size = UDim2.new(1, 0, 0, 45)
TopBar.BackgroundTransparency = 1
TopBar.ZIndex = 2
TopBar.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -150, 1, 0)
Title.Position = UDim2.new(0, 20, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "Farm A Fish | by IQI"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = TopBar

local FpsLabel = Instance.new("TextLabel")
FpsLabel.Size = UDim2.new(0, 44, 0, 25)
FpsLabel.Position = UDim2.new(1, -120, 0.5, -12)
FpsLabel.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
FpsLabel.Text = "--"
FpsLabel.TextColor3 = Color3.fromRGB(120, 255, 120)
FpsLabel.Font = Enum.Font.GothamBold
FpsLabel.TextSize = 11
FpsLabel.BorderSizePixel = 0
FpsLabel.Parent = TopBar
Instance.new("UICorner", FpsLabel).CornerRadius = UDim.new(0, 5)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -80, 0.5, -15)
MinBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 18
MinBtn.Parent = TopBar
Instance.new("UICorner", MinBtn).CornerRadius = UDim.new(0, 6)

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(1, -45, 0.5, -15)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 16
CloseBtn.Parent = TopBar
Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 6)

local BodyContainer = Instance.new("Frame")
BodyContainer.Name = "BodyContainer"
BodyContainer.Size = UDim2.new(1, 0, 1, -45)
BodyContainer.Position = UDim2.new(0, 0, 0, 45)
BodyContainer.BackgroundTransparency = 1
BodyContainer.Parent = MainFrame

local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 150, 1, -40)
Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
Sidebar.Parent = BodyContainer
Instance.new("UICorner", Sidebar).CornerRadius = UDim.new(0, 8)

local function CreateSidebarBtn(text, yPos)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0.9, 0, 0, 35)
    Btn.Position = UDim2.new(0.05, 0, 0, yPos)
    Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Parent = Sidebar
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    return Btn
end

local TabBtnAuto = CreateSidebarBtn("Auto Mutasi", 15)
local TabBtnShop = CreateSidebarBtn("Shop", 55)
local TabBtnGear = CreateSidebarBtn("Craft & Food", 95)
local TabBtnEvent = CreateSidebarBtn("Event", 135)

-- ✅ TAB BARU: Diletakkan di bawah Event (Y: 175)
local TabBtnNewAuto = CreateSidebarBtn("⚡ Auto", 175) 

-- Geser tombol Boost ke bawah
local TabBtnBoost = CreateSidebarBtn("Boost & Webhook", 215)

local function CreateContentFrame()
    local F = Instance.new("Frame")
    F.Size = UDim2.new(1, -150, 1, -40)
    F.Position = UDim2.new(0, 150, 0, 0)
    F.BackgroundTransparency = 1
    F.Visible = false
    F.Parent = BodyContainer
    return F
end

local ContentAuto = CreateContentFrame()
local ContentShop = CreateContentFrame()
local ContentGear = CreateContentFrame()
local ContentEvent = CreateContentFrame()

local ContentNewAuto = CreateContentFrame() -- ✅ SISIPKAN INI

local ContentBoost = CreateContentFrame()
ContentAuto.Visible = true -- Biarkan ini tetap ada

local function CreateScrolling(parent)
    local S = Instance.new("ScrollingFrame")
    S.Size = UDim2.new(1, -20, 1, -20)
    S.Position = UDim2.new(0, 10, 0, 10)
    S.BackgroundTransparency = 1
    S.BorderSizePixel = 0
    S.ScrollBarThickness = 6
    S.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
    S.CanvasSize = UDim2.new(0, 0, 0, 0)
    S.AutomaticCanvasSize = Enum.AutomaticSize.Y
    S.Parent = parent
    Instance.new("UIListLayout", S).Padding = UDim.new(0, 8)
    return S
end

local ScrollingAuto = CreateScrolling(ContentAuto)
local ScrollingShop = CreateScrolling(ContentShop)
local ScrollingGear = CreateScrolling(ContentGear)
local ScrollingEvent = CreateScrolling(ContentEvent)

local ScrollingNewAuto = CreateScrolling(ContentNewAuto) -- ✅ SISIPKAN INI

local ScrollingBoost = CreateScrolling(ContentBoost)

local StatusPanel = Instance.new("Frame")
StatusPanel.Size = UDim2.new(1, 0, 0, 55)
StatusPanel.Position = UDim2.new(0, 0, 1, -55)
StatusPanel.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
StatusPanel.Parent = BodyContainer
Instance.new("UICorner", StatusPanel).CornerRadius = UDim.new(0, 8)

local StatusLbl = Instance.new("TextLabel")
StatusLbl.Size = UDim2.new(1, -20, 1, 0)
StatusLbl.Position = UDim2.new(0, 10, 0, 0)
StatusLbl.BackgroundTransparency = 1
StatusLbl.Text = "Status: IDLE"
StatusLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLbl.TextXAlignment = Enum.TextXAlignment.Left
StatusLbl.Font = Enum.Font.Gotham
StatusLbl.TextSize = 10
StatusLbl.TextWrapped = true
StatusLbl.Parent = StatusPanel

local MiniBtn = Instance.new("TextButton")
MiniBtn.Size = UDim2.new(0, 56, 0, 28)
MiniBtn.Position = UDim2.new(0, 10, 0, 10)
MiniBtn.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
MiniBtn.Text = "⛔"
MiniBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MiniBtn.Font = Enum.Font.GothamBold
MiniBtn.TextSize = 14
MiniBtn.BorderSizePixel = 0
MiniBtn.Visible = false
MiniBtn.Active = true
MiniBtn.Draggable = true
MiniBtn.Parent = ScreenGui
Instance.new("UICorner", MiniBtn).CornerRadius = UDim.new(0, 6)

MinBtn.MouseButton1Click:Connect(function()
    S.minimized = true
    MainFrame.Visible = false
    MiniBtn.Visible = true
end)

MiniBtn.MouseButton1Click:Connect(function()
    S.minimized = false
    MainFrame.Visible = true
    MiniBtn.Visible = false
end)

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
    S.gOn, S.bOn, S.eOn, S.gdOn = false, false, false, false
    BCONFIG.FoodOn, BCONFIG.CraftOn = false, false
    B.isRunning = false
    stopAntiAfk()
    stopHWCollect()
    stopHWFeedPickup()
end)

local function SwitchTab(activeTab, activeBtn)
    ContentAuto.Visible = activeTab == ContentAuto
    ContentShop.Visible = activeTab == ContentShop
    ContentGear.Visible = activeTab == ContentGear
    ContentEvent.Visible = activeTab == ContentEvent
    ContentBoost.Visible = activeTab == ContentBoost
    
    ContentNewAuto.Visible = activeTab == ContentNewAuto -- ✅ SISIPKAN INI

    local btns = {TabBtnAuto, TabBtnShop, TabBtnGear, TabBtnEvent, TabBtnBoost, TabBtnNewAuto} -- ✅ TAMBAHKAN TabBtnNewAuto DI SINI
    for _, b in ipairs(btns) do
        b.BackgroundColor3 = b == activeBtn and Color3.fromRGB(50, 50, 60) or Color3.fromRGB(35, 35, 40)
        b.TextColor3 = b == activeBtn and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(150, 150, 150)
    end
end

TabBtnAuto.MouseButton1Click:Connect(function() SwitchTab(ContentAuto, TabBtnAuto) end)
TabBtnShop.MouseButton1Click:Connect(function() SwitchTab(ContentShop, TabBtnShop) end)
TabBtnGear.MouseButton1Click:Connect(function() SwitchTab(ContentGear, TabBtnGear) end)
TabBtnEvent.MouseButton1Click:Connect(function() SwitchTab(ContentEvent, TabBtnEvent) end)

TabBtnNewAuto.MouseButton1Click:Connect(function() SwitchTab(ContentNewAuto, TabBtnNewAuto) end) -- ✅ SISIPKAN INI

TabBtnBoost.MouseButton1Click:Connect(function() SwitchTab(ContentBoost, TabBtnBoost) end)

local function CreateToggle(text, default, parent, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Btn.Text = "  " .. text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.TextXAlignment = Enum.TextXAlignment.Left
    Btn.Font = Enum.Font.Gotham
    Btn.TextSize = 14
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)

    local Ind = Instance.new("Frame")
    Ind.Size = UDim2.new(0, 36, 0, 20)
    Ind.Position = UDim2.new(1, -46, 0.5, -10)
    Ind.BackgroundColor3 = default and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 80, 80)
    Ind.Parent = Btn
    Instance.new("UICorner", Ind).CornerRadius = UDim.new(1, 0)

    local Circle = Instance.new("Frame")
    Circle.Size = UDim2.new(0, 16, 0, 16)
    Circle.Position = default and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
    Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Circle.Parent = Ind
    Instance.new("UICorner", Circle).CornerRadius = UDim.new(1, 0)

    local state = default
    Btn.MouseButton1Click:Connect(function()
        state = not state
        Ind.BackgroundColor3 = state and Color3.fromRGB(0, 150, 255) or Color3.fromRGB(80, 80, 80)
        Circle.Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
        callback(state)
    end)
end

local function CreateInput(text, default, parent, callback)
    local Frame = Instance.new("Frame")
    Frame.Size = UDim2.new(1, 0, 0, 40)
    Frame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
    Frame.Parent = parent
    Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 6)

    local Lbl = Instance.new("TextLabel")
    Lbl.Size = UDim2.new(0.4, 0, 1, 0)
    Lbl.Position = UDim2.new(0, 10, 0, 0)
    Lbl.BackgroundTransparency = 1
    Lbl.Text = text
    Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
    Lbl.TextXAlignment = Enum.TextXAlignment.Left
    Lbl.Font = Enum.Font.Gotham
    Lbl.TextSize = 14
    Lbl.Parent = Frame

    local Box = Instance.new("TextBox")
    Box.Size = UDim2.new(0.55, -20, 0, 26)
    Box.Position = UDim2.new(0.4, 10, 0.5, -13)
    Box.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    Box.Text = tostring(default)
    Box.TextColor3 = Color3.fromRGB(255, 255, 255)
    Box.Font = Enum.Font.Gotham
    Box.TextSize = 14
    Box.Parent = Frame
    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)

    Box.FocusLost:Connect(function()
        callback(Box.Text)
    end)
end

-- ====================== HELPER: ANTI KLIK-SAAT-SCROLL (CROSS-PLATFORM) ======================
local UserInputService = UserInputService or game:GetService("UserInputService")
local GuiService = GuiService or game:GetService("GuiService")

local IS_TOUCH = UserInputService.TouchEnabled and not UserInputService.MouseEnabled

local function makeAntiScrollClick(button, scrollFrame)
    -- Threshold beda untuk touch vs mouse
    local MOVE_THRESHOLD   = IS_TOUCH and 18 or 8       -- pixel
    local TIME_THRESHOLD   = IS_TOUCH and 0.60 or 0.35  -- detik
    local CANVAS_THRESHOLD = 2
    local DEBOUNCE         = IS_TOUCH and 0.20 or 0.15

    -- State
    local pressPos       = nil
    local pressTime      = 0
    local canvasAtDown   = nil
    local lastFire       = 0
    local touchMovedTooMuch = false
    local touchReleasedEarly = false
    local lastTouchMove = 0

    -- ===== MOUSE PATH =====
    button.MouseButton1Down:Connect(function()
        if IS_TOUCH then return end -- di touch, MouseButton1Down tidak reliable
        pressPos = UserInputService:GetMouseLocation()
        pressTime = os.clock()
        if scrollFrame then canvasAtDown = scrollFrame.CanvasPosition end
    end)

    -- ===== TOUCH PATH =====
    local function onTouchBegan(input)
        if not IS_TOUCH then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        pressPos = input.Position -- Vector3 (x, y)
        pressTime = os.clock()
        touchMovedTooMuch = false
        if scrollFrame then canvasAtDown = scrollFrame.CanvasPosition end
    end

    local function onTouchMoved(input)
        if not IS_TOUCH then return end
        if input.UserInputType ~= Enum.UserInputType.Touch then return end
        if not pressPos then return end
        local delta = (Vector2.new(input.Position.X, input.Position.Y)
                     - Vector2.new(pressPos.X, pressPos.Y)).Magnitude
        if delta > MOVE_THRESHOLD then
            touchMovedTooMuch = true
        end
        lastTouchMove = os.clock()
    end

    button.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            onTouchBegan(input)
        end
    end)

    button.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch then
            onTouchMoved(input)
        end
    end)

    -- Fallback: kalau InputChanged tidak fire di Roblox versi tertentu
    UserInputService.TouchMoved:Connect(function(input)
        if not pressPos then return end
        local delta = (Vector2.new(input.Position.X, input.Position.Y)
                     - Vector2.new(pressPos.X, pressPos.Y)).Magnitude
        if delta > MOVE_THRESHOLD then
            touchMovedTooMuch = true
        end
        lastTouchMove = os.clock()
    end)

    -- Klik handler (sama untuk mouse & touch)
    return function()
        local now = os.clock()

        -- === TOUCH ===
        if IS_TOUCH then
            -- 1. Jari sempat geser jauh = scroll
            if touchMovedTooMuch then
                pressPos = nil; canvasAtDown = nil; touchMovedTooMuch = false
                return false
            end
            -- 2. Canvas bergeser = scroll
            if scrollFrame and canvasAtDown then
                local cd = (scrollFrame.CanvasPosition - canvasAtDown).Magnitude
                if cd > CANVAS_THRESHOLD then
                    pressPos = nil; canvasAtDown = nil; touchMovedTooMuch = false
                    return false
                end
            end
            -- 3. Hold terlalu lama
            if pressPos and (now - pressTime) > TIME_THRESHOLD then
                pressPos = nil; canvasAtDown = nil; touchMovedTooMuch = false
                return false
            end
            -- 4. Debounce
            if now - lastFire < DEBOUNCE then
                pressPos = nil; canvasAtDown = nil; touchMovedTooMuch = false
                return false
            end
            lastFire = now
            pressPos = nil; canvasAtDown = nil; touchMovedTooMuch = false
            return true
        end

        -- === MOUSE (logika lama) ===
        local pos = UserInputService:GetMouseLocation()
        if pressPos and (now - pressTime) > TIME_THRESHOLD then
            pressPos = nil; canvasAtDown = nil
            return false
        end
        if pressPos then
            local delta = (pos - pressPos).Magnitude
            if delta > MOVE_THRESHOLD then
                pressPos = nil; canvasAtDown = nil
                return false
            end
        end
        if scrollFrame and canvasAtDown then
            local cd = (scrollFrame.CanvasPosition - canvasAtDown).Magnitude
            if cd > CANVAS_THRESHOLD then
                pressPos = nil; canvasAtDown = nil
                return false
            end
        end
        if now - lastFire < DEBOUNCE then
            pressPos = nil; canvasAtDown = nil
            return false
        end
        lastFire = now
        pressPos = nil; canvasAtDown = nil
        return true
    end
end

local ALL_DROPDOWNS = {}
local DropdownOrder = 0
local function CreateDropdown(title, parent, callback, showSelectAll)
    DropdownOrder += 1
    local baseZ = 20 + DropdownOrder * 10

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundColor3 = THEME.panelAlt
    Container.ClipsDescendants = true
    Container.ZIndex = baseZ
    Container.LayoutOrder = DropdownOrder
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = baseZ + 1
    Header.Parent = Container

    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -50, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 12, 0, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = title
    HeaderLabel.TextColor3 = THEME.text
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Font = Enum.Font.GothamMedium
    HeaderLabel.TextSize = 13
    HeaderLabel.ZIndex = baseZ + 2
    HeaderLabel.Parent = Header

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 26, 1, 0)
    Arrow.Position = UDim2.new(1, -32, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = THEME.textDim
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 12
    Arrow.ZIndex = baseZ + 2
    Arrow.Parent = Header

    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, 0, 0, 0)
    Body.Position = UDim2.new(0, 0, 0, 42)
    Body.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    Body.BorderSizePixel = 0
    Body.ClipsDescendants = true
    Body.Visible = false
    Body.ZIndex = baseZ + 1
    Body.Parent = Container
    Instance.new("UICorner", Body).CornerRadius = UDim.new(0, 6)

    local ActionRow, SelectAllBtn, ClearAllBtn
    local LIST_HEIGHT = 180
    local TOP_OFFSET = 6

    if showSelectAll then
        ActionRow = Instance.new("Frame")
        ActionRow.Size = UDim2.new(1, -12, 0, 26)
        ActionRow.Position = UDim2.new(0, 6, 0, 6)
        ActionRow.BackgroundTransparency = 1
        ActionRow.ZIndex = baseZ + 2
        ActionRow.Parent = Body

        SelectAllBtn = Instance.new("TextButton")
        SelectAllBtn.Size = UDim2.new(0.48, 0, 1, 0)
        SelectAllBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 90)
        SelectAllBtn.Text = "✅ Select All"
        SelectAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        SelectAllBtn.Font = Enum.Font.GothamBold
        SelectAllBtn.TextSize = 11
        SelectAllBtn.ZIndex = baseZ + 3
        SelectAllBtn.Parent = ActionRow
        Instance.new("UICorner", SelectAllBtn).CornerRadius = UDim.new(0, 4)

        ClearAllBtn = Instance.new("TextButton")
        ClearAllBtn.Size = UDim2.new(0.48, 0, 1, 0)
        ClearAllBtn.Position = UDim2.new(0.52, 0, 0, 0)
        ClearAllBtn.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
        ClearAllBtn.Text = "✖ Clear"
        ClearAllBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ClearAllBtn.Font = Enum.Font.GothamBold
        ClearAllBtn.TextSize = 11
        ClearAllBtn.ZIndex = baseZ + 3
        ClearAllBtn.Parent = ActionRow
        Instance.new("UICorner", ClearAllBtn).CornerRadius = UDim.new(0, 4)

        TOP_OFFSET = 36
    end

    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, -8, 0, LIST_HEIGHT)
    ListFrame.Position = UDim2.new(0, 4, 0, TOP_OFFSET)
    ListFrame.BackgroundTransparency = 1
    ListFrame.BorderSizePixel = 0
    ListFrame.ScrollBarThickness = 5
    ListFrame.ScrollBarImageColor3 = THEME.accentDim
    ListFrame.ElasticBehavior = Enum.ElasticBehavior.Never
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ListFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ListFrame.ZIndex = baseZ + 2
    ListFrame.Parent = Body

    local ListLayout = Instance.new("UIListLayout")
    ListLayout.Padding = UDim.new(0, 3)
    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ListLayout.Parent = ListFrame
    Instance.new("UIPadding", ListFrame).PaddingLeft = UDim.new(0, 2)
    Instance.new("UIPadding", ListFrame).PaddingRight = UDim.new(0, 2)
    Instance.new("UIPadding", ListFrame).PaddingTop = UDim.new(0, 2)
    Instance.new("UIPadding", ListFrame).PaddingBottom = UDim.new(0, 2)

    local isOpen = false
    local selectedValues = {}
    local currentItems = {}

    local function fireCallback()
        local sel = {}
        for k in pairs(selectedValues) do table.insert(sel, k) end
        callback(sel)
    end

    local function setItemVisual(btn, item)
        if selectedValues[item] then
            btn.BackgroundColor3 = THEME.accentDim
            btn.TextColor3 = Color3.fromRGB(255, 255, 255)
        else
            btn.BackgroundColor3 = Color3.fromRGB(34, 37, 46)
            btn.TextColor3 = Color3.fromRGB(200, 200, 210)
        end
    end

    local self = {
        Update = function() end, -- assign later
        Frame = Container,
        Close = function()
            isOpen = false
            Body.Visible = false
            Body.Size = UDim2.new(1, 0, 0, 0)
            Container.Size = UDim2.new(1, 0, 0, 42)
            Arrow.Text = "▼"
        end,
    }
    table.insert(ALL_DROPDOWNS, self)

    local checkHeader = makeAntiScrollClick(Header, nil)
    Header.MouseButton1Click:Connect(function()
        if not checkHeader() then return end
        isOpen = not isOpen
        if isOpen then
            for _, dd in ipairs(ALL_DROPDOWNS) do
                if dd ~= self then dd.Close() end
            end
            Body.Visible = true
            local totalH = TOP_OFFSET + LIST_HEIGHT + 8
            Body.Size = UDim2.new(1, 0, 0, totalH)
            Container.Size = UDim2.new(1, 0, 0, 42 + totalH)
            Arrow.Text = "▲"
        else
            self.Close()
        end
    end)

    if SelectAllBtn then
        local checkSelectAll = makeAntiScrollClick(SelectAllBtn, ListFrame)
        SelectAllBtn.MouseButton1Click:Connect(function()
            if not checkSelectAll() then return end
            for _, item in ipairs(currentItems) do selectedValues[item] = true end
            for _, c in ipairs(ListFrame:GetChildren()) do
                if c:IsA("TextButton") then
                    local k = c:GetAttribute("ItemKey")
                    if k then setItemVisual(c, k) end
                end
            end
            fireCallback()
        end)
    end

    if ClearAllBtn then
        local checkClearAll = makeAntiScrollClick(ClearAllBtn, ListFrame)
        ClearAllBtn.MouseButton1Click:Connect(function()
            if not checkClearAll() then return end
            selectedValues = {}
            for _, c in ipairs(ListFrame:GetChildren()) do
                if c:IsA("TextButton") then
                    local k = c:GetAttribute("ItemKey")
                    if k then setItemVisual(c, k) end
                end
            end
            fireCallback()
        end)
    end

    local function UpdateData(items)
        currentItems = items
        for _, c in ipairs(ListFrame:GetChildren()) do
            if c:IsA("TextButton") then c:Destroy() end
        end
        local order = 0
        for _, item in ipairs(items) do
            order += 1
            local ItemBtn = Instance.new("TextButton")
            ItemBtn.Size = UDim2.new(1, 0, 0, 32)
            ItemBtn.BackgroundColor3 = Color3.fromRGB(34, 37, 46)
            ItemBtn.Text = item
            ItemBtn.TextColor3 = Color3.fromRGB(200, 200, 210)
            ItemBtn.TextXAlignment = Enum.TextXAlignment.Left
            ItemBtn.Font = Enum.Font.Gotham
            ItemBtn.TextSize = 12
            ItemBtn.AutoButtonColor = false
            ItemBtn.LayoutOrder = order
            ItemBtn.ZIndex = baseZ + 3
            ItemBtn.Parent = ListFrame
            Instance.new("UICorner", ItemBtn).CornerRadius = UDim.new(0, 4)
            local ip = Instance.new("UIPadding", ItemBtn)
            ip.PaddingLeft = UDim.new(0, 10)
            ItemBtn:SetAttribute("ItemKey", item)
            setItemVisual(ItemBtn, item)

            local checkItem = makeAntiScrollClick(ItemBtn, ListFrame)
            ItemBtn.MouseButton1Click:Connect(function()
                if not checkItem() then return end
                if selectedValues[item] then
                    selectedValues[item] = nil
                else
                    selectedValues[item] = true
                end
                setItemVisual(ItemBtn, item)
                fireCallback()
            end)
        end
    end

    self.Update = UpdateData
    return self
end

local function CreateButton(parent, text, callback)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, 0, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    Btn.Text = text
    Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    Btn.Font = Enum.Font.GothamBold
    Btn.TextSize = 14
    Btn.Parent = parent
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 6)
    Btn.MouseButton1Click:Connect(callback)
end

local isRunning = false
CreateToggle("Start Auto Mutasi", false, ScrollingAuto, function(state)
    isRunning = state
    B.isRunning = state
    if B.isRunning then
        if next(B.targetPets) == nil then warn("Pilih Pet Target dulu!"); return end
        if not hasSelected() then warn("Pilih target mutasi dulu!"); return end
        resetWave()
        B.placedPets = {}; B.pickedUpPets = {}
        B.placedLeveling = {}; B.placedSpeedup = {}
        B.mutationInProgress = {}; B.processedMutation = {}
        B.currentLoadout = nil; B.lastLoadoutSwitch = 0
        B.totalBoosted = 0; B.totalMutated = 0; B.cycleCount = 0
        B.jumperCounter = 0; B.lastJumperFire = 0; B.lastMutationAction = 0
        B.boostJumperCount = 0; B.boostLoadoutSwitching = false
        B.lastJumperEmptyNotify = 0
        B.collectSetupDone = false
        task.spawn(boostLoop)
    end
end)

local mutDropdown = CreateDropdown("Target Mutasi", ScrollingAuto, function(sel)
    B.selectedMutations = {}
    for _, m in ipairs(sel) do B.selectedMutations[m] = true end
end)
mutDropdown.Update(ALL_MUTATIONS)

CreateInput("Max Place Target", B.maxPlacePerWave, ScrollingAuto, function(text)
    local n = tonumber(text)
    if n then B.maxPlacePerWave = math.floor(n) end
end)

local lvlLabelToId, spdLabelToId, tgtLabelToId, colLabelToId = {}, {}, {}, {}

local lvlDropdown = CreateDropdown("Pet Leveling", ScrollingAuto, function(sel)
    B.levelingPets = {}
    for _, lbl in ipairs(sel) do
        local id = lvlLabelToId[lbl]; if id then B.levelingPets[id] = true end
    end
end)

local spdDropdown = CreateDropdown("Pet Boost Mesin", ScrollingAuto, function(sel)
    B.speedupPets = {}
    for _, lbl in ipairs(sel) do
        local id = spdLabelToId[lbl]; if id then B.speedupPets[id] = true end
    end
end)

local tgtDropdown = CreateDropdown("Pet Target", ScrollingAuto, function(sel)
    B.targetPets = {}
    for _, lbl in ipairs(sel) do
        local id = tgtLabelToId[lbl]; if id then B.targetPets[id] = true end
    end
end, true)

local colDropdown = CreateDropdown("Pet Collect", ScrollingAuto, function(sel)
    B.collectPets = {}
    for _, lbl in ipairs(sel) do
        local id = colLabelToId[lbl]; if id then B.collectPets[id] = true end
    end
end)

CreateButton(ScrollingAuto, "Scan Pet", function()
    if B.isRunning then warn("Stop dulu sebelum scan."); return end
    local allPets   = scanAllPetsForList()
    local lvlPets   = scanPetsFiltered(SPECIES_FILTER.leveling)
    local spdPets   = scanPetsFiltered(SPECIES_FILTER.speedup)
    local colPets   = scanPetsFiltered(SPECIES_FILTER.collect)

    B.petList = allPets; B.petById = {}
    lvlLabelToId, spdLabelToId, tgtLabelToId, colLabelToId = {}, {}, {}, {}
    local lvlOpt, spdOpt, tgtOpt, colOpt = {}, {}, {}, {}

    for _, p in ipairs(lvlPets) do
        B.petById[p.id] = p
        table.insert(lvlOpt, p.label); lvlLabelToId[p.label] = p.id
    end
    for _, p in ipairs(spdPets) do
        B.petById[p.id] = p
        table.insert(spdOpt, p.label); spdLabelToId[p.label] = p.id
    end
    for _, p in ipairs(allPets) do
        B.petById[p.id] = p
        table.insert(tgtOpt, p.label); tgtLabelToId[p.label] = p.id
    end
    for _, p in ipairs(colPets) do
        B.petById[p.id] = p
        table.insert(colOpt, p.label); colLabelToId[p.label] = p.id
    end

    lvlDropdown.Update(lvlOpt)
    spdDropdown.Update(spdOpt)
    tgtDropdown.Update(tgtOpt)
    colDropdown.Update(colOpt)
end)

CreateButton(ScrollingAuto, "Clear All Selection", function()
    if B.isRunning then warn("[Clear] Stop dulu."); return end
    B.levelingPets, B.speedupPets, B.targetPets, B.collectPets = {}, {}, {}, {}
    lvlDropdown.Update({}); spdDropdown.Update({}); tgtDropdown.Update({}); colDropdown.Update({})
end)

CreateToggle("Auto PetToy", false, ScrollingAuto, function(s) B.useAutoPetToy = s end)
CreateToggle("Auto Cookie", false, ScrollingAuto, function(s) B.useAutoCookie = s end)

-- SHOP TAB
CreateToggle("Auto Buy Gear", false, ScrollingShop, function(state)
    S.gOn = state
    S.nextGear = 0
end)
CreateToggle("Auto Buy Bait", false, ScrollingShop, function(state)
    S.bOn = state
    S.nextBait = 0
end)
CreateToggle("Auto Buy Egg", false, ScrollingShop, function(state)
    S.eOn = state
    S.nextEgg = 0
end)
CreateToggle("Auto Buy Golden Merchant", false, ScrollingShop, function(state)
    S.gdOn = state
    S.nextGolden = 0
end)

-- GEAR TAB
CreateToggle("Auto Craft (TimeJumper Only)", false, ScrollingGear, function(state)
    BCONFIG.CraftOn = state
    S._nextCraftTry = 0
    if not BCONFIG.CraftOn then S.cPhase = "idle" S.cCd = 0 end
end)
CreateToggle("Auto Place Food (Supreme/Advanced/Basic)", false, ScrollingGear, function(state)
    BCONFIG.FoodOn = state
    S.nextPlace = 0
end)

-- EVENT TAB
CreateToggle("Auto Collect Halloween Fish", false, ScrollingEvent, function(state)
    S.hwCollect = state
    if state then startHWCollect() else stopHWCollect() end
end)
CreateToggle("Auto Feed & Pickup Halloween", false, ScrollingEvent, function(state)
    S.hwFeedPickup = state
    if state then startHWFeedPickup() else stopHWFeedPickup() end
end)

-- BOOST TAB
CreateToggle("Super FPS Boost", false, ScrollingBoost, function(v)
    task.spawn(function()
        if v and not FPS_STATE.boosted then boostFPS()
        elseif not v and FPS_STATE.boosted then unboostFPS() end
    end)
end)

CreateToggle("Hide Fish", false, ScrollingBoost, function(v)
    task.spawn(function()
        if v and not FPS_STATE.fishHidden then hideFish()
        elseif not v and FPS_STATE.fishHidden then showFish() end
    end)
end)

local WebhookFrame = Instance.new("Frame")
WebhookFrame.Size = UDim2.new(1, 0, 0, 65)
WebhookFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
WebhookFrame.ClipsDescendants = true
WebhookFrame.Parent = ScrollingBoost
Instance.new("UICorner", WebhookFrame).CornerRadius = UDim.new(0, 6)

local WebhookTitle = Instance.new("TextLabel")
WebhookTitle.Size = UDim2.new(1, -20, 0, 25)
WebhookTitle.Position = UDim2.new(0, 10, 0, 5)
WebhookTitle.BackgroundTransparency = 1
WebhookTitle.Text = "🔗 Discord Webhook URL (Khusus Mutasi)"
WebhookTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
WebhookTitle.TextXAlignment = Enum.TextXAlignment.Left
WebhookTitle.Font = Enum.Font.GothamBold
WebhookTitle.TextSize = 12
WebhookTitle.Parent = WebhookFrame

local WebhookInput = Instance.new("TextBox")
WebhookInput.Size = UDim2.new(1, -20, 0, 28)
WebhookInput.Position = UDim2.new(0, 10, 0, 30)
WebhookInput.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
WebhookInput.Text = WEBHOOK.url
WebhookInput.PlaceholderText = "https://discord.com/api/webhooks/..."
WebhookInput.TextColor3 = Color3.fromRGB(255, 255, 255)
WebhookInput.Font = Enum.Font.Gotham
WebhookInput.TextSize = 12
WebhookInput.TextXAlignment = Enum.TextXAlignment.Left
WebhookInput.ClearTextOnFocus = false
WebhookInput.ClipsDescendants = true
WebhookInput.Parent = WebhookFrame
Instance.new("UICorner", WebhookInput).CornerRadius = UDim.new(0, 4)

WebhookInput.FocusLost:Connect(function()
    WEBHOOK.url = WebhookInput.Text
    if WebhookInput.Text:find("https://discord.com/api/webhooks/") then
        print("[Webhook] ✅ URL Valid disimpan.")
    else
        warn("[Webhook] ❌ URL tidak valid! Pastikan link Discord Webhook.")
    end
end)

CreateToggle("Aktifkan Webhook", true, ScrollingBoost, function(v) WEBHOOK.enabled = v end)
CreateToggle("Notif TimeJumper Habis", true, ScrollingBoost, function(v) WEBHOOK.notifyJumperEmpty = v end)

CreateButton(ScrollingBoost, "🧪 Test Webhook", function()
    WEBHOOK.url = WebhookInput.Text
    if WEBHOOK.url == "" then warn("[Webhook] URL kosong. Paste link dulu di kotak atas."); return end
    local embed = {
        title = "🧪 Test Webhook Berhasil",
        description = "Koneksi dari Farm A fish berjalan dengan baik!",
        color = 0x00FF00,
        fields = {
            { name = "👤 Player", value = tostring(getPlayerDisplayName()), inline = true },
            { name = "⏱️ TimeJumper Sisa", value = tostring(getJumperCount()), inline = true },
        },
        footer = { text = "Farm A fish | by bang iqi" },
        timestamp = DateTime.now():ToIsoDate(),
    }
    sendWebhook({ username = WEBHOOK.username, embeds = { embed } })
end)

-- ============================================================
-- FITUR AUTO FARM (LANGSUNG DI DALAM TAB ⚡ AUTO)
-- ============================================================
local AutoFarmRunning = false
local AutoFarmFeederRunning = false
local AutoFarmThread, AutoFarmFeederThread = nil, nil

-- Ambil Remote untuk Auto Farm
local ReplicatedStorageFarm = game:GetService("ReplicatedStorage")
local getPlayerDataByIdFarm = require(ReplicatedStorageFarm.TS.state["player-data"]).getPlayerDataById
local remoFarm = ReplicatedStorageFarm.rbxts_include.node_modules["@rbxts"].remo.src.container
local collectAllFishRemote = remoFarm:WaitForChild("bait.collectAllFish")
local sellRemote = remoFarm:WaitForChild("sellFish.sellAllFish")
local placeRemote = remoFarm:WaitForChild("ponds.placeBuilding")
local SwitchPetLoadout = remoFarm:WaitForChild("pets.switchPetLoadout")

-- 1. TOGGLE COLLECT + SELL
-- ============================================================
-- TOGGLE 1: AUTO COLLECT
-- ============================================================
local AutoCollectRunning = false

CreateToggle("Auto Collect Ikan", false, ScrollingNewAuto, function(state)
    AutoCollectRunning = state
    if AutoCollectRunning then
        task.spawn(function()
            while AutoCollectRunning do
                local ok, data = pcall(getPlayerDataByIdFarm, tostring(player.UserId))
                if ok and data and data.ponds and data.ponds[data.currentPond] and data.ponds[data.currentPond].baits then
                    local pondBaits = data.ponds[data.currentPond].baits
                    
                    for uid, _ in pairs(pondBaits) do
                        if not AutoCollectRunning then break end
                        pcall(collectAllFishRemote.FireServer, collectAllFishRemote, uid)
                        task.wait(0.05) -- Jeda super singkat per ikan
                    end
                end
                task.wait(0.1) -- Jeda cek kolam
            end
        end)
        print("[Auto Farm] Auto Collect Dinyalakan")
    else
        print("[Auto Farm] Auto Collect Dimatikan")
    end
end)

-- ============================================================
-- TOGGLE 2: AUTO SELL
-- ============================================================
local AutoSellRunning = false
local SellInterval = 3 -- ✅ Dikunci otomatis 3 detik

CreateToggle("Auto Sell Ikan", false, ScrollingNewAuto, function(state)
    AutoSellRunning = state
    if AutoSellRunning then
        task.spawn(function()
            while AutoSellRunning do
                task.wait(SellInterval) -- Nunggu 3 detik
                
                if AutoSellRunning then
                    pcall(sellRemote.FireServer, sellRemote)
                    print("[Auto Farm] Menjual semua ikan di inventory.")
                end
            end
        end)
        print("[Auto Farm] Auto Sell Dinyalakan")
    else
        print("[Auto Farm] Auto Sell Dimatikan")
    end
end)

-- 2. INTERVAL & DELAY FEEDER
local AutoFarmInterval = 300
local AutoFarmDelay = 0

CreateInput("Interval Feeder (s)", "300", ScrollingNewAuto, function(text)
    local n = tonumber(text)
    if n then AutoFarmInterval = n end
end)

-- 3. FUNGSI DROPDOWN KHUSUS FEEDER (KOTAK INPUT DI DALAM DROPDOWN)
-- Feeder dropdown (ANTI-SCROLL-CLICK)
local FeederInputValues = {}
local function CreateFeederDropdown(parent, feedersList)
    DropdownOrder += 1
    local baseZ = 20 + DropdownOrder * 10

    local Container = Instance.new("Frame")
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundColor3 = THEME.panelAlt
    Container.ClipsDescendants = true
    Container.ZIndex = baseZ
    Container.LayoutOrder = DropdownOrder
    Container.Parent = parent
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Header = Instance.new("TextButton")
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = baseZ + 1
    Header.Parent = Container

    local HeaderLabel = Instance.new("TextLabel")
    HeaderLabel.Size = UDim2.new(1, -50, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 12, 0, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = "⚙️ Pengaturan Feeder"
    HeaderLabel.TextColor3 = THEME.text
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Font = Enum.Font.GothamMedium
    HeaderLabel.TextSize = 13
    HeaderLabel.ZIndex = baseZ + 2
    HeaderLabel.Parent = Header

    local Arrow = Instance.new("TextLabel")
    Arrow.Size = UDim2.new(0, 26, 1, 0)
    Arrow.Position = UDim2.new(1, -32, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = THEME.textDim
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 12
    Arrow.ZIndex = baseZ + 2
    Arrow.Parent = Header

    local Body = Instance.new("Frame")
    Body.Size = UDim2.new(1, 0, 0, 0)
    Body.Position = UDim2.new(0, 0, 0, 42)
    Body.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    Body.BorderSizePixel = 0
    Body.ClipsDescendants = true
    Body.Visible = false
    Body.ZIndex = baseZ + 1
    Body.Parent = Container
    Instance.new("UICorner", Body).CornerRadius = UDim.new(0, 6)

    local LIST_HEIGHT = 230
    local TOP_OFFSET = 4

    local ListFrame = Instance.new("ScrollingFrame")
    ListFrame.Size = UDim2.new(1, -8, 0, LIST_HEIGHT)
    ListFrame.Position = UDim2.new(0, 4, 0, TOP_OFFSET)
    ListFrame.BackgroundTransparency = 1
    ListFrame.BorderSizePixel = 0
    ListFrame.ScrollBarThickness = 5
    ListFrame.ScrollBarImageColor3 = THEME.accentDim
    ListFrame.ElasticBehavior = Enum.ElasticBehavior.Never
    ListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    ListFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ListFrame.ScrollingDirection = Enum.ScrollingDirection.Y
    ListFrame.ZIndex = baseZ + 2
    ListFrame.Parent = Body

    local LL = Instance.new("UIListLayout", ListFrame)
    LL.Padding = UDim.new(0, 4)
    LL.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", ListFrame).PaddingTop = UDim.new(0, 4)
    Instance.new("UIPadding", ListFrame).PaddingBottom = UDim.new(0, 4)
    Instance.new("UIPadding", ListFrame).PaddingLeft = UDim.new(0, 4)
    Instance.new("UIPadding", ListFrame).PaddingRight = UDim.new(0, 4)

    local isOpen = false
    local self = {
        Frame = Container,
        Close = function()
            isOpen = false
            Body.Visible = false
            Body.Size = UDim2.new(1, 0, 0, 0)
            Container.Size = UDim2.new(1, 0, 0, 42)
            Arrow.Text = "▼"
        end,
    }
    table.insert(ALL_DROPDOWNS, self)

    local checkHeader = makeAntiScrollClick(Header, nil)
    Header.MouseButton1Click:Connect(function()
        if not checkHeader() then return end
        isOpen = not isOpen
        if isOpen then
            for _, dd in ipairs(ALL_DROPDOWNS) do
                if dd ~= self then dd.Close() end
            end
            Body.Visible = true
            local totalH = TOP_OFFSET + LIST_HEIGHT + 8
            Body.Size = UDim2.new(1, 0, 0, totalH)
            Container.Size = UDim2.new(1, 0, 0, 42 + totalH)
            Arrow.Text = "▲"
        else
            self.Close()
        end
    end)

    for i, fName in ipairs(feedersList) do
        FeederInputValues[fName] = 0

        local row = Instance.new("Frame")
        row.Size = UDim2.new(1, 0, 0, 30)
        row.BackgroundColor3 = (i % 2 == 0) and Color3.fromRGB(34, 37, 46) or Color3.fromRGB(28, 30, 38)
        row.BorderSizePixel = 0
        row.LayoutOrder = i
        row.ZIndex = baseZ + 2
        row.Parent = ListFrame
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

        local nameLbl = Instance.new("TextLabel")
        nameLbl.Size = UDim2.new(1, -70, 1, 0)
        nameLbl.Position = UDim2.new(0, 10, 0, 0)
        nameLbl.BackgroundTransparency = 1
        nameLbl.Text = fName
        nameLbl.TextColor3 = THEME.text
        nameLbl.Font = Enum.Font.Gotham
        nameLbl.TextSize = 12
        nameLbl.TextXAlignment = Enum.TextXAlignment.Left
        nameLbl.ZIndex = baseZ + 3
        nameLbl.Parent = row

        local cntBox = Instance.new("TextBox")
        cntBox.Size = UDim2.new(0, 50, 0, 22)
        cntBox.Position = UDim2.new(1, -58, 0.5, -11)
        cntBox.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
        cntBox.BorderSizePixel = 0
        cntBox.Text = "0"
        cntBox.TextColor3 = THEME.accent
        cntBox.Font = Enum.Font.Code
        cntBox.TextSize = 12
        cntBox.ClearTextOnFocus = false
        cntBox.ZIndex = baseZ + 3
        cntBox.Parent = row
        Instance.new("UICorner", cntBox).CornerRadius = UDim.new(0, 4)

        cntBox.FocusLost:Connect(function()
            local n = tonumber(cntBox.Text) or 0
            n = math.max(0, math.floor(n))
            FeederInputValues[fName] = n
            cntBox.Text = tostring(n)
        end)
    end
end

local Feeders = {"BasicAutoFeeder","AdvancedAutoFeeder","SupremeAutoFeeder","ExtremeAutoFeeder","GodlyAutoFeeder","GoldenAutoFeeder"}
CreateFeederDropdown(ScrollingNewAuto, Feeders)

-- 4. TOGGLE AUTO FEEDER
-- 4. TOGGLE AUTO FEEDER
CreateToggle("Auto Place Feeders", false, ScrollingNewAuto, function(state)
    AutoFarmFeederRunning = state
    if AutoFarmFeederRunning then
        AutoFarmFeederThread = task.spawn(function()
            while AutoFarmFeederRunning do
                local totalAll = 0
                for _, fName in ipairs(Feeders) do
                    totalAll += (FeederInputValues[fName] or 0)
                end

                if totalAll > 0 then
                    SwitchPetLoadout:InvokeServer(1)
                    task.wait(0.5)
                    
                    for _, fName in ipairs(Feeders) do
                        local n = FeederInputValues[fName] or 0
                        if n > 0 then
                            print("Menaruh " .. fName .. " sebanyak " .. n)
                            for i = 1, n do
                                if not AutoFarmFeederRunning then break end
                                placeRemote:InvokeServer("booster", fName, Vector3.new(24.86, -0.01, -23))
                                task.wait(0) -- ✅ Delay Feeder dikunci 0
                            end
                        end
                    end
                    
                    SwitchPetLoadout:InvokeServer(0)
                else
                    print("[Auto Feeder] Total feeder 0, isi dulu inputannya!")
                end

                local waited = 0
                while waited < AutoFarmInterval and AutoFarmFeederRunning do
                    task.wait(1)
                    waited += 1
                end
            end
        end)
        print("[Auto Farm] Feeder Dinyalakan")
    else
        if AutoFarmFeederThread then pcall(task.cancel, AutoFarmFeederThread) end
        print("[Auto Farm] Feeder Dimatikan")
    end
end)

-- ============================================================
-- FITUR BAIT SCANNER (TOGGLE DI LUAR + LIST DI DALAM DROPDOWN)
-- ============================================================
local function CreateBaitScannerUI(parentFrame)
    local RS = game:GetService("ReplicatedStorage")
    local Players = game:GetService("Players")
    local getPlayerDataById = require(RS.TS.state["player-data"]).getPlayerDataById
    local gearUseFishFeeder = RS.rbxts_include.node_modules["@rbxts"].remo.src.container:WaitForChild("gear.useFishFeeder")

    local SCOOP_ITEM = "GoldenFoodScoop"
    local DEFAULT_DELAY = 0.1
    local BAIT_CAPACITY = 10

    local scanned, queue, active, threads = {}, {}, {}, {}
    local sent, failed, skipped = 0, 0, 0
    local autoScan, query = true, ""
    local delay = DEFAULT_DELAY
    local scanThread = nil
    local rowCache = {}
    local isScoopRunning = false

    local function baitName(b)
        if type(b) ~= "table" then return "?" end
        if type(b.bait) == "table" and type(b.bait.baitType) == "string" then return b.bait.baitType end
        for _, k in ipairs({"baitType","type","baitId","id","name"}) do
            if type(b[k]) == "string" then return b[k] end
        end
        return "?"
    end

    local function getCurrentAmount(b)
        if type(b) ~= "table" then return 0 end
        if type(b.fishes) == "table" then
            local n = 0
            for _ in pairs(b.fishes) do n = n + 1 end
            return n
        end
        if type(b.bait) == "table" and type(b.bait.amount) == "number" then return b.bait.amount end
        return 0
    end

    local function isBaitFull(b)
        return getCurrentAmount(b) >= BAIT_CAPACITY
    end

    local function scan()
        local out = {}
        for _, p in ipairs(Players:GetPlayers()) do
            local ok, d = pcall(getPlayerDataById, tostring(p.UserId))
            if ok and d and d.ponds then
                local pond = d.ponds[d.currentPond]
                if pond and pond.baits then
                    local list = {}
                    for uid, b in pairs(pond.baits) do
                        local cur = getCurrentAmount(b)
                        table.insert(list, {
                            uid = tostring(uid),
                            type = baitName(b),
                            amount = cur,
                            maxAmount = BAIT_CAPACITY,
                            isFull = (cur >= BAIT_CAPACITY),
                            owner = p.Name,
                            pond = tostring(d.currentPond),
                        })
                    end
                    out[p.Name] = { pond = tostring(d.currentPond), baits = list }
                end
            end
        end
        return out
    end

    local function countTable(t)
        local n = 0
        for _ in pairs(t) do n = n + 1 end
        return n
    end

    -- ====================== TOGGLE AUTO SCOOP ======================
    local scoopToggleFrame = Instance.new("Frame", parentFrame)
    scoopToggleFrame.Size = UDim2.new(1, 0, 0, 42)
    scoopToggleFrame.BackgroundColor3 = THEME.panelAlt
    scoopToggleFrame.BorderSizePixel = 0
    scoopToggleFrame.Parent = parentFrame
    Instance.new("UICorner", scoopToggleFrame).CornerRadius = UDim.new(0, 6)

    local scoopBtn = Instance.new("TextButton", scoopToggleFrame)
    scoopBtn.Size = UDim2.new(1, 0, 1, 0)
    scoopBtn.BackgroundTransparency = 1
    scoopBtn.Text = ""
    scoopBtn.AutoButtonColor = false
    scoopBtn.Parent = scoopToggleFrame

    local scoopLabel = Instance.new("TextLabel", scoopBtn)
    scoopLabel.Size = UDim2.new(1, -70, 1, 0)
    scoopLabel.Position = UDim2.new(0, 12, 0, 0)
    scoopLabel.BackgroundTransparency = 1
    scoopLabel.Text = "Auto Scoop (Ambil Ikan)"
    scoopLabel.TextColor3 = THEME.text
    scoopLabel.TextXAlignment = Enum.TextXAlignment.Left
    scoopLabel.Font = Enum.Font.Gotham
    scoopLabel.TextSize = 13
    scoopLabel.Parent = scoopBtn

    local scoopInd = Instance.new("Frame", scoopBtn)
    scoopInd.Size = UDim2.new(0, 38, 0, 22)
    scoopInd.Position = UDim2.new(1, -50, 0.5, -11)
    scoopInd.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
    scoopInd.Parent = scoopBtn
    Instance.new("UICorner", scoopInd).CornerRadius = UDim.new(1, 0)

    local scoopCircle = Instance.new("Frame", scoopInd)
    scoopCircle.Size = UDim2.new(0, 16, 0, 16)
    scoopCircle.Position = UDim2.new(0, 3, 0.5, -8)
    scoopCircle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    scoopCircle.Parent = scoopInd
    Instance.new("UICorner", scoopCircle).CornerRadius = UDim.new(1, 0)

    -- ====================== DROPDOWN BAIT SCANNER ======================
    local Container = Instance.new("Frame", parentFrame)
    Container.Size = UDim2.new(1, 0, 0, 42)
    Container.BackgroundColor3 = THEME.panelAlt
    Container.ClipsDescendants = true  -- ✅ HARUS true
    Container.ZIndex = 15
    Container.Parent = parentFrame
    Instance.new("UICorner", Container).CornerRadius = UDim.new(0, 6)

    local Header = Instance.new("TextButton", Container)
    Header.Size = UDim2.new(1, 0, 0, 42)
    Header.BackgroundTransparency = 1
    Header.Text = ""
    Header.AutoButtonColor = false
    Header.ZIndex = 16
    Header.Parent = Container

    local HeaderLabel = Instance.new("TextLabel", Header)
    HeaderLabel.Size = UDim2.new(1, -50, 1, 0)
    HeaderLabel.Position = UDim2.new(0, 12, 0, 0)
    HeaderLabel.BackgroundTransparency = 1
    HeaderLabel.Text = "🎣 Bait Scanner (List Ikan)"
    HeaderLabel.TextColor3 = THEME.text
    HeaderLabel.TextXAlignment = Enum.TextXAlignment.Left
    HeaderLabel.Font = Enum.Font.GothamBold
    HeaderLabel.TextSize = 13
    HeaderLabel.ZIndex = 17
    HeaderLabel.Parent = Header

    local Arrow = Instance.new("TextLabel", Header)
    Arrow.Size = UDim2.new(0, 26, 1, 0)
    Arrow.Position = UDim2.new(1, -32, 0, 0)
    Arrow.BackgroundTransparency = 1
    Arrow.Text = "▼"
    Arrow.TextColor3 = THEME.textDim
    Arrow.Font = Enum.Font.GothamBold
    Arrow.TextSize = 12
    Arrow.ZIndex = 17
    Arrow.Parent = Header

    local ListWrapper = Instance.new("Frame", Container)
    ListWrapper.Size = UDim2.new(1, 0, 0, 0)
    ListWrapper.Position = UDim2.new(0, 0, 0, 42)  -- ✅ Position: nempel di bawah header
    ListWrapper.BackgroundColor3 = Color3.fromRGB(24, 26, 32)
    ListWrapper.BorderSizePixel = 0
    ListWrapper.ClipsDescendants = true
    ListWrapper.Visible = false
    ListWrapper.ZIndex = 20
    ListWrapper.Parent = Container
    Instance.new("UICorner", ListWrapper).CornerRadius = UDim.new(0, 6)
    local lwStroke = Instance.new("UIStroke", ListWrapper)
    lwStroke.Color = THEME.border
    lwStroke.Thickness = 1

    local main = Instance.new("Frame", ListWrapper)
    main.Size = UDim2.new(1, -8, 0, 360)
    main.Position = UDim2.new(0, 4, 0, 4)
    main.BackgroundColor3 = Color3.fromRGB(20, 22, 28)
    main.BorderSizePixel = 0
    main.ZIndex = 21
    main.Parent = ListWrapper
    Instance.new("UICorner", main).CornerRadius = UDim.new(0, 6)

    local search = Instance.new("TextBox", main)
    search.Size = UDim2.new(1, -122, 0, 24)
    search.Position = UDim2.new(0, 8, 0, 8)
    search.BackgroundColor3 = Color3.fromRGB(34, 37, 46)
    search.BorderSizePixel = 0
    search.PlaceholderText = "🔎 Cari nama bait / pemain..."
    search.TextColor3 = THEME.text
    search.PlaceholderColor3 = THEME.textDim
    search.Font = Enum.Font.Gotham
    search.TextSize = 11
    search.TextXAlignment = Enum.TextXAlignment.Left
    search.ClearTextOnFocus = false
    search.ZIndex = 22
    Instance.new("UICorner", search).CornerRadius = UDim.new(0, 4)
    Instance.new("UIPadding", search).PaddingLeft = UDim.new(0, 8)

    local btnScan = Instance.new("TextButton", main)
    btnScan.Size = UDim2.new(0, 50, 0, 24)
    btnScan.Position = UDim2.new(1, -110, 0, 8)
    btnScan.BackgroundColor3 = THEME.accentDim
    btnScan.Text = "🔄 Scan"
    btnScan.TextColor3 = THEME.text
    btnScan.Font = Enum.Font.GothamBold
    btnScan.TextSize = 10
    btnScan.AutoButtonColor = false
    btnScan.ZIndex = 22
    Instance.new("UICorner", btnScan).CornerRadius = UDim.new(0, 4)

    local btnAutoScan = Instance.new("TextButton", main)
    btnAutoScan.Size = UDim2.new(0, 48, 0, 24)
    btnAutoScan.Position = UDim2.new(1, -56, 0, 8)
    btnAutoScan.BackgroundColor3 = THEME.success
    btnAutoScan.Text = "⚡ ON"
    btnAutoScan.TextColor3 = THEME.text
    btnAutoScan.Font = Enum.Font.GothamBold
    btnAutoScan.TextSize = 10
    btnAutoScan.AutoButtonColor = false
    btnAutoScan.ZIndex = 22
    Instance.new("UICorner", btnAutoScan).CornerRadius = UDim.new(0, 4)

    local lblDelay = Instance.new("TextLabel", main)
    lblDelay.Size = UDim2.new(0, 40, 0, 24)
    lblDelay.Position = UDim2.new(0, 8, 0, 38)
    lblDelay.BackgroundTransparency = 1
    lblDelay.Text = "Delay:"
    lblDelay.TextColor3 = THEME.textDim
    lblDelay.Font = Enum.Font.GothamBold
    lblDelay.TextSize = 10
    lblDelay.TextXAlignment = Enum.TextXAlignment.Left
    lblDelay.ZIndex = 22

    local boxDelay = Instance.new("TextBox", main)
    boxDelay.Size = UDim2.new(0, 40, 0, 24)
    boxDelay.Position = UDim2.new(0, 48, 0, 38)
    boxDelay.BackgroundColor3 = Color3.fromRGB(34, 37, 46)
    boxDelay.BorderSizePixel = 0
    boxDelay.Text = "0.1"
    boxDelay.TextColor3 = THEME.text
    boxDelay.Font = Enum.Font.Code
    boxDelay.TextSize = 11
    boxDelay.ClearTextOnFocus = false
    boxDelay.ZIndex = 22
    Instance.new("UICorner", boxDelay).CornerRadius = UDim.new(0, 4)

    local queueLbl = Instance.new("TextLabel", main)
    queueLbl.Size = UDim2.new(0, 160, 0, 24)
    queueLbl.Position = UDim2.new(0, 96, 0, 38)
    queueLbl.BackgroundTransparency = 1
    queueLbl.Text = "Q:0 A:0 S:0 Sk:0"
    queueLbl.TextColor3 = THEME.textDim
    queueLbl.Font = Enum.Font.Code
    queueLbl.TextSize = 10
    queueLbl.TextXAlignment = Enum.TextXAlignment.Left
    queueLbl.ZIndex = 22

    local btnClear = Instance.new("TextButton", main)
    btnClear.Size = UDim2.new(0, 40, 0, 24)
    btnClear.Position = UDim2.new(1, -48, 0, 38)
    btnClear.BackgroundColor3 = Color3.fromRGB(34, 37, 46)
    btnClear.Text = "🧹"
    btnClear.TextColor3 = THEME.text
    btnClear.Font = Enum.Font.GothamBold
    btnClear.TextSize = 11
    btnClear.AutoButtonColor = false
    btnClear.ZIndex = 22
    Instance.new("UICorner", btnClear).CornerRadius = UDim.new(0, 4)

    local list = Instance.new("ScrollingFrame", main)
    list.Size = UDim2.new(1, -16, 0, 260)
    list.Position = UDim2.new(0, 8, 0, 70)
    list.BackgroundColor3 = Color3.fromRGB(34, 37, 46)
    list.BorderSizePixel = 0
    list.ScrollBarThickness = 4
    list.ScrollBarImageColor3 = THEME.accentDim
    list.ElasticBehavior = Enum.ElasticBehavior.Never
    list.CanvasSize = UDim2.new(0, 0, 0, 0)
    list.AutomaticCanvasSize = Enum.AutomaticSize.Y
    list.ScrollingDirection = Enum.ScrollingDirection.Y
    list.ZIndex = 22
    Instance.new("UICorner", list).CornerRadius = UDim.new(0, 5)
    local listLayout = Instance.new("UIListLayout", list)
    listLayout.Padding = UDim.new(0, 2)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    Instance.new("UIPadding", list).PaddingTop = UDim.new(0, 4)
    Instance.new("UIPadding", list).PaddingBottom = UDim.new(0, 4)
    Instance.new("UIPadding", list).PaddingLeft = UDim.new(0, 4)
    Instance.new("UIPadding", list).PaddingRight = UDim.new(0, 4)

    local status = Instance.new("TextLabel", main)
    status.Size = UDim2.new(1, -16, 0, 18)
    status.Position = UDim2.new(0, 8, 1, -22)
    status.BackgroundTransparency = 1
    status.Text = "Ready."
    status.TextColor3 = THEME.textDim
    status.Font = Enum.Font.Gotham
    status.TextSize = 10
    status.TextXAlignment = Enum.TextXAlignment.Left
    status.ZIndex = 22

    -- Header toggle
        -- Header toggle
    local isOpen = false
    local self = {
        Frame = Container,
        Close = function()
            isOpen = false
            ListWrapper.Visible = false
            ListWrapper.Size = UDim2.new(1, 0, 0, 0)
            Container.Size = UDim2.new(1, 0, 0, 42)
            Arrow.Text = "▼"
        end,
    }
    table.insert(ALL_DROPDOWNS, self)

    local checkHeader = makeAntiScrollClick(Header, nil)
    Header.MouseButton1Click:Connect(function()
        if not checkHeader() then return end
        isOpen = not isOpen
        if isOpen then
            for _, dd in ipairs(ALL_DROPDOWNS) do
                if dd ~= self then dd.Close() end
            end
            ListWrapper.Visible = true
            local totalH = 372
            ListWrapper.Size = UDim2.new(1, 0, 0, totalH)
            Container.Size = UDim2.new(1, 0, 0, 42 + totalH)
            Arrow.Text = "▲"
        else
            self.Close()  -- ✅ pakai fungsi Close biar konsisten
        end
    end)

    -- Logika scoop
    local function stopUID(uid)
        active[uid] = nil
        if threads[uid] then pcall(task.cancel, threads[uid]); threads[uid] = nil end
    end

    local function startUID(uid)
        if active[uid] or not queue[uid] then return end
        active[uid] = true
        threads[uid] = task.spawn(function()
            while active[uid] and queue[uid] and isScoopRunning and main.Parent do
                local ok, d = pcall(getPlayerDataById, tostring(player.UserId))
                if ok and d and d.ponds and d.ponds[d.currentPond] and d.ponds[d.currentPond].baits and d.ponds[d.currentPond].baits[uid] then
                    local b = d.ponds[d.currentPond].baits[uid]
                    if not isBaitFull(b) then
                        pcall(function() gearUseFishFeeder:FireServer(SCOOP_ITEM, uid, 1) end)
                        sent = sent + 1
                    else
                        skipped = skipped + 1
                    end
                else
                    skipped = skipped + 1
                end
                queueLbl.Text = string.format("Q:%d A:%d S:%d Sk:%d", countTable(queue), countTable(active), sent, skipped)
                task.wait(delay)
            end
            active[uid] = nil; threads[uid] = nil
        end)
    end

    local function stopAll()
        for uid in pairs(active) do stopUID(uid) end
    end

    -- Toggle scoop (anti double click)
    local checkScoop = makeAntiScrollClick(scoopBtn, nil)
    scoopBtn.MouseButton1Click:Connect(function()
        if not checkScoop() then return end
        isScoopRunning = not isScoopRunning
        if isScoopRunning then
            scoopInd.BackgroundColor3 = THEME.accent
            scoopCircle.Position = UDim2.new(1, -18, 0.5, -8)
            for uid in pairs(queue) do startUID(uid) end
            status.Text = "Auto Scoop: ON"
        else
            scoopInd.BackgroundColor3 = Color3.fromRGB(70, 70, 80)
            scoopCircle.Position = UDim2.new(0, 3, 0.5, -8)
            stopAll()
            status.Text = "Auto Scoop: OFF"
        end
    end)
    
    local updateRowState
    local function createRow(order, name, b)
        local row = Instance.new("Frame", list)
        row.Size = UDim2.new(1, 0, 0, 28)
        row.BackgroundColor3 = Color3.fromRGB(42, 46, 56)
        row.BorderSizePixel = 0
        row.LayoutOrder = order
        row.Active = true
        row.ZIndex = 23
        Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

        local ind = Instance.new("Frame", row)
        ind.Size = UDim2.new(0, 3, 1, 0)
        ind.BackgroundColor3 = THEME.accent
        ind.BorderSizePixel = 0
        ind.Visible = false
        ind.ZIndex = 24
        Instance.new("UICorner", ind).CornerRadius = UDim.new(0, 3)

        local btn = Instance.new("TextButton", row)
        btn.Size = UDim2.new(1, 0, 1, 0)
        btn.BackgroundTransparency = 1
        btn.Text = ""
        btn.ZIndex = 30
        btn.AutoButtonColor = false

        local n1 = Instance.new("TextLabel", row)
        n1.Size = UDim2.new(0, 90, 1, 0)
        n1.Position = UDim2.new(0, 8, 0, 0)
        n1.BackgroundTransparency = 1
        n1.Text = name
        n1.TextColor3 = THEME.accent
        n1.Font = Enum.Font.GothamBold
        n1.TextSize = 10
        n1.TextXAlignment = Enum.TextXAlignment.Left
        n1.TextTruncate = Enum.TextTruncate.AtEnd
        n1.ZIndex = 25

        local n2 = Instance.new("TextLabel", row)
        n2.Size = UDim2.new(0, 100, 1, 0)
        n2.Position = UDim2.new(0, 100, 0, 0)
        n2.BackgroundTransparency = 1
        n2.Text = b.type
        n2.TextColor3 = THEME.text
        n2.Font = Enum.Font.GothamMedium
        n2.TextSize = 10
        n2.TextXAlignment = Enum.TextXAlignment.Left
        n2.TextTruncate = Enum.TextTruncate.AtEnd
        n2.ZIndex = 25

        local n3 = Instance.new("TextLabel", row)
        n3.Size = UDim2.new(0, 80, 1, 0)
        n3.Position = UDim2.new(0, 202, 0, 0)
        n3.BackgroundTransparency = 1
        n3.Text = b.uid:sub(1, 8)
        n3.TextColor3 = THEME.textDim
        n3.Font = Enum.Font.Code
        n3.TextSize = 9
        n3.TextXAlignment = Enum.TextXAlignment.Left
        n3.ZIndex = 25

        local n4 = Instance.new("TextLabel", row)
        n4.Size = UDim2.new(0, 50, 1, 0)
        n4.Position = UDim2.new(1, -90, 0, 0)
        n4.BackgroundTransparency = 1
        n4.Text = ""
        n4.TextColor3 = THEME.textDim
        n4.Font = Enum.Font.Code
        n4.TextSize = 9
        n4.ZIndex = 25

        local st = Instance.new("TextLabel", row)
        st.Size = UDim2.new(0, 40, 1, 0)
        st.Position = UDim2.new(1, -40, 0, 0)
        st.BackgroundTransparency = 1
        st.Text = ""
        st.Font = Enum.Font.GothamBold
        st.TextSize = 11
        st.TextXAlignment = Enum.TextXAlignment.Right
        st.ZIndex = 25

        -- 🔥 ANTI-SCROLL-CLICK untuk row 🔥
        local checkRow = makeAntiScrollClick(btn, list)
        btn.MouseButton1Click:Connect(function()
            if not checkRow() then return end
            if queue[b.uid] then
                stopUID(b.uid)
                queue[b.uid] = nil
            else
                queue[b.uid] = { uid = b.uid, owner = name }
                if isScoopRunning then startUID(b.uid) end
            end
            updateRowState(b.uid)
            queueLbl.Text = string.format("Q:%d A:%d S:%d Sk:%d", countTable(queue), countTable(active), sent, skipped)
        end)

        return { row = row, ind = ind, btn = btn, n1 = n1, n2 = n2, n3 = n3, n4 = n4, st = st }
    end

        updateRowState = function(uid)
        local cache = rowCache[uid]
        if not cache then return end
        local b = nil
        for _, info in pairs(scanned) do
            for _, bait in ipairs(info.baits) do
                if bait.uid == uid then b = bait; break end
            end
            if b then break end
        end
        cache.row.BackgroundColor3 = Color3.fromRGB(42, 46, 56)
        cache.ind.Visible = false
        cache.st.Text = ""
        if not b then return end
        cache.n4.Text = tostring(b.amount) .. "/" .. tostring(b.maxAmount)
        cache.n4.TextColor3 = b.isFull and Color3.fromRGB(255, 180, 80) or THEME.textDim
        if b.isFull then
            cache.ind.BackgroundColor3 = Color3.fromRGB(255, 180, 80)
            cache.ind.Visible = true
            cache.st.Text = "FULL"
            cache.st.TextColor3 = Color3.fromRGB(255, 180, 80)
            cache.st.TextSize = 9
        end
        if active[uid] then
            cache.ind.BackgroundColor3 = THEME.success
            cache.ind.Visible = true
            cache.st.Text = "▶"
            cache.st.TextColor3 = THEME.success
        elseif queue[uid] then
            cache.ind.BackgroundColor3 = Color3.fromRGB(180, 130, 240)
            cache.ind.Visible = true
            cache.st.Text = "✓"
            cache.st.TextColor3 = Color3.fromRGB(180, 130, 240)
        end
    end

    local function render()
        local q = string.lower(query)
        local order = 0
        local seen = {}
        local total, players = 0, 0
        local names = {}
        for n in pairs(scanned) do table.insert(names, n) end
        table.sort(names)
        for _, name in ipairs(names) do
            local info = scanned[name]
            local shown = 0
            for _, b in ipairs(info.baits) do
                local match = (q == "") or string.find(string.lower(name), q, 1, true) or string.find(string.lower(b.type), q, 1, true) or string.find(string.lower(b.uid), q, 1, true)
                if match then
                    shown += 1
                    order += 1
                    total += 1
                    seen[b.uid] = true
                    if not rowCache[b.uid] then rowCache[b.uid] = createRow(order, name, b) end
                    rowCache[b.uid].row.LayoutOrder = order
                    updateRowState(b.uid)
                end
            end
            if shown > 0 then players += 1 end
        end
        for uid, cache in pairs(rowCache) do
            if not seen[uid] then cache.row:Destroy(); rowCache[uid] = nil end
        end
        status.Text = string.format("P:%d B:%d Q:%d Sk:%d", players, total, countTable(queue), skipped)
    end

    local function startScanLoop()
        if scanThread then return end
        scanThread = task.spawn(function()
            while main.Parent and autoScan do
                scanned = scan()
                render()
                task.wait()
            end
            scanThread = nil
        end)
    end

    local function stopScanLoop()
        if scanThread then pcall(task.cancel, scanThread); scanThread = nil end
    end

    boxDelay.FocusLost:Connect(function()
        local n = tonumber(boxDelay.Text)
        if n and n >= 0 then delay = n else boxDelay.Text = tostring(delay) end
    end)

    search:GetPropertyChangedSignal("Text"):Connect(function() query = search.Text; render() end)

    local checkScanBtn = makeAntiScrollClick(btnScan, nil)
    btnScan.MouseButton1Click:Connect(function()
        if not checkScanBtn() then return end
        scanned = scan(); render()
    end)

    local checkAutoScan = makeAntiScrollClick(btnAutoScan, nil)
    btnAutoScan.MouseButton1Click:Connect(function()
        if not checkAutoScan() then return end
        autoScan = not autoScan
        btnAutoScan.BackgroundColor3 = autoScan and THEME.success or THEME.danger
        btnAutoScan.Text = autoScan and "⚡ ON" or "⏸ OFF"
        if autoScan then startScanLoop() else stopScanLoop() end
    end)

    local checkClear = makeAntiScrollClick(btnClear, nil)
    btnClear.MouseButton1Click:Connect(function()
        if not checkClear() then return end
        stopAll()
        for uid in pairs(queue) do queue[uid] = nil end
        queueLbl.Text = "Q:0 A:0 S:0 Sk:0"
        render()
    end)

    scanned = scan()
    render()
    startScanLoop()
end

-- PANGGIL FUNGSI DI PALING BAWAH
CreateBaitScannerUI(ScrollingNewAuto)
-- FPS Counter Loop
frameCount, fpsAccum, lastFpsUpdate = 0, 0, os.clock()
RunService.RenderStepped:Connect(function(dt)
    frameCount += 1
    fpsAccum += dt
    local now = os.clock()
    if now - lastFpsUpdate >= 0.5 then
        fps = math.floor(frameCount / fpsAccum + 0.5)
        if fps >= 50 then col = Color3.fromRGB(120, 255, 120)
        elseif fps >= 30 then col = Color3.fromRGB(255, 220, 100)
        else col = Color3.fromRGB(255, 100, 100) end
        
        pcall(function()
            FpsLabel.Text = tostring(fps)
            FpsLabel.TextColor3 = col
        end)
        
        frameCount = 0
        fpsAccum = 0
        lastFpsUpdate = now
    end
end)

task.spawn(function()
    while true do
        task.wait(1)
        tickScheduler()

        local c, t = countWave()
        local mq = #scanForMutation()
        local mi = 0
        for _ in pairs(B.mutationInProgress) do mi = mi + 1 end
        local tgtTotal, tgtOk, tgtMaxed = 0, 0, 0
        local data = getData()
        if data and data.inventory then
            for id, pd in pairs(data.inventory.pets) do
                if B.targetPets[id] then
                    tgtTotal = tgtTotal + 1
                    local m = getPetMutation(pd)
                    if isDesired(m) then tgtOk = tgtOk + 1 end
                    if getPetAge(pd) >= BCONFIG.TargetAge then tgtMaxed = tgtMaxed + 1 end
                end
            end
        end
        local colStr = tostring(B.collectSetupDone and "SET" or "PENDING")
        local statusText = string.format(
            "Fase: %s | W: %d/%d | Tgt: %d/%d | Q: %d | Mut: %d | Lvl: %d | Spd: %d | LO: %s | Jmp: %d/%d | Col: %s",
            B.wavePhase:upper(), c, t, tgtOk, tgtTotal, mq,
            B.totalMutated, #scanLevelingPets(), #scanSpeedupPets(),
            tostring(B.currentLoadout), B.boostJumperCount, BCONFIG.JumperBeforeSwitch, colStr
        )
        pcall(function()
            StatusLbl.Text = statusText
        end)
    end
end)
