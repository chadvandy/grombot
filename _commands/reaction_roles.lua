-- --- Main command, ?roles, which shows every role on the default role display message. Use the reactions to add in the various roles

-- ---- Admin/Owner stuff ----
-- --- ?roles set_owner "Role Name" @Owner, to add in an owner for a role who can set it, change it, hide it, and ping it
-- --- ?roles ping "Role Name", to make Gromby ping that role if the person is an owner or admin. Check if any are owned, if no name is passed - if only one is, use that. If more than one is, send a navigation manager and ask which one they want.
-- --- ?roles hide "Role Name", to remove it from the list for now but keep the role around
-- --- ?roles edit_desc "Role Name" "New description"
-- --- ?roles edit_role "Role Name" "role_id"
-- --- ?roles edit_reaction "Role Name" "reaction_id"
-- --- ?roles edit_name "Role Name" "New Name"

-- local function save()
--     save_data("roles")
-- end

-- local function new_role(role)
--     if not saved_data.roles._ROLES then 
--         ---@type table<number, role_obj>
--         saved_data.roles._ROLES = {}
--     end

--     saved_data.roles._ROLES[#saved_data.roles._ROLES+1] = role
--     save_data("roles")
-- end

-- local function delete_role(role_name)
--     local new_roles = {}
--     for i = 1, #saved_data.roles._ROLES do
--         local role = saved_data.roles._ROLES[i]
--         if role.name ~= role_name then
--             new_roles[#new_roles+1] = role
--         end
--     end

--     saved_data.roles._ROLES = new_roles
--     save_data("roles")
-- end

-- local function get_roles()
--     return saved_data.roles._ROLES
-- end

-- local function get_role(role_name)
--     for i = 1, #saved_data.roles._ROLES do
--         local role = saved_data.roles._ROLES[i]
--         if role.name == role_name then
--             return role
--         end
--     end

--     return false
-- end

-- ---comment
-- ---@param member Member
-- ---@return boolean Valid
-- ---@return string|nil Errmsg
-- local function is_admin_or_owner(member, role)
--     local is,err = is_admin(member)
--     if not is then return is, err end

--     local user = member.user

--     if role then
--         for i = 1, #role.owner do
--             local owner_id = role.owner[i]
--             if owner_id == user.id then
--                 return true
--             end
--         end

--         return false, "You don't own this role!"
--     end

--     local roles = saved_data.roles._ROLES
--     for i = 1, #roles do
--         local role = roles[i]
--         for j = 1, #role.owner do
--             local owner_id = role.owner[j]
--             if owner_id == user.id then
--                 return true
--             end
--         end
--     end

--     return false, "You don't have any owned roles!"
-- end

-- ---comment
-- ---@param member Member
-- ---@return role_obj|nil Role
-- local function get_owned_role(member)
--     local user = member.user

--     local roles = get_roles()
--     for i = 1, #roles do
--         local role = roles[i]
--         local owners = role.owner
--         for j = 1, #owners do
--             local owner_id = owners[j]
--             if owner_id == user.id then
--                 return role
--             end
--         end
--     end
-- end

-- local react = CM:new_command(
--     "reaction_roles",
--     ---@param msg Message
--     ---@param args table<number, string>
--     function (msg, args)
--         local channel = msg.channel
--         local navigator = PM.new("roles", channel)

--         navigator:set_title("Available Roles")
--         navigator:set_description("List of available roles at the moment!")
--         navigator:set_fields_per_page(20)
--         navigator:set_user(msg.author.id)

--         local roles = saved_data.roles._ROLES

--         local all_fields = {}

--         if roles then
--             for i = 1, #roles do
--                 local role = roles[i]

--                 local reaction_str = role.reaction
--                 if string.find(reaction_str, ":") then
--                     reaction_str = "<:"..reaction_str..">"
--                 end

--                 all_fields[#all_fields+1] = {
--                     name = reaction_str.. " - " .. role.name,
--                     value = role.desc
--                 }

--                 printf("Reaction is %q", role.reaction)
--                 navigator:add_reaction(
--                     role.reaction,
--                     ---@param self prompt
--                     ---@param user_id string
--                     function(self, user_id)
--                         local message = self._message
--                         local guild = message.guild
--                         local user = guild:getMember(user_id)

--                         if not user then --[[err]] return end
--                         local role_id = role.id
--                         if user:hasRole(role_id) then
--                             user:removeRole(role_id)
--                         else
--                             user:addRole(role_id)
--                         end
--                     end
--                 )
--             end
--         end

--         navigator:set_fields(all_fields)
--         navigator:start()
--     end
-- )
-- react:set_name("Notification Roles")
-- react:set_description("Use this command to get a display of all available notification roles, and to opt in or out of any of them!")
-- react:set_usage("`%sroles`")
-- react:set_trigger("message", "roles")
-- react:set_category("Utility")
-- react:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         return args
--     end
-- )

-- local add = react:set_sub_command(CM:new_command(
--     "reaction_roles_add",
--     ---@param message Message
--     ---@param args reaction_roles_user_args
--     function(message, args)
--         local member = message.member

--         local role_name = args.role_name
--         local role = args.role

--         member:addRole(role.id)
--         message.channel:send("Added role \""..role_name.."\".")
--     end
-- ))
-- add:set_name("Add Notification Role")
-- add:set_description("Enroll in the specified notification role!")
-- add:set_usage("`%sroles add \"Role Name\"`")
-- add:set_trigger("message", "add")
-- add:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         local str = table.concat(args, " ")

--         local role_name,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_name then
--             return false, "You have to pass a name for the role to add within quotes, ie. `?roles add \"My Role\"`"
--         end

--         local role = get_role(role_name)

--         if not role then
--             return false, "No role found with the name \""..role_name.."\""
--         end

--         ---@type reaction_roles_user_args
--         return {
--             role_name = role_name,
--             role = role,
--         }
--     end
-- )

