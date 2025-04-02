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
