local ns = ForeverVendorSniper
-- Deliberately fail closed: stale scan indices cannot be safely purchased.
function ns.ValidatePurchase(row, current)
    if not row or not current or row.page ~= current.page or row.index ~= current.index then return false, "Listing changed" end
    if row.link ~= current.link or row.count ~= current.count or row.buyout ~= current.buyout then return false, "Price or item changed" end
    if type(row.buyout) ~= "number" or row.buyout <= 0 then return false, "No buyout" end
    return true
end
function ns.RequestBuyout()
    if not ns.auctionOpen then return false, "Auction House closed" end
    -- The server's live purchase/commodity protocol has not yet been verified.
    -- Never invoke PlaceAuctionBid with an index captured during a previous scan.
    return false, "Buyout disabled pending verified Forever AH purchase API"
end
