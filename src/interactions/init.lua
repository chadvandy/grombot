local discordia = require("discordia")
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class InteractionManager
local InteractionManager = {
    ---@type table<string, Command>
    _commands = {},
}

discordia.storage.InteractionManager = InteractionManager

InteractionManager.enums = require("./enums")

---@type Command
InteractionManager.Command = require("./command")

---@type CommandOption
InteractionManager.CommandOption = require("./option")



function InteractionManager:is_enum(enum_type, ind)
    local enums = self.enums[enum_type]

    for i, v in ipairs(enums) do
        if is_number(ind) and i == ind then return i end
        if is_string(ind) and v == ind then return i end
    end

    return false
end

function InteractionManager:new_command(name, description)
    local command = self.Command:new(name, description):set_type("CHAT_INPUT")
    self._commands[name] = command

    return command
end

function InteractionManager:new_command_option(name, description)
    local option = self.CommandOption:new(name, description)
    return option
end

function InteractionManager:init()
    local roll_command = self:new_command("roll", "Roll some bones!")
    local pool = roll_command:create_option("dice_pool", "The number of dice to roll!")
    pool:set_type("INTEGER")
    pool:set_required(true)
    pool:set_max_value(100)
    pool:set_min_value(1)

    do
        --- TODO use option choies? ie., d4, d6, d8, d10, dF, etc.
        local num_faces = roll_command:create_option("num_faces", "The number of faces for each die!")
        num_faces:set_type("INTEGER")
        num_faces:set_required(true)
    
        local modifier = roll_command:create_option("modifier", "A number to modify the end result by - ex., +1 or -6.")
        modifier:set_type("INTEGER")
        modifier:set_required(true)
    
        local num_keep = roll_command:create_option("num_keep", "The number of die to keep from the pool!")
        num_keep:set_type("INTEGER")
        num_keep:set_required(false)
    
        local keep_highest = roll_command:create_option("keep_highest", "Keep the highest dice, if any are discarded. False to keep the lowest.")
        keep_highest:set_type("BOOLEAN")
        keep_highest:set_required(false)
    end


    local function flush()
        -- set a random seed
        math.randomseed(os.time())
        
        -- flush out the random shit
        math.random()
        math.random()
        math.random()
        math.random()
        math.random()
    end
    
    ---@alias die {res:number, type:string, keep:boolean}

    --- Roll some bones!
    ---@param i number? The number of dice. 
    ---@param f number? The number of faces per die.
    ---@return die[]
    local function roll(i, f)
        flush()

        if not is_number(i) then i = 1 end
        if not is_number(f) then f = 6 end

        local res = {}
        for j = 1, i do
            res[j] = {
                res = math.random(1, f),
                type = "d"..f,
                keep = true,
                id = j,
            }
        end

        -- --- sort the results from highest to lowest
        -- table.sort(res, function (a, b)
        --     return a.res > b.res
        -- end)

        return res
    end

    roll_command:set_callback(function(int, args)
        local num_dice = args.dice_pool
        local num_faces = args.num_faces
        local mod = args.modifier
        local num_keep = args.num_keep
        local keep_highest = not is_boolean(args.keep_highest) and true or args.keep_highest

        local roll_results = roll(num_dice, num_faces)

        -- sorted highest to lowest. ie. [1]=highest, [6]=lowest.
        ---@type table
        local ordered_results = table.copy(roll_results)
        table.sort(ordered_results, function(a, b) return a.res > b.res end)

        --- TODO handle num_keep / keep_highest
        if num_keep then
            local to_drop = num_dice - num_keep

            -- drop the highest X or the lowest X from the roll_results table
            -- TODO just visually and numerically drop them
            if to_drop > 0 then
                if keep_highest then
                    -- if we're dropping 2 lowest dice, and we have a 6 pool, we're getting the last 2 die objects
                    -- so we need to get the FINAL, and then FINAL-TO_DROP+1, because it's inclusive (ie. 6 and 5 are two)
                    for i = num_dice, num_dice - to_drop + 1, -1 do
                        local kill = ordered_results[i]
                        roll_results[kill.id].keep = false
                    end
                else
                    -- if we're dropping the 2 highest dice, and we have a 6 pool, we're getting the first 2 die objects
                    -- so we get 1, and then TO_DROP, which is 2
                    for i = 1, to_drop, 1 do
                        local kill = ordered_results[i]
                        roll_results[kill.id].keep = false
                    end
                end
            end
        end

        local str_res = ""

        local total = mod
        for i, die in ipairs(roll_results) do
            if die.keep then
                total = total + die.res
            end

            local s = die.keep and die.res or "~~"..die.res.."~~"

            if i ~= 1 then s = " + " .. s end
            str_res = str_res .. s
        end

        local str_total = string.format("Rolled a **%d!**", total)
        str = string.format("%s\n\n%s", str_total, str_res)

        if mod ~= 0 then
            if mod > 0 then
                str = str .. " + " .. math.abs(mod) .. " [modifier]"
            else
                str = str .. " - " .. math.abs(mod) .. " [modifier]"
            end
        end

        int:reply(str)
    end)

    local payload = roll_command.payload
    payload.options = {}
    local options = roll_command.options
    for i, option in ipairs(options) do
        payload.options[i] = option.payload
    end

    -- log_me(client:createGlobalApplicationCommand(payload))
end

function InteractionManager:process_interaction(int, cmd, args)
    local command = self._commands[cmd.name]
    command:process(int, args)
end

return InteractionManager