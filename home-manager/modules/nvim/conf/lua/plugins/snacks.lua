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
})

vim.keymap.set("n", "<leader>n", function()
	if snacks.config.picker and snacks.config.picker.enabled then
		snacks.picker.notifications()
	else
		snacks.notifier.show_history()
	end
end, { desc = "Notification History" })

vim.keymap.set("n", "<leader>bd", function()
	snacks.bufdelete()
end, { desc = "Delete Buffer" })
vim.keymap.set("n", "<leader>bo", function()
	snacks.bufdelete.other()
end, { desc = "Delete Other Buffers" })
vim.keymap.set("n", "<leader>bD", "<cmd>:bd<cr>", { desc = "Delete Buffer and Window" })

vim.keymap.set("n", "<leader>gL", function()
	snacks.picker.git_log()
end, { desc = "Git Log (cwd)" })
vim.keymap.set("n", "<leader>gb", function()
	snacks.picker.git_log_line()
end, { desc = "Git Blame Line" })
vim.keymap.set("n", "<leader>gf", function()
	snacks.picker.git_log_file()
end, { desc = "Git Current File History" })
vim.keymap.set({ "n", "x" }, "<leader>gB", function()
	snacks.gitbrowse()
end, { desc = "Git Browse (open)" })
vim.keymap.set({ "n", "x" }, "<leader>gY", function()
	snacks.gitbrowse({
		open = function(url)
			vim.fn.setreg("+", url)
		end,
		notify = false,
	})
end, { desc = "Git Browse (copy)" })

vim.keymap.set({ "n", "t" }, "<C-_>", function()
	snacks.terminal.focus(nil, { cwd = vim.fn.getcwd() })
end, { desc = "Terminal (Root Dir)" })

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

if vim.lsp.inlay_hint then
	snacks.toggle.inlay_hints():map("<leader>uh")
end
