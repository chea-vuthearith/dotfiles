return {
  "mrjones2014/smart-splits.nvim",
  lazy = false,
  opts = { at_edge = "stop" },
  keys = {
    {
      "<C-Left>",
      function()
        require("smart-splits").resize_left()
      end,
      desc = "Resize Left",
    },
    {
      "<C-Down>",
      function()
        require("smart-splits").resize_down()
      end,
      desc = "Resize Down",
    },
    {
      "<C-Up>",
      function()
        require("smart-splits").resize_up()
      end,
      desc = "Resize Up",
    },
    {
      "<C-Right>",
      function()
        require("smart-splits").resize_right()
      end,
      desc = "Resize Right",
    },
    {
      "<C-h>",
      function()
        require("smart-splits").move_cursor_left()
      end,
      desc = "Go to Left Window",
    },
    {
      "<C-j>",
      function()
        require("smart-splits").move_cursor_down()
      end,
      desc = "Go to Lower Window",
    },
    {
      "<C-k>",
      function()
        require("smart-splits").move_cursor_up()
      end,
      desc = "Go to Upper Window",
    },
    {
      "<C-l>",
      function()
        require("smart-splits").move_cursor_right()
      end,
      desc = "Go to Right Window",
    },
    {
      "<C-S-H>",
      function()
        require("smart-splits").swap_buf_left()
      end,
      desc = "Swap Buffer Left",
    },
    {
      "<C-S-J>",
      function()
        require("smart-splits").swap_buf_down()
      end,
      desc = "Swap Buffer Down",
    },
    {
      "<C-S-K>",
      function()
        require("smart-splits").swap_buf_up()
      end,
      desc = "Swap Buffer Up",
    },
    {
      "<C-S-L>",
      function()
        require("smart-splits").swap_buf_right()
      end,
      desc = "Swap Buffer Right",
    },
  },
}
