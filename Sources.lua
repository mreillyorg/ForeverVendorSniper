local ns = ForeverVendorSniper
-- External pricing addons may expose historical prices, not live auction indices.
-- Never use their cached prices to authorize a purchase.
function ns.DetectSources()
    local sources = { "Native AH" }
    if type(IsAddOnLoaded) == "function" then
        if IsAddOnLoaded("Auctionator") then table.insert(sources, "Auctionator (detected)") end
        if IsAddOnLoaded("TradeSkillMaster") or IsAddOnLoaded("TSM") then table.insert(sources, "TSM (detected)") end
    end
    return sources
end
