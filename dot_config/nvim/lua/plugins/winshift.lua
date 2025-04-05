return {
  "sindrets/winshift.nvim",
  config = function()
    require("winshift").setup({
      keymaps = {
        disable_defaults = true, -- Disable the default keymaps
      },
    })
  end,
}
