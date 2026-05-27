local function run_build(spec, path)
	local build = spec.data and spec.data.build
	if not build then
		return
	end

	if type(build) == "string" and build:sub(1, 1) == ":" then
		vim.cmd(build:sub(2))
		return
	end

	vim.system({ "sh", "-c", build }, {
		cwd = path,
		text = true,
	})
end

-- build plugins whose spec has data.build
vim.api.nvim_create_autocmd("PackChanged", {
	callback = function(ev)
		if ev.data.kind == "install" or ev.data.kind == "update" then
			run_build(ev.data.spec, ev.data.path)
		end
	end,
})

--- @type (string|vim.pack.Spec)[]
local specs = {
	{ src = "https://github.com/tpope/vim-abolish" },
	"https://github.com/MeanderingProgrammer/render-markdown.nvim",
	{ src = "https://github.com/saghen/blink.cmp" },
	{ src = "https://github.com/saghen/blink.lib" },
	{ src = "https://github.com/chrisgrieser/nvim-early-retirement" },
	{ src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
	-- { src = "https://github.com/mistricky/codesnap.nvim", version = "v1.6.3", data = { build = "make" } },
	{ src = "https://github.com/stevearc/conform.nvim" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-ui" },
	{ src = "https://github.com/tpope/vim-dadbod" },
	{ src = "https://github.com/kristijanhusak/vim-dadbod-completion" },
	{ src = "https://github.com/monaqa/dial.nvim" },
	{ src = "https://github.com/lewis6991/gitsigns.nvim" },
	{ src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
	{ src = "https://github.com/nvim-lua/plenary.nvim" },
	{ src = "https://github.com/neovim/nvim-lspconfig" },
	{ src = "https://github.com/folke/snacks.nvim" },
	{ src = "https://github.com/nvim-lualine/lualine.nvim" },
	{ src = "https://github.com/nvim-mini/mini.ai" },
	{ src = "https://github.com/nvim-mini/mini.comment" },
	{ src = "https://github.com/nvim-mini/mini.icons" },
	{ src = "https://github.com/MagicDuck/grug-far.nvim" },
	{ src = "https://github.com/MunifTanjim/nui.nvim" },
	{ src = "https://github.com/folke/noice.nvim", name = "noice" },
	{ src = "https://github.com/folke/sidekick.nvim" },
	{ src = "https://github.com/nvim-mini/mini.surround" },
	{ src = "https://github.com/folke/trouble.nvim" },
	{ src = "https://github.com/mrjones2014/smart-splits.nvim" },
	{ src = "https://github.com/JoosepAlviste/nvim-ts-context-commentstring" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-context" },
	{ src = "https://github.com/folke/todo-comments.nvim" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", branch = "main", data = { build = ":TSUpdate" } },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
	{ src = "https://github.com/windwp/nvim-ts-autotag" },
	{ src = "https://github.com/dmmulroy/tsc.nvim" },
	{ src = "https://github.com/linux-cultist/venv-selector.nvim" },
	{ src = "https://github.com/folke/which-key.nvim" },
	{ src = "https://github.com/gbprod/yanky.nvim" },
	"https://github.com/folke/lazydev.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	{ src = "https://github.com/L3MON4D3/LuaSnip", data = { build = "make install_jsregexp" } },
}

local removed = {}
local on_disk = vim.pack.get()
if #on_disk ~= #specs then
	local expected = {}
	for _, spec in ipairs(specs) do
		expected[type(spec) == "string" and spec or spec.src] = true
	end
	for _, plugin in ipairs(on_disk) do
		if not expected[plugin.spec.src] then
			table.insert(removed, plugin.spec.name)
			vim.pack.del({ plugin.spec.name })
		end
	end
end

local current_file = debug.getinfo(1, "S").source:sub(2)
local config_dir = vim.fn.fnamemodify(current_file, ":h")
local plugins_dir = vim.fn.fnamemodify(config_dir, ":h") .. "/plugins"
local plugin_files = vim.fn.glob(plugins_dir .. "/*.lua", false, true)
vim.pack.add(specs)
local errors = {}
for _, file in ipairs(plugin_files) do
	local module = "plugins." .. vim.fn.fnamemodify(file, ":t:r")
	local ok, err = pcall(require, module)
	if not ok then
		table.insert(errors, ("Failed to load %s: %s"):format(module, err))
	end
end

if #removed > 0 then
	vim.schedule(function()
		vim.notify("Plugins removed: " .. table.concat(removed, ", "), vim.log.levels.WARN)
	end)
end

if #errors > 0 then
	vim.schedule(function()
		vim.notify(table.concat(errors, "\n"), vim.log.levels.ERROR)
	end)
end
