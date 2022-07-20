local TimeDrivenAcceleration = {}

function TimeDrivenAcceleration:new(config)
  local o = {
    key_count = 0,
    previous_timestamp = {},
    acceleration_table = config.acceleration_table,
    deceleration_table = config.deceleration_table,
    end_of_count = config.acceleration_table[#config.acceleration_table],
    acceleration_limit = config.acceleration_limit,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

function TimeDrivenAcceleration:decelerate(delay)
  local deceleration_count = self.deceleration_table[#self.deceleration_table][2]
  local prev_dec_count = 0
  for elapsed, dec_count in pairs(self.deceleration_table) do
    if delay < elapsed then
      deceleration_count = prev_dec_count
      break
    else
      prev_dec_count = dec_count
    end
  end
  self.key_count = (self.key_count - deceleration_count < 0 and 0 or self.key_count - deceleration_count)
end

function TimeDrivenAcceleration:get_acceleration_step()
  local len = #self.acceleration_table
  for idx, value in ipairs(self.acceleration_table) do
    if value > self.key_count then
      return idx
    end
  end
  return len + 1
end

function TimeDrivenAcceleration:move_to(movement)
  local step = vim.api.nvim_get_vvar('count')
  if step and step ~= 0 then
    vim.api.nvim_command('normal! ' .. step .. movement)
    return
  end
  local previous_timestamp = self.previous_timestamp[movement] or {0, 0}
  local current_timestamp = vim.fn.reltime()
  local delta = vim.fn.split(vim.fn.reltimestr(vim.fn.reltime(previous_timestamp, current_timestamp)), '\\.')
  local msec = tonumber(delta[1] .. string.sub(delta[2], 1, 3))
  if msec > self.acceleration_limit then
    self:decelerate(msec)
  end
  step = self:get_acceleration_step()
  vim.api.nvim_command('normal! ' .. step .. movement)
  if self.key_count < self.end_of_count then
    self.key_count = self.key_count + 1
  end
  self.previous_timestamp[movement] = current_timestamp
end

return TimeDrivenAcceleration
