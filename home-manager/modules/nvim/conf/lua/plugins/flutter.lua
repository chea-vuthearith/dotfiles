vim.pack.add({
  { src = "https://github.com/nvim-flutter/flutter-tools.nvim" },
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/stevearc/dressing.nvim",
})

require("flutter-tools").setup({})
