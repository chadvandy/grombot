local discordia = require("discordia")
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local FS = require("fs")

---@class InteractionManager
local InteractionManager = {
    ---@type table<string, Command>
    _commands = {},
}

discordia.storage.InteractionManager = InteractionManager

InteractionManager.enums = require("./enums")

---@type Command
InteractionManager.Command = require("./command/")

---@type CommandOption
InteractionManager.CommandOption = require("./option/")


---@return integer|boolean
function InteractionManager:is_enum(enum_type, ind)
    local enums = self.enums[enum_type]

    for i, v in ipairs(enums) do
        if is_number(ind) and i == ind then return i end
        if is_string(ind) and v == ind then return i end
    end

    return false
end

---comment
---@param name string Name of the command
---@param description string Description of the command
---@param interaction_type ApplicationCommandTypes
---@return Command
function InteractionManager:new_command(name, description, interaction_type)
    if not interaction_type then
        interaction_type = "CHAT_INPUT"
    end

    local command = self.Command:new(name, description):set_type(interaction_type)
    self._commands[name] = command

    print("Adding command " .. name .. " to IM!")

    return command
end

function InteractionManager:new_command_option(name, description)
    local option = self.CommandOption:new(name, description)
    return option
end

-- TODO loop through each scr/interactions/commands/ file and init them
function InteractionManager:init()
    print("Starting IM:init()")
    for file_name, file_type in FS.scandirSync("src/interactions/commands") do
        local path = "src/interactions/commands/" .. file_name
        if file_type == "file" then
            -- local file = FS.readFileSync(path)
            print("Loading IM command: " .. path)

            local command, errMsg = loadfile(path, "bt", getfenv(1))

            if command and is_function(command) then
                ---@type Command
                local command_obj = command()

                if command_obj then
                    client:createGlobalApplicationCommand(command_obj:get_payload())
                end

            else
                -- Error loading command!
                errmsg("Error loading command!\n" .. errMsg)
            end
        end
    end
end

function InteractionManager:process_interaction(int, cmd, args)
    local command = self._commands[cmd.name]
    command:process(int, args)
end

return InteractionManager