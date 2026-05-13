require("tsc").setup({
	use_diagnostics = true,
	use_trouble_qflist = true,
	flags = "-b",
})

vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("tsc_tsgo_keymap", { clear = true }),
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		if not client or client.name ~= "tsgo" then
			return
		end
		vim.keymap.set("n", "<leader>ct", function()
			require("tsc").run()
		end, { desc = "Run TSC", buffer = ev.buf, silent = true })
	end,
})
