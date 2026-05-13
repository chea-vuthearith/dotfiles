vim.pack.add({
	{ src = "https://github.com/dmmulroy/tsc.nvim" },
})

require("tsc").setup({
	use_diagnostics = true,
	use_trouble_qflist = true,
	flags = "-b",
})

vim.keymap.set("n", "<leader>ct", function()
	require("tsc").run()
end, { desc = "Run TSC" })
-- TODO: add only to ts
