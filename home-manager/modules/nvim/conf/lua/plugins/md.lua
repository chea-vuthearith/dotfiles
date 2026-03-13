return {
  "MeanderingProgrammer/render-markdown.nvim",
  ft = { "markdown" },
  ---@type render.md.UserConfig
  opts = {
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },

    bullet = {
      right_pad = 1,
    },

    checkbox = {
      enabled = true,
    },

    heading = {
      enabled = true,
      sign = true,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },
  },
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.fn["mkdp#util#install"]()
    end,
  },
}
