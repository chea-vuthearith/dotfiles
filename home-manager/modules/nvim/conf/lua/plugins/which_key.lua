require("which-key").setup({
	preset = "helix",
	timeoutlen = 50,
})

vim.keymap.set("n", "<leader>?", function()
	require("which-key").show()
end, { desc = "which-key" })
