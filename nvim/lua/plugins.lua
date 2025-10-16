return {

    -- nvim-treesitter for syntax highlighting and other features
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- Telescope and its dependencies
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",

    -- NightFox colorscheme
    {
        "EdenEast/nightfox.nvim",
        priority = 1000,  -- Ensure it loads first
    },

    -- nvim-lint
    { 
	"mfussenegger/nvim-lint",
  	config = function()
    		require("config.lint").setup()
  	end,
    },

    -- lualine (status bar)
    {
        'nvim-lualine/lualine.nvim',
        dependencies = { 'nvim-tree/nvim-web-devicons' }
    }
}
