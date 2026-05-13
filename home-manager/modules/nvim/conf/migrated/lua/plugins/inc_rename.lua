vim.pack.add({
  { src = "https://github.com/smjonas/inc-rename.nvim" },
})

require("inc_rename").setup({})

vim.keymap.set("n", "<leader>rn", function()
  return ":IncRename " .. vim.fn.expand("<cword>")
end, { expr = true, desc = "Incremental Rename" })
