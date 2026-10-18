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

local mute_role_id = "650338854359924806"

---comment
---@param operation_type string
---@param member Member
---@param admin Member
---@param reason string|nil
---@param duration? any
---@param message? Message
function admin_operation_notify(operation_type, member, admin, reason, duration, message)
	-- TODO type checking
	local cnc_guild_id = "373745291289034763"
	local logging_channel_id = "650311653388320778"

	if type(reason) ~= "string" or reason == "" then
		reason = "No reason provided."
	end

	local user = member.user

	local operation_type_past = ""

	if operation_type:sub(-1, -1) == "e" then
		operation_type_past = operation_type .. "d"
	elseif operation_type:find("ban") then
		operation_type_past = operation_type .. "ned"
	else
		operation_type_past = operation_type .. "ed"
	end

	printf("operation type %s, past tense is %q", operation_type, operation_type_past)
	printf("reason is %q", reason)

	local guild = client:getGuild(cnc_guild_id)
	local logging_channel = guild:getChannel(logging_channel_id)
	
	local title = "["..operation_type:upper().."] " .. user.tag
	local avatar_url = user:getAvatarURL()

	local embed = {
		-- title = title,
		author = {
			name = title,
			icon_url = avatar_url
		},
		-- image = {url = avatar_url},
		fields = {
			{name = "User", value = "<@"..user.id..">", inline = true},
			-- {name = "User", value = user.id, inline = true}
			{name = "Admin", value = "<@"..admin.id..">", inline = true},
		}
	}

	-- if reason and reason ~= "" then
		embed.fields[#embed.fields+1] = {name = "Reason", value = reason, inline = false}
	-- end

	-- duration is actually the end time in MS, so subtract it by os.time() to get the difference in MS
	if duration then
		-- duration = duration - os.time()
		local duration_str = s_to_time_string(duration)

		embed.fields[#embed.fields+1] = {name = "Duration", value = duration_str, inline = true}
	end

	if message then
		-- send a message to the channel itself
		do
			local my_embed = {
				author = {
					name = user.tag .. " has been " .. operation_type_past,
					icon_url = avatar_url,
				},
				fields = {
					{name = "Reason: ", value = reason, inline = false},
				},
			}

			if duration then
				local duration_str = s_to_time_string(duration)
		
				my_embed.fields[#my_embed.fields+1] = {name = "Duration", value = tostring(duration_str), inline = true}
			end

			local ok, err = validate_embed(my_embed) 
			if not ok then
				errmsg(err)
			else
				local msg = message.channel:send({embed = my_embed})
				embed.fields[#embed.fields+1] = {name = "Original Message", value = msg.link, inline = false}
			end
		end
	end

	local ok, err = validate_embed(embed)
	if not ok then
		return errmsg(err)
	end
	
	logging_channel:send({embed = embed})
end

do
    -- TODO ban / kick / delete / timeout / etc.

    -- Warn the specified user with provided reason.
    local WarnCommand  = Command:add_subcommand("warn", "Warn a member with specified reason.")
    WarnCommand:create_option("user", "User to warn")
                :set_required(true)
                :set_type("USER")

    WarnCommand:create_option("reason", "Reason for being warned")
                :set_required(true)
                :set_type("STRING")

    WarnCommand:set_callback(function (int, args)
        int:reply("Warning them!", true)

        local member = int._guild:getMember(args.user)
        local admin = int._member

        admin_operation_notify("warn", member, admin, args.reason)
    end)

    local MuteCommand = Command:add_subcommand("mute", "Mute a member.")
    MuteCommand:create_option("user", "User to mute")
               :set_required(true)
               :set_type("USER")

    MuteCommand:create_option("reason", "Reason for being muted")
               :set_required(true)
               :set_type("STRING")
            
    MuteCommand:create_option("duration", "Duration for the mute. `X[s/m/h/d]`, where X is a number. Default is infinite.")
               :set_required(false)
               :set_type("STRING")

    MuteCommand:set_callback(function (int, args)
        -- Confirm valid args.
        -- The only one needing testing is the "duration" string.

        local duration = nil
        if is_string(args.duration) then
            local err
            duration, err = get_ms_from_time(args.duration)

            if is_nil(duration) then
                int:reply("Invalid format for duration.\n" .. err, true)
                return
            end
        end

        ---@type Member
        local member = int._guild:getMember(args.user)

        ---@type Member
        local admin = int._member

        -- member:mute()
        member:addRole(mute_role_id)

        if is_nil(duration) then
            int:reply(string.format("%s muted!", member.name), true)
        else
            int:reply(string.format("%s muted for %s!", member.name, s_to_time_string(duration)), true)

            local data = {
                admin = admin.id,
                victim = member.user.id,
                reason = args.reason,
                type = "mute",
            }

            saved_data.admin_table[#saved_data.admin_table+1] = data
        end
        
        admin_operation_notify("mute", member, admin, args.reason, duration)
    end)

    local UnmuteCommand = Command:add_subcommand("unmute", "Unmute a user.")

    UnmuteCommand:create_option("user", "User to unmute")
                 :set_required(true)
                 :set_type("USER")

    UnmuteCommand:set_callback(function (int, args)
        ---@type Member
        local member = int._guild:getMember(args.user)
        local admin = int._member

        if member:hasRole(mute_role_id) then
            member:removeRole(mute_role_id)

            int:reply(string.format("Unmuted user %s", member.name), true)

            admin_operation_notify("unmute", member, admin)
        else
            int:reply(string.format("%s is not muted!", member.name), true)
        end
    end)

    local KickCommand = Command:add_subcommand("kick", "Kick a user.")

    KickCommand:create_option("user", "User to kick")
               :set_required(true)
               :set_type("USER")

    KickCommand:create_option("reason", "Reason for being kicked")
               :set_required(true)
               :set_type("STRING")

    KickCommand:set_callback(function (int, args)
        ---@type Member 
        local member = int._guild:getMember(args.user)
        local admin = int._member

        local memberName = member.name
        
        local guild = int._guild
        guild:kickUser(member.user, args.reason)
        
        int:reply(string.format("%s kicked.", memberName), true)

        admin_operation_notify("kick", member, admin, args.reason)
    end)

    local BanCommand = Command:add_subcommand("ban", "Ban a user.")

    BanCommand:create_option("user", "User to ban")
              :set_required(true)
              :set_type("USER")

    BanCommand:create_option("reason", "Reason for being banned")
              :set_required(true)
              :set_type("STRING")

    BanCommand:create_option("delete_messages", "Number between 0-7, for how many days worth of messages should be deleted. Defaults to 0.")
              :set_required(false)
              :set_type("INTEGER")

    BanCommand:create_option("duration", "Duration for the ban. `X[s/m/h/d]`, where X is a number. Default is infinite.")
              :set_required(false)
              :set_type("STRING")

    BanCommand:set_callback(function (int, args)
        -- Confirm valid args.
        -- Need to test the "duration" string and the "delete_messages" value.

        local duration = nil
        if is_string(args.duration) then
            local err
            duration, err = get_ms_from_time(args.duration)

            if is_nil(duration) then
                int:reply("Invalid format for duration.\n" .. err, true)
                return
            end
        end

        local days_to_delete = args.delete_messages
        if is_number(days_to_delete) then
            if days_to_delete < 0 or days_to_delete > 7 then
                int:reply("Invalid value for delete_messages. Must be between 0 and 7.", true)
                return
            end
        else
            days_to_delete = 0
        end

        ---@type Member
        local member = int._guild:getMember(args.user)

        local memberName = member.name
        local victimId = member.id

        ---@type Member
        local admin = int._member

        ---@type Guild
        local guild = int._guild

        ---@type string
        local reason = args.reason

        -- member:mute()
        guild:banUser(victimId, reason, days_to_delete)

        if is_nil(duration) then
            int:reply(string.format("%s banned!", memberName), true)
        else
            int:reply(string.format("%s banned for %s!", memberName, s_to_time_string(duration)), true)

            local data = {
                admin = admin.id,
                victim = victimId,
                reason = args.reason,
                type = "ban",
                time = os.time() + duration
            }

            saved_data.admin_table[#saved_data.admin_table+1] = data
        end
        
        admin_operation_notify("ban", member, admin, reason, duration)
    end)
end

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

            int:reply("Nice! Added it!", true)
        end)
    end
end

-- Command:set_callback(function (int, args)
--     int:reply("Admin shit!")
-- end)

return Command