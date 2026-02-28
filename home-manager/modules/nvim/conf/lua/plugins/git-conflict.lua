return {
  "akinsho/git-conflict.nvim",
  version = "*",
  keys = {
    { "<leader>ga", "", desc = "Accept" },
    { "<leader>gal", ":GitConflictListQf<CR>", desc = "List Conflicts" },
    { "<leader>gao", "<Plug>(git-conflict-ours)", desc = "Accept Ours" },
    { "<leader>gat", "<Plug>(git-conflict-theirs)", desc = "Accept Theirs" },
    { "<leader>gab", "<Plug>(git-conflict-both)", desc = "Accept Both" },
    { "<leader>ga0", "<Plug>(git-conflict-none)", desc = "Accept None" },
    { "[x", "<Plug>(git-conflict-prev-conflict)", desc = "Prev Conflict" },
    { "]x", "<Plug>(git-conflict-next-conflict)", desc = "Next Conflict" },
  },
  config = true,
  opts = {
    default_mappings = false,
    list_opener = function()
      require("trouble").open("qflist")
    end,
  },
}
