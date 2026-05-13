vim.pack.add({
	"https://github.com/folke/todo-comments.nvim",
})

require("todo-comments").setup({})

vim.keymap.set("n", "<leader>st", vim.cmd.TodoTelescope, { desc = "Resize Left" })
