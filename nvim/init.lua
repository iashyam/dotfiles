vim.cmd('set expandtab')
vim.cmd('set tabstop=4')
vim.cmd('set shiftwidth=4')
vim.cmd('set rnu')
vim.cmd('set number')
vim.g.mapleader=' '

-- the lazy plugin manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local opts = {}
local plugins = {
 { "catppuccin/nvim", name = "catppuccin", priority = 1000 }, 
 {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' }
  },

  {"nvim-treesitter/nvim-treesitter", build= ":TSUpdate"}, 
  {'github/copilot.vim'}

}

require("lazy").setup(plugins, opts)

--require catppuccin
require("catppuccin").setup()

--set the colorscheme to it!
vim.cmd.colorscheme "catppuccin"

-- telescope setup
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<C-p>', builtin.find_files, {})
vim.keymap.set('n', '<leader>f', builtin.live_grep, {})

-- treesitter config
local config = require("nvim-treesitter.configs")
config.setup({
  ensure_installed = {"python", "lua", "javascript", "go"},
  highlight = { enable = true },
  indent = { enable = true }
})
