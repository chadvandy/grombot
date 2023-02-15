print("requiring CM")

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata

---@class command_manager
---@field _commands table<string, command>
---@field _triggers table<string, string>
---@field _directory string
local command_manager = {
    -- k/v, command KEYS to commands. keys are irrelevant to the user
    _commands = {},

    -- list of all categories 
    _categories = {
        -- example_category = {name="Name", desc="The description", commands = {"command1", "command2"}}
    },

    -- k/v, triggers to command keys
    _triggers = {},

    -- directory to auto-load commands!
    _directory = "_commands/"
}

---@class command
local command_prototype = {}

---@class command_category
local command_category = {
    _name = "No Name Found!",
    _description = "No Description Found!",
    _commands = {},
}

function command_category:new(o)
    o = table.copy_add(
        is_table(o) and o or {},
        command_category
    )
    setmetatable(o, {__index = command_category})

    return o
end

---@type command
TEMPLATES.command = {
    _key = "",
    _callback = function() end,
    _arg_parse = function(message, args) return args end,

    ---@type table<string, command>
    _subcommands = {},
    _master_command = nil,

    -- how it's triggered - text or reaction
    _trigger_type = false,

    -- available triggers
    _triggers = {},

    -- tags to grab and set tags on a command, for help and similar
    _tags = {},

    -- TODO remove this and make it prettier
    _internal_only = false,

    -- localisation for help and otherwise
    _name = "Default Command Name",
    _description = "Command Description",
    _usage = "Command Usage",
}

function command_prototype:__tostring()
    return "COMMAND " .. self._key
end

---@return command
function command_prototype:new()
    -- if not key then key = "" end -- errmsg!
    ---@type command
    local o = {}
    o = setmetatable(o,
        {
            __index = command_prototype,
            __tostring = function(self) return "COMMAND "..self._key end
        }
    )

    o = table.copy_add(o, TEMPLATES.command)

    return o
end

function command_prototype:set_callback(cb)
    if not is_function(cb) then return end

    self._callback = cb
end

