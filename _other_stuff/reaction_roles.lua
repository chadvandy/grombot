-- TODO move this entirely to a ?role_add command, instead of this reaction stuff

local reactions_to_roles = {
	pontus = "527982501344313381",
	grom = "438633999364128768",
	caged = "527984494221721621",
	othonk = "527982346461249538",
	lenny = "510186513917542401",
	deadpan = "617115832706793593",
	dab = "617124521660383248",
	fuck = "617115685910347842",
	slap = "777715970705326103",
	allcomingtogether = "805258050775678996",
	skreeee = "813355539488440351",
	boyo = "819603205120983091",
	siggy = "825129609087025233",
	settra = "938235392262545410",
}


function get_rules_react_msg()
	return {
		title = "Reaction Roles",
		-- color = 0xFF0000,
		description = "React with the following emojis to get the role! Modders will use these roles to notify peeps who opted-in about progress reports, updates and the such! If you reacted to a previous message, you will keep your roles. To revoke a role, simply remove your reaction!",
		fields = {
			{name = "<:pontus:391190040975507466> - CFU", value = "Notifications for Crynsos's Faction Unlocker and similar (<#373754956341313536>)"},
			{name = "<:grom:373750441844015114> - CTT", value = "Notifications for Cataph\'s Closer to Tabletop mod (<#375747157732491274>)"},
			{name = "<:caged:385182375270678548> - Cataph Etc.", value = "Notifications for other Cataph things (<#373754902608084994>)"},
			{name = "<:othonk:446745080704008193> - RPFM", value = "Notifications for Frodo\'s Rusted Pack File Manager (<#498934055564476416>)"},
			{name = "<:lenny:373750563193618442> - DF", value = "Notifications for DrunkFlamingo\'s work (<#413118111630360597>)"},
			{name = "<:deadpan:611224582308888578> - Mixu", value = "Notifications for all things Mixu (<#466624302897430530>)"},
			{name = "<:dab:559762293089370137> - OvN", value = "Notifications for the Old Versus New mods (<#581350078263066665>)"},
			{name = "<:fuck:469401867991121931> - Vandy", value = "Notifications for Vandy things (<#588478080692256789>)."},
			{name = "<:slap:690593395730677800> - ER", value = "Notifications for Expanded Rosters (<#614052756944322561>)."},
			{name = "<:allcomingtogether:652279996110602287> - Jam, not Jelly", value = "Notifications for Mod Jam events, organized by Vandy (<#798557550089601034>)."},
			{name = "<:skreeee:563696616444264449> - Rigging, Modeling, Animations, Oh My!", value = "Notifications for updates about Phazer's and h3ro's tools - RME (<#707230816887111690>) and the Asset Editor (<#795235087352201226>)."},
			{name = "<:boyo:436263911973584896> - We'z Speshul", value = "Notifications about the We'z Speshul mod series, by Lost2Insanity (<#743568448369459382>)."},
			{name = "<:siggy:442243620859412484> - KMM", value = "Notifications for the Kaedrin Mod Manager! (<#482251184980361256>)"},
			{name = "<:settra:374150074378223618> - Agemouk", value = "Notifications for all things Agemouk! (<#937702185536479272>)"}
		}
	}
end

---comment
---@param reaction Reaction
---@param userId string
function role_add_command(reaction, userId, hash, channel)
	printf("Adding role")
	local guild
	if reaction then
		guild = reaction.message.guild
	end

	if channel then
		guild = channel.guild
	end

	if not guild then printf("Guild not found!") return end

	local member = guild:getMember(userId)

	local emoji_name

	if reaction then
		emoji_name = reaction.emojiName
		-- printf("It's cached - grabbing emoji name %q", emoji_name)
	elseif hash then
		local emoji = guild:getEmoji(hash)
		emoji_name = emoji.name
		-- printf("Not cached - grabbing emoji name from guild, %q", emoji_name)
	end
	
	local role = reactions_to_roles[emoji_name]

	if not role then
		printf("No role found!")
		-- errmsg
		return
	end

	member:addRole(role)
end

function role_remove_command(reaction, userId, hash, channel)
	printf("Removing role!")
	local guild
	if reaction then
		guild = reaction.message.guild
	end

	if channel then
		guild = channel.guild
	end

	if not guild then printf("Guild not found!") return end

	local member = guild:getMember(userId)

	local emoji_name

	if reaction then
		emoji_name = reaction.emojiName
		-- printf("It's cached - grabbing emoji name %q", emoji_name)
	elseif hash then
		local emoji = guild:getEmoji(hash)
		if emoji then
			emoji_name = emoji.name
		end
		-- printf("Not cached - grabbing emoji name from guild, %q", emoji_name)
	end
	
	local role = reactions_to_roles[emoji_name]

	if not role then
		printf("No role found!")
		-- errmsg
		return
	end

	member:removeRole(role)
end