return {
  "nvim-lualine/lualine.nvim",
  opts = function()
    local palette = require("catppuccin.palettes").get_palette()
    return {
      sections = {
        lualine_b = { "branch" },
        lualine_x = {
          {
            function()
              local recording = vim.fn.reg_recording()
              if recording == "" then
                return ""
              end
              return "Recording @" .. recording
            end,
            color = { fg = palette.peach, gui = "bold" },
          },
        },
        lualine_y = { "progress" },
        lualine_z = { "location" },
      },
    }
  end,
}
