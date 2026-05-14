vim.keymap.set("n", "<leader>hl", function()
	require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Open harpoon window" })

vim.keymap.set("n", "<leader>ha", function()
	require("harpoon"):list():add()
end, { desc = "Add file to harpoon" })
vim.keymap.set("n", "<C-p>", function()
	require("harpoon"):list():prev()
end, { desc = "Go to previous harpoon buffer" })

vim.keymap.set("n", "<C-n>", function()
	require("harpoon"):list():next()
end, { desc = "Go to next harpoon buffer" })

for i = 1, 4 do
	vim.keymap.set("n", "<leader>" .. i, function()
		require("harpoon"):list():select(i)
	end, { desc = "Select harpoon file " .. i })
end
