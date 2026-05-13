vim.pack.add({
  { src = "https://github.com/folke/sidekick.nvim" },
})

require("sidekick").setup({
  nes = {
    enabled = false,
  },
  cli = {
    mux = {
      backend = "tmux",
      enabled = true,
    },
  },
})

vim.keymap.set("n", "<leader>aa", function()
  require("sidekick.cli").toggle({ name = "opencode" })
end, { desc = "Toggle Sidekick" })
