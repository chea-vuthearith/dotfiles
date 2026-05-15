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

local map = vim.keymap.set

local markers = {
	start = "^<<<<<<< ",
	["end"] = "^>>>>>>> ",
}

local function jump_conflict(pattern, flags, label)
	local pos = vim.fn.search(pattern, flags)

	if pos > 0 then
		vim.cmd("normal! zz")
		return
	end

	vim.notify(("No %s conflict found"):format(label), vim.log.levels.INFO, {
		title = "Git Conflict",
	})
end

map("n", "]x", function()
	jump_conflict(markers.start, "W", "next")
end, { desc = "Next Conflict Start" })

map("n", "[x", function()
	jump_conflict(markers.start, "bW", "previous")
end, { desc = "Prev Conflict Start" })

map("n", "]X", function()
	jump_conflict(markers["end"], "W", "next end")
end, { desc = "Next Conflict End" })

map("n", "[X", function()
	jump_conflict(markers["end"], "bW", "previous end")
end, { desc = "Prev Conflict End" })

local function conflict_range()
	local cursor = vim.api.nvim_win_get_cursor(0)[1]
	local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)

	local start_line
	for i = cursor, 1, -1 do
		if lines[i]:match(markers.start) then
			start_line = i
			break
		end
	end

	if not start_line then
		return
	end

	for i = cursor, #lines do
		if lines[i]:match(markers["end"]) then
			return start_line, i
		end
	end
end

local function diffget_conflict(target, label)
	if not vim.wo.diff then
		vim.notify("Not in diff mode", vim.log.levels.WARN, {
			title = "Git Conflict",
		})
		return
	end

	local start_line, end_line = conflict_range()

	if not start_line or not end_line then
		vim.notify("No conflict block under cursor", vim.log.levels.INFO, {
			title = "Git Conflict",
		})
		return
	end

	vim.cmd(("%d,%ddiffget %s"):format(start_line, end_line, target))
end

if os.getenv("NVIM_MERGETOOL") then
	map("n", "<leader>gat", function()
		diffget_conflict("RE", "theirs")
	end, { desc = "Accept Theirs" })

	map("n", "<leader>gao", function()
		diffget_conflict("LO", "ours")
	end, { desc = "Accept Ours" })

	map("n", "<leader>ga0", function()
		diffget_conflict("BA", "base")
	end, { desc = "Accept None" })
end

map("n", "<leader>gam", function()
	local file = vim.fn.expand("%:p")

	vim.fn.system({
		"tmux",
		"neww",
		"env",
		"NVIM_MERGETOOL=1",
		"git",
		"mergetool",
		file,
	})
end, { desc = "Mergetool Current File (tmux)" })

map("n", "<leader>gal", function()
	local trouble = require("trouble")

	if trouble.is_open() then
		trouble.close()
	end

	local git_root = require("snacks").git.get_root()

	if not git_root then
		vim.notify("Not in a git repo", vim.log.levels.ERROR, {
			title = "Git",
		})
		return
	end

	local lines = vim.fn.systemlist("git diff --check")
	local items = {}

	for _, line in ipairs(lines) do
		local filename, lnum_str, msg = line:match("^(.-):(%d+):%s*(.*)$")

		local lnum = tonumber(lnum_str)

		if filename and lnum and lnum > 0 then
			items[#items + 1] = {
				filename = git_root .. "/" .. filename,
				lnum = lnum,
				text = msg,
			}
		end
	end

	if vim.tbl_isempty(items) then
		vim.notify("No conflicts found", vim.log.levels.INFO, {
			title = "Git",
		})
		return
	end

	vim.fn.setloclist(0, items)
	trouble.open({ mode = "loclist" })
end, { desc = "List Conflicts" })
