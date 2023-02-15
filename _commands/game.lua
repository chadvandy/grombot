-- local discordia = require("discordia")
-- local client = discordia.storage.client

-- local typing = require("type_checking")
-- local is_boolean,is_string,is_function,is_number,is_nil,is_table,is_userdata = typing.is_boolean, typing.is_string, typing.is_function, typing.is_number, typing.is_nil, typing.is_table, typing.is_userdata
-- local log_me = require("logging").log_me

-- local game_guild = "880510793823694848"

-- ---@param msg Message
-- local function auth(msg)

-- end

-- local function save()
--     save_data("game")
-- end

-- --- TODO save data automatically on every modify method within (use Discordia method of __index calls w/ groups of methods)
-- -- TODO auto-roll a move
-- -- TODO some global function for "index a table for something that has this string", for macro search or looking in this moves table, etc.

-- local moves = {
--     ["Advantage/Disadvantage"] = "When you *make a roll with advantage*, roll an extra die and discard the lowest result.\nWhen you *make a roll with disadvantage*, roll an extra die and discard the highest result.\nWhen you *make a roll with both advantage and disadvantage*, roll as normal - they cancel each other out.",
--     ["Aid"] = "When you ***help another character who's about to roll***, they gain advantage but you are exposed to any risks, costs, or consequences.",
--     ["Defy Danger"] = "When ***danger looms, the stakes are high, and you act anyway***, check if another move applies. If not, roll...\n\n**+STR** to power through or test your might\n**+DEX** to employ speed, agility, or finesse\n**+CON** to endure or hold steady\n**+INT** to apply expertise or enact a clever plan\n**+WIS** to exert willpower or rely on your senses\n**+CHA** to charm, bluff, impress, or fit in\n\n**On a 10+**, you pull it off as well as one could hope.\n**On a 7-9**, you can do it, but the GM will present a lesser success, a cost, or a consequence (and maybe a choice between them, or a chance to back down).",
--     ["Discern Realities"] = "When you ***closely study a situation or person and look to the GM for insight***, roll +WIS.\n\n**On a 10+**, ask the GM 3 questions from the list blow.\n**On a 7-9**, ask 1 question from the list below.\nTake advantage on the next move that acts on the answers.\n- What happened here recently?\nWhat is about to happen?\nWhat should I be on the lookout for?\nWhat here is useful or valuable to me?\nWho or what is really in control heer?\nWhat here is not what it appears to be?",
--     ["Have What You Need"] = [[When you ***decide that you had something all along***, clear a slot (or two) from your Undefined gear, and mark an item or slot to indicate that you have it. If you mark a slot, fill it with a common, mundane item.
    
--     Alternatively, expend 1 use of Supplies (instead of Undefined) to produce a *small*, common, mundane item.]],

--     ["Interfere"] = [[When you ***try to foil another PC's action and neither of you back down,*** roll...
--         **+STR** to power through or test your might
--         **+DEX** to employ speed, agility, or finesse
--         **+CON** to endure or hold steady
--         **+INT** to apply expertise or enact a clever plan
--         **+WIS** to exert willpower or rely on your senses
--         **+CHA** to charm, bluff, impress, or fit in

--         **On a 10+**, they pick 1 from the list below.
--         **On a 7-9**, they pick 1 but you are left off balance, exposed, or otherwise vulnerable.
--         - Do the action anyway, but with disadvantage on your next roll.
--         - Relent, change course, or otherwise allow your move to be foiled.
--     ]],
--     ["Parley"] = [[When you ***press or entice an NPC***, say what you want them to do (or not do). If they ***have reason to resist***, roll +CHA.
        
--         **On a 10+**, they either do as you want, or reveal the easiest way to convince them.
--         **On a 7-9**, they reveal something you can do to convince them, though it'll likely be costly, tricky, or distasteful.

--         When you ***press or etice a PC and they resist***, you can roll +CHA.

--         **On a 10+**, both.
--         **On a 7-9**, pick 1:
--         - They mark XP if they do what you want.
--         - They must do what you want, or reveal how you could convince them to do so.       
--     ]],
--     ["Resupply"] = [[
--         When you ***take the opportunity to resupply***, erase all slots and reselct your gear as you wish. If you're paying for something, a *valuable* item (like a pouch of coins) should cover the party.
--     ]],
--     ["Spout Lore"] = [[
--         When you ***consult your accumulated knowledge about something***, roll +INT.

--         **On a 10+**, the GM will tell you something interesting and useful, and relevant about the subject.
--         **On a 7-9**, the GM will only tell you something interesting - it's on you to make it useful.

--         Either way, the GM may ask you "How do you know this?" Tell them the truth.
--     ]],

--     --- TODO all violence/recovery/chosen optional/ moves.
--     ["Deal Damage"] = [[
--         When you ***harm a foe but don't finish them outright***, roll your damage and say the result (plus any tags like *messy*, *forceful*, etc.). The GM will reduce the victim's HP by that amount (minus Armor) and either describe the result or ask you to do so.

--         When ***a creature is reduced to 0 HP***, they are out of the action: dead, unconscious, cowering, etc.

--         When you ***have advantage or disadvantage on a damage roll***, roll your damage die twice and take the higher or lower result, respctively; then add any bonus dice or modifiers that apply.

--         If you ***harm multiple foes at once***, roll damage separately for each.
--     ]],

--     ["Defend"] = [[
--         When you ***take up a defensive stance*** or ***jump in to protect others***, roll +CON.

--         **On a 10+**, hold 3-Readiness.
--         **On a 7-9**, hold 1-Readiness.

--         You can spend Readiness 1-to-1 to:
--         - Suffer an attack's damage/effects instead of your ward.
--         - Halve an attack's damage/effects.
--         - Draw all attention from your ward to yourself.
--         - Strike back at an attacker (Deal Damage w/ disadvantage)

--         When you ***go on the offense, cease to focus on the defense, or the threat passes***, lose any Readiness that you hold.
--     ]],

--     ["Hack and Slash"] = [[
--         When you ***fight in melee or close quarters***, roll +STR.

--         **On a 10+**, your meneuver works as expected (Deal Damage) and choose one:
--         - Evade, prevent, or counter the enemy's attack.
--         - Strike hard and fast, for extra 1d6 damage, but suffer the enemy's attack.
--         **On a 7-9**, your maneuver works (Deal Damage), but suffer the enemy's attack.
--     ]],

--     ["Volley"] = [[
--         When you ***launch a ranged attack***, roll +DEX.

--         **On a 10+**, you have a clear shot - Deal Damage.
--         **On a 7-9**, Deal Damage, but choose 1:
--         - You have to move/hold steady to take the shot, placing you in danger of the GM's choice
--         - Take what you can get; Deal Damage with disadvantage
--         - Deplete your ammunition; mark the next status next to your weapon
--     ]],

--     ["Take Damage"] = [[
--         When you ***are injured, roughed up, or otherwise suffer harm***, the GM will tell you how much damage you take, along with any additional effects. Reduce the damage by your Armor (if any) and lose that many HP.

--         When you are ***reduce to 0 HP***, you are out of the action. If you have suffered potentially deadly harm, you are dying - roll Last Breath.
--     ]],

--     ["Last Breath"] = [[
--         When you ***are dying***, you catch a glimpse of what lies beyond the Black Gates of Death - describe it. Then roll +Nothing.

--         **On a 10+**, you've cheated death - you're no longer dying, but you're still in a bad place.
--         **On a 7-9**, Death will offer you a bargain. Take it and stabilize, or refuse and pass beyond into whatever fate awaits you.
--         **On a 6-**, your fate is sealed. You're marked as Death's own, and you'll cross the threshold soon. The GM will tell you when.
--     ]],

--     ["Recover"] = [[
--         When you ***take time to catch your breath and tend to what ails you***, expend 1-Supplies and regain 5 HP. You can't benefit from this move twice in one rest.

--         When you ***tend to a debility or a problematic wound***, say how. The GM will either say that it'll take care of itself, or will tell you what's required to heal it (Defying Danger, expending Supplies, Making Camp, Downtime, finding something, etc.)
--     ]],

--     ["Make Camp"] = [[
--         When you ***settle in to rest in a dangerous area***, someone in the party must expend 1 use of Supplies. Then, take turns with the following:
--         - Give an example of how you've met your Drive's requirements. If you can, mark XP.
--         - Describe how your opinion of or relationship with another character has changed. If everyone agrees, mark XP.
--         - Point out something awesome that another character did, that no one else has mentioned yet. If it's sufficiently awesome, mark XP.

--         When you ***wake from at least a few hours sleep***, choose 1. If you expend 1 extra use of Supplies, choose another.
--         - Regain HP equal to 1/2 your maximum.
--         - Clear all your debilities.
--         - Gain advantage on your next roll.
--     ]]
-- }

