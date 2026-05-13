vim.pack.add({
	{ src = "https://github.com/folke/noice.nvim" },
	"https://github.com/MunifTanjim/nui.nvim",
})

require("noice").setup({
	lsp = {
		-- override markdown rendering so that **cmp** and other plugins use **Treesitter**
		override = {
			["vim.lsp.util.convert_input_to_markdown_lines"] = true,
			["vim.lsp.util.stylize_markdown"] = true,
			["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
		},
	},
	cmdline = {
		view = "cmdline",
	},
	indent = { enabled = true },
	input = { enabled = true },
	notifier = { enabled = true },
	scope = { enabled = true },
	scroll = { enabled = true },
	statuscolumn = { enabled = false }, -- we set this in options.lua
	words = { enabled = true },
	presets = {
		command_palette = false,
		inc_rename = true,
	},
})
