std = "lua51"
max_line_length = 140
-- Addon-owned namespace and SavedVariables are intentionally mutable.
globals = {
  "ForeverVendorSniper", "ForeverVendorSniperDB",
  "SLASH_FOREVERVENDORSNIPER1", "SlashCmdList",
}
-- WoW functions are normally read-only; test mocks override them.
read_globals = {
  "_G", "CreateFrame", "UIParent", "GetItemInfo", "IsAddOnLoaded",
  "DEFAULT_CHAT_FRAME",
}
