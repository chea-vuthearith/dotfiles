return {
  "mistricky/codesnap.nvim",
  tag = "v1.6.3",
  keys = {
    { "<leader>cs", "<cmd>'<,'>CodeSnap<cr>", mode = "v", desc = "Save selected code snapshot into clipboard" },
    -- { "<leader>cs", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
  },
  lazy = false,
  opts = {
    radius = 0,
    code_font_family = "FiraCode Nerd Font",
    mac_window_bar = false,
    has_line_number = true,
    has_breadcrumbs = true,
    watermark = "",
    bg_padding = 0,
  },
}
