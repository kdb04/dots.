
return {
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },

  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require("custom.configs.lspconfig")
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = function(_, opts)
      opts.filters = opts.filters or {}
      opts.filters.git_ignored = false

      opts.renderer = opts.renderer or {}
      opts.renderer.icons = opts.renderer.icons or {}
      opts.renderer.icons.glyphs = opts.renderer.icons.glyphs or {}

      opts.renderer.icons.glyphs.git = {
        unstaged = "M",
        staged = "A",
        unmerged = "U",
        renamed = "R",
        untracked = "U",
        deleted = "D",
        ignored = "I",
      }

      return opts
    end,
  },

  -- test new blink
  -- { import = "nvchad.blink.lazyspec" },

  -- {
  -- 	"nvim-treesitter/nvim-treesitter",
  -- 	opts = {
  -- 		ensure_installed = {
  -- 			"vim", "lua", "vimdoc",
  --      "html", "css"
  -- 		},
  -- 	},
  -- },
}
