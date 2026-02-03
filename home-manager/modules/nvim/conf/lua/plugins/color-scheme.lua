return {
  {
    "catppuccin",
    opts = {
      term_colors = true,
      transparent_background = true,
      float = {
        transparent = true,
      },
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
  {
    "folke/noice.nvim",
    config = {
      cmdline = {
        view = "cmdline",
      },
      presets = {
        command_palette = false, -- position the cmdline and popupmenu together
      },
    },
  },
}
