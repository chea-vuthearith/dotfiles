-- Options that differ from or extend LazyVim defaults
vim.opt.timeoutlen = 50
vim.opt.wildmenu = true
vim.opt.wildmode = { "longest:list", "full" }

vim.g.snacks_animate = false
vim.g.lazyvim_blink_main = true
vim.g.ai_cmp = false
vim.g.lazyvim_picker = "snacks"

vim.opt.foldmethod = "indent"
vim.opt.foldtext = ""
vim.opt.linebreak = true
vim.opt.list = false
vim.opt.smoothscroll = true
vim.opt.diffopt:append("vertical")
vim.opt.mouse = ""
vim.opt.wrap = true
