local mute_role_id = "650338854359924806"

---comment
---@param operation_type string
---@param member Member
---@param admin Member
---@param reason string|nil
---@param duration any
---@param message Message
local function admin_operation_notify(operation_type, member, admin, reason, duration, message)
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

	-- print("message passed: "..tostring(message))
end

function check_admin()
	-- print("checking admin stuff")
	local t = saved_data.admin_table
	local new_t = {}

	local current_time = os.time()

	for i = 1, #t do
		local data = t[i]

		if current_time >= data.time then
			local guild_id = data.guild_id
			-- local channel_id = data.channel_id

			local admin_id = data.admin
			local user_id = data.victim

			
			local guild = client:getGuild(guild_id)
			
			printf("Trying to get user with ID %s", user_id)
			local member = guild:getMember(user_id)
			printf("Trying to get admin with I %s", admin_id)
			local admin = guild:getMember(admin_id)

			local punishment_type = data.type

			if punishment_type == "mute" then
				if not CLASS.isInstance(member, CLASS.classes.Member) then
					-- not a member!
					return
				end

				member:removeRole(mute_role_id)

				admin_operation_notify("unmute", member, admin, "Mute timeout!", nil, nil)

			elseif punishment_type == "ban" then
				guild:unbanUser(user_id, "Temporary ban ended.")
			end
		else
			new_t[#new_t+1] = data
		end
	end

	-- remove the reminder from the saved_data table and override the json file
	saved_data.admin_table = new_t

	local json = JSON.stringify(saved_data.admin_table)

	if type(json) ~= "string" then
		json = "[]"
	end

	FS.writeFileSync("json/admin_table.json", json)
end

function s_to_time_string(ms)
	local times = {
		{
			str = " days",
			len = 86400,
		},
		{
			str = " hours",
			len = 3600,
		},
		{
			str = " minutes",
			len = 60,
		},
	}

	local time_str = {}

	for i = 1, #times do
		local checked_time = times[i]
		local str = checked_time.str
		local len = checked_time.len

		printf("testing s-to-string at%s", str)

		if ms >= len then
			printf("%ds is larger than%s (%d)", ms, str, len)
			local num = math.floor(ms / len)
			printf("Lasts %d%s", num, str)
			ms = ms % len

			-- chop off the "s"
			if num == 1 then str = str:sub(1, -2) end

			time_str[#time_str+1] = num .. str
		end
	end

	if ms > 0 then time_str[#time_str+1] = ms .. " seconds." end

	time_str = table.concat(time_str, ", ")
	return time_str
end

---comment
---@param message Message
local function arg_parser(message, args, get_time)
	local admin = message.member
	local mentions = message.mentionedUsers:toArray()
	local guild = message.guild

	-- local args = message.content:split(" ")
	---@class admin_arg_parser
	local ret_args = {
		---@type Member[]
		members = {},

		---@type string
		reason = nil,

		---@type Member
		admin = admin,

		---@type number
		duration = 0,

		---@type number
		end_time = 0,
	}

    if #mentions == 0 then
        return false, "You have to @mention a member to use this command!"
    end

	local content = table.concat(args, " ")
	printf("Content %q", content)

	for i = 1, #mentions do
		---@type User
		local mentioned_user = mentions[i]
		local member = guild:getMember(mentioned_user)

		if not member then
			return false, "The member mentioned is not in the channel?"
		end

		ret_args.members[#ret_args.members+1] = member

		local mentioned_str = mentioned_user.mentionString
		mentioned_str = mentioned_str:gsub("<@", "<@!", 1)
		print("Mentioned str: " .. mentioned_str)

		for j = 1, #args do
			local arg = args[j]
			if arg == mentioned_str then
				table.remove(args, j)
			end
		end
	end

	printf("Remaining content %q", table.concat(args, " "))

	local remaining_args = args

	if get_time then
		printf("Remaining args 1: " .. remaining_args[1])
		local duration,errmsg = get_ms_from_time(remaining_args[1])

		if not duration then
			return false, errmsg
		end
	
		ret_args.duration = duration
		ret_args.end_time = os.time() + duration

		table.remove(remaining_args, 1)
	end

	local reason = table.concat(remaining_args, " ")

	ret_args.reason = reason

	return ret_args
end


local warn = CM:new_command("warn",
	---@param args admin_arg_parser
	---@param message Message
	function(message, args)
		print("Doing a warn")
		for i = 1, #args.members do
			admin_operation_notify("warn", args.members[i], args.admin, args.reason, nil, message)
		end

		message:delete()
	end
)
warn:set_name("Warn a Member")
warn:set_description("Warn a member with the specified @ mention. Provide a reason for the warning, so we can look back on it later.")
warn:set_usage("`%swarn @Member For being a dick`")
warn:set_validity_check(is_admin)
warn:set_argument_parser(function(message, args)
	return arg_parser(message, args)
end)
warn:set_trigger("message", "warn")
warn:set_category("Admin")

---@param args admin_arg_parser
---@param message Message
local unmute = CM:new_command("unmute", function (message, args)
	print("Doing a unmute")
	for i = 1, #args.members do
		local member = args.members[i]
	
		local roles = member.roles
	
		if roles:get(mute_role_id) then
			member:removeRole(mute_role_id)
		end
		
		admin_operation_notify("unmute", member, args.admin, nil, nil, message)
	end

	message:delete()
end)
unmute:set_name("Unmute a Member")
unmute:set_description("Unmute a member with the specified @ mention.")
unmute:set_usage("`%sunmute @Member`")
:set_validity_check(is_admin)
unmute:set_argument_parser(function(message, args)
	return arg_parser(message, args)
end)
unmute:set_trigger("message", "unmute")
unmute:set_category("Admin")

---@param args admin_arg_parser arg[1] is the mentioned, onward is the reason, if any provided
---@param message Message
local mute = CM:new_command("mute", function (message, args)
	print("Doing a mute")
	---@type Member
	for i = 1, #args.members do
		local member = args.members[i]
		member:addRole(mute_role_id)
		
		admin_operation_notify("mute", args.members[i], args.admin, args.reason, nil, message)
	end

	message:delete()
end)
mute:set_name("Mute")
mute:set_description("Mute a member. Reason is optional.")
mute:set_usage("`%smute @Member You were naughty.`, using the mention functionality.")
mute:set_validity_check(is_admin)
mute:set_argument_parser(function(message, args)
	return arg_parser(message, args)
end)
mute:set_trigger("message", "mute")
mute:set_category("Admin")

-- args1: mention
-- args2: time
-- args3+: reason
---@param args admin_arg_parser
---@param message Message
local tempmute = CM:new_command("tempmute", function (message, args)
	print("Doing a tempmute")
	
	local channel = message.channel
	local channel_id = channel.id
	local guild = channel.guild
	local guild_id = guild.id
	
	for i = 1, #args.members do
		local member = args.members[i]
	
		member:addRole(mute_role_id)
		
		local data = {
			admin = args.admin.id,
			victim = member.user.id,
			reason = args.reason,
			type = "mute",
			time = args.end_time,
			channel_id = channel_id,
			guild_id = guild_id,
		}
		
		saved_data.admin_table[#saved_data.admin_table+1] = data
		
		admin_operation_notify("tempmute", member, args.admin, args.reason, args.duration, message)
	end

	message:delete()
end)
tempmute:set_name("Temp mute")
tempmute:set_description("Mute a member temporarily. Must provide a time, in s/m/h/d, ie. `1m` for one minute.")
tempmute:set_usage("`%stempmute @Member 1m You were naught.`, using the mention functionality.")
tempmute:set_validity_check(is_admin)
tempmute:set_argument_parser(function(message, args)
	return arg_parser(message, args, true)
end)
tempmute:set_trigger("message", "tempmute")
tempmute:set_category("Admin")

-- arg1: mention user
-- arg2+: reason
---@param args admin_arg_parser
---@param message Message
local kick = CM:new_command("kick", function (message, args)
	print("Doing a kick")
	for i = 1, #args.members do
		local member = args.members[i]
		local user = member.user
	
		local guild = message.guild
		
		guild:kickUser(user, args.reason)
		
		admin_operation_notify("kick", member, args.admin, args.reason, nil, message)
	end

	message:delete()
end)
kick:set_name("Kick")
kick:set_description("Kick a member.")
kick:set_usage("`%skick @Member Reason here.`, using the mention functionality. Reason optional.")
kick:set_validity_check(is_admin)
kick:set_argument_parser(function(message, args)
	return arg_parser(message, args)
end)
kick:set_trigger("message", "kick")
kick:set_category("Admin")

-- arg1: mention
-- arg2: time
-- arg3+: reason
---@param args admin_arg_parser
---@param message Message
local tempban = CM:new_command("tempban", function (message, args)
	print("Doing a tempban")
	
	local channel = message.channel
	local channel_id = channel.id
	local guild = channel.guild
	local guild_id = guild.id
	
	for i = 1, #args.members do
		local member = args.members[i]

		guild:banUser(member.id, args.reason)
	
		local data = {
			admin = args.admin.id,
			victim = member.user.id,
			reason = args.reason,
			type = "ban",
			time = args.end_time,
			channel_id = channel_id,
			guild_id = guild_id,
		}
		
		saved_data.admin_table[#saved_data.admin_table+1] = data
		
		admin_operation_notify("tempban", member, args.admin, args.reason, args.duration, message)
	end

	message:delete()
end)
tempban:set_name("Temporary Ban")
tempban:set_description("Ban a bitch. *Temporarily*.")
tempban:set_usage("`%stempban @Member 1h For being a bitch.`, where the time can be in s/m/h/d. The reason is optional.")
tempban:set_validity_check(is_admin)
tempban:set_argument_parser(function(message, args)
	return arg_parser(message, args, true)
end)
tempban:set_trigger("message", "tempban")
tempban:set_category("Admin")

-- arg1: mention
-- arg2+: reason
---@param args admin_arg_parser
---@param message Message
local ban = CM:new_command("ban", function (message, args)
	print("Doing a ban")
	local guild = message.channel.guild
	
	for i = 1, #args.members do
		local member = args.members[i]
	
		guild:banUser(member.id, args.reason)
		
		admin_operation_notify("ban", member, args.admin, args.reason, nil, message)
	end

	message:delete()
end)
ban:set_name("Ban")
ban:set_description("Ban a bitch.")
ban:set_usage("`%sban @Member Reason here.`, using the mention functionality. Reason optional.")
ban:set_validity_check(is_admin)
ban:set_argument_parser(function(message, args)
	return arg_parser(message, args)
end)
ban:set_trigger("message", "ban")
ban:set_category("Admin")

-- delete messages
-- arg1: num messages (?)
-- arg2: user mention (?)
-- arg3: channel mention (?)
local delete = CM:new_command(
	"delete", 
	---@param args table
	---@param message Message
	function (message, args)
		print("Doing a delete")
		---@type string
		local user = args.user

		---@type GuildTextChannel
		local channel = args.channel

		---@type number
		local num_messages = args.num_messages

		local og_channel = message.channel

		printf("Deleting %d messages in channel %q for user", num_messages, channel.name or channel.id, tostring(user))

		-- TODO use cached shit?
		local messages
		
		if user then
			messages = channel:getMessagesBefore(message.id, 50)
		else
			messages = channel:getMessagesBefore(message.id, num_messages)
		end
		
		local msg_array = messages:toArray("timestamp")

		local num_deleted = 0

		local bulk = {}

		for i = #msg_array, 1, -1 do
			if num_deleted == num_messages then break end
			---@type Message
			local msg = msg_array[i]

			if user then
				if msg.author.id == user then
					-- msg:delete()
					bulk[#bulk+1] = msg.id
					num_deleted = num_deleted+1
				end
			else
				-- msg:delete()
				bulk[#bulk+1] = msg.id
				num_deleted = num_deleted+1
			end
		end

		local actual = #bulk
		channel:bulkDelete(bulk)

		message:delete()
		-- og_channel:send("Deleted "..tostring(actual).." messages!")
	end

)
delete:set_name("Delete Messages")
delete:set_description("Delete a number of messages within this channel. If no number is provided, it defaults to 5. Optionally specify a channel and/or a user to delete messages from.")
delete:set_usage("`%sdelete 5 @User #channel_name`. All args are optional, but must be in that order. You can use `#all` as the final argument, but a user must be provided in that case. It will only delete a maximum of 50 messages at a time, as a safety measure, but I'll probably eventually bump that up.")
delete:set_validity_check(is_admin)
---@param message Message
delete:set_argument_parser(function(message, args)
	local num_messages = tonumber(args[1])
	if not num_messages then
		num_messages = 5

		-- TODO determine what args1 is!
	else
		num_messages = math.clamp(num_messages, 1, 50)
	end

	local channel = message.channel
	local mentionedChannels = message.mentionedChannels

	if mentionedChannels and mentionedChannels.first then
		channel = mentionedChannels.first
	end

	---@type User
	local user
	local mentionedUsers = message.mentionedUsers

	if mentionedUsers and mentionedUsers.first then
		user = mentionedUsers.first.id
	end

	-- TODO allow for a #all call

	printf("User found %q", tostring(user))

	return {
		user = user,
		channel = channel,
		num_messages = num_messages
	}

	-- return arg_parser(message, 2)
end)
delete:set_trigger("message", "delete")
delete:set_category("Admin")

-- Grom Write for me only
-- arg1: channel (?)
-- arg2+: message
---@param args table
---@param message Message
local write = CM:new_command("grom_write", function (message, args)
	print("Doing a Grom write!")
	message:delete()

	local channel = args.channel
	local msg = args.message

	channel:send(msg)
end)
write:set_name("Grom Write")
write:set_description("Make Grom send a message, to an optionally specified channel. If no channel specified, it'll post it right into this channel. This admin command is immediately deleted after sending!")
write:set_usage("`%sgrom_write #channel Grom is fuckin' watching you.`, using the mention functionality for channel. Channel optional.")
write:set_validity_check(is_admin)
---@type Message
write:set_argument_parser(function(message, args)
	local channel = message.channel
	if message.mentionedChannels and message.mentionedChannels.first then
		channel = message.mentionedChannels.first
		table.remove(args, 1)
	end

	local msg = table.concat(args, " ")

	return {
		channel = channel,
		message = msg
	}

	-- return arg_parser(message, 2)
end)
write:set_trigger("message", "grom_write")
write:set_category("Admin")

-- TODO set admin logging room per-server!