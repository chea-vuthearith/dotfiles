return {
  {
    "catppuccin",
    priority = 1000, -- Ensure it loads first
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
