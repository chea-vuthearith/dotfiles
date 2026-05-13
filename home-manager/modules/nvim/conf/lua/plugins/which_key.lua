vim.pack.add({
  { src = "https://github.com/folke/which-key.nvim" },
})

require("which-key").setup({})

vim.keymap.set("n", "<leader>?", function()
  require("which-key").show()
end, { desc = "which-key" })
