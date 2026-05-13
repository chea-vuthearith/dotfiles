vim.pack.add({
  { src = "https://github.com/stevearc/conform.nvim" },
})

require("conform").setup({
  formatters_by_ft = {
    javascript = { "biome" },
    javascriptreact = { "biome" },
    typescript = { "biome" },
    typescriptreact = { "biome" },
    html = { "biome" },
    css = { "biome" },
    json = { "biome" },
    sh = { "beautysh" },
    nix = { "alejandra" },
    kdl = { "kdlfmt" },
  },
  formatters = {
    biome = {
      command = "biome",
      args = { "check", "--write", "$FILENAME" },
      stdin = false,
    },
  },
})
