return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    lazy = false,
    config = true,
    opts = {
      default_mappings = false,
      default_commands = true,
      disable_diagnostics = true,
      list_opener = function()
        require("trouble").open("quickfix")
      end,
      highlights = {
        incoming = "DiffAdd",
        current = "DiffText",
      },
    },
    keys = {
      { "<leader>ga", desc = "Git Conflicts" },
      { "<leader>gao", "<Plug>(git-conflict-ours)", desc = "Accept ours" },
      { "<leader>gat", "<Plug>(git-conflict-theirs)", desc = "Accept theirs" },
      { "<leader>gab", "<Plug>(git-conflict-both)", desc = "Accept both" },
      { "<leader>ga0", "<Plug>(git-conflict-none)", desc = "Accept none" },
      { "[x", "<Plug>(git-conflict-prev-conflict)", desc = "Previous conflict" },
      { "]x", "<Plug>(git-conflict-next-conflict)", desc = "Next conflict" },
      {
        "<leader>gal",
        function()
          vim.cmd("GitConflictListQf")
        end,
        desc = "List conflicts",
      },
    },
  },
}
