---@class prompt
local Prompt = {}

-- Prompt metatable
local __Prompt = {
    __index = Prompt,
    __tostring = function(me) return "Prompt ["..me._key.."]" end
}

local footer_string = "Page %d of %d"

-- TODO refresh embed w/ all "set_xxx" methods
-- TODO OOP queries

--- Create a new Prompt.
---@param key string
---@param channel GuildTextChannel
---@return prompt
function Prompt.new(key, channel)
    if not is_string(key) then return error("Tried to call a new Prompt, but the key provided wasn't a string!") end
    if not is_instance_of_class(channel, "Channel") then return error("Tried to create a new Prompt, but the channel provided wasn't valid!") end

    ---@type prompt
    local o = {}
    setmetatable(o, __Prompt)

    o._key = key

    ---@type GuildTextChannel
    o._channel = channel

    o._users = {}

    o._current_page = 1
    o._total_pages = 1
    o._fields_per_page = 10
    o._timeout_ms = 300000

    o._fields = {}
    o._valid = nil

    o._reactions = {

    }

    o._queries = {}
    o._query_cleanup = {}

    o._reactions_to_funcs = {

    }

    o._description = ""
    o._footer = ""

    o._embed = {
        title = "",
        description = "",
        fields = {},
    }

    ---@type Message
    o._message = nil
    o._timer = nil

    o._goodbye_callback = function(self) end

    return o
end

function Prompt:set_default_reactions()
    self:set_reactions({
        {
            "⏪",
            function(o, user_id)
                o:set_page(1)
            end,
        },
        {
            "◀️",
            function(o)
                o:set_page(o._current_page - 1)
            end,
        },
        {
            "⏹️",
            function(o)
                o:goodbye()
            end,
        },
        {
            "▶️",
            function(o)
                o:set_page(o._current_page + 1)
            end,
        },
        {
            "⏩",
            function(o)
                o:set_page(o._total_pages)
            end,
        }
    }
)
end

--- Using this command will add the fields added in nav:set_fields() to the description, instead of separate fields.
---@param b boolean|nil
function Prompt:set_fields_is_description(b)
    if b == nil then b = true end

    if self._embed.description ~= "" then
        printf("Trying to use the description for fields, for navigator w/ key %q, but there's already a description set!", self._key)
    end

    self._fields_is_description = b
end

function Prompt:set_footer(text)
    if text and not is_string(text) then return end
    self._footer = text
end

