return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
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
  },
}
