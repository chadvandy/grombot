local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me


local Command = InteractionManager:new_command("random_number", "Generate random number[s] for use in TW databases.", "CHAT_INPUT")

Command.id = "1109525548906057859"
Command.is_global = true

local o = Command:create_option("num", "How many random numbers do you need?")
o:set_type("INTEGER")
o:set_min_value(1)
o:set_max_value(20)
o:set_required(true)

local function generate(t)
    flush_random()

    local tab = {}

    for i = 1, t do
        tab[i] = math.random(1, 2147483647)
    end

    return table.concat(tab, "\n")
end

Command:set_callback(function (int, args)
    local total = args.num
    local all = generate(total)
    int:reply(all, true)
end)

return Command