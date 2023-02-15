local function flush()
	-- set a random seed
	math.randomseed(os.time())

	-- flush out the random shit
	math.random()
	math.random()
	math.random()
	math.random()
	math.random()
end

local function roll_dice(max, min)
	if not min then min = 1 end

	return math.random(min, max)
end

---@class die_obj
local die_obj = {
	-- num_faces = 6,
	---@type number The maximum value rollable
	max_value = 6,
	---@type number The minimum value rollable
	min_value = 1,
	---@type number The value jump between faces (for things like evens-only dice or whatever)
	diff = 1,

	---@type number The number of times to roll this die
	num_times = 1,

	---@type number Number of dice to keep if rolling with advantage/disadvantage
	num_keep = 1,

	---@type number Advantage state. 0 is none, 1 is advantage (keep best), 2 is disadvantage (keep worst)
	adv_state = 0,
}

local __die_obj = {
	__index = die_obj,
	__tostring = function(o)
		return "d" .. o.max_value
	end,
}

function die_obj:roll()
	local num_times = self.num_times

	local results = {}
	for _ = 1, num_times do
		results[#results+1] = math.random(self.min_value, self.max_value)
	end

	self.results = results

	local total = 0
	if self.adv_state == 0 then
		for i = 1, #results do
			total = total + results[i]
		end

		return total
	end

	table.sort(results)
	local num_keep = self.num_keep

	if self.adv_state == 1 then
		-- take the highest
		for i = 0, num_keep-1 do
			total = total + results[#results-i]
		end
	else
		-- take the lowest
		for i = 1, num_keep do
			total = total + results[i]
		end
	end

	printf("Rolled w/ %s, got %d", self.adv_state == 1 and "advantage" or "disadvantage", total)

	return total
end

---comment
---@param o table
---@return die_obj
function die_obj:new(o)
	o = o or {}
	setmetatable(o, __die_obj)
	return o
end

---@class dice_bowl
local dice_bowl = {
}

---comment
---@param die die_obj
---@param is_subtraction boolean
function dice_bowl:add_die(die, is_subtraction)
	if is_subtraction then is_subtraction = -1 else is_subtraction = 1 end
	self.pool[#self.pool+1] = {die, is_subtraction}
end

function dice_bowl:format_results()
	-- take the results table (which has the die object and the result rolled, and the is_sub value) and go through it to format a single string
	-- take the largest dice type first, and go down
	-- group 
end

--- Roll all of the dice, return the final result and a string for the actual individual parts.
function dice_bowl:roll()
	self.value = 0

	local pool = self.pool
	local results = {}

	for _,die_table in ipairs(pool) do
		---@type die_obj
		local die = die_table[1]
		local is_subtraction = die_table[2]
		local roll = die:roll()

		if die.num_times >= 5 then
			results[#results+1] = string.format("%s %d[%d%s]", is_subtraction == -1 and "-" or #results==0 and "" or "+", roll, die.num_times, "d"..die.max_value)
		else
			-- print each individual result
			-- TODO if it's adv then ~~d~~ out the unused rolls
			local diced = die.results
			for i = 1, #diced do
				local res = string.format("%s %d[%s]", is_subtraction == -1 and "-" or #results==0 and "" or "+", diced[i], "d"..die.max_value)
				results[#results+1] = res
			end
		end

		self.value = self.value + (is_subtraction * roll)
	end

	if self.mods ~= 0 then
		results[#results+1] = string.format("%s%d", self.mods<0 and "" or "+", self.mods)
		self.value = self.value + self.mods
	end

	return self.value, table.concat(results, " ") .. " = "..self.value
end

---@type dice_bowl
function dice_bowl:new(o)
	o = o or {}
	o.pool = {}
	o.mods = 0
	return setmetatable(o, {__index = dice_bowl})
end

--- Take a single table of strings from the arg, and parse them into separate dice to be used in the roll.
--- Can take any number of dice, any types, with a few limitations.
--[[
	understands
		NdX
		dX, defaults to 1
		+/-N
		+/-d
		Ib[NdX] or Iw[NdX], for "roll NdX, take the best/worst I of them"
		doesn't require spaces between args, just the +/- symbols
--]]

--- Takes the message content (sans the ?roll command) and divvies it up accordingly.
---@param message Message
---@param args string[]
---@return table
local function parse_args(message, args)
	-- remove all spaces for ease of use
	local msg = message.content:gsub(" ", "")

	--[[
		[+-]? - start the search off by seeing if there's a +/- symbol. Optional
			-- This is all for the best/worst check
			%d* - check next for any leading num-dice for the best/worst check
			[bw]? - check to see if there's either a "b" or a "w"
			%[? -  check for the front bracket, optional
		%d* - check to see for leading num-dice for the proper die
		d - grab the "d" in the middle
		%d+ - grab all of the trailing dice at the end for the num-faces
			%]? - optional end bracket
	--]]

	printf("Full string for dice is %s", msg)

	local pool = dice_bowl:new()

	for word in msg:gmatch("[+-]?%d*[bw]?%[?%d*d%d+%]?") do
		printf("Die found! %s", word)

		local die = die_obj:new()

		-- handle advantage/disadvantage
		if word:find("[bw]") then
			local num_keep = word:match("%d*[bw]"):gsub("[bw]", "")
			if not num_keep then num_keep = 1 end

			local is_best = word:find("b")

			die.num_keep = num_keep
			die.adv_state = is_best and 1 or 2
		end

		local is_subtraction = word:find("-")
		local num_dice = word:match("%d*d"):gsub("d", "")
		if num_dice == "" then num_dice = 1 end
		

		local num_faces = word:match("d%d+"):gsub("d", "")

		printf("Num dice: %d.\nNum faces: %d.", num_dice, num_faces)

		die.max_value = tonumber(num_faces)
		die.num_times = tonumber(num_dice)

		pool:add_die(die, is_subtraction)

		printf("New die %s", tostring(die))
	end

	-- check at the end for any mods
	local mods = msg:match("[+-]%d+$")
	if mods then
		mods = tonumber(mods)
	else
		mods = 0
	end

	pool.mods = mods

	return {
		pool = pool
	}
end

---@class dice_args

-- TODO better +/-; allow for "roll 1d6+6" instead of needing the space

-- arg1: XdY, where X is the number of dice, and Y is the highest number on the die
-- arg2: +/-N, where N is an arbitrary number to add or subtract from the end result
---@param args dice_args
---@param message Message
CM:new_command("roll", function (message, args)
	flush()

	---@type dice_bowl
	local pool = args.pool

	local res,str = pool:roll()

	message.channel:send("Rolled a " .. res .. ".\n\n"..str)
end)
:set_name("Roll the Dice:tm:")
:set_description("A randomized dice roller! Handles any types of dice or any number of dice - up to a point!")
:set_usage("`%sroll XdY +N`, where X is the number of dice, Y is the number of faces on the die, and N is any addition to perform after the fact. Assumes 1d6 if nothing is provided.")
:set_category("Utility")
:set_argument_parser(parse_args)
:set_trigger("message", "roll")
:set_trigger("message", "dice")


local q_formatted = {
	"Wazzock, you really want to ask me that?",
	"I am compelled by Grungni to answer your question.",
}

local answers = {
	"Yes - so it's written!",
	"Assuredly.",
	"Without a doubt.",
	"Yes. Definitely.",
	"You may rely on it.",
	"As my eyes see - yes.",
	"Most likely.",
	"Outlook: pretty good.",
	"Yeah man.",
	"Runes point to yes.",

	"Reply hazy, try again.",
	"Ask again later.",
	"Better tell you later.",
	"Can't tell.",
	"Concentrate, and ask once more.",

	"Don't count on it.",
	"Hell no.",
	"My sources say no.",
	"Outlook: pretty bad.",
	"Incredibly doubtful.",
}

local recent_questions = {
	last_time = 0,
	last_q = {

	}
}

local ask_grom = CM:new_command(
	"ask_grom",
	function(message, args)
		flush()

		local q = args.q
		local q_str = string.format(q_formatted[math.random(#q_formatted)], q)

		q_str = q_str .. "\n\nMy answer is ... \n" .. answers[math.random(#answers)]

		message.channel:send(q_str)
	end
)
ask_grom:set_name("Ask Grom")
ask_grom:set_description("Ask Grombrindal anything, and be delivered an answer if he finds you worthy!")
ask_grom:set_usage("`%sask_grom Will I ever find love?`")
ask_grom:set_trigger("message", "ask_grom")
ask_grom:set_category("Goof")
ask_grom:set_argument_parser(
	function (message, args)
		local channel = message.channel
		if channel.id ~= "810247445333540894" then
			return false, "You can only use this command in <#810247445333540894>."
		end
		local q = table.concat(args, " ")
		if q == "" then
			return false, "C'mon, ask me a question!"
		end

		if not q:endswith("?") then
			return false, "You gotta ask a question, fool!"
		end

		return {
			q = q,
		}
	end
)