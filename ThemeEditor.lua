local ns = ForeverVendorSniper
-- In-game custom theme editing through /fvs theme commands.
-- Uses WoW's existing chat command input; no external UI dependencies.
local keys = { background = true, panel = true, accent = true, text = true, profit = true }
function ns.CreateTheme(name, base)
    if type(name) ~= "string" or not string.match(name, "^[%w_%-]+$") then return false, "Use letters, numbers, _ or -" end
    if ns.themes[name] then return false, "Built-in themes cannot be overwritten" end
    local colors = ns.GetTheme(base or ns.db.theme)
    if not ns.SaveCustomTheme(name, colors) then return false, "Could not save theme" end
    ns.db.theme = name
    return true
end
function ns.SetThemeColor(name, key, hex)
    if not (ns.db.customThemes[name] and keys[key] and ns.ValidHex(hex)) then return false end
    ns.db.customThemes[name][key] = string.upper(string.gsub(hex, "#", ""))
    if ns.db.theme == name and ns.ApplyTheme then ns.ApplyTheme(ns.panel) end
    return true
end
function ns.SelectTheme(name)
    if not (ns.themes[name] or ns.db.customThemes[name]) then return false end
    ns.db.theme = name
    if ns.ApplyTheme then ns.ApplyTheme(ns.panel) end
    return true
end
function ns.DeleteTheme(name)
    if not ns.db.customThemes[name] then return false end
    ns.db.customThemes[name] = nil
    if ns.db.theme == name then ns.SelectTheme("Blizzard") end
    return true
end
function ns.ThemeCommand(command)
    local action, rest = string.match(command or "", "^(%S+)%s*(.*)$")
    if action == "select" then return ns.SelectTheme(rest)
    elseif action == "create" then return ns.CreateTheme(rest)
    elseif action == "delete" then return ns.DeleteTheme(rest)
    elseif action == "color" then
        local name, key, value = string.match(rest, "^(%S+)%s+(%S+)%s+(%S+)$")
        return ns.SetThemeColor(name, key, value)
    end
    return false, "Use: /fvs theme select NAME | create NAME | color NAME FIELD HEX | delete NAME"
end
