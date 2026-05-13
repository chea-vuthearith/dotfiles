vim.pack.add({
	{
		src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
		version = vim.version.range("3"),
	},
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/folke/snacks.nvim",
})

local events = require("neo-tree.events")
local on_move = function(data)
	Snacks.rename.on_rename_file(data.source, data.destination)
end
require("neo-tree").setup({
	close_if_last_window = true,
	popup_border_style = "rounded",
	event_handlers = {
		{ event = events.FILE_MOVED, handler = on_move },
		{ event = events.FILE_RENAMED, handler = on_move },
	},
	filesystem = {
		filtered_items = {
			visible = true,
			show_hidden_count = true,
			hide_dotfiles = false,
			hide_gitignored = true,
			hide_ignored = true,
		},
	},
	window = {
		mappings = {
			["l"] = "open",
			["h"] = "close_node",
			["<space>"] = "none",
			["Y"] = {
				function(state)
					local node = state.tree:get_node()
					local path = node:get_id()
					vim.fn.setreg("+", path, "c")
				end,
				desc = "Copy Path to Clipboard",
			},
			["O"] = {
				function(state)
					local path = state.tree:get_node().path
					vim.fn.jobstart({ "xdg-open", path }, { detach = true })
				end,
				desc = "Open with System Application",
			},
			["P"] = { "toggle_preview", config = { use_float = false } },
		},
	},
})

vim.keymap.set("n", "<leader>ge", function()
	require("neo-tree.command").execute({ source = "git_status", toggle = true })
end, { desc = "Explorer NeoTree (git)" })

vim.keymap.set("n", "<leader>e", function()
	require("neo-tree.command").execute({ reveal = true, toggle = true, reveal_force_cwd = true })
end, { desc = "Explorer NeoTree" })
