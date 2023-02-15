---- Arbitrarily run code. Can ONLY BE USED by moi!

local code = CM:new_command(
    "code",
    function(message, args)
        local channel = message.channel

        local code_string = table.concat(args, " ")

        local fn, syntax_err = load(code_string)
        if not fn then return channel:send(syntax_err) end

        local lines = {}

        local function print_line(...)
            local ret = {}
            for i = 1, select("#", ...) do
                local arg = tostring(select(i, ...))
                table.insert(ret, arg)
            end
            return table.concat(ret, "\t")
        end

        local env = getfenv()
        env.print = function(...)
            table.insert(lines, print_line(...))
        end

        env.msg = message

        setfenv(fn, env)

        local ret = nil
        local success, runtime_err = pcall(function() ret = fn() end)
        if not success then return channel:send(runtime_err) end

        if ret then
            channel:send("**Returned**: " .. tostring(ret))
        end

        local str = table.concat(lines, "\n")
        if str and str ~= "" then
            return channel:send(table.concat(lines, "\n"))
        end

        -- if nothing was returned and nothing was printed, just say Hi.
        if not ret then
            return channel:send("I did your code, I guess.")
        end
    end
)
code:set_name("Arbitrary Code")
code:set_description("Arbitrarily run any code. Groove Wizard only :)")
code:set_category("Admin")
code:set_trigger("message", "code")
code:set_usage("`%scode local code = do_stuff code()`")
code:set_validity_check(
    ---@param member Member
    function(member)
        local user = member.user
        if user.id ~= client.owner.id then
            return false, "Only Groove Wizard can use this!"
        end

        return true
    end
)