-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.lsp.set_log_level("off")

-- for obsidian
vim.opt.conceallevel = 1

vim.opt.termguicolors = true
vim.opt.wrap = true
vim.opt.mouse = ""
vim.opt.clipboard = "unnamedplus"

vim.g.snacks_animate = false
vim.g.lazyvim_blink_main = false
vim.g.ai_cmp = false

-- vim.g.tokyonight_cterm_colors = false
-- vim.g.tokyonight_terminal_colors = true
-- vim.g.tokyonight_italic_comments = true
-- vim.g.tokyonight_italic_keywords = true
-- vim.g.tokyonight_italic_functions = false
-- vim.g.tokyonight_italic_variables = false
-- vim.g.tokyonight_transparent = false
-- vim.g.tokyonight_hide_inactive_statusline = true
-- vim.g.tokyonight_dark_sidebar = true
-- vim.g.tokyonight_dark_float = true
-- vim.g.tokyonight_colors = {}
