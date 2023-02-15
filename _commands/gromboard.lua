local discordia = require("discordia")
local client = discordia.storage.client

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

--- A system for Gromby to collect transmissions, so shit doesn't easily get lost in #moddr_team_up or any of the #modding_tech channels.
--- Start off with #moddr_team_up:
    -- Two modes - submitting offers, and submitting requests
        -- ?moddr lf anyone to help me out with unit cards!
        -- ?moddr uf helping anybody with unit cards!
        -- Also include a way to search - `?moddr search lf unit cards` or some shit?
    -- Third mode to just see the entire board.
        -- Gromby can post in #moddr_team_up every ~24hrs, if the last message within the channel isn't from him, with the entire board. No timeout on this one, though - timeout only happens when the next regular-post is posted'd.
    -- A way to clear requests and to clear offers.

local function save()
    save_data("gromboard")
end

local function moddr_add_offer(user_id, str)
    if not is_string(user_id) then
        -- errmsg
        return false
    end

    if not is_string(str) then
        -- errmsg
        return false
    end

    local ticket_num = TM:generate_ticket_number("moddr")

    local offer = {
        ticket_num = ticket_num,
        str = str,
        user_id = user_id,
    }

    saved_data.gromboard.moddr.offers[#saved_data.gromboard.moddr.offers+1] = offer
    save()

    return ticket_num
end

local function moddr_add_request(user_id, str)
    if not is_string(user_id) then
        -- errmsg
        return false
    end

    if not is_string(str) then
        -- errmsg
        return false
    end

    local ticket_num = TM:generate_ticket_number("moddr")

    local request = {
        ticket_num = ticket_num,
        str = str,
        user_id = user_id,
    }

    saved_data.gromboard.moddr.requests[#saved_data.gromboard.moddr.requests+1] = request
    save()

    return ticket_num
end

local function get_ticket(ticket_num)
    ticket_num = tonumber(ticket_num)
    if not is_number(ticket_num) then
        printf("Trying to get ticket, but the num provided %q isn't a number!", tostring(ticket_num))
        return false
    end

    if ticket_num < 0 then
        printf("Trying to get ticket, but the num provided %d isn't a valid integer!", ticket_num)
        return false
    end

    for i = 1, #saved_data.gromboard.moddr.requests do
        local request = saved_data.gromboard.moddr.requests[i]
        if request.ticket_num == ticket_num then
            return request,i,"request"
        end
    end

    for i = 1, #saved_data.gromboard.moddr.offers do
        local offer = saved_data.gromboard.moddr.offers[i]
        printf("Testing ticket %d against %d", offer.ticket_num, ticket_num)
        if offer.ticket_num == ticket_num then
            printf("Returning ticket!")
            return offer,i,"offer"
        end
    end
end

local function moddr_remove_ticket(num)
    local ticket,pos,type = get_ticket(num)
    if not ticket then
        return false
    end

    table.remove(saved_data.gromboard.moddr[type.."s"], pos)
    save()
end

---@param channel GuildChannel
local function create_embed(channel, user_id)
    local nav = PM.new("moddr_embed", channel)
    nav:set_title("Moddr Team-Up")
    nav:set_description("Check the board below for currently active requests and offers for teaming up!")
    nav:set_fields_per_page(10)

    local guild = channel.guild

    if user_id then
        local member = guild:getMember(user_id)
        nav:set_title("Moddr Team-Up ["..member.name.."]")
        nav:set_description("List of all current tickets registered by you.")
    end

    local all = {}
    for i = 1, #saved_data.gromboard.moddr.requests do
        local o = saved_data.gromboard.moddr.requests[i]

        local member = guild:getMember(o.user_id)
        if member and (not user_id or user_id == o.user_id) then
            all[#all+1] = {
                name = "Ticket #"..o.ticket_num .. " by "..member.name .. " [REQUEST]",
                value = o.str .. "\n<@"..o.user_id..">",
                num = o.ticket_num
            }
        end
    end
    for i = 1, #saved_data.gromboard.moddr.offers do
        local o = saved_data.gromboard.moddr.offers[i]

        local member = guild:getMember(o.user_id)
        if member and (not user_id or user_id == o.user_id) then
            all[#all+1] = {
                name = "Ticket #"..o.ticket_num .. " by "..member.name .. " [OFFER]",
                value = o.str .. "\n<@"..o.user_id..">",
                num = o.ticket_num
            }
        end
    end

    table.sort(
        all, 
        function(a, b)
            return a.num < b.num
        end
    )

    for i = 1, #all do
        local tab = all[i]
        tab.num = nil
    end

    nav:set_fields(all)
    nav:start()
end

local function create_offer_embed(channel, user_id)
    local nav = PM.new("moddr_offer_embed", channel)
    nav:set_title("Moddr Team-Up Offers")
    nav:set_description("Check the board below for currently active offers for teaming up!")
    nav:set_fields_per_page(10)

    local guild = channel.guild

    if user_id then
        local member = guild:getMember(user_id)
        nav:set_title("Moddr Team-Up Offers ["..member.name.."]")
        nav:set_description("List of all current offer tickets registered by you.")
    end

    local all = {}
    -- for i = 1, #saved_data.gromboard.moddr.requests do
    --     local o = saved_data.gromboard.moddr.requests[i]

    --     local member = guild:getMember(o.user_id)
    --     if member then
    --         all[#all+1] = {
    --             name = "Ticket #"..o.ticket_num .. " by "..member.name .. " [REQUEST]",
    --             value = o.str .. "\n<@"..o.user_id..">",
    --         }
    --     end
    -- end
    for i = 1, #saved_data.gromboard.moddr.offers do
        local o = saved_data.gromboard.moddr.offers[i]

        local member = guild:getMember(o.user_id)
        if member and (not user_id or user_id == o.user_id) then
            all[#all+1] = {
                name = "Ticket #"..o.ticket_num .. " by "..member.name .. "",
                value = o.str .. "\n<@"..o.user_id..">",
            }
        end
    end

    nav:set_fields(all)
    nav:start()
end

local function create_request_embed(channel, user_id)
    local nav = PM.new("moddr_embed", channel)
    nav:set_title("Moddr Team-Up Requests")
    nav:set_description("Check the board below for currently active requests for teaming up!")
    nav:set_fields_per_page(10)

    local guild = channel.guild

    if user_id then
        local member = guild:getMember(user_id)
        nav:set_title("Moddr Team-Up Requests ["..member.name.."]")
        nav:set_description("List of all current request tickets registered by you.")
    end

    local all = {}
    for i = 1, #saved_data.gromboard.moddr.requests do
        local o = saved_data.gromboard.moddr.requests[i]

        local member = guild:getMember(o.user_id)
        if member and (not user_id or user_id == o.user_id) then
            all[#all+1] = {
                name = "Ticket #"..o.ticket_num .. " by "..member.name .. "",
                value = o.str .. "\n<@"..o.user_id..">",
            }
        end
    end
    -- for i = 1, #saved_data.gromboard.moddr.offers do
    --     local o = saved_data.gromboard.moddr.offers[i]

    --     local member = guild:getMember(o.user_id)
    --     if member then
    --         all[#all+1] = {
    --             name = "Ticket #"..o.ticket_num .. " by "..member.name .. " [OFFER]",
    --             value = o.str .. "\n<@"..o.user_id..">",
    --         }
    --     end
    -- end

    nav:set_fields(all)
    nav:start()
end

--  TODO dis
-- local post = CM:new_command(
--     "post",
--     function(message, args)
    
--     end
-- )
-- post:set_name("Post")
-- post:set_description("Get Gromby to post something later on, using your input. Can be used for regularly-posted things.")
-- post:set_usage("`%spost #channel Input here.` Input can be any message you'd normally send to get Grombot to do stuff.")
-- post:set_trigger("message", "post")
-- post:set_category("Admin")
-- post:set_validity_check(is_admin)
-- post:set_argument_parser(
--     ---@param message Message
--     ---@param args string[]
--     function (message, args)
--         local channel = message.channel

--         local mentioned_channels = message.mentionedChannels
--         if #mentioned_channels == 1 then
--             ---@type GuildTextChannel
--             channel = mentioned_channels.first
--         end

--         local msg
--     end
-- )

local moddr = CM:new_command(
    "moddr",
    function(message, args)
        create_embed(message.channel)
    end
)
moddr:set_name("Moddr")
moddr:set_description("Open up the Moddr board, to check to see any current requests or offers. Use the subcommands `request` or `offwer` (looking for / up for) to view specifically requests or offers, or to submit one yourself.")
moddr:set_usage("`%smoddr`")
moddr:set_trigger("message", "moddr")

local tickets = moddr:set_sub_command(CM:new_command(
    "moddr_tickets",
    ---@param message Message
    ---@param args any
    function(message, args)
        create_embed(message.channel, message.author.id)
    end
))
tickets:set_name("View Own Tickets")
tickets:set_description("View all of your currently active tickets, for either requests or offers.")
tickets:set_usage("`%smoddr tickets`")
tickets:set_trigger("message", "tickets")

local clear_ticket = moddr:set_sub_command(CM:new_command(
    "moddr_clear_ticket",
    function(message, args)
        local ticket = args.ticket
        local num = args.num

        moddr_remove_ticket(num)

        message.channel:send("Ticket #" ..num.." cleared!")
    end
))
clear_ticket:set_name("Clear Ticket")
clear_ticket:set_description("Clear a ticket you've submitted.")
clear_ticket:set_usage("`%smoddr clear_ticket #1` where 1 is the ticket number being removed.")
clear_ticket:set_trigger("message", "clear_ticket")
clear_ticket:set_argument_parser(
    function (message, args)
        printf("First arg is %q", tostring(args[1]))
        local ticket_num = args[1]
        if string.find(ticket_num, "#") then
            ticket_num = string.gsub(ticket_num, "#", "")
        end

        if not ticket_num then
            return false, "You have to provide a ticket number!"
        end

        local ticket = get_ticket(tonumber(ticket_num))
        if not ticket then
            return false, "There is no ticket with the number [#"..tostring(ticket_num).."]"
        end

        -- if the arg user is an admin, continue
        if not is_admin(message.member) then  
            if not ticket.user_id == message.author.id then
                return false, "This is not your ticket!"
            end
        end

        return {
            ticket = ticket,
            num = ticket_num,
        }
    end
)

local lf = moddr:set_sub_command(CM:new_command(
    "moddr_lf",
    function(message, args)
        create_request_embed(message.channel)
    end
))
lf:set_name("Moddr Request")
lf:set_description("Open up the Moddr board to check \"Looking For\" requests. Use the subcommands `submit` or `search` to either submit a Looking For request, or to search within specific parameters.")
lf:set_usage("`%smoddr request` or `moddr looking for`")
lf:set_trigger("message", "lf")
lf:set_trigger("message", "looking for")
lf:set_trigger("message", "request")

local lf_submit = lf:set_sub_command(CM:new_command(
    "moddr_lf_submit",
    function(message, args)
        local channel = message.channel

        local user_id = args.user
        local str = args.str

        local ticket = moddr_add_request(user_id, str)

        channel:send("Request with details \""..str.."\" submitted, with ticket number ["..ticket.."]!")
    end
))
lf_submit:set_name("Moddr Looking For: Submit")
lf_submit:set_description("Submit a request to the Moddr board, so others might see it later on!")
lf_submit:set_usage("`%smoddr request submit \"Your request here, include all relevant details!\"`")
lf_submit:set_trigger("message", "submit")
lf_submit:set_validity_check(is_cnc_and_modder)
lf_submit:set_argument_parser(
    ---@param message Message
    ---@param args table<number, string>
    function(message, args)
        local user = message.member.user
        local user_id = user.id

        local str = table.concat(args, " ")

        local quoted_str = get_quoted_name_from_string(str)

        if not quoted_str or quoted_str == "" then
            return false, "You have to submit details! `moddr request submit \"Your details here\"`, within quotes."
        end

        return {
            user = user_id,
            str = quoted_str,
        }
    end
)

local lf_search = lf:set_sub_command(CM:new_command(
    "moddr_lf_search",
    function(message, args)

    end
))
lf_search:set_name("Moddr Looking For: Search")
lf_search:set_description("Search for a specific request on the request board. Could search for queries such as 'unit cards' or 'script'.")
lf_search:set_usage("`%smoddr request search \"search here\"`")
lf_search:set_trigger("message", "search")

local uf = moddr:set_sub_command(CM:new_command(
    "moddr_uf",
    function(message, args)
        create_offer_embed(message.channel)
    end
))
uf:set_name("Moddr Offer")
uf:set_description("Open up the Moddr board to check \"Up For\" offers. Use the subcommands `submit` or `search` to either submit a Up For offer, or to search within specific parameters.")
uf:set_usage("`%smoddr offer` or `moddr up for`")
uf:set_trigger("message", "uf")
uf:set_trigger("message", "up for")
uf:set_trigger("message", "offer")

local uf_submit = uf:set_sub_command(CM:new_command(
    "moddr_uf_submit",
    function(message, args)
        local channel = message.channel

        local user_id = args.user
        local str = args.str

        local ticket = moddr_add_offer(user_id, str)

        channel:send("Request with details \""..str.."\" submitted, with ticket number ["..ticket.."]!")
    end
))
uf_submit:set_name("Moddr Up For: Submit")
uf_submit:set_description("Submit an offer to the Moddr board, so others might see it later on!")
uf_submit:set_usage("`%smoddr offer submit \"Your offer here, include all relevant details!\"`")
uf_submit:set_trigger("message", "submit")
uf_submit:set_argument_parser(
    ---@param message Message
    ---@param args table<number, string>
    function(message, args)
        local user = message.member.user
        local user_id = user.id

        local str = table.concat(args, " ")

        local quoted_str = get_quoted_name_from_string(str)

        if not quoted_str or quoted_str == "" then
            return false, "You have to submit details! `moddr offer submit \"Your details here\"`, within quotes."
        end

        return {
            user = user_id,
            str = quoted_str,
        }
    end
)

local uf_search = uf:set_sub_command(CM:new_command(
    "moddr_uf_search",
    function(message, args)

    end
))
uf_search:set_name("Moddr Up For: Search")
uf_search:set_description("Search for a specific offer on the offer board. Could search for queries such as 'unit cards' or 'script'.")
uf_search:set_usage("`%smoddr offer search \"search here\"`")
uf_search:set_trigger("message", "search")