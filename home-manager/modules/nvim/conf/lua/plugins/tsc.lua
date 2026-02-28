local keys = {
  {
    "<leader>ct",
    function()
      require("tsc").run()
    end,
    desc = "Run TSC",
  },
}
return {
  {
    "dmmulroy/tsc.nvim",
    cmd = "TSC",
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
          keys = keys,
        },
        tsgo = {
          keys = keys,
        },
      },
    },
  },
}
