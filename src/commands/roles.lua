local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local Command = InteractionManager:new_command("roles", "Select between available noification roles!", "CHAT_INPUT")

Command.id = "1113979120926347325"
Command:set_global(true) -- TODO it should be DMD specific.

local all_roles = saved_data.roles._ROLES

local function save()
    save_data("roles") 
end

local function get_role_with_id(id)
    local gId = "373745291289034763"
    local guild = client:getGuild(gId)

    local role = guild:getRole(id)

    return role
end

local function get_role_data_with_id(id)
    for i, role in ipairs(all_roles) do
        if role.id == id then
            return role
        end
    end
end

local function get_all_role_choices()
    ---@type {name: string, value:string}[]
    local all_role_choices = {}
    for _, role in ipairs(all_roles) do
        -- inform("Found a single role! Name is " .. role.name)
        local role_obj = get_role_with_id(role.id)

        if not role_obj then
            inform("Could not find the role object for reaction role " .. role.name)
        end

        if role.visible and role_obj then
            all_role_choices[#all_role_choices+1] = {
                name = role_obj.name,
                value = role_obj.id
            }
        end
    end

    return all_role_choices
end

Command:add_subcommand("all", "Show all Notification Roles.")
    :set_callback(function (int, args)
        local embed = {
            title = "Available Roles",
            description = "List of all available notification roles.",

            author = {
                name = client.user.name,
                icon_url = client.user.avatarURL,
            },
        }

        local fields = {}

        local i = 0
        for _, role_data in ipairs(all_roles) do
            local role_obj = get_role_with_id(role_data.id)

            if role_data.visible then
                i = i + 1
                fields[#fields+1] = {
                    name = role_obj.name,
                    value = role_data.desc,
                    inline = true,
                }
    
                if i % 2 == 1 then
                    fields[#fields+1] = {
                        name = "",
                        value = "",
                        inline = true,
                    }
                end
            end
        end

        embed.fields = fields

        local ok, err = int:reply(
            {
                content = "",
                embed = embed,
            },
            true
        )

        if not ok then errmsg(err) end
    end
)


local function search_for_role(int, data, value)
    local choices = {}

    local srch = string.lower(value)

    -- print("Checking search string: " .. srch)

    for _, role in ipairs(all_roles) do
        local role_obj = get_role_with_id(role.id)
        local role_name = role_obj.name
        local comp = string.lower(role_name)
        -- print("Comparing against " .. comp)

        if string.find(comp, srch) then
            choices[#choices+1] = {
                name = role_name,
                value = role.id,
            }
        end
    end

    return choices
end

do
    local Add = Command:add_subcommand("add", "Add a new role!")
    do
        local opt = Add:create_option("role", "Role to add")

        opt:set_type("STRING")
        opt:set_required(true)
        -- opt:set_option_choices(get_all_role_choices())
        opt:set_autocomplete(true)
        opt:set_on_autocomplete(search_for_role)
    end

    Add:set_callback(function (int, args)
        local member = int.member
        local role_id = args.role

        if role_id == nil then
            errmsg("Trying to add role to member, but the role called is nil!")
            return
        end

        if member == nil then
            errmsg("Trying to add role to member, but the member is nil!")
            return
        end

        local role = int.guild:getRole(role_id) 

        if not role then
            errmsg("Trying to add role w/ ID " .. tostring(role_id) .. ", but it doesn't exist!")
            return
        end


        local ok, err = member:addRole(role_id)

        if ok then
            int:reply("Added role " .. role.mentionString .. "!", true)
        else
            int:reply("Error while adding role: \n" .. err, true)
            errmsg("Error while adding role: " .. err)
        end
    end)
end

do
    --- TODO autocomplete but w/ a list of roles this user currently has?
    local Remove = Command:add_subcommand("remove", "Remove a role!")
    do
        local opt = Remove:create_option("role", "Role to add!")
        opt:set_type("STRING")
        opt:set_required(true)
        -- opt:set_option_choices(get_all_role_choices())
        opt:set_autocomplete(true)
        opt:set_on_autocomplete(search_for_role)
    end

    Remove:set_callback(function (int, args)
        local member = int.member
        ---@type string #The ID of the Role.
        local role_id = args.role

        if member then
            local role = int.guild:getRole(role_id)
            local ok, err = member:removeRole(role_id)
            
            if ok then
                int:reply("Removed role " .. role.mentionString .. "!", true)
            else
                int:reply("Error while removing role: \n" .. err, true)
                errmsg("Error while removing role: " .. err)
            end
        end
    end)
end

return Command