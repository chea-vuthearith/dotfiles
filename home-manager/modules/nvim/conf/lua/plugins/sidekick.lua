return {
  "folke/sidekick.nvim",
  keys = {
    {
      "<leader>aa",
      function()
        require("sidekick.cli").toggle({ name = "opencode" })
      end,
      desc = "Toggle Sidekick",
    },
  },
  opts = {
    nes = {
      enabled = false,
    },
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
    },
  },
}
