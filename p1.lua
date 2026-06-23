_G.ITEMS_FINDER = _G.ITEMS_FINDER or {}

local allowedHWIDs = {
    "72d7e5fd-b32a-11f0-a6c6-806e6f6e6963",
    "f5435083-36eb-11f1-9f7a-806e6f6e6963",
    "37663962643566383762626138386636363631653036376666323464643536323966393730633866373733313732633130656263633265653965633834626335",
    "766f6773-3bdd-11f1-aea1-806e6f6e6963",
    "8c403d10e09c565586836a585aea1989ade6aaff1314fb629a1b1de2bc0dc2a3370a83e25f3f7fab04d3d8e358d712596f96b24f0e524426b8075f370f7e82c5"
}
local allowedUserIDs = {
    7674072905
}

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function getHWID()
    if gethwid then
        return gethwid()
    elseif game:GetService("RbxAnalyticsService") then
        return game:GetService("RbxAnalyticsService"):GetClientId()
    end
    return nil
end

local currentHWID = getHWID()
local currentUserID = localPlayer and localPlayer.UserId

local authorizedByHWID = false
local authorizedByUserID = false

if currentHWID then
    for _, hwid in ipairs(allowedHWIDs) do
        if currentHWID == hwid then
            authorizedByHWID = true
            break
        end
    end
end

if currentUserID then
    for _, id in ipairs(allowedUserIDs) do
        if currentUserID == id then
            authorizedByUserID = true
            break
        end
    end
end

if not (authorizedByHWID or authorizedByUserID) then
    while true do end
end

_G.ITEMS_FINDER.authorized = true
