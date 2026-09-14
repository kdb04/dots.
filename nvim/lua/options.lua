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

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
