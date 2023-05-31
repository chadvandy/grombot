TEMPLATES = {}

VANDY = "364410374688342018"

GUILDS_AND_STUFF = {
	den = {
		id = "373745291289034763",
		channels = {
			rules = {
				id = "373746683537915913"
			}
		},
		roles = {
			modder = {
				id = "374532828169502731"
			}
		}
	}
}

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata

function _G.flush_random()
    math.randomseed(os.time())
    
    math.random()
    math.random()
    math.random()
    math.random()
    math.random()
end

local function sanitize(t)
    if not is_table(t) then return end
    for k,v in pairs(t) do
        if is_function(v) then
            t[k]=nil
        elseif is_table(v) then
            sanitize(v)
        end
    end

    return t
end

--- Saves the .json file for one of the databases.
---@param data_name string The database to save.
function save_data(data_name)
	if not is_string(data_name) then
		printf("Calling save_data(), but the data name supplied [%s] isn't a string!", tostring(data_name))
	end

	if not saved_data[data_name] then
		printf("ERROR! Trying to save data with name %q, but nothing with that key is found in the database!", data_name)
	end

    -- sanitize the data, remove all functions!
    local new_t = table.copy(saved_data[data_name])
    new_t = sanitize(new_t)

	FS.writeFileSync("json/"..data_name..".json", JSON.encode(new_t))
end

---@param member Member
function is_cnc_and_modder(member)
	local guild = member.guild
	if guild and guild.id == GUILDS_AND_STUFF.den.id then
		-- local user = message.author
		-- local member = guild:getMember(user)

		if not member then
			printf("Macro checking for is den & modder, but the author isn't a member? Wtf?")
			return false, "Macro checking for is den & modder, but the author isn't a member? Wtf?"
		end

		if not member:hasRole(GUILDS_AND_STUFF.den.roles.modder.id) then
			return false, "Only Modders can use this command!"
		end

		return true
	end

	return true
end

-- TODO call this more performatively
---@param member Member
function is_admin(member)
    print("Checking permissions for member")
    -- TODO use resolvable to grab the member, to allow ID's/User objects

	if not CLASS.isInstance(member, CLASS.classes.Member) then
		print("Not a member!")
		-- errmsg, not a member
		return false
	end

	local ret = member:hasPermission(nil, ENUMS.permission.banMembers)

	if not ret then
		return false, "<:raeg:418415373143113728> You have to be an admin to use admin commands. <:raeg:418415373143113728>"
	end

	return ret
end

function is_instance_of_class(obj, class_name)
	if not obj then return false end

	if not is_string(class_name) then
		-- errmsg, not a valid string
		return false
	end

	if not CLASS.classes[class_name] then	
		-- errmsg, not a valid class
		return false
	end

	return CLASS.isInstance(obj, CLASS.classes[class_name])
end

-- just grabs the expected quoted name, ie. ?macro "movie packs", grabs `movie packs`
--- Get the full string between two "'s
---@param str string
---@return string Name The string found, without quotatios.
---@return number Endpos The end position of the string, to use for finding stuff after this quoted string.
function get_quoted_name_from_string(str)
	printf("Testing %q for a set of quotes", str)
	local first_x = str:find("\"")
	local second_x
	if first_x then
		second_x = str:find("\"", first_x+1)
	end

	if not first_x or not second_x then
		return
	end

	local found_str = str:sub(first_x+1, second_x-1)

	printf("Found string: %q", found_str)

	return found_str, second_x+1
end

function get_quoted_name_and_remaining_from_string(str)
	local name, second_x = get_quoted_name_from_string(str)
	if not name then return end
	if second_x then
		local remainder = str:sub(second_x)
		return name, remainder
	end
end

---@param obj any
function is_command(obj)
	printf("Checking if %q is a command", tostring(obj))
	return string.sub(tostring(obj), 1, 8) == "COMMAND "
end

-- TODO whatever this was?
function string.discord_escape(str)
	return "```\n"..str.."\n```"
end

function random_unique(max, min, num)
    flush_random()

    for i = 1, num do
        
    end
end

--- Take an existing table, and copy the contents of another into it.
---@param t table
---@param o table
function table.copy_add(t, o)
	if not is_table(t) or not is_table(o) then return end

	for k,v in pairs(o) do
		if not t[k] then
			if is_table(v) then
				local new_t = {}
				v = table.copy_add(new_t, v)
			end

			t[k] = v
		end
	end

	return t
end

