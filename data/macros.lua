return {
	["_TAGS"] = {
		["pasta"] = {
			["name"] = [=[pasta]=],
			["description"] = [=[add souce]=],
		},
		["scripting"] = {
			["name"] = [=[scripting]=],
			["description"] = [=[Of all things Lua-related]=],
		},
		["troubleshooting"] = {
			["name"] = [=[troubleshooting]=],
			["description"] = [=[Troubleshooting macros, for users trying to get their mod lists functional.]=],
		},
		["Modding"] = {
			["name"] = [=[Modding]=],
			["description"] = [=[General modding help, tips, and tricks.]=],
		},
		["modding tools"] = {
			["name"] = [=[modding tools]=],
			["description"] = [=[Macros of or relating to the tools used for modding.]=],
		},
		["To-Do"] = {
			["name"] = [=[To-Do]=],
			["description"] = [=[These macros have been created but not filled out, someone must fill them out!]=],
		},
	},
	["_MACROS"] = {
		["Steam Down?"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 49,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 12,
			["name"] = [=[Steam Down?]=],
			["creation_time"] = 0,
			["field"] = [=[**Q: Is Steam down or buggy or slow or weird for anyone else?**
**A:** https://tenor.com/view/yes-nod-yeah-agree-ross-geller-gif-16617477]=],
		},
		["nurgle recruitment"] = {
			["tags"] = {
			},
			["ticket_num"] = 78,
			["user"] = [=[331428721556848641]=],
			["num_uses"] = 14,
			["name"] = [=[nurgle recruitment]=],
			["creation_time"] = 0,
			["field"] = [=[How to add custom units to nurgle's recruitment pool:
1. add your units to mercenary_pool_to_groups_junctions_tables and mercenary_unit_groups_tables
2. add your units to wh3_main_nur_recruitment_pool unit set
3. add your units to merc pool with cm:add_unit_to_faction_mercenary_pool

This will only add the unit to their recruitment pool. Making it work exactly like vanilla units may or may not be possible entirely.
Example script: https://cdn.discordapp.com/attachments/466624302897430530/964174358153150514/nurgle_pool.lua]=],
		},
		["Script Folder"] = {
			["tags"] = {
				["scripting"] = true,
			},
			["ticket_num"] = 2,
			["user"] = [=[]=],
			["num_uses"] = 15,
			["name"] = [=[Script Folder]=],
			["creation_time"] = 0,
			["field"] = [=[When writing up a new script in your mod, there's a few options for where to put it.

If you're making a script for the campaign, use the following directories:
- `?.pack/script/campaign/mod/?.lua` - loaded in every campaign
- `?.pack/script/campaign/main_warhammer/mod/?.lua` - loaded in Mortal Empires, WH2
- `?.pack/script/campaign/wh2_main_great_vortex/mod/?.lua` - loaded in Eye of Vortex, WH2
- `?.pack/script/campaign/wh3_main_combi/mod/?.lua` - loaded in Immortal Empires, WH3
- `?.pack/script/campaign/wh3_main_chaos/mod/?.lua` - loaded in Realms of Chaos, WH3
- `?.pack/script/campaign/wh3_main_prologue/mod/?.lua` - loaded in Yuri's Prologue, WH3

If you wish to load the script in just battle, just the frontend (main menu + faction selection, or in all three game modes, use the following three respectively:
- `?.pack/script/battle/mod/?.lua`
- `?.pack/script/frontend/mod/?.lua`
- `?.pack/script/_lib/mod/?.lua`

Note that _lib is loaded before any other directory, so it's a great place for API-style global scripts!

If you want to ensure your campaign- or battle- or frontend-specific .lua script is loaded before others (when writing a mod that will act as a dependency), you can place it in the /_lib/mod/ folder, but at the top put `if not core:is_campaign() then return end` (or change it to whatever version therein you need) to prevent your script from being loaded when you don't want it.]=],
		},
		["no"] = {
			["tags"] = {
			},
			["ticket_num"] = 86,
			["user"] = [=[659939703507779587]=],
			["num_uses"] = 6,
			["name"] = [=[no]=],
			["creation_time"] = 0,
			["field"] = [=[https://media.discordapp.net/attachments/588478080692256789/1042504280369790996/grumpy-cat-no.jpg]=],
		},
		["that's a script break"] = {
			["tags"] = {
				["scripting"] = true,
				["troubleshooting"] = true,
			},
			["ticket_num"] = 4,
			["user"] = [=[]=],
			["num_uses"] = 14,
			["name"] = [=[that's a script break]=],
			["creation_time"] = 0,
			["field"] = [=[https://cdn.discordapp.com/attachments/466624302897430530/725382980356407416/scriptbreak.png]=],
		},
		["Download Bugged"] = {
			["tags"] = {
			},
			["ticket_num"] = 48,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 4,
			["name"] = [=[Download Bugged]=],
			["creation_time"] = 0,
			["field"] = [=[Are you having trouble with a Total War download on Steam freezing at the middle or refreshing the same time or something like that?

I have the cure for you!




**__DON'T TOUCH IT.__**


Because of how the game is downloaded (the entire game with all of its packed files is downloaded to disk, and then copied over to the existing installation) the metrics on Steam's download reporter get confused. Don't do anything.

🙂]=],
		},
		["RTFM"] = {
			["tags"] = {
			},
			["ticket_num"] = 36,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 5,
			["name"] = [=[RTFM]=],
			["creation_time"] = 0,
			["field"] = [=[https://media.discordapp.net/attachments/810247445333540894/865281502875090994/keep-calm-and-read-the-fucking-manual-2.png]=],
		},
		["Crashing Down!"] = {
			["tags"] = {
			},
			["ticket_num"] = 54,
			["user"] = [=[]=],
			["num_uses"] = 11,
			["name"] = [=[Crashing Down!]=],
			["creation_time"] = 0,
			["field"] = [=[If a Tool crashed and the author asked for logs, you can find its logs here:
- The forest
  - They're as raw as you can get them.
- RPFM
  - Open it again, go to "Game Selected/Open MyMod Config Folder", then check the "rpfm.log" file for regular usage log, and under the error folder for Crash Logs.
- Asset Editor
  - Options=>Open AssetEditor Folder. Then go to the logs folder and sort by date and send the newest file.
- KMM
  - TBC by its author.
- QtRME / Old RME
  - TBC by its author.]=],
		},
		["Breadcrumb"] = {
			["tags"] = {
				["modding"] = true,
				["Modding"] = true,
			},
			["ticket_num"] = 31,
			["user"] = [=[]=],
			["num_uses"] = 92,
			["name"] = [=[Breadcrumb]=],
			["creation_time"] = 0,
			["field"] = [=[If you're looking for something in the game, and you don't know what the actual in-game code for it is, or where the database entries related to it might be, start with the following method:

- Find the thing you're looking for in-game. If you're trying to find the effects of an item to edit in-data, open that item in game. If it's some mission, get that mission opened up.
- Global search in RPFM the main text for said thing. It might be the item's name, or the mission text, running on the same example.
- To do this in RPFM, View -> Toggle Global Search Window, and make sure Search Source is on Game Files (or leave it on Packfile if you're rummaging in a mod you opened). When searching in Game Files for something that isn't a script, disable Text and Schemas to make it faster.
- After finding the localised text, you can use RPFM's "Go To Key" shortcut, or global search the actual key to your heart's content in the game's content.

Example: the name "Chaosblade of Doom" will potentially direct you to ancillaries_tables, linked to some key, and you can search out from there to linked tables - ancillary_to_effects - to find out how to edit specific parts of that item, or how to make new ones!]=],
		},
		["TIAS"] = {
			["tags"] = {
			},
			["ticket_num"] = 23,
			["user"] = [=[]=],
			["num_uses"] = 69,
			["name"] = [=[TIAS]=],
			["creation_time"] = 0,
			["field"] = [=[https://cdn.discordapp.com/attachments/531219831861805069/819373285828460594/tias_thumb.jpg]=],
		},
		["engine"] = {
			["tags"] = {
			},
			["ticket_num"] = 72,
			["user"] = [=[164896718750613507]=],
			["num_uses"] = 4,
			["name"] = [=[engine]=],
			["creation_time"] = 0,
			["field"] = [=[Total War currently runs on the Total War Engine 3, also known as TWE3. Warscape is the name of the rendering/modeling engine.]=],
		},
		["Data Coring"] = {
			["tags"] = {
				["Modding"] = true,
			},
			["ticket_num"] = 8,
			["user"] = [=[]=],
			["num_uses"] = 20,
			["name"] = [=[Data Coring]=],
			["creation_time"] = 0,
			["field"] = [=[Data coring is the act of inputting data files in your mod with the same name as the CA data files - thus completely overwriting them. For example, in WH2 having your db files named "data__" - same as the vanilla data.pack. It is typically used to remove vanilla data from a table.

**It should be avoided at all costs.**

Data coring will cause a few significant issues for you, including:
- Incompatibility issues with other mods that edit that table or reference CA data- Hard crashes with other mods that data core that table
- A lot of pain when you have to update your data after a new patch, since you have to add in all the new rows CA added while still making the changes you need.

Many tables or data structures can be disabled in more ways than one - there's no sure guide to avoiding data coring, but it's a good practice to avoid it unless absolutely necessary.]=],
		},
		["Movie Pack"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 10,
			["user"] = [=[]=],
			["num_uses"] = 48,
			["name"] = [=[Movie Pack]=],
			["creation_time"] = 0,
			["field"] = [=[**Movie-type pack files**

Some mods come distributed as a "Movie"-type pack file, which is necessary for certain vfx changes\*. Some goobers use them for database too, which can be harmful because when Movie packs are in the /data/ folder of that game, they are *always* enabled, regardless of your input. You may want to unsubscribe from them when you're not using them, and delete them from /data/.

They are invisible in the vanilla mod launcher. With either Kaedrin's (pre-WH3) or PropJoe's (WH3) Mod Managers they are signalled and easy to remove with a right click on them (Unsub&Delete).

\*In WH3 (and maybe onwards), movie-type pack files no longer are required for VFX changes.]=],
		},
		["dependencies"] = {
			["tags"] = {
			},
			["ticket_num"] = 84,
			["user"] = [=[234019992197136384]=],
			["num_uses"] = 7,
			["name"] = [=[dependencies]=],
			["creation_time"] = 0,
			["field"] = [=[https://cdn.discordapp.com/attachments/1009136110754074624/1030507555417493504/6d76w6.png]=],
		},
		["EmpsLactase"] = {
			["tags"] = {
			},
			["ticket_num"] = 52,
			["user"] = [=[265581973085356032]=],
			["num_uses"] = 6,
			["name"] = [=[EmpsLactase]=],
			["creation_time"] = 0,
			["field"] = [=[Theory is that the Emperor of Mankind, being born around 8000BC, around 4000 years before humans started to being able to produce the lactase enzyme as adults, can't properly digest dairy without blowing some massive stinkers]=],
		},
		["Sound Editing"] = {
			["tags"] = {
			},
			["ticket_num"] = 14,
			["user"] = [=[]=],
			["num_uses"] = 24,
			["name"] = [=[Sound Editing]=],
			["creation_time"] = 0,
			["field"] = [=[CA uses a pretty complicated sound system called WWise. The sound system in the game appears to be (almost) 100% data driven which is great news and  means we can do pretty much what ever we want. The bad news is that WWise is very complicated and there is currently no tooling support. There is about 150k sound files, all names something like 726472848.wem. That name is the hash of the sound name, which is not very useful. Wwise in its simplest form works by triggering an event which then triggers a sound. You can find a event name to sound ID map here (not all sounds are present, but they will all be added at some point) https://discord.com/channels/373745291289034763/795235087352201226/889975938434089020

Replacing the sounds is easy, but its also possible to add new sounds and custom dialog trees, but that is a lot of work. The sounds can also be hooked into the game variables, such as increasing volume if a battle is going badly. While replacing is easy, adding new sounds are pretty complicated. If you are pretty technical and actually and want to go that road, leave a comment in the asset_editor  channel and someone might be able to answer questions. There is also quite a bit of code related to Wwise for Warhammer and Attila in the AssetEditor which is open source. So short status is this: **We can do pretty much what we want, but its complicated and there is close to no tooling for it.**]=],
		},
		["RPFM Diagnostics Tool"] = {
			["tags"] = {
			},
			["ticket_num"] = 15,
			["user"] = [=[]=],
			["num_uses"] = 8,
			["name"] = [=[RPFM Diagnostics Tool]=],
			["creation_time"] = 0,
			["field"] = [=[In RPFM, go to View>Toggle Diagnostics Window if disabled. Make it check the file or just the packedfiles (tables) you have opened right now if you know where you've been working and you know the rest would be false positives. It will light up most possible fatal errors with your mod like missing keys. You're on your own on some things like blank cells that shouldn't be blank (TBD), so just take care not making shit up as you go, always start from a working base rather than from a blank line.]=],
		},
		["ReDownload"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 43,
			["user"] = [=[344855662083309578]=],
			["num_uses"] = 10,
			["name"] = [=[ReDownload]=],
			["creation_time"] = 0,
			["field"] = [=[If you're having trouble with your mods always remember to RE-DOWNLOAD them first and check again.

- You can do this via hitting the unsubscribe button and then subscribing again on your mods workshop page and if you seek to do it on mass you can always make a collection with all your favourites, don't be a lazy <:buttheart:539452477406183443>
- Verifying your steam game install files is also and option.

For more Troubleshooting information hit up https://tw-modding.com/index.php/Troubleshooting

**P.S.** If the mod is outdated and you tell us it doesn't work every one in the room will turn and glare at you menacingly.]=],
		},
		["dx11 launch option"] = {
			["tags"] = {
			},
			["ticket_num"] = 75,
			["user"] = [=[308754289352900608]=],
			["num_uses"] = 7,
			["name"] = [=[dx11 launch option]=],
			["creation_time"] = 0,
			["field"] = [=[the -dx11 launch option causes mods not to work in WH3 after patch 1.1. You'll have to remove it.]=],
		},
		["Generate Dependencies Cache"] = {
			["tags"] = {
				["modding tools"] = true,
				["Modding"] = true,
			},
			["ticket_num"] = 53,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 8,
			["name"] = [=[Generate Dependencies Cache]=],
			["creation_time"] = 0,
			["field"] = [=[If you're getting an error in RPFM saying you need to generate your dependencies cache, follow these simple steps:
1) Install the Assembly Kit for this game, on the same disk as your game (ie. if you installed the game in C:/, install the AK in the same drive)
2) Double click the error in RPFM, or use Special Stuff -> [Game In Question] -> Generate Dependencies Cache3)

Yay reading!]=],
		},
		["readable name"] = {
			["tags"] = {
			},
			["ticket_num"] = 55,
			["user"] = [=[234019992197136384]=],
			["num_uses"] = 18,
			["name"] = [=[readable name]=],
			["creation_time"] = 0,
			["field"] = [=[Please have at least part of your name and/or Discord ID written in latin characters. This excludes cursed font or whatever special characters. This ensures that everybody can actually read and ping your name without effort. We *will* change your name if you don't.]=],
		},
		["Modding in Data Folder"] = {
			["tags"] = {
				["Modding"] = true,
			},
			["ticket_num"] = 17,
			["user"] = [=[]=],
			["num_uses"] = 9,
			["name"] = [=[Modding in Data Folder]=],
			["creation_time"] = 0,
			["field"] = [=[Some buffoons will use the data folder (/data/ within the respective game's steam folder) as a place for storing and actively modding, editing their packs directly within the folder itself.

They are buffoons, and you should not do this.

The /data/ folder is held hostage by a lot of programs - the game, the assembly kit, the pack file managers, launchers. It's a dangerous thing to use as an active modding and holding bay, since stuff can get deleted, corrupted, replaced, with very little control or warning.

A much better method is to use the RPFM MyMod functionality. It allows you to store your mods in a specific folder on your PC, and with a simple shortcut, RPFM will immediately install your current mod pack into the /data/ folder for quick testing.

Since RPFM 2.4 you don't need to use MyMod to install a mod pack. You can install any pack as long as it's not already in the /data/ folder. Just in case you're not interested in that. ||Still, you should use MyMods though. I'll make your life easier.||]=],
		},
		["PingMixu"] = {
			["tags"] = {
			},
			["ticket_num"] = 39,
			["user"] = [=[218447420437037056]=],
			["num_uses"] = 9,
			["name"] = [=[PingMixu]=],
			["creation_time"] = 0,
			["field"] = [=[So, you have pinged Mixu in his own channel. A brave move, but a foolish one. Such a barbaric action was expressly forbidden by Section 1 of the Channel Description. It will not go unpunished.... Know that Mixu will take a day off from modding every time you fail him and yourself so miserably! Know that your plea will go unanswered and that you alone are responsible for the delay of *insert character name here* that Mixu has been working on tirelessly. If only this could have been avoided....]=],
		},
		["lua in discord"] = {
			["tags"] = {
			},
			["ticket_num"] = 47,
			["user"] = [=[]=],
			["num_uses"] = 19,
			["name"] = [=[lua in discord]=],
			["creation_time"] = 0,
			["field"] = [=[When posting a script, make it more readable by scripters by typing it in markdown like this:
\`\`\`lua
-- your Lua code goes here
\`\`\`

Which will look like this:
```lua
-- your Lua code goes here!
```

If your script exceeds the message size, please post the file instead.]=],
		},
		["Botched Download"] = {
			["tags"] = {
			},
			["ticket_num"] = 56,
			["user"] = [=[351546207551619072]=],
			["num_uses"] = 9,
			["name"] = [=[Botched Download]=],
			["creation_time"] = 0,
			["field"] = [=[Since Steam is a perfectly functional program with absolutely no issues whatsoever, sometimes the download just breaks and you need to force a redownload to get your beloved mod to workie.

Unsub and resub does the trick (either in Steam or KMM) ... Unless Steam botches the redownload too. Yep, perfectly functional program with absolutely no issues whatsoever.

For more detailed information, please refer to your handy troubleshooting guide located in the pins and channel description of <#373746233367330827>.]=],
		},
		["Localisation"] = {
			["tags"] = {
				["Modding"] = true,
			},
			["ticket_num"] = 19,
			["user"] = [=[]=],
			["num_uses"] = 33,
			["name"] = [=[Localisation]=],
			["creation_time"] = 0,
			["field"] = [=[**A short tutorial on in-game text!**

Localisation is the process of creating the in-game text for DB objects. This means creating the unit text (ie. "Dreadspears") that shows up within the game's UI (ie. within the unit tooltip).

Localisation is done within *.loc files, located within the directory *.pack/text/. Loc files are loaded from lowest alphanumerical priority (zzzz) to highest alphanumerical priority (!!!!). 

To overwrite existing text in the game, your .loc file has to be a higher priority than the .loc file name you're overriding.Within the .loc file, there's three columns - key, text, and a boolean that DOESN'T MATTER AT ALL. The "key" uses a simple structure - `[table name]_[column name]_[key]`.

In db tables, there will be some columns that don't do anything *within* the DB, and have to be done in .loc. An easy example is, within land_units, there's an "onscreen_name" column that's visible within the Assembly Kit. If you create a new unit with the key "my_awesome_unit", the loc key would be: `land_units_onscreen_name_my_awesome_unit`. The "text" column would be the in-game text you want: "My Awesome Unit!"

Additionally, RPFM can generate missing loc entries for you. Right click on a table in your mod and choose "generate missing locs", a missing_locs file will be generated with each of the keys pre-generated based on the rows in your table. You just need to fill in the values.

https://cdn.discordapp.com/attachments/597937992773926962/929367264518623232/Untitled.png]=],
		},
		["Powershell"] = {
			["tags"] = {
			},
			["ticket_num"] = 114,
			["user"] = [=[]=],
			["num_uses"] = 0,
			["name"] = [=[Powershell]=],
			["creation_time"] = 0,
			["field"] = [=[ Troubleshooting a huge mod list and wondering which pack file(s) contain XXX ? 

You can run the following command in a powershell console - update the path to your workshop folder:
```ps
Get-ChildItem "E:\SteamLibrary\steamapps\workshop\content\1142710" -Filter *.pack -Recurse | Select-String "XXX" | Select-Object -Unique Path
```
You can search for any string - database keys, ingame text, script names. The more unique the string you are looking for the better your chances at finding the pack file(s) you are looking for. Note that it can take a while to run depending on the size of your workshop folder.]=],
		},
		["Use KMM"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 24,
			["user"] = [=[]=],
			["num_uses"] = 10,
			["name"] = [=[Use KMM]=],
			["creation_time"] = 0,
			["field"] = [=[https://media.discordapp.net/attachments/373745291289034765/569917924278796318/USEKMM.jpg?width=500&height=373]=],
		},
		["Star Wars"] = {
			["tags"] = {
			},
			["ticket_num"] = 27,
			["user"] = [=[]=],
			["num_uses"] = 8,
			["name"] = [=[Star Wars]=],
			["creation_time"] = 0,
			["field"] = [=[YOTURNEERAGERNSHTMEE
https://www.reddit.com/r/funny/comments/f1fxkp/my_drunk_friend_sent_me_this_voiced_over_the/?utm_medium=android_app&utm_source=share]=],
		},
		["Bisect"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 29,
			["user"] = [=[]=],
			["num_uses"] = 29,
			["name"] = [=[Bisect]=],
			["creation_time"] = 0,
			["field"] = [=[**Bisecting a Mod List**

Since WH2 doesn't really have any usable mod debugging, one of the quickest ways to find a faulty mod that crashes your game on startup is to:
- Bisect (aka split in half) your mod list
- Does the game still crash?
 - If yes, you know the fault is in the half you still have
 - If not, you know the fault was in the other half
- Go back to step one to bisect further

This method doesn't work super well for problems that occur late into a campaign, nor for problems that occur from running multiple mods together, nor if movie mods are interfering (which TL;DM are always enabled even if you turn them off). Turning off outdated mods is a good start, though.]=],
		},
		["Accuracy"] = {
			["tags"] = {
			},
			["ticket_num"] = 59,
			["user"] = [=[503642040656199692]=],
			["num_uses"] = 6,
			["name"] = [=[Accuracy]=],
			["creation_time"] = 0,
			["field"] = [=[Accuracy is dictated by a few factors, firstly by marksmanship bonus on the projectile and accuracy on the unit - these are added together to get you an overall accuracy stat, the exact effect is too complicated to bother but bigger is more accurate. Spread is the sledgehammer for inaccuracy, and has a huge impact on making things miss (its also used to make multi missiles not all in one place) - use with small doses and caution. Then is missile calibration distance - beyond this range missiles become wildly less accurate. Then you have calibration area, which is the size of area the projectiles are calibrated to, so increasing this makes them less accurate while lower makes them more precise. The terms here are for wh but they exist in all post etw tw but with different names.]=],
		},
		["ask"] = {
			["tags"] = {
			},
			["ticket_num"] = 93,
			["user"] = [=[503642040656199692]=],
			["num_uses"] = 6,
			["name"] = [=[ask]=],
			["creation_time"] = 0,
			["field"] = [=[https://dontasktoask.com/]=],
		},
		["Localisation File Names"] = {
			["tags"] = {
				["Modding"] = true,
			},
			["ticket_num"] = 34,
			["user"] = [=[]=],
			["num_uses"] = 8,
			["name"] = [=[Localisation File Names]=],
			["creation_time"] = 0,
			["field"] = [=[Localisation files (.loc) should be located in the /text/ folder of a .pack file, in any subdirectory, and they can be named anything - by convention, CA loc files take the name of the respective DB file. The name of the file has no real meaning on its own - the game uses the *key* to know what localisation goes where!If overwriting any text, you have to make your .loc file name have a higher alphanumerical priority compared to either the vanilla .loc file, or the modded .loc file from a mod you're overwriting.Otherwise, any file name is valid!]=],
		},
		["IPs"] = {
			["tags"] = {
			},
			["ticket_num"] = 64,
			["user"] = [=[492798861727891466]=],
			["num_uses"] = 12,
			["name"] = [=[IPs]=],
			["creation_time"] = 0,
			["field"] = [=[WHFB, WH40k, and WHAoS are different IPs - anything from the latter two IPs is verboten.
https://media.discordapp.net/attachments/810247445333540894/938734257256398908/CA_IP.png]=],
		},
		["UI Listeners"] = {
			["tags"] = {
			},
			["ticket_num"] = 68,
			["user"] = [=[308754289352900608]=],
			["num_uses"] = 4,
			["name"] = [=[UI Listeners]=],
			["creation_time"] = 0,
			["field"] = [=[When working with the UI through Lua script, you can use UI events to get information about when components are being clicked, hovered, or otherwise used. Some examples of useful UI events are PanelOpenedCampaign, ComponentLClickUp, and ComponentMouseOn.When working with UI listeners:- you can get the name of the associated component from context.string, and the UIC for the associated component with UIComponent(context.component) - Some UI events will not trigger for all components by default. If you wish to enable all UI events for a particular component then you can do so by calling uic:AddScriptEventReporter() on the component.- **UI Events happen only on one computer in multiplayer games**; if you have gameplay consequences as a result of a UI Event then you must use CampaignUI.TriggerCampaignScriptEvent() to initiate the changes on both computers, otherwise your script will desynchronize in multiplayer campaigns.]=],
		},
		["Print Methods"] = {
			["tags"] = {
				["scripting"] = true,
			},
			["ticket_num"] = 1,
			["user"] = [=[]=],
			["num_uses"] = 10,
			["name"] = [=[Print Methods]=],
			["creation_time"] = 0,
			["field"] = [=[If you're scripting and using CA script_interfaces, chances are there might be some undocumented methods available to use. Run the below code to print all of those methods out (replacing the logging call to whatever it is for the game you're modding!)

```lua
local object -- get your object however you do, cm:get_faction("faction key") for a faction script interface, etc.

local mt = getmetatable(object)
for name, value in pairs(mt) do
  if is_function(value) then
    out("Found: "..name.."()")
  elseif name == "__index" then
    for index_name, index_value in pairs(value) do
      if is_function(index_value) then
        out("Found: "..index_name.."() in index!")
      end
    end
  end
end
```]=],
		},
		["Effect Scopes"] = {
			["tags"] = {
				["Modding"] = true,
			},
			["ticket_num"] = 3,
			["user"] = [=[]=],
			["num_uses"] = 10,
			["name"] = [=[Effect Scopes]=],
			["creation_time"] = 0,
			["field"] = [=[Pssssst, hey kid. Hey, you.

**Effect scopes are database-driven.**

You can make new ones.
__You can look at vanilla ones within the database.__]=],
		},
		["Lore"] = {
			["tags"] = {
			},
			["ticket_num"] = 46,
			["user"] = [=[164896718750613507]=],
			["num_uses"] = 17,
			["name"] = [=[Lore]=],
			["creation_time"] = 0,
			["field"] = [=[As a rule of thumb, all material published in whatever form by Games Workshop, its subsidiaries and license holders is considered an acceptable source. The only requirement being that any editor must be able to prove the existence and content of any cited source used. Yes, even that one Black Library book you don't agree with.

This is based on numerous testimony from Games Workshop employees such as Aaron Dembski-Bowden, Gavin Thorpe, George Mann, etc. When it comes to conflicting sources, it is both yes and no on which is the purported "right" source. These stories and adventures are written from the perspective of what can be an unreliable and/or misinformed narrator, fallible to the same problems we have with recounting our own experiences!

Generally, newer literature is seen to be more kosher than older literature, though both still hold validity to an extent. As a good benchmark, Warhammer Fantasy has its foundation upwards from 4th edition, Warhammer 40k has its foundation from 1st edition, and Warhammer Age of Sigmar has its foundation from 1st edition.]=],
		},
		["Embed Limits"] = {
			["tags"] = {
			},
			["ticket_num"] = 41,
			["user"] = [=[]=],
			["num_uses"] = 2,
			["name"] = [=[Embed Limits]=],
			["creation_time"] = 0,
			["field"] = [=[*This is pretty much just for Groove Wizard atm*field amount = 25, title/field name = 256, value = 1024, footer text/description = 2048**Note that the sum of all characters in the embed should be less than or equal to 6000.**]=],
		},
		["portrait guide"] = {
			["tags"] = {
			},
			["ticket_num"] = 63,
			["user"] = [=[331428721556848641]=],
			["num_uses"] = 7,
			["name"] = [=[portrait guide]=],
			["creation_time"] = 0,
			["field"] = [=[https://steamcommunity.com/sharedfiles/filedetails/?id=1194811468]=],
		},
		["Training Levels"] = {
			["tags"] = {
				["Modding"] = true,
			},
			["ticket_num"] = 7,
			["user"] = [=[]=],
			["num_uses"] = 4,
			["name"] = [=[Training Levels]=],
			["creation_time"] = 0,
			["field"] = [=[**Training Levels**

The training level has a subtle effect on when and how units approach the volley behaviour causing slight variances in unit ranged performance that are hard to quantify.Most notable and visible however is that units with higher training levels will decrease or ignore the fatigue morale penalty (-4) which is not intended behaviour in Total Warhammer, especially since training level is mostly disconnected and isn't communicated to the player in game and as such should be set to Trained by default.]=],
		},
		["Other DDS Formats"] = {
			["tags"] = {
			},
			["ticket_num"] = 69,
			["user"] = [=[344855662083309578]=],
			["num_uses"] = 26,
			["name"] = [=[Other DDS Formats]=],
			["creation_time"] = 0,
			["field"] = [=[**Total War: Warhammer 2**

- **CA DDS Formats**
 - Diffuse, Specular are in DXT10, BC1 Unorm sRGB + alpha
 - Gloss_map is in DXT1, Gloss is BC1 Unorm + alpha
 - Mask, Normal are in DXT5, BC3 Unorm + alpha
- **Intel Texture Works v1.0.4 Settings**
 - Diffuse, Specular use Color and BC7 8 bpp Fine (sRGB, DX11++) or Color+Alpha and BC7 8 bpp Fine (sRGB, DX11++)
 - Gloss_map use Color and BC1 4bpp (Linear)
 - Mask, Normal use Color+Alpha and BC1 4bpp (Linear)
- **Paint.Net Settings**
 - Diffuse, Specular use BC1 (sRGB, DX 10+)
 - Gloss_map use BC1 (Linear, DXT1)
 - Mask, Normal use BC3 (Linear, DXT5)
- **GIMP Settings**
 - Diffuse, Specular use BC3 / DXT5 (Does not work well with wsmodel shaders)
 - Gloss_map use BC1 / DXT1
 - Mask, Normal use BC3 / DXT5]=],
		},
		["Ceiling Grom"] = {
			["tags"] = {
			},
			["ticket_num"] = 26,
			["user"] = [=[]=],
			["num_uses"] = 16,
			["name"] = [=[Ceiling Grom]=],
			["creation_time"] = 0,
			["field"] = [=[https://cdn.discordapp.com/attachments/373745291289034765/817446090046570586/grom_ceiling.png]=],
		},
		["Mod Troubleshooting Guide"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 11,
			["user"] = [=[]=],
			["num_uses"] = 25,
			["name"] = [=[Mod Troubleshooting Guide]=],
			["creation_time"] = 0,
			["field"] = [=[Read the mod troubleshooting guide at <https://tw-modding.com/index.php/Troubleshooting>]=],
		},
		["the real macro"] = {
			["tags"] = {
			},
			["ticket_num"] = 58,
			["user"] = [=[351546207551619072]=],
			["num_uses"] = 7,
			["name"] = [=[the real macro]=],
			["creation_time"] = 0,
			["field"] = [=[the real macro would be STOP FUCKING USING COLLECTIONS FROM 2017]=],
		},
		["Upload Mod"] = {
			["tags"] = {
				["modding tools"] = true,
				["Modding"] = true,
			},
			["ticket_num"] = 33,
			["user"] = [=[]=],
			["num_uses"] = 83,
			["name"] = [=[Upload Mod]=],
			["creation_time"] = 0,
			["field"] = [=[In order to upload a mod to Steam, you have to have your finished .pack file, and a display image thumbnail for Steam. The image must be smaller than 1Mb, and it has to be a .png with the same name as your .pack (so you would have mymod.pack and mymod.png), with size about 250 square. 

Put both of the items into your /data/ folder for the game you're modding, and open up the launcher. The mod should show up with the display thumbnail visible! Simply enable the mod in the launcher, press the folder button, and follow the dialogs from there onward to upload your mod and agree to the EULA.]=],
		},
		["Update Schemas"] = {
			["tags"] = {
				["modding tools"] = true,
				["Modding"] = true,
			},
			["ticket_num"] = 13,
			["user"] = [=[]=],
			["num_uses"] = 4,
			["name"] = [=[Update Schemas]=],
			["creation_time"] = 0,
			["field"] = [=[If you get a message within RPFM that looks a lot like the one pictured below, you should update your schemas!

All you have to do within RPFM is make sure the proper game is selected (Game Selected -> Your game), and then update your schemas using About -> Check Update Schemas. After doing so, reboot your instance of RPFM and check again. It should work!
https://cdn.discordapp.com/attachments/526071721472819210/813040183145791518/unknown.png]=],
		},
		["stop"] = {
			["tags"] = {
			},
			["ticket_num"] = 51,
			["user"] = [=[164896718750613507]=],
			["num_uses"] = 15,
			["name"] = [=[stop]=],
			["creation_time"] = 0,
			["field"] = [=[For the love of all that is holy, please refrain from inappropriate questions/comments that arise from the dragon siblings, dragons in general, Morathi, Malekith, Slaanesh's sexuality/gender identity, etcetera. Chances are high that you are not adding anything constructive, the "joke" has been made before, and that no one wants to talk about those things in regards to this fantasy wargame setting. Please grow up.]=],
		},
		["CMF"] = {
			["tags"] = {
			},
			["ticket_num"] = 57,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 3,
			["name"] = [=[CMF]=],
			["creation_time"] = 0,
			["field"] = [=[DELETE COMMUNITY MODDING FRAMEWORK IF YOU HAVE IT ENABLED IT'S LAST BEEN UPDATED LIKE SEVENTY YEARS AGO]=],
		},
		["Tale of the Butt-Heart"] = {
			["tags"] = {
			},
			["ticket_num"] = 16,
			["user"] = [=[]=],
			["num_uses"] = 14,
			["name"] = [=[Tale of the Butt-Heart]=],
			["creation_time"] = 0,
			["field"] = [=[Many moons ago, Lost2Insanity was ~~raging~~ pointing out to CA that the giants in game have some clipping, particularly in their trouserware. Following several crude pictures, a CA employee responded with an early Valentine's Day card, and it has thrived ever since.

https://cdn.discordapp.com/attachments/597937992773926962/837484024334778448/Screenshot_20210429-201800.jpg
https://cdn.discordapp.com/attachments/597937992773926962/837484033192755230/Screenshot_20210429-201811.jpg]=],
		},
		["cathay"] = {
			["tags"] = {
			},
			["ticket_num"] = 79,
			["user"] = [=[164896718750613507]=],
			["num_uses"] = 8,
			["name"] = [=[cathay]=],
			["creation_time"] = 0,
			["field"] = [=[Cathay, both as a location and a sovereign state, has been a footnote for most of this setting's history. Mostly crammed with Ind under the couch cushions of Warhammer Fantasy until the advent of Total War Warhammer 3 as well as The Old World. What both Games Workshop and Creative Assembly have given us in narrative and world building is **neither comprehensive nor exhaustive**, and as a result this macro was triggered because we very likely do not know the answer to your question.]=],
		},
		["Ind"] = {
			["tags"] = {
			},
			["ticket_num"] = 65,
			["user"] = [=[164896718750613507]=],
			["num_uses"] = 10,
			["name"] = [=[Ind]=],
			["creation_time"] = 0,
			["field"] = [=[Andy Hall, writer of Total War Warhammer 1, 2, 3, on the question of potential races such as Ind, Nippon, Amazons, the Moot, etcetera:
"We're never gonna say never because there should always be the opportunity to bring these new races in or new nations, but you know I've seen the road map and these nations aren't on there now. There's no plans to do them in the immediate or even long-term future. We've still go so much to do with Cathay. Honestly the stuff I've seen it'll curl your toes in the best possible way. [...] People are kinda desperately hanging on for one of these other nations. [...] Don't lose any sleep, it's not happening anytime soon. Probably never, I'm afraid. Cathay was a brillant coup for us. Doesn't mean it's gonna be repeated."]=],
		},
		["Open All CA Packs"] = {
			["tags"] = {
			},
			["ticket_num"] = 25,
			["user"] = [=[]=],
			["num_uses"] = 5,
			["name"] = [=[Open All CA Packs]=],
			["creation_time"] = 0,
			["field"] = [=[**Note: Since RPFM v4.x, Open All CA Packs has been fully replaced with the Dependency Manager. Use the Dependencies window and navigate through "Game Files" and "Assembly Kit Files" to access vanilla data!**

A useful tool to check vanilla data and file locations. When in RPFM, you can press PackFile -> "Load all CA PackFiles", or use Ctrl+G (if you haven't changed the shortcut), to open up all CA packfiles for the game selected. This'll allow you to take a look at vanilla files and where they might be.

https://cdn.discordapp.com/attachments/636634459264909322/809864893422370816/unknown.png]=],
		},
		["ulrika"] = {
			["tags"] = {
			},
			["ticket_num"] = 92,
			["user"] = [=[312710717751164929]=],
			["num_uses"] = 12,
			["name"] = [=[ulrika]=],
			["creation_time"] = 0,
			["field"] = [=[SCM Ulrika will still show up in game, there will be options in MCT so you can chose to have two of them in game, to substitute CA's Ulrika for SCM's Ulrika, or have SCM's Ulrika not show up.For each Legendary character that there is a CA's version and a SCM's version these two options will be available in MCT.]=],
		},
		["DDS Formats"] = {
			["tags"] = {
				["Modding"] = true,
			},
			["ticket_num"] = 6,
			["user"] = [=[]=],
			["num_uses"] = 115,
			["name"] = [=[DDS Formats]=],
			["creation_time"] = 0,
			["field"] = [=[**Total War: Warhammer 3** 

- **Paint.Net settings**
 - Base_colour, Material_map use BC1 (sRGB, DX 10+)
 - Mask, Normal use BC3 (Linear, DXT5)
- **Intel Texture Works v1.0.4 settings**
 - Base Colour use Color+Alpha (optional) and BC3 8bpp sRGB DX10+ Linear
 - Material_map use Color and BC1 4bpp (Linear)
 - Mask use Color+Alpha (optional) and BC3 8bpp Linear
 - Normal use Color+Alpha and BC3 8bpp Linear

Remember that you can save Presets. If you're looking for older DDS Formats use `/macro search Other DDS Formats`]=],
		},
		["Script Debugger"] = {
			["tags"] = {
			},
			["ticket_num"] = 9,
			["user"] = [=[]=],
			["num_uses"] = 52,
			["name"] = [=[Script Debugger]=],
			["creation_time"] = 0,
			["field"] = [=[**Lua Script Logging:** 

To enable logging, grab the script log mod listed and enable it within the launcher. This will print out a script log in the game's main folder, which contains any out() and script_error() calls from vanilla or any mods you have enabled.

**Note: This doesn't automatically bug-check your game or mods. The mods NEED to have these logs implemented into their scripts.** To plug in logs into your own scripts, use out() calls through your code to print out relevant information, or to see where code is breaking.

WH3: <https://steamcommunity.com/sharedfiles/filedetails/?id=2789857593> 
WH2: <https://steamcommunity.com/sharedfiles/filedetails/?id=1271877744>]=],
		},
		["Saved Characters Crash"] = {
			["tags"] = {
			},
			["ticket_num"] = 81,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 12,
			["name"] = [=[Saved Characters Crash]=],
			["creation_time"] = 0,
			["field"] = [=[If you're experiencing crashes when opening up the recruitment menu, you probably have modded saved characters that are referencing mods you're not currently using. To fix this, go to your File Explorer, then go to AppData/Roaming/The Creative Assembly/Warhammer3/saved_characters. Highlight everything within, delete it, and you should be good to go!]=],
		},
		["moddata"] = {
			["tags"] = {
			},
			["ticket_num"] = 74,
			["user"] = [=[308754289352900608]=],
			["num_uses"] = 13,
			["name"] = [=[moddata]=],
			["creation_time"] = 0,
			["field"] = [=[If you're having problems with getting mods to load at all in your game, you might have launcher sickness. You can cure launcher sickness by going to /%appdata%/The Creative Assembly/Launcher/ and deleting the moddata.dat file that can be found there. This will force the launcher to rebuild the file on the next launch, which usually fixes most launcher issues.]=],
		},
		["Scripting Events"] = {
			["tags"] = {
				["scripting"] = true,
			},
			["ticket_num"] = 18,
			["user"] = [=[]=],
			["num_uses"] = 15,
			["name"] = [=[Scripting Events]=],
			["creation_time"] = 0,
			["field"] = [=[To get to the scripting documentation about events (to use with listeners) and interfaces (which are passed around through events or other means), use the "Events & Interfaces" link for the relevant game in https://chadvandy.github.io/tw_modding_resources/index.html

The page it'll take you to will list first all of the event names valid for core:add_listener(), and then each event will have a list of valid interfaces that are linked through the "context" of the event, ie. "context:faction()" for "FactionTurnStart".]=],
		},
		["Load Order"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 28,
			["user"] = [=[]=],
			["num_uses"] = 24,
			["name"] = [=[Load Order]=],
			["creation_time"] = 0,
			["field"] = [=[Q: Should I edit the load order?

A: https://tenor.com/view/shaq-dont-dont-do-it-no-nope-gif-4384713]=],
		},
		["troglagob"] = {
			["tags"] = {
			},
			["ticket_num"] = 5,
			["user"] = [=[]=],
			["num_uses"] = 34,
			["name"] = [=[troglagob]=],
			["creation_time"] = 0,
			["field"] = {
				[2] = [=[https://www.youtube.com/watch?v=uPmNlnGNEqw]=],
				[3] = [=[https://www.youtube.com/watch?v=wEpJU3xqeSE]=],
				[4] = [=[https://www.youtube.com/watch?v=_OFN2Uztp34]=],
			},
		},
		["priority"] = {
			["tags"] = {
			},
			["ticket_num"] = 88,
			["user"] = [=[312710717751164929]=],
			["num_uses"] = 16,
			["name"] = [=[priority]=],
			["creation_time"] = 0,
			["field"] = [=[Overwrite priority order ! # $ % & ‘ ( ) + , – ; = @ 0-9 a-z [ ] ^ _ ` { } ~ Where “!” wins over “a”.]=],
		},
		["RPFM"] = {
			["tags"] = {
				["modding tools"] = true,
				["Modding"] = true,
			},
			["ticket_num"] = 12,
			["user"] = [=[]=],
			["num_uses"] = 17,
			["name"] = [=[RPFM]=],
			["creation_time"] = 0,
			["field"] = [=[Rusted Pack File Manager (#rpfm) is a way better tool for creating and editing mods than any other option currently available, and you should:
https://c.tenor.com/LUOHdYdROZQAAAAM/just-do-it-shia-la-beouf.gif]=],
		},
		["Sort Mods by Recently Updated"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 20,
			["user"] = [=[]=],
			["num_uses"] = 7,
			["name"] = [=[Sort Mods by Recently Updated]=],
			["creation_time"] = 0,
			["field"] = [=[Sometimes it's important to see what mod recently updated! To check which have recently updated, go to the Steam Workshop page for WH2: <https://steamcommunity.com/app/594570/workshop/>. When there, on the right you'll see "Your Workshop Files | Your Files". Hover over the latter and switch it to "Subscribed Items". On the page that files, you'll see a list of mods you have subscribed. On the right, it'll say "Subscribed Items | Date Subscribed". Click Date Subscribed, change it to Date Updated, and Steam will sort your mods by the most recently updated!]=],
		},
		["Playing Unmodded"] = {
			["tags"] = {
				["troubleshooting"] = true,
			},
			["ticket_num"] = 42,
			["user"] = [=[351546207551619072]=],
			["num_uses"] = 6,
			["name"] = [=[Playing Unmodded]=],
			["creation_time"] = 0,
			["field"] = [=[If you need to play unmodded WH2 - for instance, to play online multiplayer - it's not just a matter of deticking all mods and hopping on from there. 

1) First, you'll need to actually disable all your mods. This is the easiest bit.
2) Then, you'll need to remove all movie mods out of existence. For more information, see ?macro movie - but, in short, these mods are always enabled regardless of whether you turned them off. You can filter by type in KMM, select all movie mods, and click the Unsub and Delete button.
3) Next, you'll need to tidy up the other mod files hanging around in the data directory (stray .pngs can also cause a "Modded!" warning). Despite all these mods not being enabled, they can sometimes interfere with the finicky process. Again, KMM has a handy Clean Data button for this. Don't click Refresh after it's done, or that'll bring all the mods back.
4), and most importantly, to play pure unmodded you must use the CA launcher.]=],
		},
		["tmb_elf"] = {
			["tags"] = {
			},
			["ticket_num"] = 85,
			["user"] = [=[312710717751164929]=],
			["num_uses"] = 22,
			["name"] = [=[tmb_elf]=],
			["creation_time"] = 0,
			["field"] = {
				[2] = [=[Tomb kings relation with elves: https://imgur.com/a/ep0d69O]=],
				[3] = [=[Tomb kings relation with elves: https://imgur.com/a/UyhYJGA]=],
			},
		},
		["art set"] = {
			["tags"] = {
			},
			["ticket_num"] = 73,
			["user"] = [=[331428721556848641]=],
			["num_uses"] = 7,
			["name"] = [=[art set]=],
			["creation_time"] = 0,
			["field"] = [=[The current placeholder art set in Warhammer 3 belongs to Kostaltyn. You might see this for your custom characters due to:
- Art set has culture/subculture/faction checks in campaign_character_art_sets_tables that prevents it to be used with another culture/subculture/faction.
- Wrong gender in campaign_character_art_sets_tables.Gender is defined in agent culture details table, CA usually has this set to female for their female characters, for some reason.
- ID in campaign_character_arts_tables is already used by another art set, could be vanilla art set or a modded one. ID has to be unique anyway.]=],
		},
		["Scripted Victory Conditions"] = {
			["tags"] = {
				["scripting"] = true,
			},
			["ticket_num"] = 32,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 6,
			["name"] = [=[Scripted Victory Conditions]=],
			["creation_time"] = 0,
			["field"] = [=[Groove Wizard has to write up a proper tutorial for this, but for now you can read an overview at https://discord.com/channels/373745291289034763/419987321585270784/805952675857825795]=],
		},
		["officers"] = {
			["tags"] = {
			},
			["ticket_num"] = 21,
			["user"] = [=[]=],
			["num_uses"] = 17,
			["name"] = [=[officers]=],
			["creation_time"] = 0,
			["field"] = [=[Land Unit Officer types: Officers and Musicians work with some limits. Musicians may not use missile weapons (working cases TBD). Standard Bearers will crash depending on sides, just don't use them. These entities can have their own distinct variants, entities, animations, both weapons. Avoid adding battle entity hp because it causes a multiplicative bug after campaign battles. They will not use missile weapons unless the land unit can. officer related ability usage keys are currently unlikely to work. Keep in mind officers as a whole are legacy code hanging on for dear life and are inherently not supported for WH2 outside of chariot/character stuff.]=],
		},
		["Mod Priority"] = {
			["tags"] = {
			},
			["ticket_num"] = 83,
			["user"] = [=[364410374688342018]=],
			["num_uses"] = 17,
			["name"] = [=[Mod Priority]=],
			["creation_time"] = 0,
			["field"] = [=[There are two parts of priority when it comes to loading mods. Let's start out by saying that **users should never be told to manually edit load order**, modders should really handle all load order and priority on their own end. 

"Priority" means which file gets loaded in what order, and it's determined by default by the name of files. 

The primary form of priority - *pack file priority* - is determined by the actual .pack file names - this is the load order determined in the mod launcher (again, seriously, don't edit). **All this load order determines is which version of a same-named file is loaded.** If two mods both have a file named `text/my_example_text.loc`, the mod with the higher load order will have that version of my_example_text.loc loaded; the other one is completely discarded.

The other type of priority - *individual table priority* - is determined by the name of **individual file names within a .pack**. Individual table priority determines **which version of a key is used within a db or loc file**. If two mods both edit the localised text for `land_units_onscreen_name_my_example_unit`, one of them using a .loc file called `text/db/!my_text.loc`, the other using `text/db/zzz_my_text.loc`, the former will take priority and the localised text set in that mod will be used. **Individual table priority will NEVER be affected by pack file priority**.

Pack file priority works the way it does because the contents of every single loaded .pack file - CA and modded - are loaded into a virtual filesystem, and a filesystem can't have any files that share the same name and path. Individual table priority works the way it does because when the game is loading at the very start (before the intro movie and CA splash screen are triggered) the individual db and loc files are read and turned into memory that the game can access, and higher priority files are overriding previous bits of memory set by lower priority files.]=],
		},
		["spotting and hiding"] = {
			["tags"] = {
			},
			["ticket_num"] = 60,
			["user"] = [=[308754289352900608]=],
			["num_uses"] = 4,
			["name"] = [=[spotting and hiding]=],
			["creation_time"] = 0,
			["field"] = [=[**Spotting and Hiding Values**Maximum spotting range determines what range you can spot a unit with a hiding scalar of 1. Multiply this value by the hiding scalar of an enemy unit to find what range you can see it at.For example, if spotting range is 300, you can see a 0.5 hiding scalar unit at 150 units, and a 2.0 hiding scalar unit at 600 units.Minimum spotting range determines what range you will spot any unit regardless of its hiding scalar or stalk.Scrub and Tree spotting distance determine what range you will spot a unit using the hide in trees or hide in scrub attribute.The values in land units tables are ignored if a spotting and hiding group (spotting_and_hiding_values_tables) is set. (Note: should be accurate at least up to WH2, testing was done in Attila).]=],
		},
		["pasta"] = {
			["tags"] = {
			},
			["ticket_num"] = 82,
			["user"] = [=[]=],
			["num_uses"] = 9,
			["name"] = [=[pasta]=],
			["creation_time"] = 0,
			["field"] = [=[Does your model look like a mess? Some common issues:
1. Mismatching wsmodel and rmv2 file =>. How to verify: Do all lods animate fine inside AssetEditor? If so this is probably the issue. Close AssetEditor and re-generate the wsmodel.
2. Not generating lods => How to verify: Does lod 0 look good in AssetEditor look correct, but the rest looks like spaghetti? If so generate lods and wsmodel.
3. Model has issues in-game and in AssetEditor => You probably forgot to re-rig some meshes. (warnings are there for a reason!)
4. None of the above and everything looks fine in AssetEditor, but nothing looks good in game => Probably incompatible animation set selected in-game]=],
		},
		["hydrate"] = {
			["tags"] = {
			},
			["ticket_num"] = 22,
			["user"] = [=[164896718750613507]=],
			["num_uses"] = 69,
			["name"] = [=[hydrate]=],
			["creation_time"] = 0,
			["field"] = {
				[2] = [=[https://tenor.com/view/guy-in-black-shirt-thirsty-overflow-hexen-so-gif-11884310]=],
				[3] = [=[https://tenor.com/view/sprayed-gif-18364490]=],
				[4] = [=[https://tenor.com/view/water-gif-4502168]=],
				[5] = [=[https://tenor.com/view/adam-sandler-the-waterboy-water-thirsty-sports-gif-5513842]=],
				[6] = [=[https://tenor.com/view/thirsty-drinking-from-faucet-drinking-water-drink-cat-gif-14154055]=],
				[7] = [=[https://tenor.com/view/stay-hydrated-drink-water-water-thirsty-dehydrated-gif-16410896]=],
				[8] = [=[https://tenor.com/view/best-friend-friends-goat-tongue-licking-gif-7682187]=],
			},
		},
		["Script Docs"] = {
			["tags"] = {
				["scripting"] = true,
			},
			["ticket_num"] = 30,
			["user"] = [=[]=],
			["num_uses"] = 31,
			["name"] = [=[Script Docs]=],
			["creation_time"] = 0,
			["field"] = [=[The scripting documentation (located at <https://chadvandy.github.io/tw_modding_resources/index.html>, or within Total War WARHAMMER III/assembly_kit/Documentation/script, if you have the AK downloaded) is auto-generated through game processes, and it might seem a little convoluted to use - so this is a quick tutorial on how to use it!

First step is, at the main page, you'll see three "Game Areas" on the left side. Click on which one you're interested in. 95% chance you're going for Campaign Index, but if you need to do battle scripting the index is available there as well.

In the area index, the right side will change to three main categories:
- **Campaign Topics** is just text about some overviews, it's rare you'll need to use these.
- **Game Code Pages** refers to stuff defined in C++, in the base game code. This is where stuff that really affects the game will be located. Notably, the "Episodic Scripting" page in the Campaign Index is the place that has pretty much every edit-game function, like "spawn army" or "add experience".
- **Script Pages** refers to pure Lua scripts in the vanilla game. It'll basically just tell you how things work - like the Invasion Manager, or whatever Lua-based thing you want to use.

Some important fun facts:
- If you're trying to get to the Model Hierarchy, to find stuff about events/listeners/game interfaces, go to Campaign Index and click "Model Hierarchy" at the top center of the page. Use ?macro Scripting Events to read more about how to use this!
- For campaign functions, check "Campaign Manager" and "Episodic Scripting". If some function is present in both, use the Campaign Manager version.
- You can use the search bar to find some shtuff, like typing in "unit" to find the command "remove_unit_from_character".]=],
		},
		["function() not found, continuing"] = {
			["tags"] = {
				["scripting"] = true,
			},
			["ticket_num"] = 35,
			["user"] = [=[]=],
			["num_uses"] = 4,
			["name"] = [=[function() not found, continuing]=],
			["creation_time"] = 0,
			["field"] = [=[If you're using the CA Script Loader (ie., plopping your stuff into script/campaign/mod/?.lua), and you check the lua_mod_log.txt or script_log_xxx.txt file, it may say something like "Executing Mods ... yourfilename() not found, continuing".

If you've done it right, that's a non-issue. The way the script loader works, it **searches the global environment for any function named the same as your .lua file**. So if you have a script called "mysweetscript.lua", it searches for any function named "mysweetscript()". If it doesn't find anything, it skips it. 

But you shouldn't use this method, since it'll quickly take hostage many default file or function names. If you initialize your script with `cm:add_first_tick_callback()` or through `core:add_listener()`, you're fine, ignore this error message. If you don't - initialize your script that way!]=],
		},
		["local variables"] = {
			["tags"] = {
			},
			["ticket_num"] = 89,
			["user"] = [=[659939703507779587]=],
			["num_uses"] = 3,
			["name"] = [=[local variables]=],
			["creation_time"] = 0,
			["field"] = [=[https://imgur.com/a/byzgD9C]=],
		},
		["help"] = {
			["tags"] = {
			},
			["ticket_num"] = 87,
			["user"] = [=[155800292477239305]=],
			["num_uses"] = 5,
			["name"] = [=[help]=],
			["creation_time"] = 0,
			["field"] = [=[Wrong way around! You need to do ?help macro]=],
		},
		["Disable pings"] = {
			["tags"] = {
			},
			["ticket_num"] = 50,
			["user"] = [=[234019992197136384]=],
			["num_uses"] = 74,
			["name"] = [=[Disable pings]=],
			["creation_time"] = 0,
			["field"] = [=[Please disable pings when quoting and it's not an urgent matter. Many users can be annoyed by unnecessary notifications when all you're doing is referencing a message. No, it can't be disabled by default, blame discord. But if you're on PC, hold shift while clicking the reply button to disable the ping. https://cdn.discordapp.com/attachments/373745291289034765/778933419547295744/unknown.png]=],
		},
		["EULA"] = {
			["tags"] = {
			},
			["ticket_num"] = 90,
			["user"] = [=[312710717751164929]=],
			["num_uses"] = 5,
			["name"] = [=[EULA]=],
			["creation_time"] = 0,
			["field"] = [=[End User License Agreement (EULA) is the contract you sign when putting your mods in the steam workshop. The legal way to publish mods is by using the steam workshop, mod.io, and epic game store. Mods can't use assets from other Intellectual Property(IP) this include other Games Workshop IP like 40k, Age of Sigmar and Old World. Grounds for being deleted from the workshop include mods that are: discriminatory, racist, obscene, libelous, offensive, illegal, defamatory, inappropriate, invasive. You can't use assets from other total war games and import them to total war warhammer, except animations when they make sense in the warhammer world.These restriction doesn't apply to Creative Assembly.You can find the relevant part to modding under MODDING TERMS in <https://store.steampowered.com/eula/364360_eula_0>]=],
		},
	},
	["_ALIAS"] = {
		["script debug"] = [=[Script Debugger]=],
		["butt-heart"] = [=[Tale of the Butt-Heart]=],
		["game pass"] = [=[Game Pass Mods]=],
		["movie mod"] = [=[Movie Pack]=],
		["unlocker"] = [=[WH3 Unlocker]=],
		["script break meme"] = [=[that's a script break]=],
		["script markdown"] = [=[lua in discord]=],
		["audio"] = [=[Sound Editing]=],
		["dependencies cache"] = [=[depend cache]=],
		["user guide"] = [=[Mod Troubleshooting Guide]=],
		["scropt log"] = [=[Script Debugger]=],
		["movie"] = [=[Movie Pack]=],
		["troubl"] = [=[Mod Troubleshooting Guide]=],
		["usekmm"] = [=[Use KMM]=],
		["kmm"] = [=[Use KMM]=],
		["xbox"] = [=[Game Pass Mods]=],
		["<:buttheart:539452477406183443>"] = [=[Tale of the Butt-Heart]=],
		["dds"] = [=[DDS Formats]=],
		["officer"] = [=[officers]=],
		["lua markdown"] = [=[lua in discord]=],
		["canon"] = [=[hierarchy]=],
		["gamepass"] = [=[Game Pass Mods]=],
		["buttheart"] = [=[Tale of the Butt-Heart]=],
		["-dx11"] = [=[dx11 launch option]=],
		["png"] = [=[Upload Mod]=],
		["binary method"] = [=[Bisect]=],
		["steam down detector"] = [=[Steam Down?]=],
		["script logger"] = [=[Script Debugger]=],
		["model hierarchy"] = [=[Scripting Events]=],
		["troubleshoot"] = [=[Mod Troubleshooting Guide]=],
		["diagno tool"] = [=[RPFM Diagnostics Tool]=],
		["loc file names"] = [=[Localisation File Names]=],
		["old dds"] = [=[Other DDS Formats]=],
		["troubleshooting"] = [=[Mod Troubleshooting Guide]=],
		["red"] = [=[ReDownload]=],
		["data__"] = [=[Data Coring]=],
		["upload"] = [=[Upload Mod]=],
		["data core"] = [=[Data Coring]=],
		["steam go brrr"] = [=[Botched Download]=],
		["reeee"] = [=[Disable pings]=],
		["disable ping"] = [=[Disable pings]=],
		["script logs"] = [=[Script Debugger]=],
		["dependency cache"] = [=[depend cache]=],
		["script break"] = [=[that's a script break]=],
		["bop"] = [=[Bop of the Day]=],
		["mod logo"] = [=[Upload Mod]=],
	},
}
