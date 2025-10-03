return {
  "neovim/nvim-lspconfig",

  opts = {
    inlay_hints = { enabled = false },
    servers = {
      vtsls = {
        settings = {
          typescript = {
            preferences = {
              importModuleSpecifier = "non-relative",
            },
          },
        },
      },
      biome = {
        settings = {
          configuration_path = vim.fn.expand("~/dotfiles/nvim/biome.json"),
        },
      },
    },
  },
}
