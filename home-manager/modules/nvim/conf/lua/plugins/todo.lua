require("todo-comments").setup({})

vim.keymap.set("n", "<leader>st", function()
	Snacks.picker.grep({ search = "TODO|FIXME|HACK|WARN|PERF|NOTE|BUG" })
end, { desc = "Find TODOs" })
