return {
  "folke/snacks.nvim",
  ---@module "snacks"
  ---@type snacks.Config
  opts = {
    dashboard = { enabled = false },
    animate = { enabled = false },
    explorer = {
      replace_netrw = true,
      trash = true,
    },
    picker = {
      sources = {
        explorer = {
          win = {
            list = {
              keys = {
                ["<C-h>"] = { "<C-w>h", expr = true, mode = { "i", "n" } },
                ["<C-j>"] = { "<C-w>j", expr = true, mode = { "i", "n" } },
                ["<C-k>"] = { "<C-w>k", expr = true, mode = { "i", "n" } },
                ["<C-l>"] = { "<C-w>l", expr = true, mode = { "i", "n" } },
              },
            },
          },
        },
      },
    },
  },
}