-- local remove = react:set_sub_command(CM:new_command(
--     "reaction_roles_remove",
--     ---@param message Message
--     ---@param args reaction_roles_user_args
--     function(message, args)
--         local member = message.member

--         local role_name = args.role_name
--         local role = args.role

--         member:removeRole(role.id)
--         message.channel:send("Removed role \""..role_name.."\".")
--     end
-- ))
-- remove:set_name("Remove Notification Role")
-- remove:set_description("Unregister from the specified notification role!")
-- remove:set_usage("`%sroles remove \"Role Name\"`")
-- remove:set_trigger("message", "remove")
-- -- add:set_validity_check(is_admin)
-- remove:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         local str = table.concat(args, " ")

--         local role_name,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_name then
--             return false, "You have to pass a name for the role to add within quotes, ie. `?roles remove \"My Role\"`"
--         end

--         local role = get_role(role_name)

--         if not role then
--             return false, "No role found with the name \""..role_name.."\""
--         end

--         ---@class reaction_roles_user_args
--         return {
--             role_name = role_name,
--             role = role,
--         }
--     end
-- )

-- --- Create new reaction - role links!
-- local create = react:set_sub_command(CM:new_command(
--     "reaction_roles_add_new",
--     ---@param msg Message
--     ---@param args reaction_roles_add_new_args
--     function (msg, args)
--         local name = args.role_name
--         local desc = args.role_desc
--         local role_id = args.role_id
--         local reaction_id = args.reaction_id

--         printf("Reaction added as %q", reaction_id)

--         ---@class role_obj
--         local role = {
--             name = name,
--             desc = desc,
--             id = role_id,
--             reaction = reaction_id,

--             visible = true,
--             owner = {},
--         }

--         local str = string.format("Name is %q, desc is %q, role ID is %q, reaction ID is %q", name, desc, role_id, reaction_id)

--         msg.channel:send(str)

--         new_role(role)
--     end
-- ))
-- create:set_name("Create a New Notification Role")
-- create:set_description("Use this command to create a new notification role - defining the name, the relevant emoji, and the relevant role.")
-- create:set_usage("`%sroles create \"Role Name\" \"Role Description\" \"Role ID\" \"Reaction ID\"`")
-- create:set_trigger("message", "create")
-- create:set_validity_check(is_admin)
-- create:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         local str = table.concat(args, " ")

--         local role_name,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_name then
--             return false, "You have to pass a name for the role to display within quotes, ie. `?roles create \"My Role\"`"
--         end

--         local role_desc,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_desc then
--             return false, "You have to pass a description for the role to display within quotes, ie. `?roles create \"Role Name\" \"Role Description\"`"
--         end

--         local role_id,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_id then
--             return false, "You have to pass the ID of the role to add within quotes, ie. `?roles create \"Role Name\" \"Role Description\" \"Role ID\"`"
--         end

--         local reaction_id,_ = get_quoted_name_and_remaining_from_string(str)
--         if not reaction_id then
--             return false, "You have to pass the ID of the reaction to add within quotes, ie. ?roles create \"Role Name\" \"Role Description\" \"Role ID\" \"Reaction ID\"`"
--         end

--         ---@class reaction_roles_add_new_args
--         return {
--             role_name = role_name,
--             role_desc = role_desc,
--             role_id = role_id,
--             reaction_id = reaction_id,
--         }
--     end
-- )

-- local delete = react:set_sub_command(CM:new_command(
--     "reaction_roles_delete",
--     ---@param message Message
--     ---@param args reaction_roles_delete_args
--     function(message, args)
--         local role_name = args.role_name
--         delete_role(role_name)
--     end
-- ))
-- delete:set_name("Delete Notification Role")
-- delete:set_description("Use this command to delete a Notification Role.")
-- delete:set_usage("`%sroles delete \"Role Name\"`")
-- delete:set_trigger("message", "delete")
-- delete:set_validity_check(is_admin)
-- delete:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         local str = table.concat(args, " ")

--         local role_name,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_name then
--             return false, "You have to pass a name for the role to remove within quotes, ie. `?roles delete \"My Role\"`"
--         end

