-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.lsp.set_log_level("off")

-- for obsidian
vim.opt.conceallevel = 1

vim.opt.termguicolors = true
vim.opt.wrap = true
vim.opt.mouse = ""

vim.g.snacks_animate = false
vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = false

vim.g.lazyvim_python_lsp = "pyright"
vim.opt.diffopt:append("vertical")
vim.g.lazyvim_picker = "fzf"

-- neovide
-- vim.g.neovide_cursor_animate_in_insert_mode = true
-- vim.g.neovide_cursor_trail_size = 0.3
-- vim.g.neovide_hide_mouse_when_typing = true
-- vim.g.neovide_refresh_rate_idle = 1
-- vim.g.neovide_scroll_animation_far_lines = 0
-- vim.g.neovide_scroll_animation_length = 0
