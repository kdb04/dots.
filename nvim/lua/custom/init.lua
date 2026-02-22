-- Ensure this runs after NvChad fully loads
vim.api.nvim_create_autocmd("ColorScheme", {
  pattern = "*",
  callback = function()
    local groups = {
      "Normal",
      "NormalNC",
      "NormalFloat",
      "FloatBorder",
      "SignColumn",
      "LineNr",
      "CursorLine",
      "CursorColumn",
      "VertSplit",
      "StatusLine",
      "StatusLineNC",
      "TelescopeNormal",
      "TelescopeBorder",
      "NvimTreeNormal",
      "NvimTreeNormalNC",
    }

    for _, group in ipairs(groups) do
      vim.cmd(("hi %s guibg=NONE ctermbg=NONE"):format(group))
    end
  end,
})
