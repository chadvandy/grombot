local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local Command = InteractionManager:new_command("roles", "Select between available noification roles!", "CHAT_INPUT")
-- Command.id = "1113235945458778122"

Command:set_global(true)

local all_roles = saved_data.roles._ROLES

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

        for i, role in ipairs(all_roles) do
            fields[#fields+1] = {
                name = role.name,
                value = role.desc,
                inline = true,
            }

            if i % 2 == 0 then
                fields[#fields+1] = {
                    name = "",
                    value = "",
                    inline = true,
                }
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
    end)

local all_role_choices = {}
for _, role in ipairs(all_roles) do
    -- inform("Found a single role!")
    all_role_choices[#all_role_choices+1] = {
        name = role.name,
        value = role.id
    }
end

local Add = Command:add_subcommand("add", "Add a new role!")
do
    local opt = Add:create_option("role", "Role to add")

    opt:set_type("STRING")
    opt:set_required(true)
    opt:set_option_choices(all_role_choices)
end

Add:set_callback(function (int, args)
    local member = int.member
    local role_id = args.role

    if member then
        local ok, err = member:addRole(role_id)

        int:reply("Added new role!", true)
    end
end)

local Remove = Command:add_subcommand("remove", "Remove a role!")
do
    local opt = Remove:create_option("role", "Role to add!")
    opt:set_type("STRING")
    opt:set_required(true)
    opt:set_option_choices(all_role_choices)
end

Remove:set_callback(function (int, args)
    local member = int.member
    local role_id = args.role

    if member then
        local ok, err = member:removeRole(role_id)

        int:reply("Removed role!", true)
    end
end)

return Command