-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--open terminal in root
vim.api.nvim_set_keymap(
  "n",
  "<leader>wt",
  [[:lua vim.fn.system('wezterm cli spawn --cwd ' .. LazyVim.root()) <CR>]],
  { noremap = true, silent = true, desc = "New terminal tab (Root Dir)" }
)

vim.api.nvim_set_keymap(
  "n",
  "H",
  ":!wezterm cli activate-tab --tab-relative -1 <CR>",
  { noremap = true, silent = true, desc = "Window Left" }
)

vim.api.nvim_set_keymap(
  "n",
  "L",
  ":!wezterm cli activate-tab --tab-relative 1 <CR>",
  { noremap = true, silent = true, desc = "Window Right" }
)
