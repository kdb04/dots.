require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "Focus Explorer" })
map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close Buffer" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
