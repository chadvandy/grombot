--- TODO handle metric system uniformly across the dec's
--- TODO better caps control
--- TODO handle plural
local conversions = {
    Fahrenheit = {
        default = "Celsius",
        alias = {
            "F","f",
        },
        convert = {
            Celsius = function(n)
                return math.round((n - 32) * (5/9), 1)
            end,
        },
    },
    Celsius = {
        default = "Fahrenheit",
        alias = {
            "C","c",
        },
        convert = {
            Fahrenheit = function(n)
                return math.round((n * (9/5) + 32))
            end,
        },
    },
    Millimeter = {
        default = "Inch",
        alias = {
            "mm",
        },
        convert = {
            Inch = function(n)
                -- TODO floating point
                return n / 25.4
            end,
        }
    },
    Inch = {
        default = "Centimeter",
        alias = {
            "in",
        },
        convert = {
            Millimeter = function(n)
                --- TODO floating point
                return n * 25.4
            end,
            Centimeter = function(n)
                return n * 2.54
            end,
            Foot = function(n)
                return n / 12
            end,
        }
    },
    Foot = {
        default = "Meter",
        alias = {
            "ft",
        },
        convert = {
            Inch = function(n)
                return n * 12
            end,
            Meter = function(n)
                return n/3.281
            end,
            Centimeter = function(n)
                return n*30.48
            end,
        }
    },
    Centimeter = {
        default = "Inch",
        alias = {
            "cm",
        },
        convert = {
            Inch = function(n)
                return n * 2.54
            end,
            Foot = function(n)
                return n / 30.48
            end,
            Meter = function(n)
                return n / 100
            end,
            Millimeter = function(n)
                return n * 10
            end,
        }
    },
    Mile = {
        default = "Kilometer",
        alias = {
            "mi",
        },
        convert = {
            Kilometer = function(n)
                return n * 1.609
            end,
            ["Nautical Mile"] = function(n)
                return n / 1.151
            end,
        },
    },
    ["Nautical Mile"] = {
        default = "Mile",
        alias = {
            "nm",
        },
        convert = {
            Mile = function(n)
                return n * 1.151
            end,
            Kilometer = function(n)
                return n * 1.852
            end,
        }
    },
    Kilometer = {
        default = "Mile",
        alias = {
            "km",
        },
        convert = {
            Mile = function(n)
                return n / 1.609
            end,
            ["Nautical Mile"] = function(n)
                return n / 1.852
            end,
        }
    }
}

local function get_conversion_with_name(type_name)
    for conversion_name,data in pairs(conversions) do
        if conversion_name == type_name then
            return data,conversion_name
        end

        for i = 1, #data.alias do
            local alias = data.alias[i]
            if alias == type_name then
                return data,conversion_name
            end
        end
    end

    return nil
end

local function get_conversion_name_by_alias(type_name)
    for conversion_name,data in pairs(conversions) do
        if conversion_name == type_name then
            return conversion_name
        end

        for i = 1, #data.alias do
            local alias = data.alias[i]
            if alias == type_name then
                return conversion_name
            end
        end
    end

    return nil
end