function Prompt:set_fields(data)
    if not is_table(data) then return end

    self._fields = data
    self._total_pages = math.ceil(#self._fields / self._fields_per_page)
end

function Prompt:add_field(field_tab)
    if not is_table(field_tab) then return end

    self._fields[#self._fields+1] = field_tab
    self._total_pages = math.ceil(#self._fields / self._fields_per_page)
end

function Prompt:set_title(title_text)
    if not is_string(title_text) then return end
    self._embed.title = title_text
end

function Prompt:set_description(description_text)
    if not is_string(description_text) then return end
    self._description = description_text
end

function Prompt:set_fields_per_page(num)
    if not is_number(num) then return end
    num = math.clamp(num, 1, 20)

    self._fields_per_page = num
end

function Prompt:handle_fields(current)
    local total = 6000

    local field_num = (self._fields_per_page * (self._current_page -1)) + 1
    local field_end = field_num + self._fields_per_page -1
    if field_end > #self._fields then field_end = #self._fields end

    if self._fields_is_description then
        local str = table.concat(self._fields, "\n", field_num, field_end)
        if self._description ~= "" then
            str = self._description .. "\n\n" .. str
        end

        self._embed.description = str
    else
        if self._description ~= "" then
            self._embed.description = self._description
        end

        self._embed.fields = {}

        for i = field_num, field_end do
            local field = self._fields[i]
            if field then
                local name = field.name
                if name:len() > 256 then
                    name = name:sub(1, 256-6) .. " [...]"
                end
    
                current = current + name:len()
                if current >= total then
                    break
                end
                
                local value = field.value
                if value:len() > 1024 then
                    value = value:sub(1, 1024-6) .. " [...]"
                end
    
                current = current + value:len()
                if current >= total then
                    break
                end

                local inline = is_boolean(field.inline) and field.inline or false
        
                self._embed.fields[#self._embed.fields+1] = {
                    name = name,
                    value = value,
                    inline = inline,
                }
            end
        end
    end
end

--- TODO! Handle something w/ flexible fields per page, if the current fields in this page are too many (ie. it's set to 10 fields per page, but 5 fields take up the total length of shtuff, so we have to get those lost 5 fields back). Handle it by doing something like changing how field_num is set?
function Prompt:refresh_embed()
    local total = 6000
    local current = 0

    current = current + self._embed.title:len() + self._embed.description:len()
    current = self:handle_fields(current)

    if self._footer == "" then
        self._embed.footer = {
            text = string.format(footer_string, self._current_page, self._total_pages)
        }
    elseif is_string(self._footer) then
        self._embed.footer = {
            text = self._footer
        }
    else
        self._embed.footer = nil
    end

    local ok, err = validate_embed(self._embed)
    if not ok then
        self._valid = false
        return errmsg(err)
    end

    self._valid = true
    local embed = self._embed

    if is_instance_of_class(self._message, "Message") then
        self._message:setEmbed(embed)
    else
        self._message = self._channel:send({content = self._content or "", embed=embed})
    end
end

function Prompt:set_page(page_num)
    if not is_number(page_num) then return end
    self._current_page = math.clamp(page_num, 1, self._total_pages)

    self:refresh_embed()
end

function Prompt:goodbye()
    -- channel:send("[DEBUG] Timing out the prompt!")
    client:removeListener("reactionAdd", self._key.."_listener")
    client:removeListener("messageCreate", self._key.."_listener")

    self:clear_timer()

    self._message:clearReactions()
    if self._goodbye_callback then
        self:_goodbye_callback()
    end
end

function Prompt:add_close_callback(callback)
    if not is_function(callback) then
        printf("Trying to call add_close_callback, but the function provided isn't actually a function!")
        -- error_msg
        return false
    end

    self._goodbye_callback = callback
end

function Prompt:clear_timer()
    if self._timer then
        TIMER.clearTimeout(self._timer)
        self._timer = nil
    end
end

function Prompt:refresh_timer()
    self:clear_timer()
    self:setup_timer()
end

function Prompt:setup_listener()
    client:on("messageCreate", function(message)
        local user_id = message.author.id
        if user_id == client.user.id then return end
        if self._channel.id ~= message.channel.id then return end

        -- check if there's exclusive users set; if there are, only react to reactions by them!
        if #self._users >= 1 then
            local is = false
            for i = 1, #self._users do
                if self._users[i] == user_id then
                    is = true
                    break
                end
            end

            if not is then return false end
        end

        if not self._active_query then
            -- ignore
            return false
        end

        self._query_cleanup[#self._query_cleanup+1] = message.id

        local response = self._active_query.response
        if response then
            local result,next_query,clear = response(message)
            print(result) print(next_query) print(clear)

            if result == true then
                if next_query then
                    self:trigger_query(next_query)
                    -- self:send_message("Responses gathered! Thanks, citizen!")
                else
                    self._active_query = nil
                end

                if clear then
                    self:clear_messages()
                end

                -- self:send_message("Result accepted!")
            else
                if is_string(result) then
                    self:send_message(result)
                else
                    self:send_message("Result DENIED.")
                end
            end
        end

        -- TODO do stuff

    end, self._key.."_listener")
end

--- Change how long until this navigator is timed out.
---@param ms number The number of milliseconds this timer will be active.
function Prompt:set_timeout(ms)
    if not is_number(ms) then return end

    self._timeout_ms = ms
end

function Prompt:setup_timer()
    self._timer = TIMER.setTimeout(self._timeout_ms, make_safe(function()
        self:goodbye()
    end))
end

--- Clear current reactions (the default 5), and set all of the valid reactions for this navigator.
---@param reactions_table table<string, fun(nav: prompt, user_id: string)>
function Prompt:set_reactions(reactions_table)
    self:clear_reactions()

    for i,reaction in ipairs(reactions_table) do
        self:add_reaction(reaction[1], reaction[2])
    end
end

function Prompt:set_content(str)
    if not is_string(str) then
        return false
    end

    self._content = str
end

--- Set a user to the list of people restricted to using this prompt. If set_user is never called, anyone can use this prompt.
---@param user_id string User ID of a person who can use this prompt.
function Prompt:set_user(user_id)
    self._users[#self._users+1] = user_id
end

--- Edit any field, and then refresh the embed if it exists.
---@param i number
---@param tab table
function Prompt:edit_field(i, tab)
    if not is_number(i) then return false end
    if not is_table(tab) then return false end
    if not self._fields[i] then
        -- this field doesn't exist!
        return false
    end

    self._fields[i] = tab
    self:refresh_embed()
end

--- Add a query to the Prompt.
---@param query_table table
function Prompt:add_query(query_table)
    if not is_table(query_table) then return false end

    self._queries[#self._queries+1] = query_table
end

function Prompt:set_queries(query_table)
    if not is_table(query_table) then return false end

    for i = 1, #query_table do
        self:add_query(query_table[i])
    end
end

-- Clear every message since the embed
function Prompt:clear_messages()
    for i,msg_id_to_kill in ipairs(self._query_cleanup) do
        local channel = self._channel

        local msg = channel:getMessage(msg_id_to_kill)
        msg:delete()
    end

    self._query_cleanup = {}
end

--- Add a reaction to this nav manager.
---@param reaction string The reaction to use.
---@param callback any
function Prompt:add_reaction(reaction, callback)
    if not is_string(reaction) then
        -- error_msg
        return false
    end

    if not is_function(callback) then
        -- err
        return false
    end

    printf("Adding in reaction %q", reaction)

    self._reactions[#self._reactions+1] = reaction
    self._reactions_to_funcs[reaction] = callback
end

function Prompt:clear_reactions()
    self._reactions = {}
    self._reactions_to_funcs = {}
end

function Prompt:send_message(content)
    ---@type TextChannel
    local channel = self._channel
    if channel then
        return channel:send(content).id
    end
end

function Prompt:trigger_query(key)
    local queries = self._queries
    for i = 1, #queries do
        local query = queries[i]
        if query.key == key then
            self._active_query = query
            if query.question then
                self._query_cleanup = {
                    self:send_message(query.question)
                }
            end
        end
    end
end

function Prompt:setup_reactions()
    local msg = self._message
    if not is_instance_of_class(msg, "Message") then return end

    if next(self._reactions_to_funcs) == nil then
        if self._total_pages >= 2 then
            self:set_default_reactions()
        else
            self:clear_reactions()
            return
        end
    end

    for i = 1, #self._reactions do
        -- printf("Adding in reaction %s", self._reactions[i])
        msg:addReaction(self._reactions[i])
    end

    client:removeListener("reactionAdd", self._key.."_listener")

    ---@param reaction Reaction
    ---@param user_id string
    client:on("reactionAdd", function(reaction, user_id)
        if user_id == client.user.id then return end

        -- check if there's exclusive users set; if there are, only react to reactions by them!
        if #self._users >= 1 then
            local is = false
            for i = 1, #self._users do
                if self._users[i] == user_id then
                    is = true
                    break
                end
            end

            if not is then return false end
        end

        local msg = reaction.message
        if self._message and msg.id == self._message.id then
            local emoji_hash = reaction.emojiHash

            local f = self._reactions_to_funcs[emoji_hash]
            if f then
                self:refresh_timer()
                f(self, user_id)

                msg:removeReaction(emoji_hash, user_id)
            end
        end
    end, self._key.."_listener")
end

function Prompt:start()
    if self._fields == 0 then
        self._fields[1] = {
            name = "None found!",
            value = "Nothing found for this embed :(",
        }
    end

    printf("Sending message for navigator %q", self._key)
    self:set_page(1)
    printf("Page set!")

    -- TODO error message or summat!
    if not self._message then return false end
    if self._valid == false then return false end

    self:setup_reactions()

    -- self:setup_queries()

    -- trigger the listener for reactions
    self:setup_listener()

    -- trigger the timer for clearing everything out
    self:setup_timer()
end

return Prompt