vim.pack.add({
  { src = "https://github.com/folke/noice.nvim" },
  "https://github.com/MunifTanjim/nui.nvim",
  "https://github.com/rcarriga/nvim-notify",
})

require("noice").setup({
  cmdline = {
    view = "cmdline",
  },
  presets = {
    command_palette = false,
  },
})
