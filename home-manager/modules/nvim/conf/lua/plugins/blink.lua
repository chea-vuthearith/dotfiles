return {
  "saghen/blink.cmp",
  opts = {
    completion = {
      menu = {
        border = "rounded",
        draw = {
          treesitter = { "lsp" },
          columns = {
            { "kind_icon", gap = 1 },
            { "label", "label_description", gap = 1 },
            { "source_name" },
          },
        },
      },
      documentation = {
        auto_show = true,
        auto_show_delay_ms = 100,
        window = { border = "rounded" },
      },
      list = {
        selection = {
          preselect = function(ctx)
            return not require("blink.cmp").snippet_active({ direction = 1 })
          end,
        },
      },
      ghost_text = { enabled = false },
      accept = { auto_brackets = { enabled = false } },
    },
    signature = {
      enabled = true,
      window = { border = "rounded" },
    },
    keymap = {
      preset = "super-tab",
      ["<Tab>"] = {
        function(cmp)
          return require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"][1](cmp)
        end,
        "fallback",
      },
      ["<S-Tab>"] = {},
      ["<C-space>"] = {
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
