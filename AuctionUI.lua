local ns = _G.ForeverVendorSniper
local frame, rows, status, offset
rows = {}
offset = 0
local function text(parent, size, x, y, width, value)
    local fs = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    fs:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    fs:SetWidth(width)
    fs:SetJustifyH("LEFT")
    fs:SetText(value or "")
    return fs
end
local function button(parent, label, x, y, width, fn)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(width, 23)
    b:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
    b:SetText(label)
    b:SetScript("OnClick", fn)
    return b
end
function ns.RefreshUI()
    if not frame then return end
    status:SetText(ns.status or "Ready")
    for i, row in ipairs(rows) do
        local data = ns.results[offset + i]
        if data then
            row.name:SetText((data.name or "Unknown") .. " x" .. tostring(data.count))
            row.buy:SetText(ns.Money(data.buyout))
            row.vendor:SetText(ns.Money(data.vendorTotal))
            row.profit:SetText(ns.Money(data.profit))
            row.button:Disable() -- purchase remains disabled until verified against live Forever API
            row.button:SetText("Verify")
            row.button:SetScript("OnClick", function() ns.RequestBuyout(data) end)
            row.container:Show()
        else row.container:Hide() end
    end
end
function ns.BuildUI()
    if frame then return end
    frame = CreateFrame("Frame", "ForeverVendorSniperPanel", UIParent)
    frame:SetSize(690, 360)
    frame:SetFrameStrata("DIALOG")
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", frame.StartMoving)
    frame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, x, y = self:GetPoint()
        ns.db.point = { point, "UIParent", relativePoint, x, y }
    end)
    local p = ns.db.point
    frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    frame.bg = frame:CreateTexture(nil, "BACKGROUND")
    frame.bg:SetAllPoints()
    frame.bg:SetColorTexture(0.1, 0.1, 0.1, 0.96)
    frame.title = text(frame, 14, 12, -12, 380, "ForeverVendorSniper  v" .. ns.version)
    button(frame, "X", 650, -7, 30, function() frame:Hide() end)
    button(frame, "Scan", 12, -40, 80, function() offset = 0 ns.StartScan() end)
    button(frame, "Next Page", 98, -40, 100, function() ns.NextPage() end)
    button(frame, "Stop", 204, -40, 70, function() ns.StopScan("Stopped by player") end)
    button(frame, "Theme", 280, -40, 80, function() ns.CycleTheme() end)
    button(frame, "Up", 580, -40, 45, function() offset = math.max(0, offset - 7) ns.RefreshUI() end)
    button(frame, "Down", 630, -40, 50, function() offset = math.min(math.max(0, #ns.results - 7), offset + 7) ns.RefreshUI() end)
    text(frame, 11, 12, -76, 220, "Item / Count")
    text(frame, 11, 245, -76, 105, "Buyout")
    text(frame, 11, 360, -76, 105, "Vendor")
    text(frame, 11, 475, -76, 105, "Profit")
    for i = 1, 7 do
        local container = CreateFrame("Frame", nil, frame)
        container:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -82 - i * 30)
        container:SetSize(690, 28)
        local r = { container = container }
        r.name = text(container, 11, 12, 0, 230)
        r.buy = text(container, 11, 245, 0, 105)
        r.vendor = text(container, 11, 360, 0, 105)
        r.profit = text(container, 11, 475, 0, 100)
        r.button = button(container, "Verify", 580, 3, 100, function() end)
        rows[i] = r
    end
    status = text(frame, 11, 12, -331, 660, "Ready")
    ns.ApplyTheme(frame)
    frame:Hide()
end
function ns.ShowUI() if frame then frame:Show() ns.RefreshUI() end end
function ns.HideUI() if frame then frame:Hide() end end
function ns.ToggleUI() if not frame then return end if frame:IsShown() then frame:Hide() else ns.ShowUI() end end
function ns.CycleTheme()
    local names = { "Blizzard", "Dark", "Light" }
    local nextIndex = 1
    for i, name in ipairs(names) do if ns.db.theme == name then nextIndex = i % #names + 1 end end
    ns.db.theme = names[nextIndex]
    ns.ApplyTheme(frame)
end
