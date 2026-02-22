---@type ChadrcConfig
local M = {}

M.ui = {
  theme = "onedark",
  transparency = true,
}

M.plugins = "custom.plugins"
M.mappings = require "custom.mappings"
M.hl_override = require "custom.highlights"

return M
