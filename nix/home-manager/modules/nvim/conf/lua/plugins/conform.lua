return {
  "conform.nvim",
  opts = {
    formatters_by_ft = {
      ["javascript"] = { "biome" },
      ["javascriptreact"] = { "biome" },
      ["typescript"] = { "biome" },
      ["typescriptreact"] = { "biome" },
      ["html"] = { "biome" },
      ["css"] = { "biome" },
      ["json"] = { "biome" },
      ["sh"] = { "beautysh" },
    },
    formatters = {
      biome = {
        command = "biome",
        args = {
          "check",
          "--write",
          "$FILENAME",
        },
        stdin = false,
      },
    },
  },
}
