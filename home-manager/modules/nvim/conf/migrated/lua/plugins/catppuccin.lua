vim.pack.add({
  { src = "https://github.com/catppuccin/nvim", name = "catppuccin" },
})

require("catppuccin").setup({
  term_colors = true,
  transparent_background = true,
  float = {
    solid = true,
    transparent = true,
  },
})

vim.cmd.colorscheme("catppuccin-nvim")
