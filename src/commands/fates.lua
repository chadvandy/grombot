local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local Command = InteractionManager:new_command("fates", "Various commands relating to the Fates of Mankind game.", "CHAT_INPUT")

Command.id = "1226641005567021127"
Command:set_global(true)

---@param pool number The number of d12's to roll
---@return table #The ordered results of the dice rolled.
---@return number #The Moirai die.
local function roll_them_bones(pool)
    -- cache the die results
    local results = {}
    
    flush_random()

    -- Roll the bones!
    for i = 1, pool do
        results[i] = math.random(12)
    end
    
    local moirai = math.random(12)

    return results, moirai
end

-- /fates roll command
    -- arg: number of dice to roll (requird)
    -- arg: difficulty (optional, defaults to 7)
    -- res: prints out the number of successes, w/ the Moirai result, and the dice results.

local Roll = Command:add_subcommand("throw", "Roll!")

Roll:create_option("pool", "The number of dice to roll!")
    :set_required(true)
    :set_type("INTEGER")
    :set_min_value(1)
    :set_max_value(30)

Roll:create_option("diff", "The difficulty of the roll.")
    :set_required(false)
    :set_type("INTEGER")
    :set_min_value(2)
    :set_max_value(12)

Roll:set_callback(function (int, args)
    local pool = args["pool"]
    local diff = args["diff"]

    if is_nil(diff) then diff = 7 end

    local results, moirai = roll_them_bones(pool)

    local rolled_successes = 0
    local total_successes = 0

    local result_string = ""
    local die_string = ""
    local moirai_string = ""

    -- 1: Seamless
    -- 0: Spinning
    -- -1: Knot
    local moirai_result = (moirai >= 11 and 1) or (moirai <= 2 and -1) or 0
    local moirai_knotted = false

    for i,die in ipairs(results) do
        -- this is a regular die.
        if die >= diff then
            rolled_successes = rolled_successes + 1
        
            results[i] = "**" .. tostring(die) .. "**"

            if moirai_result < 0 and not moirai_knotted then
                results[i] = "~~**" .. tostring(die) .. "**~~"
                moirai_knotted = true
            end
        else
            results[i] = tostring(die)
        end
    end

    total_successes = rolled_successes + moirai_result

    -- Test the total number of successes received, including the
    -- alteration through the Moirai, to inform the user their roll result.
    if total_successes > 0 then
        -- End-positive result. See if moirai is a 1 and total is above 1.
        if moirai_result == 1 and total_successes > 1 then
            result_string = "**Critical Success!**"
        else
            result_string = "**Success!**"
        end
    else
        -- End-negative result. It's a Failure.
        result_string = "**Failure!**"

        -- Critical failure happens if there's 0 successes and a knotted moirai.
        if moirai_result == -1 then
            result_string = "**Critical Failure!**"
        end
    end

    -- Build the result string for the Moirai.
    if moirai_result > 0 then
        moirai_string = "Seamless Moirai: **" .. moirai .. "** (+1 Success)"
    elseif moirai_result < 0 then
        moirai_string = "Knotted Moirai: " .. moirai .. " (-1 Success)"
    else
        moirai_string = "Spinning Moirai: " .. moirai
    end

    local roll_string = string.format("Rolling %dd12 against [Difficulty %d]\nResults: %s", pool,diff,  table.concat(results, ", "))
    local success_string = string.format("Rolled Successes: %d", rolled_successes)
    local total_string = string.format("Total Successes: %d", total_successes)

    local str = string.format("%s\n%s\n%s\n\n%s\n%s", roll_string, success_string, moirai_string, result_string, total_string)
    -- local str = string.format("%s\n\n%s\n%s\n\n%s", success_string, total_success_string, die_string, moirai_string)

    int:reply(str)
end)