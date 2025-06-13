return {
  {
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
      suggestion = {
        keymap = {
          accept = "<S-Enter>",
          next = "<M-]>",
          prev = "<M-[>",
        },
        enabled = true,
        auto_trigger = true,
      },
    },
  },
}
