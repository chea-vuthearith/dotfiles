vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set
local cmd = vim.cmd

map("n", "Q", "q", { desc = "Record Macro" })
map("n", "q", "<nop>", { desc = "Disable q" })

map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll Up and Center" })
map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll Down and Center" })

map(
  "n",
  "<leader>qr",
  ":mksession! /tmp/restart-session.vim | restart source /tmp/restart-session.vim<CR>",
  { noremap = true, silent = true, desc = "Restart Neovim" }
)

map("n", "<leader><TAB>l", cmd.tabnext, { desc = "Next Tab" })
map("n", "<leader><TAB>h", cmd.tabprevious, { desc = "Previous Tab" })

map("i", "<S-Tab>", function()
  vim.lsp.inline_completion.get()
end, { expr = true, desc = "Accept Inline Completion" })

-- remove LazyVim's buffer/tab defaults we don't want
vim.keymap.del("n", "H")
vim.keymap.del("n", "L")
pcall(vim.keymap.del, "n", "<leader><TAB>]")
pcall(vim.keymap.del, "n", "<leader><TAB>[")
