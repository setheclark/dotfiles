return {
	{
		"catppuccin/nvim",
		lazy = false,
		opts = {},
	},
	{
		"lazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin-frappe",
		},
	},
	{
		"folke/snacks.nvim",
		opts = {
			picker = {
				hidden = true,
				sources = {
					files = {
						hidden = true,
					},
				},
			},
		},
	},
	-- {
	--   "nvim-neo-tree/neo-tree.nvim",
	--   opts = {
	--     filesystem = {
	--     filtered_items = {
	--       visible = true,
	--       show_hidden_count = true,
	--       hide_dotfiles = false,
	--       hide_gitignored = true,
	--       hide_by_name = {
	--         -- '.git',
	--         -- '.DS_Store',
	--         -- 'thumbs.db',
	--     },
	--     never_show = {},
	--         },
	--       }
	--     },
	--     keys = {
	--       {
	--         "<C-n>",
	--         "<cmd>Neotree filesystem reveal left<CR>",
	--         desc = "Project view"
	--       }
	--     }
	-- },
}

