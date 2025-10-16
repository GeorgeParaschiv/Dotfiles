return {
  "karb94/neoscroll.nvim",
  keys = {
    "<C-u>", "<C-d>", "<C-b>", "<C-f>", "zt", "zz", "zb",
    "<ScrollWheelUp>", "<ScrollWheelDown>",
  },
  config = function()
    local ok, neoscroll = pcall(require, "neoscroll")
    if not ok then return end

    -- Use new options; disable default mappings (we define our own)
    neoscroll.setup({
      mappings = {},
      easing = "quadratic",
      performance_mode = true,
      respect_scrolloff = true,
      hide_cursor = false,
      stop_eof = true,
    })

    -- Helper to map in normal/visual/select
    local modes = { "n", "v", "x" }
    local map = function(lhs, rhs, desc)
      vim.keymap.set(modes, lhs, rhs, { silent = true, desc = desc })
    end

    -- Mouse wheel (cursor follows view: move_cursor = true)
    map("<ScrollWheelUp>",   function() neoscroll.scroll(-0.10, { move_cursor = true,  duration = 60  }) end, "neoscroll wheel up")
    map("<ScrollWheelDown>", function() neoscroll.scroll( 0.10, { move_cursor = true,  duration = 60  }) end, "neoscroll wheel down")

    -- Keyboard equivalents (cursor moves by design in these helpers)
    map("<C-u>", function() neoscroll.ctrl_u({ duration = 250 }) end, "neoscroll <C-u>")
    map("<C-d>", function() neoscroll.ctrl_d({ duration = 250 }) end, "neoscroll <C-d>")
    map("<C-b>", function() neoscroll.ctrl_b({ duration = 400 }) end, "neoscroll <C-b>")
    map("<C-f>", function() neoscroll.ctrl_f({ duration = 400 }) end, "neoscroll <C-f>")
    map("zt",    function() neoscroll.zt({ half_win_duration = 250 }) end, "neoscroll zt")
    map("zz",    function() neoscroll.zz({ half_win_duration = 250 }) end, "neoscroll zz")
    map("zb",    function() neoscroll.zb({ half_win_duration = 250 }) end, "neoscroll zb")

  end,
}
