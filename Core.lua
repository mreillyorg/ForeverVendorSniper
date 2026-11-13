local addonName, ns = ...
ns = ns or {}
ForeverVendorSniper = ns
ns.name = addonName or "ForeverVendorSniper"
ns.version = "0.1.0-alpha"
ns.defaults = {
    theme = "Blizzard", customThemes = {}, minProfit = 100, minDiscount = 0,
    autoOpen = true, point = { "CENTER", "UIParent", "CENTER", 260, 0 },
}

local function mergeDefaults(target, defaults)
    for k, v in pairs(defaults) do
        if target[k] == nil then
            if type(v) == "table" then
                target[k] = {}
                mergeDefaults(target[k], v)
            else target[k] = v end
        elseif type(v) == "table" and type(target[k]) == "table" then
            mergeDefaults(target[k], v)
        end
    end
end
ns.MergeDefaults = mergeDefaults
function ns.Initialize()
    if type(ForeverVendorSniperDB) ~= "table" then ForeverVendorSniperDB = {} end
    mergeDefaults(ForeverVendorSniperDB, ns.defaults)
    ns.db = ForeverVendorSniperDB
    if ns.BuildUI then ns.BuildUI() end
end
if type(CreateFrame) == "function" then
    local eventFrame = CreateFrame("Frame")
    eventFrame:RegisterEvent("ADDON_LOADED")
    eventFrame:RegisterEvent("AUCTION_HOUSE_SHOW")
    eventFrame:RegisterEvent("AUCTION_HOUSE_CLOSED")
    eventFrame:SetScript("OnEvent", function(_, event, arg)
        if event == "ADDON_LOADED" and arg == ns.name then ns.Initialize()
        elseif event == "AUCTION_HOUSE_SHOW" then
            ns.auctionOpen = true
            if ns.db and ns.db.autoOpen and ns.ShowUI then ns.ShowUI() end
        elseif event == "AUCTION_HOUSE_CLOSED" then
            ns.auctionOpen = false
            if ns.StopScan then ns.StopScan("Auction House closed") end
            if ns.HideUI then ns.HideUI() end
        end
    end)
    SLASH_FOREVERVENDORSNIPER1 = "/fvs"
    SlashCmdList.FOREVERVENDORSNIPER = function(command)
        if string.sub(command, 1, 6) == "theme " and ns.ThemeCommand then
            local ok, message = ns.ThemeCommand(string.sub(command, 7))
            if DEFAULT_CHAT_FRAME then
                DEFAULT_CHAT_FRAME:AddMessage("FVS: " .. (message or (ok and "Theme updated" or "Invalid theme command")))
            end
        elseif command == "scan" and ns.StartScan then ns.StartScan()
        elseif ns.ToggleUI then ns.ToggleUI() end
    end
end
