return {
  -- download pretty-ts-errors-md binary
  {
    name = "pretty-ts-errors-installer",
    dir = vim.fn.stdpath("config"),
    build = function()
      local data_dir = vim.fn.stdpath("data") .. "/pretty-ts-errors"
      vim.fn.mkdir(data_dir, "p")

      local install_cmd =
        string.format("cd %s && npm install --no-save pretty-ts-errors-markdown@latest", vim.fn.shellescape(data_dir))

      vim.fn.system(install_cmd)
    end,
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = { "pretty-ts-errors-installer" },
    opts = {
      inlay_hints = { enabled = false },
      -- prettify ts errors
      diagnostics = {
        float = {
          format = (function()
            local cache = {}
            local cache_order = {}
            local bin_path = vim.fn.stdpath("data") .. "/pretty-ts-errors/node_modules/.bin/pretty-ts-errors-markdown"

            return function(diagnostic)
              -- Only format TypeScript errors
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
                  -- remove md links
                  result = result:gsub("%[([^%]]+)%]%(([^%)]+)%)", "%1")
                  -- remove codeblock markers
                  result = result:gsub("```%w*\n", ""):gsub("\n```", "")

                  -- cache result, so that focusing diagnostics doesnt run format again
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
          end)(),
        },
      },
      servers = {
        vtsls = { settings = { typescript = { preferences = { importModuleSpecifier = "non-relative" } } } },
        biome = {},
      },
    },
  },
}
