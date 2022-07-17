-- Save checklists in a new saved data container, id'd by the User ID -> array of checklists (a collection of info, items, etc)
-- Core: a list of items, which can be set to different states through time.
    -- Repeating: take a core checklist and duplicate it every so often, or optionally do similar with Items. Useful for habit trackers and SHIT.


--- ?checklist - show all checklists, or offer up a way to create a new checklist through a prompt
    -- show all prompt should have a way to open up a specific checklist, create a new one, delete one, etc.
    -- individual checklist prompt should have a way to edit details (description/name/icon), a way to add a new item, a way to create a sub-list, etc.

local CheckList = {
    ticket_num = 0,
    name = "",
    description = "",
    items = {},
    owner_id = 0,

    -- 0 for open, 1 for closed, 2 for archived?
    state = 0,
}

local CheckItem = {
    ticket_num = 0,
    name = "",

    -- 0 for open, 1 for in-progress, 2 for finished, 3 for canceled
    state = 0,
}

local function save()
    return save_data("checklists")
end

local function get_checklist_for_user()
    return false
end

-- TODO
---@param message Message
local function create_new_prompt(message)
    local new_prompt = PM.new("create_new_checklist", message.channel)
    new_prompt:set_content("Would you like to create a new checklist? Say y/yes to create a new one, otherwise I'll leave you be.")
    new_prompt:set_queries({
        {   
            key = "create",
            question = nil,
            ---@param msg Message
            response = function(msg)
                local content = msg.content:lower()
                if content == "y" or content == "yes" then
                    -- continue!
                    new_prompt:trigger_query("name")
                end
            end
        },
        {
            key = "name",
            question = "What do you want to name the checklist?",
            ---@param msg Message
            response = function(msg)
                local content = msg.content
                if content:len() == 0 then
                    -- TODO
                    return false
                end

                local name = content
            end
        }
    })

end

local function display_all_prompt(msg)

end

-- Main command; display all checklists you have, or get some sort of prompt to make a new one if you have none.
local checklist = CM:new_command(
    "checklist",
    ---@param msg Message
    ---@param args string[]
    function(msg, args)
        local author = msg.author
        if get_checklist_for_user(author.id) then
            -- display prompt with all checklists
            display_all_prompt(msg)
        else
            -- display prompt for creating a new checklist
            create_new_prompt(msg)
        end
    end
)