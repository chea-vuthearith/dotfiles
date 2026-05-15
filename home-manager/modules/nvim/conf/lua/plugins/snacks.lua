local snacks = require("snacks")
snacks.setup({
	dashboard = { enabled = false },
	animate = { enabled = false },
	bigfile = { enabled = true },
	image = { enabled = true },
	notifier = { enabled = true },
	quickfile = { enabled = true },
	words = { enabled = true },
	indent = { enabed = true },
	statuscolumn = { enabed = true },
	scope = { enabled = true },
	explorer = { replace_netrw = true, trash = true },
	picker = {
		enabled = true,
		actions = {
			trouble_open = require("trouble.sources.snacks").actions.trouble_open,
		},

		sources = {
			explorer = {
				actions = {
					explorer_find_files = function(picker)
						Snacks.picker.files({ cwd = picker:cwd() })
					end,
				},
				hidden = true,
				follow_file = true,
				win = {
					input = {
						keys = {
							["<esc>"] = { "focus_list", mode = "i" },
						},
					},
					list = {
						keys = {
							["<esc>"] = { "", mode = "n" },
							["<leader><leader>"] = { "explorer_find_files", mode = { "n" } },
						},
					},
				},
			},
			files = { hidden = true, follow = true },
		},
		win = {
			input = {
				keys = {
					["<esc>"] = { "close", mode = { "n", "i" } },
					["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
					["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
					["<a-i>"] = { "toggle_ignored", mode = { "n", "i" } },
					["<a-.>"] = { "toggle_hidden", mode = { "n", "i" } },
					["<a-f>"] = { "toggle_follow", mode = { "n", "i" } },
					["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
				},
			},
		},
	},
})
local map = vim.keymap.set
map("n", "<leader>n", function()
	snacks.picker.notifications()
end, { desc = "Notification History" })
map("n", "<leader>bd", function()
	snacks.bufdelete()
end, { desc = "Delete Buffer" })
map("n", "<leader>bo", function()
	snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })
map("n", "<leader>gL", function()
	snacks.picker.git_log()
end, { desc = "Git Log (cwd)" })
map("n", "<leader>gb", function()
	snacks.picker.git_log_line()
end, { desc = "Git Blame Line" })
map("n", "<leader>gf", function()
	snacks.picker.git_log_file()
end, { desc = "Git Current File History" })
map({ "n", "x" }, "<leader>gB", function()
	snacks.gitbrowse()
end, { desc = "Git Browse (open)" })
map({ "n", "x" }, "<leader>gY", function()
	snacks.gitbrowse({
		open = function(url)
			vim.fn.setreg("+", url)
		end,
		notify = false,
	})
end, { desc = "Git Browse (copy)" })
map({ "n", "t" }, "<C-_>", function()
	snacks.terminal.focus(nil, { cwd = vim.fn.getcwd() })
end, { desc = "Terminal (Root Dir)" })
map({ "n" }, "<leader>z", function()
	snacks.picker.zoxide()
end, { desc = "Zoxide" })
map({ "n" }, "<leader>p", function()
	snacks.picker.cliphist()
end, { desc = "Clip history" })
map("n", "<leader>e", function()
	Snacks.explorer()
end, { desc = "Explorer" })
map("n", "<leader>E", function()
	Snacks.explorer({ cwd = Snacks.git.get_root() })
end, { desc = "Explorer (Git root)" })
map("n", "<leader>gd", function()
	Snacks.picker.git_diff()
end, { desc = "Git Diff" })
map("n", "<leader><leader>", function()
	Snacks.picker.files()
end, { desc = "Find Files" })
map("n", "<leader>sk", function()
	Snacks.picker.keymaps()
end, { desc = "Key Maps" })
map("n", "<leader>/", function()
	Snacks.picker.grep()
end, { desc = "Grep Project" })
map("n", "<leader>fc", function()
	Snacks.picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
snacks.toggle.diagnostics():map("<leader>ud")
snacks.toggle.line_number():map("<leader>ul")
snacks.toggle
	.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" })
	:map("<leader>uc")
snacks.toggle
	.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" })
	:map("<leader>uA")
snacks.toggle.treesitter():map("<leader>uT")
snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
snacks.toggle.dim():map("<leader>uD")
snacks.toggle.animate():map("<leader>ua")
snacks.toggle.indent():map("<leader>ug")
snacks.toggle.scroll():map("<leader>uS")
snacks.toggle.profiler():map("<leader>dpp")
snacks.toggle.profiler_highlights():map("<leader>dph")
