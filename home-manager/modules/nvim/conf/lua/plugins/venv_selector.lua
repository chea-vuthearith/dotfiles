require("venv-selector").setup({})

vim.api.nvim_create_autocmd("FileType", {
	pattern = { "python" },
	group = vim.api.nvim_create_augroup("venv_selector_keymap", { clear = true }),
	callback = function(ev)
		vim.keymap.set("n", "<leader>cv", "<cmd>VenvSelect<cr>", { buffer = ev.buf, desc = "Select Python Venv" })
	end,
})
