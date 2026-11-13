local ns = ForeverVendorSniper
ns.vendorCache = {}
function ns.GetVendorUnit(itemLink)
    if not itemLink or type(GetItemInfo) ~= "function" then return nil end
    local itemID = string.match(itemLink, "item:(%d+)")
    if itemID and ns.vendorCache[itemID] then return ns.vendorCache[itemID] end
    local _, _, _, _, _, _, _, _, _, _, sellPrice = GetItemInfo(itemLink)
    if type(sellPrice) == "number" and sellPrice > 0 then
        if itemID then ns.vendorCache[itemID] = sellPrice end
        return sellPrice
    end
    return nil
end
