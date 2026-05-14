require("nvim-treesitter").setup({
	indent = { enable = true },
	highlight = { enable = true },
	folds = { enable = true },
	install_dir = vim.fn.stdpath("data") .. "/site",
})
require("nvim-treesitter")
	.install({
		"bash",
		"c",
		"cpp",
		"css",
		"diff",
		"gitattributes",
		"gitcommit",
		"git_config",
		"gitignore",
		"git_rebase",
		"go",
		"html",
		"java",
		"javascript",
		"json",
		"lua",
		"markdown",
		"markdown_inline",
		"nix",
		"python",
		"query",
		"regex",
		"rust",
		"sql",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"yaml",
	})
	:wait(300000) -- wait max. 5 minutes

require("nvim-ts-autotag").setup({})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_features", { clear = true }),
	callback = function(ev)
		-- skip special buffers
		if vim.bo[ev.buf].buftype ~= "" then
			return
		end

		vim.treesitter.start(ev.buf)
		vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
			vim.wo[win].foldmethod = "expr"
			vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
		end
	end,
})

local textobjects_opts = {
	move = {
		enable = true,
		set_jumps = true,
		keys = {
			goto_next_start = { ["]f"] = "@function.outer", ["]c"] = "@class.outer", ["]a"] = "@parameter.inner" },
			goto_next_end = { ["]F"] = "@function.outer", ["]C"] = "@class.outer", ["]A"] = "@parameter.inner" },
			goto_previous_start = { ["[f"] = "@function.outer", ["[c"] = "@class.outer", ["[a"] = "@parameter.inner" },
			goto_previous_end = { ["[F"] = "@function.outer", ["[C"] = "@class.outer", ["[A"] = "@parameter.inner" },
		},
	},
}

local textobjects = require("nvim-treesitter-textobjects")
textobjects.setup(textobjects_opts)

local function attach(buf)
	local moves = vim.tbl_get(textobjects_opts, "move", "keys") or {}

	for method, keymaps in pairs(moves) do
		for key, query in pairs(keymaps) do
			local queries = type(query) == "table" and query or { query }
			local parts = {}
			for _, q in ipairs(queries) do
				local part = q:gsub("@", ""):gsub("%..*", "")
				part = part:sub(1, 1):upper() .. part:sub(2)
				table.insert(parts, part)
			end
			local desc = table.concat(parts, " or ")
			desc = (key:sub(1, 1) == "[" and "Prev " or "Next ") .. desc
			desc = desc .. (key:sub(2, 2) == key:sub(2, 2):upper() and " End" or " Start")
			vim.keymap.set({ "n", "x", "o" }, key, function()
				if vim.wo.diff and key:find("[cC]") then
					return vim.cmd("normal! " .. key)
				end
				require("nvim-treesitter-textobjects.move")[method](query, "textobjects")
			end, {
				buffer = buf,
				desc = desc,
				silent = true,
			})
		end
	end
end

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_textobjects", { clear = true }),
	callback = function(ev)
		attach(ev.buf)
	end,
})
vim.tbl_map(attach, vim.api.nvim_list_bufs())

vim.api.nvim_set_hl(0, "TreesitterContextBottom", { underline = false })
vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = false })
