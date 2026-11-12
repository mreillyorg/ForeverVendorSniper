local ns = _G.ForeverVendorSniper
ns.results = {}
ns.scan = { active = false, page = 0, pending = false, scanned = 0 }
local PAGE_SIZE = 50
local function notify(message)
    ns.status = message
    if ns.RefreshUI then ns.RefreshUI() end
end
function ns.StopScan(reason)
    ns.scan.active, ns.scan.pending = false, false
    notify(reason or "Scan stopped")
end
function ns.QueryPage(page)
    if not ns.scan.active or not ns.auctionOpen then return end
    if type(CanSendAuctionQuery) == "function" and not CanSendAuctionQuery() then
        notify("Waiting for AH query cooldown; press Scan to retry")
        ns.scan.active = false
        return
    end
    if type(QueryAuctionItems) ~= "function" then return ns.StopScan("AH query API unavailable") end
    ns.scan.page, ns.scan.pending = page, true
    -- Vanilla/Classic signature; Forever-specific implementations require live verification.
    QueryAuctionItems("", nil, nil, page, false, nil, false, false, nil)
    notify("Scanning page " .. tostring(page + 1))
end
function ns.StartScan()
    if not ns.auctionOpen then notify("Open an Auction House first") return false end
    if ns.scan.active then return false end
    ns.results = {}
    ns.scan = { active = true, page = 0, pending = false, scanned = 0 }
    ns.QueryPage(0)
    return true
end
function ns.ProcessPage()
    if not ns.scan.active or not ns.scan.pending then return end
    if type(GetNumAuctionItems) ~= "function" or type(GetAuctionItemInfo) ~= "function" then return ns.StopScan("AH listing API unavailable") end
    ns.scan.pending = false
    local shown, total = GetNumAuctionItems("list")
    if type(shown) ~= "number" then return ns.StopScan("Invalid AH response") end
    for index = 1, shown do
        local name, _, count, _, _, _, _, minBid, minIncrement, buyout, bidAmount = GetAuctionItemInfo("list", index)
        local link = type(GetAuctionItemLink) == "function" and GetAuctionItemLink("list", index) or nil
        local vendor = ns.GetVendorUnit(link)
        local candidate = ns.CalculateOpportunity({ name = name, link = link, count = count, vendorUnit = vendor,
            bid = bidAmount and bidAmount > 0 and (bidAmount + (minIncrement or 0)) or minBid,
            buyout = buyout, page = ns.scan.page, index = index }, ns.db.minProfit, ns.db.minDiscount)
        if candidate then table.insert(ns.results, candidate) end
    end
    ns.scan.scanned = ns.scan.scanned + shown
    ns.SortOpportunities(ns.results)
    if ns.scan.scanned >= (total or 0) or shown == 0 or shown < PAGE_SIZE then
        ns.StopScan("Scan complete: " .. tostring(#ns.results) .. " opportunities")
    else
        -- Do not issue unthrottled requests; user can resume from next page.
        ns.scan.nextPage = ns.scan.page + 1
        ns.StopScan("Page complete; press Next Page to continue")
    end
end
function ns.NextPage()
    if ns.scan.nextPage == nil or not ns.auctionOpen then return end
    local page = ns.scan.nextPage
    ns.scan.nextPage = nil
    ns.scan.active = true
    ns.QueryPage(page)
end
if type(CreateFrame) == "function" then
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("AUCTION_ITEM_LIST_UPDATE")
    frame:SetScript("OnEvent", function() ns.ProcessPage() end)
end