-- -- -- TODO don't hardcode this
-- -- ---@type char_obj[]
-- -- local chars = {
-- --     ["Ricasso Hanvil"] = {
-- --         reaction = "🛠️",
-- --         class = "Fighter",
-- --         player_id = "279383618382594059",
-- --         stats = {
-- --             str = 2,
-- --             dex = 1,
-- --             con = 1,
-- --             int = 0,
-- --             wis = -1,
-- --             cha = 0,
-- --         },
-- --         drive = {
-- --             "Challenge:",
-- --             "Enter a fight that you aren't sure you can win."
-- --         },
-- --         background = {
-- --             name = "Weapon Insecure",
-- --             moves = {
-- --                 "When you ***Have What You Need***, you can always produce a weapon or tool for the job at hand, but it may be marked, dinged, or low quality in some way.",
-- --                 "When you ***Spout Lore about a weapon***, roll with Advantage.",
-- --                 "Start with three Weapon Specializations, instead of two.",
-- --             },
-- --         },
-- --         xp = 5,
-- --         hp = {
-- --             20,
-- --             20,
-- --         },
-- --         damage_die = "d10",

-- --         gear = {
-- --             max_load = 6,
            
-- --             inventory = {
-- --                 {
-- --                     name = "Breastplate",
-- --                     weight = 2,
-- --                     tags = {"clumsy"},
-- --                     mods = {
-- --                         armor = 2,
-- --                     },
-- --                 },
-- --                 {
-- --                     name = "Shield",
-- --                     weight = 2,
-- --                     tags = {"+1 Readiness when you roll Defend 7+"},
-- --                     mods = {
-- --                         armor = 1,
-- --                     },
-- --                 },
-- --                 {
-- --                     name = "Sword",
-- --                     weight = 1,
-- --                     mods = {
-- --                         damage = 1,
-- --                     },
-- --                 },
-- --                 {
-- --                     name = "Supplies",
-- --                     weight = 1,
-- --                     uses = {0, 3},
-- --                 },
-- --                 {
-- --                     name = "Knife",
-- --                 },
-- --                 {
-- --                     name = "Purse of Coins",
-- --                 },
-- --                 {
-- --                     name = "Weapon Maintenance Tools",
-- --                 },
-- --             },
-- --         }
-- --     },
-- --     ["Boschdun"] = {
-- --         class = "Barbarian",
-- --         player_id = "282385029387124736",
-- --         stats = {
-- --             str = 1,
-- --             dex = 0,
-- --             con = 2,
-- --             int = -1,
-- --             wis = 0,
-- --             cha = 1,
-- --         },
-- --         damage_die = "d10",
-- --         hp = {20, 20},
-- --         xp = 5,
-- --         reaction = "🥫",

-- --         drive = {
-- --             "Gigantic Mirth:",
-- --             "Cause trouble by over-induling."
-- --         },
-- --         background = {
-- --             name = "From a Grim and Darksome Dungeon",
-- --             moves = {
-- --                 "When you ***Defy Danger or Struggle as One to surmount a physical obstacle***, you have advantage.",
-- --                 "When you ***Venture Forth through difficult or perilous terrain***, tell us how you negate or easily overcome one consequence of the journey.",
-- --                 "When ***the party Makes Camp in the wild***, you can roll +INT: On a 10+, you fashion or forage 1d4 uses of Supplies; on a 7-9, you fashion or forage 1d4 uses of Supplies but some sort of trouble follows you back to camp.",
-- --             },
-- --         },

-- --         gear = {
-- --             max_load = 5,
-- --             inventory = {
-- --                 {
-- --                     name = "Flail",
-- --                     weight = 1,
-- --                     mods = {
-- --                         damage = 1,
-- --                     },
-- --                 },
-- --                 {
-- --                     name = "Thick Hides",
-- --                     weight = 1,
-- --                     mods = {
-- --                         armor = 1,
-- --                     },
-- --                 },
-- --                 {
-- --                     name = "Shield",
-- --                     weight = 2,
-- --                     tags = {"+1 Readiness when you roll Defend 7+"},
-- --                     mods = {
-- --                         armor = 1,
-- --                     }
-- --                 },
-- --                 {
-- --                     name = "Supplies",
-- --                     weight = 1,
-- --                     uses = {1, 3},
-- --                 },
-- --                 {
-- --                     name = "Jar of Spices",
-- --                 },
-- --                 {
-- --                     name = "Carving Knife"
-- --                 },
-- --                 {
-- --                     name = "Skin of Fine Bourbon"
-- --                 },
-- --             }
-- --         }
-- --     },
-- --     ["Carpkin"] = {
-- --         class = "Thief",
-- --         player_id = "694140429708427354",
-- --         stats = {
-- --             str = 1,
-- --             dex = 1,
-- --             con = 0,
-- --             int = 2,
-- --             wis = -1,
-- --             cha = 0,
-- --         },
-- --         hp = {16, 16},
-- --         xp = 3,
-- --         reaction = "🐸",

-- --         damage_die = "d8",

-- --         drive = {
-- --             "Conscience:",
-- --             "Forego comfort or advantage to do the right thing.",
-- --         },

-- --         gear = {
-- --             max_load = 3,
-- --             inventory = {
-- --                 {
-- --                     name = "Supplies",
-- --                     weight = 2,
-- --                     uses = {4, 6},
-- --                 },
-- --                 {
-- --                     name = "Cudgel",
-- --                     weight = 1,
-- --                 },
-- --                 {
-- --                     name = "Normal Spoon",
-- --                 },
-- --                 {
-- --                     name = "Dagger",
-- --                 },
-- --                 {
-- --                     name = "Thief's Tools"
-- --                 }
-- --             }
-- --         }
-- --     }
-- -- }

