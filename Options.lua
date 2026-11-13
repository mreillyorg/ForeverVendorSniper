local ns = ForeverVendorSniper
function ns.SetMinimumProfit(copper)
    if type(copper) ~= "number" or copper < 0 then return false end
    ns.db.minProfit = math.floor(copper)
    return true
end
function ns.SetMinimumDiscount(percent)
    if type(percent) ~= "number" or percent < 0 or percent > 100 then return false end
    ns.db.minDiscount = percent
    return true
end
