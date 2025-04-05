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

-- git-conflict.nvim
vim.keymap.set("n", "<leader>ga", "", { desc = "Accept" })
vim.keymap.set("n", "<leader>gao", "<Plug>(git-conflict-ours)", { desc = "Accept Ours" })
vim.keymap.set("n", "<leader>gat", "<Plug>(git-conflict-theirs)", { desc = "Accept Theirs" })
vim.keymap.set("n", "<leader>gab", "<Plug>(git-conflict-both)", { desc = "Accept Both" })
vim.keymap.set("n", "<leader>ga0", "<Plug>(git-conflict-none)", { desc = "Accept None" })
vim.keymap.set("n", "[x", "<Plug>(git-conflict-prev-conflict)", { desc = "Prev Conflict" })
vim.keymap.set("n", "]x", "<Plug>(git-conflict-next-conflict)", { desc = "Next Conflict" })

-- jumps
vim.keymap.set("n", "<C-u>", "<C-u>zz", { noremap = true, silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { noremap = true, silent = true })

-- smart-splits.nvim
vim.keymap.set("n", "<C-Left>", require("smart-splits").resize_left)
vim.keymap.set("n", "<C-Down>", require("smart-splits").resize_down)
vim.keymap.set("n", "<C-Up>", require("smart-splits").resize_up)
vim.keymap.set("n", "<C-Right>", require("smart-splits").resize_right)
-- moving between splits
vim.keymap.set("n", "<C-h>", require("smart-splits").move_cursor_left)
vim.keymap.set("n", "<C-j>", require("smart-splits").move_cursor_down)
vim.keymap.set("n", "<C-k>", require("smart-splits").move_cursor_up)
vim.keymap.set("n", "<C-l>", require("smart-splits").move_cursor_right)

vim.keymap.set("n", "<C-S-H>", "<cmd>WinShift left<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-J>", "<cmd>WinShift down<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-K>", "<cmd>WinShift up<cr>", { noremap = true, silent = true })
vim.keymap.set("n", "<C-S-L>", "<cmd>WinShift right<cr>", { noremap = true, silent = true })

--disable toggle term
vim.keymap.del("n", "<C-/>")
vim.keymap.del("n", "<C-_>")
