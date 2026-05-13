vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})

local lspconfig = require("lspconfig")

lspconfig.lua_ls.setup({
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			diagnostics = { globals = { "vim" } },
		},
	},
})

lspconfig.tsgo.setup({
	settings = {
		typescript = {
			preferences = {
				importModuleSpecifier = "non-relative",
				preferences = {
					autoImportSpecifierExcludeRegexes = {
						"^@mui/[^/]+$",
					},
				},
			},
		},
	},
})

lspconfig.nixd.setup({
	nixpkgs = {
		expr = "import <nixpkgs> { }",
		formatting = { command = { "alejandra" } },
		options = {
			nixos = {
				expr = '(builtins.getFlake "github:chea-vuthearith/dotfiles").nixosConfigurations.desktop.options',
			},
			home_manager = {
				expr = '(builtins.getFlake "github:chea-vuthearith/dotfiles").nixosConfigurations.desktop.options.home-manager.users.type.getSubOptions []',
			},
		},
	},
})

lspconfig.biome.setup({})
lspconfig.hyprls.setup({})
lspconfig.taplo.setup({})
lspconfig.copilot.setup({})
