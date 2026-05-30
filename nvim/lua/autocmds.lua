vim.api.nvim_create_autocmd("VimEnter", {
  callback = function(data)
    if vim.fn.isdirectory(data.file) == 1 then
      vim.cmd.cd(data.file)

      vim.schedule(function()
        vim.cmd("doautocmd User FilePost")
        vim.cmd("NvimTreeToggle")
      end)
    end
  end,
})
