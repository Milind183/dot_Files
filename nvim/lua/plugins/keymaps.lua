-- Telescope
vim.keymap.set("n", "<leader>fs", ":Telescope find_files<cr>")
vim.keymap.set("n", "<leader>fp", ":Telescope git_files<cr>")
vim.keymap.set("n", "<leader>fz", ":Telescope live_grep<cr>")
vim.keymap.set("n", "<leader>fo", ":Telescope oldfiles<cr>")

--Tree
vim.keymap.set("n", "<leader>e", ":NvimTreeFindFileToggle<cr>")

--formatting
vim.keymap.set("n", "<leader>fmd", vim.lsp.buf.format)

-- Debug adapter

local dap = require("dap")
local dapui = require("dapui")

-- Core DAP Shortcuts
vim.keymap.set("n", "<F5>", dap.continue, { desc = "Start/Continue debugging" })
vim.keymap.set("n", "<F10>", dap.step_over, { desc = "Step over" })
vim.keymap.set("n", "<F11>", dap.step_into, { desc = "Step into" })
vim.keymap.set("n", "<F12>", dap.step_out, { desc = "Step out" })
vim.keymap.set("n", "<Leader>db", dap.toggle_breakpoint, { desc = "Toggle breakpoint" })

-- DAP UI Shortcuts
vim.keymap.set("n", "<Leader>du", dapui.toggle, { desc = "Toggle DAP UI" })
vim.keymap.set("n", "<Leader>dr", function()
	dap.repl.open()
end, { desc = "Open REPL" })

--copy paste
vim.keymap.set('n', 'y', '"+y') -- copy to system clipboard
vim.keymap.set('n', 'P', '"+p') -- paste from system clipboard

--autosave
vim.keymap.set("n", "<Leader>as", ":ASToggle<CR>", { noremap = true, silent = true, desc = "Toggle Auto-Save" })
