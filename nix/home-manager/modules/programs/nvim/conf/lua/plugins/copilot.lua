return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        keymap = {
          accept = "<S-Tab>",
          next = "<M-]>",
          prev = "<M-[>",
        },
        enabled = true,
        auto_trigger = true,
      },
    },
  },
}
