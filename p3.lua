if not (_G.ITEMS_FINDER and _G.ITEMS_FINDER.F) then return end
local F = _G.ITEMS_FINDER.F

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local localPlayer = Players.LocalPlayer

local function mkStroke(parent, color, thick)
    local s = Instance.new("UIStroke")
    s.Color = color or F.C.bd
    s.Thickness = thick or 1
    s.Parent = parent
    return s
end

local function mkPad(parent, t, b, l, r)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, t or 0)
    p.PaddingBottom = UDim.new(0, b or 0)
    p.PaddingLeft   = UDim.new(0, l or 0)
    p.PaddingRight  = UDim.new(0, r or 0)
    p.Parent = parent
end

local pg = localPlayer:WaitForChild("PlayerGui")
local old = pg:FindFirstChild("ItemsFinderGUI")
if old then old:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "ItemsFinderGUI"
gui.ResetOnSpawn = false
gui.DisplayOrder = 100
gui.Parent = pg

local win = Instance.new("Frame")
win.Size = UDim2.new(0, 224, 0, 0)
win.Position = UDim2.new(0, 20, 0, 20)
win.BackgroundColor3 = F.C.b1
win.BorderSizePixel = 0
win.AutomaticSize = Enum.AutomaticSize.Y
win.ClipsDescendants = true
win.Parent = gui
mkStroke(win, F.C.ac)

local winList = Instance.new("UIListLayout")
winList.SortOrder = Enum.SortOrder.LayoutOrder
winList.Padding = UDim.new(0, 0)
winList.Parent = win

local titleBar = Instance.new("Frame")
titleBar.Size = UDim2.new(1, 0, 0, 24)
titleBar.BackgroundColor3 = F.C.b0
titleBar.BorderSizePixel = 0
titleBar.LayoutOrder = 0
titleBar.Parent = win
mkStroke(titleBar, F.C.ac)

local tList = Instance.new("UIListLayout")
tList.FillDirection = Enum.FillDirection.Horizontal
tList.VerticalAlignment = Enum.VerticalAlignment.Center
tList.Padding = UDim.new(0, 5)
tList.Parent = titleBar
mkPad(titleBar, 0, 0, 10, 8)

local function tLbl(parent, text, size, color, bold)
    local l = Instance.new("TextLabel")
    l.Text = text
    l.TextSize = size
    l.TextColor3 = color
    l.Font = bold and Enum.Font.GothamBold or Enum.Font.Code
    l.BackgroundTransparency = 1
    l.AutomaticSize = Enum.AutomaticSize.X
    l.Size = UDim2.new(0, 0, 1, 0)
    l.TextXAlignment = Enum.TextXAlignment.Left
    l.Parent = parent
end

tLbl(titleBar, "ITEMS FINDER", 11, F.C.ac3, true)
tLbl(titleBar, "|", 10, F.C.ac, false)
tLbl(titleBar, "by 7g0d", 13, F.C.t1, false)

local dragging, dragStart, startPos = false, nil, nil
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = win.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local d = input.Position - dragStart
        win.Position = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + d.X,
            startPos.Y.Scale, startPos.Y.Offset + d.Y
        )
    end
end)

for i, item in ipairs(F.ITEMS) do
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 22)
    row.BackgroundColor3 = F.C.b1
    row.BorderSizePixel = 0
    row.LayoutOrder = i
    row.Parent = win
    mkStroke(row, F.C.bd)

    local rList = Instance.new("UIListLayout")
    rList.FillDirection = Enum.FillDirection.Horizontal
    rList.VerticalAlignment = Enum.VerticalAlignment.Center
    rList.Padding = UDim.new(0, 5)
    rList.Parent = row
    mkPad(row, 0, 0, 8, 6)

    local ind = Instance.new("TextLabel")
    ind.Size = UDim2.new(0, 12, 0, 12)
    ind.BackgroundTransparency = 1
    ind.BorderSizePixel = 0
    ind.Text = ""
    ind.TextSize = 11
    ind.Font = Enum.Font.Code
    ind.TextColor3 = F.C.t3
    ind.TextXAlignment = Enum.TextXAlignment.Center
    ind.TextYAlignment = Enum.TextYAlignment.Center
    ind.Parent = row

    F.indicators[item.name] = ind

    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(0, 44, 0, 15)
    btn.Text = "FIND"
    btn.TextSize = 9
    btn.Font = Enum.Font.GothamBold
    btn.BackgroundColor3 = F.C.b3
    btn.TextColor3 = F.C.t3
    btn.BorderSizePixel = 0
    btn.Parent = row
    mkStroke(btn, F.C.bd)

    local lbl = Instance.new("TextLabel")
    lbl.Size = UDim2.new(1, -75, 1, 0)
    lbl.Text = item.name
    lbl.TextSize = 10
    lbl.Font = Enum.Font.Code
    lbl.TextColor3 = F.C.t1
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.TextTruncate = Enum.TextTruncate.AtEnd
    lbl.Parent = row

    row.MouseEnter:Connect(function() row.BackgroundColor3 = F.C.b2 end)
    row.MouseLeave:Connect(function() row.BackgroundColor3 = F.C.b1 end)

    btn.MouseButton1Click:Connect(function()
        F.isFinding[item.name] = not F.isFinding[item.name]

        if F.isFinding[item.name] then
            btn.Text = "ON"
            btn.BackgroundColor3 = F.C.b3
            btn.TextColor3 = F.C.ac3
            F.setIndicator(item.name, "searching")
        else
            F.isFinding[item.name] = false
            btn.Text = "FIND"
            btn.BackgroundColor3 = F.C.b3
            btn.TextColor3 = F.C.t3
            F.setIndicator(item.name, "idle")

            for _, dealer in ipairs(F.foundDealers[item.name]) do
                F.setHighlight(dealer, false)
            end
            F.foundDealers[item.name] = {}
        end
    end)
end

local killBtn = Instance.new("TextButton")
killBtn.Size = UDim2.new(1, 0, 0, 22)
killBtn.BackgroundColor3 = F.C.offB
killBtn.Text = "Unload"
killBtn.TextSize = 10
killBtn.Font = Enum.Font.GothamBold
killBtn.TextColor3 = F.C.offC
killBtn.BorderSizePixel = 0
killBtn.AutoButtonColor = false
killBtn.LayoutOrder = 999
killBtn.Parent = win

killBtn.MouseEnter:Connect(function() killBtn.BackgroundColor3 = F.C.b3 end)
killBtn.MouseLeave:Connect(function() killBtn.BackgroundColor3 = F.C.offB end)

killBtn.MouseButton1Click:Connect(function()
    if F.updateConnection then
        F.updateConnection:Disconnect()
        F.updateConnection = nil
    end
    for _, conn in pairs(F.spinConnections) do
        if conn then conn:Disconnect() end
    end
    F.spinConnections = {}
    F.clearHighlights()
    gui:Destroy()
end)

if _G.ITEMS_FINDER and _G.ITEMS_FINDER.F and _G.ITEMS_FINDER.F.startScanning then
    _G.ITEMS_FINDER.F.startScanning()
end
