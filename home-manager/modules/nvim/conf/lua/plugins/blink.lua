local cmp = require("blink.cmp")
vim.schedule(function()
	cmp.build():wait(60000)
end)
cmp.setup({
	completion = {
		list = {
			selection = {
				preselect = function(ctx)
					return not require("blink.cmp").snippet_active({ direction = 1 })
				end,
			},
		},
		ghost_text = { enabled = false },
		accept = {
			auto_brackets = { enabled = false },
		},
	},
	sources = {
		default = { "lazydev", "lsp", "path", "snippets", "buffer" },
		per_filetype = {
			sql = { "snippets", "dadbod", "buffer" },
		},
		providers = {
			dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" },
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				-- make lazydev completions top priority (see `:h blink.cmp`)
				score_offset = 100,
			},
		},
	},

	keymap = {
		preset = "super-tab",
		["<Tab>"] = {
			require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
			"fallback",
		},
		["<S-Tab>"] = {},
		["<C-space>"] = {
			function(cmp)
				if cmp.is_visible() then
					return cmp.hide()
				else
					return cmp.show()
				end
			end,
		},
	},
})
