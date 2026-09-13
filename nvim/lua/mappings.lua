require "nvchad.mappings"

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map("n", "<leader>e", "<cmd>NvimTreeFocus<CR>", { desc = "Focus Explorer" })
map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Close Buffer" })
map({"n", "t"}, "<leader>t", "<cmd>TermToggle<CR>", { desc = "Toggle Terminal" })
map({"n", "t"}, "<leader>tn", "<cmd>TermNew<CR>", { desc = "New Terminal "})
map({"n", "t"}, "<leader>tx", "<cmd>TermClose<CR>", { desc = "Close Terminal "})
map("t", "<Esc>", "<C-\\><C-n>", { desc = "Exit Terminal Mode" })
map({"n", "t"}, "<leader>tr", "<cmd>TermNext<CR>", { desc = "Next Terminal" })
map({"n", "t"}, "<leader>tl", "<cmd>TermPrev<CR>", { desc = "Previous Terminal" })
map("n", "<S-Down>", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next Git Hunk" })
map("n", "<S-Up>", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous Git Hunk" })
map("n", "<leader>g", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview Git Hunk" })
map("n", "<leader>a", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage Git Hunk" })
map("n", "<leader>u", "<cmd>Gitsigns undo_stage_hunk<CR>", { desc = "Unstage Git Hunk" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>bprev<CR>", { desc = "Previous Buffer" })
map("n", "gd", vim.lsp.buf.definition, { desc = "Go to Definition" })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
