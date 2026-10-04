vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.termguicolors = true
vim.opt.number = true
vim.opt.updatetime = 100
-- vim.opt.relativenumber = true
vim.opt.autoread = true
vim.opt.laststatus = 3 -- one global statusline instead of one per window
vim.opt.showmode = false -- lualine shows the mode

vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, {
  pattern = "*",
  command = "checktime",
})

-- nvim-tree replaces netrw; must be set before plugins load
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- leader
vim.g.mapleader = " "


-- keymapping
-- vim.keymap.set("n", "<leader>d", "<cmd>Telescope diagnostics<cr>")
vim.keymap.set("n", "<leader>e", vim.lsp.buf.hover)
vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float)
vim.keymap.set("n", "<leader>gdf", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("vnew")
  vim.fn.setline(1, vim.fn.systemlist("git diff " .. vim.fn.shellescape(file)))
  vim.bo.buftype = "nofile"
  vim.bo.filetype = "diff"
  vim.api.nvim_buf_set_name(0, "git diff: " .. vim.fn.expand("%"))
end, { desc = "Git diff current file" })

-- File explorer: nvim-tree (keymaps set in its plugin spec below)

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
  event = "InsertEnter",
  config = function()
      require("copilot").setup({
      suggestion = { enabled = false },
      panel = { enabled = false },
    })
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
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        theme = "auto", -- follows the colorscheme
        globalstatus = true, -- one bar for all windows
        component_separators = { left = "", right = "" },
        section_separators = { left = "", right = "" },
        disabled_filetypes = { statusline = {} },
      },
      sections = {
        lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
        lualine_b = { "branch", "diff" },
        lualine_c = {
          { "filename", path = 1, symbols = { modified = " ●", readonly = " ", unnamed = "[No Name]" } },
        },
        lualine_x = {
          { "diagnostics", sources = { "nvim_diagnostic" } },
          { "filetype", icon_only = false },
        },
        lualine_y = { "progress" },
        lualine_z = { { "location", separator = { right = "" }, left_padding = 2 } },
      },
      extensions = { "nvim-tree", "lazy" },
    },
  },
{
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
  opts = {},
},
{
  "karb94/neoscroll.nvim",
  config = function()
    require('neoscroll').setup({})
  end
},
{
  "sphamba/smear-cursor.nvim",
  opts = {},
},
{
    "laytan/cloak.nvim",
        ops = {
            enabled = true,
            cloak_character = "*",
            cloak_telescope = true,
            highlight_group = "Comment",
            patterns = {
                "**/*.env",
                "**/.env.*",
                "**/secret*",
                "**/secrets*",
                "**/config*",
                "**/*.key",
                "**/*.keys",
                "**/*.pem",
                "**/*.crt",
                "**/*.cer",
            },
        },
        config = function(_, opts)
            require("cloak").setup(opts)
        end,
},

{ 'projekt0n/github-nvim-theme', name = 'github-theme' },

