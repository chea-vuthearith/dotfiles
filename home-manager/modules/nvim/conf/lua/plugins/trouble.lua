vim.pack.add({ "https://github.com/folke/trouble.nvim" })
require("trouble").setup({})

local map = vim.keymap.set
map("n", "[q", function()
	require("trouble").prev({ skip_groups = true, jump = true })
end, { desc = "Prev Trouble Item" })
map("n", "]q", function()
	require("trouble").next({ skip_groups = true, jump = true })
end, { desc = "Next Trouble Item" })