-- ---@class gear_obj
-- local gear_obj = {
--     name = "",
--     ---@type number
--     weight = 0,
--     ---@type table
--     uses = {0, 0},
--     tags = {"text"},

--     ---@type table<string, number>
--     mods = {},
-- }


-- ---@class char_obj
-- local char_obj = {
--     __ = {},
--     name = "",
--     class = "",
--     xp = 0,
--     hp = {0, 0},
--     damage_die = "",
--     stats = {
--         str = 0,
--         dex = 0,
--         con = 0,
--         int = 0,
--         wis = 0,
--         cha = 0,
--     },

--     background = {
--         name = "",
--         moves = {}
--     },

--     drive = {},

--     reaction = "",

--     player_id = "",

--     gear = {
--         ---@type number
--         max_load = 0,

--         ---@type gear_obj[]
--         inventory = {},
--     },

--     available_moves = {},
-- }

-- local char_obj_setters = {
--     modify_hp = true,
--     modify_xp = true,
-- }

-- local char_obj_mt = {
--     __index = function(self, k)
--         if char_obj_setters[k] then
--             -- Save in a bit!
--             TIMER.setTimeout(100, save)
--         end

--         return rawget(self,k) or char_obj[k]
--     end,
--     -- __newindex = function(self, k)

--     -- end,
--     __tostring = function(self)
--         return "Character: ["..self.name.."]"
--     end,
-- }

