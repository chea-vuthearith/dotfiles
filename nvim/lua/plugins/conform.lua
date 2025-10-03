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
        settings = {
          configuration_path = vim.fn.expand("~/dotfiles/nvim/biome.json"),
        },
        command = "biome",
        args = { "check", "--write", "--linter-enabled=false", "$FILENAME" },
        stdin = false,
        require_cwd = false,
      },
    },
  },
}
