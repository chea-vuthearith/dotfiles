vim.pack.add({
  { src = "https://github.com/mrjones2014/smart-splits.nvim" },
  { src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
})

require("smart-splits").setup({
  at_edge = "stop",
})

vim.keymap.set("n", "<C-Left>", function()
	require("smart-splits").resize_left()
end, { desc = "Resize Left" })
vim.keymap.set("n", "<C-Down>", function()
	require("smart-splits").resize_down()
end, { desc = "Resize Down" })
vim.keymap.set("n", "<C-Up>", function()
	require("smart-splits").resize_up()
end, { desc = "Resize Up" })
vim.keymap.set("n", "<C-Right>", function()
	require("smart-splits").resize_right()
end, { desc = "Resize Right" })

vim.keymap.set("n", "<C-h>", function()
	require("smart-splits").move_cursor_left()
end, { desc = "Go to Left Window" })
vim.keymap.set("n", "<C-j>", function()
	require("smart-splits").move_cursor_down()
end, { desc = "Go to Lower Window" })
vim.keymap.set("n", "<C-k>", function()
	require("smart-splits").move_cursor_up()
end, { desc = "Go to Upper Window" })
vim.keymap.set("n", "<C-l>", function()
	require("smart-splits").move_cursor_right()
end, { desc = "Go to Right Window" })

vim.keymap.set("n", "<C-S-H>", function()
	require("smart-splits").swap_buf_left()
end, { desc = "Swap Buffer Left" })
vim.keymap.set("n", "<C-S-J>", function()
	require("smart-splits").swap_buf_down()
end, { desc = "Swap Buffer Down" })
vim.keymap.set("n", "<C-S-K>", function()
	require("smart-splits").swap_buf_up()
end, { desc = "Swap Buffer Up" })
vim.keymap.set("n", "<C-S-L>", function()
	require("smart-splits").swap_buf_right()
end, { desc = "Swap Buffer Right" })

vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })
vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = false })