function command_category:add_command(command_key)
    if not is_string(command_key) then return end
    self._commands[#self._commands+1] = command_key
end

function command_category:get_name()
    return self._name
end

function command_category:get_description()
    return self._description
end

function command_category:get_commands()
    return self._commands
end

function command_category:get_embed_field()
    local field = {
        name = self:get_name(),
        value = self:get_description(),
        inline = false,
    }

    local commands = self:get_commands()
    local commands_str = {}
    for i = 1, #commands do
        local command = CM:get_command(commands[i])
        commands_str[#commands_str+1] = "`"..command:get_trigger().."`"
    end

    table.sort(commands_str)

    field.value = field.value .. "\n" .. table.concat(commands_str, " ")
    return field
end

--- Returns the first trigger available for this command.
---@return string
---@return boolean
function command_prototype:get_trigger()
    return next(self._triggers)
end

----------------
---Set the localised name for the command
---@param str string
---@return command
function command_prototype:set_name(str)
    if not is_string(str) then return self end

    self._name = str

    return self
end

function command_prototype:get_name()
    return self._name
end

function command_prototype:get_key()
    return self._key
end

---comment
---@param self command
---@param str string
---@return command
function command_prototype:set_usage(str)
    if not is_string(str) then return self end

    self._usage = str

    return self
end

function command_prototype:get_usage()
    -- TODO handle prefix better if it's different!
    return is_string(self._usage) and string.format(self._usage, prefix)
end

-- Description in the commands prompt, explains what the command is
---comment
---@param self command
---@param str string
---@return command
function command_prototype:set_description(str)
    if not is_string(str) then return self end

    self._description = str

    return self
end

function command_prototype:get_description()
    return self._description
end

--- validity check as well as a return of a k/v table with all relevant args
---@param message Message
---@return table<number, string>
function command_prototype:parse_arguments(message, args)
    printf("Parsing args for command %q, msg is %q", self._key, message.content)

    if is_function(self._arg_parse) then
        printf("Calling arg parser!")
        return self._arg_parse(message, args)
    end

    return args
end

function command_prototype:check_sub_command_by_trigger(str)
    if not is_string(str) then return end
    local subcommands = self._subcommands
    
    for key, command in pairs(subcommands) do
        printf("Testing %q for trigger %q", key, str)
        if command._triggers[str] == true then
            for k,v in pairs(command._triggers) do
                printf("Found trigger %q in command %q", k, key)
            end
            return command
        end
    end
end

---@param command command
---@return command
function command_prototype:set_sub_command(command)
    printf("Adding subcommand %q to command %q", command._key, self._key)
    if self._subcommands[command._key] then
        printf("Trying to add a subcommand with key %q to command %q, but this already exists!", command._key, self._key)
        return false
    end

    self._subcommands[command._key] = command
    command._master_command = self._key

    return command
end

--- Validity check is called before a command is executed; it determines if a member is able to perform a specified command.
---@param callback fun(member: Member): boolean The function passed forth to determine the validity. Only takes a member.
---@return command
function command_prototype:set_validity_check(callback)
    if not is_function(callback) then
        -- errmsg
        return self
    end

    self._validation_check = callback

    return self
end

--- Argument parser. This is called after a command is triggered - it takes the live message, divides it up into expected arguments, and passes them back to the actual command callback. If none is provided, the command callback is sent the message.
--- If any unexpected parameters are found within the argument parser, an error message is returned instead, to print out the issue.
---@param callback fun(message: Message, args: table<number, string>): table|string
---@return command
function command_prototype:set_argument_parser(callback)
    if not is_function(callback) then
        -- errmsg
        return self
    end

    self._arg_parse = callback

    return self
end

---@param trigger_type '"reaction"'|'"message"' The type of trigger expected for this command.
function command_prototype:set_trigger_type(trigger_type)
    if not is_string(trigger_type) then
        -- errmsg
        return self
    end

    if trigger_type ~= "reaction" and trigger_type ~= "message" then
        -- errmsg, this type of trigger is unsupported!
        return self
    end

    self._trigger_type = trigger_type

    return self
end

-- TODO, this needs to act differently if this is a subcommand!
--- The trigger for this command; can be a reaction or a message.
---@param trigger_type '"reaction"'|'"message"' The type of trigger expected for this command.
---@param value string The trigger. Can either be the message expected post-prefix, or the reaction ID.
---@return command self Returns the command itself.
function command_prototype:set_trigger(trigger_type, value)
    if not is_string(trigger_type) then
        -- errmsg
        return self
    end

    if trigger_type ~= "reaction" and trigger_type ~= "message" then
        -- errmsg, this type of trigger is unsupported!
        return self
    end

    if not is_string(value) then
        -- errmsg
        return self
    end

    if command_manager._triggers[value] then
        -- errmsg, this trigger is already set on another command!
        -- printf("Trying to give trigger %q to CM for command %q, but it's already used by another command.", value, self._key)
        self._triggers[value] = true
        return self
    end

    printf("Assigning trigger %q to CM for command %q", value, self._key)
    
    self._triggers[value] = true
    command_manager._triggers[value] = self._key

    return self
end

--- Grab a formatted string of all tags available for this command, if any
function command_prototype:get_tags()
    if self._tags and next(self._tags) then
        local tags = {}
        for k,_ in pairs(self._tags) do
            tags[#tags+1] = k
        end

        local str = "**Tag:** "

        if #tags > 1 then
            str = "**Tags:** " .. table.concat(tags, ", ")
        else
            str = str .. tags[1]
        end
        
        return str
    end

    return nil
end

-- TODO use include sub commands?
-- return a table with keys "name" and "value" for this command
-- will have multiple tables if including sub commands
function command_prototype:get_embed_field(full_display)
    if is_nil(full_display) then full_display = false end

    local name = self:get_name()
    local desc = self:get_description()

    -- if full_display then
        local usage = self:get_usage()
        local tags = self:get_tags()

        if usage then
            desc = desc .."\n**Usage**: " .. usage
        end
        
        if tags then
            desc = desc .. "\n" .. tags
        end
    -- end

    return {name = name, value = desc}
end

--- Execution node on the command proper. Can be called internally on triggers, or through other means (Prompts and otherwise)
---@param message Message The message that triggered this. TODO make this work for reactions? :)
---@vararg any Any other arguments necessary for the command.
function command_prototype:execute(message, args)
    printf("Executing command %q w/ message %q", self._key, message.content)
    local can,err = self:check_validity(message.member)
    
    printf("Command found. Can do: "..tostring(can))
    if not can then
        if is_string(err) then
            message.channel:send(err)
        else
            message.channel:send("You cannot use this command, for reasons unknown. Yell at <@364410374688342018> to make an error message here.")
        end

        return
    end

    if not args then
        args = message.content:split(" ")
    end

    printf("Removing arg %q", args[1])
    table.remove(args, 1)
    printf("New first arg: %q", tostring(args[1]))

    printf("Executing %s.", self._key)
    local sub = self:check_sub_command_by_trigger(args[1])

    if sub then
        printf("Sub command [%s] found within %q.", sub._key, self._key)
        printf("Is internal only: "..tostring(sub._internal_only))
    
        if not sub._internal_only then
            -- table.remove(args, 1)
            sub:execute(message, args)
            return
        end
    end

    local errr

    args, errr = self:parse_arguments(message, args)
    if not is_table(args) then
        if is_string(errr) then
            message.channel:send(errr)
        else
            message.channel:send("You cannot use this command, because of invalid parameters. Yell at <@364410374688342018> to make a better error message here.")
        end

        return
    end

    printf("Calling command %q with %d args", self._key, #args)
    for i = 1, #args do printf("Arg %d is %q", i, args[i]) end
    self:get_callback()(message, args)
end

---This is used to verify that a MEMBER or USER can use this command. Does not check arguments or anything like that.
---@param member Member
---@return boolean
function command_prototype:check_validity(member)
    if not CLASS.isInstance(member, CLASS.classes.Member) then
        -- errmsg
        return false
    end
    
    if self._validation_check then
        return self._validation_check(member)
    end

    return true
end

---comment
---@return fun(msg: Message, args: table<number, string>)
function command_prototype:get_callback()
    return self._callback
end

-- makes it so this command will only be called within code
-- will never be called via the messageCreate auto-trigger
-- will never be called via the sub-command loader in command:execute()
function command_prototype:set_internal_only(b)
    if is_nil(b) then b = true end

    self._internal_only = b
    return self
end

---@return command
function command_prototype:get_sub_command(str)
    if not is_string(str) then return end
    printf("Checking %q for subcommand with key %q", self._key, str)
    return self._subcommands[str]
end

function command_prototype:get_sub_commands()
    return self._subcommands
end

function command_prototype:has_sub_commands()
    return next(self._subcommands) ~= nil
end

---@return command
function command_manager:get_command(name)
    if not type(name) == "string" then
        -- errmsg
        return false
    end

    local command = self._commands[name]

    if not command then
        -- errmsg, none found
        return false
    end

    return command
end

--- TODO make this work for subcommands! ??? 
--- Check a string trigger.
---@param str string The command string passed.
function command_manager:check_trigger(str)
    if not is_string(str) then
        -- errmsg
        return false
    end

    local trigger = self._triggers[str]
    if not trigger then
        -- nothing found with that trigger
        return false
    end

    local command = self:get_command(trigger)
    if not command then
        -- trigger found, but no command found? ERROR
        return false
    end

    return command
end

-- create a new command
---@param key string
---@param callback fun(msg: Message, args: table<number, string>)
---@return command
function command_manager:new_command(key, callback)
    if not is_string(key) then
        -- errmsg
        return false
    end

    if not is_function(callback) then
        -- errmsg
        return false
    end

    if self._commands[key] then
        printf("Trying to create a new command with key %q, but one already exists with that key!", key)
        return false
    end

    local command = command_prototype:new()

    -- TODO hook these betterer?
    command._key = key
    command._callback = callback
    command._triggers = {}

    self._commands[key] = command

    -- printf("New command created with key %q. Next trigger is: ", key, tostring(next(command._triggers)))

    return command
end

---@return table<number, command>
function command_manager:get_commands_by_tag(tag_key)
    printf("Testing command manager for commands with tag %q", tag_key)
    local ret = {}
    local commands = self._commands
    for _, command in pairs(commands) do
        if command._tags[tag_key] then
            printf("Command %q has tag %q!", _, tag_key)
            ret[#ret+1] = command
        end
    end

    return ret
end

--- for ?help
---@param message Message The message object, to read the member and pass along for validity checks.
---@param command_key string|nil If one is provided, this will grab the specified command and all sub commands. Otherwise, all valid commands.
---@return table<number,command> commands
function command_manager:get_valid_commands_for_member(message, command_key)
    local member = message.member

    if not member then
        -- errmsg
        return false
    end

    -- local commands = self._commands

    -- if the command key passed is valid, only pass along that command and its children
    if is_string(command_key) then
        local command = self:get_command(command_key)
        if command then
            if command:check_validity(member) then
                local commands = {command}

                for _, subcommand in pairs(command._subcommands) do
                    commands[#commands+1] = subcommand
                end

                return commands
            end
        else
            -- test if it was a trigger!
            local command = self:check_trigger(command_key)
            if command then
                if command:check_validity(member) then
                    local commands = {command}

                    for _, subcommand in pairs(command._subcommands) do
                        commands[#commands+1] = subcommand
                    end
    
                    return commands
                end
            else
                -- it may have been a tag!
                local test = self:get_commands_by_tag(command_key)
                if #test ~= 0 then
                    local commands = {}
                    for i = 1, #test do
                        local command = test[i]
                        if command:check_validity(member) then
                            commands[#commands+1] = command
                        end
                    end
                    return commands
                end
            end
        end

        -- error, no command found!
        return "No command found with the name provided - \""..command_key.."\""
    end

    local commands = {}

    -- pass along all commands
    for key,command in pairs(self._commands) do
        -- only check master level commands (this check looks to see if this command HAS a master command, I know that's confusing)
        -- also prevents any prompt commands from being presented here, they're handled separately
        printf("Checking all commands, at %q. Master command %q", command._key, tostring(command._master_command))
        if not command._master_command then
            printf("Adding %q to list of commands. Verifying!", command._key)
            if command:check_validity(member) then
                printf("%q is valid, adding to list.", command._key)
                commands[#commands+1] = command
            end
        end
    end

    return commands
end

-- used solely for master commands in ?help
function command_prototype:set_master_description(str)
    if not is_string(str) then
        -- errmsg
        return false
    end

    self._master_description = str

    return self
end

function command_prototype:get_master_description()

    return self._master_description or self:get_description()
end

function command_manager:new_category(name, description)
    if self._categories[name] then return self._categories[name] end
    
    if not is_string(name) then
        -- errmsg
        return false
    end

    if not is_string(description) then
        -- errmsg
        return false
    end

    self._categories[name] = command_category:new({_name = name, _description = description})
    return self._categories[name]
end

---comment
---@param name string
---@return command_category
function command_manager:get_category(name)
    return is_string(name) and self._categories[name]
end

function command_manager:get_categories()
    return self._categories
end

---@param category_key AvailableCategories
---@return command
function command_prototype:set_category(category_key)
    if not is_string(category_key) then return self end
    if not command_manager:get_category(category_key) then return self end

    local cat = command_manager:get_category(category_key)
    cat._commands[#cat._commands+1] = self:get_key()

    return self
end

function command_manager:message_created(message)
    local author = message.author
    local content = message.content

    if author.bot or not message.guild then
        -- can't be a robot or a DM
        -- TODO allow DMs
        return false
    end

    local args = content:split(" ")
    local command_str = args[1]

    if command_str and command_str:sub(1, #prefix) == prefix then
        command_str = command_str:sub(#prefix+1)

        local command = self:check_trigger(command_str)
        if command then
            -- remove the primary command from the args
            table.remove(args, 1)

            command:execute(message)
        end
    end

    return false
end

function command_manager:load_module(file_path)
    -- local file_path = self.directory .. module
    printf("Loading module with at path %q", file_path)
    local f, err = loadfile(file_path)

    if not f then
        printf("Command Manager init, failed to load the file %q. Err is %q", file_path, err)
    else
        setfenv(f, getfenv(1))
        local ok, p_err = pcall(function()
            f()
        end) 
        if not ok then printf("Failed to execute code in command module %q. Err is %q", file_path, p_err) end
    end
end

function command_manager:init()
    print("cm init")

    local dir = self._directory

    for file, file_type in FS.scandirSync(dir) do
        printf("Scanning commands, %q found, type %q.", file, file_type)
        if file_type == "file" and file:find(".lua") then
            printf("Loading module %q", file)
            self:load_module(dir .. file)
        end
    end
end

return command_manager