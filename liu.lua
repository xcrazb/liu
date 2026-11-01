RS = (RS or game:GetService("ReplicatedStorage"))
Players = (Players or game:GetService("Players"))
CollectionService = (CollectionService or game:GetService("CollectionService"))
HttpService = (HttpService or game:GetService("HttpService"))
Lighting = (Lighting or game:GetService("Lighting"))
RunService = (RunService or game:GetService("RunService"))
player = (player or Players.LocalPlayer)
local a = nil
pcall(function()
  a = require(RS:WaitForChild("TS", 30):WaitForChild("state", 10):WaitForChild("player-data", 10))
end)
local function b()
  if not a then
    return nil
  end
  local c, d = pcall(function()
    return a.getPlayerDataById(tostring(player.UserId))
  end)
  return ((c and d) or nil)
end
local e = RS:WaitForChild("TS", 30)
if not e then
  return
end
local f = require(e:WaitForChild("remotes")).default
local g = require(e:WaitForChild("state"):WaitForChild("player-data"))
local h = g.getPlayerData
local i = require(e:WaitForChild("state"):WaitForChild("shop-restock"))
local j, k, l = i.shopRestock, i.ShopType, i.personalRestockItems
local m = require(e.state["travelling-merchant"])
local n = m.travellingMerchants
local o = nil
pcall(function()
  o = require(e:WaitForChild("utils"):WaitForChild("crafting.utils"))
end)
local p = nil
pcall(function()
  p = require(e:WaitForChild("utils"):WaitForChild("pet-age.utils"))
end)
local q = RS:WaitForChild("rbxts_include"):WaitForChild("node_modules"):WaitForChild("@rbxts"):WaitForChild("remo"):WaitForChild("src"):WaitForChild("container")
local r = q:WaitForChild("ponds.placeBuilding")
local s = q:WaitForChild("crafting.selectCraftingItem")
local t = q:WaitForChild("crafting.submitItems")
local u = q:WaitForChild("crafting.startCraft")
local v = q:WaitForChild("crafting.collectCraft")
local w = q:WaitForChild("merchant.purchaseItem")
local x = f.shop.purchaseGear
local y = f.shop.purchaseBait
local z = f.shop.purchaseEgg
local aa = q:FindFirstChild("bait.collectFish")
local ab = q:FindFirstChild("halloween.feedTreeAll")
local ac = q:FindFirstChild("pickup.claimPickup")
local ad = 549755813888
pcall(function()
  local ae = require(e:WaitForChild("lists"):WaitForChild("game"):WaitForChild("mutation-bits")).MUTATION_BITS
  if (ae and ae.Halloween) then
    ad = (2 ^ ae.Halloween)
  end
end)
local af = {diamond = true}
local function ag(ah)
  if (not ah or (ah == "")) then
    return false
  end
  local ai = string.lower(string.gsub(tostring(ah), "^%s*(.-)%s*$", "%1"))
  return (af[ai] == true)
end
local function aj(ak)
  if (not ak or (ak == "")) then
    return "none"
  end
  return string.lower(string.gsub(tostring(ak), "^%s*(.-)%s*$", "%1"))
end
local al = {TargetAge = 50, HelperMinAge = 100, JumperInterval = 3, WaitAfterPlace = 0.5, JumperCooldown = 1.5, MutationCooldown = 2, MainLoadout = 0, ResetLoadout = 1, WaitingLoadout = 1, CollectLoadout = 4, LoadoutSwitchDelay = 1.5, MutationCollectSyncDelay = 1.5, MaxCyclesBeforeStop = 999, JumperBeforeSwitch = 3, JumperSwitchDelay = 1.5, SpeedupPlaceCount = 10, AntiAfkInterval = 60, Interval = 5, BuyAll = true, BaitWL = {}, BaitBL = {}, BuyDelay = 0.15, StockTTL = 1.5, GoldenInterval = 3, GoldenIdleInterval = 10, GoldenBuyDelay = 0.25, GoldenBulkLoopDelay = 0.4, GoldenMaxPass = 8, FoodOn = false, FoodInt = 30, FoodList = {"SupremeFoodTray", "AdvancedFoodTray", "BasicFoodTray"}, FoodCat = "booster", FoodPos = Vector3.new(10.86, -0.012, -11), CraftOn = false, CraftItem = "TimeJumper", CraftCat = "gear", CraftMats = {{n = "TeleportWand", a = 10}, {n = "MagnifyingGlass", a = 25}, {n = "SupremeAutoFeeder", a = 1}}}
local am = {"Diamond", "Silver", "Radiant", "Huge", "Lightning", "Guardian", "Gold", "Tiny", "Aquatic", "Tamed"}
local an = {"NetMover", "FoodScoop", "MagnifyingGlass", "TeleportWand", "StarLock", "TradingTicket", "BasicAutoFeeder", "AdvancedAutoFeeder", "SupremeAutoFeeder", "ExtremeAutoFeeder", "GodlyAutoFeeder", "BasicFoodTray", "AdvancedFoodTray", "SupremeFoodTray", "XpCookie", "PetToy", "PetWhistle", "GoldenCookie", "EggHatcher", "EggIncubator", "MutationBeacon", "StormHorn"}
local ao = {"Tropical", "Exotic"}
local ap = "DiamondCookie"
local aq = "XpCookie"
local ar = "PetToy"
local as = 600
local at = 300
local au = {leveling = {"pegazeus", "darkphoenix"}, speedup = {"darkphoenix", "eviltrex"}, collect = {"darkphoenix", "werewolf"}}
local av = {isRunning = false, currentWave = {}, wavePhase = "idle", placedPets = {}, pickedUpPets = {}, selectedMutations = {}, mutationInProgress = {}, processedMutation = {}, lastMutationAction = 0, currentLoadout = nil, lastLoadoutSwitch = 0, totalBoosted = 0, totalMutated = 0, cycleCount = 0, jumperCounter = 0, lastJumperFire = 0, boostJumperCount = 0, boostLoadoutSwitching = false, selectedPets = {}, petList = {}, petById = {}, levelingPets = {}, speedupPets = {}, targetPets = {}, collectPets = {}, placedLeveling = {}, placedSpeedup = {}, maxPlacePerWave = 0, lastJumperEmptyNotify = 0, useAutoPetToy = false, useAutoCookie = false, collectSetupDone = false}
local aw = {gOn = false, gTot = 0, bOn = false, bTot = 0, eOn = false, eTot = 0, gdOn = false, gdTot = 0, gdActive = false, nextGear = 0, nextBait = 0, nextEgg = 0, nextGolden = 0, _stockCache = {}, pRun = false, pCnt = 0, pCd = 0, nextPlace = 0, cRun = false, cAtt = 0, cOk = 0, cFail = 0, cCd = 0, cPhase = "idle", hwCollect = false, hwFeedPickup = false, hwCollectThread = nil, hwFeedPickupThread = nil, minimized = false}
local ax = p
local ay = nil
pcall(function()
  ay = require(player.PlayerScripts.TS.ui.features.toolbar["inventory.state"])
end)
local function az(ba)
  local bb, bc = pcall(function()
    return RS:WaitForChild("rbxts_include", 10):WaitForChild("node_modules", 10):WaitForChild("@rbxts", 10):WaitForChild("remo", 10):WaitForChild("src", 10):WaitForChild("container", 10):WaitForChild(ba, 10)
  end)
  return ((bb and bc) or nil)
end
local bd = az("gear.useTimeWatch")
local be = az("tools.equipTool")
local bf = az("pets.placePetFromInventory")
local bg = az("pets.requestPosition")
local bh = az("pets.pickUpPet")
local bi = az("pets.switchPetLoadout")
local bj = az("pets.startMutation")
local bk = az("pets.collectMutation")
local bl = az("pets.choosePetMutation")
local bm = {}
local bn = az("pets.usePetGearOnPet")
local bo = game:GetService("VirtualInputManager")
local bp = game:GetService("VirtualUser")
local bq = {running = false, count = 0, lastFire = 0}
local function br()
  pcall(function()
    bo:SendKeyEvent(true, Enum.KeyCode.Z, false, game)
  end)
  task.wait(0.05)
  pcall(function()
    bo:SendKeyEvent(false, Enum.KeyCode.Z, false, game)
  end)
  pcall(function()
    bp:CaptureController()
    bp:ClickButton2(Vector2.new(0, 0))
  end)
  bq.lastFire = os.clock()
  bq.count = (bq.count + 1)
end
local function bs()
  if bq.running then
    return
  end
  bq.running = true
  task.spawn(function()
    task.wait(1)
    br()
    while bq.running do
      task.wait(al.AntiAfkInterval)
      br()
    end
  end)
end
local function bt()
  bq.running = false
end
task.spawn(bs)
local bu = {url = "", enabled = true, notifyJumperEmpty = true, username = "Farm A Fish - Mutation Log", lastJumperEmptyNotify = 0}
local function bv(bw)
  if (not bu.enabled or (bu.url == "")) then
    return
  end
  task.spawn(function()
    pcall(function()
      local bx = HttpService:JSONEncode(bw)
      local by = (((((syn and syn.request)) or ((http and http.request))) or http_request) or request)
      if by then
        by({Url = bu.url, Method = "POST", Headers = {["Content-Type"] = "application/json"}, Body = bx})
      end
    end)
  end)
end
local function bz()
  return ((player.DisplayName or player.Name) or "Unknown")
end
local function ca(cb)
  if (not p or not p.calculatePetWeight) then
    return "0.0kg"
  end
  local cc, cd = pcall(p.calculatePetWeight, cb)
  if (not cc or not cd) then
    return "0.0kg"
  end
  if p.formatPetWeight then
    local ce, cf = pcall(p.formatPetWeight, cd)
    if (ce and cf) then
      return cf
    end
  end
  if (cd >= 1000) then
    return string.format("%.2ft", (cd / 1000))
  else
    return string.format("%.2fkg", cd)
  end
end
local function cg()
  local ch = b()
  if ((not ch or not ch.inventory) or not ch.inventory.gears) then
    return 0
  end
  local ci = ch.inventory.gears.TimeJumper
  return ((ci and ((ci.amount or 0))) or 0)
end
local function cj(ck)
  local cl = b()
  if ((not cl or not cl.inventory) or not cl.inventory.gears) then
    return 0
  end
  local cm = cl.inventory.gears[ck]
  return ((cm and ((cm.amount or 0))) or 0)
end
local function cn(co, cp, cq, cr)
  local cs = false
  local ct = aj(cq)
  for cu in pairs(av.selectedMutations) do
    if (aj(cu) == ct) then
      cs = true
      break
    end
  end
  if not cs then
    return
  end
  local cv = {title = "🧬 Mutation Result (Target Tercapai!)", color = 0x9B59B6, fields = {{name = "👤 Player", value = tostring(bz()), inline = true}, {name = "🐾 Pet", value = tostring(co), inline = true}, {name = "⚖️ Berat Pet", value = tostring(cp), inline = true}, {name = "✨ Mutasi Didapat", value = tostring((cq or "None")), inline = true}, {name = "⏱️ TimeJumper Sisa", value = tostring(cr), inline = true}}, footer = {text = "Farm A fish | by bang iqi"}, timestamp = DateTime.now():ToIsoDate()}
  bv({username = bu.username, embeds = {cv}})
