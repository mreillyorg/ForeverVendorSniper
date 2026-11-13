local ns = ForeverVendorSniper
ns.themes = {
    Blizzard = { background = "292016", panel = "382B1D", accent = "D4AC62", text = "F4E6CB", profit = "62CE71" },
    Dark = { background = "141820", panel = "242B36", accent = "659ED6", text = "E4EAF3", profit = "62CEAA" },
    Light = { background = "F0EDE6", panel = "FFFFFF", accent = "366A91", text = "292B32", profit = "167346" },
}
function ns.ValidHex(value) return type(value) == "string" and string.match(value, "^#?%x%x%x%x%x%x$") ~= nil end
function ns.HexRGB(value)
    if not ns.ValidHex(value) then return 1, 1, 1 end
    value = string.gsub(value, "#", "")
    return tonumber(string.sub(value, 1, 2), 16)/255, tonumber(string.sub(value, 3, 4), 16)/255, tonumber(string.sub(value, 5, 6), 16)/255
end
function ns.GetTheme(name)
    local custom = ns.db and ns.db.customThemes
    return (custom and custom[name]) or ns.themes[name] or ns.themes.Blizzard
end
function ns.SaveCustomTheme(name, colors)
    if type(name) ~= "string" or not string.match(name, "%S") or ns.themes[name]
        or type(colors) ~= "table" or not ns.db then
        return false
    end
    local theme = {}
    for key, fallback in pairs(ns.themes.Blizzard) do
        theme[key] = ns.ValidHex(colors[key]) and string.gsub(colors[key], "#", "") or fallback
    end
    ns.db.customThemes[name] = theme
    return true
end
function ns.ApplyTheme(frame)
    if not frame or not frame.bg then return end
    local theme = ns.GetTheme(ns.db and ns.db.theme)
    frame.bg:SetColorTexture(ns.HexRGB(theme.background))
    if frame.title then frame.title:SetTextColor(ns.HexRGB(theme.accent)) end
end
