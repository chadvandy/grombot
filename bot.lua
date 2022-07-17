---@type discordia
discordia = require('discordia')

---@type Client
client = discordia.Client(
	-- {logLevel = discordia.enums.logLevel.debug}
)

discordia.extensions()

function _G.env_require(path, env)
	if not env then env = getfenv(1) end
	local f = assert(loadfile(path))
	setfenv(f, env)
	return f()
end

ENUMS = discordia.enums
CLASS = discordia.class
EMITTER = discordia.Emitter
FS = require("fs")
JSON = require("json")
TIMER = require("timer")
-- RESOLVER = require("deps.discordia.libs.client.Resolver")
local http = require("coro-http")

-- TODO hook in configuration stuff
CONFIG = FS.readFileSync(".config")
TOKEN = FS.readFileSync(".token")

local function other_stuff(file)
	return env_require("_other_stuff/"..file..".lua")
end

-- TODO write some way to change this locally to a guild or w/e
prefix = "?"

other_stuff("!globals")

---@type ticket_manager
TM = other_stuff("ticket_manager")

---@type prompt
PM = other_stuff("prompt_manager")

---@type command_manager
CM = other_stuff("command_manager")


saved_data = {
	reminders = {},
	admin_table = {},
	macros = {},

	roles = {},
	gromboard = {
		moddr = {
			requests = {},
			offers = {},
		},
		tech = {},
	},

	tickets = {
		current_number = 1,
	},

	game = {},

	signups = {},

	checklists = {},
}

local function load_file(name)
	local filepath = "json/"..name..".json"

	local file = FS.readFileSync(filepath)

	local new = function()
		FS.writeFileSync(filepath, saved_data[name])
	end

	if file then
		local json = JSON.decode(file)
		if json then
			saved_data[name] = json
		else
			printf("Data in %s is not JSON-able, creating new.", filepath)
			new()
		end
	else
		printf("No file with name %s, creating a new.", filepath)
		new()
	end

	printf("Loaded file %s, the new data is [%s]", name, tostring(saved_data[name]))
end

local function load_saved_data()
	printf("Loading saved data!")
	local ok, err = pcall(function()
		for k,_ in pairs(saved_data) do
			load_file(k)
		end
	end) if not ok then printf(err) end
end

local ready_functions = {}
function on_ready(fn)
	assert(is_function(fn), "Must send a function to on_ready()!")
	ready_functions[#ready_functions+1] = fn
end

-- local package = require('../../package.lua')

-- local function test()
-- 	printf("TESTING")
-- 	local url = "https://discord.com/api/v9/channels/531219831861805069/messages"
-- 	local g = "531219831861805067"
-- 	local c = "531219831861805069"


-- 	local success, res, msg = pcall(function()

-- 	http.request("POST", url,
-- 	{
-- 		{'User-Agent', string.format('DiscordBot (%s, %s)', "https://github.com/SinisterRectus/Discordia", "0.0.0")},
-- 		{'X-RateLimit-Precision', "millisecond"},
-- 		{'Authorization', 'Bot ' .. tostring(TOKEN)},
-- 	},
-- 	{
-- 		content = "Hello!",
-- 		-- tts = false,
-- 		-- components = {
-- 		-- 	{
-- 		-- 		type = 1,
-- 		-- 		components = {
-- 		-- 			{
-- 		-- 				type = 2,
-- 		-- 				label = "My Test Button",
-- 		-- 				style = 1,
-- 		-- 				custom_id = "my_test",
-- 		-- 			}
-- 		-- 		}
-- 		-- 	}
-- 		-- }
-- 	}, nil)

-- end) if not success then printf(res) printf(msg) end

-- end

client:once('ready', function()
	-- client:setGame(string.format("100%% Lua, baby. Prefix is %q.", prefix))
	client:setGame(string.format("", prefix))

	-- read the read files
	load_saved_data()

	-- prep all commands
	CM:init()

	other_stuff("reaction_roles")

	--- TODO post a "now online" message somewhere.

	-- edit reaction msg
	do
		local cnc = client:getGuild("373745291289034763")
		local rules = cnc:getChannel("373746683537915913")
		local reaction_msg = rules:getMessage("617129472583270400")

		reaction_msg:setEmbed(get_rules_react_msg())
	end

	local fn = make_safe(function() check_reminders() check_admin() end)

	TIMER.setInterval(1000, fn)
	
	for i = 1, #ready_functions do
		ready_functions[i]()
	end

	-- if is_function(test) then
	-- 	test()
	-- end
end)

local reaction_message_id = "617129472583270400"
client:on("reactionAdd", function(reaction, userId)
	if reaction.message.id == reaction_message_id then
		role_add_command(reaction, userId)
	end
end)

client:on("reactionAddUncached", function(channel, messageId, hash, userId)
	printf("Reaction added on uncached msg, hash is %q", hash)
	if messageId == reaction_message_id then
		role_add_command(nil, userId, hash, channel)
	end
end)

client:on("reactionRemove", function(reaction, userId)
	if reaction.message.id == reaction_message_id then
		role_remove_command(reaction, userId)
	end
end)

client:on("reactionRemoveUncached", function(channel, messageId, hash, userId)
	if messageId == reaction_message_id then
		role_remove_command(nil, userId, hash, channel)
	end
end)

client:on('messageCreate',
	---@param message Message
	function(message)
		if message.author.bot then
			-- Don't allow the bot (or any) to use its own commands
			return
		end

		local user_id = message.author.id
		local channel_id = message.channel.id

		if message.content:startswith(prefix) then
			CM:message_created(message)
			return
		end
	end
)


local voice_role_id = "532011147948195860"
local channel_id = "373745291289034767"
client:on("voiceChannelJoin", 
	---@param member Member
	---@param channel GuildVoiceChannel
	function(member, channel)
		if channel.id == channel_id then
			member:addRole(voice_role_id)
		end
	end
)

client:on("voiceChannelLeave", 
	---@param member Member
	---@param channel GuildVoiceChannel
	function(member, channel)
		if channel.id == channel_id then
			member:removeRole(voice_role_id)
		end
	end
)

client:run('Bot ' .. tostring(TOKEN))