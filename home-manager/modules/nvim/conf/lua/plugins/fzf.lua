require("fzf-lua").setup({
	defaults = {
		profile = "fzf-tmux",
	},
	files = {
		cmd = "fd --type f --hidden --follow --exclude .git",
	},
})

vim.keymap.set("n", "<leader>z", "<cmd>FzfLua zoxide<cr>", { desc = "List Zoxide Directories" })
vim.keymap.set("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep Project" })
vim.keymap.set("n", "<leader>fc", function()
	require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
