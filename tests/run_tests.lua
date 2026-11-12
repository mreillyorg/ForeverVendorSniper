local checks = 0
local function eq(actual, expected, label)
    checks = checks + 1
    if actual ~= expected then error((label or "assertion") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual)) end
end
_G.ForeverVendorSniper = { db = { customThemes = {}, minProfit = 100, minDiscount = 0 } }
dofile("Themes.lua")
dofile("Opportunities.lua")
dofile("Sources.lua")
dofile("VendorPrices.lua")
dofile("Purchasing.lua")
dofile("Options.lua")
local ns = _G.ForeverVendorSniper
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
print("PASS: " .. checks .. " assertions")
