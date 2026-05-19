vim.keymap.set("n", "<leader>sr", function()
	require("grug-far").open()
end, {
	desc = "Search and replace",
})
