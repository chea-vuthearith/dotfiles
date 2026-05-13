vim.pack.add({
	"https://github.com/akinsho/git-conflict.nvim",
})

require("git-conflict").setup({
	default_mappings = false,
	list_opener = function()
		local ok, trouble = pcall(require, "trouble")
		if ok then
			trouble.open("qflist")
		else
			vim.cmd("copen")
		end
	end,
})

vim.keymap.set("n", "<leader>gal", ":GitConflictListQf<CR>", { desc = "List Conflicts" })
vim.keymap.set("n", "<leader>gao", "<Plug>(git-conflict-ours)", { desc = "Accept Ours" })
vim.keymap.set("n", "<leader>gat", "<Plug>(git-conflict-theirs)", { desc = "Accept Theirs" })
vim.keymap.set("n", "<leader>gab", "<Plug>(git-conflict-both)", { desc = "Accept Both" })
vim.keymap.set("n", "<leader>ga0", "<Plug>(git-conflict-none)", { desc = "Accept None" })
vim.keymap.set("n", "[x", "<Plug>(git-conflict-prev-conflict)", { desc = "Prev Conflict" })
vim.keymap.set("n", "]x", "<Plug>(git-conflict-next-conflict)", { desc = "Next Conflict" })
