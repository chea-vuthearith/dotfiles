local current_file = debug.getinfo(1, "S").source:sub(2)
local config_dir = vim.fn.fnamemodify(current_file, ":h")
local plugins_dir = vim.fn.fnamemodify(config_dir, ":h") .. "/plugins"

local plugin_files = vim.fn.glob(plugins_dir .. "/*.lua", false, true)
table.sort(plugin_files)

for _, file in ipairs(plugin_files) do
	local module = "plugins." .. vim.fn.fnamemodify(file, ":t:r")
	require(module)
end
