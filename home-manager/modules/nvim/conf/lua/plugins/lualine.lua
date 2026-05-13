vim.pack.add({
  { src = "https://github.com/nvim-lualine/lualine.nvim" },
})

require("lualine").setup({
  sections = {
    lualine_b = { "branch" },
    lualine_y = { "progress" },
    lualine_z = { "location" },
  },
})
