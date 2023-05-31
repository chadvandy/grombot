local discordia = require("discordia")
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local Super = InteractionManager.CommandOption
local Command = InteractionManager.Command

---@class SubcommandGroup : CommandOption
---@field __new fun():SubcommandGroup
local defaults = {
    payload = {
        type = 2,

        ---@type string #The Name for this group.
        name = "",
    
        ---@type string #The description!
        description = "",
        
    },
    -- ---@param int Interaction
    -- ---@param args table<string, any> K/V table of option keys and passed values.
    -- callback = function(int, args) int:reply("This command hasn't been completed yet!") end,

    ---@type Command #The Command that owns this subcommand group.
    parent_command = {},

    ---@type Command[] #Internal subcommands for this group.
    subcommands = {},
}

---@class SubcommandGroup : CommandOption
local SubcommandGroup = Super:extend("SubcommandGroup", defaults)

function SubcommandGroup:new(name, desc)
    local o = self:__new()
    Super.init(o, name, desc)
    
    o:init()

    return o
end

function SubcommandGroup:init()
    self.payload.options = {}
    self.payload.type = 2

    self.subcommands = {}
end

function SubcommandGroup:add_subcommand(name, desc)
    local o = Command:new(name, desc)
    o:set_type(1)

    self.subcommands[#self.subcommands+1] = o

    return o
end

function SubcommandGroup:get_subcommand(name)
    for i, subcommand in ipairs(self.subcommands) do
        if subcommand.payload.name == name then
            return subcommand
        end
    end
end

function SubcommandGroup:get_payload()
    local p = self.payload

    for i, v in ipairs(self.subcommands) do
        p.options[i] = v:get_payload()
    end

    return self.payload
end

return SubcommandGroup