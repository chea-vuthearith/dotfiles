local snacks = require("snacks")
local icons = {
	Error = " ",
	Warn = " ",
	Hint = " ",
	Info = " ",
}

vim.diagnostic.config({
	underline = true,
	update_in_insert = false,
	severity_sort = true,
	virtual_text = {
		spacing = 4,
		source = "if_many",
		prefix = "●",
	},
	signs = {
		text = {
			[vim.diagnostic.severity.ERROR] = icons.Error,
			[vim.diagnostic.severity.WARN] = icons.Warn,
			[vim.diagnostic.severity.HINT] = icons.Hint,
			[vim.diagnostic.severity.INFO] = icons.Info,
		},
	},
})
local map = vim.keymap.set
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local bufnr = ev.buf
		if client and client.name == "copilot" and vim.lsp.inline_completion then
			vim.lsp.inline_completion.enable(true)
		end

		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"

		map("n", "gd", function()
			Snacks.picker.lsp_definitions()
		end, { desc = "Goto Definition" })

		map("n", "gr", function()
			Snacks.picker.lsp_references()
		end, { desc = "References", nowait = true })

		map("n", "gI", function()
			Snacks.picker.lsp_implementations()
		end, { desc = "Goto Implementation" })

		map("n", "gy", function()
			Snacks.picker.lsp_type_definitions()
		end, { desc = "Goto T[y]pe Definition" })

		map("n", "gD", Snacks.picker.lsp_declarations, { desc = "Goto Declaration" })

		map("n", "gi", Snacks.picker.lsp_incoming_calls, { desc = "Incoming Calls" })

		map("n", "go", Snacks.picker.lsp_outgoing_calls, { desc = "Outgoing calls" })

		map("n", "<leader>ss", Snacks.picker.lsp_symbols, { desc = "Symbols" })

		map("n", "<leader>sS", Snacks.picker.lsp_workspace_symbols, { desc = "Symbols (Workspace)" })

		map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })

		map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })

		map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, {
			desc = "Code Action",
		})

		map("n", "<leader>cr", vim.lsp.buf.rename, { desc = "Rename" })

		map("n", "<leader>co", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = { only = { "source.organizeImports" }, diagnostics = {} },
			})
		end, { desc = "Organize Imports" })

		map("n", "<leader>cR", function()
			local old = vim.api.nvim_buf_get_name(bufnr)
			local new = vim.fn.input("New name: ", old)
			snacks.rename.on_rename_file(old, new)
		end, { desc = "Rename File" })

		map("n", "]]", function()
			snacks.words.jump(vim.v.count1)
		end, { desc = "Next Reference" })

		map("n", "[[", function()
			snacks.words.jump(-vim.v.count1)
		end, { desc = "Prev Reference" })
	end,
})

map("n", "<leader>cl", snacks.picker.lsp_config, { desc = "Lsp Info" })

vim.lsp.config("*", {
	capabilities = {
		workspace = {
			fileOperations = {
				didRename = true,
				willRename = true,
			},
		},
	},
})

-- vim.lsp.config("lua_ls", {
-- 	settings = {
-- 		Lua = {
-- 			runtime = { version = "LuaJIT" },
-- 			codeLens = { enable = true },
-- 			completion = { callSnippet = "Replace" },
-- 			doc = { privateName = { "^_" } },
-- 			workspace = {
-- 				library = vim.api.nvim_get_runtime_file("", true),
-- 				checkThirdParty = false,
-- 			},
-- 			diagnostics = { globals = { "vim" } },
-- 			hint = {
-- 				enable = true,
-- 				setType = false,
-- 				paramType = true,
-- 				paramName = "Disable",
-- 				semicolon = "Disable",
-- 				arrayIndex = "Disable",
-- 			},
-- 		},
-- 	},
-- })
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
vim.lsp.enable("pyright")
vim.lsp.enable("yamlls")
vim.lsp.enable("taplo")
vim.lsp.enable("prismals")

vim.lsp.config("copilot", {
	telemetry = {
		telemetryLevel = "none",
	},
})
vim.lsp.enable("copilot")
