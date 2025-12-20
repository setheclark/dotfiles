-- =============================================================================
-- Neovim configuration
-- =============================================================================

-- This is a minimal base configuration. You can expand it as needed.
-- Consider using a distribution like LazyVim, AstroNvim, or NvChad
-- for a more complete setup.

-- -----------------------------------------------------------------------------
-- Options
-- -----------------------------------------------------------------------------

local opt = vim.opt

-- Line numbers
opt.number = true
opt.relativenumber = true

-- Indentation
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.autoindent = true

-- Search
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true
opt.incsearch = true

-- Display
opt.wrap = false
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.signcolumn = "yes"
opt.colorcolumn = "100"
opt.cursorline = true
opt.termguicolors = true

-- Splits
opt.splitbelow = true
opt.splitright = true

-- Files
opt.backup = false
opt.swapfile = false
opt.undofile = true
opt.undodir = vim.fn.stdpath("data") .. "/undo"

-- Clipboard
opt.clipboard = "unnamedplus"

-- Mouse
opt.mouse = "a"

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }

-- Performance
opt.updatetime = 250
opt.timeoutlen = 300

-- Misc
opt.hidden = true
opt.showmode = false
opt.fillchars = { eob = " " }

-- -----------------------------------------------------------------------------
-- Key mappings
-- -----------------------------------------------------------------------------

local keymap = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Better escape
keymap("i", "jk", "<Esc>", opts)
keymap("i", "kj", "<Esc>", opts)

-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

-- Resize windows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffer navigation
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)
keymap("n", "<leader>bd", ":bdelete<CR>", opts)

-- Move lines
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Stay in visual mode when indenting
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Clear search highlighting
keymap("n", "<leader>h", ":nohlsearch<CR>", opts)

-- Save and quit shortcuts
keymap("n", "<leader>w", ":w<CR>", opts)
keymap("n", "<leader>q", ":q<CR>", opts)
keymap("n", "<leader>x", ":x<CR>", opts)

-- File explorer (using netrw for now)
keymap("n", "<leader>e", ":Explore<CR>", opts)

-- -----------------------------------------------------------------------------
-- Netrw settings (built-in file explorer)
-- -----------------------------------------------------------------------------

vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25

-- -----------------------------------------------------------------------------
-- Autocommands
-- -----------------------------------------------------------------------------

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
    group = "YankHighlight",
    callback = function()
        vim.highlight.on_yank({ higroup = "IncSearch", timeout = 200 })
    end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
    group = "TrimWhitespace",
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

-- Return to last edit position
augroup("LastPosition", { clear = true })
autocmd("BufReadPost", {
    group = "LastPosition",
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Filetype-specific settings
augroup("FileTypeSettings", { clear = true })
autocmd("FileType", {
    group = "FileTypeSettings",
    pattern = { "lua", "yaml", "json", "javascript", "typescript" },
    callback = function()
        vim.opt_local.tabstop = 2
        vim.opt_local.shiftwidth = 2
    end,
})

autocmd("FileType", {
    group = "FileTypeSettings",
    pattern = { "kotlin", "java" },
    callback = function()
        vim.opt_local.tabstop = 4
        vim.opt_local.shiftwidth = 4
    end,
})

-- -----------------------------------------------------------------------------
-- Plugin manager (lazy.nvim) - Bootstrap
-- -----------------------------------------------------------------------------

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
    -- Catppuccin colorscheme (Frappe variant)
    {
        "catppuccin/nvim",
        name = "catppuccin",
        lazy = false,
        priority = 1000,
        config = function()
            require("catppuccin").setup({
                flavour = "frappe",
                transparent_background = false,
                term_colors = true,
                integrations = {
                    cmp = true,
                    gitsigns = true,
                    nvimtree = true,
                    telescope = true,
                    treesitter = true,
                },
            })
            vim.cmd.colorscheme("catppuccin")
        end,
    },

    -- Add more plugins here as needed
    -- { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
    -- { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },
    -- { "neovim/nvim-lspconfig" },
    -- { "hrsh7th/nvim-cmp" },
})
