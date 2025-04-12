return {
  "mistricky/codesnap.nvim",
  build = "make",
  keys = {
    { "<leader>cs", "<cmd>CodeSnap<cr>", mode = "x", desc = "Save selected code snapshot into clipboard" },
    -- { "<leader>cs", "<cmd>CodeSnapSave<cr>", mode = "x", desc = "Save selected code snapshot in ~/Pictures" },
  },
  lazy = false,
  opts = {
    mac_window_bar = false,
    has_line_number = true,
    has_breadcrumbs = true,
    watermark = "",
    bg_theme = "default",
  },
}
