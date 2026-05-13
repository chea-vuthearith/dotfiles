local TS = require("nvim-treesitter")
local install_dir = vim.fn.stdpath("data") .. "/site"
local opts = {
	indent = { enable = true },
	highlight = { enable = true },
	folds = { enable = true },
	install_dir = install_dir,
	ensure_installed = {
		"bash",
		"c",
		"diff",
		"html",
		"javascript",
		"jsdoc",
		"json",
		"lua",
		"luadoc",
		"luap",
		"markdown",
		"markdown_inline",
		"printf",
		"python",
		"query",
		"regex",
		"toml",
		"tsx",
		"typescript",
		"vim",
		"vimdoc",
		"xml",
		"yaml",
	},
}

if TS.get_installed then
	TS.setup(opts)

	local installed = TS.get_installed() or {}
	local installed_set = {}
	for _, lang in ipairs(installed) do
		installed_set[lang] = true
	end

	local install = vim.tbl_filter(function(lang)
		return not installed_set[lang]
	end, opts.ensure_installed or {})

	if #install > 0 then
		TS.install(install, { summary = true })
	end
end

require("nvim-ts-autotag").setup({})

vim.api.nvim_create_autocmd("FileType", {
	group = vim.api.nvim_create_augroup("treesitter_features", { clear = true }),
	callback = function(ev)
		local ft = ev.match
		local lang = vim.treesitter.language.get_lang(ft)
		if not lang then
			return
		end

		local function enabled(feat)
			local f = opts[feat] or {}
			if f.enable == false then
				return false
			end
			if type(f.disable) == "table" and vim.tbl_contains(f.disable, lang) then
				return false
			end
			return true
		end

		if enabled("highlight") then
			vim.treesitter.start(ev.buf)
		end

		if enabled("indent") then
			vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
		end

		if enabled("folds") then
			for _, win in ipairs(vim.fn.win_findbuf(ev.buf)) do
				vim.wo[win].foldmethod = "expr"
				vim.wo[win].foldexpr = "v:lua.vim.treesitter.foldexpr()"
			end
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
