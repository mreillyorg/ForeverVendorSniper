local ns = ForeverVendorSniper
function ns.CalculateOpportunity(listing, minProfit, minDiscount)
    if type(listing) ~= "table" then return nil end
    local count, unit = listing.count, listing.vendorUnit
    if type(count) ~= "number" or count < 1 or count ~= math.floor(count) or type(unit) ~= "number" or unit <= 0 then return nil end
    local vendorTotal = count * unit
    local buyout = listing.buyout
    if type(buyout) ~= "number" or buyout <= 0 then return nil end
    local profit = vendorTotal - buyout
    local discount = profit / vendorTotal * 100
    if profit <= 0 or profit < (minProfit or 0) or discount < (minDiscount or 0) then return nil end
    local result = {}
    for k, v in pairs(listing) do result[k] = v end
    result.vendorTotal, result.profit, result.discount = vendorTotal, profit, discount
    return result
end
function ns.SortOpportunities(rows)
    table.sort(rows, function(a, b)
        if a.profit == b.profit then return (a.name or "") < (b.name or "") end
        return a.profit > b.profit
    end)
end
function ns.Money(amount)
    amount = math.floor(math.max(0, amount or 0))
    return string.format("%dg %02ds %02dc", math.floor(amount/10000), math.floor(amount/100)%100, amount%100)
end
