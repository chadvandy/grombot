local discordia = require("discordia")
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local function save()
	save_data("macros")
end

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

---@class macro_manager
local MacroManager = {}

---@class macro_obj
local MacroObj = {
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

---@class macro_tag
local MacroTag = {
	---@type string The name of the tag.
	name = "",

	---@type string The description of the tag, to be displayed with the tag commands.
	description = "",
}

---@param o table
---@return macro_obj
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

function MacroTag:new(o)
	o = o or {}
	table.copy_add(o, self)
	setmetatable(o, {
		__index = self
	})

	return o
end

function MacroTag:instantiate(o)
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

function MacroManager:init()
	local macros = self:get_macros()
	for k, macro in pairs(macros) do
		MacroObj:instantiate(macro)

		-- instantiate ticket numbers for older macros!
		if macro.ticket_num == 0 then
			macro.ticket_num = TM:generate_ticket_number("macro")
		end
	end

	local tags = self:get_tags()
	for k, tag in pairs(tags) do
		MacroTag:instantiate(tag)
	end

	save()
end

--- Get a macro throug a query of either a string (name OR alias), or the ticket ID number.
---@param query string
---@param is_case_sensitive boolean|nil
---@return macro_obj
function MacroManager:query_macro(query, is_case_sensitive)
	-- automatically change to a number if it can be converted; otherwise, keep as stringbean.
	query = tonumber(query) or query

	-- try to find a macro w/ this name.
	if is_string(query) then
		if not is_case_sensitive then query = query:lower() end

		local t = saved_data.macros._ALIAS[query]

		local macros = self:get_macros()
		if t then return macros[t], t end

		for k,v in pairs(macros) do
			if k:lower() == query then
				return v,k
			end
		end
	end

	-- try to find a macro w/ this ID!
	if is_number(query) then
		local macros = self:get_macros()
		for k,v in pairs(macros) do
			if v.ticket_num == query then
				return v,k
			end
		end
	end
end

--- Create & Save a new macro.
---@param name string
---@param field string
---@return macro_obj
function MacroManager:new_macro(name, field, owner)
	if not is_string(name) then return false end
	if not is_string(field) then return false end
	if not is_string(owner) then return false end

	if self:match_macro(name) then
		return false, "There's already a macro with the name " .. name
	end

	local ticket = TM:generate_ticket_number("macro")
	local macro = MacroObj:new({name=name, field=field, user=owner,ticket_num=ticket})
	saved_data.macros._MACROS[name] = macro
	save()

	return macro
end

--- Create & Save a new macro tag.
---@param name string The name ID for the new tag.
---@param description string The description for the new tag.
---@return macro_tag
function MacroManager:new_tag(name, description)
	if not is_string(name) then return false end
	if not is_string(description) then return false end

	if self:get_tag(name) then
		return false, "There's already a tag with the name " ..  name
	end

	if not saved_data.macros._TAGS then saved_data.macros._TAGS = {} end

	local tag = MacroTag:new({name=name, description=description})
	saved_data.macros._TAGS[name] = tag
	save()

	return tag
end

function MacroManager:get_tags()
	if not saved_data.macros._TAGS then saved_data.macros._TAGS = {} end
	return saved_data.macros._TAGS
end

function MacroManager:get_tag(name)
	local tags = self:get_tags()
	
	if tags[name] then return tags[name] end

	for k,v in pairs(tags) do
		if name:lower() == k:lower() then
			return v
		end
	end
end

--- Get all macros.
---@return table<string, macro_obj>
function MacroManager:get_macros()
	return saved_data.macros._MACROS
end

---comment
---@param tag string
---@param name_only boolean|nil
---@return macro_obj[]
function MacroManager:get_macros_with_tag(tag, name_only)
	local ret = {}
	local macros = self:get_macros()
	-- printf("Getting macros with tag %q", tag)
	for key, macro in pairs(macros) do
		if macro:has_tag(tag) then
			if name_only then
				ret[#ret+1] = key
			else
				ret[#ret+1] = macro
			end
		end
	end

	return ret
end


---comment
---@param message Message
function MacroManager:display_all_macros(message)
	local nav = PM.new("macro_all", message.channel)
	nav:set_title("Macros")

	local macros = self:get_macros()
	local str = {}
	for macro_name, macro in pairs_by_keys(macros) do
		str[#str+1] = #str+1 .. ". " .. macro:get_line_text()
	end

	nav:set_fields_per_page(20)
	nav:set_fields_is_description()
	nav:set_fields(str)
	nav:set_user(message.author.id)
	nav:start()
end

--- Display the navigator for a search msg.
---@param message Message
---@param query string The queried string to search.
function MacroManager:display_search_macro(message, query)
	local nav = PM.new("macro_search", message.channel)
	nav:set_title("Macros")

	local macros_found = {}
	local fields = {}

	for macro_name, macro in pairs_by_keys(self:get_macros()) do
		local macro_key = macro.name:lower()

		-- printf("Comparing %q against %q", macro_key, query)

		if macro_key:find(query) then
			if not macros_found[macro_key] then
				fields[#fields+1] = #fields+1 .. ". " .. macro:get_line_text()
				macros_found[macro_key] = true
			end
		end
	end

	if #fields == 0 then
		fields[1] = "No macros were found with this search, sorry :("
	end

	nav:set_fields_is_description()
	nav:set_fields_per_page(20)
	nav:set_fields(fields)
	nav:set_user(message.author.id)
	nav:start()
end

--- Display a macro and tick its usage up one!
---@param message Message
---@param macro macro_obj
function MacroManager:display_macro(message, macro)
	local field = macro.field
	if is_table(field) then field = field[math.random(#field)] end
	message.channel:send(field)

	macro.num_uses = macro.num_uses + 1
	save()
end

--- Show full details about a macro!
---@param message Message
---@param macro macro_obj
function MacroManager:display_macro_details(message, macro)
	local nav = PM.new("macro_details", message.channel)
	nav:set_title(tostring(macro.name))
	-- nav:set_description("Bloop") TODO?
	nav:set_fields_per_page(5)
	printf("Macro owner of %q is %q, len is %d", macro.name, tostring(macro.user), tostring(macro.user):len())

	local owner_str = macro.user ~= "" and "<@" .. macro.user .. ">" or "Unclaimed"
	local tags = {}
	for tag,_ in pairs(macro.tags) do
		tags[#tags+1] = tag
	end

	local tag_str = "No tags"
	if #tags >= 1 then
		tag_str = ""
		local concat = table.concat(tags, ", ")
		for line in concat:gmatch("[%a%s]+,?") do
			tag_str = tag_str .. string.format("`%s`", line)
		end
	end

	local uses_str = tostring(macro.num_uses)

	local aliases = {}
	for alias,macro_key in pairs(saved_data.macros._ALIAS) do
		if macro_key == macro.name then
			aliases[#aliases+1] = alias
		end
	end
	local alias_str = "No aliases."
	if #aliases >= 1 then
		alias_str = ""
		local concat = table.concat(aliases, ", ")
		for line in concat:gmatch("[%a%s]+,?") do
			if line:find(",") then
				-- insert before the comma
				local no_comma = line:gsub(",", "")
				alias_str = alias_str .. string.format("`%s`,", no_comma)
			else
				alias_str = alias_str .. string.format("`%s`", line)
			end
		end
	end

	nav:set_fields({
		{
			name = "Owner",
			value = owner_str,
			inline = true,
		},
		{
			name = "Uses",
			value = uses_str,
			inline = true,
		},
		{
			name = "Tags",
			value = tag_str,
			inline = true,
		},
		{
			name = "Aliases",
			value = alias_str,
			inline = true,
		},
		{
			name = "Ticket ID",
			value = tostring(macro.ticket_num),
			inline = true,
		}
	})

	-- TODO
	-- nav:set_footer("Created at " .. shit here I guess)
	nav:set_user(message.author.id)
	nav:start()
end

function MacroManager:get_macros_owned_by_user(user_id)
	local ret = {}
	local macros = self:get_macros()
	for key, macro in pairs_by_keys(macros) do
		if not user_id then
			if macro.user ~= "" then
				ret[#ret+1] = macro
			end
		end
		if macro.user == user_id then
			ret[#ret+1] = macro
		end
	end

	return ret
end

function MacroManager:get_macros_unowned()
	local ret = {}
	local macros = self:get_macros()
	for key, macro in pairs_by_keys(macros) do
		if macro.user == "" then
			ret[#ret+1] = macro
		end
	end
	
	return ret
end

--- Display a list of all self-owned macros.
---@param message Message
function MacroManager:display_mine_macros(message)
	local nav = PM.new("macro_mine", message.channel)
	nav:set_title("Your Macros")
	nav:set_description("Your owned macros. Use `?macro \"Macro Name\"` to view a macro in its fullest!")

	local fields = {}
	
	local mine = self:get_macros_owned_by_user(message.author.id)
	if #mine > 0 then
		nav:set_fields_per_page(20)
		nav:set_fields_is_description()

		for i = 1, #mine do
			local macro = mine[i]
			fields[#fields+1] = #fields+1 .. ". " .. macro:get_line_text()
		end
	else
		fields[1] = {
			name = "None found!",
			value = "You don't own any macros!",
		}
	end

	nav:set_fields(fields)
	nav:set_user(message.author.id)
	nav:start()
end

--- Display a list of all owned macros.
---@param message Message
function MacroManager:display_owned_macros(message)
	local nav = PM.new("macro_owned", message.channel)
	nav:set_title("Owned Macros")
	nav:set_description("All owned macros. Use `?macro \"Macro Name\"` to view a macro in its fullest!")

	local fields = {}
	
	local owned = self:get_macros_owned_by_user()
	if #owned > 0 then
		nav:set_fields_per_page(20)
		nav:set_fields_is_description()

		for i = 1, #owned do
			local macro = owned[i]
			fields[#fields+1] = #fields+1 .. ". " .. macro:get_line_text() .. " by <@"..macro.user..">"
		end
	else
		fields[1] = {
			name = "None found!",
			value = "No one owns any macros!",
		}
	end

	nav:set_fields(fields)
	nav:set_user(message.author.id)
	nav:start()
end

--- Display a list of all unowned macros.
---@param message Message
function MacroManager:display_unowned_macros(message)
	local nav = PM.new("macro_unowned", message.channel)
	nav:set_title("Unowned Macros")
	nav:set_description("All unclaimed macros. Use `?macro \"Macro Name\"` to view a macro in its fullest, and `?macro claim \"Macro Name\"` to claim it!")

	local fields = {}
	
	local unowned = self:get_macros_unowned()
	if #unowned > 0 then
		nav:set_fields_per_page(20)
		nav:set_fields_is_description()

		for i = 1, #unowned do
			local macro = unowned[i]
			fields[#fields+1] = #fields+1 .. ". " .. macro:get_line_text()
		end
	else
		fields[1] = {
			name = "None found!",
			value = "There are no unclaimed macros!",
		}
	end

	nav:set_fields(fields)
	nav:set_user(message.author.id)
	nav:start()
end

function MacroManager:display_all_tags(message)
	local navigator = PM.new("macro_tags", message.channel)
	navigator:set_title("All Tags")
	navigator:set_description("All currently available tags for macros. Use `?macro tag \"tag name\"` to view all macros with a specified tag.")
	navigator:set_fields_per_page(10)

	local fields = {}
	local tags = self:get_tags()

	for tag_name, tag in pairs_by_keys(tags) do
		fields[#fields+1] = {
			name = tag_name,
			value = tag.description
		}
	end

	navigator:set_fields(fields)
	navigator:set_user(message.author.id)
	navigator:start()
end

--- Display an embed showing everything within a tag!
---@param message Message
---@param tag macro_tag
function MacroManager:display_tag(message, tag)
	local navigator = PM.new("macro_tag", message.channel)
	local tag_name = tag.name
	navigator:set_title("Tag: " .. tag_name)
	navigator:set_description(string.format(tag.description .. "\nAll macros with the tag `%s`. Use `?macro Macro Name` to view a complete macro.", tag_name))

	local macros = self:get_macros_with_tag(tag_name)
	if #macros == 0 then
		navigator:set_fields({
			{
				name = "None found!",
				value = "Doesn't seem like there's any macros with this tag yet. You can assign a macro to this tag by using `?macro set_tag \"Macro Name\" \"" .. tag_name .."\"`"
			}
		})
	else
		local fields = {}
		for name, macro in pairs_by_keys(macros) do
			fields[#fields+1] = #fields+1 .. " " .. macro:get_line_text()
		end

		navigator:set_fields_is_description()
		navigator:set_fields_per_page(20)
		navigator:set_fields(fields)
	end

	navigator:set_user(message.author.id)
	navigator:start()
end

--- Try to get a macro with specified text - isn't case-sensitive.
---@param test string
---@return macro_obj, string
function MacroManager:match_macro(test)
	if not is_string(test) then return end
	local macros = self:get_macros()

	test = test:lower()

	for k,v in pairs(macros) do
		local macro_key = k:lower()

		if macro_key == test then
			return v,k
		end
	end
end

local quote_err = "You have to wrap the name of the macro in quotes, for instance \"my macro\"."

---@param args table<number, string>
---@param message Message
local macro_command = CM:new_command(
	"macro", 
	function (message, args)
		local macro = args.macro

		MacroManager:display_macro(message, macro)
	end
)
macro_command:set_name("Macros")
macro_command:set_description("The macro functionality allows you to check out simple macros saved to this server, for quick reference.")
macro_command:set_usage("`%smacro macro name`, where macro name is a valid name of a macro.")
macro_command:set_trigger("message", "macro")
macro_command:set_master_description("Macros are simple messages that members can create, edit, delete, and reference at any time - designed to be a quick and easy way to grab simple information. Use the following commands to interface with the macro system!\nOnly modders can use the commands that edit or create or delete macros!")
macro_command:set_category("Utility")
macro_command:set_argument_parser(
	function (message, args)
	-- TODO ?macro called by itself - treat it like a help function?
		if #args == 0 then
			return false, "You have to pass a name along to find a macro, as in ?macro my macro"
		end

		local str = table.concat(args, " ")

		-- allow for quoted catches and otherwise
		local name, end_x = get_quoted_name_from_string(str)
		if not name then name = str end

		name = name:lower()

		-- tests ID numbers, aliases, and names.
		local macro = MacroManager:query_macro(name)

		-- if not macro then
		-- 	local test = saved_data.macros._ALIAS[name]
		-- 	macro = match_macro(test)
		-- end

		if not macro then
			return false, string.format("There is no macro found with the name %q", name)
		end

		return {
			macro = macro,
		}
	end
)

-- create a new macro, using ?macro new []
local macro_create = macro_command:set_sub_command(CM:new_command(
	"macro_create",
	---@param args table<number, string>
	---@param message Message
	function (message, args)
		local name, description, owner = args.name, args.description, message.author.id
		local macro, err = MacroManager:new_macro(name, description, owner)
		if not macro then
			return sendf(message.channel, err)
		end

		sendf(message.channel, "New macro created with name %q!", name)
	end
))
macro_create:set_name("Create a Macro")
macro_create:set_description("Create a new macro, with the name and description provided. Use quotation marks around the macro name!")
macro_create:set_usage("`%smacro create \"New Macro\" Macro description goes here.`\nIt accepts Discord formatting!")
macro_create:set_trigger("message", "create")
macro_create:set_validity_check(is_cnc_and_modder)
macro_create:set_argument_parser(function (message, args)
	if not args or not is_string(args[1]) then
		return false, "You need to give it a name, for instance `"..prefix.."macro create \"My New Macro.\"`"
	end

	local passed_str = table.concat(args, " ")
	local name, end_x = get_quoted_name_from_string(passed_str)

	if not name then
		return false, quote_err
	end

	if tonumber(name) then
		return false, "You can't make a macro's name a number! TRY AGAIN."
	end

	if macro_command:get_sub_command(name) then
		return false, string.format("You can't use the name %q because it's reserved for this command.", name)
	end
	
	if MacroManager:query_macro(name) then
		return false, string.format("A macro with the name %q already exists.", name)
	end

	-- start after the next space
	local start = passed_str:find(" ", end_x)
	
	if not start then
		return false, "You need to pass a description to the new macro, for instance ?macro create \"my new macro\" Macro description here"
	end

	start = start+1
	
	local description = passed_str:sub(start)
	if not description then
		return false, "You need to pass a description to the new macro, for instance ?macro create \"my new macro\" Macro description here"
	end

	return {
		name = name,
		description = description,
	}
end)

local set_owner = macro_command:set_sub_command(CM:new_command(
	"macro_set_owner",
	---@param message Message
	---@param args set_owner_args
	function(message, args)
		local macro = args.macro
		local macro_key = args.macro_key
		local user_id = args.user_id

		if user_id then
			macro.user = user_id
			sendf(message.channel, "Macro %s owner changed!", macro_key)
		else
			macro.user = ""
			sendf(message.channel, "Macro %s set to no owner!", macro_key)
		end
	end
))
set_owner:set_name("Set macro's owner")
set_owner:set_description("Change the owner of a macro, so only the owner (and admins) can edit or delete it.")
set_owner:set_usage("`%smacro set_owner \"macro name\" @Owner`. Don't put in a mention if you want to clear the owner.")
set_owner:set_trigger("message", "set_owner")
set_owner:set_validity_check(is_admin)
set_owner:set_argument_parser(
	---@param message Message
	---@param args table<number, string>
	function (message, args)
		local macro_key,_ = get_quoted_name_from_string(table.concat(args, " "))
		if not macro_key then
			return false, quote_err
		end

		local macro = MacroManager:query_macro(macro_key)
		if not macro then
			return false, "No macro found with the key "..macro_key
		end

		---@type User
		local user = message.mentionedUsers.first
		local user_id = nil
		if user then
			user_id = user.id
		end

		---@class set_owner_args
		return {
			macro = macro,
			macro_key = macro_key,
			user_id = user_id,
		}
	end
)

local claim = macro_command:set_sub_command(CM:new_command(
	"macro_claim",
	function(message, args)
		local macro = args.macro
		local macro_key = args.macro_key
		local user_id = args.new_owner

		macro.user = user_id
		save_data("macros")

		message.channel:send("You have claimed the macro ["..macro_key.."]!")
	end
))
claim:set_name("Claim macro")
claim:set_description("Claim a macro, and set yourself as the owner. This means only you (and admins) can edit or delete it.")
claim:set_usage("`%smacro claim \"macro name\"`")
claim:set_trigger("message", "claim")
claim:set_validity_check(is_cnc_and_modder)
claim:set_argument_parser(
	---@param message Message
	---@param args table<number, string>
	function(message, args)
		local macro_key,_ = get_quoted_name_from_string(table.concat(args, " "))
		if not macro_key then
			return false, quote_err
		end

		local user_id = message.author.id

		local macro = MacroManager:query_macro(macro_key)
		if not macro then
			return false, "No macro found with the key "..macro_key
		end

		local owner,err = is_owner_of_macro(macro, user_id)
		if not owner then
			return false, err
		end

		return {
			macro = macro,
			macro_key = macro_key,
			new_owner = user_id,
		}
	end
)

local unclaim = macro_command:set_sub_command(CM:new_command(
	"macro_unclaim",
	function(message, args)
		local macro = args.macro
		local macro_key = args.macro_key
		local user_id = args.new_owner

		macro.user = user_id
		save_data("macros")

		message.channel:send("You have unclaimed the macro ["..macro_key.."]!")
	end
))
unclaim:set_name("Unclaim macro")
unclaim:set_description("Unclaim a macro, and remove yourself as the owner. This means anyone (with relevant permissions) can edit or delete it.")
unclaim:set_usage("`%smacro unclaim \"macro name\"`")
unclaim:set_trigger("message", "unclaim")
unclaim:set_validity_check(is_cnc_and_modder)
unclaim:set_argument_parser(
	---@param message Message
	---@param args table<number, string>
	function (message, args)
		local macro_key,_ = get_quoted_name_from_string(table.concat(args, " "))
		if not macro_key then
			return false, quote_err
		end

		local user_id = message.author.id

		local macro = MacroManager:query_macro(macro_key)
		if not macro then
			return false, "No macro found with the key "..macro_key
		end

		local is_owner, err = is_owner_of_macro(macro, user_id)
		if not is_owner then
			return false, err
		end

		if is_owner and err == true then
			return false, "This macro doesn't have an owner."
		end

		return {
			macro = macro,
			macro_key = macro_key,
			new_owner = "",
		}
	end
)

local macro_set_extra_field = macro_command:set_sub_command(CM:new_command(
	"macro_set_extra_field",
	function(message, args)
		local channel = message.channel
		
		local macro = args.macro
		local new_field = args.description

		if is_string(macro.field) then macro.field = {macro.field} end
		macro.field[#macro.field+1] = new_field

		sendf(channel, "New field added!")
		save()
	end
))
macro_set_extra_field:set_name("Set Extra Field")
macro_set_extra_field:set_description("Add an extra field to a macro, so one of the fields defined will be displayed randomly.")
macro_set_extra_field:set_usage("`%smacro set_extra_field \"macro name\" Extra Field.`")
macro_set_extra_field:set_trigger("message", "set_extra_field")
macro_set_extra_field:set_validity_check(is_cnc_and_modder)
macro_set_extra_field:set_argument_parser(
	function (message, args)
		if not args or not is_string(args[1]) then
			return false, "You need to give it a name, for instance `"..prefix.."macro set_extra_field \"My Macro\" Extra field.`"
		end

		local passed_str = table.concat(args, " ")

		local name, second_x = get_quoted_name_from_string(passed_str)
		if not name then
			return false, quote_err
		end
		
		local macro = MacroManager:query_macro(name)
		if not macro then
			return false, string.format("No macro with the name %q exists.", name)
		end

		local user_id = message.author.id
		local is_owner, err = is_owner_of_macro(macro, user_id)
		if not is_owner then
			return false, err
		end

		-- start after the next space
		local start = passed_str:find(" ", second_x) +1

		if not start then
			return false, "You need to pass a description to the macro, for instance `?macro set_extra_field \"my macro\" Macro description here`"
		end

		local new_description = passed_str:sub(start)

		return {
			macro = macro,
			description = new_description,
		}
	end
)

local macro_edit = macro_command:set_sub_command(CM:new_command(
	"macro_edit",
	function (message, args)
		local channel = message.channel

		local macro = args.macro
		local new_description = args.description

		macro.field = new_description

		sendf(channel, "Macro edited!")
		save()
	end
))
macro_edit:set_name("Edit a macro")
macro_edit:set_description("Change a macro by its name. Use quotation marks around the name to get it.")
macro_edit:set_usage("`%smacro edit \"macro name\" New Macro Description.`")
macro_edit:set_trigger("message", "edit")
macro_edit:set_validity_check(is_cnc_and_modder)
macro_edit:set_argument_parser(
	function (message, args)
		if not args or not is_string(args[1]) then
			return false, "You need to give it a name, for instance `"..prefix.."macro edit \"My Macro\" Edited field.`"
		end

		local passed_str = table.concat(args, " ")

		local name, second_x = get_quoted_name_from_string(passed_str)
		if not name then
			return false, quote_err
		end
		
		local macro = MacroManager:query_macro(name)
		if not macro then
			return false, string.format("No macro with the name %q exists.", name)
		end

		local user_id = message.author.id
		local is_owner, err = is_owner_of_macro(macro, user_id)
		if not is_owner then
			return false, err
		end

		-- start after the next space
		local start = passed_str:find(" ", second_x) +1

		if not start then
			return false, "You need to pass a description to the macro, for instance `?macro edit \"my macro\" Macro description here`"
		end

		local new_description = passed_str:sub(start)

		return {
			macro = macro,
			description = new_description,
		}
	end
)

local rename = macro_command:set_sub_command(CM:new_command(
	"macro_rename",
	function(message, args)
		local channel = message.channel

		local macro = args.macro
		local old_name = args.old_name
		local new_name = args.new_name
		macro.name = new_name

		saved_data.macros._MACROS[old_name] = nil
		saved_data.macros._MACROS[new_name] = macro

		sendf(channel, "Macro edited! New name is %q", new_name)
		save_data("macros")
	end
))
rename:set_name("Rename a macro")
rename:set_description("Rename the name for a macro.")
rename:set_usage("`%smacro rename \"macro name\" \"New Macro Name\"")
rename:set_trigger("message", "rename")
rename:set_validity_check(is_cnc_and_modder)
rename:set_argument_parser(
	function (message, args)
		if not args or not is_string(args[1]) then
			-- errmsg, needs arguments passed!
			return false, "You need to give it a name, for instance `"..prefix.."macro rename \"My Macro\" \"New Name\".`"
		end

		local passed_str = table.concat(args, " ")

		local old_name,end_x = get_quoted_name_from_string(passed_str)

		if not old_name then
			return false, "You have to wrap the name of the macro in quotes, for instance `?macro rename \"my macro\" \"New Name\"`"
		end

		local macro, true_old_name = MacroManager:query_macro(old_name)
		if not macro then
			return false, string.format("No macro with the name %q exists.", old_name)
		end

		local is_owner, err = is_owner_of_macro(macro, message.author.id)
		if not is_owner then
			return false, err
		end

		passed_str = passed_str:sub(end_x)

		local new_name,_ = get_quoted_name_from_string(passed_str)
		if not new_name then
			return false, "You have to wrap the new name of the macro in quotes, for instance `?macro rename \"my macro\" \"New Name\"`"
		end

		return {
			macro = macro,
			old_name = true_old_name,
			new_name = new_name
		}
	end
)

-- display all macros
local macro_all = macro_command:set_sub_command(CM:new_command(
	"macro_all",
	---@param message Message
	---@param args any
	function (message, args)
		MacroManager:display_all_macros(message)

			-- local navigator = PM.new("all_macros", channel)

			-- navigator:set_title("All Macros!")
			-- navigator:set_description("All macro names. Use `?macro Macro Name` to view the complete macro.")

			-- local all_fields = {}
			-- local macros = saved_data.macros._MACROS
			-- for k,v in pairs(macros) do
			-- 	local t = {
			-- 		name = k or "NO NAME FOUND???",
			-- 		value = "Owner: None",
			-- 	}

			-- 	local aliases = get_aliases_for_macro(k)
			-- 	if next(aliases) then
			-- 		-- t.value = t.value.."\n**Alias:** "

			-- 		for i = 1, #aliases do
			-- 			if i == 1 then
			-- 				if 1 == #aliases then
			-- 					t.value = t.value .. "\nAlias: \"".. aliases[i].."\""
			-- 				else
			-- 					t.value = t.value .. "\nAliases: \"".. aliases[i].."\""
			-- 				end
			-- 			else
			-- 				if i == #aliases then
			-- 					t.value = t.value .. ", \"".. aliases[i].."\"."
			-- 				else
			-- 					t.value = t.value .. ", \"".. aliases[i].."\""
			-- 				end
			-- 			end
			-- 		end
			-- 	end

			-- 	-- printf("Adding embed with name %q and value %q", t.name, t.value)
					
			-- 	all_fields[#all_fields+1] = t
			-- end

			-- navigator:set_fields_per_page(10)
			-- navigator:set_fields(all_fields)

			-- navigator:start()
	end
))
macro_all:set_name("Display all macros")
macro_all:set_description("Display a list of every macro available.")
macro_all:set_usage("`%smacro all`")
macro_all:set_trigger("message", "all")

-- delete a macro
local macro_delete = macro_command:set_sub_command(CM:new_command(
	"macro_delete",
	function (message, args)
		local macro = args.macro
		local name = args.name

		saved_data.macros._MACROS[name] = nil
		save_data("macros")

		sendf(message.channel, "Macro %q deleted!", name)
	end
))
macro_delete:set_name("Delete a macro")
macro_delete:set_description("Delete a specified macro with the name provided. This action is irreversible.")
macro_delete:set_usage("`%smacro delete \"macro name\"`")
macro_delete:set_trigger("message", "delete")
macro_delete:set_validity_check(is_cnc_and_modder)
macro_delete:set_argument_parser(
	---@param message Message
	---@param args table<number, string>
	function (message, args)
		local str = table.concat(args, " ")
		local name,_ = get_quoted_name_from_string(str)
		if not name then
			return sendf(message.channel, quote_err)
		end

		local macro, true_name = MacroManager:query_macro(name)

		if not macro then
			return false, "No macro found with name \""..name.."\", looks like you got what you wanted!"
		end

		if not is_owner_of_macro(name, message.author.id) then
			return false, "You cannot delete this macro unless you're the owner."
		end

		return {
			macro = macro,
			name = true_name,
		}
	end
)


local macro_search = macro_command:set_sub_command(CM:new_command(
	"macro_search",
	function (message, args)
		local query = args.query

		MacroManager:display_search_macro(message, query)
	end
))
macro_search:set_name("Search for a macro")
macro_search:set_description("Search for a given macro. Useful when you know the idea of a macro but forget its name. If you input \"testing\", it'll show all macros that have a name that includes \"testing\".")
macro_search:set_usage("`%smacro search [query here]`. You can use multiple words after 'search' to search for many names at once.")
macro_search:set_trigger("message", "search")
macro_search:set_argument_parser(function (message, args)
	if not args or not is_string(args[1]) then
		return false, "You need to give a valid query!"
	end

	return {
		query = table.concat(args, " "):lower()
	}
end)


local macro_set_alias = macro_command:set_sub_command(CM:new_command(
	"macro_set_alias",
	function (message, args)
		local channel = message.channel

		if not args or not is_string(args[1]) then
			-- errmsg, needs arguments passed!
			sendf(channel, "You need to specify a macro name, for instance `"..prefix.."macro set_alias \"macro name\" alias`")
			return
		end

		local passed_str = table.concat(args, " ")
		local macro_name, end_x = get_quoted_name_from_string(passed_str)

		if not macro_name then
			sendf(channel, quote_err)
			return
		end

		local macro = MacroManager:query_macro(macro_name)
		
		if not macro then
			sendf(channel, "No macro with the name %q found!", macro_name)
			return
		end

		macro_name = macro.name

		-- sendf(channel, "New macro is named %q", new_name)

		-- start after the next space
		local start = passed_str:find(" ", end_x) +1

		if not start then
			sendf(channel, "You need to pass a new alias to the macro, for instance ?macro set_alias \"my macro\" alias here")
			return
		end

		local new_alias = passed_str:sub(start)
		new_alias = new_alias:lower()

		if saved_data.macros._ALIAS[new_alias] and saved_data.macros._ALIAS[new_alias] ~= macro_name then
			sendf(channel, "The alias %q is already used for another macro!", new_alias)
			return
		end

		saved_data.macros._ALIAS[new_alias] = macro_name

		save_data("macros")

		sendf(channel, "Alias %q created for macro %q", new_alias, macro_name)
	end
))
macro_set_alias:set_name("Set a macro alias")
macro_set_alias:set_description("Set the alias of a macro, so `?macro [alias]` will trigger that macro name as well.")
macro_set_alias:set_usage("`%smacro set_alias \"macro name\" alias`")
macro_set_alias:set_trigger("message", "set_alias")
macro_set_alias:set_validity_check(is_cnc_and_modder)

local macro_remove_alias = macro_command:set_sub_command(CM:new_command(
	"macro_remove_alias",
	function (message, args)
		local channel = message.channel

		if not args or not is_string(args[1]) then
			-- errmsg, needs arguments passed!
			sendf(channel, "You need to specify a macro name, for instance `"..prefix.."macro remove_alias \"macro name\" alias`")
			return
		end

		local passed_str = table.concat(args, " ")
		local macro_name, end_x = get_quoted_name_from_string(passed_str)

		if not macro_name then
			sendf(channel, quote_err)
			return
		end

		local macro = MacroManager:query_macro(macro_name)
		
		if not macro then
			sendf(channel, "No macro with the name %q found!", macro_name)
			return
		end

		macro_name = macro.name

		-- sendf(channel, "New macro is named %q", new_name)

		-- start after the next space
		local start = passed_str:find(" ", end_x) +1

		if not start then
			sendf(channel, "You need to pass an alias to delete, for instance ?macro remove_alias \"my macro\" alias here")
			return
		end

		local new_alias = passed_str:sub(start)
		new_alias = new_alias:lower()

		if not saved_data.macros._ALIAS[new_alias] then
			sendf(channel, "The string %q is not used as an alias!", new_alias)
			return
		end

		if saved_data.macros._ALIAS[new_alias] ~= macro_name then
			sendf(channel, "The alias %q is used for a different macro!", new_alias)
			return
		end

		saved_data.macros._ALIAS[new_alias] = nil

		save_data("macros")

		sendf(channel, "Alias %q removed for macro %q", new_alias, macro_name)
	end
))
macro_remove_alias:set_name("Remove a macro's alias")
macro_remove_alias:set_description("Remove a present alias for a macro, so it's freed up for other goodies.")
macro_remove_alias:set_usage("`%smacro remove_alias \"macro name\" alias`")
macro_remove_alias:set_trigger("message", "remove_alias")
macro_remove_alias:set_validity_check(is_cnc_and_modder)

local macro_raw = macro_command:set_sub_command(CM:new_command(
	"macro_raw",
	function (message, args)
		local channel = message.channel

		if not args or not is_string(args[1]) then
			-- errmsg, needs arguments passed!
			sendf(channel, "You need to specify a macro name, for instance `"..prefix.."macro raw \"macro name\"`")
			return
		end

		local passed_str = table.concat(args, " ")
		local macro_name, end_x = get_quoted_name_from_string(passed_str)

		if not macro_name then
			macro_name = passed_str
		end

		local macro = MacroManager:query_macro(macro_name)
		
		if not macro then
			sendf(channel, "No macro with the name %q found!", macro_name)
			return
		end

		macro_name = macro.name

		local field = macro.field
		if is_table(field) then field = field[1] end -- TODO navigator to display different pages?

		sendf(channel, field:discord_escape())
	end
))
macro_raw:set_name("Get the raw text for a macro")
macro_raw:set_description("Get the raw unformmated text of a macro, for easier editing.")
macro_raw:set_usage("`%smacro raw \"macro name\"`")
macro_raw:set_trigger("message", "raw")

local macro_new_tag = macro_command:set_sub_command(CM:new_command(
	"macro_new_tag",
	---@param message Message
	---@param args table
	function(message, args)
		local name, description = args.name, args.description

		MacroManager:new_tag(name, description)
		sendf(message.channel, "New tag with name %q created!", name)
	end
))
macro_new_tag:set_argument_parser(
	function (message, args)
		if not args or not is_string(args[1]) then
			return false, "You need to specify a tag name, for instance `"..prefix.."macro new_tag \"tag name\"`"
		end

		local passed_str = table.concat(args, " ")
		local tag_name, end_x = get_quoted_name_from_string(passed_str)

		if not tag_name then
			return false, "You need to wrap the name of the tag in quotes!"
		end

		if MacroManager:get_tag(tag_name) then
			return false, "There's already a tag with this name!"
		end

		local tag_description = get_quoted_name_from_string(passed_str:sub(end_x))

		if not tag_description then
			return false, "You need to wrap the description of the tag in quotes!"
		end

		return {
			name = tag_name,
			description = tag_description,
		}
	end
)
macro_new_tag:set_name("Create a new tag")
macro_new_tag:set_description("Create a new tag to assign to macros.")
macro_new_tag:set_trigger("message", "new_tag")
macro_new_tag:set_usage("`%smacro new_tag \"tag name\" \"tag description\"`.")

local macro_remove_tag = macro_command:set_sub_command(CM:new_command(
	"macro_remove_tag", 
	---@param message Message
	---@param args table
	function(message, args)
		---@type macro_obj
		local macro = args.macro

		---@type macro_tag
		local tag = args.tag
		local tag_name = tag.name

		if not macro.tags then macro.tags = {} end
		macro.tags[tag_name] = nil -- clear out that tag!

		sendf(message.channel, "Removed tag %q from macro %q!", tag, macro.name)
		save_data("macros")
	end
))
macro_remove_tag:set_argument_parser(
	function (message, args)
		if not args or not is_string(args[1]) then
			return false, "You need to specify a macro name, for instance `"..prefix.."macro remove_tag \"macro name\"`"
		end

		local passed_str = table.concat(args, " ")
		local macro_name, end_x = get_quoted_name_from_string(passed_str)

		if not macro_name then
			return false, quote_err
		end

		local macro = MacroManager:query_macro(macro_name)
		local tag_name = get_quoted_name_from_string(passed_str:sub(end_x))
		
		if not macro then
			return false, string.format("No macro with the name %q found!", macro_name)
		end

		if not tag_name then
			-- errmsg!
			return false, "You need to wrap the name of the tag to remove in quotes!"
		end

		local tag = MacroManager:get_tag(tag_name)
		if not tag then
			return false, "No tag found with the name "..tag_name.."!"
		end

		if not macro:has_tag(tag_name) then
			return false, "The macro specified doesn't have the tag ["..tag_name.."]."
		end

		return {
			macro = macro,
			tag = tag,
		}
	end
)
macro_remove_tag:set_name("Remove a macro tag.")
macro_remove_tag:set_description("Remove a tag from a macro, so that macro can no longer be retrieved using `?macro tag \"tag key\"`.")
macro_remove_tag:set_usage("`%smacro remove_tag \"Macro Name\" \"macro tag\"`")
macro_remove_tag:set_trigger("message", "remove_tag")

local macro_set_tag = macro_command:set_sub_command(CM:new_command(
	"macro_set_tag", 
	---@param message Message
	---@param args table
	function(message, args)
		---@type macro_obj
		local macro = args.macro
		---@type string
		local tag = args.tag

		if not macro.tags then macro.tags = {} end
		macro.tags[tag] = true

		sendf(message.channel, "Added tag %q to macro %q!", tag, macro.name)
		save_data("macros")
	end
))
macro_set_tag:set_argument_parser(
	function (message, args)
		if not args or not is_string(args[1]) then
			return false, "You need to specify a macro name, for instance `"..prefix.."macro set_tag \"macro name\"`"
		end

		local passed_str = table.concat(args, " ")
		local macro_name, end_x = get_quoted_name_from_string(passed_str)

		if not macro_name then
			return false, quote_err
		end

		local macro = MacroManager:query_macro(macro_name)
		local tag_name = get_quoted_name_from_string(passed_str:sub(end_x))
		
		if not macro then
			return false, string.format("No macro with the name %q found!", macro_name)
		end

		if not tag_name then
			return false, "You need to wrap the name of the tag to remove in quotes!"
		end

		if not MacroManager:get_tag(tag_name) then
			return false, "No tag exists with the name ["..tag_name.."]. You have to create it first using `?macro new_tag`"
		end

		return {
			macro = macro,
			tag = tag_name,
		}
	end
)
macro_set_tag:set_name("Set a macro tag.")
macro_set_tag:set_description("Set a tag for a macro, so that macro can be retrieved using `?macro tag \"tag key\"`.")
macro_set_tag:set_usage("`%smacro set_tag \"Macro Name\" \"macro tag\"`")
macro_set_tag:set_trigger("message", "set_tag")

local macro_tag = macro_command:set_sub_command(CM:new_command(
	"macro_tag",
	---@param message Message
	---@param args table
	function(message, args)
		---@type macro_tag
		local tag = args.tag

		MacroManager:display_tag(message, tag)
	end
))
macro_tag:set_argument_parser(
	function (message, args)
		local passed_str = table.concat(args, " ")
		local tag_name = get_quoted_name_from_string(passed_str)
		if not is_string(tag_name) then
			tag_name = passed_str
		end

		local tag = MacroManager:get_tag(tag_name)
		if not tag then
			return false, "There's no tag available with the name "..tag_name.."!"
		end

		return {
			tag = tag
		}
	end
)
macro_tag:set_name("View tag")
macro_tag:set_description("View every macro with the tag provided. You can see all available tags using `?macro tags`, or you can use `?macro \"Macro Name\" to view any macro within this function.")
macro_tag:set_usage("`%smacro tag \"tag name\"`")
macro_tag:set_trigger("message", "tag")

local macro_tags = macro_command:set_sub_command(CM:new_command(
	"macro_tags",
	---@param message Message
	---@param args table<number, string>
	function(message, args)
		MacroManager:display_all_tags(message)
	end
))
macro_tags:set_argument_parser(
	---@param message Message
	---@param args table<number, string>
	function (message, args)
		return args
	end
)
macro_tags:set_name("View all tags")
macro_tags:set_description("View every tag currently available. You can see all macros with a tag by using `?macro tag \"tag name\"`.")
macro_tags:set_usage("`%smacro tags`")
macro_tags:set_trigger("message", "tags")

local macro_details = macro_command:set_sub_command(CM:new_command(
	"macro_details",
	---@param message Message
	---@param args table
	function(message, args)
		---@type macro_obj
		local macro = args.macro

		MacroManager:display_macro_details(message, macro)
	end
))
macro_details:set_argument_parser(
	---@param message Message
	---@param args table<number, string>
	function (message, args)
		local passed_str = table.concat(args, " ")
		local macro_name = get_quoted_name_from_string(passed_str)
		if not macro_name then
			macro_name = passed_str
		end

		local macro = MacroManager:query_macro(macro_name)
		if not macro then
			return false, "No macro found with the name \"" .. macro_name .. "\"!"
		end

		return {
			macro = macro,
		}
	end
)
macro_details:set_name("Macro Details")
macro_details:set_description("Show the full details - owner, tags, use numbers, etc., - of the specified macro.")
macro_details:set_usage("`%smacro details \"Macro Name\"`")
macro_details:set_trigger("message", "details")

local macro_mine = macro_command:set_sub_command(CM:new_command(
	"macro_mine",
	function(message, args)
		MacroManager:display_mine_macros(message)
	end
))
macro_mine:set_name("Display Your Macros")
macro_mine:set_description("Use this command to display every macro that ye have claimed.")
macro_mine:set_usage("`%smacro mine`")
macro_mine:set_trigger("message", "mine")

local macro_unowned = macro_command:set_sub_command(CM:new_command(
	"macro_unowned",
	function(message, args)
		MacroManager:display_unowned_macros(message)
	end
))
macro_unowned:set_name("Display Unclaimed Macros")
macro_unowned:set_description("Use this command to display every macro that doesn't have an owner.")
macro_unowned:set_usage("`%smacro unclaimed`")
macro_unowned:set_trigger("message", "unclaimed")

local macro_owned = macro_command:set_sub_command(CM:new_command(
	"macro_owned",
	function(message, args)
		MacroManager:display_owned_macros(message)
	end
))
macro_owned:set_name("Display Claimed Macros")
macro_owned:set_description("Use this command to display every macro that has an owner.")
macro_owned:set_usage("`%smacro claimed`")
macro_owned:set_trigger("message", "claimed")

MacroManager:init()