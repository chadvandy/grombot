--- TODO Modding command group to bundle all TW-mod specific systems.

local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

local regenerate_guid = require "src.helpers.regen_guid_function"

local Modding = InteractionManager:new_command("modding", "All commands that are helpful for modding Total War.", "CHAT_INPUT")
Modding.is_global = true

-- DB helpers.
do
    local RandomNumber = Modding:add_subcommand("random_number", "Generate random number[s] for use in TW databases.")

    local o = RandomNumber:create_option("num", "How many random numbers do you need?")
        o:set_type("INTEGER")
        o:set_min_value(1)
        o:set_max_value(500)
        o:set_required(true)
        
    local function generate(t)
        flush_random()
    
        local tab = {}
    
        for i = 1, t do
            tab[i] = math.random(1, 2147483647)
        end
    
        return table.concat(tab, "\n")
    end
    
    RandomNumber:set_callback(function (int, args)
        local total = args.num
        local all = generate(total)

        local reply = {
            content = "Here are your random numbers:",
            file = {"generated_numbers.txt", all}
        }

        int:reply(reply, true)
    end)
end

do -- TWUI helpers
    local RegenGuid = Modding:add_subcommand("regen_guid", "Regenerate GUIDs within a .twui.xml file!")

    local o = RegenGuid:create_option("file", ".twui.xml file to regenerate!")
    o:set_type("ATTACHMENT")
    o:set_required(true)

    RegenGuid:set_callback(function (int, args)
        if args.file then
            -- int:reply("We have an arg provided for file!")

            local att = args.file
            local url = att.url
            local filename = att.filename
            local ending = ".twui.xml"

            if filename:sub(-#ending) ~= ending then
                int:reply("This isn't a .twui.xml file!", true)
                return
            end

            print("File name: "  .. att.filename)
            print("Attachment URL: " .. url)
            
            local response, body = http.request("GET", url)

            local txt, err = regenerate_guid(body)

            if err ~= "" then
                int:reply("Error while regenerating GUIDs:" .. err)
            else
                local suc,ierr = int:reply({content = "Here is your TWUI file with regenerated GUID's!", file = {filename, txt}}, true)
                if not suc then
                    errmsg(ierr)
                end
            end
        end
    end)
end

return Modding