end
local function cw(cx)
  local cy = {title = "⚠️ TIMEJUMPER HABIS", description = "TimeJumper di inventory sudah habis. Auto mutasi akan berhenti sampai kamu craft / isi ulang.", color = 0xE74C3C, fields = {{name = "👤 Player", value = tostring(bz()), inline = true}, {name = "⏱️ Sisa TimeJumper", value = tostring((cx or 0)), inline = true}}, footer = {text = "Farm A fish | by bang iqi"}, timestamp = DateTime.now():ToIsoDate()}
  bv({username = bu.username, embeds = {cy}})
end
local function cz(da)
  if (not ax or not da) then
    return 0
  end
  local db, dc = pcall(ax.getPetAgeFromData, da)
  return ((db and ((dc or 0))) or 0)
end
local function dd(de)
  if not de then
    return "None"
  end
  local df = {de.mutation, de.mutations, de.mutationType, de.mutationName, (de.attributes and de.attributes.mutation)}
  for dg, dh in ipairs(df) do
    if ((dh and (dh ~= "")) and (dh ~= "None")) then
      if (type(dh) == "table") then
        for di, dj in pairs(dh) do
          if ((dj and (dj ~= "")) and (dj ~= "None")) then
            return tostring(dj)
          end
        end
      else
        return tostring(dh)
      end
    end
  end
  return "None"
end
local function dk(dl, dm)
  return (dl .. ("|" .. dm))
end
local function dn(dp, dq)
  aw._stockCache[dk(dp, dq)] = nil
end
local function dr(ds, dt)
  local du = dk(ds, dt)
  local dv = os.clock()
  local dw = aw._stockCache[du]
  if (dw and (((dv - dw.t)) < al.StockTTL)) then
    return dw.v
  end
  local dx = 0
  local dy, dz, ea, eb = pcall(function()
    return j(), l(), h(player)
  end)
  if ((dy and dz) and eb) then
    local ec = os.time()
    local ed = (eb.personalRestocks and eb.personalRestocks[ds])
    local ee = ((ed and ed.endTime) and (ec < ed.endTime))
    local ef = tostring(player.UserId)
    local eg
    if ee then
      eg = (((ea[ef] and ea[ef][ds]) and ea[ef][ds][dt]) or 0)
    else
      eg = (((dz.availableItems and dz.availableItems[ds]) and dz.availableItems[ds][dt]) or 0)
    end
    local eh = 0
    local ei = (eb.shopPurchases and eb.shopPurchases[ds])
    if (ei and ei.purchases) then
      if (ee and (ei.currentTimeSlot == ed.timeSlot)) then
        eh = (ei.purchases[dt] or 0)
      elseif (not ee and (ei.currentTimeSlot == dz.currentTimeSlot)) then
        eh = (ei.purchases[dt] or 0)
      end
    end
    dx = math.max(0, (eg - eh))
  end
  aw._stockCache[du] = {v = dx, t = dv}
  return dx
