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
do
    local All = Command:add_subcommand("all", "List all macros")
    All:set_callback(function (int, args)
        MacroManager:all_macros(int)
    end)
end


do
    local Search = Command:add_subcommand("search", "Search for and display a specific macro.")
    Search:create_option("name", "Name of the macro you're looking for")
        :set_type("STRING")
        :set_required(true)
        :set_autocomplete(true)
        :set_on_autocomplete(function(int, data, value)
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
end

-- Create a new Macro.
-- /macro create -> modal
do
    --- TODO some verification to prevent a new macro being created with the name of an extant one.
    local Create = Command:add_subcommand("create", "Create a new Macro!")

    Create:set_callback(function (int, args)
        -- Trigger Modal.
        local CreateModal = InteractionManager:create_modal("create_macro", "Create a new macro!")
        CreateModal:add_input("name", "Macro Name", true, true)
        CreateModal:add_input("desc", "Set a description", true, false)
    
        CreateModal:set_callback(function (m_int, m_args)
            local name, desc = m_args.name, m_args.desc
    
            if MacroManager:get_macro(name) then
                m_int:reply("There's already a Macro with the name " .. name .. "!", true)
                return
            end
    
            if string.len(desc) <= 0 then
                m_int:reply("Invalid description!", true)
                return
            end
    
            MacroManager:new_macro(name, desc)
            m_int:reply("New Macro created named " .. name .. "! Good job!")
        end)
        
        int:modal(CreateModal:get_payload())
    end)
end

do
    --- TODO move the edit functions into a Modal.
    local Edit = Command:add_subcommand("edit", "Edit a Macro.")

    Edit:set_callback(function (int, args)
        local member = int.member
        local name = args.name
        local desc, rename = args.desc, args.rename

        local macro = MacroManager:get_macro(name)
        if not macro then
            int:reply("No macro with the name " .. args.name .. " exists!", true)
            return
        end

        if desc then
            -- TODO convert \n into true new lines.
            desc = desc:gsub("\\n", "\n")
            macro:set_field(desc)
        end

        if rename then
            macro:set_name(rename)
        end

        MacroManager:save()
        int:reply("Macro " .. args.name .. " edited!")
    end)

    local name = Edit:create_option("name", "Name of the macro you're looking for")
    name:set_type("STRING")
    name:set_required(true)
    name:set_autocomplete(true)
    name:set_on_autocomplete(function(int, data, value)
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

    local desc = Edit:create_option("desc", "New description for the Macro.")
    desc:set_type("STRING")
    desc:set_required(false)

    local rename = Edit:create_option("rename", "New name for the Macro.")
    rename:set_type("STRING")
    rename:set_required(false)
end

do
    local Delete = Command:add_subcommand("delete", "Delete a Macro. Only the owner can delete their Macros, or admins.")

    Delete:set_callback(function (int, args)
        local member = int.member
        local macro = MacroManager:get_macro(args.name)

        if not macro then
            int:reply("No macro with the name " .. args.name .. " exists!", true)
            return
        end

        if member and member:hasPermission(nil, discordia.enums.permission.banMembers) then
            MacroManager:delete_macro(args.name)
            int:reply("Macro " .. args.name .. " deleted!")
        else
            int:reply("You don't have permission to delete this Macro!", true)
        end
    end)

    local opt = Delete:create_option("name", "Macro to delete.")
    opt:set_required(true)
    opt:set_autocomplete(true)
    opt:set_type("STRING")

    opt:set_on_autocomplete(function (int, data, value)
        local member = int.member
        local choices = {}
        local search_str = string.lower(value)

        if member and member:hasPermission(nil, discordia.enums.permission.banMembers) then
            for macro_name, macro in pairs(MacroManager:get_macros()) do
                -- if is_nil(macro.user) or macro.user.id == 
                if string.find(string.lower(macro_name), search_str) then
                    choices[#choices+1] = {
                        name = macro_name,
                        value = macro_name,
                    }
    
                    if #choices == 25 then break end
                end
            end
        else
            choices[1] = "Admin-only command!"
        end


        return choices
    end)
end

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