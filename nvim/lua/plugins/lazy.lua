-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
			{ out,                            "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({

	{
		"catppuccin/nvim", name = "catppuccin", priority = 1000
	},
	--init.lua:
	{
		'nvim-telescope/telescope.nvim',
		tag = '0.1.8',
		dependencies = { 'nvim-lua/plenary.nvim' }
	},
	--Auto Pairs
	{
		'windwp/nvim-autopairs',
		event = "InsertEnter",
		config = true
		-- use opts = {} for passing setup options
		-- this is equivalent to setup({}) function
	},
	--File Tree
	{
		"nvim-tree/nvim-tree.lua",
		version = "*",
		lazy = false,
		dependencies = {
			"nvim-tree/nvim-web-devicons",
		},
		config = function()
			require("nvim-tree").setup {}
		end,
	},
	--buffer bar
	{
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons'
	},

	-- comment
	{
		"terrortylor/nvim-comment",
		config = function()
			require('nvim_comment').setup({ create_mappings = false })
		end,
	},
	-- fancier lualine
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 'nvim-tree/nvim-web-devicons' }

	},
	--gitsigns
	{
		'lewis6991/gitsigns.nvim',
		config = function()
			require('gitsigns').setup()
		end,
	}
	,

	-- Dashboard plugin
	{
		'nvimdev/dashboard-nvim',
		event = 'VimEnter',
		config = function()
			require('dashboard').setup {
				-- config
			}
		end,
		dependencies = { { 'nvim-tree/nvim-web-devicons' } }
	},
	--autosave
	{
		"Pocco81/auto-save.nvim",
		config = function()
			require("auto-save").setup({
				enabled = true, -- Start in auto-save mode
				execution_message = {
					message = function()
						return "File saved at " .. vim.fn.strftime("%H:%M:%S")
					end,
				},
				trigger_events = { "InsertLeave", "TextChanged" }, -- Automatically save on these events
				debounce_delay = 135,  -- Delay in ms before saving
			})
		end,
	},
	-- AutoSession
	{
		'rmagatti/auto-session',
		lazy = false,

		---enables autocomplete for opts
		---@module "auto-session"
		---@type AutoSession.Config
		opts = {
			suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
			-- log_level = 'debug',
		}
	},

	-- dap	
	{
		"mfussenegger/nvim-dap",
		dependencies = {
			"rcarriga/nvim-dap-ui", -- UI for DAP
			"theHamsta/nvim-dap-virtual-text", -- Virtual text support
			"mfussenegger/nvim-dap-python", -- Python adapter
			"nvim-neotest/nvim-nio" -- Dependency for nvim-dap-ui
		}
	},

	-- language setup
	{
		{
			'VonHeikemen/lsp-zero.nvim',
			branch = 'v3.x',
			lazy = true,
			config = false,
			init = function()
				-- Disable automatic setup, we are doing it manually
				vim.g.lsp_zero_extend_cmp = 0
				vim.g.lsp_zero_extend_lspconfig = 0
			end,
		},
		{
			'williamboman/mason.nvim',
			lazy = false,
			config = true,
		},

		-- Autocompletion
		{
			'hrsh7th/nvim-cmp',
			event = 'InsertEnter',
			dependencies = {
				{ 'L3MON4D3/LuaSnip' },
			},
			config = function()
				-- Here is where you configure the autocompletion settings.
				local lsp_zero = require('lsp-zero')
				lsp_zero.extend_cmp()

				-- And you can configure cmp even more, if you want to.
				local cmp = require('cmp')
				local cmp_action = lsp_zero.cmp_action()

				cmp.setup({
					formatting = lsp_zero.cmp_format({ details = true }),
					mapping = cmp.mapping.preset.insert({
						['<C-Space>'] = cmp.mapping.complete(),
						['<C-u>'] = cmp.mapping.scroll_docs(-4),
						['<C-d>'] = cmp.mapping.scroll_docs(4),
						['<C-f>'] = cmp_action.luasnip_jump_forward(),
						['<C-b>'] = cmp_action.luasnip_jump_backward(),
						['<CR>'] = cmp.mapping.confirm({ select = true }),
					}),
					snippet = {
						expand = function(args)
							require('luasnip').lsp_expand(args.body)
						end,
					},
				})
			end
		},

		-- LSP
		{
			'neovim/nvim-lspconfig',
			cmd = { 'LspInfo', 'LspInstall', 'LspStart' },
			event = { 'BufReadPre', 'BufNewFile' },
			dependencies = {
				{ 'hrsh7th/cmp-nvim-lsp' },
				{ 'williamboman/mason-lspconfig.nvim' },
			},
			config = function()
				-- This is where all the LSP shenanigans will live
				local lsp_zero = require('lsp-zero')
				lsp_zero.extend_lspconfig()

				-- if you want to know more about mason.nvim
				-- read this: https://github.com/VonHeikemen/lsp-zero.nvim/blob/v3.x/doc/md/guides/integrate-with-mason-nvim.md
				lsp_zero.on_attach(function(client, bufnr)
					-- see :help lsp-zero-keybindings
					-- to learn the available actions
					lsp_zero.default_keymaps({ buffer = bufnr })
				end)

				require('mason-lspconfig').setup({
					ensure_installed = {},
					handlers = {
						-- this first function is the "default handler"
						-- it applies to every language server without a "custom handler"
						function(server_name)
							require('lspconfig')[server_name].setup({})
						end,

						-- this is the "custom handler" for `lua_ls`
						lua_ls = function()
							-- (Optional) Configure lua language server for neovim
							local lua_opts = lsp_zero.nvim_lua_ls()
							require('lspconfig').lua_ls.setup(lua_opts)
						end,
					}
				})
			end
		}
	}

})
