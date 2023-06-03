---@type Client
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local FS = require("fs")

---@class InteractionManager
local InteractionManager = {
    ---@type table<string, Command>
    _commands = {},

    ---@type table<string, Interaction.Modal>
    _modals = {},

    is_init = false,

    _components = {
        ---@type table<string, Interaction.Button>
        Button = {},
        ---@type table<string, Interaction.Menu>
        Menu = {},
    },

    ---@type table<string, Navigation>
    _navs = {},
}

discordia.storage.InteractionManager = InteractionManager


InteractionManager.enums = require("./enums")

---@type Command
InteractionManager.Command = require("./command/")

---@type CommandOption
InteractionManager.CommandOption = require("./option/")

---@type CommandOptionChoice
InteractionManager.CommandOptionChoice = require ("./option/choice/")

---@type SubcommandGroup
InteractionManager.SubcommandGroup = require("./option/subcommand_group")

---@type Interaction.Modal
InteractionManager.Modal = require ("./modal")

InteractionManager.Components = {
    Holder = require ("./components/holder"),
    Menu = require ("./components/menu"),
    Button = require ('./components/button')
}

InteractionManager.Navigation = require("./navigation")


---@return integer|boolean
function InteractionManager:is_enum(enum_type, ind)
    local enums = self.enums[enum_type]

    for i, v in ipairs(enums) do
        if is_number(ind) and i == ind then return i end
        if is_string(ind) and v == ind then return i end
    end

    return false
end

--- create a button template that can be applied wherever, and have the same callback.
function InteractionManager:create_button_template(template_key)
    local btn = self.Components.Button:new(template_key)
    self._components["Button"][template_key] = btn

    return btn
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

---@param command Command
---@param guild_id Snowflake|string
function InteractionManager:add_command_to_guild(command, guild_id)
    local ok, err = client:createGuildApplicationCommand(guild_id, command:get_payload())
    if not ok then
        errmsg(err)
    else
        command.id = ok._application_id
        command.version = ok._version
    end
end

---@param command Command
---@param guild Guild
function InteractionManager:remove_command_from_guild(command, guild)
    local gId = guild.id
    local id = command.id

    if id then
        inform("Trying to remove Command " .. command.id .. " from guild whatever")

        local ok, err = client:deleteGuildApplicationCommand(gId, id)
        if not ok then
            errmsg(err)
        end
    end
end

function InteractionManager:add_global_command(command)
    local ok,err = client:createGlobalApplicationCommand(command:get_payload())
    if not ok then
        errmsg(err)
    end
end

---@param cmd Command
function InteractionManager:edit_global_command(cmd)
    if is_nil(cmd.id) then return end

    local ok, err = client:editGlobalApplicationCommand(cmd.id, cmd:get_payload())

    if not ok then
        errmsg("Trying to edit global command, but it failed!\n" .. err)
    end
end

function InteractionManager:get_global_command(cmd)
    if is_nil(cmd.id) then return end

    local ok, err = client:getGlobalApplicationCommand(cmd.id)

    if not ok then
        return errmsg("Trying to get global command w/ ID [" .. cmd.id .. "], but failed!\n" .. err)
    end

    return ok
end

---@return Interaction.Button
function InteractionManager:get_button_template(component_key)
    return self._components.Button[component_key]
end

function InteractionManager:get_menu_template(component_key)
    return self._components.Menu[component_key]
end

-- TODO loop through each scr/commands/ file and init them
function InteractionManager:init()
    print("Starting IM:init()")
    -- Load up all template components.
    for file_name, file_type in FS.scandirSync("src/component_templates") do
        local path = "src/component_templates/" .. file_name
        if file_type == "file" then
            local comp, err = loadfile(path, "bt", getfenv(1))

            if comp and is_function(comp) then
                comp()

                -- if component then
                --     self:add_component_template(component)
                -- end
            end
        end
    end

    for file_name, file_type in FS.scandirSync("src/commands") do
        local path = "src/commands/" .. file_name
        if file_type == "file" then
            -- local file = FS.readFileSync(path)
            print("Loading IM command: " .. path)

            local command, errMsg = loadfile(path, "bt", getfenv(1))

            if command and is_function(command) then
                ---@type Command
                local command_obj = command()

                if command_obj then
                    if command_obj:get_global() then
                        local cmd = self:get_global_command(command_obj)

                        if cmd then
                            self:edit_global_command(command_obj)
                        else
                            self:add_global_command(command_obj)
                        end
                    else
                        for i, guild_id in ipairs(command_obj:get_guilds()) do
                            -- self:add_command_to_guild(command_obj, guild_id)
                        end
                    end

                    -- remove from dev channel if not set to dev
                    if command_obj.is_testing and command_obj.is_global then
                        self:remove_command_from_guild(command_obj, client:getGuild("531219831861805067"))
                    end
                end
            else
                -- Error loading command!
                errmsg("Error loading command!\n" .. errMsg)
            end
        end
    end

    print("IM:init() completed!")
    self.is_init = true
