vim.pack.add({
  { src = "https://github.com/ThePrimeagen/harpoon", version = "harpoon2" },
  "https://github.com/nvim-lua/plenary.nvim",
})

vim.keymap.set("n", "<leader>hl", function()
  require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
end, { desc = "Open harpoon window" })

vim.keymap.set("n", "<leader>ha", function()
  require("harpoon"):list():add()
end, { desc = "Add file to harpoon" })

vim.keymap.set("n", "<leader>1", function()
  require("harpoon"):list():select(1)
end, { desc = "Select first harpoon file" })

vim.keymap.set("n", "<leader>2", function()
  require("harpoon"):list():select(2)
end, { desc = "Select second harpoon file" })

vim.keymap.set("n", "<leader>3", function()
  require("harpoon"):list():select(3)
end, { desc = "Select third harpoon file" })

vim.keymap.set("n", "<leader>4", function()
  require("harpoon"):list():select(4)
end, { desc = "Select fourth harpoon file" })

vim.keymap.set("n", "<C-p>", function()
  require("harpoon"):list():prev()
end, { desc = "Go to previous harpoon buffer" })

vim.keymap.set("n", "<C-n>", function()
  require("harpoon"):list():next()
end, { desc = "Go to next harpoon buffer" })
