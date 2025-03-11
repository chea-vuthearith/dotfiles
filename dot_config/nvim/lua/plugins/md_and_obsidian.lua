return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ---@type render.md.UserConfig
    opts = {
      code = {
        sign = false,
        width = "block",
        right_pad = 1,
      },

      bullet = {
        right_pad = 1,
      },

      checkbox = {
        enabled = true,

        -- for obsidian
        custom = {
          todo = { raw = "[ ]", rendered = "󰄱", highlight = "ObsidianTodo", scope_highlight = nil },
          done = { raw = "[x]", rendered = "", highlight = "ObsidianDone", scope_highlight = nil },
          in_progress = { raw = "[>]", rendered = "", highlight = "ObsidianRightArrow", scope_highlight = nil },
          cancelled = { raw = "[~]", rendered = "󰰱", highlight = "ObsidianTilde", scope_highlight = nil },
          important = { raw = "[!]", rendered = "", highlight = "ObsidianImportant", scope_highlight = nil },
        },
      },

      heading = {
        enabled = true,
        sign = true,
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
      },
    },
  },

  {
    "epwalsh/obsidian.nvim",
    version = "*", -- recommended, use latest release instead of latest commit
    lazy = true,
    ft = "markdown",
    dependencies = {
      -- Required.
      "nvim-lua/plenary.nvim",
    },
    opts = {
      workspaces = {
        {
          name = "personal",
          path = "~/vaults/personal",
        },
        {
          name = "study",
          path = "~/vaults/study",
        },
        {
          name = "work",
          path = "~/vaults/work",
        },
      },
    },
  },
}
