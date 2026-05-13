vim.pack.add({
  { src = "https://github.com/MeanderingProgrammer/render-markdown.nvim" },
  { src = "https://github.com/iamcco/markdown-preview.nvim" },
})

require("render-markdown").setup({
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
})

vim.fn["mkdp#util#install"]()
