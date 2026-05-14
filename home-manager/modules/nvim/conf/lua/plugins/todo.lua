require("todo-comments").setup({})

vim.keymap.set("n", "<leader>st", function()
	require("fzf-lua").grep({ search = "TODO|FIXME|HACK|WARN|PERF|NOTE|BUG" })
end, { desc = "Find TODOs" })
