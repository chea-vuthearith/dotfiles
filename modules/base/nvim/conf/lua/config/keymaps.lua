vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local map = vim.keymap.set
local cmd = vim.cmd

map("n", "Q", "q", { desc = "Record Macro" })
map("n", "q", "<nop>", { desc = "Disable q" })

map("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true, desc = "Scroll Up and Center" })
map("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true, desc = "Scroll Down and Center" })

map("n", "<leader>qr", function()
  require("persistence").save()
  vim.cmd("restart source " .. vim.fn.fnameescape(require("persistence").current()))
end, { noremap = true, silent = true, desc = "Restart Neovim" })

-- <tab>h/l = close tabs left/right, same as Vimium C's <space><tab>h/l
-- (a :N,Mtabclose range closes only one tab, so close them one at a time)
map("n", "<leader><TAB>h", function()
  for _ = 2, vim.fn.tabpagenr() do
    cmd("1tabclose")
  end
end, { desc = "Close Tabs to the Left" })
map("n", "<leader><TAB>l", function()
  while vim.fn.tabpagenr("$") > vim.fn.tabpagenr() do
    cmd("$tabclose")
  end
end, { desc = "Close Tabs to the Right" })

map("i", "<S-Tab>", function()
  vim.lsp.inline_completion.get()
end, { expr = true, desc = "Accept Inline Completion" })

-- remove LazyVim's buffer/tab defaults we don't want
vim.keymap.del("n", "H")
vim.keymap.del("n", "L")
pcall(vim.keymap.del, "n", "<leader><TAB>]")
pcall(vim.keymap.del, "n", "<leader><TAB>[")
