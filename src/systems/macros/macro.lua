local client = discordia.storage.client
local MacroManager = discordia.storage.MacroManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class MacroObj : Class
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

	--- the actual table that gets saved.
	data = {}
}

---@class MacroObj
local MacroObj = NewClass("MacroObj", defaults)

---@param name string
---@param desc string
---@return MacroObj
function MacroObj:new(name, desc)
	local o = self:__new()
	o:init(name, desc)

	return o
end

-- function MacroObj:__tostring()
-- 	return string.format("MacroObj: %s (ID: %d)", self.name, self.ticket_num)
-- end

function MacroObj:init(name, desc)
	self:set_name(name)
	self:set_field(desc)
	self.ticket_num = TM:generate_ticket_number("macro")

	return self
end

function MacroObj:instantiate(o)
	local s = self:__new()
	s.ticket_num = o.ticket_num
	s.num_uses = o.num_uses
	s.creation_time = o.creation_time
	s.field = o.field
	s.name = o.name
	s.user = o.user
	s.tags = o.tags

	return s
end

function MacroObj:set_name(name)
	if not is_string(name) then return false, "Name must be a string." end
	if name == "" then return false, "Name cannot be blank." end

	local old_name = self.name
	self.name = name

	MacroManager.macros[name] = self
	if old_name then
		MacroManager.macros[old_name] = nil
	end
	
	return self
end

function MacroObj:set_field(field)
	if not is_string(field) then return false, "Field must be a string." end
	if field == "" then return false, "Field cannot be blank." end

	self.field = field
	return self
end

function MacroObj:get_name()
	return self.name
end

function MacroObj:get_field()
	return self.field
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

function MacroObj:to_save()
	local data = {
		ticket_num = self.ticket_num,
		num_uses = self.num_uses,
		creation_time = self.creation_time,
		field = self.field,
		name = self.name,
		user = self.user,
		tags = self.tags,
	}

	return data
end

return MacroObj