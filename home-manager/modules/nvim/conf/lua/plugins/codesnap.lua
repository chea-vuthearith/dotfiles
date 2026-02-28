return {
  "mistricky/codesnap.nvim",
  tag = "v1.6.3",
  build = "make",
  keys = {
    {
      "<leader>cs",
      ":CodeSnap<cr>",
      mode = "x",
      desc = "Save selected code snapshot into clipboard",
    },
    {
      "<leader>ch",
      ":CodeSnapHighlight<cr>",
      mode = "x",
      desc = "Highlight selected code snapshot and save into clipboard",
    },
  },
  opts = {
    radius = 0,
    editor_font_family = "FiraCode Nerd Font",
    mac_window_bar = false,
    has_line_number = true,
    has_breadcrumbs = true,
    watermark = "",
    bg_padding = 0,
  },
}
