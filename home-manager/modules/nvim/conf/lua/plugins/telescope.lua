vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/stevearc/dressing.nvim",
	"https://github.com/folke/trouble.nvim",
})

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

vim.keymap.set("n", "<leader><leader>", function()
	require("telescope.builtin").find_files()
end, { desc = "Find Files" })
