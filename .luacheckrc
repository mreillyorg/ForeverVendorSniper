std = "lua51"
max_line_length = 140
-- Addon-owned namespace and SavedVariables are intentionally mutable.
globals = {
  "ForeverVendorSniper", "ForeverVendorSniperDB", "C_AuctionHouse",
  "SLASH_FOREVERVENDORSNIPER1", "SlashCmdList",
  -- The unit-test harness replaces these WoW AH API functions with mocks.
  "CanSendAuctionQuery", "QueryAuctionItems",
  "GetNumAuctionItems", "GetAuctionItemInfo", "GetAuctionItemLink",
}
-- WoW functions are normally read-only; test mocks override them.
read_globals = {
  "_G", "CreateFrame", "UIParent", "GetItemInfo", "IsAddOnLoaded",
  "DEFAULT_CHAT_FRAME",
}
