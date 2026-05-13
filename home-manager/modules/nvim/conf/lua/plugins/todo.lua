require("todo-comments").setup({})

vim.keymap.set("n", "<leader>st", vim.cmd.TodoTelescope, { desc = "Find TODOs" })
