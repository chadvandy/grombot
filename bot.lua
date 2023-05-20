---@type discordia
local discordia = require('discordia')
-- require("discordia-interactions") -- Modifies Discordia and adds interactionCreate event
dslash = require("discordia-slash") -- Modifies Discordia and adds interactionCreate event

package.path = package.path .. ";?.lua;?/init.lua"

local intrType = discordia.enums.interactionType

---@type Client
client = discordia.Client(
	-- {logLevel = discordia.enums.logLevel.debug}
)

client:enableAllIntents()

discordia.storage.client = client

client:useApplicationCommands()
dslash.util.appcmd(client, "531219831861805067")
dslash.util.appcmd(client, "373745291289034763")

discordia.extensions()

function _G.env_require(path, env)
	if not env then env = getfenv(1) end
	local f = assert(loadfile(path, "bt", getfenv(1)))
	return f()
end

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata

NewClass = require "../30-log"
_G.NewClass = NewClass
print("NewClass is: "..tostring(NewClass))
ENUMS = discordia.enums
CLASS = discordia.class
EMITTER = discordia.Emitter

_G.FS = require("fs")
_G.JSON = require("json")
_G.TIMER = require("timer")
_G.http = require("coro-http")


-- TODO hook in configuration stuff
CONFIG = FS.readFileSync(".config")

local function other_stuff(file)
	return env_require("_other_stuff/"..file..".lua")
end

-- TODO write some way to change this locally to a guild or w/e
prefix = "?"

other_stuff("!globals")

local my_class = NewClass("Test", {})

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

local function log_me(...)
	local s = ''
	for i=1,select('#',...) do s = string.format("%s %s", s, tostring(select(i, ...))) end

	client.owner:send(s)
end

local function edit_reaction_msg()
	-- Demo
	-- local guild = client:getGuild("531219831861805067")
	-- local channel = guild:getChannel("532002921877995520")
	-- ---@cast channel GuildTextChannel
	-- local msg = channel:getMessage("1028123908446105631")

	-- Live
	local guild = client:getGuild("373745291289034763")
	local channel = guild:getChannel("373746683537915913")
	---@cast channel GuildTextChannel
	local msg = channel:getMessage("617129472583270400")

	local embed = get_rules_react_msg()

	-- embed = {
	-- 	title = "Testing",
	-- 	description = "Testing",
	-- 	fields = {
	-- 		{
	-- 			name = "testing",
	-- 			value = "testing",
	-- 		}
	-- 	}
	-- }

	-- msg:clearReactions()
	local ok, err = msg:setEmbed(embed)
	if not ok then log_me("ERROR: " .. err) end

	local fields = embed.fields
	for i, field in ipairs(fields) do
		local str = field.name
		local emoji = str:match("(<.+>)")
		local num = emoji:match("(%d+)")
		local name = emoji:match(":(.+):")

		str = name..":"..num

		local ok, err = msg:addReaction(str)
		if not ok then log_me(err) end
	end

	-- channel:send({content="test", embed={title="Test"}})
end

---@type InteractionManager
local InteractionManager = require("./src/interactions")

client:once('ready', function()
	-- client:setGame(string.format("100%% Lua, baby. Prefix is %q.", prefix))
	client:setActivity({name="Cruisin' on the Karaz Ankor"})

	-- read the read files
	load_saved_data()

	-- prep all commands
	CM:init()

	other_stuff("reaction_roles")

	--- TODO post a "now online" message somewhere.
	InteractionManager:init()

	-- edit reaction msg
	do
		local ok, err = pcall(function()
			edit_reaction_msg()
			-- local cnc = client:getGuild("373745291289034763")

			-- local rules = cnc:getChannel("373746683537915913")
			-- ---@cast rules GuildTextChannel
			-- local reaction_msg = rules:getMessage("617129472583270400")

			-- local is, erro = validate_embed(get_rules_react_msg())
			-- if not is then
			-- 	log_me("Embed is incorrect, error is: " .. erro)
			-- end

			-- log_me("React msg embed is: " .. tostring(get_rules_react_msg()))

			-- reaction_msg:setEmbed({title="TESTING", fields = {{name="TESTING", value="MORE TESTS"}}})
			-- reaction_msg:setEmbed(get_rules_react_msg())
		end) if not ok then log_me("Error: " .. err) end
	end

	local fn = make_safe(function() check_reminders() check_admin() end)

	TIMER.setInterval(1000, fn)
	
	for i = 1, #ready_functions do
		ready_functions[i]()
	end
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

client:on(
	"slashCommand",
	---@param int Interaction
	---@param cmd table
	---@param args table
	function(int, cmd, args)
		InteractionManager:process_interaction(int, cmd, args)
	end
)

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

client:run('Bot ' .. tostring(FS.readFileSync(".token")))