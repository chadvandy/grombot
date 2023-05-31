--- TODO split up "ActionRow" and "Holder", which can be an abstracted class to just hold internal component objects, while ActionRow is an actual Discord object.

local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class Interaction.Holder : Class
---@field __new fun():Interaction.Holder
local Holder = NewClass("ActionRow", {})

function Holder:new()
    return self:__new():init()
end

function Holder:init()
    self.payload = {
        type = 1,
        components = {},
    }

    self.components = {}
    self.space = 5

    return self
end

function Holder:add_component(component)
    self.space = self.space - component.size

    if self.space < 0 then
        -- too many, can't add!
        return self
    end

    self.components[#self.components+1] = component

    return self
end

function Holder:get_payload()
    self.payload.components = {}
    for i, component in ipairs(self.components) do
        self.payload.components[#self.payload.components+1] = component:get_payload()
    end

    return self.payload
end

return Holder