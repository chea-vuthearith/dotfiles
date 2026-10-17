return {
  "folke/snacks.nvim",
  opts = {
    dashboard = { enabled = false },
    animate = { enabled = false },
    bigfile = { enabled = false },
    image = { enabled = true },
    notifier = { enabled = true },
    quickfile = { enabled = true },
    words = { enabled = true },
    indent = { enabled = true },
    statuscolumn = { enabled = true },
    scope = { enabled = true },
    picker = {
      enabled = true,
      actions = {
        trouble_open = function(...)
          return require("trouble.sources.snacks").actions.trouble_open(...)
        end,
      },
      sources = {
        files = { hidden = true, follow = true },
      },
      win = {
        input = {
          keys = {
            ["<esc>"] = { "close", mode = { "n", "i" } },
            ["<c-u>"] = { "preview_scroll_up", mode = { "i", "n" } },
            ["<c-d>"] = { "preview_scroll_down", mode = { "i", "n" } },
            ["<a-i>"] = { "toggle_ignored", mode = { "n", "i" } },
            ["<a-.>"] = { "toggle_hidden", mode = { "n", "i" } },
            ["<a-f>"] = { "toggle_follow", mode = { "n", "i" } },
            ["<c-t>"] = { "trouble_open", mode = { "n", "i" } },
          },
        },
      },
    },
  },
  keys = {
    { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
    { "<leader>bD", "<cmd>:bd<cr>", desc = "Delete Buffer and Window" },
    { "<leader>gL", function() Snacks.picker.git_log() end, desc = "Git Log (cwd)" },
    { "<leader>gp", function() Snacks.picker.gh_pr() end, desc = "Github PRs" },
    { "<leader>gb", function() Snacks.picker.git_log_line() end, desc = "Git Blame Line" },
    { "<leader>gf", function() Snacks.picker.git_log_file() end, desc = "Git Current File History" },
    { "<leader>gB", function() Snacks.gitbrowse() end, mode = { "n", "x" }, desc = "Git Browse (open)" },
    { "<leader>gY", function() Snacks.gitbrowse({ open = function(url) vim.fn.setreg("+", url) end, notify = false }) end, mode = { "n", "x" }, desc = "Git Browse (copy)" },
    { "<C-_>", function() Snacks.terminal.focus(nil, { cwd = vim.fn.getcwd() }) end, mode = { "n", "t" }, desc = "Terminal (Root Dir)" },
    { "<leader>z", function() Snacks.picker.zoxide() end, desc = "Zoxide" },
    { "<leader>p", function() Snacks.picker.cliphist() end, desc = "Clip history" },
    { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff" },
    { "<leader><leader>", function() Snacks.picker.files() end, desc = "Find Files" },
    { "<leader>sk", function() Snacks.picker.keymaps() end, desc = "Key Maps" },
    { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep Project" },
    { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
  },
  config = function(_, opts)
    local snacks = require("snacks")
    snacks.setup(opts)

    snacks.toggle.option("spell", { name = "Spelling" }):map("<leader>us")
    snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
    snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
    snacks.toggle.diagnostics():map("<leader>ud")
    snacks.toggle.line_number():map("<leader>ul")
    snacks.toggle.option("conceallevel", { off = 0, on = vim.o.conceallevel > 0 and vim.o.conceallevel or 2, name = "Conceal Level" }):map("<leader>uc")
    snacks.toggle.option("showtabline", { off = 0, on = vim.o.showtabline > 0 and vim.o.showtabline or 2, name = "Tabline" }):map("<leader>uA")
    snacks.toggle.treesitter():map("<leader>uT")
    snacks.toggle.option("background", { off = "light", on = "dark", name = "Dark Background" }):map("<leader>ub")
    snacks.toggle.dim():map("<leader>uD")
    snacks.toggle.animate():map("<leader>ua")
    snacks.toggle.indent():map("<leader>ug")
    snacks.toggle.scroll():map("<leader>uS")
    snacks.toggle.profiler():map("<leader>dpp")
    snacks.toggle.profiler_highlights():map("<leader>dph")
  end,
}
