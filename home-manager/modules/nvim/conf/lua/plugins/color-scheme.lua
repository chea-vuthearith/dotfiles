return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = {
      term_colors = true,
      transparent_background = true,
      float = {
        solid = true,
        transparent = true,
      },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
  { "tokyonight.nvim", enabled = false },
}
