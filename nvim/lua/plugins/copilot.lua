return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        keymap = {
          accept = "<tab>",
          next = "<M-]>",
          prev = "<M-[>",
        },
        enabled = true,
        auto_trigger = true,
      },
    },
  },
  { "zbirenbaum/copilot-cmp", enabled = false },
}
