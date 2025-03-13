-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

--open terminal in root
vim.api.nvim_set_keymap(
  "n",
  "<leader>wt",
  [[:lua vim.fn.system('wezterm cli spawn --cwd ' .. LazyVim.root()) <CR>]],
  { noremap = true, silent = true, desc = "New terminal tab (Root Dir)" }
)

vim.api.nvim_set_keymap(
  "n",
  "H",
  ":!wezterm cli activate-tab --tab-relative -1 <CR>",
  { noremap = true, silent = true, desc = "Window Left" }
)

vim.api.nvim_set_keymap(
  "n",
  "L",
  ":!wezterm cli activate-tab --tab-relative 1 <CR>",
  { noremap = true, silent = true, desc = "Window Right" }
)

local function px_to_rem()
  -- Get visual selection
  local _, start_col, _, end_col = unpack(vim.fn.getpos("'<"))
  local text = vim.fn.getreg('"') -- Use default unnamed register
  local new_text = text:gsub("(%d+)px", function(px)
    return string.format("%.2frem", px / 16)
  end)

  -- Replace selection with converted text
  vim.api.nvim_input("<Esc>") -- Exit visual mode
  vim.fn.setreg('"', new_text)
  vim.cmd('normal! gv"_c"') -- Replace selection with converted value
end

vim.keymap.set("v", "<leader>pr", px_to_rem, { desc = "Convert px to rem in visual mode" })

local function toggle_case_visual()
  -- Get visual selection
  local _, start_col, _, end_col = unpack(vim.fn.getpos("'<"))
  local text = vim.fn.getreg('"') -- Use default unnamed register

  local new_text
  if text:find("_") then
    -- Convert snake_case to camelCase
    new_text = text:gsub("_(%l)", function(c)
      return c:upper()
    end)
  else
    -- Convert camelCase to snake_case
    new_text = text:gsub("([a-z])([A-Z])", "%1_%2"):lower()
  end

  -- Replace selection with converted text
  vim.api.nvim_input("<Esc>") -- Exit visual mode
  vim.fn.setreg('"', new_text)
  vim.cmd('normal! gv"_c"') -- Replace selection with converted value
end

vim.keymap.set("v", "<leader>tc", toggle_case_visual, { desc = "Toggle Snake ⇄ Camel Case in visual mode" })
