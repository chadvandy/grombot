--- Ticket system! Link tickets to valid details. Allow for separate "types" of tickets.
--- Tickets could be administrative actions, or Gromboard things, or Reminders, or anything in between.
--- They all share:
    -- A unique ID for the ticket
    -- A shared set of fields within types

local function save()
    save_data("tickets")
end

---@class ticket_manager
local ticket_manager = {
    tickets = {
        current_ticket_num = 1,
    },
}

function ticket_manager:generate_ticket_number(ticket_type)
    if not ticket_type then
        local current_num = saved_data.tickets.current_number
        saved_data.tickets.current_number = current_num +1
        save()

        return current_num
    end

    local tickets = saved_data.tickets[ticket_type]
    if not tickets then 
        saved_data.tickets[ticket_type] = {num = 1} 
        tickets = saved_data.tickets[ticket_type]
    end

    local num = tickets.num

    tickets.num = num + 1
    save()

    return num
end

-- function ticket_manager:init()
--     self.tickets = saved_data.tickets
-- end

return ticket_manager