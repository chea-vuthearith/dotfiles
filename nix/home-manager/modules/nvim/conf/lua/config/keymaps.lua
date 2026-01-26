-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_set_keymap(
  "v",
  "<leader>tr",
  [[:s#\v(\d+)px#\=printf("%grem", 1.0/16*submatch(1))#g<CR>]],
  { noremap = true, silent = true, desc = "px to rem" }
)

vim.api.nvim_set_keymap(
  "v",
  "<leader>ts",
  [[:s/\v\a@<=(\u)/\L_\1/g<CR>]],
  { noremap = true, silent = true, desc = "to snake_case" }
)

vim.api.nvim_set_keymap(
  "v",
  "<leader>tc",
  [[:s/\v_(\a)/\u\1/g<CR>]],
  { noremap = true, silent = true, desc = "to camelCase" }
)
-- jumps
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

vim.keymap.set("n", "<leader><TAB>l", ":tabn<CR>", { desc = "Next Tab" })
vim.keymap.set("n", "<leader><TAB>h", ":tabp<CR>", { desc = "Previous Tab" })

vim.keymap.del("n", "<leader><TAB>]")
vim.keymap.del("n", "<leader><TAB>[")

-- Disable arrow keys in all modes
for _, key in ipairs({ "<Up>", "<Down>", "<Left>", "<Right>" }) do
  vim.keymap.set("", key, "<Nop>", { noremap = true, silent = true })
  vim.keymap.set("i", key, "<Nop>", { noremap = true, silent = true })
  vim.keymap.set("v", key, "<Nop>", { noremap = true, silent = true })
end

vim.keymap.del("n", "<S-H>")
vim.keymap.del("n", "<S-L>")

if vim.g.vscode then
  local vscode = require("vscode")
  vim.keymap.set("n", "<leader>e", function()
    vscode.action("workbench.files.action.collapseExplorerFolders")
    vscode.action("workbench.view.explorer")
  end, { desc = "Collapse & Focus Explorer" })

  vim.keymap.set("n", "<leader>aa", function()
    vscode.action("workbench.action.chat.toggle")
  end, { desc = "Toggle VS Code Chat" })

  vim.keymap.set("n", "<leader>wo", function()
    vscode.action("workbench.action.closeEditorsInOtherGroups")
  end, { desc = "Close other editors" })

  vim.keymap.set("n", "<leader>wd", function()
    vscode.action("workbench.action.closeEditorsAndGroup")
  end, { desc = "Close this editor" })
end
