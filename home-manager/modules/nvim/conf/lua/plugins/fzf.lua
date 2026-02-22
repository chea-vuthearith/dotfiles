return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>z", "<cmd>FzfLua zoxide<cr>", desc = "List Zoxide Directories" },
  },
  ---@module "fzf-lua"
  ---@type fzf-lua.Config|{}
  ---@diagnostic disable: missing-fields
  opts = {
    files = {
      cmd = "fd --type f --hidden --follow --exclude .git",
    },
  },
  ---@diagnostic enable: missing-fields
}
