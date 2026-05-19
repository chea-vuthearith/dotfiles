require("conform").setup({
	formatters_by_ft = {
		javascript = { "biome" },
		javascriptreact = { "biome" },
		typescript = { "biome" },
		typescriptreact = { "biome" },
		html = { "biome" },
		css = { "biome" },
		json = { "biome" },
		sh = { "beautysh" },
		nix = { "alejandra" },
		kdl = { "kdlfmt" },
		lua = { "stylua" },
		python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
	},
	format_on_save = {
		timeout_ms = 500,
		lsp_format = "fallback",
	},
	formatters = {
		ruff_format = {
			exit_codes = { 0, 1 },
		},
		biome = {
			command = "biome",
			args = { "check", "--write", "$FILENAME" },
			stdin = false,
		},
	},
})
