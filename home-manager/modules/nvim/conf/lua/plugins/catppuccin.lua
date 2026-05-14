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
			errors = { "undercurl" },
			hints = { "undercurl" },
			warnings = { "undercurl" },
			information = { "undercurl" },
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
		lsp_trouble = true,
		dadbod_ui = true,
		which_key = true,
		fzf = true,
		treesitter_context = true,
		gitsigns = {
			enabled = true,
			transparent = true,
		},
		blink_cmp = {
			style = "solid",
		},
	},
})

vim.cmd.colorscheme("catppuccin-nvim")
