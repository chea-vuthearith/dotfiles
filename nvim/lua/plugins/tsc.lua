return {
  "dmmulroy/tsc.nvim",
  ft = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  keys = {
    { "<leader>ct", "<cmd>TSC<cr>", desc = "Run TSC" },
  },
  opts = {
    use_diagnostics = true,
    use_trouble_qflist = true,
  },
}
