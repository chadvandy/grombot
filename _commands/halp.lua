local discordia = require("discordia")
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

--[[
-- A function to:
	- grab a command by the specified key, OR
	- grab a category by the specified key

-- A function to:
	- display all categories, if nothing is provided
	- display a command and all subcommands, as well as master description
--]]

--- Display every category, on the main page.
---@param channel TextChannel
local function full_display(channel)
	local navigator = PM.new("help_all", channel)
	navigator:set_title("Categories")
	navigator:set_description("Use `?help [command]` for more info on a command.\nUse `?help [category]` for more info on a category.")
	navigator:set_fields_per_page(6)

	local all_fields = {}
	local categories = CM:get_categories()

	for key, category in pairs_by_keys(categories) do
		all_fields[#all_fields+1] = category:get_embed_field()
	end

	navigator:set_fields(all_fields)
	navigator:start()
end

--- Display every command within a category!
---@param channel TextChannel
---@param category command_category
local function category_display(channel, category)
	local navigator = PM.new("help_cat", channel)
	navigator:set_title(category:get_name())
	navigator:set_description(category:get_description())
	navigator:set_fields_per_page(8)

	local all_fields = {}
	local commands = category:get_commands()
	for i = 1, #commands do
		printf("Checking for command %q", commands[i])
		local command = CM:get_command(commands[i])
		if command then
			all_fields[#all_fields+1] = command:get_embed_field(false)
		end
	end

	navigator:set_fields(all_fields)
	navigator:start()
end

--- Display a command and all subcommands!
---@param channel TextChannel
---@param command command
local function command_display(channel, command)
	local navigator = PM.new("help_com", channel)
	navigator:set_title(command:get_name())
	navigator:set_description(command:get_master_description())
	navigator:set_fields_per_page(6)

	navigator:add_field({name="Usage", value=command:get_usage()})

	if command:has_sub_commands() then
		local subcommands = command:get_sub_commands()
		local names = {}
		for key, subcommand in pairs(subcommands) do
			names[#names+1] = "`"..subcommand:get_trigger().."`"
		end

		local cm_trigger = command:get_trigger()

		local this_command = command
		while is_string(this_command._master_command) do
			this_command = CM:get_command(this_command._master_command)
			cm_trigger = string.format("%s %s", this_command:get_trigger(), cm_trigger)
		end

		local v = "Use `?help "..cm_trigger.." subcommand`, where you replace 'subcommand' with the subcommand's name, to get information about the subcommands!\n\n" .. table.concat(names, " ")

		navigator:add_field({name = "Subcommands", value = v})
	end

	-- navigator:add_field(command:get_embed_field(true))
	navigator:start()
end


---@param args table<number, string>
---@param message Message
local help = CM:new_command("help", function(message, args)
	-- printf("Help called, passing forth the msg")
	-- help:new_prompt_instance(message, "all")

	local channel = message.channel

	if args.all then
		full_display(channel)
	elseif args.category then
		category_display(channel, args.category)
	elseif args.command then
		command_display(channel, args.command)
	end

	-- local navigator = PM.new("help_all", channel)

	-- navigator:set_title("GromBot Commands")
	-- navigator:set_description("List of valid commands for GromBot.")
	-- navigator:set_fields_per_page(5)

	-- local test = args[1]
	-- local commands = CM:get_valid_commands_for_member(message, test)

	-- if is_table(commands) then
	-- 	local all_fields = {}
	-- 	printf("Number of commands found: "..#commands)
	
	-- 	for i = 1, #commands do
	-- 		local command = commands[i]
	-- 		all_fields[#all_fields+1] = command:get_embed_field()
	-- 	end

	-- 	navigator:set_fields(all_fields)
	-- 	navigator:start()
	-- elseif is_string(commands) then
	-- 	-- TODO format this a bit betta
	-- 	message.channel:send(commands)
	-- else
	-- 	-- errmsg?
	-- end
end)
help:set_name("Help")
help:set_description("This is your generic help function. Displays all commands and how to use 'em!")
help:set_usage("`%shelp`, but you already know that if you're reading this.")
help:set_trigger("message", "help")
help:set_category("Utility")
help:set_argument_parser(
	---@param message Message
	---@param args table<number, string>
	---@return table|boolean
	function (message, args)
		-- display all commands, if no args are passed!
		if not args[1] or args[1] == "" then
			printf("No arg found, doing all!")
			return {all=true}
		end

		local test = args[1]

		-- first, test if args[1] is a category!
		local category = CM:get_category(test)
		if category then
			return {category=category}
		end

		-- otherwise, try to get a command (and any subcommands if specified!)
		local command = CM:get_command(test:lower())

		if command then
			-- if there's any specified subargs, check those too!
			for i = 2, #args do
				test = command:check_sub_command_by_trigger(args[i])
				if test then
					command = test
				end
			end

			return {command=command}
		end

		return false, "No category or command found!"
	end
)