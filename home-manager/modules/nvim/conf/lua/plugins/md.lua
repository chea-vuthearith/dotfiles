require("render-markdown").setup({
	latex = { enabled = false },
	code = {
		sign = false,
		width = "block",
		right_pad = 1,
	},
	bullet = {
		right_pad = 1,
	},
	checkbox = {
		enabled = true,
	},
	heading = {
		enabled = true,
		sign = true,
		icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
	},
})

vim.fn["mkdp#util#install"]()
