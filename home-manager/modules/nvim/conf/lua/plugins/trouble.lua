require("trouble").setup({})

vim.keymap.set("n", "<leader>cS", "<cmd>Trouble symbols toggle<cr>", { desc = "Symbols Tree" })

local map = vim.keymap.set
map("n", "[q", function()
	require("trouble").prev({ skip_groups = true, jump = true })
end, { desc = "Prev Trouble Item" })
map("n", "[q", function()
	require("trouble").prev({ skip_groups = true, jump = true })
end, { desc = "Prev Trouble Item" })
map("n", "]q", function()
	require("trouble").next({ skip_groups = true, jump = true })
end, { desc = "Next Trouble Item" })
