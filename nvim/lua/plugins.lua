return {

    -- nvim-treesitter for syntax highlighting and other features
    { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" },

    -- Telescope and its dependencies
    "nvim-lua/plenary.nvim",
    "nvim-telescope/telescope.nvim",

    -- One Dark Pro colorscheme
    {
        "olimorris/onedarkpro.nvim",
        priority = 1000,  -- Ensure it loads first
    },

    -- nvim-lint
    { 
	"mfussenegger/nvim-lint",
  	config = function()
    		require("config.lint").setup()
  	end,
    }
}
