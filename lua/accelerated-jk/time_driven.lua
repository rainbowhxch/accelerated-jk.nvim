local TimeDrivenAcceleration = {}

function TimeDrivenAcceleration:new(config)
    local o = {
        key_count = 0,
        j_timestamp = {0, 0},
        k_timestamp = {0, 0},
        h_timestamp = {0, 0},
        l_timestamp = {0, 0},
        acceleration_table = config.acceleration_table,
        deceleration_table = config.deceleration_table,
        end_of_count = config.acceleration_table[#config.acceleration_table],
        acceleration_limit = config.acceleration_limit,
    }
    setmetatable(o, self)
    self.__index = self
    return o
end

function TimeDrivenAcceleration:get_previous_timestamp(movement)
    if movement == 'j' then
        return self.j_timestamp
    elseif movement == 'k' then
        return self.k_timestamp
    elseif movement == 'h' then
        return self.h_timestamp
    elseif movement == 'l' then
        return self.l_timestamp
    end
end

function TimeDrivenAcceleration:set_previous_timestamp(movement, new_timestamp)
    if movement == 'j' then
        self.j_timestamp = new_timestamp
    elseif movement == 'k' then
        self.k_timestamp = new_timestamp
    elseif movement == 'h' then
        self.h_timestamp = new_timestamp
    elseif movement == 'l' then
        self.l_timestamp = new_timestamp
    end
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
    return len
end

function TimeDrivenAcceleration:move_to(movement)
    local step = vim.api.nvim_get_vvar('count')
    if step and step ~= 0 then
        vim.api.nvim_command('normal! ' .. step .. movement)
        return
    end
    local previous_timestamp = self:get_previous_timestamp(movement)
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
    self:set_previous_timestamp(movement, current_timestamp)
end

return TimeDrivenAcceleration