local convert = CM:new_command(
    "convert",
    ---@param message Message
    ---@param args conversion_args
    function(message, args)
        if next(args) == nil then
            return message.channel:send({
                file = "assets/wololo.jpg",
            })
        end

        local n,x,y = args.n, args.x, args.y

        local conversion,name = get_conversion_with_name(x)
        local type_name = get_conversion_name_by_alias(y)

        
        local converter = conversion.convert[type_name]
        if not converter then
            return message.channel:send("No valid conversion from "..name .. " to " .. type_name .. "!")
        end
        
        local result = converter(n)
        
        message.channel:send("Converting " ..name .. " to " .. type_name .. "\nResult is " .. tostring(result) .. " " .. type_name)
    end
)
convert:set_name("Convert")
convert:set_description("Convert one value to another. Use `?convert` to see all available conversions!")
convert:set_usage("`%sconvert nX to Y`, where n is the number, x is the first type, and y is the type to convert to.")
convert:set_trigger("message", "convert")
convert:set_trigger("message", "conversion")
convert:set_category("Utility")
convert:set_argument_parser(
    ---@param message Message
    ---@param args table<number, string>
    function (message, args)
        if #args == 0 then
            return {}
        end

        -- there's no "to" passed, so it's just `?convert nX" or `?convert n X".
        if #args <= 2 then
            if #args == 2 then
                local n = tonumber(args[1])
                local x = args[2]

                if not is_number(n) then
                    return false, "You have to provide a number to convert, ie. `?convert 5C`, where 5 is the number to convert!"
                end

                if not is_string(x) then
                    return false, "You have to provide a type to convert from, ie. `?convert 5C`, where C is the type!"
                end
        
                if not get_conversion_name_by_alias(x) then
                    return false, "Conversion ["..x.."] isn't recognized!"
                end

                local conversion = get_conversion_with_name(x)
                local y = conversion.default
                if not y then
                    return false, "Conversion ["..x.."] doesn't have any default convert-to types! You have to provide a type, by using `?convert nX to Y`, and providing Y."
                end

                return {
                    n = n,
                    x = x,
                    y = y
                }
            else
                local x = args[1]
                local n
                for i = 1,x:len() do
                    local test = x:sub(1, i)
                    if is_number(tonumber(test)) or test == "+" or test == "-" then
                        n = tonumber(test)
                    else
                        x = x:sub(i)
                        break
                    end
                end
                if not is_number(n) then
                    return false, "You have to provide a number to convert, ie. `?convert 5C to F`, where 5 is the number to convert!"
                end

                if not is_string(x) then
                    return false, "You have to provide a type to convert from, ie. `?convert 5C`, where C is the type!"
                end
        
                if not get_conversion_name_by_alias(x) then
                    return false, "Conversion ["..x.."] isn't recognized!"
                end

                local conversion = get_conversion_with_name(x)
                local y = conversion.default
                if not y then
                    return false, "Conversion ["..x.."] doesn't have any default convert-to types! You have to provide a type, by using `?convert nX to Y`, and providing Y."
                end

                return {
                    n = n,
                    x = x,
                    y = y
                }
            end
        end

        local to_pos = 0
        for i = 1, #args do
            if string.lower(args[i]) == "to" then
                to_pos = i
            end
        end

        if to_pos == 0 then
            return false, "You have to use \"to\" between the two types! ie., `?convert 5C to F`"
        end

        local x_pos = to_pos -1
        local n
        local x = args[x_pos]

        if not x then
            return false, "You have to provide a type that's being converted, ie. `?convert 5C to F`, where C is the type."
        end

        if x_pos > 1 then
            n = tonumber(args[x_pos-1])

            if not is_number(n) then
                return false, "You have to provide a number to convert, ie. `?convert 5C to F`, where 5 is the number to convert!"
            end
        else
            for i = 1,x:len() do
                local test = x:sub(1, i)
                if is_number(tonumber(test)) or test == "+" or test == "-" then
                    n = tonumber(test)
                else
                    x = x:sub(i)
                    break
                end
            end
        end

        local y = args[to_pos + 1]
        if not y then
            return false, "You have to choose a type to convert to, ie. `?convert 50C to F`."
        end

        if not is_number(n) then
            return false, "You have to provide a number to convert, ie. `?convert 5C to F`, where 5 is the number to convert!"
        end

        if not get_conversion_name_by_alias(x) then
            return false, "Conversion ["..x.."] isn't recognized!"
        end

        if not get_conversion_name_by_alias(y) then
            return false, "Conversion ["..y.."] isn't recognized!"
        end

        ---@class conversion_args
        return {
            n = n,
            x = x,
            y = y,
        }
    end
)