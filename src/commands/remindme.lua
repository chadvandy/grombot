--- TODO port of the remindme systems.
--- TODO better access to data.

local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

---@type MacroManager
local MacroManager = discordia.storage.MacroManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me


local Command = InteractionManager:new_command("remindme", "Reminders!", "CHAT_INPUT")
-- Command.id = "1112747919846674513"
Command:set_global(true)

--- TODO remindme at
--- TODO remindme in
--- TODO remindme list
--- TODO remindme clear

local _message = "message"
local _y, _mn, _d, _h, _m, _s = "year", "month", "day", "hour", "minute", "second"
local _ys, _mns, _ds, _hs, _ms, _ss = "years", "months", "days", "hours", "minutes", "seconds"

local in_msg = "How many %s from now?"
local at_msg = "What %s to send the reminder?"

local _int = "INTEGER"
local _str = "STRING"

local sf = string.format

local function save()
    save_data("reminders")
end

-- Test a vararg to see if any are not nil.
local function are_any_not_nil(...)
    local args = table.pack(...)
    for i = 1, args.n do
        local v = args[i]
        print("Testing vararg w/ i,v: " .. tostring(i) .. ", " .. tostring(v))
        if not is_nil(v) then
            return true
        end
    end

    return false
end

local function start_reminder() 

end

-- TODO Localise the time to the user's used time zone?
    -- Need to have a specific set-timezone command for users, if they don't want to use GMT.
do
    local At = Command:add_subcommand("at", "Set a reminder for a specified date/time. Time is based off of GMT!")
    
    At:create_option("message", "The message to send when the reminder is triggered.")
        :set_required(true)
        :set_type("STRING")

    At:create_option("day", "The day to set the reminder for. Leave it blank to use the current day.")
        :set_required(false)
        :set_type("INTEGER")

    At:create_option("month", "The month to set the reminder for. Leave it blank to use the current month.")
        :set_required(false)
        :set_type("INTEGER")

    At:create_option("year", "The year to set the reminder for. Leave it blank to use the current year.")
        :set_required(false)
        :set_type("INTEGER")

    At:create_option("hour", "The hour to set the reminder for. Leave it blank to use the current hour.")
        :set_required(false)
        :set_type("INTEGER")
    
    At:create_option("minute", "The minute to set the reminder for. Leave it blank to use the current minute.")
        :set_required(false)
        :set_type("INTEGER")

    -- At:set_callback(function(int, args) 
        -- TODO Confirms args

        -- TODO Save message

        -- TODO translate to local timezone, if any are set
    
    -- end)
end

do
    local In = Command:add_subcommand("in", "Set a reminder to trigger in a certain amount of time.")

    In:create_option(_message, "The message to send yourself later.")
        :set_required(true)
        :set_type(_str)

    -- Send type (private, hidden, or public)

    -- Reference original message?

    -- Hours
    In:create_option(_h, sf(in_msg, _hs))
        :set_required(false)
        :set_type(_int)

    -- Minutes
    In:create_option(_m, sf(in_msg, _ms))
        :set_required(false)
        :set_type(_int)

    -- Seconds
    In:create_option(_s, sf(in_msg, _ss))
        :set_required(false)
        :set_type(_int)

    -- Days
    In:create_option(_d, sf(in_msg, _ds))
        :set_required(false)
        :set_type(_int)

    -- Months
    In:create_option(_mn, sf(in_msg, _mns))
        :set_required(false)
        :set_type(_int)

    -- Years
    In:create_option(_y, sf(in_msg, _ys))
        :set_required(false)
        :set_type(_int)

    -- Handle responding to a "remindme in" command.
    In:set_callback(function (int, args)
        -- Get the user who sent this request.  
        local user = int.user

        -- user:send("Hey dude I got your message.")

        -- TODO confirm that this user exists?

        -- Confirm that at least one of the time-based options was used.
        local ok, err = pcall(function() 
        local h,m,s,yr,mn,dy = args[_h], args[_m], args[_s], args[_y], args[_mn], args[_d]

        if not are_any_not_nil(h, m, s, yr, mn, dy) then
            -- Inform the user that they need to use at least one time-based option!
            int:reply("You need to supply at least one time argument! (ie. hours, minutes, seconds, etc.)")
            return
        end

        -- Force convert each of the numerical inputs into a 0 value if they're nil,
        -- to prevent any script breaks below (and simplify the code)
        h,m,s,yr,mn,dy = h or 0, m or 0, s or 0, yr or 0, mn or 0, dy or 0

        -- Save the details of the reminder in our internal data.
        local msg = args[_message]

        -- Get the current time to build the offset time from the provided values.
        ---@type Date
        local now = discordia.Date()
        local now_s = now:toSeconds()
        local due_s = now_s + (s) + (m * 60)
                    + (h * 60 * 60)
                    + (dy * 60 * 60 * 24)
                    -- + (yr * 60 * 60 * 24 * 365)
        -- ---@type Date
        -- local due = discordia.Date(due_s)

        -- TODO Handle year and month!

        -- TODO Save the data within Gromby's internals.

        -- Inform the user that the reminder has been set, and send a time-formatted
        -- response to let them know when it will be sent, w/ the ability to cancel
        -- or edit it via message components.
        int:reply("You will be reminded at <t:" .. due_s .. ">!")

        end) if not ok then int:reply(err) end
    end)
end

return Command