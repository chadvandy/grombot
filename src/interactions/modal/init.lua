local discordia = require("discordia")
local client = discordia.storage.client

---@type InteractionManager
local InteractionManager = discordia.storage.InteractionManager

local typing = require("type_checking")
local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
local log_me = require("logging").log_me

---@class Interaction.Modal : Class
---@field __new fun():Interaction.Modal
local Modal = NewClass("Modal", {})

function Modal:new(key, title)
    local o = self:__new()
    return o:init(key, title)
end

function Modal:init(key, title)
    self.payload = {
        custom_id = key,
        title = title,

        components = {},
    }

    return self
end

-- --- Add a dropdown menu to the Modal.
-- ---@param custom_id string
-- ---@param options {label:string, value:string, description:string?, default:boolean?}[]
-- function Modal:add_menu(custom_id, options, min_i, max_i)
--     if #self.payload.components > 5 then
--         errmsg("Can't do more than 5 components for a Modal!")
--         return
--     end

--     local menu = {
--         type = 1,
--         components = {
--             {
--                 type= 3,
--                 custom_id = custom_id,
        
--                 options = options,
--             }
--         }
--     }

--     self.payload.components[#self.payload.components+1] = menu
-- end

function Modal:add_input(custom_id, label, is_required, is_short)
    if #self.payload.components > 5 then
        errmsg("Can't do more than 5 text inputs for a Modal!")
        return false
    end

    local input = {
        type = 1,
        components = {
            {
                type = 4,
                custom_id = custom_id,
                label = label,
                required = is_required,
                style = (is_short and 1) or 2
            }
        }
    }

    self.payload.components[#self.payload.components+1] = input
end

function Modal:get_payload()
    return self.payload
end

function Modal:process(int, args)
    self._callback(int, args)
end

---@param fn fun(int:Interaction, args:table<string, string>)
function Modal:set_callback(fn)
    if not is_function(fn) then
        return
    end

    self._callback = fn
end

return Modal