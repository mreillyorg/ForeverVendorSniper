-- luacheck: globals QueryAuctionItems CanSendAuctionQuery GetNumAuctionItems GetAuctionItemInfo GetAuctionItemLink
local checks = 0
local function eq(actual, expected, label)
    checks = checks + 1
    if actual ~= expected then error((label or "assertion") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual)) end
end
ForeverVendorSniper = { db = { customThemes = {}, minProfit = 100, minDiscount = 0 } }
dofile("Themes.lua")
dofile("Opportunities.lua")
dofile("Sources.lua")
dofile("VendorPrices.lua")
dofile("Purchasing.lua")
dofile("Options.lua")
local ns = ForeverVendorSniper
local row = ns.CalculateOpportunity({ name = "Sword", count = 2, vendorUnit = 1000, buyout = 1500 }, 100, 0)
eq(row.profit, 500, "profit")
eq(row.vendorTotal, 2000, "stack vendor")
eq(row.discount, 25, "discount")
eq(ns.CalculateOpportunity({count=1,vendorUnit=100,buyout=100},0,0), nil, "no profit")
eq(ns.CalculateOpportunity({count=1,vendorUnit=0,buyout=1},0,0), nil, "unsellable")
eq(ns.CalculateOpportunity({count=1,vendorUnit=100,buyout=1},100,0), nil, "threshold")
eq(ns.CalculateOpportunity({count=1,vendorUnit=100,buyout=90},0,20), nil, "discount threshold")
eq(ns.CalculateOpportunity({count=0,vendorUnit=100,buyout=1},0,0), nil, "zero stack")
eq(ns.CalculateOpportunity({count=1.5,vendorUnit=100,buyout=1},0,0), nil, "fractional stack")
eq(ns.Money(12345), "1g 23s 45c", "money")
local sorted = {{name="B",profit=2},{name="A",profit=2},{name="C",profit=10}}
ns.SortOpportunities(sorted)
eq(sorted[1].name,"C","sort profit")
eq(sorted[2].name,"A","sort tie")
eq(ns.ValidHex("#112233"),true,"hex valid")
eq(ns.ValidHex("bad"),false,"hex invalid")
eq(ns.SaveCustomTheme("Custom",{background="#112233"}),true,"save custom")
eq(ns.GetTheme("Custom").background,"112233","load custom")
eq(ns.SaveCustomTheme("Dark",{}),false,"no builtin overwrite")
local a = {page=0,index=1,link="item:123",count=2,buyout=500}
local b = {page=0,index=1,link="item:123",count=2,buyout=500}
eq(ns.ValidatePurchase(a,b),true,"matching purchase")
b.buyout=600
eq(ns.ValidatePurchase(a,b),false,"changed price")
eq(ns.RequestBuyout(a),false,"buyout fails closed")
eq(ns.SetMinimumProfit(-1),false,"invalid threshold")
eq(ns.SetMinimumProfit(250),true,"valid threshold")
eq(ns.db.minProfit,250,"saved threshold")
eq(ns.SetMinimumDiscount(101),false,"invalid discount")
dofile("ThemeEditor.lua")
eq(ns.CreateTheme("Ocean", "Dark"), true, "create custom theme")
eq(ns.db.theme, "Ocean", "activate custom theme")
eq(ns.SetThemeColor("Ocean", "accent", "#abcdef"), true, "set custom color")
eq(ns.GetTheme("Ocean").accent, "ABCDEF", "normalized color")
eq(ns.SetThemeColor("Ocean", "unknown", "123456"), false, "invalid theme field")
eq(ns.CreateTheme("Dark"), false, "reject built-in theme")
eq(ns.SelectTheme("missing"), false, "reject unknown theme")
eq(ns.ThemeCommand("select Light"), true, "theme chat command")
eq(ns.DeleteTheme("Ocean"), true, "delete custom theme")
-- Mock a two-page native scan and verify that results survive pagination.
dofile("Scanner.lua")
ns.auctionOpen = true
ns.db.minProfit = 0
ns.db.minDiscount = 0
ns.GetVendorUnit = function() return 100 end
local page, queries = 0, 0
QueryAuctionItems = function(_, _, _, p) page = p queries = queries + 1 end
CanSendAuctionQuery = function() return true end
GetNumAuctionItems = function()
    if page == 0 then return 50, 51 end
    return 1, 51
end
GetAuctionItemInfo = function(_, index)
    return "Item" .. index, nil, 1, nil, nil, nil, nil, 0, 0, 50, 0
end
GetAuctionItemLink = function(_, index) return "item:" .. index end
eq(ns.StartScan(), true, "start native scan")
ns.ProcessPage()
eq(#ns.results, 50, "first page candidates")
eq(ns.scan.nextPage, 1, "next page queued")
eq(ns.NextPage(), true, "advance page")
ns.ProcessPage()
eq(#ns.results, 51, "second page candidates")
eq(ns.scan.active, false, "scan complete")
eq(queries, 2, "query count")
print("PASS: " .. checks .. " assertions")