-- ---comment
-- ---@param channel GuildTextChannel
-- ---@param user_id string
-- function char_obj:start_display(channel, user_id)
--     local prompt = PM.new("char_display_"..self.name, channel)

--     self.__.prompt = prompt
--     self.__.page = ""

--     prompt:set_fields_per_page(12)

--     prompt:set_reactions({
--         {
--             "🏠",
--             function(nav, user_id)
--                 if self.__.page ~= "main" then
--                     self:set_main_page()
--                     self.__.page = "main"
--                 end
--             end,
--         },
--         {
--             "🎒",
--             function(nav, user_id)
--                 if self.__.page ~= "inv" then
--                     self:set_inventory_page()
--                     self.__.page = "inv"
--                 end
--             end,
--         },
--         {
--             "💪",
--             function(nav, user_id)
--                 if self.__.page ~= "moves" then
--                     self:set_moves_page()
--                     self.__.page = "moves"
--                 end
--             end,
--         },
--         {
--             "🩸",
--             function(nav, user_id)
--                 if user_id == VANDY then
--                     self:start_hp_query()
--                 end
--             end,
--         },
--         {
--             "🏅",
--             function(nav, user_id)
--                 if user_id == VANDY then
--                     self:start_xp_query()
--                 end
--             end,
--         },
--     })

