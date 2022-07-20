local M = {}

local driver = nil
local conf_module = require('accelerated-jk.config')
local initialized = false

local create_driver = function(config)
  if config.mode == 'time_driven' then
    return require('accelerated-jk.time_driven'):new(config)
  else
    return require('accelerated-jk.position_driven'):new(config)
  end
end

local create_keymaps = function(config)
  for _, motion in ipairs(config.acceleration_motions) do
    vim.api.nvim_set_keymap(
      'n',
      motion,
      string.format("<CMD>lua require'accelerated-jk'.move_to('%s')<CR>", motion),
      { silent = true, noremap = true }
    )
  end
  vim.api.nvim_set_keymap(
    'n',
    '<Plug>(accelerated_jk_j)',
    "<CMD>lua require'accelerated-jk'.move_to('j')<CR>",
    { silent = true, noremap = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<Plug>(accelerated_jk_k)',
    "<CMD>lua require'accelerated-jk'.move_to('k')<CR>",
    { silent = true, noremap = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<Plug>(accelerated_jk_gj)',
    "<CMD>lua require'accelerated-jk'.move_to('gj')<CR>",
    { silent = true, noremap = true }
  )
  vim.api.nvim_set_keymap(
    'n',
    '<Plug>(accelerated_jk_gk)',
    "<CMD>lua require'accelerated-jk'.move_to('gk')<CR>",
    { silent = true, noremap = true }
  )
end

M.reset_key_count = function()
  driver:reset_key_count()
end

M.move_to = function(movement)
  driver:move_to(movement)
end

M.setup = function(opts)
  if initialized then
    return
  end

  local config = conf_module.merge_config(opts)
  driver = create_driver(config)
  create_keymaps(config)

  initialized = true
end

return M
