return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<leader>h", desc = "Harpoon" },
    {
      "<leader>hl",
      function()
        require("harpoon").ui:toggle_quick_menu(require("harpoon"):list())
      end,
      desc = "Open harpoon window",
    },
    {
      "<leader>ha",
      function()
        require("harpoon"):list():add()
      end,
      desc = "Add file to harpoon",
    },
    {
      "<leader>1",
      function()
        require("harpoon"):list():select(1)
      end,
      desc = "Select first harpoon file",
    },
    {
      "<leader>2",
      function()
        require("harpoon"):list():select(2)
      end,
      desc = "Select second harpoon file",
    },
    {
      "<leader>3",
      function()
        require("harpoon"):list():select(3)
      end,
      desc = "Select third harpoon file",
    },
    {
      "<leader>4",
      function()
        require("harpoon"):list():select(4)
      end,
      desc = "Select fourth harpoon file",
    },
    {
      "<C-p>",
      function()
        require("harpoon"):list():prev()
      end,
      desc = "Go to previous harpoon buffer",
    },
    {
      "<C-n>",
      function()
        require("harpoon"):list():next()
      end,
      desc = "Go to next harpoon buffer",
    },
  },
}
