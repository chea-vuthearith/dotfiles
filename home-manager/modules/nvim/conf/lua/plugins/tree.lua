return {
  "nvim-neo-tree/neo-tree.nvim",
  ---@module 'neo-tree'
  ---@type neotree.Config
  opts = {
    close_if_last_window = true,
    popup_border_style = "rounded",
    filesystem = {
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_ignored = true,
        never_show = {
          "node_modules",
          ".DS_Store",
          "__pycache__",
        },
      },
    },
  },
}
