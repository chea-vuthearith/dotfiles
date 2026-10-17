vim.opt.timeoutlen = 50
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:list", "full" }

vim.g.snacks_animate = false
vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = false
vim.g.lazyvim_picker = "snacks"

-- Over SSH, copy to the local clipboard via OSC 52 (herdr forwards it to ghostty).
-- Paste reads nvim's own register: OSC 52 reads make ghostty prompt every time.
-- Paste the local clipboard with the terminal's paste key instead.
if vim.env.SSH_CONNECTION then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste()
    return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
vim.opt.clipboard = "unnamedplus"

vim.opt.foldmethod = "indent"
vim.opt.foldtext = ""
vim.opt.linebreak = true
vim.opt.list = false
vim.opt.diffopt:append("vertical")
vim.opt.mouse = ""
vim.opt.wrap = true
