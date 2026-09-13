
return {
  {
    "tpope/vim-fugitive",
    event = "VeryLazy",
  },
  {
    "lewis6991/gitsigns.nvim",
    opts = {},
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

  {
    "coder/claudecode.nvim",
    dependencies = {
      "folke/snacks.nvim",
    },
    cmd = {
      "ClaudeCode",
      "ClaudeCodeFocus",
      "ClaudeCodeSelectModel",
      "ClaudeCodeAdd",
      "ClaudeCodeSend",
      "ClaudeCodeTreeAdd",
      "ClaudeCodeStatus",
      "ClaudeCodeStart",
      "ClaudeCodeStop",
      "ClaudeCodeOpen",
      "ClaudeCodeClose",
      "ClaudeCodeDiffAccept",
      "ClaudeCodeDiffDeny",
      "ClaudeCodeCloseAllDiffs",
    },
    opts = {
      terminal = {
        provider = "snacks",
        snacks_win_opts = {
          position = "float",
          width = 0.85,
          height = 0.85,
          border = "rounded",
        },
      },
    },
  },
  {
    "vapourismo/terminals.nvim",
    dependencies = { "folke/snacks.nvim" },
    cmd = {
      "TermNew",
      "TermClose",
      "TermPrev",
      "TermNext",
      "TermToggle"
    },
    opts = {
      position = "float",
    },
    config = function(_, opts)
      require("snacks").config.style("terminal", {
        border = "rounded",
      })
      require("terminals").setup(opts)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    lazy = false,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    lazy = false,
    opts = {
    	ensure_installed = {
      		"clangd",
      		"gopls",
      		"jdtls",
      		"pyright",
      		"rust_analyzer",
      		"sqlls",
      		"ts_ls",
      		"lua_ls",
    	},
    	automatic_enable = true,
     },
  },
}
