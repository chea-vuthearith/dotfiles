local data_dir = vim.fn.stdpath("data") .. "/pretty-ts-errors"
vim.fn.mkdir(data_dir, "p")

vim.pack.add({
  {
    src = "https://github.com/neovim/nvim-lspconfig",
    name = "pretty-ts-errors-installer",
    build = "npm install --no-save pretty-ts-errors-markdown@latest",
    dir = data_dir,
  },
})

local function pretty_ts_formatter()
  local cache = {}
  local cache_order = {}
  local bin_path = data_dir .. "/node_modules/.bin/pretty-ts-errors-markdown"

  return function(diagnostic)
    if diagnostic.source ~= "ts" and diagnostic.source ~= "typescript" then
      return diagnostic.message
    end

    local cache_key = diagnostic.message .. (diagnostic.code or "")
    if cache[cache_key] then
      return cache[cache_key]
    end

    local diagnostic_json = vim.json.encode(diagnostic)
    local handle = io.popen(bin_path .. " -i '" .. diagnostic_json:gsub("'", "'\\''") .. "' 2>/dev/null")
    if handle then
      local prettified = handle:read("*a")
      handle:close()
      if prettified and prettified ~= "" then
        local result = prettified:gsub("^%s*(.-)%s*$", "%1")
        result = result:gsub("%[([^%]]+)%]%(([^%)]+)%)", "%1")
        result = result:gsub("```%w*\n", ""):gsub("\n```", "")
        if #cache_order >= 3 then
          local oldest = table.remove(cache_order, 1)
          cache[oldest] = nil
        end
        cache[cache_key] = result
        table.insert(cache_order, cache_key)
        return result
      end
    end
  end
end

vim.diagnostic.config({
  float = {
    format = pretty_ts_formatter(),
  },
})
