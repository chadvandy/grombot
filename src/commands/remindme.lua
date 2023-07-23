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

local function save()
    save_data("reminders")
end

do
    local At = Command:add_subcommand("at", "Set a reminder for a specified date/time. Time is based off of GMT!")
    
    At:create_option("message", "The message to send when the reminder is triggered.")
        :set_required(false)
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

end

return Command