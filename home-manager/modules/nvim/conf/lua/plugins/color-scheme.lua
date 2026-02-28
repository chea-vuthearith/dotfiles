return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    lazy = false,
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
