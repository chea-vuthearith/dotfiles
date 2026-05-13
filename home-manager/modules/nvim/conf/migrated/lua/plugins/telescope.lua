vim.pack.add({
  { src = "https://github.com/nvim-telescope/telescope.nvim" },
  "https://github.com/nvim-lua/plenary.nvim",
})

require("telescope").setup({})

vim.keymap.set("n", "<leader><leader>", function()
  require("telescope.builtin").find_files()
end, { desc = "Find Files" })
