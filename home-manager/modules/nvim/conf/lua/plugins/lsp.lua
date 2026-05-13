vim.pack.add({
	{ src = "https://github.com/neovim/nvim-lspconfig" },
})

vim.lsp.config("lua_ls", {
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
vim.lsp.enable("lua_ls")

vim.lsp.config("tsgo", {
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
vim.lsp.enable("tsgo")

vim.lsp.config("nixd", {
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
vim.lsp.enable("nixd")

vim.lsp.enable("biome")
vim.lsp.enable("hyprls")
vim.lsp.enable("taplo")
vim.lsp.enable("copilot")
