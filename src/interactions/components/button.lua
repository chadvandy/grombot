local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class Interaction.Button : Class
---@field __new fun():Interaction.Button
local Button = NewClass("Button", {size = 1})

function Button:new(custom_id)
    local o = self:__new()

    return o:init(custom_id)
end

function Button:init(custom_id)
    self.payload = {
        custom_id = custom_id,
        
        type = 2,
        label = "",
        style = 1,
    }

    return self
end

function Button:set_custom_id(id)
    self.payload.custom_id = id

    return self
end

function Button:set_style(style)
    self.payload.style = style

    return self
end

function Button:set_disabled(b)
    if not is_boolean(b) then b = true end

    self.payload.disabled = b

    return self
end

function Button:set_label(t)
    self.payload.label = t

    return self
end

function Button:get_payload()
    return self.payload
end

---@param fn fun(int:Interaction)
function Button:set_on_callback(fn)
    self.on_callback = fn

    return self
end

---@param int Interaction
function Button:callback(int)
    self.on_callback(int)
end

return Button