vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim" },
	"https://github.com/nvim-lua/plenary.nvim",
})

local actions = require("telescope.actions")

require("telescope").setup({
	defaults = {
		mappings = {
			i = {
				["<Esc>"] = actions.close,
			},
			n = {
				["<Esc>"] = actions.close,
			},
		},
	},
})

vim.keymap.set("n", "<leader><leader>", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })
