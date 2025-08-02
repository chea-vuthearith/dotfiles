return {
  {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      view_options = {
        show_hidden = true,
      },
      default_file_explorer = true,
      win_options = {
        wrap = true,
      },
      keymaps = {
        ["q"] = { "actions.close", mode = "n" },
        ["<Backspace>"] = { "actions.parent", mode = "n" },
        ["<C-s>"] = { "actions.parent", mode = "n" },
      },
    },
    -- Optional dependencies
    dependencies = { { "echasnovski/mini.icons", opts = {} } },
    -- dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
    -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
    lazy = false,
  },
  {
    "neo-tree.nvim",
    enabled = false,
  },
}
