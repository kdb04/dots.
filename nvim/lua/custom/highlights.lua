---@type Base46HLGroupsList
local M = {}

M.override = {
  Normal = { bg = "none" },
  NormalNC = { bg = "none" },
  NormalFloat = { bg = "none" },
  FloatBorder = { bg = "none" },
  CursorLine = { bg = "none" },
  CursorColumn = { bg = "none" },
  SignColumn = { bg = "none" },
  LineNr = { bg = "none" },

  NvimTreeGitDirty = { fg = "#E5C07B" }, -- Modified (Yellow)
  NvimTreeGitNew = { fg = "#98C379" }, -- Green (Added)
  NvimTreeGitDeleted = { fg = "#E06C75" }, -- Red (Deleted)
  NvimTreeGitRenamed = { fg = "#61AFEF" }, -- Blue (Renamed)
  NvimTreeGitIgnored = { fg = "#5C6370" }, -- Gray (Ignored)
}

return M