function table.random_sort(t)
    assert(is_table(t), "A table must be passed to table.random_sort()!")
    flush_random()

    local ret = {}
    local ran = math.random

    for i = 1, #t do
        local value = t[i]
        local offset = i - 1

        local random_index = offset*ran()
        random_index = random_index - random_index % 1

        if random_index == offset then
            ret[#ret+1] = value
        else
            ret[#ret+1] = ret[random_index+1]
            ret[random_index+1] = value
        end
    end

    return ret
end

-- --- Pack any vararg with all parameters stored into arrayed keys.
-- ---@vararg any
-- function table.pack(...)
-- 	return { n = select("#", ...), ... }
-- end

--- Acts as "pairs()" but automatically sorts a table by keys, in alphabetical order.
---@param t table<string, any> The table to iterate!
---@param func function|nil An optional function to sort by,
function _G.pairs_by_keys(t, func)
    local ordered_keys = {}
    for key,_ in pairs(t) do ordered_keys[#ordered_keys+1] = key end
    table.sort(ordered_keys, func)

    local i = 0
    local function iter()
        i = i + 1
        if ordered_keys[i] == nil then return nil end

        local key = ordered_keys[i]
        return key, t[key]
    end
    return iter
end

function safe_format(str, ...)
	if not is_string(str) then return "" end

	local old_str = str
	-- local vararg = ...
	if ... then
		local ok, err = pcall(function(...)
			str = string.format(str, ...)
		end, ...)

		if not ok then
			printf(err)
			return old_str,err
		end
	end

	return str
end

---@param str string
---@vararg any
function printf(str, ...)
	local str, err = safe_format(str, ...)
	print(str)
	if err then errmsg(err) end
end

---@param channel TextChannel|GuildChannel|GuildTextChannel
---@param str string
---@vararg string
function sendf(channel, str, ...)
    if not CLASS.isInstance(channel, CLASS.classes.TextChannel) then return end

	local str, err = safe_format(str, ...)
	if err then errmsg(err) end
	local ok, err = channel:send(str)

    if not ok then errmsg(err) end
end


--- @param t table
--- @param ignored_fields table<string>
--- @param loop_value number
--- @return table<string>
local function inner_loop_fast_print(t, ignored_fields, loop_value)
    --- @type table<any>
	local table_string = {'{\n'}
	--- @type table<any>
	local temp_table = {}
    for key, value in pairs(t) do
        table_string[#table_string + 1] = string.rep('\t', loop_value + 1)

        if type(key) == "string" then
            table_string[#table_string + 1] = '["'
            table_string[#table_string + 1] = key
            table_string[#table_string + 1] = '"] = '
        elseif type(key) == "number" then
            table_string[#table_string + 1] = '['
            table_string[#table_string + 1] = key
            table_string[#table_string + 1] = '] = '
        else
            table_string[#table_string + 1] = '['
            table_string[#table_string + 1] = tostring(key)
            table_string[#table_string + 1] = '] = '
        end

		if type(value) == "table" then
			temp_table = inner_loop_fast_print(value, ignored_fields, loop_value + 1)
			for i = 1, #temp_table do
				table_string[#table_string + 1] = temp_table[i]
			end
		elseif type(value) == "string" then
			table_string[#table_string + 1] = '[=['
			table_string[#table_string + 1] = value
			table_string[#table_string + 1] = ']=],\n'
		else
			table_string[#table_string + 1] = tostring(value)
			table_string[#table_string + 1] = ',\n'
		end
    end

	table_string[#table_string + 1] = string.rep('\t', loop_value)
    table_string[#table_string + 1] = "},\n"

    return table_string
end

--- @param t table
--- @param ignored_fields table<string>?
--- @return string|boolean
function _G.fast_print(t, ignored_fields)
    if not (type(t) == "table") then
        return "false"
    end

    --- @type table<any>
    local table_string = {'{\n'}
	--- @type table<any>
	local temp_table = {}

    for key, value in pairs(t) do

        table_string[#table_string + 1] = string.rep('\t', 1)
        if type(key) == "string" then
            table_string[#table_string + 1] = '["'
            table_string[#table_string + 1] = key
            table_string[#table_string + 1] = '"] = '
        elseif type(key) == "number" then
            table_string[#table_string + 1] = '['
            table_string[#table_string + 1] = key
            table_string[#table_string + 1] = '] = '
        else
            --- TODO skip it somehow?
            table_string[#table_string + 1] = '['
            table_string[#table_string + 1] = tostring(key)
            table_string[#table_string + 1] = '] = '
        end

        if type(value) == "table" then
            temp_table = inner_loop_fast_print(value, ignored_fields, 1)
            for i = 1, #temp_table do
                table_string[#table_string + 1] = temp_table[i]
            end
        elseif type(value) == "string" then
            table_string[#table_string + 1] = '[=['
            table_string[#table_string + 1] = value
            table_string[#table_string + 1] = ']=],\n'
        elseif type(value) == "boolean" or type(value) == "number" then
            table_string[#table_string + 1] = tostring(value)
            table_string[#table_string + 1] = ',\n'
        else
            -- unsupported type, technically.
            table_string[#table_string+1] = "nil,\n"
        end
    end

    table_string[#table_string + 1] = "}\n"

    return table.concat(table_string)
end

local private_channel
local _gId, _cId = "531219831861805067", "1010311107640033301"
function _G.errmsg(text)
    local guild_id = "531219831861805067"
    local channel_id = "1010311107640033301"
    text = tostring(text)
    
    local t = "<@364410374688342018>, script error!\n%s\n%s"
    
    text = string.format(t, text, debug.traceback("", 2))
    printf(text)

    if not private_channel then
        private_channel = client:getGuild(_gId):getChannel(_cId)
    end

	sendf(private_channel, text)
end

function _G.inform(text)
    local guild_id = "531219831861805067"
    local channel_id = "1010311107640033301"
    
    text = string.format("<@364410374688342018>\n%s", tostring(text))
    
	local channel = client:getGuild(guild_id):getChannel(channel_id)
	sendf(channel, text)
end

local utf8 = require 'utf8'
local floor = math.floor

local function dkjson_isarray(tbl)
    local max, n, arraylen = 0, 0, 0
    for k, v in pairs(tbl) do
        if k == 'n' and type(v) == 'number' then
            arraylen = v
            if v > max then
                max = v
            end
        else
            if type(k) ~= 'number' or k < 1 or floor(k) ~= k then
                return false, 'non-sequential key: ' .. tostring(k)
            end
            if k > max then
                max = k
            end
            n = n + 1
        end
    end
    if max > 10 and max > arraylen and max > n * 2 then
        return false, 'too many holes' -- don't create an array with too many holes
    end
    return true
end

---Validates a Discord message for consumption by Discordia's send function.
---@param message Message
---@return boolean
---@return string? #Position and description of what is invalid
function validate_msg(message)
    local has_content = false

    if message.content ~= nil then
        if type(message.content) ~= 'string' then
            return false, 'message.content: wrong type (expected string or nil, got ' .. type(message.content) .. ')'
        elseif utf8.len(message.content) < 1 then
            return false, 'message.content: too small (' .. utf8.len(message.content) .. ' < 1)'
        elseif utf8.len(message.content) > 256 then
            return false, 'message.content: too large (' .. utf8.len(message.content) .. ' > 256)'
        end

        has_content = true
    end

    if message.embed ~= nil then
        if type(message.embed) ~= 'table' then
            return false, 'message.embed: wrong type (expected table or nil, got ' .. type(message.embed) .. ')'
        end

        local valid, why = validate_embed(message.embed, 'message.embed')
        if not valid then
            return false, why
        end

        has_content = true
    end

    if not has_content then
        return false, 'message: must contain one of `content`, `embed`'
    end

    if message.tts ~= nil then
        if type(message.tts) ~= 'boolean' then
            return false, 'message.tts: wrong type (expected boolean or nil, got ' .. type(message.tts) .. ')'
        end
    end

    if message.nonce ~= nil then
        if type(message.nonce) ~= 'number' and type(message.nonce) ~= 'string' then
            return false, 'message.nonce: wrong type (expected string or number or nil, got ' .. type(message.nonce) .. ')'
        end
    end

    return true
end

---Validates a Discord message embed for consumption by Discordia's send function.
---@param embed table
---@return boolean
---@return string? #Position and description of what is invalid
function _G.validate_embed(embed, prefix)
    prefix = prefix or 'embed'
    local total_size = 0

    if embed.title ~= nil then
        if type(embed.title) ~= 'string' then
            return false, prefix .. '.title: wrong type (expected string or nil, got ' .. type(embed.title) .. ')'
        -- elseif utf8.len(embed.title) < 1 then
        --     return false, prefix .. '.title: too small (' .. utf8.len(embed.title) .. ' < 1)'
        elseif utf8.len(embed.title) > 256 then
            return false, prefix .. '.title: too large (' .. utf8.len(embed.title) .. ' > 256)'
        end

        total_size = total_size + utf8.len(embed.title)
    end

    if embed.type ~= nil then
        return false, prefix .. '.type: wrong type (expected nil, got ' .. type(embed.type) .. ')'
    end

    if embed.description ~= nil then
        if type(embed.description) ~= 'string' then
            return false, prefix .. '.description: wrong type (expected string or nil, got ' .. type(embed.description) .. ')'
        -- elseif utf8.len(embed.description) < 1 then
        --     return false, prefix .. '.description: too small (' .. utf8.len(embed.description) .. ' < 1)'
        elseif utf8.len(embed.description) > 2048 then
            return false, prefix .. '.description: too large (' .. utf8.len(embed.description) .. ' > 2048)'
        end

        total_size = total_size + utf8.len(embed.description)
    end

    if embed.url ~= nil then
        if type(embed.url) ~= 'string' then
            return false, prefix .. '.url: wrong type (expected string or nil, got ' .. type(embed.url) .. ')'
        end
    end

    if embed.timestamp ~= nil then
        -- TODO: validate ISO-8601 (using Discordia?)
        if type(embed.timestamp) ~= 'string' then
            return false, prefix .. '.timestamp: wrong type (expected string or nil, got ' .. type(embed.timestamp) .. ')'
        end
    end

    if embed.color ~= nil then
        if type(embed.color) ~= 'number' then
            return false, prefix .. '.color: wrong type (expected number or nil, got ' .. type(embed.color) .. ')'
        elseif embed.color < 0 then
            return false, prefix .. '.color: too small (' .. embed.color .. ' < 0)'
        elseif embed.color > 16777215 then
            return false, prefix .. '.color: too large (' .. embed.color .. ' > 16777215)'
        end
    end

    if embed.footer ~= nil then
        if type(embed.footer) ~= 'table' then
            return false, prefix .. '.footer: wrong type (expected table or nil, got ' .. type(embed.footer) .. ')'
        end

        if type(embed.footer.text) ~= 'string' then
            return false, prefix .. '.footer.text: wrong type (expected string, got ' .. type(embed.footer.text) .. ')'
        elseif utf8.len(embed.footer.text) < 1 then
            return false, prefix .. '.footer.text: too small (' .. utf8.len(embed.footer.text) .. ' < 1)'
        elseif utf8.len(embed.footer.text) > 2048 then
            return false, prefix .. '.footer.text: too large (' .. utf8.len(embed.footer.text) .. ' > 2048)'
        end

        total_size = total_size + utf8.len(embed.footer.text)

        if embed.footer.icon_url ~= nil then
            if type(embed.footer.icon_url) ~= 'string' then
                return false, prefix .. '.footer.icon_url: wrong type (expected string or nil, got ' .. type(embed.footer.icon_url) .. ')'
            end
        end

        if type(embed.footer.proxy_icon_url) ~= 'nil' then
            return false, prefix .. '.footer.proxy_icon_url: wrong type (expected nil, got ' .. type(embed.footer.proxy_icon_url) .. ')'
        end
    end

    if embed.image ~= nil then
        if type(embed.image) ~= 'table' then
            return false, prefix .. '.image: wrong type (expected table or nil, got ' .. type(embed.image) .. ')'
        end

        if embed.image.url ~= nil then
            if type(embed.image.url) ~= 'string' then
                return false, prefix .. '.image.url: wrong type (expected string or nil, got ' .. type(embed.image.url) .. ')'
            end
        end

        if embed.image.proxy_url ~= nil then
            return false, prefix .. '.image.proxy_url: wrong type (expected nil, got ' .. type(embed.image.proxy_url) .. ')'
        end

        if embed.image.height ~= nil then
            return false, prefix .. '.image.height: wrong type (expected nil, got ' .. type(embed.image.height) .. ')'
        end

        if embed.image.width ~= nil then
            return false, prefix .. '.image.width: wrong type (expected nil, got ' .. type(embed.image.width) .. ')'
        end
    end

    if embed.thumbnail ~= nil then
        if type(embed.thumbnail) ~= 'table' then
            return false, prefix .. '.thumbnail: wrong type (expected table or nil, got ' .. type(embed.thumbnail) .. ')'
        end

        if embed.thumbnail.url ~= nil then
            if type(embed.thumbnail.url) ~= 'string' then
                return false, prefix .. '.thumbnail.url: wrong type (expected string or nil, got ' .. type(embed.thumbnail.url) .. ')'
            end
        end

        if embed.thumbnail.proxy_url ~= nil then
            return false, prefix .. '.thumbnail.proxy_url: wrong type (expected nil, got ' .. type(embed.thumbnail.proxy_url) .. ')'
        end

        if embed.thumbnail.height ~= nil then
            return false, prefix .. '.thumbnail.height: wrong type (expected nil, got ' .. type(embed.thumbnail.height) .. ')'
        end

        if embed.thumbnail.width ~= nil then
            return false, prefix .. '.thumbnail.width: wrong type (expected nil, got ' .. type(embed.thumbnail.width) .. ')'
        end
    end

    if embed.video ~= nil then
        return false, prefix .. '.video: wrong type (expected nil, got ' .. type(embed.video) .. ')'
    end

    if embed.provider ~= nil then
        return false, prefix .. '.provider: wrong type (expected nil, got ' .. type(embed.provider) .. ')'
    end

    if embed.author ~= nil then
        if type(embed.author) ~= 'table' then
            return false, prefix .. '.author: wrong type (expected table or nil, got ' .. type(embed.author) .. ')'
        end

        if embed.author.name ~= nil then
            if type(embed.author.name) ~= 'string' then
                return false, prefix .. '.author.name: wrong type (expected string or nil, got ' .. type(embed.author.name) .. ')'
            elseif utf8.len(embed.author.name) < 1 then
                return false, prefix .. '.author.name: too small (' .. utf8.len(embed.author.name) .. ' < 1)'
            elseif utf8.len(embed.author.name) > 256 then
                return false, prefix .. '.author.name: too large (' .. utf8.len(embed.author.name) .. ' > 256)'
            end
        end

        total_size = total_size + utf8.len(embed.author.name)

        if embed.author.url ~= nil then
            if type(embed.author.url) ~= 'string' then
                return false, prefix .. '.author.url: wrong type (expected string or nil, got ' .. type(embed.author.url) .. ')'
            end
        end

        if embed.author.icon_url ~= nil then
            if type(embed.author.icon_url) ~= 'string' then
                return false, prefix .. '.author.icon_url: wrong type (expected string or nil, got ' .. type(embed.author.icon_url) .. ')'
            end
        end

        if type(embed.author.proxy_icon_url) ~= 'nil' then
            return false, prefix .. '.author.proxy_icon_url: wrong type (expected nil, got ' .. type(embed.author.proxy_icon_url) .. ')'
        end
    end

    if embed.fields ~= nil then
        if type(embed.fields) ~= 'table' then
            return false, prefix .. '.fields: wrong type (expected table or nil, got ' .. type(embed.fields) .. ')'
        end

        local is_array, why = dkjson_isarray(embed.fields)
        if not is_array then
            return false, prefix .. '.fields: not an array (' .. why .. ')'
        end

        if #embed.fields > 25 then
            return false, prefix .. '.fields: too large (' .. #embed.fields .. ' > 25)'
        end

        for i = 1, #embed.fields do
            local field = embed.fields[i]

            if not field or type(field) ~= 'table' then
                return false, prefix .. '.fields[' .. i .. ']: wrong type (expected table, got ' .. type(field) .. ')'
            end

            if type(field.name) ~= 'string' then
                return false, prefix .. '.fields[' .. i .. '].name: wrong type (expected string, got ' .. type(field.name) .. ')'
            elseif utf8.len(field.name) < 0 then
                return false, prefix .. '.fields[' .. i .. '].name: too small (' .. utf8.len(field.name) .. ' < 0)'
            elseif utf8.len(field.name) > 256 then
                return false, prefix .. '.fields[' .. i .. '].name: too large (' .. utf8.len(field.name) .. ' > 256)'
            end

            total_size = total_size + utf8.len(field.name)

            if type(field.value) ~= 'string' then
                return false, prefix .. '.fields[' .. i .. '].value: wrong type (expected string, got ' .. type(field.value) .. ')'
            elseif utf8.len(field.value) < 0 then
                return false, prefix .. '.fields[' .. i .. '].value: too small (' .. utf8.len(field.value) .. ' < 0)'
            elseif utf8.len(field.value) > 1024 then
                return false, prefix .. '.fields[' .. i .. '].value: too large (' .. utf8.len(field.value) .. ' > 1024)'
            end

            total_size = total_size + utf8.len(field.value)

            if field.inline ~= nil then
                if type(field.inline) ~= 'boolean' then
                    return false, prefix .. '.fields[' .. i .. '].inline: wrong type (expected boolean or nil, got ' .. type(field.inline) .. ')'
                end
            end
        end
    end

    if total_size > 6000 then
        return false, prefix .. ': embed content exceeds 6000 characters'
    end

    return true
end

-- ---Validates a Discord message embed for consumption by Discordia's send function.
-- ---@param embed table
-- ---@return boolean
-- ---@error Position and description of what is invalid
-- function validate_embed(embed, prefix)
--     prefix = prefix or 'embed'
--     local total_size = 0

-- 	local proper_embed = {}
-- 	local errors = {}

-- 	local function add_total(num)
-- 		total_size = total_size + num
-- 		if total_size == 6000 then
-- 			-- abort!
-- 			return true
-- 		elseif total_size > 6000 then
-- 			errors[#errors+1] = prefix .. ': embed content exceeds 6000 characters'
-- 			return true
-- 		end

-- 		return false
-- 	end

--     if embed.title ~= nil then
-- 		local str = embed.title
--         if type(str) ~= 'string' then
-- 			errors[#errors+1] = prefix .. '.title: wrong type (expected string or nil, got ' .. tostring(str) .. ')'
--         elseif utf8.len(str) < 1 then
--             errors[#errors+1] = prefix .. '.title: too small (' .. utf8.len(str) .. ' < 1)'
--         elseif utf8.len(str) > 256 then
-- 			proper_embed.title = string.sub(str, 1, 256)
--             errors[#errors+1] = prefix .. '.title: too large (' .. utf8.len(str) .. ' > 256)'
-- 		else
-- 			proper_embed.title = str
--         end

-- 		if add_total(utf8.len(proper_embed.title)) then
-- 			return proper_embed
-- 		end
--     end

--     if embed.type ~= nil then
--         errors[#errors+1] = prefix .. '.type: wrong type (expected nil, got ' .. type(embed.type) .. ')'
--     end

--     if embed.description ~= nil then
-- 		local str = embed.description
--         if type(str) ~= 'string' then
--             errors[#errors+1] = prefix .. '.description: wrong type (expected string or nil, got ' .. type(embed.description) .. ')'
--         elseif utf8.len(embed.description) < 1 then
--             errors[#errors+1] = prefix .. '.description: too small (' .. utf8.len(embed.description) .. ' < 1)'
--         elseif utf8.len(embed.description) > 2048 then
-- 			proper_embed.description = string.sub(str, 1, 2048)
--             errors[#errors+1] = prefix .. '.description: too large (' .. utf8.len(embed.description) .. ' > 2048)'
-- 		else
-- 			proper_embed.description = str
--         end

-- 		if add_total(utf8.len(proper_embed.description)) then
-- 			return proper_embed
-- 		end
--     end

--     if embed.url ~= nil then
--         if type(embed.url) ~= 'string' then
--             errors[#errors+1] = prefix .. '.url: wrong type (expected string or nil, got ' .. type(embed.url) .. ')'
-- 		else
-- 			proper_embed.url = embed.url
--         end
--     end

-- 	-- TODO
--     if embed.timestamp ~= nil then
--         -- TODO: validate ISO-8601 (using Discordia?)
--         if type(embed.timestamp) ~= 'string' then
--             return false, prefix .. '.timestamp: wrong type (expected string or nil, got ' .. type(embed.timestamp) .. ')'
--         end
--     end

-- 	-- TODO
--     if embed.color ~= nil then
--         if type(embed.color) ~= 'number' then
--             return false, prefix .. '.color: wrong type (expected number or nil, got ' .. type(embed.color) .. ')'
--         elseif embed.color < 0 then
--             return false, prefix .. '.color: too small (' .. embed.color .. ' < 0)'
--         elseif embed.color > 16777215 then
--             return false, prefix .. '.color: too large (' .. embed.color .. ' > 16777215)'
--         end
--     end

--     if embed.footer ~= nil then
--         if type(embed.footer) ~= 'table' then
--             errors[#errors+1] = prefix .. '.footer: wrong type (expected table or nil, got ' .. type(embed.footer) .. ')'
-- 		else
-- 			proper_embed.footer = {}
-- 			if type(embed.footer.text) ~= 'string' then
-- 				errors[#errors+1] = prefix .. '.footer.text: wrong type (expected string, got ' .. type(embed.footer.text) .. ')'
-- 			elseif utf8.len(embed.footer.text) < 1 then
-- 				errors[#errors+1] = prefix .. '.footer.text: too small (' .. utf8.len(embed.footer.text) .. ' < 1)'
-- 			elseif utf8.len(embed.footer.text) > 2048 then
-- 				proper_embed.footer.text = string.sub(embed.footer.text, 1, 2048)
-- 				errors[#errors+1] = prefix .. '.footer.text: too large (' .. utf8.len(embed.footer.text) .. ' > 2048)'
-- 			else
-- 				proper_embed.footer.text = embed.footer.text
-- 			end

-- 			if add_total(utf8.len(proper_embed.footer.text)) then
-- 				return proper_embed
-- 			end

-- 			if embed.footer.icon_url ~= nil then
-- 				if type(embed.footer.icon_url) ~= 'string' then
-- 					return false, prefix .. '.footer.icon_url: wrong type (expected string or nil, got ' .. type(embed.footer.icon_url) .. ')'
-- 				end
-- 			end
	
-- 			if type(embed.footer.proxy_icon_url) ~= 'nil' then
-- 				return false, prefix .. '.footer.proxy_icon_url: wrong type (expected nil, got ' .. type(embed.footer.proxy_icon_url) .. ')'
-- 			end
--         end
--     end

--     if embed.image ~= nil then
--         if type(embed.image) ~= 'table' then
--             return false, prefix .. '.image: wrong type (expected table or nil, got ' .. type(embed.image) .. ')'
--         end

--         if embed.image.url ~= nil then
--             if type(embed.image.url) ~= 'string' then
--                 return false, prefix .. '.image.url: wrong type (expected string or nil, got ' .. type(embed.image.url) .. ')'
--             end
--         end

--         if embed.image.proxy_url ~= nil then
--             return false, prefix .. '.image.proxy_url: wrong type (expected nil, got ' .. type(embed.image.proxy_url) .. ')'
--         end

--         if embed.image.height ~= nil then
--             return false, prefix .. '.image.height: wrong type (expected nil, got ' .. type(embed.image.height) .. ')'
--         end

--         if embed.image.width ~= nil then
--             return false, prefix .. '.image.width: wrong type (expected nil, got ' .. type(embed.image.width) .. ')'
--         end
--     end

--     if embed.thumbnail ~= nil then
--         if type(embed.thumbnail) ~= 'table' then
--             return false, prefix .. '.thumbnail: wrong type (expected table or nil, got ' .. type(embed.thumbnail) .. ')'
--         end

--         if embed.thumbnail.url ~= nil then
--             if type(embed.thumbnail.url) ~= 'string' then
--                 return false, prefix .. '.thumbnail.url: wrong type (expected string or nil, got ' .. type(embed.thumbnail.url) .. ')'
--             end
--         end

--         if embed.thumbnail.proxy_url ~= nil then
--             return false, prefix .. '.thumbnail.proxy_url: wrong type (expected nil, got ' .. type(embed.thumbnail.proxy_url) .. ')'
--         end

--         if embed.thumbnail.height ~= nil then
--             return false, prefix .. '.thumbnail.height: wrong type (expected nil, got ' .. type(embed.thumbnail.height) .. ')'
--         end

--         if embed.thumbnail.width ~= nil then
--             return false, prefix .. '.thumbnail.width: wrong type (expected nil, got ' .. type(embed.thumbnail.width) .. ')'
--         end
--     end

--     if embed.video ~= nil then
--         return false, prefix .. '.video: wrong type (expected nil, got ' .. type(embed.video) .. ')'
--     end

--     if embed.provider ~= nil then
--         return false, prefix .. '.provider: wrong type (expected nil, got ' .. type(embed.provider) .. ')'
--     end

--     if embed.author ~= nil then
--         if type(embed.author) ~= 'table' then
--             return false, prefix .. '.author: wrong type (expected table or nil, got ' .. type(embed.author) .. ')'
--         end

--         if embed.author.name ~= nil then
--             if type(embed.author.name) ~= 'string' then
--                 return false, prefix .. '.author.name: wrong type (expected string or nil, got ' .. type(embed.author.name) .. ')'
--             elseif utf8.len(embed.author.name) < 1 then
--                 return false, prefix .. '.author.name: too small (' .. utf8.len(embed.author.name) .. ' < 1)'
--             elseif utf8.len(embed.author.name) > 256 then
--                 return false, prefix .. '.author.name: too large (' .. utf8.len(embed.author.name) .. ' > 256)'
--             end
--         end

--         total_size = total_size + utf8.len(embed.author.name)

--         if embed.author.url ~= nil then
--             if type(embed.author.url) ~= 'string' then
--                 return false, prefix .. '.author.url: wrong type (expected string or nil, got ' .. type(embed.author.url) .. ')'
--             end
--         end

--         if embed.author.icon_url ~= nil then
--             if type(embed.author.icon_url) ~= 'string' then
--                 return false, prefix .. '.author.icon_url: wrong type (expected string or nil, got ' .. type(embed.author.icon_url) .. ')'
--             end
--         end

--         if type(embed.author.proxy_icon_url) ~= 'nil' then
--             return false, prefix .. '.author.proxy_icon_url: wrong type (expected nil, got ' .. type(embed.author.proxy_icon_url) .. ')'
--         end
--     end

--     if embed.fields ~= nil then
--         if type(embed.fields) ~= 'table' then
--             return false, prefix .. '.fields: wrong type (expected table or nil, got ' .. type(embed.fields) .. ')'
--         end

--         local is_array, why = dkjson_isarray(embed.fields)
--         if not is_array then
--             return false, prefix .. '.fields: not an array (' .. why .. ')'
--         end

--         if #embed.fields > 25 then
--             return false, prefix .. '.fields: too large (' .. #embed.fields .. ' > 25)'
--         end

--         for i = 1, #embed.fields do
--             local field = embed.fields[i]

--             if type(field) ~= 'table' then
--                 return false, prefix .. '.fields[' .. i .. ']: wrong type (expected table, got ' .. type(field) .. ')'
--             end

--             if type(field.name) ~= 'string' then
--                 return false, prefix .. '.fields[' .. i .. '].name: wrong type (expected string, got ' .. type(field.name) .. ')'
--             elseif utf8.len(field.name) < 1 then
--                 return false, prefix .. '.fields[' .. i .. '].name: too small (' .. utf8.len(field.name) .. ' < 1)'
--             elseif utf8.len(field.name) > 256 then
--                 return false, prefix .. '.fields[' .. i .. '].name: too large (' .. utf8.len(field.name) .. ' > 256)'
--             end

--             total_size = total_size + utf8.len(embed.field.name)

--             if type(field.value) ~= 'string' then
--                 return false, prefix .. '.fields[' .. i .. '].value: wrong type (expected string, got ' .. type(field.value) .. ')'
--             elseif utf8.len(field.value) < 1 then
--                 return false, prefix .. '.fields[' .. i .. '].value: too small (' .. utf8.len(field.value) .. ' < 1)'
--             elseif utf8.len(field.value) > 1024 then
--                 return false, prefix .. '.fields[' .. i .. '].value: too large (' .. utf8.len(field.value) .. ' > 1024)'
--             end

--             total_size = total_size + utf8.len(embed.field.value)

--             if field.inline ~= nil then
--                 if type(field.inline) ~= 'string' then
--                     return false, prefix .. '.fields[' .. i .. '].inline: wrong type (expected boolean or nil, got ' .. type(field.inline) .. ')'
--                 end
--             end
--         end
--     end

--     if total_size > 6000 then
--         return false, 
--     end

--     return true
-- end

-- validity checker for embeds to prevent hard crashes
function send_embed(channel, embed)
	if not is_instance_of_class(channel, "Channel") then return end
	if not is_table(embed) then return end

	local ok, err = validate_embed(embed)
	if ok then
		channel:send({embed=embed})
	else
		errmsg(err)
	end
end

_G.send_embed = send_embed

function make_safe(fn)
	if not type(fn) == "function" then
		-- err 
		return false
	end

	return coroutine.wrap(function(...)
		fn(...)
		while true do
			fn(coroutine.yield())
		end
	end)
end
	
---@param time_msg string
function get_ms_from_time(time_msg)
	if not type(time_msg) == "string" then
		printf("get_ms_from_time called with an invalid arg passed, %s", tostring(time_msg))
		return
	end

	local time_tags = {
		s = 1,
		m = 60,
		h = 3600,
		d = 86400,
	}

	printf("get ms from time %s", time_msg)

	local ms_delay = tonumber(string.sub(time_msg, 1, -2))
	local time_tag = tostring(string.sub(time_msg, -1, -1))
	if not is_number(ms_delay) and (not is_string(time_tag) or not time_tags[time_tag]) then
		return false, "You have to pass in a time string, ie. `5s`, where 5 is the number and s is the time tag. Valid time tags are s/m/h/d, for seconds/minutes/hours/days."
	end

	if not is_number(ms_delay) then
		return nil, "You have to pass a number to the time-string, ie. `5s`, where 5 is the number!"
	end

	-- get the s/m/h/d tag
	if not is_string(time_tag) then
		return nil, "You have to pass a time tag to the time-string, ie. `5s`, where s is the time tag! Valid time tags are s/m/h/d, for seconds/minutes/hours/days."
	end

	if not time_tags[time_tag] then
		return nil, "The time tag passed, \"" ..time_tag .."\" is not a valid time tag! Only valid ones are s/m/h/d, for seconds/minutes/hours/days."
	end

	printf("ms_delay: %d\ntime_tag: %s", tonumber(ms_delay), tostring(time_tag))

	ms_delay = ms_delay * time_tags[time_tag]

	printf("ms_delay: %d", ms_delay)

	return ms_delay
end

---- Very first thing, override Emitter to use named listeners and the like
do
	local ok, err = pcall(function()
	local function new(self, name, listener)
		local listeners = self._listeners[name]
		if not listeners then
			listeners = {}
			self._listeners[name] = listeners
		end

		if not listener.key or not is_string(listener.key) then
			listener.key = self:_generate_unique_key(name)
		end

		table.insert(listeners, listener)
		return listener.fn
	end

	function EMITTER:_generate_unique_key(event_name)
		local listeners = self._listeners[event_name]
		if not listeners then
			listeners = {}
		end

		return event_name.."_"..#listeners+1
	end
	
	rawset(EMITTER, "on", function(self, name, fn, key)
		return new(self, name, {fn = fn, key = key})
	end)

	rawset(EMITTER, "once", function(self, name, fn, key)
		return new(self, name, {fn = fn, once = true, key = key})
	end)

	rawset(EMITTER, "onSync", function(self, name, fn, key)
		return new(self, name, {fn = fn, sync = true, key = key})
	end)
	
	rawset(EMITTER, "onceSync", function(self, name, fn, key)
		return new(self, name, {fn = fn, once = true, sync = true, key = key})
	end)

	rawset(EMITTER, "removeListener", function(self, name, fn)
		printf("Calling Vandy's special remove listener!")
		local listeners = self._listeners[name]
		if not listeners then return end
		for i, listener in ipairs(listeners) do
			if is_function(fn) then
				if listener and listener.fn == fn then
					listeners[i] = false
				end
			elseif is_string(fn) then
				if listener and listener.key == fn then
					listeners[i] = false
				end
			end
		end
		listeners._removed = true
	end)

	function client:_generate_unique_key(event_name)
		local listeners = self._listeners[event_name]
		if not listeners then
			listeners = {}
		end

		return event_name.."_"..#listeners+1
	end

	rawset(client, "on", function(self, name, fn, key)
		return new(self, name, {fn = fn, key = key})
	end)

	rawset(client, "once", function(self, name, fn, key)
		return new(self, name, {fn = fn, once = true, key = key})
	end)

	rawset(client, "onSync", function(self, name, fn, key)
		return new(self, name, {fn = fn, sync = true, key = key})
	end)
	
	rawset(client, "onceSync", function(self, name, fn, key)
		return new(self, name, {fn = fn, once = true, sync = true, key = key})
	end)

	rawset(client, "removeListener", function(self, name, fn)
		printf("Calling Vandy's special remove listener!")
		local listeners = self._listeners[name]
		if not listeners then return end
		for i, listener in ipairs(listeners) do
			if is_function(fn) then
				if listener and listener.fn == fn then
					listeners[i] = false
				end
			elseif is_string(fn) then
				if listener and listener.key == fn then
					listeners[i] = false
				end
			end
		end
		listeners._removed = true
	end)

	end) if not ok then printf(err) end
end