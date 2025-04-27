-- Load the plugin manager (lazy.nvim)
require('lazy')

-- Load the plugins setup from plugins.lua
require('plugins')

-- Load the individual plugin configurations
require('config.treesitter')
require('config.telescope')
