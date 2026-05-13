vim.pack.add({
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

local palette = require("catppuccin.palettes").get_palette()

require("lualine").setup({
	sections = {
		lualine_b = { "branch" },
		lualine_x = {
			{
				function()
					local recording = vim.fn.reg_recording()
					if recording == "" then
						return ""
					end
					return "Recording @" .. recording
				end,
				color = { fg = palette.peach, gui = "bold" },
			},
		},
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
})
