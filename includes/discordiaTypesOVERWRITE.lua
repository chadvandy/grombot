---@class class
local class = {}

---@param obj any
---@param cls class
function class.isInstance(obj, cls)

end

---@class Emitter
local emitter = {}
emitter._listeners = {}

---@class Message
local message = {}

---@type TextChannel|GuildChannel
message.channel = nil

---@class Member
local member = {}
---@type string
member.id = ""