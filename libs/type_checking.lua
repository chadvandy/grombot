local t = type

return {
    ---@param o any
    is_string = function(o) return t(o) == "string" end,
    is_boolean = function(o) return t(o) == "boolean" end,
    is_table = function(o) return t(o) == "table" end,
    is_number = function(o) return t(o) == "number" end,
    is_nil = function(o) return t(o) == "nil" end,
    is_function = function(o) return t(o) == "function" end,
    is_userdata = function(o) return t(o) == "userdata" end,
}