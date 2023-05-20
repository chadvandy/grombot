--- TODO command wrapper object. Payload data w/ methods and etc.
--- Slash Commands

local discordia = require("discordia")
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me


---@class Command : Class
---@field __new fun():Command
local defaults = {
    payload = {},
    ---@param int Interaction
    ---@param args table<string, any> K/V table of option keys and passed values.
    callback = function(int, args) int:reply("This command hasn't been completed yet!") end,

    ---@type CommandOption[]
    options = {},
}

---@class Command : Class
local Command = NewClass("Command", defaults)

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local function is_option(t)
    return is_table(t) and t.class and t:instanceOf(InteractionManager.CommandOption)
end

function Command:new(name, description)
    local o = self:__new()
    o:set_name(name):set_description(description)

    return o
end

function Command:set_name(name)
    assert(is_string(name), "")

    self.payload.name = name
    return self
end


function Command:set_description(description)
    assert(is_string(description), "")

    self.payload.description = description
    return self
end

---@param intType ApplicationCommandTypes
function Command:set_type(intType)
    local i = InteractionManager:is_enum("ApplicationCommandTypes", intType)
	if not i then
		error("type must not be nil")
	end

	self.payload.type = i
	return self
end

---@param fn fun(int:Interaction, args:table)
function Command:set_callback(fn)
    assert(is_function(fn))

    self.callback = fn
end

---@param t CommandOption[]
function Command:set_options(t)
    assert(is_table(t))

    self.options = t
end

function Command:create_option(name, description)
    local opt = InteractionManager:new_command_option(name, description)
    self:add_option(opt)
    return opt
end

---@param t CommandOption
function Command:add_option(t)
    assert(is_option(t))

    self.options[#self.options+1] = t
end

---@param int Interaction
function Command:process(int, args)
    self.callback(int, args)
end

function Command:get_payload()
    local payload = self.payload
    payload.options = {}
    local options = self.options
    for i, option in ipairs(options) do
        payload.options[i] = option.payload
    end

    return payload
end

return Command