end

function InteractionManager:create_navigation()

    local nav = self.Navigation:new()
    -- self._navs[id] = nav

    return nav
end

function InteractionManager:get_navigation(msg_id)
    return self._navs[msg_id]
end

function InteractionManager:create_modal(custom_id, title)
    local modal = self.Modal:new(custom_id, title)

    self._modals[custom_id] = modal

    return modal
end

---@alias ComponentType 1|2|3|4|5|6|7|8
---@alias InteractionModalData {custom_id:string, components:ComponentData[]}
---@alias ComponentData {type: ComponentType, custom_id: string}
---@alias RowComponentData {type: 1, components:ComponentData[]}

---@alias ButtonComponentData {type: 2, style: 1|2|3|4|5, label:string?}
---@alias TextComponentData {type:4, style:1|2, label:string, value:string, required:boolean?, min_length: number, max_length: number}

---@param int Interaction
---@param data table
---@param args table
function InteractionManager:process_modal(int, data, args)

    local custom_id = data.custom_id
    local modal = self._modals[custom_id]

    if not modal then
        errmsg("No Modal found with custom id " .. custom_id)
        return
    end

    modal:process(int, args)
    -- int:reply("Cool thanks!")
end

--- Process a Message Component Interaction. Text inputs, buttons, and menus. 
---@param int Interaction
---@param data table
function InteractionManager:process_component(int, data)
    local t = data.component_type
    local id = data.custom_id
    local values = data.values

    if id then
        if is_number(t) then
            if t == 2 then
                -- we've got a button!
                local btn = self:get_button_template(id)
                if btn then
                    btn:callback(int)
                end
            elseif t == 3 or t >= 5 and t <= 8 then
                -- we've got a menu!
            elseif t == 4 then
                -- text input!
            end
        end
    end
end

function InteractionManager:get_slash_command_from_data(data, args)
    local cmd_name = data.name
    if not cmd_name then return end

    local command = self._commands[cmd_name]
    if not command then return end

    -- This is a "Holder" command, we want to get the subcommand triggered.
    if command.is_holder then
        local option = data.options[1]

        -- inform("Getting options for holder command: " .. fast_print(option))

        -- This is a subcommand group!
        if option.type == 2 then
            args = args[option.name]
            -- inform("Args breakdown subcommandgroup: " .. fast_print(args))
            local subcommand_group = command:get_subcommand_group(option.name)
            
            -- Get the first option within the subcommand group, which should be the subcommand.
            local subcommand_opt = option.options[1]
            local subcommand = subcommand_group:get_subcommand(subcommand_opt.name)
            args = args[subcommand_opt.name]

            return subcommand, args
        end

        -- This is an internal subcommand!
        if option.type == 1 then
            args = args[option.name]
            
            -- inform("Args breakdown subcommand: " .. fast_print(args))
            local subcommand = command:get_subcommand(option.name)
            return subcommand, args
        end
    else
        return command, args
    end
end

function InteractionManager:process_autocomplete(int, data, focused, args)
    local command, args = self:get_slash_command_from_data(data, args)
    if not command then return end

    local option = command:get_option(focused.name)
    if option and option:is_autocomplete() then
        option:handle_autocomplete(int, data, focused.value)
    end
end

function InteractionManager:process_slash_command(int, data, args)
    local command, args = self:get_slash_command_from_data(data, args)
    if not command then return end
    if not args then args = {} end

    command:process(int, args)
end

return InteractionManager