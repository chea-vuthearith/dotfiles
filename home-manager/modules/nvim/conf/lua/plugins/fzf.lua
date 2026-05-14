local map = vim.keymap.set

local actions = require("trouble.sources.fzf").actions
local fzf = require("fzf-lua")

fzf.setup({
	{ "telescope", "fzf-tmux", "fzf-native" },
	ui_select = true,
	files = {
		cmd = "fd --type f --hidden --follow --exclude .git",
	},
	actions = {
		files = {
			["ctrl-t"] = actions.open,
			["alt-i"] = FzfLua.actions.toggle_ignore,
			["alt-."] = FzfLua.actions.toggle_hidden,
			["alt-f"] = FzfLua.actions.toggle_follow,
		},
	},
})

map("n", "<leader><leader>", function()
	fzf.files()
end, { desc = "Find Files" })

map("n", "<leader>sk", function()
	fzf.keymaps({
		previewer = false,
	})
end, { desc = "Key Maps" })

map("n", "<leader>z", "<cmd>FzfLua zoxide<cr>", { desc = "List Zoxide Directories" })
map("n", "<leader>/", "<cmd>FzfLua live_grep<cr>", { desc = "Grep Project" })
map("n", "<leader>fc", function()
	fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config File" })
