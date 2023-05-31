local t = type

local typing = {}

function typing.is_string(o) return t(o) == "string" end
function typing.is_boolean(o) return t(o) == "boolean" end
function typing.is_table(o) return t(o) == "table" end
function typing.is_number (o) return t(o) == "number" end
function typing.is_nil(o) return t(o) == "nil" end
function typing.is_function (o) return t(o) == "function" end
function typing.is_userdata(o) return t(o) == "userdata" end


return typing