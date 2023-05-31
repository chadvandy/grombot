--@type class
local class = {}

--@param obj any
--@param cls class
function class.isInstance(obj, cls)

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