--     prompt:set_user(user_id)

--     prompt:add_query({
--         key = "hp",
--         question = "How much HP should be added/subtracted?",
--         ---@param msg Message
--         response = function(msg)
--             local content = msg.content
--             local num = tonumber(content:match("[+-]?%d+"))

--             if not is_number(num) then
--                 return "You have to provide a number!"
--             end

--             self:modify_hp(num)
--             self.__.query = nil

--             prompt:refresh_embed()

--             return true, nil, true
--         end,
--     })

--     prompt:add_query({
--         key = "xp",
--         question = "How much XP should be added/subtracted?",
--         ---@param msg Message
--         response = function(msg)
--             local content = msg.content
--             local num = tonumber(content:match("[+-]?%d+"))

--             if not is_number(num) then
--                 return "You have to provide a number!"
--             end

--             self:modify_xp(num)
--             self.__.query = nil

--             prompt:refresh_embed()

--             return true, nil, true
--         end,
--     })

--     self:set_main_page()

--     prompt:start()
-- end

-- function char_obj:start_hp_query()
--     self.__.query = "hp"
--     local prompt = self.__.prompt

--     prompt:trigger_query("hp")
-- end

-- function char_obj:start_xp_query()
--     self.__.query = "xp"
--     local prompt = self.__.prompt

--     prompt:trigger_query("xp")
-- end

-- local function f_stat(s)
--     if s > 0 then
--         return "+"..tostring(s)
--     end

--     return tostring(s)
-- end

-- function char_obj:get_load()
--     local max_load = self.gear.max_load
--     local inv = self:get_inv()

--     local current_load = 0

--     for i,item in ipairs(inv) do
--         if item.weight then
--             current_load = current_load + item.weight
--         end
--     end

--     return string.format("%d / %d", current_load, max_load)
-- end

-- function char_obj:get_stats()
--     local stats = self.stats
--     local a,b,c,d,e,f = stats.str, stats.dex, stats.con, stats.int, stats.wis, stats.cha

--     return f_stat(a), f_stat(b), f_stat(c), f_stat(d), f_stat(e), f_stat(f)
-- end

-- function char_obj:get_current_hp()
--     return self.hp[1]
-- end

-- function char_obj:get_max_hp()
--     return self.hp[2]
-- end

-- function char_obj:modify_hp(mod)
--     if not is_number(mod) then return end

--     local new_hp = self:get_current_hp() + mod
--     if new_hp > self:get_max_hp() then
--         new_hp = self:get_max_hp()
--     elseif new_hp <= 0 then
--         new_hp = 0
--         -- TODO message about "you're down"
--     end

--     self.hp[1] = new_hp
-- end

-- function char_obj:modify_xp(mod)
--     if not is_number(mod) then return end

--     local new = self.xp + mod

