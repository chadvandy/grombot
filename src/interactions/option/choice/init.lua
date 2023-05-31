--- TODO application command option choice\

local defaults = {
    
}

---@class CommandOptionChoice: Class
---@field __new fun():CommandOptionChoice
local OptionChoice = NewClass("CommandOptionChoice", defaults)

function OptionChoice:new(name, value)
    local o = self:__new()
    return o:init(name, value)
end

function OptionChoice:init(name, value)
    self.payload = {
        name = name,
        value = value,
    }
    
    return self
end

function OptionChoice:set_name(n)
    self.payload.name = n
end

function OptionChoice:set_value(v)
    self.payload.value = v
end

function OptionChoice:get_payload()
    return self.payload    
end

return OptionChoice