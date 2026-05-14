require("gitsigns").setup({
	signs = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
		untracked = { text = "▎" },
	},
	signs_staged = {
		add = { text = "▎" },
		change = { text = "▎" },
		delete = { text = "" },
		topdelete = { text = "" },
		changedelete = { text = "▎" },
	},
	on_attach = function(buffer)
		local gs = package.loaded.gitsigns

		local function map(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc, silent = true })
		end

		map("n", "]h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "]c", bang = true })
			else
				gs.nav_hunk("next")
			end
		end, "Next Hunk")
		map("n", "[h", function()
			if vim.wo.diff then
				vim.cmd.normal({ "[c", bang = true })
			else
				gs.nav_hunk("prev")
			end
		end, "Prev Hunk")
		map("n", "]H", function()
			gs.nav_hunk("last")
		end, "Last Hunk")
		map("n", "[H", function()
			gs.nav_hunk("first")
		end, "First Hunk")
		map({ "n", "x" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
		map({ "n", "x" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
		map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
		map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
		map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
		map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
		map("n", "<leader>ghb", function()
			gs.blame_line({ full = true })
		end, "Blame Line")
		map("n", "<leader>ghB", function()
			gs.blame()
		end, "Blame Buffer")
		map("n", "<leader>ghd", gs.diffthis, "Diff This")
		map("n", "<leader>ghD", function()
			gs.diffthis("~")
		end, "Diff This ~")
		map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
	end,
})

local map = vim.keymap.set

-- disable diagnostics in merge tool
if os.getenv("NVIM_MERGETOOL") then
	vim.api.nvim_create_autocmd("LspAttach", {
		group = vim.api.nvim_create_augroup("mergetool_lsp", { clear = true }),
		callback = function(args)
			if vim.wo.diff then
				vim.diagnostic.enable(false)
			end
		end,
	})
end

map("n", "]x", function()
	local pos = vim.fn.search("^<<<<<<<", "W")
	if pos > 0 then
		vim.cmd("normal! zz")
	end
end, { desc = "Next Conflict Start" })
map("n", "[x", function()
	local pos = vim.fn.search("^<<<<<<<", "bW")
	if pos > 0 then
		vim.cmd("normal! zz")
	end
end, { desc = "Prev Conflict Start" })
map("n", "]X", function()
	local pos = vim.fn.search("^>>>>>>>", "W")
	if pos > 0 then
		vim.cmd("normal! zz")
	end
end, { desc = "Next Conflict End" })
map("n", "[X", function()
	local pos = vim.fn.search("^>>>>>>>", "bW")
	if pos > 0 then
		vim.cmd("normal! zz")
	end
end, { desc = "Prev Conflict End" })

map("n", "<leader>gat", function()
	if vim.wo.diff then
		vim.cmd("diffget RE")
	end
end, { desc = "Accept Theirs" })
map("n", "<leader>gao", function()
	if vim.wo.diff then
		vim.cmd("diffget LO")
	end
end, { desc = "Accept Ours" })
map("n", "<leader>ga0", function()
	if vim.wo.diff then
		vim.cmd("diffget BA")
	end
end, { desc = "Accept None" })
map("n", "<leader>gam", function()
	local file = vim.fn.expand("%:p")
	vim.fn.system({ "tmux", "neww", "env", "NVIM_MERGETOOL=1", "git", "mergetool", file })
end, { desc = "Mergetool Current File (tmux)" })
map("n", "<leader>gal", function()
	if require("trouble").is_open() then
		require("trouble").close()
	end
	local lines = vim.fn.systemlist("git diff --check")
	local items = {}
	local git_root = require("snacks").git.get_root()
	if not git_root then
		vim.notify("Not in a git repo", vim.log.levels.ERROR, { title = "Git" })
		return
	end
	for _, line in ipairs(lines) do
		local filename, lnum_str, msg = line:match("^(.-):(%d+):%s*(.*)$")
		if filename then
			local lnum = tonumber(lnum_str)
			if lnum and lnum > 0 then
				table.insert(items, {
					filename = git_root .. "/" .. filename,
					lnum = lnum,
					text = msg,
				})
			end
		end
	end
	if #items == 0 then
		vim.notify("No conflicts found", vim.log.levels.INFO, { title = "Git" })
		return
	end
	vim.fn.setloclist(0, items)
	require("trouble").open({ mode = "loclist" })
end, { desc = "List Conflicts" })
