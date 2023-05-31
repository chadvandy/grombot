-- TODO the Macro system

local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

---@type MacroManager
local MacroManager = discordia.storage.MacroManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me


local Command = InteractionManager:new_command("macro", "Macros galore!", "CHAT_INPUT")
Command.id = "1112747919846674513"
Command:set_global(true)

-- Main command is used to search through all macros.

local All = Command:add_subcommand("all", "List all macros")
All:set_callback(function (int, args)
    MacroManager:all_macros(int)
end)

local Search = Command:add_subcommand("search", "Search for and display a specific macro.")
Search:create_option("name", "Name of the macro you're looking for")
    :set_type("STRING")
    :set_required(true)
    :set_autocomplete(true)
    :set_on_autocomplete(function(data, value)
        local all = MacroManager:get_macros()

        ---@type table<string, MacroObj>
        local choices = table.filter(
            all,
            ---@param val MacroObj
            ---@param key string
            ---@param t table<string, MacroObj>
            function (val, key, t)
                if string.find(string.lower(val.name), string.lower(value)) then
                    return true
                end
            end,
            25
        )

        local ret = {}
        for _,macro in pairs(choices) do
            ret[#ret+1] = {
                name = macro.name,
                value = macro.name,
            }
        end

        return ret
    end)

Search:set_callback(function (int, args)
    local macro = MacroManager:get_macro(args.name)

    int:reply(macro.field)
end)

-- -- local search = Command:add_subcommand_group("search", "Search for macros!")
-- local Create = Command:add_subcommand_group("create", "Create a new Macro!")

-- local Test = Create:add_subcommand("test", "Dev testing")

-- Test:set_callback(function (int, args)
--     local holder = InteractionManager.Components.Holder:new()
--     local menu = InteractionManager.Components.Menu:new("custom_menu", 6)
--     -- menu:add_option("test_1", "Testing 1", "Description for option", true)
--     -- menu:add_option("test_2", "Testing 2", "My cool description!", false)

--     holder:add_component(menu)


--     local ok, err = int:reply({
--         content = "Testing message",
--         components = {
--             holder:get_payload()
--         }
--     })

--     if not ok then errmsg(err) end
-- end)

-- local New = Create:add_subcommand("new", "Fresh new macro here! Get your macro!")
-- -- New:create_option("name", "Name for the new Macro"):set_type("STRING")
-- -- New:create_option("desc", "Description for the new Macro."):set_type("STRING")

-- local t =  {
--         custom_id = "new_macro",
--         title = "Create a ding-dang new macro!",
--         components = {
--             {
--                 type = 1,
--                 components = {
--                     {
--                         type = 4,
--                         custom_id = "name",
--                         label = "Macro Name",
--                         style = 1,
--                         required = true,
--                     },
--                 },
--             },
--             {
--                 type = 1,
--                 components = {
--                     {
--                         type = 4,
--                         custom_id = "desc",
--                         label = "Description",
--                         style = 2,
--                         required = true,
--                     }
--                 }
--             }
--         }
--     }

-- New:set_callback(function (int, args)
--     -- int:reply("Nice new macro!")
--     -- int:reply("Name: " .. args.name)
--     -- int:reply("Description: \n```" .. args.desc .. "```")

--     local m = InteractionManager:create_modal("new_macro", "Create a ding-dang new macro!")

--     m:add_input("name", "Macro Name", true, true)
--     m:add_input("desc", "Set a description", true, true)
    
--     m:set_callback(function (iInt, iArgs)
--         local name = iArgs.name
--         local desc = iArgs.desc
--         local ok, err = iInt:reply("New macro w/ name " .. name .. " created!")

--         if not ok then
--             errmsg(err)
--         end
--     end)

--     local ok, err = int:modal(m:get_payload())

--     if not ok then errmsg(err) end
-- end)


    --{
--     custom_id = "new_macro",
--     title = "Create a ding-dang new macro!",
--     components = {
--         {
--             type = 1,
--             components = {
--                 {
--                     type = 4,
--                     custom_id = "name",
--                     label = "Macro Name",
--                     style = 1,
--                     required = true,
--                 },
--             },
--         },
--         {
--             type = 1,
--             components = {
--                 {
--                     type = 4,
--                     custom_id = "desc",
--                     label = "Description",
--                     style = 2,
--                     required = true,
--                 }
--             }
--         }
--     }
-- }

return Command