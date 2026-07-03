return {
  "folke/sidekick.nvim",
  opts = {
    nes = { enabled = false },
    cli = {
      mux = {
        backend = "tmux",
        enabled = true,
      },
    },
  },
  keys = {
    { "<leader>a", desc = "+ai" },
    { "<C-.>", function() require("sidekick.cli").focus() end, mode = { "n", "t", "i", "x" }, desc = "Sidekick Focus" },
    { "<leader>aa", function() require("sidekick.cli").toggle({ name = "claude" }) end, desc = "Toggle CLI" },
    { "<leader>as", function() require("sidekick.cli").select() end, desc = "Select CLI" },
    { "<leader>ad", function() require("sidekick.cli").close() end, desc = "Detach CLI Session" },
    { "<leader>at", function() require("sidekick.cli").send({ msg = "{this}", name = "claude" }) end, mode = { "x", "n" }, desc = "Send This" },
    { "<leader>af", function() require("sidekick.cli").send({ msg = "{file}", name = "claude" }) end, desc = "Send File" },
    { "<leader>av", function() require("sidekick.cli").send({ msg = "{selection}", name = "claude" }) end, mode = "x", desc = "Send Visual Selection" },
    { "<leader>ap", function() require("sidekick.cli").prompt({ name = "claude" }) end, mode = { "n", "x" }, desc = "Sidekick Select Prompt" },
  },
}
