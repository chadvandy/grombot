--- TODO command wrapper object. Payload data w/ methods and etc.
--- Slash Commands

---@type discordia
local discordia = require("discordia")

---@type Client
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

    ---@type SubcommandGroup[]
    subcommand_groups = {},

    ---@type Command[]
    subcommands = {},

    is_holder = false,

    is_global = false,

    is_testing = false,

    ---@type string[]
    guilds = {"531219831861805067"},

    permissions = {},
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

function Command:dev(b)
    if b == false then
        self.is_testing = true

        self.is_global = true
        self.guilds = {}
    else
        self.is_testing = true
    
        self.is_global = false
        self.guilds = {"531219831861805067"}
    end
end

function Command:disable_by_default(b)
    self.payload.default_member_permissions = "0"
end

function Command:set_moderator_only()
    local perm = bit.lshift(1, 2)
    self.payload.default_member_permissions = tostring(perm)
end

--- Call :deploy() when any changes are made to a command's parameters.
---@param is_global any
---@param guilds any
function Command:deploy(is_global, guilds)
    
end

function Command:set_global(b)
    if is_nil(b) then b = true end

    if not is_boolean(b) then return end

    self.is_global = b
end

function Command:get_global() return self.is_global end

function Command:set_guilds(t)

end

function Command:get_guilds()
    return self.guilds
end

function Command:add_to_guild(gId)
    if not is_string(gId) then return end

    local guild = client:getGuild(gId)
    if not guild then
        return
    end

    self.guilds[#self.guilds+1] = gId

    if InteractionManager.is_init then
        InteractionManager:add_command_to_guild(self, gId)
    end
end

function Command:set_description(description)
    assert(is_string(description), "")

    self.payload.description = description
    return self
end

---@param intType ApplicationCommandTypes|number
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

    return self
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

---@return SubcommandGroup
function Command:add_subcommand_group(name, desc)
    local o = InteractionManager.SubcommandGroup:new(name, desc)

    self.is_holder = true

    self.subcommand_groups[#self.subcommand_groups+1] = o

    return o
end

function Command:add_subcommand(name, desc)
    local o = InteractionManager.Command:new(name, desc)
    o:set_type(1)

    self.is_holder = true

    self.subcommands[#self.subcommands+1] = o

    return o
end

function Command:get_subcommand_group(name)
    for _, subcommand_group in ipairs(self.subcommand_groups) do
        if subcommand_group.payload.name == name then
            return subcommand_group
        end
    end
end

function Command:get_subcommand(name)
    for _, subcommand in ipairs(self.subcommands) do
        if subcommand.payload.name == name then
            return subcommand
        end
    end
end

function Command:get_option(k)
    for i,opt in ipairs(self.options) do
        if opt.payload.name == k then
            return opt
        end
    end
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
    for _, option in ipairs(options) do
        payload.options[#payload.options+1] = option:get_payload()
    end

    for _, subcommand_group in ipairs(self.subcommand_groups) do
        payload.options[#payload.options+1] = subcommand_group:get_payload()
    end

    for _, subcommand in ipairs(self.subcommands) do
        payload.options[#payload.options+1] = subcommand:get_payload()
    end

    return payload
end

return Command