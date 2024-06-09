local whichkey = require("which-key")

vim.o.timeout = true
vim.o.timeoutlen = 300

whichkey.register()

whichkey.setup {}
