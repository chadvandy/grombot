local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class Interaction.Menu : Class
---@field __new fun():Interaction.Menu
local Menu = NewClass("Menu", {size = 5})

function Menu:new(custom_id, menu_type)
    local o = self:__new()

    return o:init(custom_id, menu_type)
end

function Menu:init(custom_id, menu_type)
    self.payload = {
        custom_id = custom_id,
        
        type = menu_type,
        options = {},
    }

    return self
end

function Menu:set_placeholder_text(t)
    self.payload.placeholder = t
end

function Menu:set_min_max(i, j)
    self.payload.min_values = i
    self.payload.max_values = j
end

function Menu:add_option(value, label, description, is_default)
    if self.payload.type ~= 3 then
        return
    end

    self.payload.options[#self.payload.options+1] = {
        label = label,
        value = value,
        description = description,
        default = is_default
    }

    return self
end

function Menu:get_payload()
    return self.payload
end

return Menu