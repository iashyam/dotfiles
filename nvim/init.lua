vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.termguicolors = true

-- leader
vim.g.mapleader = " "


-- keymapping
vim.keymap.set("n", "<leader>d", "<cmd>Telescope diagnostics<cr>")
vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float)

-- lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- LSP
  "neovim/nvim-lspconfig",

  -- breakcet 
  "windwp/nvim-autopairs",

  -- completion
  "hrsh7th/nvim-cmp",
  "hrsh7th/cmp-nvim-lsp",
  "stevearc/conform.nvim",
  {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  config = function()
    require("copilot").setup({})
  end,
  },
  {
  "zbirenbaum/copilot-cmp",
  dependencies = "zbirenbaum/copilot.lua",
  config = function()
    require("copilot_cmp").setup()
  end,
  },

  -- telescope
  {
  "nvim-telescope/telescope.nvim",

  dependencies = { "nvim-lua/plenary.nvim" },
  { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
  },

 {
  "ray-x/lsp_signature.nvim",
  event = "LspAttach",
  opts = {
    bind = true,
    floating_window = true,
    hint_enable = false, -- VS Code–style popup only
  },
 },

 {
  "windwp/nvim-autopairs",
  event = "InsertEnter",
  opts = {},
 },

 {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  opts = {
    ensure_installed = { "python", "go", "lua" },
    highlight = { enable = true },
    indent = { enable = true },
  },
 },

 --harpoon
 {
  "ThePrimeagen/harpoon",
  dependencies = { "nvim-lua/plenary.nvim" },
 },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' }
  },
{
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
}
} 
)

--confirm 

require("conform").setup({
    formatters_by_ft = {
        lua = { "stylua" },
        -- You can add other file types and formatters here
        -- python = { "isort", "black" },
    },
    -- Optional: configure formatting on save
    format_on_save = { timeout_ms = 500, lsp_fallback = true },
})


-- LSP

vim.lsp.config("pyright", {})
vim.lsp.config("goplus", {})

-- LSP (Neovim 0.11+ correct way)
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)

vim.lsp.enable("pyright")
vim.lsp.enable("gopls")

vim.lsp.config("pyright", {
  capabilities = capabilities,
})

vim.lsp.config("gopls", {
  capabilities = capabilities,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  group = vim.api.nvim_create_augroup("GoFormat", { clear = true }),
  pattern = "*.go",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})


-- completion (VS Code–like)

vim.opt.completeopt = { "menu", "menuone", "noselect" }

local cmp = require("cmp")

cmp.setup({
  completion = {
    autocomplete = { cmp.TriggerEvent.TextChanged },
  },
  mapping = {
      ["<Tab>"] = cmp.mapping.confirm({ select = true}),
      ["<CR>"] = cmp.mapping.confirm({ select = true})
  },
  sources = {
    { name = "nvim_lsp" }, -- relevance comes from here
  },
})


local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("pyright", {
  capabilities = capabilities,
})

vim.lsp.config("gopls", {
  capabilities = capabilities,
})

--colorscheme

-- vim.cmd("colorscheme catppuccin")
-- vim.cmd("colorscheme monokai")
vim.cmd("colorscheme tokyonight")

-- vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
-- vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
-- vim.api.nvim_set_hl(0, "LineNr", { bg = "none" })
-- vim.api.nvim_set_hl(0, "CursorLineNr", { bg = "none" })
-- vim.api.nvim_set_hl(0, "SignColumn", { bg = "none" })
-- vim.api.nvim_set_hl(0, "FoldColumn", { bg = "none" })

-- telescope setup
require("telescope").setup({})
vim.keymap.set("n", "<leader>f", "<cmd>Telescope find_files<cr>")
vim.keymap.set("n", "<leader>g", "<cmd>Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fa", "<cmd>Telescope find_files cwd=/<cr>")
vim.keymap.set("n", "<leader>fA", "<cmd>Telescope live_grep cwd=/<cr>")

vim.api.nvim_set_hl(0, "TelescopeNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePromptNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopeResultsNormal", { bg = "none" })
vim.api.nvim_set_hl(0, "TelescopePreviewNormal", { bg = "none" })

-- harpoon settings
-- Harpoon (stable v1)
local mark = require("harpoon.mark")
local ui = require("harpoon.ui")

vim.keymap.set("n", "<leader>a", mark.add_file)
vim.keymap.set("n", "<leader>h", ui.toggle_quick_menu)

vim.keymap.set("n", "<leader>1", function() ui.nav_file(1) end)
vim.keymap.set("n", "<leader>2", function() ui.nav_file(2) end)
vim.keymap.set("n", "<leader>3", function() ui.nav_file(3) end)
vim.keymap.set("n", "<leader>s", function() ui.nav_prev() end)

