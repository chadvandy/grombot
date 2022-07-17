-- Config file handler, for guild-based and user-based settings.
--[[ Needed to Config:
        guild-based (admin only edits):
            - prefix
            - admin logging channel
            - bot-command channels
            - admin-acting roles
            - role things?
            -- post changelogs (default to NO)
        user-based:
            - 
--]]

--- One instance of configs per guild; there's a default if a setting isn't defined for a guild.
local ConfigInstance = {

}

local ConfigDefaults = {}