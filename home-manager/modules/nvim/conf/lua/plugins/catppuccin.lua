vim.pack.add({
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({
	term_colors = true,
	transparent_background = true,
	float = {
		solid = true,
		transparent = true,
	},
	lsp_styles = { -- Handles the style of specific lsp hl groups (see `:h lsp-highlight`).
		virtual_text = {
			errors = { "italic" },
			hints = { "italic" },
			warnings = { "italic" },
			information = { "italic" },
			ok = { "italic" },
		},
		underlines = {
			errors = { "underline" },
			hints = { "underline" },
			warnings = { "underline" },
			information = { "underline" },
			ok = { "underline" },
		},
		inlay_hints = {
			background = true,
		},
	},
	integrations = {
		harpoon = true,
		markview = true,
		neotree = true,
		noice = true,
		snacks = {
			enabled = true,
		},
		dadbod_ui = true,
		which_key = true,
		telescope = {
			enabled = true,
		},
		blink_cmp = {
			style = "bordered",
		},
	},
})

vim.cmd.colorscheme("catppuccin-nvim")
