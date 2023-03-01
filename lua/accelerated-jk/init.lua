local M = {}

local driver = nil
local config_module = require('accelerated-jk.config')

local create_driver = function()
  if config_module.items.mode == 'time_driven' then
    return require('accelerated-jk.time_driven'):new(config_module.items)
  else
    return require('accelerated-jk.position_driven'):new(config_module.items)
  end
end

local create_keymaps = function()
  for _, motion in ipairs(config_module.items.acceleration_motions) do
    vim.api.nvim_set_keymap(
      'n',
      motion,
      string.format("<CMD>lua require'accelerated-jk'.move_to('%s')<CR>", motion),
      { silent = true, noremap = true }
    )
  end
  local keymaps = {
    ['<Plug>(accelerated_jk_j)'] = "<CMD>lua require'accelerated-jk'.move_to('j')<CR>",
    ['<Plug>(accelerated_jk_k)'] = "<CMD>lua require'accelerated-jk'.move_to('k')<CR>",
    ['<Plug>(accelerated_jk_gj)'] = "<CMD>lua require'accelerated-jk'.move_to('gj')<CR>",
    ['<Plug>(accelerated_jk_gk)'] = "<CMD>lua require'accelerated-jk'.move_to('gk')<CR>"
  }
  for keymap, motion in pairs(keymaps) do
    vim.api.nvim_set_keymap(
      'n',
      keymap,
      motion,
      { silent = true, noremap = true }
    )
  end
end

M.reset_key_count = function()
  driver:reset_key_count()
end

M.move_to = function(movement)
  driver:move_to(movement)
end

M.setup = function(opts)
  config_module.merge_config(opts)
  driver = create_driver()
  create_keymaps()
end

return M
