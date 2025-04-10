return {
  "conform.nvim",
  opts = {
    formatters_by_ft = {
      ["javascript"] = { "biome" },
      ["javascriptreact"] = { "biome" },
      ["typescript"] = { "biome" },
      ["typescriptreact"] = { "biome" },
      ["html"] = { "biome" },
      ["css"] = { "biome" },
      ["json"] = { "biome" },
      ["sh"] = { "beautysh" },
    },
    formatters = {
      biome = {
        command = "biome",
        args = { "check", "--config-path", vim.env.BIOME_CONFIG_PATH, "--write", "$FILENAME" },
        stdin = false,
        require_cwd = false,
      },
    },
  },
}
