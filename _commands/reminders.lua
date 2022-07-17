local function save()
	save_data("reminders")
end

local function get_reminders(user_id)
	local ret = {}
	local reminders = saved_data.reminders

	for i = 1, #reminders do
		local reminder = reminders[i]
		if reminder.author_id == user_id then
			ret[#ret+1] = {reminder,i}
		end
	end

	return ret
end

local function remove_reminder(i)
	if not is_number(i) then return end
	if #saved_data.reminders < i then return end

	table.remove(saved_data.reminders, i)
	save()
end

local function post_reminder(reminder_data)
	-- get deets from the reminder
	local author_id = reminder_data.author_id
	local guild_id = reminder_data.guild_id
	local channel_id = reminder_data.channel_id
	local message_id = reminder_data.message_id
	local message_to_send = reminder_data.message

	-- get the Discord objects
	local guild = client:getGuild(guild_id)
	local channel = guild:getChannel(channel_id)
	local author = guild:getMember(author_id)

	if not author then
		-- error_msg
		return
	end

	local auth_str = "⏰ <@"..author_id.."> ⏰\n"..message_to_send

	local fields = {
		{
			name = "Re-Remind",
			value = "Use 🕧 to be reminded again in 1h with the same message. Use 🔄 to be reminded again in 24h with the same message.",
		},
	}

	if message_id then
		local og_message = channel:getMessage(message_id)

		if og_message then
			fields[#fields+1] = {name = "Original Link", value = og_message.link}
		end
	end

	local remind_again = false

	local navigator = PM.new("reminder", channel)
	navigator:set_fields(fields)

	-- timer will last one hour!
	navigator:set_timeout(3600000)
	navigator:set_user(author_id) -- only the person who made it can use it!
	navigator:set_reactions({
		{
			"🕧",
			function(self, user_id)
				remind_again = 3600
				self:edit_field(1, {name = "One hour!", value = "You will get this reminder again in one hour!"})
				self:goodbye()
			end,
		},
		{
			"🔄",
			function(self, user_id)
				remind_again = 86400
				self:edit_field(1, {name = "One day!", value = "You will get this reminder again in one day!"})
					self:goodbye()
			end
		},

	})

	navigator:add_close_callback(function(self)
		if remind_again then
			local new_reminder = reminder_data
			new_reminder.time = reminder_data.time + remind_again

			table.insert(saved_data.reminders, new_reminder)

			-- self:edit_field(2, {name = "Re-reminder!", value = "I will reinform you in 24 hours!"})
		end
	end)

	navigator:set_content(auth_str)

	local ok = navigator:start()
	if ok == false then
		local new_reminder = reminder_data
		new_reminder.time = reminder_data.time + 3600

		table.insert(saved_data.reminders, new_reminder)
	end

	-- channel:send({content = auth_str, embed = embed})
end

-- This is called through a timer in bot.lua, every few seconds
function check_reminders()
	-- print("checking reminders")
	local t = saved_data.reminders
	local new_t = {}

	-- current time since epoch, UTC
	local current_time = os.time()

	for i = 1, #t do
		local reminder_data = t[i]

		-- printf("Current time %d, reminder time is %d", current_time, reminder_data.time)

		if current_time >= reminder_data.time then
			post_reminder(reminder_data)
		else
			new_t[#new_t+1] = reminder_data
		end
	end

	-- remove the reminder from the saved_data table and override the json file
	saved_data.reminders = new_t
	save()
end

---@param args table
---@param message Message
local remindme = CM:new_command("remindme", function (message, args)
    -- local content = message.content
    if next(args) == nil then
        -- show all currently waiting reminders.
		local reminders = get_reminders(message.author.id)
		if #reminders == 0 then
			return message.channel:send("You have no currently awaiting reminders, and you didn't pass any arguments to call remindme. Use `?help remindme` to see how this function works!")
		end

		local nav = PM.new("reminders", message.channel)
		nav:set_title("Currently Awaiting Reminders")
		nav:set_description("These are your current reminders that have not been triggered yet!")
		nav:set_fields_per_page(5)

		local all = {}
		for i = 1, #reminders do
			local reminder = reminders[i][1]
			all[#all+1] = {
				name = "#"..reminders[i][2]..", due in " .. s_to_time_string(reminder.time - os.time()),
				value = reminder.message
			}
		end

		nav:set_fields(all)
		return nav:start()
    end

	table.insert(saved_data.reminders, args)
	save()

	message:reply("Reminder set! You will be informed in " .. s_to_time_string(args.time - os.time()))
end)
remindme:set_name("Remind Me")
remindme:set_description("Create a reminder. Time can be any number followed by s/m/h/d, for seconds/minutes/hours/day.")
remindme:set_usage("`%sremindme 1s Remind Me Message`, message is optional and can be anything.")
remindme:set_trigger("message", "remindme")
remindme:set_category("Utility")
remindme:set_argument_parser(
	---@param message Message
	---@param args table
	function(message, args)
		if #args == 0 then
			return {}
		end

		local time_msg = args[1]
		table.remove(args, 1)
			
		local ms_delay, errmsg = get_ms_from_time(time_msg)
	
		if not ms_delay then
			if ms_delay == false then 
				errmsg = "You have to pass in a time, ie. `?remindme 5s Remind me`, where 5s is the time. Pass in a number and a 'time tag' (s/m/h/d, for seconds/minutes/hours/days)."
			end
			return false, errmsg
		end
	
		if #args == 0 then
			-- return false, "You have to pass in a message after the time amount! `?remindme 5s Message`, where Message is the, well."
			args[1] = ""
		end

		local msg = table.concat(args, " ")
		printf("message: %s", msg)
	
		local author_id = message.author.id
		local guild_id = message.guild.id
		local channel_id = message.channel.id
	
		local time = os.time() + ms_delay
	
		return {
			message = msg,
			time = time,
			author_id = author_id,
			channel_id = channel_id,
			guild_id = guild_id,
			message_id = message.id,
		}
	end
)

local remove = remindme:set_sub_command(CM:new_command(
	"remindme_remove",
	function(message, args)
		remove_reminder(args.i)

		message.channel:send("Reminder canceled!")
	end
))
remove:set_name("Remove Reminder")
remove:set_description("Cancel an in-prog reminder before it gets sent. Uses the ticket # found by using `?remindme`.")
remove:set_usage("`%sremindme remove N`, where N is the ticket number.")
remove:set_trigger("message", "remove")
remove:set_argument_parser(
	function (message, args)
		if #args == 0 then
			return false, "You have to pass a ticket number to this command!"
		end

		local num = string.gsub(args[1], "#", "")
		num = tonumber(num)

		if not is_number(num) then
			return false, "The ticket number passed, "..tostring(num) ..", is not a valid number!"
		end

		if #saved_data.reminders < num then
			return false, "Invalid ticket number!"
		end

		local reminder = saved_data.reminders[num]
		if not is_admin(message.author) then
			if reminder.author_id ~= message.author.id then
				return false, 'This is not your reminder!'
			end
		end

		return {
			i = num
		}
	end
)

local admin = remindme:set_sub_command(CM:new_command(
	"remindme_admin",
	function(message, args)
		local fields = {}
		local nav = PM.new("reminders_admin", message.channel)
		nav:set_title("Currently Awaiting Reminders [ADMIN]")
		nav:set_description("This is every awaiting reminder ever.")
		nav:set_fields_per_page(5)
		for i = 1, #saved_data.reminders do
			local reminder = saved_data.reminders[i]

			fields[#fields+1] = {
				name = "#"..i.." by <@"..reminder.author_id..">, due in " .. s_to_time_string(reminder.time - os.time()),
				value = reminder.message
			}
		end

		nav:set_fields(fields)
		return nav:start()
	end
))
admin:set_validity_check(is_admin)
-- admin:set_category("Admin") TODO this! 
admin:set_trigger("message", "admin")