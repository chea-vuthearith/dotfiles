return {
  {
    "dmmulroy/tsc.nvim",
    ft = { "typescript", "typescriptreact" },
    lazy = true,
    opts = {
      use_diagnostics = true,
      use_trouble_qflist = true,
    },
  },
  {
    "nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          keys = {
            { "<leader>ct", ":TSC<cr>", desc = "Run TSC" },
          },
        },
      },
    },
  },
}
