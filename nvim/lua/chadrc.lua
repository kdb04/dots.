---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "onedark",
  transparency = true,
}

M.nvdash = {
  load_on_startup = true,
}

M.plugins = "custom.plugins"
M.hl_override = require "custom.highlights"

return M