--     if new < 0 then
--         new = 0
--     elseif new >= 5 then
--         -- TODO message about "you can get an advancement!"
--     end

--     self.xp = new
-- end

-- function char_obj:format_health_points()
--     return string.format("%d / %d", self.hp[1], self.hp[2])
-- end

-- function char_obj:get_inv()
--     return self.gear.inventory
-- end

-- function char_obj:get_armor()
--     local armor = 0

--     local inv = self:get_inv()

--     for i,item in ipairs(inv) do
--         if item.mods and item.mods.armor then
--             armor = armor + item.mods.armor
--         end
--     end

--     return armor
-- end

-- function char_obj:format_armor()
--     -- TODO calculate current armor from gear and moves!
--     return string.format("%d", self:get_armor())
-- end

-- function char_obj:get_damage()
--     local damage = 0

--     local inv = self:get_inv()

--     for i,item in ipairs(inv) do
--         if item.mods and item.mods.damage then
--             damage = damage + item.mods.damage
--         end
--     end

--     local damage_die = self.damage_die

--     if damage ~= 0 then
--         damage_die = damage_die .. string.format("%s%d", damage>0 and "+" or "", damage)
--     end

--     return damage_die
-- end

-- function char_obj:format_damage()
--     -- TODO calculate w/ gear and class default!
--     return string.format("%s", self:get_damage())
-- end

-- function char_obj:format_xp()
--     return string.format("%d", self.xp)
-- end

-- function char_obj:set_moves_page()
--     local prompt = self.__.prompt

--     prompt:set_title("Moves Page")

--     -- TODO navigate between moves without leaving the moves page (keeping Drives and Background at the top)
--     prompt:set_fields({
--         {
--             name = string.format("Drive: %s", self.drive[1]),
--             value = self.drive[2],
--             inline = true,
--         },
--         {
--             name = string.format("Background: %s", self.background.name),
--             value = "TODO",
--             inline = true,
--         },
--         -- {
--         --     name 
--         -- }
--     })

--     prompt:refresh_embed()
-- end

-- function char_obj:get_inv_as_fields()
--     local fields = {
--         {
--             name = "Load",
--             value = self:get_load(),
--             inline = false,
--         }
--     }
--     local inv = self:get_inv()

--     local small_items = {}

--     --- TODO add all "small items" to a single field here, name = "Small Items" value = table.concat(remaining_items, ", ")
--     for i,item in ipairs(inv) do
--         local item_str = string.format(
--             "%s%s%s%s%s",
--             item.weight and "Weight: " .. item.weight .. "\n" or "",
--             item.uses and "Uses: " .. tostring(item.uses[1]).."/"..tostring(item.uses[2]).."\n" or "",
--             item.tags and "Tags: " .. table.concat(item.tags, ", ") .. "\n" or "",
--             item.mods and item.mods.armor and "Armor: +" .. item.mods.armor .. "\n" or "",
--             item.mods and item.mods.damage and "Damage: +" .. item.mods.damage .. "\n" or ""
--         )