end
local function ej(ek, el, em)
  local en = {}
  local eo = j()
  if not eo then
    return en
  end
  local ep = (eo.availableItems and eo.availableItems[ek])
  if not ep then
    return en
  end
  local eq, er
  if (el and (#el > 0)) then
    eq = {}
    for es, et in ipairs(el) do
      eq[et] = true
    end
  end
  if (em and (#em > 0)) then
    er = {}
    for eu, ev in ipairs(em) do
      er[ev] = true
    end
  end
  for ew, ex in pairs(ep) do
    local ey = true
    if (eq and not eq[ew]) then
      ey = false
    end
    if ((ey and er) and er[ew]) then
      ey = false
    end
    if ey then
      en[(#en + 1)] = {type = ew, stock = ex}
    end
  end
  return en
end
local function ez(fa)
  local fb = pcall(x, fa)
  if fb then
    dn(k.Gear, fa)
  end
  return fb
end
local function fc(fd)
  local fe = pcall(y, fd)
  if fe then
    dn(k.Bait, fd)
  end
  return fe
end
local function ff(fg)
  local fh = pcall(z, fg)
  if fh then
    dn(k.Eggs, fg)
  end
  return fh
end
local function fi()
  for fj, fk in ipairs(an) do
    if not aw.gOn then
      return
    end
    local fl = dr(k.Gear, fk)
    if (fl > 0) then
      local fm = ((al.BuyAll and ((fl + 2))) or 1)
      for fn = 1, fm do
        if not aw.gOn then
          return
        end
        if not ez(fk) then
          break
        end
        aw.gTot += 1
        if (fn < fm) then
          task.wait(al.BuyDelay)
        end
      end
    end
  end
end
local function fo()
  local fp = ej(k.Bait, al.BaitWL, al.BaitBL)
  if (#fp == 0) then
    return
  end
  for fq, fr in ipairs(fp) do
    if not aw.bOn then
      return
    end
    local fs = dr(k.Bait, fr.type)
    if (fs > 0) then
      local ft = ((al.BuyAll and ((fs + 2))) or 1)
      for fu = 1, ft do
        if not aw.bOn then
          return
        end
        if not fc(fr.type) then
          break
        end
        aw.bTot += 1
        if (fu < ft) then
          task.wait(al.BuyDelay)
        end
      end
    end
  end
end
local function fv()
  local fw = ej(k.Eggs, ao, nil)
  if (#fw == 0) then
    return
  end
  for fx, fy in ipairs(fw) do
    if not aw.eOn then
      return
    end
    local fz = dr(k.Eggs, fy.type)
    if (fz > 0) then
      local ga = ((al.BuyAll and ((fz + 2))) or 1)
      for gb = 1, ga do
        if not aw.eOn then
          return
        end
        if not ff(fy.type) then
          break
        end
        aw.eTot += 1
        if (gb < ga) then
          task.wait(al.BuyDelay)
        end
      end
    end
  end
end
local function gc()
  local gd = n()
  if not gd then
    return nil
  end
  return gd.golden
end
local function ge()
  local gf = gc()
  if ((not gf or not gf.isActive) or not gf.availableStock) then
    return {}, false
  end
  local gg = {}
  for gh, gi in pairs(gf.availableStock) do
    gg[gh] = gi
  end
  return gg, true
end
local function gj(gk)
  return pcall(function()
    w:FireServer("golden", gk)
  end)
end
local function gl()
  local gm, gn = 0, 0
  while (aw.gdOn and (gn < al.GoldenMaxPass)) do
    gn += 1
    local go, gp = ge()
    if not gp then
      break
    end
    local gq = {}
    for gr, gs in pairs(go) do
      if (gs > 0) then
        table.insert(gq, gr)
      end
    end
    if (#gq == 0) then
      break
    end
    for gt, gu in ipairs(gq) do
      if not aw.gdOn then
        break
      end
      if gj(gu) then
        gm += 1
        aw.gdTot += 1
      end
      task.wait(al.GoldenBuyDelay)
    end
    task.wait(al.GoldenBulkLoopDelay)
  end
  return gm
end
local function gv()
  aw.pCnt += 1
  local gw = nil
  for gx, gy in ipairs(al.FoodList) do
    if (cj(gy) > 0) then
      gw = gy
      break
    end
  end
  if not gw then
    gw = al.FoodList[#al.FoodList]
  end
  pcall(function()
    r:InvokeServer(al.FoodCat, gw, al.FoodPos)
  end)
end
local gz = {DiamondCookie = 300, YolkBreaker = 600, TimeJumper = 600, ShieldLock = 1500, NetRetractor = 1500}
local function ha(hb, hc)
  if (o and o.getCraftingTime) then
    local hd, he = pcall(o.getCraftingTime, hb, hc)
    if (hd and he) then
      return he
    end
  end
  return (gz[hb] or 600)
end
local function hf()
  local hg = h(player)
  if (not hg or not hg.crafting) then
    return nil
  end
  local hh = hg.crafting[al.CraftCat]
  if (not hh or not hh.id) then
    return nil
  end
  return hh
end
local function hi()
  local hj = hf()
  if (not hj or not hj.timeStarted) then
    return nil
  end
  local hk = os.time()
  local hl = ha(hj.id, al.CraftCat)
  local hm = (hj.accumulatedProgress or 0)
  local hn = (hj.lastProgressUpdate or hj.timeStarted)
  local ho = (hj.depletionRate or 1)
  return math.max(0, (hl - ((hm + (((hk - hn)) * ho)))))
end
local function hp()
  local hq = hf()
  return (hq and (hq.timeStarted ~= nil))
end
local function hr()
  aw.cAtt += 1
  aw.cPhase = "submitting"
  local hs = pcall(function()
    s:FireServer(al.CraftItem, al.CraftCat)
  end)
  task.wait(0.3)
  if hs then
    local ht, hu = {}, 1
    for hv, hw in ipairs(al.CraftMats) do
      for hx = 1, hw.a do
        ht[hu] = hw.n
        hu += 1
      end
    end
    hs = pcall(function()
      t:FireServer(ht, al.CraftCat)
    end)
    task.wait(0.3)
  end
  if hs then
    hs = pcall(function()
      u:FireServer(al.CraftCat)
    end)
    task.wait(0.3)
  end
  if not hs then
    aw.cFail += 1
    aw.cPhase = "idle"
    return false
  end
  aw.cPhase = "crafting"
  return true
end
local function hy()
  aw.cPhase = "collecting"
  local hz = pcall(function()
    v:FireServer(al.CraftCat)
  end)
  if hz then
    aw.cOk += 1
  end
  aw.cPhase = "idle"
  return hz
end
local ia = {}
local ib = 0
local function ic(id)
  if not id then
    return false
  end
  if (typeof(id) == "number") then
    return ((math.floor((id / ad)) % 2) == 1)
  end
  if (type(id) == "table") then
    for ie, ig in pairs(id) do
      if ((typeof(ig) == "string") and (ig:lower() == "halloween")) then
        return true
      end
    end
  end
  return false
end
local function ih()
  if not aa then
    return 0
  end
  local ii = h(player)
  if (not ii or not ii.ponds) then
    return 0
  end
  local ij = ii.currentPond
  if not ij then
    return 0
  end
  local ik = 0
  local il = ii.ponds[ij]
  if ((type(il) == "table") and il.baits) then
    for im, io in pairs(il.baits) do
      if ((type(io) == "table") and io.fishes) then
        for ip, iq in pairs(io.fishes) do
          if ((type(iq) == "table") and ic(iq.mutations)) then
            pcall(function()
              aa:FireServer(im, ip)
            end)
            ik += 1
            task.wait(0.05)
          end
        end
      end
    end
  end
  return ik
end
local function ir()
  if not ab then
    return false
  end
  local is = os.time()
  if (((is - ib)) >= 5) then
    ib = is
    return pcall(function()
      ab:FireServer()
    end)
  end
  return false
end
local function it()
  if not ac then
    return 0
  end
  local iu = 0
  for iv, iw in ipairs(workspace:GetChildren()) do
    if (iw:IsA("BasePart") and (iw.Name:sub(1, 7) == "Pickup_")) then
      local ix = iw.Name:sub(8)
      if (#ix > 0) then
        pcall(function()
          ac:FireServer(ix)
        end)
        iu += 1
        task.wait(0.05)
      end
    end
  end
  return iu
end
local function iy()
  if aw.hwCollectThread then
    pcall(function()
      task.cancel(aw.hwCollectThread)
    end)
  end
  aw.hwCollectThread = task.spawn(function()
    while aw.hwCollect do
      pcall(ih)
      task.wait(1)
    end
  end)
end
local function iz()
  aw.hwCollect = false
  if aw.hwCollectThread then
    pcall(function()
      task.cancel(aw.hwCollectThread)
    end)
    aw.hwCollectThread = nil
  end
end
local function ja()
  if aw.hwFeedPickupThread then
    pcall(function()
      task.cancel(aw.hwFeedPickupThread)
    end)
  end
  aw.hwFeedPickupThread = task.spawn(function()
    while aw.hwFeedPickup do
      pcall(ir)
      task.wait(1)
      pcall(it)
      task.wait(1)
    end
  end)
end
local function jb()
  aw.hwFeedPickup = false
  if aw.hwFeedPickupThread then
    pcall(function()
      task.cancel(aw.hwFeedPickupThread)
    end)
    aw.hwFeedPickupThread = nil
  end
end
local function jc()
  local jd = os.clock()
  if (aw.gOn and (jd >= aw.nextGear)) then
    aw.nextGear = (jd + al.Interval)
    task.spawn(fi)
  end
  if (aw.bOn and (jd >= aw.nextBait)) then
    aw.nextBait = (jd + al.Interval)
    task.spawn(fo)
  end
  if (aw.eOn and (jd >= aw.nextEgg)) then
    aw.nextEgg = (jd + al.Interval)
    task.spawn(fv)
  end
  if (aw.gdOn and (jd >= aw.nextGolden)) then
    local je = ((aw.gdActive and al.GoldenInterval) or al.GoldenIdleInterval)
    aw.nextGolden = (jd + je)
    task.spawn(function()
      local jf, jg = ge()
      aw.gdActive = jg
      if jg then
        gl()
      end
    end)
  end
  if (al.FoodOn and (jd >= aw.nextPlace)) then
    aw.nextPlace = (jd + al.FoodInt)
    task.spawn(gv)
  end
  if al.CraftOn then
    if hp() then
      local jh = hi()
      if jh then
        aw.cCd = jh
        aw.cPhase = "crafting"
        if (jh <= 0) then
          task.spawn(hy)
        end
      else
        aw.cPhase = "idle"
        aw.cCd = 0
      end
    else
      if (not aw._nextCraftTry or (jd >= aw._nextCraftTry)) then
        aw._nextCraftTry = (jd + 2)
        task.spawn(hr)
      end
    end
  else
    aw.cCd = 0
  end
end
local function ji()
  local jj = {}
  if not ay then
    return jj
  end
  local jk, jl = pcall(function()
    return ay.inventoryStackedData()
  end)
  if (not jk or not jl) then
    return jj
  end
  for jm, jn in pairs(jl) do
    local jo = tostring(jn.toolType):lower()
    if ((jo:find("pet") and jn.items) and jn.items[1]) then
      local jp = jn.items[1].id
      if jp then
        jj[jp] = ((jn.displayName or jn.itemName) or tostring(jp))
      end
    end
  end
  return jj
end
local function jq(jr)
  if (av.currentLoadout == jr) then
    return true
  end
  if not bi then
    return false
  end
  local js = os.clock()
  local jt = (js - av.lastLoadoutSwitch)
  if (jt < al.LoadoutSwitchDelay) then
    task.wait((al.LoadoutSwitchDelay - jt))
  end
  local ju = pcall(function()
    bi:InvokeServer(jr)
  end)
  if ju then
    av.currentLoadout = jr
    av.lastLoadoutSwitch = os.clock()
    task.wait(al.LoadoutSwitchDelay)
    return true
  end
  return false
end
local function jv(jw)
  if (av.currentLoadout == jw) then
    return true
  end
  return jq(jw)
end
local function jx()
  for jy in pairs(av.selectedMutations) do
    return true
  end
  return false
end
local function jz(ka)
  if not jx() then
    return false
  end
  local kb = aj(ka)
  if ((kb == "none") or (kb == "")) then
    return false
  end
  for kc in pairs(av.selectedMutations) do
    if (aj(kc) == kb) then
      return true
    end
  end
  return false
end
local function kd()
  local ke = CollectionService:GetTagged("petMutationLabel")
  if (#ke == 0) then
    return "Unknown"
  end
  local kf = ke[1].Text
  if ((kf == "MUTATION") or (kf == "")) then
    return "Idle"
  elseif (kf == "READY!") then
    return "Ready"
  else
    return "InProgress"
  end
end
local function kg(kh, ki)
  local kj = (((((kh.mutation and (kh.mutation ~= "")) and (kh.mutation ~= "None"))) and kh.mutation) or "No Mutation")
  local kk = string.format("%.1f", (kh.age or 0))
  local kl = ((ki and string.format("  #%d", ki)) or "")
  return string.format("%s | %s | Age %s%s", kh.displayName, kj, kk, kl)
end
local function km(kn, ko, kp)
  if (not ko or not ko.activeGearBuffs) then
    return false, 0
  end
  local kq = ko.activeGearBuffs[kp]
  if kq then
    local kr = (kq - os.time())
    if (kr > 0) then
      return true, kr
    else
      return false, 0
    end
  end
  return false, 0
end
local function ks(kt, ku)
  local kv = b()
  if ((not kv or not kv.inventory) or not kv.inventory.pets[kt]) then
    return false
  end
  local kw = kv.inventory.pets[kt]
  local kx, ky = km(kt, kw, ku)
  return (not kx or (ky <= as))
end
local function kz(la, lb)
  local lc = b()
  if ((not lc or not lc.inventory) or not lc.inventory.gears) then
    return false
  end
  local ld = lc.inventory.gears[lb]
  if (not ld or (((ld.amount or 0)) <= 0)) then
    return false
  end
  if be then
    pcall(function()
      be:FireServer(lb, "gear")
    end)
  end
  task.wait(0.5)
  local le = false
  if bn then
    le = pcall(function()
      bn:FireServer(la)
    end)
  end
  task.wait(0.5)
  return le
end
local function lf(lg)
  if (not lg or not lg.activeGearBuffs) then
    return false, 0
  end
  local lh = lg.activeGearBuffs[ar]
  if lh then
    local li = (lh - os.time())
    if (li > 0) then
      return true, li
    else
      return false, 0
    end
  end
  return false, 0
end
local function lj(lk, ll)
  local lm = b()
  if ((not lm or not lm.inventory) or not lm.inventory.pets[lk]) then
    return false
  end
  local ln = lm.inventory.pets[lk]
  local lo, lp = lf(ln)
  return (not lo or (lp <= ((ll or at))))
end
local function lq(lr)
  local ls = b()
  if ((not ls or not ls.inventory) or not ls.inventory.gears) then
    return false
  end
  local lt = ls.inventory.gears[ar]
  if (not lt or (((lt.amount or 0)) <= 0)) then
    return false
  end
  if be then
    pcall(function()
      be:FireServer(ar, "gear")
    end)
  end
  task.wait(0.5)
  local lu = false
  if bn then
    lu = pcall(function()
      bn:FireServer(lr)
    end)
  end
  task.wait(0.5)
  return lu
end
local function lv(lw, lx)
  if not av.useAutoPetToy then
    return
  end
  for ly in pairs(lw) do
    if lj(ly, at) then
      lq(ly)
    end
  end
end
local function lz(ma, mb, mc)
  local md = cz(mb)
  local me = dd(mb)
  local mf = ((((mb.petType or mb.type) or mb.species) or mb.model) or "Unknown")
  local mg = (((mb.nickname or mb.name) or mb.displayName) or mb.petName)
  local mh = mc[ma]
  if ((not mh or (mh == "")) or (mh == tostring(ma))) then
    if ((mg and (mg ~= "")) and (string.lower(tostring(mg)) ~= string.lower(tostring(mf)))) then
      mh = string.format("%s (%s)", tostring(mf), tostring(mg))
    else
      mh = tostring(mf)
    end
  end
  return {id = ma, age = md, mutation = me, displayName = tostring(mh)}
end
local function mi()
  local mj = b()
  if not mj then
    return {}
  end
  if (not mj.inventory or not mj.inventory.pets) then
    return {}
  end
  local mk = ji()
  local ml = {}
  for mm, mn in pairs(mj.inventory.pets) do
    if not ag(dd(mn)) then
      table.insert(ml, lz(mm, mn, mk))
    end
  end
  table.sort(ml, function(mo, mp)
    if (mo.displayName ~= mp.displayName) then
      return (mo.displayName < mp.displayName)
    end
    return (mo.age < mp.age)
  end)
  for mq, mr in ipairs(ml) do
    mr.label = kg(mr, mq)
  end
  return ml
end
local function ms()
  local mt = b()
  if not mt then
    return {}
  end
  if (not mt.inventory or not mt.inventory.pets) then
    return {}
  end
  local mu = ji()
  local mv = {}
  for mw, mx in pairs(mt.inventory.pets) do
    local my = cz(mx)
    if (my >= al.HelperMinAge) then
      table.insert(mv, lz(mw, mx, mu))
    end
  end
  table.sort(mv, function(mz, na)
    if (mz.displayName ~= na.displayName) then
      return (mz.displayName < na.displayName)
    end
    return (mz.age < na.age)
  end)
  for nb, nc in ipairs(mv) do
    nc.label = kg(nc, nb)
  end
  return mv
end
local function nd(ne, nf)
  if not ne then
    return false
  end
  local ng = string.lower(tostring(ne))
  for nh, ni in ipairs(nf) do
    if ng:find(ni, 1, true) then
      return true
    end
  end
  return false
end
local function nj(nk)
  local nl = b()
  if not nl then
    return {}
  end
  if (not nl.inventory or not nl.inventory.pets) then
    return {}
  end
  local nm = ji()
  local nn = {}
  for no, np in pairs(nl.inventory.pets) do
    local nq = cz(np)
    if (nq >= al.HelperMinAge) then
      local nr = ((((np.petType or np.type) or np.species) or np.model) or "")
      if nd(nr, nk) then
        table.insert(nn, lz(no, np, nm))
      end
    end
  end
  table.sort(nn, function(ns, nt)
    if (ns.displayName ~= nt.displayName) then
      return (ns.displayName < nt.displayName)
    end
    return (ns.age < nt.age)
  end)
  for nu, nv in ipairs(nn) do
    nv.label = kg(nv, nu)
  end
  return nn
end
local function nw()
  local nx = b()
  if (not nx or not nx.inventory) then
    return {}
  end
  local ny = {}
  for nz, oa in pairs(nx.inventory.pets) do
    if (av.targetPets[nz] and not bm[nz]) then
      local ob = dd(oa)
      if (not ag(ob) and not jz(ob)) then
        local oc = cz(oa)
        if (oc < al.TargetAge) then
          table.insert(ny, {id = nz, age = oc})
        end
      end
    end
  end
  table.sort(ny, function(od, oe)
    return (od.age < oe.age)
  end)
  return ny
end
local function of()
  local og = b()
  if (not og or not og.inventory) then
    return {}
  end
  local oh = {}
  for oi, oj in pairs(og.inventory.pets) do
    if (av.targetPets[oi] and not bm[oi]) then
      local ok = dd(oj)
      if (((not ag(ok) and not jz(ok)) and not av.processedMutation[oi]) and not av.mutationInProgress[oi]) then
        local ol = cz(oj)
        if (ol >= al.TargetAge) then
          table.insert(oh, {id = oi, age = ol})
        end
      end
    end
  end
  table.sort(oh, function(om, on)
    return (om.age > on.age)
  end)
  return oh
end
local function oo()
  local op = b()
  if (not op or not op.inventory) then
    return {}
  end
  local oq = {}
  for os, ot in pairs(op.inventory.pets) do
    if (av.levelingPets[os] and not av.placedLeveling[os]) then
      if (cz(ot) >= al.HelperMinAge) then
        table.insert(oq, {id = os, age = cz(ot)})
      end
    end
  end
  table.sort(oq, function(ou, ov)
    return (ou.age < ov.age)
  end)
  return oq
end
local function ow()
  local ox = b()
  if (not ox or not ox.inventory) then
    return {}
  end
  local oy = {}
  for oz, pa in pairs(ox.inventory.pets) do
    if (av.speedupPets[oz] and not av.placedSpeedup[oz]) then
      if (cz(pa) >= al.HelperMinAge) then
        table.insert(oy, {id = oz, age = cz(pa)})
      end
    end
  end
  return oy
end
local function pb()
  local pc = b()
  if (not pc or not pc.inventory) then
    return false
  end
  local pd, pe = 0, 0
  for pf, pg in pairs(pc.inventory.pets) do
    if av.targetPets[pf] then
      local ph = dd(pg)
      if (not ag(ph) and not jz(ph)) then
        pd = (pd + 1)
        if (cz(pg) >= al.TargetAge) then
          pe = (pe + 1)
        end
      end
    end
  end
  return ((pd > 0) and (pe >= pd))
end
local function pi()
  local pj = b()
  if (not pj or not pj.inventory) then
    return false
  end
  local pk, pl = 0, 0
  for pm, pn in pairs(pj.inventory.pets) do
    if av.targetPets[pm] then
      local po = dd(pn)
      if not ag(po) then
        pk = (pk + 1)
        if jz(po) then
          pl = (pl + 1)
        end
      end
    end
  end
  return ((pk > 0) and (pl >= pk))
end
local function pp()
  return (#nw() > 0)
end
local function pq()
  return (#of() > 0)
end
local function pr()
  local ps, pt = 0, 0
  local pu = b()
  if (not pu or not pu.inventory) then
    return 0, 0
  end
  for pv in pairs(av.currentWave) do
    pt = (pt + 1)
    local pw = pu.inventory.pets[pv]
    if (pw and (cz(pw) >= al.TargetAge)) then
      ps = (ps + 1)
    end
  end
  return ps, pt
end
local function px(py, pz)
  if (not pz and av.placedPets[py]) then
    return true
  end
  local qa = b()
  if ((not qa or not qa.inventory) or not qa.inventory.pets[py]) then
    av.placedPets[py] = true
    return true
  end
  if be then
    pcall(function()
      be:FireServer(py, "pet")
    end)
  end
  task.wait(al.WaitAfterPlace)
  local qb = false
  if bf then
    qb = pcall(function()
      bf:InvokeServer(py)
    end)
  end
  task.wait(al.WaitAfterPlace)
  if (qb and bg) then
    pcall(function()
      bg:InvokeServer(py)
    end)
  end
  task.wait(0.3)
  av.placedPets[py] = true
  av.pickedUpPets[py] = nil
  return qb
end
local function qc(qd)
  if av.pickedUpPets[qd] then
    return true
  end
  if not bh then
    return false
  end
  local qe = pcall(function()
    bh:InvokeServer(qd)
  end)
  if not qe then
    return false
  end
  av.pickedUpPets[qd] = true
  av.placedPets[qd] = nil
  return true
end
local function qf(qg)
  local qh = os.clock()
  if (not qg and (((qh - av.lastJumperFire)) < al.JumperCooldown)) then
    return "cooldown"
  end
  if (av.currentLoadout ~= al.MainLoadout) then
    jv(al.MainLoadout)
  end
  local qi = b()
  if ((not qi or not qi.inventory) or not qi.inventory.gears) then
    return "error"
  end
  local qj = qi.inventory.gears.TimeJumper
  local qk = ((qj and ((qj.amount or 0))) or 0)
  if (qk <= 0) then
    if bu.notifyJumperEmpty then
      local ql = os.time()
      if ((ql - ((bu.lastJumperEmptyNotify or 0))) > 120) then
        bu.lastJumperEmptyNotify = ql
        cw(0)
      end
    end
    return "empty"
  end
  if not bd then
    return "error"
  end
  local qm = pcall(function()
    bd:FireServer("TimeJumper")
  end)
  if qm then
    av.lastJumperFire = qh
    av.jumperCounter = (av.jumperCounter + 1)
    av.boostJumperCount = (av.boostJumperCount + 1)
    local qn = b()
    local qo = 0
    if (((qn and qn.inventory) and qn.inventory.gears) and qn.inventory.gears.TimeJumper) then
      qo = (qn.inventory.gears.TimeJumper.amount or 0)
    end
    if ((qo <= 0) and bu.notifyJumperEmpty) then
      local qp = os.time()
      if ((qp - ((bu.lastJumperEmptyNotify or 0))) > 120) then
        bu.lastJumperEmptyNotify = qp
        cw(qo)
      end
    end
    return "ok"
  end
  return "error"
end
local function qq()
  if av.boostLoadoutSwitching then
    return
  end
  av.boostLoadoutSwitching = true
  jv(al.ResetLoadout)
  task.wait(al.JumperSwitchDelay)
  jv(al.MainLoadout)
  task.wait(al.JumperSwitchDelay)
  av.boostJumperCount = 0
  lv(av.levelingPets, "Leveling")
  av.boostLoadoutSwitching = false
end
local function qr()
  av.currentWave = {}
  av.wavePhase = "idle"
end
local function qs()
  jv(al.MainLoadout)
  local qt = oo()
  for qu, qv in ipairs(qt) do
    local qw = (av.useAutoPetToy and lj(qv.id, at))
    if px(qv.id, true) then
      av.placedLeveling[qv.id] = true
      if qw then
        task.wait(0.5)
        lq(qv.id)
      end
    end
    task.wait(0.2)
  end
  local qx = nw()
  if (#qx == 0) then
    av.wavePhase = "done"
    return false
  end
  local qy = #qx
  if (av.maxPlacePerWave > 0) then
    qy = math.min(av.maxPlacePerWave, #qx)
  end
  av.currentWave = {}
  av.wavePhase = "placing"
  local qz = 0
  for ra = 1, qy do
    local rb = qx[ra].id
    local rc = (av.useAutoCookie and ks(rb, ap))
    local rd = (av.useAutoCookie and ks(rb, aq))
    local re = px(rb)
    if (re ~= false) then
      av.currentWave[rb] = true
      qz = (qz + 1)
      if (rc or rd) then
        task.wait(0.5)
        if rc then
          kz(rb, ap)
        end
        if rd then
          kz(rb, aq)
        end
      end
    end
    task.wait(0.2)
  end
  if (qz == 0) then
    av.wavePhase = "done"
    return false
  end
  av.boostJumperCount = 0
  av.wavePhase = "boosting"
  return true
end
local function rf()
  jv(al.MainLoadout)
  local rg = ow()
  local rh = 0
  for ri, rj in ipairs(rg) do
    if (rh >= al.SpeedupPlaceCount) then
      break
    end
    local rk = (av.useAutoPetToy and lj(rj.id, at))
    if px(rj.id, true) then
      av.placedSpeedup[rj.id] = true
      rh = (rh + 1)
      if rk then
        task.wait(0.5)
        lq(rj.id)
      end
    end
    task.wait(0.2)
  end
  return rh
end
local function rl()
  for rm in pairs(av.placedSpeedup) do
    qc(rm)
    task.wait(0.2)
  end
  av.placedSpeedup = {}
end
local function rn(ro)
  local rp = b()
  if ((not rp or not rp.inventory) or not rp.inventory.pets[ro]) then
    return false
  end
  if ag(dd(rp.inventory.pets[ro])) then
    return false
  end
  if be then
    pcall(function()
      be:FireServer(ro, "pet")
    end)
  end
  task.wait(0.5)
  if not bj then
    return false
  end
  local rq = pcall(function()
    bj:InvokeServer(ro)
  end)
  if rq then
    av.mutationInProgress[ro] = true
    av.processedMutation[ro] = true
    return true
  end
  return false
end
local function rr()
  if av.collectSetupDone then
    return true
  end
  if (next(av.collectPets) == nil) then
    av.collectSetupDone = true
    return true
  end
  if not jv(al.CollectLoadout) then
    return false
  end
  local rs = false
  for rt in pairs(av.collectPets) do
    local ru = b()
    if ((ru and ru.inventory) and ru.inventory.pets[rt]) then
      local rv = (av.useAutoPetToy and lj(rt, at))
      if px(rt, true) then
        rs = true
        if rv then
          task.wait(0.5)
          lq(rt)
        end
      end
    end
    task.wait(0.2)
  end
  task.wait(0.5)
  av.collectSetupDone = true
  jv(al.MainLoadout)
  return rs
end
local function rw(rx, ry)
  local rz = b()
  if (not rz or not rz.petMutation) then
    return false
  end
  local sa = (rz.petMutation.petData and rz.petMutation.petData.mutation)
  local sb = (rx or rz.petMutation.rolledMutation)
  if (not sa or not sb) then
    pcall(function()
      bl:InvokeServer(true)
    end)
    return false
  end
  local sc = {["None"] = 0, ["Tamed"] = 1, ["Guardian"] = 2, ["Tiny"] = 3, ["Aquatic"] = 4, ["Lightning"] = 5, ["Radiant"] = 6, ["Huge"] = 7, ["Silver"] = 8, ["Gold"] = 9, ["Diamond"] = 10}
  local sd = (sc[sa] or 0)
  local se = (sc[sb] or 0)
  local sf = false
  local sg = false
  for sh in pairs(av.selectedMutations) do
    if (string.lower(sh) == string.lower(sb)) then
      sg = true
      break
    end
  end
  if (string.lower(tostring(sb)) == "diamond") then
    sf = true
  else
    sf = (se > sd)
  end
  print(string.format("[AutoResolve] Lama=%s → Baru=%s | %s", tostring(sa), tostring(sb), ((sf and "TAKE") or "KEEP")))
  local si = {not sf}
  local sj = pcall(function()
    bl:InvokeServer(unpack(si))
  end)
  if ((sj and sf) and ((sg or (string.lower(tostring(sb)) == "diamond")))) then
    task.wait(1)
    local sk = "Unknown"
    local sl = "0.0kg"
    local sm = b()
    if (((ry and sm) and sm.inventory) and sm.inventory.pets[ry]) then
      local sn = sm.inventory.pets[ry]
      sk = ((((sn.petType or sn.type) or sn.species) or sn.model) or "Unknown")
      sl = ca(sn)
    end
    cn(sk, sl, sb, cg())
    print(("📨 [Webhook] Notifikasi terkirim: " .. (tostring(sk) .. (" | " .. (tostring(sl) .. (" | " .. tostring(sb)))))))
    if (string.lower(tostring(sb)) == "diamond") then
      if (ry and av.targetPets[ry]) then
        av.targetPets[ry] = nil
        bm[ry] = true
        print("🏆 [GRADUATION] Pet sukses dapat Diamond! Dihapus dari target.")
      end
    end
  end
  return sj, sf
end
local function so()
  local sp = os.clock()
  if (((sp - av.lastMutationAction)) < al.MutationCooldown) then
    return
  end
  local sq = kd()
  if (sq == "Ready") then
    if not jv(al.CollectLoadout) then
      return
    end
    lv(av.collectPets, "Collect")
    local sr = {}
    for ss in pairs(av.mutationInProgress) do
      table.insert(sr, ss)
    end
    if not bk then
      return
    end
    local st, su = pcall(function()
      return bk:InvokeServer()
    end)
    if (st and su) then
      task.wait(0.5)
      local sv = (b() and b().petMutation)
      local sw = (sv and sv.petId)
      rw(su, sw)
      task.wait(1.5)
      local sx = b()
      if ((sx and sx.inventory) and sx.inventory.pets) then
        for sy, sz in ipairs(sr) do
          local ta = sx.inventory.pets[sz]
          if ta then
            local tb = ((((ta.petType or ta.type) or ta.species) or ta.model) or tostring(sz))
            local tc = dd(ta)
            local td = ca(ta)
            local te = cg()
            if (av.targetPets[sz] and jz(tc)) then
              cn(tb, td, tc, te)
            end
          end
        end
      end
      for tf, tg in ipairs(sr) do
        av.totalMutated = (av.totalMutated + 1)
        av.processedMutation[tg] = nil
      end
      av.mutationInProgress = {}
      av.lastMutationAction = os.clock()
    end
    jv(al.MainLoadout)
    return
  end
  if (sq == "InProgress") then
    if not av.collectSetupDone then
      local th = rr()
      if th then
        jv(al.WaitingLoadout)
      end
      return
    end
    if (av.currentLoadout ~= al.WaitingLoadout) then
      jv(al.WaitingLoadout)
    end
    return
  end
  if (sq == "Idle") then
    if (next(av.mutationInProgress) ~= nil) then
      av.mutationInProgress = {}
    end
    local ti = of()
    if (#ti == 0) then
      return
    end
    if not jv(al.MainLoadout) then
      return
    end
    lv(av.speedupPets, "Speedup")
    if rn(ti[1].id) then
      av.lastMutationAction = sp
      task.wait(0.5)
      jv(al.WaitingLoadout)
    end
  end
end
local function tj()
  for tk in pairs(av.currentWave) do
    if qc(tk) then
      av.totalBoosted = (av.totalBoosted + 1)
    end
    task.wait(0.3)
  end
  qr()
end
local function tl()
  for tm in pairs(av.placedLeveling) do
    qc(tm)
    task.wait(0.3)
  end
  av.placedLeveling = {}
end
local function tn()
  jv(al.MainLoadout)
  while av.isRunning do
    task.wait(al.JumperInterval)
    local to = b()
    if not to then
      continue
    end
    if pi() then
      rl()
      tl()
      av.wavePhase = "stopped"
      av.isRunning = false
      break
    end
    if (av.cycleCount >= al.MaxCyclesBeforeStop) then
      av.wavePhase = "stopped"
      av.isRunning = false
      break
    end
    if (av.wavePhase == "mutating") then
      if (((#of() > 0) or (kd() == "Ready")) or (kd() == "InProgress")) then
        so()
      else
        if (next(av.placedSpeedup) ~= nil) then
          rl()
        end
        av.wavePhase = "idle"
      end
      continue
    end
    if ((av.wavePhase == "idle") or (av.wavePhase == "done")) then
      if pp() then
        qs()
      elseif pb() then
        tj()
        tl()
        rf()
        av.wavePhase = "mutating"
      elseif (next(av.currentWave) ~= nil) then
        local tp, tq = pr()
        if ((tq > 0) and (tp >= tq)) then
          tj()
        end
      end
    elseif (av.wavePhase == "placing") then
      av.wavePhase = "boosting"
    elseif (av.wavePhase == "boosting") then
      local tr, ts = pr()
      if ((ts > 0) and (tr >= ts)) then
        tj()
        av.boostJumperCount = 0
        if pb() then
          tl()
          rf()
          av.wavePhase = "mutating"
        end
      else
        if ((av.boostJumperCount >= al.JumperBeforeSwitch) and not av.boostLoadoutSwitching) then
          qq()
        else
          local tt = qf(false)
          if (tt == "empty") then
            if pq() then
              tj()
              av.boostJumperCount = 0
              tl()
              rf()
              av.wavePhase = "mutating"
            else
              rl()
              tl()
              tj()
              av.wavePhase = "stopped"
              av.isRunning = false
              break
            end
          end
        end
      end
    end
  end
end
local tu = {boosted = false, originalSettings = {}, hiddenObjects = {}, terrainSettings = {}, fishHidden = false, hiddenFish = {}, mutedSounds = {}, materialCache = {}}
local tv = workspace:FindFirstChildOfClass("Terrain")
local function tw(tx)
  local ty, tz = pcall(function()
    return tx:GetChildren()
  end)
  if (ty and tz) then
    return tz
  end
  return {}
end
local function ua(ub)
  local uc, ud = pcall(function()
    return ub:GetDescendants()
  end)
  if (uc and ud) then
    return ud
  end
  return {}
end
local function ue()
  tu.originalSettings = {GlobalShadows = Lighting.GlobalShadows, ShadowSoftness = Lighting.ShadowSoftness, Brightness = Lighting.Brightness, Ambient = Lighting.Ambient, OutdoorAmbient = Lighting.OutdoorAmbient, FogEnd = Lighting.FogEnd, FogStart = Lighting.FogStart, FogColor = Lighting.FogColor, EnvironmentDiffuseScale = Lighting.EnvironmentDiffuseScale, EnvironmentSpecularScale = Lighting.EnvironmentSpecularScale, ExposureCompensation = Lighting.ExposureCompensation, ClockTime = Lighting.ClockTime, QualityLevel = UserSettings().GameSettings.SavedQualityLevel.Value}
  if tv then
    pcall(function()
      tu.terrainSettings = {WaterWaveSize = tv.WaterWaveSize, WaterWaveSpeed = tv.WaterWaveSpeed, WaterReflectance = tv.WaterReflectance, WaterTransparency = tv.WaterTransparency, Decoration = tv.Decoration}
    end)
  end
end
local function uf(ug, uh)
  if (not ug or not ug.Parent) then
    return
  end
  if (uh and (((ug == uh) or ug:IsDescendantOf(uh)))) then
    return
  end
  local ui = ug.ClassName
  if ((((((((((((ui == "ParticleEmitter") or (ui == "Trail")) or (ui == "Beam")) or (ui == "Fire")) or (ui == "Smoke")) or (ui == "Sparkles")) or (ui == "PointLight")) or (ui == "SpotLight")) or (ui == "SurfaceLight")) or (ui == "Explosion")) or (ui == "Atmosphere")) or (ui == "Sky")) then
    pcall(function()
      if ug.Enabled then
        ug.Enabled = false
        table.insert(tu.hiddenObjects, {obj = ug, prop = "Enabled", val = true})
      end
    end)
  elseif ((ui == "Decal") or (ui == "Texture")) then
    pcall(function()
      if (ug.Transparency < 1) then
        table.insert(tu.hiddenObjects, {obj = ug, prop = "Transparency", val = ug.Transparency})
        ug.Transparency = 1
      end
    end)
  elseif (ui == "MeshPart") then
    pcall(function()
      if (ug.TextureID ~= "") then
        table.insert(tu.hiddenObjects, {obj = ug, prop = "TextureID", val = ug.TextureID})
        ug.TextureID = ""
      end
      if (ug.Material ~= Enum.Material.SmoothPlastic) then
        table.insert(tu.materialCache, {obj = ug, prop = "Material", val = ug.Material})
        ug.Material = Enum.Material.SmoothPlastic
      end
    end)
  elseif (ui == "SurfaceAppearance") then
    pcall(function()
      if ug.Enabled then
        table.insert(tu.hiddenObjects, {obj = ug, prop = "Enabled", val = true})
        ug.Enabled = false
      end
    end)
  elseif (ui == "BasePart") then
    pcall(function()
      if (ug.Material ~= Enum.Material.SmoothPlastic) then
        table.insert(tu.materialCache, {obj = ug, prop = "Material", val = ug.Material})
        ug.Material = Enum.Material.SmoothPlastic
      end
      if ug.CastShadow then
        table.insert(tu.hiddenObjects, {obj = ug, prop = "CastShadow", val = true})
        ug.CastShadow = false
      end
    end)
  end
end
local function uj()
  if tu.boosted then
    return false
  end
  local ur = pcall(function()
    ue()
    tu.boosted = true
    tu.hiddenObjects = {}
    tu.mutedSounds = {}
    tu.materialCache = {}
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
    for uk, ul in ipairs(tw(Lighting)) do
      pcall(function()
        if ((ul:IsA("PostEffect") or ul:IsA("Atmosphere")) or ul:IsA("Sky")) then
          if (ul.Enabled ~= nil) then
            ul.Enabled = false
            table.insert(tu.hiddenObjects, {obj = ul, prop = "Enabled", val = true})
          end
        end
      end)
    end
    if tv then
      pcall(function()
        tv.WaterWaveSize = 0
        tv.WaterWaveSpeed = 0
        tv.WaterReflectance = 0
        tv.WaterTransparency = 1
        tv.Decoration = false
      end)
    end
    pcall(function()
      UserSettings().GameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1
    end)
    local um = player.Character
    for un, uo in ipairs(ua(workspace)) do
      uf(uo, um)
    end
    for up, uq in ipairs(ua(workspace)) do
      pcall(function()
        if (uq:IsA("Sound") and uq.Playing) then
          uq.Playing = false
          table.insert(tu.mutedSounds, uq)
        end
      end)
    end
  end)
  if not ur then
    tu.boosted = false
    return false
  end
  return true
end
local function us()
  if not tu.boosted then
    return false
  end
  tu.boosted = false
  pcall(function()
    local ut = (tu.originalSettings or {})
    Lighting.GlobalShadows = (ut.GlobalShadows ~= false)
    Lighting.ShadowSoftness = (ut.ShadowSoftness or 0.2)
    Lighting.Brightness = (ut.Brightness or 2)
    Lighting.Ambient = (ut.Ambient or Color3.fromRGB(70, 70, 70))
    Lighting.OutdoorAmbient = (ut.OutdoorAmbient or Color3.fromRGB(128, 128, 128))
    Lighting.FogEnd = (ut.FogEnd or 100000)
    Lighting.FogStart = (ut.FogStart or 0)
    Lighting.FogColor = (ut.FogColor or Color3.fromRGB(192, 192, 192))
    Lighting.EnvironmentDiffuseScale = (ut.EnvironmentDiffuseScale or 1)
    Lighting.EnvironmentSpecularScale = (ut.EnvironmentSpecularScale or 1)
    Lighting.ExposureCompensation = (ut.ExposureCompensation or 0)
    Lighting.ClockTime = (ut.ClockTime or 14)
    if (tv and tu.terrainSettings) then
      local uu = tu.terrainSettings
      tv.WaterWaveSize = (uu.WaterWaveSize or 0.15)
      tv.WaterWaveSpeed = (uu.WaterWaveSpeed or 10)
      tv.WaterReflectance = (uu.WaterReflectance or 0.1)
      tv.WaterTransparency = (uu.WaterTransparency or 0.3)
      tv.Decoration = (uu.Decoration ~= false)
    end
    for uv, uw in ipairs(tu.hiddenObjects) do
      pcall(function()
        if (uw.obj and uw.obj.Parent) then
          uw.obj[uw.prop] = uw.val
        end
      end)
    end
    tu.hiddenObjects = {}
    for ux, uy in ipairs(tu.materialCache) do
      pcall(function()
        if (uy.obj and uy.obj.Parent) then
          uy.obj[uy.prop] = uy.val
        end
      end)
    end
    tu.materialCache = {}
    for uz, va in ipairs(tu.mutedSounds) do
      pcall(function()
        if (va and va.Parent) then
          va.Playing = true
        end
      end)
    end
    tu.mutedSounds = {}
    pcall(function()
      UserSettings().GameSettings.SavedQualityLevel = (ut.QualityLevel or Enum.SavedQualitySetting.QualityLevel5)
    end)
  end)
  return true
end
local function vb()
  if tu.fishHidden then
    return 0
  end
  tu.hiddenFish = {}
  local vc = 0
  local vd = workspace:FindFirstChild("Game")
  if vd then
    table.insert(tu.hiddenFish, {obj = vd, parent = vd.Parent, type = "folder"})
    pcall(function()
      vd.Parent = nil
    end)
    vc += 1
  end
  for ve, vf in ipairs(workspace:GetDescendants()) do
    if (vf:IsA("Model") and vf.Parent) then
      if vf.Parent.Name:lower():find("pond") then
        local vg = vf.Name:lower()
        if (((((vg == "sardine") or (vg == "cod")) or (vg == "salmon")) or vg:find("_gold")) or vg:find("_silver")) then
          table.insert(tu.hiddenFish, {obj = vf, parent = vf.Parent, type = "model"})
          pcall(function()
            vf.Parent = nil
          end)
          vc += 1
        end
      end
    end
  end
  tu.fishHidden = true
  return vc
end
local function vh()
  if not tu.fishHidden then
    return 0
  end
  local vi = 0
  for vj, vk in ipairs(tu.hiddenFish) do
    if vk.obj then
      pcall(function()
        vk.obj.Parent = (vk.parent or workspace)
        vi += 1
      end)
    end
  end
  tu.hiddenFish = {}
  tu.fishHidden = false
  return vi
end
local vl = game:GetService("CoreGui"):FindFirstChild("CustomAutoMutasiUI")
if vl then
  vl:Destroy()
end
local vm = Instance.new("ScreenGui")
vm.Name = "CustomAutoMutasiUI"
vm.ResetOnSpawn = false
vm.Parent = game:GetService("CoreGui")
local vn = Instance.new("Frame")
vn.Name = "MainFrame"
vn.Size = UDim2.new(0, 600, 0, 450)
vn.Position = UDim2.new(0.5, -300, 0.5, -225)
vn.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
vn.BorderSizePixel = 0
vn.Active = true
vn.Draggable = true
vn.ClipsDescendants = true
vn.Parent = vm
Instance.new("UICorner", vn).CornerRadius = UDim.new(0, 8)
local vo = Instance.new("Frame")
vo.Name = "TopBar"
vo.Size = UDim2.new(1, 0, 0, 45)
vo.BackgroundTransparency = 1
vo.ZIndex = 2
vo.Parent = vn
local vp = Instance.new("TextLabel")
vp.Size = UDim2.new(1, -150, 1, 0)
vp.Position = UDim2.new(0, 20, 0, 0)
vp.BackgroundTransparency = 1
vp.Text = "Farm A Fish | by IQI"
vp.TextColor3 = Color3.fromRGB(255, 255, 255)
vp.TextXAlignment = Enum.TextXAlignment.Left
vp.Font = Enum.Font.GothamBold
vp.TextSize = 18
vp.Parent = vo
local vq = Instance.new("TextLabel")
vq.Size = UDim2.new(0, 44, 0, 25)
vq.Position = UDim2.new(1, -120, 0.5, -12)
vq.BackgroundColor3 = Color3.fromRGB(15, 20, 28)
vq.Text = "--"
vq.TextColor3 = Color3.fromRGB(120, 255, 120)
vq.Font = Enum.Font.GothamBold
vq.TextSize = 11
vq.BorderSizePixel = 0
vq.Parent = vo
Instance.new("UICorner", vq).CornerRadius = UDim.new(0, 5)
local vr = Instance.new("TextButton")
vr.Size = UDim2.new(0, 30, 0, 30)
vr.Position = UDim2.new(1, -80, 0.5, -15)
vr.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
vr.Text = "-"
vr.TextColor3 = Color3.fromRGB(255, 255, 255)
vr.Font = Enum.Font.GothamBold
vr.TextSize = 18
vr.Parent = vo
Instance.new("UICorner", vr).CornerRadius = UDim.new(0, 6)
local vs = Instance.new("TextButton")
vs.Size = UDim2.new(0, 30, 0, 30)
vs.Position = UDim2.new(1, -45, 0.5, -15)
vs.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
vs.Text = "X"
vs.TextColor3 = Color3.fromRGB(255, 255, 255)
vs.Font = Enum.Font.GothamBold
vs.TextSize = 16
vs.Parent = vo
Instance.new("UICorner", vs).CornerRadius = UDim.new(0, 6)
local vt = Instance.new("Frame")
vt.Name = "BodyContainer"
vt.Size = UDim2.new(1, 0, 1, -45)
vt.Position = UDim2.new(0, 0, 0, 45)
vt.BackgroundTransparency = 1
vt.Parent = vn
local vu = Instance.new("Frame")
vu.Size = UDim2.new(0, 150, 1, -40)
vu.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
vu.Parent = vt
Instance.new("UICorner", vu).CornerRadius = UDim.new(0, 8)
local function vv(vw, vx)
  local vy = Instance.new("TextButton")
  vy.Size = UDim2.new(0.9, 0, 0, 35)
  vy.Position = UDim2.new(0.05, 0, 0, vx)
  vy.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
  vy.Text = vw
  vy.TextColor3 = Color3.fromRGB(150, 150, 150)
  vy.Font = Enum.Font.Gotham
  vy.TextSize = 14
  vy.Parent = vu
  Instance.new("UICorner", vy).CornerRadius = UDim.new(0, 6)
  return vy
end
local vz = vv("Auto Mutasi", 15)
local wa = vv("Shop", 55)
local wb = vv("Craft & Food", 95)
local wc = vv("Event", 135)
local wd = vv("Boost & Webhook", 175)
local function we()
  local wf = Instance.new("Frame")
  wf.Size = UDim2.new(1, -150, 1, -40)
  wf.Position = UDim2.new(0, 150, 0, 0)
  wf.BackgroundTransparency = 1
  wf.Visible = false
  wf.Parent = vt
  return wf
end
local wg = we()
local wh = we()
local wi = we()
local wj = we()
local wk = we()
wg.Visible = true
local function wl(wm)
  local wn = Instance.new("ScrollingFrame")
  wn.Size = UDim2.new(1, -20, 1, -20)
  wn.Position = UDim2.new(0, 10, 0, 10)
  wn.BackgroundTransparency = 1
  wn.BorderSizePixel = 0
  wn.ScrollBarThickness = 6
  wn.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 100)
  wn.CanvasSize = UDim2.new(0, 0, 0, 0)
  wn.AutomaticCanvasSize = Enum.AutomaticSize.Y
  wn.Parent = wm
  Instance.new("UIListLayout", wn).Padding = UDim.new(0, 8)
  return wn
end
local wo = wl(wg)
local wp = wl(wh)
local wq = wl(wi)
local wr = wl(wj)
local ws = wl(wk)
local wt = Instance.new("Frame")
wt.Size = UDim2.new(1, 0, 0, 55)
wt.Position = UDim2.new(0, 0, 1, -55)
wt.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
wt.Parent = vt
Instance.new("UICorner", wt).CornerRadius = UDim.new(0, 8)
local wu = Instance.new("TextLabel")
wu.Size = UDim2.new(1, -20, 1, 0)
wu.Position = UDim2.new(0, 10, 0, 0)
wu.BackgroundTransparency = 1
wu.Text = "Status: IDLE"
wu.TextColor3 = Color3.fromRGB(200, 200, 200)
wu.TextXAlignment = Enum.TextXAlignment.Left
wu.Font = Enum.Font.Gotham
wu.TextSize = 10
wu.TextWrapped = true
wu.Parent = wt
local wv = Instance.new("TextButton")
wv.Size = UDim2.new(0, 56, 0, 28)
wv.Position = UDim2.new(0, 10, 0, 10)
wv.BackgroundColor3 = Color3.fromRGB(30, 35, 50)
wv.Text = "⛔"
wv.TextColor3 = Color3.fromRGB(255, 255, 255)
wv.Font = Enum.Font.GothamBold
wv.TextSize = 14
wv.BorderSizePixel = 0
wv.Visible = false
wv.Active = true
wv.Draggable = true
wv.Parent = vm
Instance.new("UICorner", wv).CornerRadius = UDim.new(0, 6)
vr.MouseButton1Click:Connect(function()
  aw.minimized = true
  vn.Visible = false
  wv.Visible = true
end)
wv.MouseButton1Click:Connect(function()
  aw.minimized = false
  vn.Visible = true
  wv.Visible = false
end)
vs.MouseButton1Click:Connect(function()
  vm:Destroy()
  aw.gOn, aw.bOn, aw.eOn, aw.gdOn = false, false, false, false
  al.FoodOn, al.CraftOn = false, false
  av.isRunning = false
  bt()
  iz()
  jb()
end)
local function ww(wx, wy)
  wg.Visible = (wx == wg)
  wh.Visible = (wx == wh)
  wi.Visible = (wx == wi)
  wj.Visible = (wx == wj)
  wk.Visible = (wx == wk)
  local wz = {vz, wa, wb, wc, wd}
  for xa, xb in ipairs(wz) do
    xb.BackgroundColor3 = (((xb == wy) and Color3.fromRGB(50, 50, 60)) or Color3.fromRGB(35, 35, 40))
    xb.TextColor3 = (((xb == wy) and Color3.fromRGB(255, 255, 255)) or Color3.fromRGB(150, 150, 150))
  end
end
vz.MouseButton1Click:Connect(function()
  ww(wg, vz)
end)
wa.MouseButton1Click:Connect(function()
  ww(wh, wa)
end)
wb.MouseButton1Click:Connect(function()
  ww(wi, wb)
end)
wc.MouseButton1Click:Connect(function()
  ww(wj, wc)
end)
wd.MouseButton1Click:Connect(function()
  ww(wk, wd)
end)
local function xc(xd, xe, xf, xg)
  local xh = Instance.new("TextButton")
  xh.Size = UDim2.new(1, 0, 0, 40)
  xh.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
  xh.Text = ("  " .. xd)
  xh.TextColor3 = Color3.fromRGB(255, 255, 255)
  xh.TextXAlignment = Enum.TextXAlignment.Left
  xh.Font = Enum.Font.Gotham
  xh.TextSize = 14
  xh.Parent = xf
  Instance.new("UICorner", xh).CornerRadius = UDim.new(0, 6)
  local xi = Instance.new("Frame")
  xi.Size = UDim2.new(0, 36, 0, 20)
  xi.Position = UDim2.new(1, -46, 0.5, -10)
  xi.BackgroundColor3 = ((xe and Color3.fromRGB(0, 150, 255)) or Color3.fromRGB(80, 80, 80))
  xi.Parent = xh
  Instance.new("UICorner", xi).CornerRadius = UDim.new(1, 0)
  local xj = Instance.new("Frame")
  xj.Size = UDim2.new(0, 16, 0, 16)
  xj.Position = ((xe and UDim2.new(1, -18, 0.5, -8)) or UDim2.new(0, 2, 0.5, -8))
  xj.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
  xj.Parent = xi
  Instance.new("UICorner", xj).CornerRadius = UDim.new(1, 0)
  local xk = xe
  xh.MouseButton1Click:Connect(function()
    xk = not xk
    xi.BackgroundColor3 = ((xk and Color3.fromRGB(0, 150, 255)) or Color3.fromRGB(80, 80, 80))
    xj.Position = ((xk and UDim2.new(1, -18, 0.5, -8)) or UDim2.new(0, 2, 0.5, -8))
    xg(xk)
  end)
end
local function xl(xm, xn, xo, xp)
  local xq = Instance.new("Frame")
  xq.Size = UDim2.new(1, 0, 0, 40)
  xq.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
  xq.Parent = xo
  Instance.new("UICorner", xq).CornerRadius = UDim.new(0, 6)
  local xr = Instance.new("TextLabel")
  xr.Size = UDim2.new(0.4, 0, 1, 0)
  xr.Position = UDim2.new(0, 10, 0, 0)
  xr.BackgroundTransparency = 1
  xr.Text = xm
  xr.TextColor3 = Color3.fromRGB(255, 255, 255)
  xr.TextXAlignment = Enum.TextXAlignment.Left
  xr.Font = Enum.Font.Gotham
  xr.TextSize = 14
  xr.Parent = xq
  local xs = Instance.new("TextBox")
  xs.Size = UDim2.new(0.55, -20, 0, 26)
  xs.Position = UDim2.new(0.4, 10, 0.5, -13)
  xs.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
  xs.Text = tostring(xn)
  xs.TextColor3 = Color3.fromRGB(255, 255, 255)
  xs.Font = Enum.Font.Gotham
  xs.TextSize = 14
  xs.Parent = xq
  Instance.new("UICorner", xs).CornerRadius = UDim.new(0, 4)
  xs.FocusLost:Connect(function()
    xp(xs.Text)
  end)
end
local function xt(xu, xv, xw, xx)
  local xy = Instance.new("Frame")
  xy.Size = UDim2.new(1, 0, 0, 40)
  xy.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
  xy.ClipsDescendants = true
  xy.Parent = xv
  Instance.new("UICorner", xy).CornerRadius = UDim.new(0, 6)
  local xz = Instance.new("TextButton")
  xz.Size = UDim2.new(1, 0, 0, 40)
  xz.BackgroundTransparency = 1
  xz.Text = ("  " .. (xu .. " "))
  xz.TextColor3 = Color3.fromRGB(255, 255, 255)
  xz.TextXAlignment = Enum.TextXAlignment.Left
  xz.Font = Enum.Font.Gotham
  xz.TextSize = 14
  xz.Parent = xy
  local ya = nil
  local yb, yc
  local yd = 45
  local ye = 150
  if xx then
    ya = Instance.new("Frame")
    ya.Size = UDim2.new(1, -20, 0, 26)
    ya.Position = UDim2.new(0, 10, 0, 45)
    ya.BackgroundTransparency = 1
    ya.Visible = false
    ya.Parent = xy
    yb = Instance.new("TextButton")
    yb.Size = UDim2.new(0.48, 0, 1, 0)
    yb.Position = UDim2.new(0, 0, 0, 0)
    yb.BackgroundColor3 = Color3.fromRGB(0, 130, 90)
    yb.Text = "✅ Select All"
    yb.TextColor3 = Color3.fromRGB(255, 255, 255)
    yb.Font = Enum.Font.GothamBold
    yb.TextSize = 12
    yb.Parent = ya
    Instance.new("UICorner", yb).CornerRadius = UDim.new(0, 4)
    yc = Instance.new("TextButton")
    yc.Size = UDim2.new(0.48, 0, 1, 0)
    yc.Position = UDim2.new(0.52, 0, 0, 0)
    yc.BackgroundColor3 = Color3.fromRGB(160, 50, 50)
    yc.Text = "✖ Clear All"
    yc.TextColor3 = Color3.fromRGB(255, 255, 255)
    yc.Font = Enum.Font.GothamBold
    yc.TextSize = 12
    yc.Parent = ya
    Instance.new("UICorner", yc).CornerRadius = UDim.new(0, 4)
    yd = 76
  end
  local yf = Instance.new("ScrollingFrame")
  yf.Size = UDim2.new(1, -20, 0, ye)
  yf.Position = UDim2.new(0, 10, 0, yd)
  yf.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
  yf.BorderSizePixel = 0
  yf.Visible = false
  yf.ScrollBarThickness = 6
  yf.CanvasSize = UDim2.new(0, 0, 0, 0)
  yf.AutomaticCanvasSize = Enum.AutomaticSize.Y
  yf.Parent = xy
  Instance.new("UICorner", yf).CornerRadius = UDim.new(0, 4)
  local yg = Instance.new("UIListLayout")
  yg.Padding = UDim.new(0, 2)
  yg.SortOrder = Enum.SortOrder.LayoutOrder
  yg.Parent = yf
  local yh = false
  local yi = {}
  local yj = {}
  local function yk()
    local yl = {}
    for ym, yn in pairs(yi) do
      table.insert(yl, ym)
    end
    xw(yl)
  end
  local function yo(yp, yq)
    if yi[yq] then
      yp.BackgroundColor3 = Color3.fromRGB(0, 100, 200)
      yp.TextColor3 = Color3.fromRGB(255, 255, 255)
    else
      yp.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
      yp.TextColor3 = Color3.fromRGB(200, 200, 200)
    end
  end
  if yb then
    yb.MouseButton1Click:Connect(function()
      for yr, ys in ipairs(yj) do
        yi[ys] = true
      end
      for yt, yu in ipairs(yf:GetChildren()) do
        if yu:IsA("TextButton") then
          local yv = yu:GetAttribute("ItemKey")
          if yv then
            yo(yu, yv)
          end
        end
      end
      yk()
    end)
  end
  if yc then
    yc.MouseButton1Click:Connect(function()
      yi = {}
      for yw, yx in ipairs(yf:GetChildren()) do
        if yx:IsA("TextButton") then
          local yy = yx:GetAttribute("ItemKey")
          if yy then
            yo(yx, yy)
          end
        end
      end
      yk()
    end)
  end
  xz.MouseButton1Click:Connect(function()
    yh = not yh
    yf.Visible = yh
    if ya then
      ya.Visible = yh
    end
    if yh then
      local yz = ((yd + ye) + 5)
      xy.Size = UDim2.new(1, 0, 0, yz)
    else
      xy.Size = UDim2.new(1, 0, 0, 40)
    end
    xz.Text = ("  " .. (xu .. (((yh and " ") or " "))))
  end)
  local function za(zb)
    yj = zb
    for zc, zd in ipairs(yf:GetChildren()) do
      if zd:IsA("TextButton") then
        zd:Destroy()
      end
    end
    for ze, zf in ipairs(zb) do
      local zg = Instance.new("TextButton")
      zg.Size = UDim2.new(1, 0, 0, 30)
      zg.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
      zg.Text = ("  " .. zf)
      zg.TextColor3 = Color3.fromRGB(200, 200, 200)
      zg.TextXAlignment = Enum.TextXAlignment.Left
      zg.Font = Enum.Font.Gotham
      zg.TextSize = 13
      zg.Parent = yf
      zg:SetAttribute("ItemKey", zf)
      yo(zg, zf)
      zg.MouseButton1Click:Connect(function()
        if yi[zf] then
          yi[zf] = nil
        else
          yi[zf] = true
        end
        yo(zg, zf)
        yk()
      end)
    end
  end
  return {Update = za, Frame = xy}
end
local function zh(zi, zj, zk)
  local zl = Instance.new("TextButton")
  zl.Size = UDim2.new(1, 0, 0, 40)
  zl.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
  zl.Text = zj
  zl.TextColor3 = Color3.fromRGB(255, 255, 255)
  zl.Font = Enum.Font.GothamBold
  zl.TextSize = 14
  zl.Parent = zi
  Instance.new("UICorner", zl).CornerRadius = UDim.new(0, 6)
  zl.MouseButton1Click:Connect(zk)
end
local zm = false
xc("Start Auto Mutasi", false, wo, function(zn)
  zm = zn
  av.isRunning = zn
  if av.isRunning then
    if (next(av.targetPets) == nil) then
      warn("Pilih Pet Target dulu!")
      return
    end
    if not jx() then
      warn("Pilih target mutasi dulu!")
      return
    end
    qr()
    av.placedPets = {}
    av.pickedUpPets = {}
    av.placedLeveling = {}
    av.placedSpeedup = {}
    av.mutationInProgress = {}
    av.processedMutation = {}
    av.currentLoadout = nil
    av.lastLoadoutSwitch = 0
    av.totalBoosted = 0
    av.totalMutated = 0
    av.cycleCount = 0
    av.jumperCounter = 0
    av.lastJumperFire = 0
    av.lastMutationAction = 0
    av.boostJumperCount = 0
    av.boostLoadoutSwitching = false
    av.lastJumperEmptyNotify = 0
    av.collectSetupDone = false
    task.spawn(tn)
  end
end)
local zr = xt("Target Mutasi", wo, function(zo)
  av.selectedMutations = {}
  for zp, zq in ipairs(zo) do
    av.selectedMutations[zq] = true
  end
end)
zr.Update(am)
xl("Max Place Target", av.maxPlacePerWave, wo, function(zs)
  local zt = tonumber(zs)
  if zt then
    av.maxPlacePerWave = math.floor(zt)
  end
end)
local zu, zv, zw, zx = {}, {}, {}, {}
local aac = xt("Pet Leveling", wo, function(zy)
  av.levelingPets = {}
  for zz, aaa in ipairs(zy) do
    local aab = zu[aaa]
    if aab then
      av.levelingPets[aab] = true
    end
  end
end)
local aah = xt("Pet Boost Mesin", wo, function(aad)
  av.speedupPets = {}
  for aae, aaf in ipairs(aad) do
    local aag = zv[aaf]
    if aag then
      av.speedupPets[aag] = true
    end
  end
end)
local aam = xt("Pet Target", wo, function(aai)
  av.targetPets = {}
  for aaj, aak in ipairs(aai) do
    local aal = zw[aak]
    if aal then
      av.targetPets[aal] = true
    end
  end
end, true)
local aar = xt("Pet Collect", wo, function(aan)
  av.collectPets = {}
  for aao, aap in ipairs(aan) do
    local aaq = zx[aap]
    if aaq then
      av.collectPets[aaq] = true
    end
  end
end)
zh(wo, "Scan Pet", function()
  if av.isRunning then
    warn("Stop dulu sebelum scan.")
    return
  end
  local aas = mi()
  local aat = nj(au.leveling)
  local aau = nj(au.speedup)
  local aav = nj(au.collect)
  av.petList = aas
  av.petById = {}
  zu, zv, zw, zx = {}, {}, {}, {}
  local aaw, aax, aay, aaz = {}, {}, {}, {}
  for aba, abb in ipairs(aat) do
    av.petById[abb.id] = abb
    table.insert(aaw, abb.label)
    zu[abb.label] = abb.id
  end
  for abc, abd in ipairs(aau) do
    av.petById[abd.id] = abd
    table.insert(aax, abd.label)
    zv[abd.label] = abd.id
  end
  for abe, abf in ipairs(aas) do
    av.petById[abf.id] = abf
    table.insert(aay, abf.label)
    zw[abf.label] = abf.id
  end
  for abg, abh in ipairs(aav) do
    av.petById[abh.id] = abh
    table.insert(aaz, abh.label)
    zx[abh.label] = abh.id
  end
  aac.Update(aaw)
  aah.Update(aax)
  aam.Update(aay)
  aar.Update(aaz)
end)
zh(wo, "Clear All Selection", function()
  if av.isRunning then
    warn("[Clear] Stop dulu.")
    return
  end
  av.levelingPets, av.speedupPets, av.targetPets, av.collectPets = {}, {}, {}, {}
  aac.Update({})
  aah.Update({})
  aam.Update({})
  aar.Update({})
end)
xc("Auto PetToy", false, wo, function(abi)
  av.useAutoPetToy = abi
end)
xc("Auto Cookie", false, wo, function(abj)
  av.useAutoCookie = abj
end)
xc("Auto Buy Gear", false, wp, function(abk)
  aw.gOn = abk
  aw.nextGear = 0
end)
xc("Auto Buy Bait", false, wp, function(abl)
  aw.bOn = abl
  aw.nextBait = 0
end)
xc("Auto Buy Egg", false, wp, function(abm)
  aw.eOn = abm
  aw.nextEgg = 0
end)
xc("Auto Buy Golden Merchant", false, wp, function(abn)
  aw.gdOn = abn
  aw.nextGolden = 0
end)
xc("Auto Craft (TimeJumper Only)", false, wq, function(abo)
  al.CraftOn = abo
  aw._nextCraftTry = 0
  if not al.CraftOn then
    aw.cPhase = "idle"
    aw.cCd = 0
  end
end)
xc("Auto Place Food (Supreme/Advanced/Basic)", false, wq, function(abp)
  al.FoodOn = abp
  aw.nextPlace = 0
end)
xc("Auto Collect Halloween Fish", false, wr, function(abq)
  aw.hwCollect = abq
  if abq then
    iy()
  else
    iz()
  end
end)
xc("Auto Feed & Pickup Halloween", false, wr, function(abr)
  aw.hwFeedPickup = abr
  if abr then
    ja()
  else
    jb()
  end
end)
xc("Super FPS Boost", false, ws, function(abs)
  task.spawn(function()
    if (abs and not tu.boosted) then
      uj()
    elseif (not abs and tu.boosted) then
      us()
    end
  end)
end)
xc("Hide Fish", false, ws, function(abt)
  task.spawn(function()
    if (abt and not tu.fishHidden) then
      vb()
    elseif (not abt and tu.fishHidden) then
      vh()
    end
  end)
end)
local abu = Instance.new("Frame")
abu.Size = UDim2.new(1, 0, 0, 65)
abu.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
abu.ClipsDescendants = true
abu.Parent = ws
Instance.new("UICorner", abu).CornerRadius = UDim.new(0, 6)
local abv = Instance.new("TextLabel")
abv.Size = UDim2.new(1, -20, 0, 25)
abv.Position = UDim2.new(0, 10, 0, 5)
abv.BackgroundTransparency = 1
abv.Text = "🔗 Discord Webhook URL (Khusus Mutasi)"
abv.TextColor3 = Color3.fromRGB(255, 255, 255)
abv.TextXAlignment = Enum.TextXAlignment.Left
abv.Font = Enum.Font.GothamBold
abv.TextSize = 12
abv.Parent = abu
local abw = Instance.new("TextBox")
abw.Size = UDim2.new(1, -20, 0, 28)
abw.Position = UDim2.new(0, 10, 0, 30)
abw.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
abw.Text = bu.url
abw.PlaceholderText = "https://discord.com/api/webhooks/..."
abw.TextColor3 = Color3.fromRGB(255, 255, 255)
abw.Font = Enum.Font.Gotham
abw.TextSize = 12
abw.TextXAlignment = Enum.TextXAlignment.Left
abw.ClearTextOnFocus = false
abw.ClipsDescendants = true
abw.Parent = abu
Instance.new("UICorner", abw).CornerRadius = UDim.new(0, 4)
abw.FocusLost:Connect(function()
  bu.url = abw.Text
  if abw.Text:find("https://discord.com/api/webhooks/") then
    print("[Webhook] ✅ URL Valid disimpan.")
  else
    warn("[Webhook] ❌ URL tidak valid! Pastikan link Discord Webhook.")
  end
end)
xc("Aktifkan Webhook", true, ws, function(abx)
  bu.enabled = abx
end)
xc("Notif TimeJumper Habis", true, ws, function(aby)
  bu.notifyJumperEmpty = aby
end)
zh(ws, "🧪 Test Webhook", function()
  bu.url = abw.Text
  if (bu.url == "") then
    warn("[Webhook] URL kosong. Paste link dulu di kotak atas.")
    return
  end
  local abz = {title = "🧪 Test Webhook Berhasil", description = "Koneksi dari Farm A fish berjalan dengan baik!", color = 0x00FF00, fields = {{name = "👤 Player", value = tostring(bz()), inline = true}, {name = "⏱️ TimeJumper Sisa", value = tostring(cg()), inline = true}}, footer = {text = "Farm A fish | by bang iqi"}, timestamp = DateTime.now():ToIsoDate()}
  bv({username = bu.username, embeds = {abz}})
end)
frameCount, fpsAccum, lastFpsUpdate = 0, 0, os.clock()
RunService.RenderStepped:Connect(function(aca)
  frameCount += 1
  fpsAccum += aca
  local acb = os.clock()
  if ((acb - lastFpsUpdate) >= 0.5) then
    fps = math.floor(((frameCount / fpsAccum) + 0.5))
    if (fps >= 50) then
      col = Color3.fromRGB(120, 255, 120)
    elseif (fps >= 30) then
      col = Color3.fromRGB(255, 220, 100)
    else
      col = Color3.fromRGB(255, 100, 100)
    end
    pcall(function()
      vq.Text = tostring(fps)
      vq.TextColor3 = col
    end)
    frameCount = 0
    fpsAccum = 0
    lastFpsUpdate = acb
  end
end)
task.spawn(function()
  while true do
    task.wait(1)
    jc()
    local acc, acd = pr()
    local ace = #of()
    local acf = 0
    for acg in pairs(av.mutationInProgress) do
      acf = (acf + 1)
    end
    local ach, aci, acj = 0, 0, 0
    local ack = b()
    if (ack and ack.inventory) then
      for acl, acm in pairs(ack.inventory.pets) do
        if av.targetPets[acl] then
          ach = (ach + 1)
          local acn = dd(acm)
          if jz(acn) then
            aci = (aci + 1)
          end
          if (cz(acm) >= al.TargetAge) then
            acj = (acj + 1)
          end
        end
      end
    end
    local aco = tostring(((av.collectSetupDone and "SET") or "PENDING"))
    local acp = string.format("Fase: %s | W: %d/%d | Tgt: %d/%d | Q: %d | Mut: %d | Lvl: %d | Spd: %d | LO: %s | Jmp: %d/%d | Col: %s", av.wavePhase:upper(), acc, acd, aci, ach, ace, av.totalMutated, #oo(), #ow(), tostring(av.currentLoadout), av.boostJumperCount, al.JumperBeforeSwitch, aco)
    pcall(function()
      wu.Text = acp
    end)
  end
end)