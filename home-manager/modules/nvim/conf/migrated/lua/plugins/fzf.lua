vim.pack.add({
  { src = "https://github.com/ibhagwan/fzf-lua" },
})

require("fzf-lua").setup({
  defaults = {
    profile = "fzf-tmux",
  },
  files = {
    cmd = "fd --type f --hidden --follow --exclude .git",
  },
})

vim.keymap.set("n", "<leader>z", "<cmd>FzfLua zoxide<cr>", { desc = "List Zoxide Directories" })
