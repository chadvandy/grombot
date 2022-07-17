--- A system for creating a sign-up sheet, setting stuff like max people, tournament style, rolled tables, etc.

--- ?signup - show all signups and their current states
--- ?signup "signup name" - post signup msg.
--- ?signup start "signup name" - start the signups!
--- ?signup close "signup name" - close them!
--- ?signup sort "signup name" - go through the user table and match up one to another!

---@class SignUp
local SignUp = {
    guild_id = nil,
    channel_id = nil,
    message_id = nil,
    name = "",
    description = "",
    trigger = "",

    ---@type string[] IDs of all users signed up for this!
    users = {},

    ---@type table<number, string[]>
    matches = {},

    --- The listener key for the active messageCreated listener - nil if not active!
    listener_name = nil,

    --- 0 for not started, 1 for active, 2 for closed
    state = 0,
}

local function save()
    save_data("signups")
end

-- Loaded whenever Gromby reboots! If any signups are in-stasis, it'll restart listeners.
on_ready(function()
    local signups = saved_data.signups
    for i = 1, #signups do
        local signup = signups[i]
        signup = SignUp:new(signup)
        if signup.listener_name then
            signup:trigger_listener()
        end
    end
end)

function SignUp:add_user(id)
    if not is_string(id) then return end

    for i = 1, #self.users do
        local user_id = self.users[i]
        if user_id == id then
            return self:send_message("<@"..id..">, you've already been added!")
        end
    end

    self.users[#self.users+1] = id

    self:send_message("<@"..id..">, you've been added to the signup \""..self.name.."\"!")

    save()
end

--- sort the list of users and match up peeps RANDOMLY.
function SignUp:sort_users()
    self.matches = {}

    flush_random()

    local users = table.copy(self.users)
    users = table.random_sort(users)

    local finished
    while not finished do
        if #users == 0 then
            -- finished!
            break
        end

        if #users == 1 then
            -- TODO we have a wildcard!
            self.matches[#self.matches+1] = {users[1], users[1]}
            break
        end

        -- match up
        local i = math.random(#users)
        local user_one = users[i]
        table.remove(users, i)

        local j = math.random(#users)
        local user_two = users[j]
        table.remove(users, j)

        self.matches[#self.matches+1] = {user_one, user_two}
    end

    self:post_match_message()
end

--- Trigger the listener ; trigger a message saying stuff
function SignUp:start()
    if self.state == 2 then return end

    self:post_message()
    self.state = 1

    self:trigger_listener()
end

function SignUp:post_match_message()
    local prompt = PM.new("signup_sorted", self:get_channel())
    prompt:set_title(self.name)
    prompt:set_fields_is_description()

    local matches = self.matches
    local desc = {}

    for i = 1, #matches do
        local match = matches[i]
        local user_one,user_two = match[1], match[2]
        if user_one == user_two then
            desc[#desc+1] = "Match #"..i..": <@" .. user_one .."> vs. Anyone who wants to fight them!"
        else
            desc[#desc+1] = "Match #"..i..": <@" .. user_one .."> vs. <@" .. user_two .. ">!"
        end
    end

    prompt:set_fields(desc)
    prompt:start()
end

function SignUp:trigger_listener()
    self.listener_name = self.name.."_listener"

    client:on(
        "messageCreate",
        ---@param msg Message
        function(msg)
            if msg.channel.id ~= self.channel_id then return end

            local trigger = self.trigger
            local content = msg.content

            if content:lower() == trigger:lower() then
                self:add_user(msg.author.id)
            end
        end,
        self.listener_name
    )
end

function SignUp:stop_listener()
    client:removeListener("messageCreate", self.listener_name)
    self.listener_name = nil
end

function SignUp:close()
    self.state = 2
    self:stop_listener()

    self:post_close_message()
end

function SignUp:get_guild()
    return client:getGuild(self.guild_id)
end

function SignUp:get_channel()
    return self:get_guild():getChannel(self.channel_id)
end

function SignUp:get_message()
    if not self.message_id then return end
    return self:get_channel():getMessage(self.message_id)
end

function SignUp:post_close_message()
    local channel = self:get_channel()

    local prompt = PM.new("signup_close", channel)
    prompt:set_title("Sign-Up Closed: " .. self.name)
    
    local users = self.users
    local desc = {}
    for i = 1, #users do
        local str = "<@"..users[i]..">"
        desc[#desc+1] = str
    end
    prompt:set_fields_is_description()
    prompt:set_fields_per_page(20)

    prompt:set_fields(desc)

    prompt:start()
end

--- Post the message w/ all the info about this sign up.
function SignUp:post_message()
    local channel = self:get_channel()

    if self.message_id then return end

    local prompt = PM.new("signup", channel)
    prompt:set_title("Sign-Up: " .. self.name)
    prompt:set_description(self.description)

    prompt:set_fields{
        {
            name = "Join in!",
            value = "Say `" .. self.trigger .. "` to join this sign-up!"
        }
    }

    prompt:start()

    self.message_id = prompt._message.id
end

--- Post a message to the channel!
---@param msg string
function SignUp:send_message(msg)
    local channel = self:get_channel()
    if channel then
        channel:send(msg)
    end
end

function SignUp:new(o)
    o = table.copy_add(o or {}, SignUp)
    setmetatable(o, {__index = SignUp})

    return o
end

--- Return an embed-ified list of all active signups.
local function get_active_signups()
    local data = {}
    local signups = saved_data.signups

    for i = 1, #signups do
        local signup = signups[i]
        if signup.state < 2 then
            data[#data+1] = {name = signup.name, value = signup.description}
        end
    end

    return data
end

---@return SignUp
local function get_signup(name)
    assert(is_string(name))
    local signups = saved_data.signups
    for i = 1, #signups do
        local signup = signups[i]
        if signup.name == name then
            return signup
        end
    end
end

-- TODO show signup message if a signup is passed to this command
local signup = CM:new_command(
    "signup",
    ---@param message Message
    ---@param args string[]
    function (message, args)
        local prompt = PM.new("all_signups", message.channel)
        prompt:set_title("Sign-Ups")
        prompt:set_description("All existing sign-ups, whether active or closed.")

        prompt:set_user(message.author.id)
        prompt:set_fields_per_page(6)
        prompt:set_fields(get_active_signups())

        prompt:start()
    end
)
signup:set_name("Sign-Ups")
signup:set_description("")
signup:set_trigger("message", "signup")

local signup_new = signup:set_sub_command(CM:new_command(
    "signup_new",
    ---@param message Message
    ---@param args string[]
    function(message, args)
        -- trigger a new prompt to create a signup from scratchy scratch!
            -- what channel
            -- what name
            -- what description
            -- what trigger for signing up

        local new_signup = {
            guild_id = message.guild.id
        }

        local prompt = PM.new("create_signup", message.channel)
        prompt:set_title("New Signup")
        prompt:set_description("Follow the prompts to create a new signup sheet!")
        prompt:set_user(message.author.id)
        prompt:set_fields({
            {
                name = "Channel",
                value = "Not set!",
            },
            {
                name = "Name",
                value = "Not set!",
            },
            {
                name = "Description",
                value = "Not set!",
            },
            {
                name = "Trigger",
                value = "Not set!",
            },
        })

        prompt:set_queries(
            {
                {
                    key = "channel",
                    question = "What channel will this sign-up take place in? Either #channel, or say 'here'.",
                    response = 
                    ---@param msg Message
                    function(msg)
                        local next = false
                        if msg.content:lower():find("here") then
                            new_signup.channel_id = message.channel.id
                            next = true
                        end

                        if msg.mentionedChannels.first then
                            new_signup.channel_id = msg.mentionedChannels.first.id
                            next = true
                        end

                        if next then
                            prompt:edit_field(1, {name = "Channel", value = "<#"..new_signup.channel_id..">"})
                            return true, "name", true
                        end

                        return false, "Error message here!"
                    end
                },
                {
                    key = "name",
                    question = "What is the name of this sign-up?",
                    response = 
                        ---@param msg Message
                        function(msg)
                            local next = false
                            if msg.content ~= "" then
                                new_signup.name = msg.content
                                next = true
                            end
    
                            if next then
                                prompt:edit_field(2, {name = "Name", value = new_signup.name})
                                return true, "description", true
                            end
                        end
                },
                {
                    key = "description",
                    question = "What is the description for this sign-up?",
                    response = 
                        ---@param msg Message
                        function(msg)
                            local next = false
                            if msg.content ~= "" then
                                new_signup.description = msg.content
                                next = true
                            end
    
                            if next then
                                prompt:edit_field(3, {name = "Description", value = new_signup.description})
                                return true, "trigger", true
                            end
                        end
                },
                {
                    key = "trigger",
                    question = "What is the trigger for this sign-up, that people will use to sign-up?",
                    response = 
                        ---@param msg Message
                        function(msg)
                            local cont
                            if msg.content ~= "" then
                                new_signup.trigger = msg.content
                                cont = true
                            end
    
                            if cont then
                                prompt:edit_field(4, {name = "Trigger", value = new_signup.trigger})
                                
                                new_signup = SignUp:new(new_signup)
                                saved_data.signups[#saved_data.signups+1] = new_signup

                                -- new_signup:start()
                                save()

                                message.channel:send("Okay! Sign-up is ready to be used. Use `?signup start \"".. new_signup.name.."\"` to begin the sign-ups!")

                                return true, nil, true
                            end
                        end
                }
            }
        )

        prompt:start()

        prompt:trigger_query("channel")
    end
))
signup_new:set_name("Create Sign-Up")
signup_new:set_description("")
signup_new:set_trigger("message", "new")

local signup_start = signup:set_sub_command(CM:new_command(
    "signup_start",
    ---@param message Message
    ---@param args string[]
    function(message, args)
        local name = args.name
        ---@type SignUp
        local sup = args.signup
        sup:start()
    end
))
signup_start:set_name("Create Sign-Up")
signup_start:set_description("")
signup_start:set_trigger("message", "start")
signup_start:set_argument_parser(
    function(msg, args)
        local name = get_quoted_name_from_string(table.concat(args, " "))

        if not is_string(name) or name == "" then
            return false, "You have to pass the name of the sign up in quotes!"
        end

        if not get_signup(name) then
            return false, "No sign-up found with the name \""..name.."\"!"
        end

        return {name = name, signup = get_signup(name)}
    end
)

local signup_close = signup:set_sub_command(CM:new_command(
    "signup_close",
    ---@param message Message
    ---@param args string[]
    function(message, args)
        local name = args.name
        ---@type SignUp
        local sup = args.signup
        sup:close()
    end
))
signup_close:set_name("Create Sign-Up")
signup_close:set_description("")
signup_close:set_trigger("message", "close")
signup_close:set_argument_parser(
    function(msg, args)
        local name = get_quoted_name_from_string(table.concat(args, " "))

        if not is_string(name) or name == "" then
            return false, "You have to pass the name of the sign up in quotes!"
        end

        if not get_signup(name) then
            return false, "No sign-up found with the name \""..name.."\"!"
        end

        return {name = name, signup = get_signup(name)}
    end
)

local signup_sort = signup:set_sub_command(CM:new_command(
    "signup_sort",
    ---@param message Message
    ---@param args string[]
    function(message, args)
        local name = args.name
        ---@type SignUp
        local sup = args.signup
        sup:sort_users()
    end
))
signup_sort:set_name("Create Sign-Up")
signup_sort:set_description("")
signup_sort:set_trigger("message", "sort")
signup_sort:set_argument_parser(
    function(msg, args)
        local name = get_quoted_name_from_string(table.concat(args, " "))

        if not is_string(name) or name == "" then
            return false, "You have to pass the name of the sign up in quotes!"
        end

        if not get_signup(name) then
            return false, "No sign-up found with the name \""..name.."\"!"
        end

        return {name = name, signup = get_signup(name)}
    end
)