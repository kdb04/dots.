require "nvchad.options"

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    vim.keymap.set("n", "K", function()
      vim.lsp.buf.hover({
        border = "rounded",
        max_width = 80,
        max_height = 20,
      })
    end, { buffer = args.buf, desc = "LSP Hover Documentation" })
  end,
})

vim.api.nvim_create_autocmd("CursorMoved", {
  callback = function()
    if vim.fn.mode() ~= "n" then
      return
    end

    local tree = require("nvim-tree.api").tree

    if tree.is_visible() and not tree.is_tree_buf(0) then
      local editor_win = vim.api.nvim_get_current_win()

      tree.find_file({
        buf = vim.api.nvim_get_current_buf(),
        update_root = true,
        focus = true,
      })

      vim.api.nvim_set_current_win(editor_win)
    end
  end,
})

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
