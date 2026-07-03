return {
  "MeanderingProgrammer/render-markdown.nvim",
  opts = {
    completions = { lsp = { enabled = true } },
    code = {
      sign = false,
      width = "block",
      right_pad = 1,
    },
    bullet = { right_pad = 1 },
    checkbox = { enabled = true },
    heading = {
      enabled = true,
      sign = true,
      icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
    },
  },
}
