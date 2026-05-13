vim.pack.add({
	{ src = "https://github.com/mistricky/codesnap.nvim", version = "v1.6.3" },
})

require("codesnap").setup({
	radius = 0,
	editor_font_family = "FiraCode Nerd Font",
	mac_window_bar = false,
	has_line_number = true,
	has_breadcrumbs = true,
	watermark = "",
	bg_padding = 0,
})

vim.keymap.set("x", "<leader>cs", ":CodeSnap<cr>", { desc = "Save selected code snapshot into clipboard" })
vim.keymap.set(
	"x",
	"<leader>ch",
	":CodeSnapHighlight<cr>",
	{ desc = "Highlight selected code snapshot and save into clipboard" }
)
