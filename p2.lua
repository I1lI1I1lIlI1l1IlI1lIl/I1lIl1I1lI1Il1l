if not (_G.ITEMS_FINDER and _G.ITEMS_FINDER.authorized) then return end

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local F = {}
_G.ITEMS_FINDER.F = F

F.C = {
    b0   = Color3.fromRGB(14, 4, 4),
    b1   = Color3.fromRGB(22, 6, 6),
    b2   = Color3.fromRGB(34, 10, 10),
    b3   = Color3.fromRGB(48, 14, 14),
    ac   = Color3.fromRGB(180, 20, 20),
    ac2  = Color3.fromRGB(220, 40, 40),
    ac3  = Color3.fromRGB(255, 70, 70),
    t1   = Color3.fromRGB(255, 200, 200),
    t2   = Color3.fromRGB(200, 120, 120),
    t3   = Color3.fromRGB(140, 70, 70),
    bd   = Color3.fromRGB(80, 20, 20),
    onB  = Color3.fromRGB(10, 50, 10),
    onC  = Color3.fromRGB(60, 200, 60),
    offB = Color3.fromRGB(50, 8, 8),
    offC = Color3.fromRGB(220, 40, 40),
}

F.ITEMS = {
    { name = "NecromancerKit",    stock = "__NecromancerKit" },
    { name = "SoulContract",      stock = "SoulContract"     },
    { name = "MonsterMashPotion", stock = "MonsterMashPotion"},
    { name = "CursedDagger",      stock = "CursedDagger"     },
    { name = "Corruptis",         stock = "Corruptis"        },
    { name = "X24",               stock = "X24"              },
    { name = "CopeCoin26",        stock = "_CopeCoin26"      },
    { name = "Relic",             stock = "Relic"            },
    { name = "SlayerKit",         stock = "__SlayerKit"      },
}

F.dealerHighlights = {}
F.isFinding = {}
F.spinConnections = {}
F.foundDealers = {}
for _, item in ipairs(F.ITEMS) do
    F.isFinding[item.name] = false
    F.foundDealers[item.name] = {}
end

F.indicators = {}
F.spinChars = {"|", "/", "-", string.char(92)}
F.spinIndex = {}
for _, item in ipairs(F.ITEMS) do
    F.spinIndex[item.name] = 1
end

function F.setHighlight(dealer, active)
    if active then
        if F.dealerHighlights[dealer] then return end
        local h = Instance.new("Highlight")
        h.Parent = dealer
        h.FillTransparency = 1
        h.OutlineTransparency = 0
        h.OutlineColor = Color3.fromRGB(220, 30, 30)
        h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        F.dealerHighlights[dealer] = h
    else
        if F.dealerHighlights[dealer] then
            F.dealerHighlights[dealer]:Destroy()
            F.dealerHighlights[dealer] = nil
        end
    end
end

function F.clearHighlights()
    for dealer, h in pairs(F.dealerHighlights) do
        if h then h:Destroy() end
    end
    F.dealerHighlights = {}
end

function F.setIndicator(itemName, state)
    local ind = F.indicators[itemName]
    if not ind then return end

    if F.spinConnections[itemName] then
        F.spinConnections[itemName]:Disconnect()
        F.spinConnections[itemName] = nil
    end

    if state == "searching" then
        F.spinIndex[itemName] = 1
        ind.Text = F.spinChars[1]
        ind.TextColor3 = Color3.fromRGB(180, 100, 100)
        local t = 0
        F.spinConnections[itemName] = RunService.RenderStepped:Connect(function(dt)
            t = t + dt
            if t >= 0.1 then
                t = 0
                F.spinIndex[itemName] = (F.spinIndex[itemName] % #F.spinChars) + 1
                ind.Text = F.spinChars[F.spinIndex[itemName]]
            end
        end)
    elseif state == "found" then
        ind.Text = "●"
        ind.TextColor3 = Color3.fromRGB(60, 200, 60)
    elseif state == "notfound" then
        ind.Text = "●"
        ind.TextColor3 = Color3.fromRGB(220, 40, 40)
    else
        ind.Text = ""
    end
end

function F.checkDealer(dealer, stockName)
    local cs = dealer:FindFirstChild("CurrentStocks")
    if not cs then return false end
    local stock = cs:FindFirstChild(stockName)
    return stock and stock:IsA("IntConstrainedValue") and stock.Value == 1
end

function F.scanItem(itemName, stockName)
    local map = workspace:FindFirstChild("Map")
    if not map then return false end
    local shopz = map:FindFirstChild("Shopz")
    if not shopz then return false end

    for _, dealer in ipairs(F.foundDealers[itemName]) do
        local stillNeeded = false
        for otherName, dealers in pairs(F.foundDealers) do
            if otherName ~= itemName and F.isFinding[otherName] then
                for _, d in ipairs(dealers) do
                    if d == dealer then stillNeeded = true break end
                end
            end
            if stillNeeded then break end
        end
        if not stillNeeded then F.setHighlight(dealer, false) end
    end
    F.foundDealers[itemName] = {}

    local found = false
    for _, dealer in ipairs(shopz:GetChildren()) do
        if dealer.Name == "Dealer" and F.checkDealer(dealer, stockName) then
            found = true
            table.insert(F.foundDealers[itemName], dealer)
            F.setHighlight(dealer, true)
        end
    end
    return found
end

F.startScanning = function()
    if F.updateConnection then return end
    local timer = 0
    F.updateConnection = RunService.Heartbeat:Connect(function(dt)
        timer = timer + dt
        if timer < 0.5 then return end
        timer = 0

        for _, item in ipairs(F.ITEMS) do
            if F.isFinding[item.name] then
                local found = F.scanItem(item.name, item.stock)
                F.setIndicator(item.name, found and "found" or "notfound")
            end
        end
    end)
end
