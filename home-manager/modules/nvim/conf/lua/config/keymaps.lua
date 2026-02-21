-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

local set = vim.keymap.set
local del = vim.keymap.del
local fn = vim.fn
local cmd = vim.cmd
local isVSCode = vim.g.vscode

-- local isNeovide = vim.g.neovide

-- jumps
set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- tabs
set("n", "<leader><TAB>l", cmd.tabnext, { desc = "Next Tab" })
set("n", "<leader><TAB>h", cmd.tabprevious, { desc = "Previous Tab" })

del("n", "<leader><TAB>]")
del("n", "<leader><TAB>[")

-- Disable arrow keys in all modes
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  set("", key, "<Nop>", { noremap = true, silent = true })
  set("i", key, "<Nop>", { noremap = true, silent = true })
  set("v", key, "<Nop>", { noremap = true, silent = true })
end

-- disable buffer tabs
del("n", "<S-H>")
del("n", "<S-L>")

-- when using nvim in vscode
if isVSCode then
  local vscode = require("vscode")
  set("n", "<leader>e", function()
    vscode.action("workbench.files.action.collapseExplorerFolders")
    vscode.action("workbench.view.explorer")
  end, { desc = "Collapse & Focus Explorer" })

  set("n", "<leader>aa", function()
    vscode.action("workbench.action.chat.toggle")
  end, { desc = "Toggle VS Code Chat" })

  set("n", "<leader>wo", function()
    vscode.action("workbench.action.closeEditorsInOtherGroups")
  end, { desc = "Close other editors" })

  set("n", "<leader>wd", function()
    vscode.action("workbench.action.closeEditorsAndGroup")
  end, { desc = "Close this editor" })
end

-- :term
set("t", "<Esc><Esc>", [[<C-\><C-n>]], { noremap = true })

-- if isNeovide then
--   -- tabs
--   set("n", "<a-l>", cmd.tabnext, { desc = "Next Tab" })
--   set("n", "<a-h>", cmd.tabprevious, { desc = "Previous Tab" })
--   set("n", "<a-s-h>", function()
--     if fn.tabpagenr() > 1 then
--       cmd("tabmove -1")
--     end
--   end, { desc = "Move Tab Left" })
--
--   set("n", "<a-s-l>", function()
--     if fn.tabpagenr() < fn.tabpagenr("$") then
--       cmd("tabmove +1")
--     end
--   end, { desc = "Move Tab Right" })
--   set("n", "<leader><tab>t", function()
--     cmd.tabnew()
--     cmd.term()
--     cmd.startinsert()
--   end, { desc = "New Terminal Tab" })
--   set({ "n", "v", "s", "x", "o", "i", "l", "c", "t" }, "<C-S-v>", function()
--     vim.api.nvim_paste(fn.getreg("+"), true, -1)
--   end, { noremap = true, silent = true })
-- end
