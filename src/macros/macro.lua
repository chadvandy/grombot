local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class MacroObj
local defaults = {
	---@type string The ID of the owning user; blank for no owner.
	user = "",

	---@type string The name of the macro, to be retrieved via macro commands.
	name = "",

	---@type string The body of the macro, to be posted when called.
	field = "",

	---@type string[] The tags linked to this macro.
	tags = {},

	---@type number The ticket number for this macro.
	ticket_num = 0,

	---@type number The number of times this macro has been triggered.
	num_uses = 0,

	---@type number The time this macro was created.
	creation_time = 0,
}

---@class MacroObj : Class
local MacroObj = NewClass("MacroObj", defaults)

---@param o table
---@return MacroObj
function MacroObj:new(o)
	o = o or {}
	table.copy_add(o, self)
	setmetatable(o, {
		__index = self
	})

	return o
end

function MacroObj:instantiate(o)
	o = o or {}
	table.copy_add(o, self)
	setmetatable(o, {
		__index = self
	})

	return o
end

function MacroObj:get_line_text()
	return string.format("%s (ID: %d)", self.name, self.ticket_num)
end

function MacroObj:has_tag(tag_name)
	return is_string(tag_name) and self.tags[tag_name]
end

--- TODO!
function MacroObj:get_embed_field()

end

return MacroObj