require("which-key").setup({
	preset = "helix",
	delay = 0,
})

vim.keymap.set("n", "<leader>?", function()
	require("which-key").show()
end, { desc = "which-key" })
