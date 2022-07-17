--@type class
local class = {}

--@param obj any
--@param cls class
function class.isInstance(obj, cls)

end

--@param str string
--@param check string
function string.startswith(str, check)

end

--@param str string
--@param sep string
function string.split(str, sep)
    
end

--@param tbl table
--@return table
function table.copy(tbl)

end

--@type Emitter
local emitter = {}
emitter._listeners = {}

--@type Message
local message = {}

--@type TextChannel|GuildChannel
message.channel = nil

--@type Member
local member = {}
--@type string
member.id = ""