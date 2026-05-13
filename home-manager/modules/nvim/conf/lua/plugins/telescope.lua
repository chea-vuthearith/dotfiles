local open_with_trouble = require("trouble.sources.telescope").open

local actions = require("telescope.actions")

require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<Esc>"] = actions.close,
				["<c-t>"] = open_with_trouble,
			},
			n = {
				["<Esc>"] = actions.close,
				["<c-t>"] = open_with_trouble,
			},
		},
	},
})

require("telescope").load_extension("fzf")

vim.keymap.set("n", "<leader><leader>", function()
	require("telescope.builtin").find_files()
end, { desc = "Find Files" })

vim.keymap.set("n", "<leader>sk", "<cmd>Telescope keymaps<cr>", { desc = "Key Maps" })
