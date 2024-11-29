
vim.g.mapleader = " " -- space bar leader key 

--buffers 
vim.keymap.set("n","<leader>n",":bn<cr>")
vim.keymap.set("n","<leader>p",":bp<cr>")
vim.keymap.set("n","<leader>x",":bd<cr>")


--nvim comment
vim.keymap.set({"n","v"},"<leader>/",":CommentToggle<cr>")



