return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      list = {
        selection = {
          preselect = function(ctx)
            return not require("blink.cmp").snippet_active({ direction = 1 })
          end,
        },
      },
      ghost_text = { enabled = false },
      accept = {
        auto_brackets = { enabled = false },
      },
    },

    keymap = {
      preset = "super-tab",
      ["<Tab>"] = {
        require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1],
        require("lazyvim.util.cmp").map({ "snippet_forward", "ai_accept" }),
        "fallback",
      },
      ["S-Tab"] = {},
      ["<C-space>"] = {
        ---@param cmp blink.cmp.API
        function(cmp)
          if cmp.is_visible() then
            return cmp.hide()
          else
            return cmp.show()
          end
        end,
      },
    },
  },
}
