local ns = _G.ForeverVendorSniper
ns.results = {}
ns.scan = { active = false, pending = false, page = 0, scanned = 0 }
local PAGE_SIZE = 50
local function notify(message)
    ns.status = message
    if ns.RefreshUI then ns.RefreshUI() end
end
function ns.StopScan(reason)
    ns.scan.active = false
    ns.scan.pending = false
    notify(reason or "Scan stopped")
end
function ns.QueryPage(page)
    if not ns.scan.active or not ns.auctionOpen then return false end
    if type(CanSendAuctionQuery) == "function" and not CanSendAuctionQuery() then
        ns.scan.active = false
        ns.scan.nextPage = page
        notify("AH query throttled; press Next Page to retry")
        return false
    end
    if type(QueryAuctionItems) ~= "function" then ns.StopScan("AH query API unavailable") return false end
    ns.scan.page = page
    ns.scan.pending = true
    -- Forever-specific query signature still needs in-game confirmation.
    local ok = pcall(QueryAuctionItems, "", nil, nil, page, false, nil, false, false, nil)
    if not ok then ns.StopScan("AH query failed; check API compatibility") return false end
    notify("Scanning page " .. tostring(page + 1))
    return true
end
function ns.StartScan()
    if not ns.auctionOpen then notify("Open an Auction House first") return false end
    if ns.scan.active then return false end
    ns.results = {}
    ns.scan = { active = true, pending = false, page = 0, scanned = 0 }
    return ns.QueryPage(0)
end
function ns.ProcessPage()
    if not ns.scan.active or not ns.scan.pending then return end
    if type(GetNumAuctionItems) ~= "function" or type(GetAuctionItemInfo) ~= "function" then
        ns.StopScan("AH listing API unavailable") return
    end
    ns.scan.pending = false
    local shown, total = GetNumAuctionItems("list")
    if type(shown) ~= "number" or shown < 0 then ns.StopScan("Invalid AH response") return end
    for index = 1, shown do
        local name, _, count, _, _, _, _, minBid, minIncrement, buyout, bidAmount = GetAuctionItemInfo("list", index)
        local link = type(GetAuctionItemLink) == "function" and GetAuctionItemLink("list", index) or nil
        local vendor = ns.GetVendorUnit(link)
        local bid = bidAmount and bidAmount > 0 and (bidAmount + (minIncrement or 0)) or minBid
        local listing = { name = name, link = link, count = count, vendorUnit = vendor,
            bid = bid, buyout = buyout, page = ns.scan.page, index = index }
        local candidate = ns.CalculateOpportunity(listing, ns.db.minProfit, ns.db.minDiscount)
        if candidate then table.insert(ns.results, candidate) end
    end
    ns.scan.scanned = ns.scan.scanned + shown
    ns.SortOpportunities(ns.results)
    if (type(total) == "number" and ns.scan.scanned >= total) or shown == 0 or shown < PAGE_SIZE then
        ns.StopScan("Scan complete: " .. tostring(#ns.results) .. " opportunities")
    else
        ns.scan.nextPage = ns.scan.page + 1
        ns.StopScan("Page complete; press Next Page to continue")
    end
end
function ns.NextPage()
    if ns.scan.nextPage == nil or not ns.auctionOpen or ns.scan.active then return false end
    local page = ns.scan.nextPage
    ns.scan.nextPage = nil
    ns.scan.active = true
    return ns.QueryPage(page)
end
if type(CreateFrame) == "function" then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
    frame:SetScript("OnEvent", function() ns.ProcessPage() end)
end
