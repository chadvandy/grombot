local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local Command = InteractionManager:new_command("admin", "Admin shit", "CHAT_INPUT")

-- Command.id = "1113979120926347325"
Command:set_global(true)
Command:set_moderator_only()

do
    local Roles = Command:add_subcommand_group("roles", "Admin commands regarding Notification Roles and other Roles systems.")

    local function get_role_data_with_id(id)
        for i, role in ipairs(saved_data.roles._ROLES) do
            if role.id == id then
                return role
            end
        end
    end

    local function get_role_with_id(id)
        local gId = "373745291289034763"
        local guild = client:getGuild(gId)
    
        local role = guild:getRole(id)
    
        return role
    end

    ---  admin roles edit [name:name] [description?] [role?] [new_name?]
    do
        local Edit = Roles:add_subcommand("edit", "Edit an existing Notification Role.")
        Edit:set_callback(function (int, args)
            local mem = int.member
            if not mem then return end
        
            local role_id = args.name
            
            local role_data = get_role_data_with_id(role_id)
            local role_obj = int.guild:getRole(role_id)
        
            int:reply("Editing Role " .. role_obj.mentionString .. "!", true)
            -- int:reply("Wheeeee!", true)
        
            local new_desc = args.new_desc
            local new_role = args.new_role
            local hide = args.hide
        
            if is_string(new_desc) then
                -- saved_data.roles._ROLES
                role_data.desc = new_desc
                int:reply("Changing description for " .. role_obj.mentionString, true)
            end
        
            if not is_nil(new_role) then
                int:reply("New Role: " .. new_role.mentionString, true)
            end
        
            if is_boolean(hide) then
                role_data.visible = not hide
            end
            
            save_data("roles")
        end)
        
        do
            local name = Edit:create_option("name", "Name of the Role")
            name:set_required(true)
            name:set_type("STRING")
            name:set_autocomplete(true)
            name:set_on_autocomplete(function(int, data, value)
                local choices = {}
        
                local srch = string.lower(value)
        
                print("Checking search string: " .. srch)
        
                for _, role in ipairs(saved_data.roles._ROLES) do
                    local role_obj = get_role_with_id(role.id)
                    local role_name = role_obj.name
                    local comp = string.lower(role_name)
                    print("Comparing against " .. comp)
                    if string.find(comp, srch) then
                        choices[#choices+1] = {
                            name = role_name,
                            value = role.id,
                        }
                    end
                end
        
                return choices
            end)
        
            Edit:create_option("new_desc", "New description for this Role.")
                :set_required(false)
                :set_type("STRING")
        
            Edit:create_option("new_role", "New Role to point to.")
                :set_required(false)
                :set_type("ROLE")
        
            Edit:create_option("hide", "Hide this role. Leave blank or false to set it visible.")
                :set_required(false)
                :set_type("BOOLEAN")
        end
    end

    --- admin roles add [role] [description]
    do
        local Add = Roles:add_subcommand("add", "Add an existing Role to the Notifications system!")

        Add:create_option("role", "The role to add to the Notifications system.")
            :set_required(true)
            :set_type("ROLE")

        Add:create_option("desc", "Description for the Role in question.")
            :set_required(true)
            :set_type("STRING")

        Add:set_callback(function (int, args)
            local mem = int.member
            if not mem then return end
            if not mem:hasPermission(nil, discordia.enums.permission.banMembers) then
                int:reply("This command is for admins only!", true)
                return
            end

            ---@type Role
            local new_role = args.role

            ---@type string
            local new_desc = args.desc

            saved_data.roles._ROLES[#saved_data.roles._ROLES+1] = {
                id = new_role.id,
                desc = new_desc,
                name = new_role.name,
                visible = true,
                reaction = "",
                owner = {},
            }

            save_data("roles")
        end)
    end
end

-- Command:set_callback(function (int, args)
--     int:reply("Admin shit!")
-- end)

return Command