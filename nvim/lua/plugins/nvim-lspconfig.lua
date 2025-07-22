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
        cmd = { "biome", "lsp-proxy", "--config-path", vim.env.BIOME_CONFIG_PATH },
        root_dir = vim.fn.getcwd(),
      },
    },
  },
}
