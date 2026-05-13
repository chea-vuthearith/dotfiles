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

-- ── On-attach (keymaps + hints + folds) ──────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(ev)
		local client = vim.lsp.get_client_by_id(ev.data.client_id)
		local bufnr = ev.buf
		local map = function(modes, lhs, rhs, desc, opts)
			vim.keymap.set(
				modes,
				lhs,
				rhs,
				vim.tbl_extend("force", { buffer = bufnr, silent = true, desc = desc }, opts or {})
			)
		end

		if client and client:supports_method("textDocument/inlayHint") and vim.bo[bufnr].filetype ~= "vue" then
			vim.lsp.inlay_hint.enable(false, { bufnr = bufnr })
		end

		if client and client.name == "copilot" and vim.lsp.inline_completion then
			vim.lsp.inline_completion.enable(true)
		end

		-- Folding (requires server-side fold provider)
		vim.wo.foldmethod = "expr"
		vim.wo.foldexpr = "v:lua.vim.lsp.foldexpr()"

		-- Codelens (disabled; uncomment to enable)
		-- if client and client:supports_method("textDocument/codeLens") then
		-- 	vim.lsp.codelens.refresh({ bufnr = bufnr })
		-- 	map({ "n", "x" }, "<leader>cc", vim.lsp.codelens.run, "Run Codelens")
		-- 	map("n", "<leader>cC", vim.lsp.codelens.refresh, "Refresh & Display Codelens")
		-- end

		-- Navigation
		map("n", "gd", function()
			require("telescope.builtin").lsp_definitions({ reuse_win = true })
		end, "Goto Definition")
		map("n", "gr", "<cmd>Telescope lsp_references<cr>", "References", { nowait = true })
		map("n", "gI", function()
			require("telescope.builtin").lsp_implementations({ reuse_win = true })
		end, "Goto Implementation")
		map("n", "gy", function()
			require("telescope.builtin").lsp_type_definitions({ reuse_win = true })
		end, "Goto T[y]pe Definition")
		map("n", "gD", vim.lsp.buf.declaration, "Goto Declaration")

		-- Hover / signature
		map("n", "K", vim.lsp.buf.hover, "Hover")
		map("n", "gK", vim.lsp.buf.signature_help, "Signature Help")
		map("i", "<c-k>", vim.lsp.buf.signature_help, "Signature Help")

		-- Actions
		map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, "Code Action")
		map("n", "<leader>cr", vim.lsp.buf.rename, "Rename")

		-- Source / organize imports
		map({ "n", "x" }, "<leader>cA", function()
			vim.lsp.buf.code_action({ context = { only = { "source" } } })
		end, "Source Action")

		map("n", "<leader>co", function()
			vim.lsp.buf.code_action({
				apply = true,
				context = { only = { "source.organizeImports" }, diagnostics = {} },
			})
		end, "Organize Imports")

		-- File rename (native; swap for Snacks if you keep it)
		map("n", "<leader>cR", function()
			local old = vim.api.nvim_buf_get_name(bufnr)
			local new = vim.fn.input("New name: ", old)
			if new ~= "" and new ~= old then
				vim.lsp.util.rename(old, new)
			end
		end, "Rename File")

		-- Reference jumping (native; swap for Snacks.words if you keep it)
		map("n", "]]", function()
			vim.lsp.buf.document_highlight()
		end, "Next Reference")
		map("n", "[[", function()
			vim.lsp.buf.clear_references()
		end, "Prev Reference")

		-- LSP info (native; was Snacks.picker.lsp_config)
		map("n", "<leader>cl", snacks.picker.lsp_config, "Lsp Info")
	end,
})

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

vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			codeLens = { enable = true },
			completion = { callSnippet = "Replace" },
			doc = { privateName = { "^_" } },
			workspace = {
				library = vim.api.nvim_get_runtime_file("", true),
				checkThirdParty = false,
			},
			diagnostics = { globals = { "vim" } },
			hint = {
				enable = true,
				setType = false,
				paramType = true,
				paramName = "Disable",
				semicolon = "Disable",
				arrayIndex = "Disable",
			},
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
vim.lsp.enable("pyright")
vim.lsp.enable("hyprls")
vim.lsp.enable("taplo")

vim.lsp.config("copilot", {
	telemetry = {
		telemetryLevel = "none",
	},
})
vim.lsp.enable("copilot")
