return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      javascript = { "biome" },
      javascriptreact = { "biome" },
      typescript = { "biome" },
      typescriptreact = { "biome" },
      html = { "biome" },
      css = { "biome" },
      json = { "biome" },
      sh = { "shfmt" },
      nix = { "alejandra" },
      markdown = { "prettierd", "injected" },
      kdl = { "kdlfmt" },
      lua = { "stylua" },
      python = { "ruff_format", "ruff_fix", "ruff_organize_imports" },
    },
    formatters = {
      biome = {
        command = "biome",
        args = { "check", "--write", "$FILENAME" },
        stdin = false,
      },
      ruff_format = {
        exit_codes = { 0, 1 },
      },
    },
  },
}
