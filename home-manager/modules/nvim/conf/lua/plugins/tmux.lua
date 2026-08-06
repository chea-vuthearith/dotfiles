local function navigate(direction)
  local ss = require("smart-splits")
  local win_before = vim.fn.winnr()
  if direction == "left" then ss.move_cursor_left()
  elseif direction == "down" then ss.move_cursor_down()
  elseif direction == "up" then ss.move_cursor_up()
  elseif direction == "right" then ss.move_cursor_right()
  end
  if vim.fn.winnr() == win_before and vim.env.HERDR_SOCKET then
    vim.fn.jobstart({ "herdr", "pane", "focus_direction", "--direction", direction, "--current" })
  end
end

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
      function() navigate("left") end,
      desc = "Go to Left Window",
    },
    {
      "<C-j>",
      function() navigate("down") end,
      desc = "Go to Lower Window",
    },
    {
      "<C-k>",
      function() navigate("up") end,
      desc = "Go to Upper Window",
    },
    {
      "<C-l>",
      function() navigate("right") end,
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
