--- TODO proper Rich Embed system that verifies and cleans up rich embeds

---@class Discord.RichEmbed
local defaults = {
    title = "",
    type = "rich",
}

---@class Discord.RichEmbed : Class
local Embed = NewClass("RichEmbed", defaults)