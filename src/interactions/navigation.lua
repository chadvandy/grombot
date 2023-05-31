--- TODO port the Navigation Systems (fancy embeds that have multiple pages) to the new Message Components system!
local IM = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata

---@class Navigation
local defaults = {
    _user = nil,
    _channel = nil,

    _current_page = 1,
    _total_pages = 1,
    _fields_per_page = 10,

    _timeout = 300000,

    _fields = {},

    _components = {},

    _embed = {},

    _footer = "",
    _title = "",
    _description = "",

    _bStarted = false,
}

---@class Navigation : Class
---@field __new fun():Navigation
local Nav = NewClass("Navigation", defaults)

local btn_previous_page = IM.Components.Button:new("previous_page")
    :set_custom_id("previous_page")
    :set_label("<")
    :set_style(2)


local btn_next_page = IM.Components.Button:new("next_page")
    :set_custom_id("next_page")
    :set_label(">")
    :set_style(2)

--- TODO 
local btn_stop = IM.Components.Button:new("stop_navigation")
    :set_custom_id("stop_navigation")
    :set_style(4)
    :set_label("Stop")


--- Create a new Nav Prompt.
function Nav:new()
    local o = self:__new()
    return o:init()
end

function Nav:init()

    return self
end

function Nav:use_default_components()
    local holder = IM.Components.Holder:new()
        :add_component(btn_previous_page)
        -- :add_component(btn_stop)
        :add_component(btn_next_page)

    self._components = {holder}
end

function Nav:get_components_payload()
    return {self._components[1]:get_payload()}
end

function Nav:set_page(page_num)
    if not is_number(page_num) then return end
    self._current_page = math.clamp(page_num, 1, self._total_pages)
end

function Nav:set_title(title)
    self._embed.title = title
end

---@param user User
function Nav:set_user(user)
    self._user = user.id
end

function Nav:set_fields_per_page(n)
    self._fields_per_page = n
end

function Nav:set_fields(tab)
    self._fields = tab

end

function Nav:build_embed()
    local total = 6000
    local current = 0

    if is_string(self._embed.title) then
        current = current + self._embed.title:len()
    end

    if is_string(self._embed.description) then
        current = current + self._embed.description:len()
    end

    current = self:handle_fields(current)
    
    if self._footer == "" then
        self._embed.footer = {
            text = string.format("Page %d of %d\t%d total fields", self._current_page, self._total_pages, #self._fields)
        }
    elseif is_string(self._footer) then
        self._embed.footer = {
            text = self._footer
        }
    else
        self._embed.footer = nil
    end

    local ok, err = validate_embed(self._embed)
    if not ok then
        self._valid = false
        return errmsg(err)
    end

    self._valid = true

    return self._embed
end

function Nav:handle_fields(current)
    local total = 6000

    self._total_pages = math.ceil(#self._fields / self._fields_per_page)

    local field_num = (self._fields_per_page * (self._current_page -1)) + 1
    local field_end = field_num + self._fields_per_page -1
    if field_end > #self._fields then field_end = #self._fields end

    -- if self._fields_is_description then
    --     local str = table.concat(self._fields, "\n", field_num, field_end)
    --     if self._description ~= "" then
    --         str = self._description .. "\n\n" .. str
    --     end

    --     self._embed.description = str
    -- else
        if self._description ~= "" then
            self._embed.description = self._description
        end

        self._embed.fields = {}

        for i = field_num, field_end do
            local field = self._fields[i]
            if field then
                local name = field.name
                if name:len() > 256 then
                    name = name:sub(1, 256-6) .. " [...]"
                end
    
                current = current + name:len()
                if current >= total then
                    break
                end
                
                local value = field.value
                if value:len() > 1024 then
                    value = value:sub(1, 1024-6) .. " [...]"
                end
    
                current = current + value:len()
                if current >= total then
                    break
                end

                local inline = is_boolean(field.inline) and field.inline or false
        
                self._embed.fields[#self._embed.fields+1] = {
                    name = name,
                    value = value,
                    inline = inline,
                }
            end
        end

    return current
end

--- Start the message!
---@param int Interaction
function Nav:send_message(int)
    local embed = self:build_embed()

    ok, err = int:reply({
        embed = embed,
        components = self:get_components_payload()
    })

    if not ok then
        errmsg(err)
    else
        ---@type Message
        local msg = int:getReply()
        self._msg_id = msg.id
        self._msg = msg
    end
end

---@param int Interaction
function Nav:refresh(int)
    local msg = self._msg
    local embed = self:build_embed()

    int:update(
        {
            content = "",
            embed = embed,
            components = self:get_components_payload(),
        }
    )
end


--- TODO timeout
--- TODO "stop" prompt
--- TODO close out a nav if it's not found 
function Nav:init_listeners()
    discordia.storage.client:on(
        "messageComponentInteraction",
        ---@param iInt Interaction
        ---@param data table
        ---@param values table<string, any>?
        function(iInt, data, values)
            -- Only listening for this one message!
            if iInt.message.id ~= self._msg_id then
                return
            end

            --- If we have a user set, we need to restrict access.
            if self._user and iInt.user.id ~= self._user then
                -- Refreshing so we still register the interaction.
                return self:refresh(iInt)
            end

            local cId = data.custom_id

            if cId then

                if cId == "previous_page" then
                    self:set_page(self._current_page - 1)
                elseif cId == "next_page" then
                    self:set_page(self._current_page + 1)
                elseif cId == "stop_navigation" then
                    -- TODO close out of the navigation prompt.
                end

                self:refresh(iInt)
            end
        end
    )
end

---@param int Interaction
function Nav:start(int)
    if #self._fields == 0 then
        -- respond that there's a bug here!
        int:reply("ERROR with this navigation!")
    end

    self:set_page(1)

    self:send_message(int)
    self:init_listeners()
end

return Nav