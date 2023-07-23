local client = discordia.storage.client
local IM = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local function is_owner_of_macro(macro, user_id)
	-- TODO check if is-admin too!
	if user_id == client.owner.id then return true end

	if not macro.user or macro.user == "" then
		return true, "There is no owner for this macro."
	end

	if macro.user == user_id then
		return true, true
	end

	if macro.user ~= user_id then
		return false, "Can't edit - this macro is owned by someone else."
	end
end

---@class MacroManager
local def = {
	macros = {}
}

---@class MacroManager
local MacroManager = NewClass("MacroMaanger", def)

discordia.storage.MacroManager = MacroManager

---@type MacroObj
MacroManager.MacroObj = require "./macro"

function MacroManager:init()
	self:load_macro_data()
	-- local macros = self:get_macros()
	-- if macros then
	-- 	for k, macro in pairs(macros) do
	-- 		macro = self.MacroObj:instantiate(macro)
	
	-- 		-- instantiate ticket numbers for older macros!
	-- 		if macro.ticket_num == 0 then
	-- 			macro.ticket_num = TM:generate_ticket_number("macro")
	-- 		end
	-- 	end
	-- end


	-- local tags = self:get_tags()
	-- for k, tag in pairs(tags) do
	-- 	self.MacroTag:instantiate(tag)
	-- end

	self:save()
end

function MacroManager:load_macro_data()
	for key, macro in pairs(saved_data.macros._MACROS) do
		self.macros[key] = self.MacroObj:instantiate(macro)
	end
end

--- Get all macros.
---@return table<string, MacroObj>
function MacroManager:get_macros()
	return self.macros
end

---@return MacroObj
function MacroManager:get_macro(name)
	return self.macros[name]
end

---@param int Interaction
function MacroManager:all_macros(int)
	local Nav = IM:create_navigation()

	Nav:set_title("All Macros")
	Nav:use_default_components()
	Nav:set_user(int.user)

	-- local nav = PM.new("macro_all", message.channel)
	-- nav:set_title("Macros")

	local macros = self:get_macros()
	local fields = {}
	for macro_name, macro in pairs_by_keys(macros) do
		fields[#fields+1] = {
			name = "",
			value = macro:get_line_text(),
			inline = false,
		}
	end

	Nav:set_fields_per_page(15)
	Nav:set_fields(fields)

	Nav:start(int)
end

function MacroManager:new_macro(name, desc)
	print("Creating new macro")
	local new_macro = self.MacroObj:new(name, desc)
	self.macros[name] = self.MacroObj:new(name, desc)
	print("New macro created")

	self:save()
	print("Saved")

	return new_macro
end

function MacroManager:delete_macro(name)
	self.macros[name] = nil
	saved_data.macros._MACROS[name] = nil
	self:save()
end

function MacroManager:save()
	saved_data.macros._MACROS = {}
	
	for key, macro in pairs(self:get_macros()) do
		saved_data.macros._MACROS[macro.name] = macro:to_save()
	end
	
    save_data("macros")
end