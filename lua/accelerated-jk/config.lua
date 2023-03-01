local M = {}

M.items = {
  mode = 'time_driven',
  enable_deceleration = false,
  acceleration_motions = {},
  acceleration_limit = 150,
  acceleration_table = { 7, 12, 17, 21, 24, 26, 28, 30 },
  deceleration_table = { { 150, 9999 } },
}

M.merge_config = function(opts)
  opts = opts or {}
  if opts.enable_deceleration then
    M.items.enable_deceleration = true
    M.items.deceleration_table = { { 200, 3 }, { 300, 7 }, { 450, 11 }, { 600, 15 }, { 750, 21 }, { 900, 9999 } }
  end
  if opts.mode ~= 'time_driven' and opts.mode ~= 'position_driven' then
    opts.mode = M.items.mode
  end
  if opts.mode ~= 'time_driven' then
    opts.acceleration_motions = M.items.acceleration_motions
  end
  M.items = vim.tbl_deep_extend('force', M.items, opts)
end

return M