--         ---@class reaction_roles_delete_args
--         return {
--             role_name = role_name,
--         }
--     end
-- )

-- local set_owner = react:set_sub_command(CM:new_command(
--     "reaction_roles_set_owner",
--     ---@param message Message
--     ---@param args reaction_roles_set_owner_args
--     function(message, args)
--         ---@type role_obj
--         local role = args.role
--         local role_name = args.role_name
--         ---@type User
--         local new_owner = args.new_owner

--         if not role.owner then role.owner = {} end
--         role.owner[#role.owner+1] = new_owner.id
--         save_data("roles")

--         local owner_str = new_owner.name

--         message.channel:send(owner_str .. " added as an owner of role " .. role_name)
--     end
-- ))
-- set_owner:set_name("Set Role Owner")
-- set_owner:set_description("Set an owner for this role. Owners can ping this role, and are able to change details about it or hide it from the view of others.")
-- set_owner:set_usage("`%sroles set_owner \"Role Name\" @Owner`")
-- set_owner:set_trigger("message", "set_owner")
-- set_owner:set_validity_check(is_admin)
-- set_owner:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         local str = table.concat(args, " ")

--         local role_name,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_name then
--             return false, "You have to pass a name for the role to remove within quotes, ie. `?roles set_owner \"My Role\"`"
--         end

--         local role = get_role(role_name)
--         if not role then
--             return false, "No role found with the name \""..role_name.."\"!"
--         end

--         local mention = message.mentionedUsers.first
--         if not mention then
--             return false, "You have to mention (@User) a new owner for this role!"
--         end

--         ---@class reaction_roles_set_owner_args
--         return {
--             role = role,
--             role_name = role_name,
--             ---@type User
--             new_owner = mention,
--         }
--     end
-- )

-- local ping = react:set_sub_command(CM:new_command(
--     "reaction_roles_ping",
--     ---@param message Message
--     ---@param args reaction_roles_ping
--     function(message, args)
--         ---@type Role
--         local role = args.role

--         message.channel:send("Notification time!\n  " .. role.mentionString)
--     end
-- ))
-- ping:set_name("Ping Role")
-- ping:set_description("Ask Gromby to ping your role for you!")
-- ping:set_usage("`%sroles ping \"Role Name\"`, role name can be omitted if you only have one role owned.")
-- ping:set_trigger("message", "ping")
-- ping:set_validity_check(is_admin_or_owner)
-- ping:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         local str = table.concat(args, " ")

--         local role

--         local role_name,str = get_quoted_name_and_remaining_from_string(str)
--         if role_name then
--             role = get_role(role_name)
--             if not role then
--                 return false, "No role found with the name \""..role_name.."\"!"
--             end

--             local is, err = is_admin_or_owner(message.member, role)
--             if not is then return is,err end
--         else
--             role = get_owned_role(message.member)

--             if not role then
--                 return false, "You don't own any roles!"
--             end
--         end

--         local real_role = message.guild:getRole(role.id)
--         if not real_role then
--             return false, "No role found with the id " .. role.id .. "!"
--         end

--         ---@class reaction_roles_ping
--         return {
--             role = real_role,
--         }
--     end
-- )

-- local edit_desc = react:set_sub_command(CM:new_command(
--     "reaction_roles_edit_desc",
--     ---@param message Message
--     ---@param args reaction_roles_edit_desc
--     function(message, args)
--         ---@type role_obj
--         local role = args.role_obj
--         local role_name = args.role_name
--         local role_desc = args.role_desc

--         role.desc = role_desc
--         save()

--         message.channel:send("Changed role \""..role_name.."\" description to \""..role_desc.."\".")
--     end
-- ))
-- edit_desc:set_name("Edit Role Description")
-- edit_desc:set_description("Change the description of an owned role.")
-- edit_desc:set_usage("`%sroles edit_desc \"Role Name\" \"New description\"`.")
-- edit_desc:set_trigger("message", "edit_desc")
-- edit_desc:set_validity_check(is_admin_or_owner)
-- edit_desc:set_argument_parser(
--     ---@param message Message
--     ---@param args table<number, string>
--     function (message, args)
--         local str = table.concat(args, " ")

--         local role

--         local role_name,str = get_quoted_name_and_remaining_from_string(str)
--         if role_name then
--             role = get_role(role_name)
--             if not role then
--                 return false, "No role found with the name \""..role_name.."\"!"
--             end

--             local is, err = is_admin_or_owner(message.member, role)
--             if not is then return is,err end
--         else
--             return false, "You have to provide a role's name within quotation marks!"
--         end

--         local role_desc,str = get_quoted_name_and_remaining_from_string(str)
--         if not role_desc then
--             return false, "You have to provide the new role description within quotation marks! ie., `?roles edit_desc \"My Role\" \"New description\"`."
--         end

--         ---@class reaction_roles_edit_desc
--         return {
--             role_name = role_name,
--             role_obj = role,
--             role_desc = role_desc
--         }
--     end
-- )