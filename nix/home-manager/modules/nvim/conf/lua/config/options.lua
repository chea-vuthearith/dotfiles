-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- vim.lsp.set_log_level("off")

-- for obsidian
vim.opt.conceallevel = 1

vim.opt.termguicolors = true
vim.opt.wrap = true
vim.opt.mouse = ""
vim.opt.clipboard = "unnamedplus"

vim.g.snacks_animate = false
vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = false

-- neovide
if vim.g.neovide then
  vim.g.terminal_color_0 = "#45475a"
  vim.g.terminal_color_1 = "#f38ba8"
  vim.g.terminal_color_2 = "#a6e3a1"
  vim.g.terminal_color_3 = "#f9e2af"
  vim.g.terminal_color_4 = "#89b4fa"
  vim.g.terminal_color_5 = "#f5c2e7"
  vim.g.terminal_color_6 = "#94e2d5"
  vim.g.terminal_color_7 = "#bac2de"
  vim.g.terminal_color_8 = "#585b70"
  vim.g.terminal_color_9 = "#f38ba8"
  vim.g.terminal_color_10 = "#a6e3a1"
  vim.g.terminal_color_11 = "#f9e2af"
  vim.g.terminal_color_12 = "#89b4fa"
  vim.g.terminal_color_13 = "#f5c2e7"
  vim.g.terminal_color_14 = "#94e2d5"
  vim.g.terminal_color_15 = "#a6adc8"
end
vim.g.neovide_cursor_animate_in_insert_mode = true
vim.g.neovide_cursor_trail_size = 0.3
vim.g.neovide_hide_mouse_when_typing = true
vim.g.neovide_refresh_rate_idle = 1
vim.g.neovide_scroll_animation_far_lines = 0
vim.g.neovide_scroll_animation_length = 0
