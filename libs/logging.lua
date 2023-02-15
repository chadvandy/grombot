local discordia = require("discordia")
local client = discordia.storage.client

return {
    log_me = function(...)
        local s = ''
        for i=1,select('#',...) do s = string.format("%s %s", s, tostring(select(i, ...))) end

        client.owner:send(s)
    end
}