-- file explorer (VS Code-style sidebar tree)
{
  "nvim-tree/nvim-tree.lua",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  lazy = false,
  config = function()
    local function on_attach(bufnr)
      local api = require("nvim-tree.api")
      local function opts(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
      end

      -- defaults: <CR>/o open, a new file (end with / for folder), r rename,
      -- d delete, x cut, c copy, p paste, y copy name, Y copy rel path,
      -- H toggle dotfiles, I toggle gitignored, R refresh, W collapse all,
      -- E expand all, <BS> close parent folder, P go to parent, - go up a dir,
      -- <C-v> vsplit, <C-x> hsplit, <C-t> tab, f filter, ? help
      api.config.mappings.default_on_attach(bufnr)

      -- vim-style expand/collapse
      vim.keymap.set("n", "l", api.node.open.edit, opts("Open / expand"))
      vim.keymap.set("n", "<Right>", api.node.open.edit, opts("Open / expand"))
      vim.keymap.set("n", "h", api.node.navigate.parent_close, opts("Collapse folder"))
      vim.keymap.set("n", "<Left>", api.node.navigate.parent_close, opts("Collapse folder"))
      vim.keymap.set("n", "L", api.node.open.preview, opts("Preview (keep focus)"))
      vim.keymap.set("n", "<2-LeftMouse>", api.node.open.edit, opts("Open"))
    end

    require("nvim-tree").setup({
      on_attach = on_attach,
      sync_root_with_cwd = true,
      update_focused_file = { enable = true }, -- highlight the current file, like VS Code
      view = { width = 32, side = "left" },
      renderer = {
        group_empty = true, -- src/main/java on one line
        highlight_git = true,
        indent_markers = { enable = true },
        icons = { show = { git = true } },
      },
      git = { enable = true, ignore = false },
      diagnostics = { enable = true, show_on_dirs = true },
      filters = { dotfiles = false, custom = { "^.git$" } },
      actions = { open_file = { quit_on_open = false } },
    })

    vim.keymap.set("n", "<leader>b", "<cmd>NvimTreeToggle<cr>", { desc = "Toggle file explorer" })
    vim.keymap.set("n", "<leader>o", "<cmd>NvimTreeFocus<cr>", { desc = "Focus file explorer" })
    vim.keymap.set("n", "<leader>r", "<cmd>NvimTreeFindFile<cr>", { desc = "Reveal current file in explorer" })
    vim.keymap.set("n", "<leader>c", "<cmd>NvimTreeCollapse<cr>", { desc = "Collapse all folders" })

    -- close nvim when the tree is the last window left
    vim.api.nvim_create_autocmd("QuitPre", {
      callback = function()
        local wins = vim.tbl_filter(function(w)
          return vim.api.nvim_win_get_config(w).relative == ""
        end, vim.api.nvim_list_wins())
        if #wins == 2 then
          vim.cmd("silent! NvimTreeClose")
        end
      end,
    })
  end,
},

{
  "nickjvandyke/opencode.nvim",
  version = "*",
  dependencies = {
    "folke/snacks.nvim",
  },
  config = function()
    vim.g.opencode_opts = {}

    -- OpenCode keymaps: oo=toggle, qp=prompt
    vim.keymap.set({ "n", "x" }, "<C-a>", function() require("opencode").ask("@this: ", { submit = true }) end, { desc = "Ask opencode…" })
    vim.keymap.set({ "n", "x" }, "<C-x>", function() require("opencode").select() end, { desc = "Execute opencode action…" })
    vim.keymap.set({ "n", "x" }, "go", function() return require("opencode").operator("@this ") end, { desc = "Add range to opencode", expr = true })
    vim.keymap.set("n", "goo", function() return require("opencode").operator("@this ") .. "_" end, { desc = "Add line to opencode", expr = true })
    vim.keymap.set("n", "<leader>oo", function() require("opencode").toggle({ focus = true }) end, { desc = "Toggle opencode" })
    vim.keymap.set("n", "<S-C-u>", function() require("opencode").command("session.half.page.up") end, { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<S-C-d>", function() require("opencode").command("session.half.page.down") end, { desc = "Scroll opencode down" })
    vim.keymap.set("n", "<leader>qp", function()
      vim.ui.input({ prompt = "OpenCode: " }, function(input)
        if input and #input > 0 then
          require("opencode").prompt(input)
        end
      end)
    end, { desc = "Quick prompt to opencode" })
  end,
}
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
    { name = "copilot" },
    { name = "nvim_lsp" },
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
-- Install without configuration


-- vim.cmd("colorscheme catppuccin")
-- (applied at the bottom of the file, after the transparency autocmd is registered)

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


-- Keep github_dark's own background; Terminal.app's background is set to the
-- same colour so the window edges don't show a mismatched border.
vim.cmd("colorscheme github_dark")

