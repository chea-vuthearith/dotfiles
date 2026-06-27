local project_root = "/home/kuro/code/work/groundup/GinaV2"
local api_root = project_root .. "/Backend/API"

-- The PR's path translation uses vim.loop.cwd() → workdir.
-- lcd to Backend/API when editing files there so the mapping is correct.
vim.api.nvim_create_autocmd("BufEnter", {
	pattern = api_root .. "/**/*.py",
	callback = function()
		vim.cmd("lcd " .. api_root)
	end,
})

-- The PR hardcodes "python" as the binary; patch it to use uv run python instead.
local base = require("neotest-python.base")
base.get_docker_python_command = function(_, docker_config)
	return vim.iter({
		{ "docker", "exec" },
		docker_config.args or {},
		{ docker_config.container },
		{ "uv", "run", "python" },
	}):flatten():totable()
end

require("neotest").setup({
	adapters = {
		require("neotest-python")({
			runner = "pytest",
			docker = {
				container = vim.trim(vim.fn.system(
					"cd "
						.. project_root
						.. " && docker compose"
						.. " -f docker-compose.data.yml"
						.. " -f docker-compose.auth.yml"
						.. " -f docker-compose.app.yml"
						.. " -f docker-compose.dev.yml"
						.. " ps --format '{{.Name}}' api 2>/dev/null | head -1"
				)),
				args = { "-i" },
				workdir = "/app",
			},
		}),
	},
	output = { open_on_run = true },
	summary = { open = "botright vsplit | vertical resize 50" },
	floating = { border = "rounded" },
})

vim.keymap.set("n", "<leader>tt", function()
	require("neotest").run.run()
end, { desc = "Run nearest test" })

vim.keymap.set("n", "<leader>tf", function()
	require("neotest").run.run(vim.fn.expand("%"))
end, { desc = "Run file tests" })

vim.keymap.set("n", "<leader>ts", function()
	require("neotest").summary.toggle()
end, { desc = "Toggle test summary" })

vim.keymap.set("n", "<leader>to", function()
	require("neotest").output.open({ enter = true, short = false })
end, { desc = "Test output (float)" })

vim.keymap.set("n", "<leader>tO", function()
	require("neotest").output_panel.toggle()
end, { desc = "Toggle test output panel" })
