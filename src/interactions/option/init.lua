--- TODO CommandOption

local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class CommandOption : Class
---@field __new fun():CommandOption
local defaults = {
    payload = {},
}

---@class CommandOption : Class
local CommandOption = NewClass("CommandOption", defaults)

local function is_option(t)
    return is_table(t) and t.class and t:instanceOf(CommandOption)
end

function CommandOption:new(name, description)
    local o = self:__new()
    o:set_name(name):set_description(description)

    return o
end

function CommandOption:set_name(name)
    assert(is_string(name), "")

    self.payload.name = name
    return self
end


function CommandOption:set_description(description)
    assert(is_string(description), "")

    self.payload.description = description
    return self
end

--- TODO enumerated!
function CommandOption:set_type(type)
    type = InteractionManager:is_enum("ApplicationCommandOptionTypes", type)
    assert(type, "Invalid type: " .. tostring(type))

	self.payload.type = type
	return self
end

function CommandOption:set_required(b)
    assert(is_boolean(b))

    self.payload.required = b
end

function CommandOption:set_max_value(n)
    assert(is_number(n))
    assert(InteractionManager.enums[self.payload.type] ~= "NUMBER" and InteractionManager.enums[self.payload.type] ~= "INTEGER", "Can only use max value for integer or number types!")

    self.payload.max_value = n
end

function CommandOption:set_min_value(n)
    assert(is_number(n))
    assert(InteractionManager.enums[self.payload.type] ~= "NUMBER" and InteractionManager.enums[self.payload.type] ~= "INTEGER", "Can only use min value for integer or number types!")

    self.payload.min_value = n
end

return CommandOption