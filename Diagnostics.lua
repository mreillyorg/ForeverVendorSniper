local ns = ForeverVendorSniper

-- Capture function names only. No auction queries, purchases or player data.
function ns.CaptureAuctionAPI()
    if not ns.db then
        return false, "Addon settings are not initialized"
    end
    local api = C_AuctionHouse
    if type(api) ~= "table" then
        return false, "C_AuctionHouse is unavailable"
    end
    local methods = {}
    for name, value in pairs(api) do
        if type(name) == "string" and type(value) == "function" then
            methods[#methods + 1] = name
        end
    end
    table.sort(methods)
    ns.db.apiDiagnostics = {
        version = 1,
        methods = methods,
        count = #methods,
    }
    return true, "Captured " .. #methods .. " C_AuctionHouse methods; log out to save them"
end

function ns.DebugCommand(command)
    if command == "api" then
        return ns.CaptureAuctionAPI()
    end
    return false, "Usage: /fvs debug api"
end
