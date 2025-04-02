return {
  "nvim-neo-tree/neo-tree.nvim",
  ---@module "neo-tree"
  ---@type neotree.Config?
  opts = {
    window = {
      position = "top",
      mappings = {
        ["P"] = { "toggle_preview", config = { use_float = false, use_image_nvim = true } },
      },
    },
  },
}