--         if item_str == "" then
--             small_items[#small_items+1] = item.name
--         else
--             fields[#fields+1] = {
--                 name = item.name,
--                 value = item_str,
--                 inline = true,
--             }
--         end
--     end

--     if #small_items > 0 then
--         fields[#fields+1] = {
--             name = "Small Items",
--             value = table.concat(small_items, "\n"),
--             inline = false,
--         }
--     end

--     return fields
-- end

-- function char_obj:set_inventory_page()
--     local prompt = self.__.prompt

--     prompt:set_title("Inventory Page")
--     prompt:set_fields(self:get_inv_as_fields())
--     -- prompt:set_default_reactions()

--     prompt:refresh_embed()
-- end

-- function char_obj:set_main_page()
--     local prompt = self.__.prompt

--     prompt:set_title("Main Page")

--     local desc = string.format("**%s**\n%s of %s", self.name, is_string(self.class) and self.class or "No Class Found", "<@"..self.player_id..">")

--     prompt:set_description(desc)
--     prompt:set_footer()

--     local a,b,c,d,e,f = self:get_stats()

--     prompt:set_fields({
--         {
--             name = "Health Points",
--             value = self:format_health_points(),
--             inline = true,
--         },
--         {
--             name = "Armor",
--             value = self:format_armor(),
--             inline = true,
--         },
--         {
--             name = "Damage Die",
--             value = self:format_damage(),
--             inline = true,
--         },
--         {
--             name = "Current XP",
--             value = self:format_xp(),
--             inline = false,
--         },
--         {
--             name = "Strength",
--             value = a,
--             inline = true,
--         },
--         {
--             name = "Dexterity",
--             value = b,
--             inline = true,
--         },
--         {
--             name = "Constitution",
--             value = c,
--             inline = true,
--         },
--         {
--             name = "Intelligence",
--             value = d,
--             inline = true,
--         },
--         {
--             name = "Wisdom",
--             value = e,
--             inline = true,
--         },
--         {
--             name = "Charisma",
--             value = f,
--             inline = true,
--         }
--     })

--     prompt:refresh_embed()
-- end

-- function char_obj:new(o)
--     o = o or {}
--     setmetatable(o, char_obj_mt)

--     return o
-- end

-- local gear_obj = {}
-- local class_obj = {}
-- local move_obj = {}

-- ---@param char_key string
-- ---@return char_obj
-- local function get_char(char_key)
--     if not is_string(char_key) then return end

--     local char = saved_data.game.chars[char_key]

--     if not char then
--         -- search!
--         for k,v in pairs(saved_data.game.chars) do
--             if k:find(char_key) then
--                 char = v
--             end
--         end
--     end

--     return char
-- end


-- local function display_all_chars(channel)
--     local prompt = PM.new("display_all_chars", channel)

--     prompt:set_title("All Characters")
--     prompt:set_description("Select the reaction below to view that character.")
    
--     prompt:start()
-- end

-- local char_command = CM:new_command(
--     "char_command",
--     ---@param msg Message
--     ---@param args table<number, string>
--     function(msg, args)
--         local channel = msg.channel
--         local char_key = args.char_key

--         if char_key == "all" then
--             return display_all_chars(channel)
--         end

--         local char = get_char(char_key)
--         if char then
--             char:start_display(channel, msg.author.id)
--         end

--         -- display_char(char_key, channel)
--     end
-- )
-- char_command:set_trigger("message", "char")
-- char_command:set_argument_parser(
--     function (message, args)
--         print("parsing args")
--         local char_str = table.concat(args, " ")
--         print(char_str)

--         if char_str == "" then
--             char_str = "all"
--         end

--         return {
--             char_key = char_str,
--         }
--     end
-- )

-- -- TODO hook in +/-XP +/-HP commands

-- --- TODO if no move provided, display all moves in a prompt
-- local move_command = CM:new_command(
--     "move_command",
--     ---@param msg Message
--     ---@param args string[]
--     function(msg, args)
--         print("In callback")
--         local key = args.move_key
--         local move = args.move

--         printf("%s and %s", key, move)

--         if key == "all" then
--             -- TODO do a prompt w/ all moves!
--             return
--         end

--         msg.channel:send({embed = 
--             {
--                 title = tostring(key),
--                 description = tostring(move),
--             }
--         })
--     end
-- )
-- move_command:set_trigger("message", "move")
-- move_command:set_argument_parser(
--     function (message, args)
--         print("parsing args")
--         local move_str = table.concat(args, " ")
--         print(move_str)
--         local move = moves[move_str]
--         print(move)

--         if move_str == "" then
--             move_str = "all"
--         end

--         return {
--             move_key = move_str,
--             move = move
--         }
--     end
-- )

-- -- TODO load from saved data!
-- -- TODO save to saved data!
-- local function init()
--     for k,v in pairs(saved_data.game.chars) do
--         v.name = k
--         saved_data.game.chars[k] = char_obj:new(v)
--         -- printf("Creating new char obj w/ key %s", k)
--     end

--     save()
-- end

-- init()