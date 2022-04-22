local PositionDrivenAcceleration = {}

function PositionDrivenAcceleration:new(config)
  local o = {
    key_count = 0,
    previous_position = {
      j = vim.api.nvim_win_get_cursor(0),
      k = vim.api.nvim_win_get_cursor(1),
      gj = vim.api.nvim_win_get_cursor(0),
      gk = vim.api.nvim_win_get_cursor(1),
    },
    acceleration_table = config.acceleration_table,
    end_of_count = config.acceleration_table[#config.acceleration_table],
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function PositionDrivenAcceleration:reset_key_count()
  self.key_count = 0
end

vim.cmd([[
augroup accelerated-jk-position-driven-reset
    autocmd!
    autocmd CursorHold,CursorHoldI * lua require('accelerated-jk').reset_key_count()
augroup END
]])

function PositionDrivenAcceleration:calclate_step()
  local acc_len = #self.acceleration_table
  for idx, step in pairs(self.acceleration_table) do
    if self.key_count < step then
      return idx
    end
  end
  return acc_len + 1
end

function PositionDrivenAcceleration:position_equal(a, b)
  return a[1] == b[1] and a[2] == b[2]
end

function PositionDrivenAcceleration:move_to(movement)
  local step = vim.api.nvim_get_vvar('count')
  if step and step ~= 0 then
    vim.api.nvim_command('normal! ' .. step .. movement)
    return
  end
  if not self:position_equal(self.previous_position[movement], vim.api.nvim_win_get_cursor(0)) then
    self.key_count = 0
  end
  step = self:calclate_step()
  vim.api.nvim_command('normal! ' .. step .. movement)
  if self.key_count < self.end_of_count then
    self.key_count = self.key_count + 1
  end
  self.previous_position[movement] = vim.api.nvim_win_get_cursor(0)
end

return PositionDrivenAcceleration
