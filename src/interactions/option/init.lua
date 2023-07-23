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

    ---@type CommandOptionChoice[]
    choices = {},

    _is_autocomplete = false,
    _autocomplete_callback = function(int, data, value) return{} end
}

---@class CommandOption : Class
local CommandOption = NewClass("CommandOption", defaults)

local function is_option(t)
    return is_table(t) and t.class and t:instanceOf(CommandOption)
end

function CommandOption:get_payload()
    local pl = self.payload
    pl.choices = {}

    for _, choice in ipairs(self.choices) do
        pl.choices[#pl.choices+1] = choice:get_payload()
    end

    return pl
end

function CommandOption:init(name, desc)
    self.payload = {
        required = false,
        name = name,
        description = desc,
        type = 3,
    }

    return self
end

function CommandOption:new(name, desc)
    local o = self:__new()
    o:init(name, desc)

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

function CommandOption:add_option_choice(name, value)
    local t = self.payload.type
    if t ~= 3 and t ~= 4 and t ~= 10 then
        errmsg("Can only use option choices for STRINGS, NUMBERS, and INTEGERS!")
        return self
    end

    local choice = InteractionManager.CommandOptionChoice:new(name, value)
    self.choices[#self.choices+1] = choice

    return self
end

function CommandOption:set_option_choices(tab)
    local t = self.payload.type
    if t ~= 3 and t ~= 4 and t ~= 10 then
        errmsg("Can only use option choices for STRINGS, NUMBERS, and INTEGERS!")
        return self
    end 

    self.choices = {}

    for i, choice_data in ipairs(tab) do
        local choice = InteractionManager.CommandOptionChoice:new(choice_data.name, choice_data.value)
        self.choices[#self.choices+1] = choice
    end

    return self
end

---@param intType ApplicationCommandOptionTypes
function CommandOption:set_type(intType)
    local i = InteractionManager:is_enum("ApplicationCommandOptionTypes", intType)
    assert(intType, "Invalid type: " .. tostring(intType))

	self.payload.type = i
	return self
end

function CommandOption:set_required(b)
    assert(is_boolean(b))

    self.payload.required = b

    return self
end

function CommandOption:set_max_value(n)
    assert(is_number(n))
    assert(InteractionManager.enums[self.payload.type] ~= "NUMBER" and InteractionManager.enums[self.payload.type] ~= "INTEGER", "Can only use max value for integer or number types!")

    self.payload.max_value = n

    return self
end

function CommandOption:set_min_value(n)
    assert(is_number(n))
    assert(InteractionManager.enums[self.payload.type] ~= "NUMBER" and InteractionManager.enums[self.payload.type] ~= "INTEGER", "Can only use min value for integer or number types!")

    self.payload.min_value = n

    return self
end

---@param int Interaction
---@param data table
function CommandOption:handle_autocomplete(int, data, value)
    local choices = self._autocomplete_callback(int, data, value)

    if not is_table(choices) then choices = {} end
    
    -- return choices!
    local ok, err = int:autocomplete(choices)
    if not ok then
        errmsg(err)
    end
end

---@param fn fun(int: Interaction, data: table, value: string): {name:string, value:string}[]
function CommandOption:set_on_autocomplete(fn)
    self._autocomplete_callback = fn

    return self
end

function CommandOption:set_autocomplete(b)
    if is_nil(b) then b = true end
    if not is_boolean(b) then return self end

    self._is_autocomplete = b
    self.payload.autocomplete = true
    return self
end

function CommandOption:is_autocomplete()
    return self._is_autocomplete
end

return CommandOption