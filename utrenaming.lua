-- stuff copied from the original file required for function
local ffi = require("ffi")
local C = ffi.C
local utf8 = require("utf8")
local config = {
	mainFrameLayer = 5,
	infoFrameLayer = 4,
	contextFrameLayer = 3,

	complexOrderParams = {
		["trade"] = {
			[1] = { id = "trade_location", name = ReadText(1001, 2943), type = "object", inputparams = { class = "sector" }, value = function (data) return next(data) and GetComponentData(data.station, "zoneid") or nil end },
			[2] = { id = "trade_partner", name = ReadText(1001, 23), type = "object", inputparams = { class = "container" }, value = function (data) return data.station end },
			[3] = { id = "trade_ware", name = ReadText(1001, 7104), type = "trade_ware", value = function (data) return next(data) and {data.isbuyoffer, data.ware} or nil end },
			[4] = { id = "trade_amount", name = ReadText(1001, 6521), type = "trade_amount", value = function (data) return {data.desiredamount, data.amount} end },
			data = function (value) return (value and menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") and GetTradeData(value, ConvertStringTo64Bit(tostring(menu.infoSubmenuObject)))) or {} end
		}
	},
	moduletypes = {
		{ type = "moduletypes_production", name = ReadText(1001, 2421) },
		{ type = "moduletypes_build",      name = ReadText(1001, 2439) },
		{ type = "moduletypes_storage",    name = ReadText(1001, 2422) },
		{ type = "moduletypes_habitation", name = ReadText(1001, 2451) },
		{ type = "moduletypes_dock",       name = ReadText(1001, 2452) },
		{ type = "moduletypes_defence",    name = ReadText(1001, 2424) },
		{ type = "moduletypes_other",      name = ReadText(1001, 2453) },
		{ type = "moduletypes_venture",    name = ReadText(1001, 2454) },
	},
	stateKeys = {
		{"mode"},
		{"modeparam"},
		{"lastactivetable"},
		{"focuscomponent", "UniverseID"},
		{"currentsector", "UniverseID"},
		{"orderQueueMode"},
		{"selectedcomponents"},
		{"searchtext"},
		{"selectedorder"},
		{"infoTableMode"},
		{"infoSubmenuObject", "UniverseID"},
	},
	leftBar = {
		{ name = ReadText(1001, 3224),	icon = "mapst_objectlist",			mode = "objectlist" },
		{ name = ReadText(1001, 1000),	icon = "mapst_propertyowned",		mode = "propertyowned" },
		{ spacing = true },
		{ name = ReadText(1001, 3324),	icon = "mapst_mission_offers",		mode = "missionoffer" },
		{ name = ReadText(1001, 3323),	icon = "mapst_mission_accepted",	mode = "mission" },
		{ spacing = true },
		{ name = ReadText(1001, 2427),	icon = "mapst_information",			mode = "info" },
		{ spacing = true },
		{ name = ReadText(1001, 3226),	icon = "mapst_plotmanagement",		mode = "plots" },
		{ spacing = true,																			condition = IsCheatVersion }, -- (cheats only)
		{ name = "Cheats",				icon = "mapst_cheats",				mode = "cheats",		condition = IsCheatVersion }, -- (cheats only)
	},
	rightBar = {
		{ name = ReadText(1001, 3227),	icon = "mapst_filtersystem",		mode = "filter" },
		{ name = ReadText(1001, 9801),	icon = "mapst_legend",				mode = "legend" },
	},
	infoCategories = {
		{ category = "objectinfo",				name = ReadText(1001, 2427),	icon = "mapst_information" },
		{ category = "orderqueue",				name = ReadText(1001, 8360),	icon = "mapst_ao_orderqueue" },
		{ category = "orderqueue_advanced",		name = ReadText(1001, 8361),	icon = "mapst_orderqueue_advanced" },
	},
	layers = {
		{ name = ReadText(1001, 3252),	icon = "mapst_fs_trade",		mode = "layer_trade" },
		{ name = ReadText(1001, 3253),	icon = "mapst_fs_think",		mode = "layer_think" },
		{ name = ReadText(1001, 8329),	icon = "mapst_fs_mining",		mode = "layer_mining" },
		{ name = ReadText(1001, 3254),	icon = "mapst_fs_other",		mode = "layer_other" },
	},
	layersettings = {
		["layer_trade"] = {
			callback = function (value) return C.SetMapRenderTradeOffers(menu.holomap, value) end,
			[1] = {
				caption = ReadText(1001,46),
				info = ReadText(1001,3279),
				overrideText = ReadText(1001,3278),
				type = "dropdownlist",
				id = "trade_wares",
				callback = function (...) return menu.filterTradeWares(...) end,
				listOptions = function (...) return menu.getFilterTradeWaresOptions(...) end,
			},
			[2] = {
				caption = ReadText(1001,1400),
				type = "checkbox",
				callback = function (...) return menu.filterTradeStorage(...) end,
				[1] = {
					id = "trade_storage_container",
					name = ReadText(20205,100),
					info = ReadText(1001,3280),
					param = "container",
				},
				[2] = {
					id = "trade_storage_solid",
					name = ReadText(20205,200),
					info = ReadText(1001,3281),
					param = "solid",
				},
				[3] = {
					id = "trade_storage_liquid",
					name = ReadText(20205,300),
					info = ReadText(1001,3282),
					param = "liquid",
				},
			},
			[3] = {
				caption = ReadText(1001,2808),
				type = "slidercell",
				callback = function (...) return menu.filterTradePrice(...) end,
				[1] = {
					id = "trade_price_maxprice",
					name = ReadText(1001,3284),
					info = ReadText(1001,3283),
					param = "maxprice",
					scale = {
						min       = 0,
						max       = 5000,
						step      = 1,
						suffix    = ReadText(1001, 101),
						exceedmax = true
					}
				},
			},
			[4] = {
				caption = ReadText(1001, 8357),
				type = "dropdown",
				callback = function (...) return menu.filterTradeVolume(...) end,
				[1] = {
					id = "trade_volume",
					info = ReadText(1001, 8358),
					listOptions = function (...) return menu.getFilterTradeVolumeOptions(...) end,
					param = "volume"
				},
			},
			[5] = {
				caption = ReadText(1001, 8343),
				type = "slidercell",
				callback = function (...) return menu.filterTradeOffer(...) end,
				[1] = {
					id = "trade_offer_number",
					name = ReadText(1001, 8344),
					info = ReadText(1001, 8345),
					param = "number",
					scale = {
						min       = 0,
						minSelect = 1,
						max       = 5,
						step      = 1,
						exceedmax = true
					}
				},
			},
		},
		["layer_fight"] = {},
		["layer_think"] = {
			callback = function (value) return menu.filterThink(value) end,
			[1] = {
				caption = ReadText(1001,3285),
				type = "dropdown",
				callback = function (...) return menu.filterThinkAlert(...) end,
				[1] = {
					info = ReadText(1001,3286),
					id = "think_alert",
					listOptions = function (...) return menu.getFilterThinkAlertOptions(...) end,
					param = "alert"
				},
			},
		},
		["layer_build"] = {},
		["layer_diplo"] = {},
		["layer_mining"] = {
			callback = function (value) return menu.filterMining(value) end,
			[1] = {
				caption = ReadText(1001, 8330),
				type = "checkbox",
				callback = function (...) return menu.filterMiningResources(...) end,
				[1] = {
					id = "mining_resource_display",
					name = ReadText(1001, 8331),
					info = ReadText(1001, 8332),
					param = "display"
				},
			},
		},
		["layer_other"] = {
			callback = function (value) return menu.filterOther(value) end,
			[1] = {
				caption = ReadText(1001, 8335),
				type = "checkbox",
				callback = function (...) return menu.filterOtherStation(...) end,
				[1] = {
					id = "other_misc_missions",
					name = ReadText(1001, 3291),
					info = ReadText(1001, 3292),
					param = "missions",
				},
				[2] = {
					id = "other_misc_cargo",
					name = ReadText(1001, 3289),
					info = ReadText(1001, 3290),
					param = "cargo",
				},
				[3] = {
					id = "other_misc_workforce",
					name = ReadText(1001, 3293),
					info = ReadText(1001, 3294),
					param = "workforce",
				},
				[4] = {
					id = "other_misc_dockedships",
					name = ReadText(1001, 3275),
					info = ReadText(1001, 3299),
					param = "dockedships",
				},
				[5] = {
					id = "other_misc_civilian",
					name = ReadText(1001, 8333),
					info = ReadText(1001, 8334),
					param = "civilian",
				},
			},
			[2] = {
				caption = ReadText(1001, 8336),
				type = "checkbox",
				callback = function (...) return menu.filterOtherShip(...) end,
				[1] = {
					id = "other_misc_orderqueue",
					name = ReadText(1001, 3287),
					info = ReadText(1001, 8372),
					param = "orderqueue",
				},
				[2] = {
					id = "other_misc_allyorderqueue",
					name = ReadText(1001, 8370),
					info = ReadText(1001, 8371),
					param = "allyorderqueue",
				},
				[3] = {
					id = "other_misc_crew",
					name = ReadText(1001, 3295),
					info = ReadText(1001, 3296),
					param = "crew",
				},
			},
			[3] = {
				caption = ReadText(1001, 2664),
				type = "checkbox",
				callback = function (...) return menu.filterOtherMisc(...) end,
				[1] = {
					id = "other_misc_ecliptic",
					name = ReadText(1001, 3297),
					info = ReadText(1001, 3298),
					param = "ecliptic",
				},
			},
		}
	},
	mapfilterversion = 11,

	-- custom default row properties, different from Helper defaults
	mapRowHeight = Helper.standardTextHeight,
	mapFontSize = Helper.standardFontSize,
	plotPairedDimension = { posX = "negX", negX = "posX", posY = "negY", negY = "posY", posZ = "negZ", negZ = "posZ" },
	maxPlotSize = 20,

	contextBorder = 5,

	classOrder = {
		["station"]		= 1,
		["ship_xl"]		= 2,
		["ship_l"]		= 3,
		["ship_m"]		= 4,
		["ship_s"]		= 5,
		["ship_xs"]		= 6,
	},
	purposeOrder = {
		["fight"]	= 1,
		["build"]	= 2,
		["mine"]	= 3,
		["trade"]	= 4,
	},

	missionMainTypeOrder = {
		["plot"] = 1,
		["tutorial"] = 2,
		["generic"] = 3,
		["upkeep"] = 4,
		["guidance"] = 5,
	},

	missionOfferCategories = {
		{ category = "guild",	name = ReadText(1001, 3331),	icon = "mapst_mission_guild" },
		{ category = "other",	name = ReadText(1001, 3332),	icon = "mapst_mission_other" },
	},

	missionCategories = {
		{ category = "guild",		name = ReadText(1001, 3333),	icon = "mapst_mission_guild" },
		{ category = "other",		name = ReadText(1001, 3334),	icon = "mapst_mission_other" },
		{ category = "upkeep",		name = ReadText(1001, 3305),	icon = "mapst_mission_upkeep" },
		{ category = "guidance",	name = ReadText(1001, 3329),	icon = "mapst_mission_guidance" },
	},

	autopilotmarker = ">> ",
	softtargetmarker_l = "> ",

	tradeContextMenuWidth = 0.5 * Helper.viewWidth + Helper.scrollbarWidth,

	legend = {
		-- hexes
		{ icon = "maplegend_hexagon_fog_01",		text = ReadText(10002, 606),	width = Helper.sidebarWidth,	height = Helper.sidebarWidth },														-- Unknown location
		{ icon = "maplegend_hexagon_01",			text = ReadText(1001, 9806),	width = Helper.sidebarWidth,	height = Helper.sidebarWidth,	color = { r = 255, g = 0, b = 0, a = 100 } },		-- Mineral Region
		{ icon = "maplegend_hexagon_01",			text = ReadText(1001, 9807),	width = Helper.sidebarWidth,	height = Helper.sidebarWidth,	color = { r = 0, g = 0, b = 255, a = 100 }  },		-- Gas Region
		{ icon = "maplegend_hexagon_01",			text = ReadText(1001, 9812),	width = Helper.sidebarWidth,	height = Helper.sidebarWidth,	color = { r = 255, g = 0, b = 255, a = 100 }  },	-- Mineral/Gas Region
		-- highways, gates, etc
		{ icon = "solid",							text = ReadText(1001, 9809),	width = Helper.sidebarWidth,	height = Helper.standardTextHeight / 2,	minRowHeight = Helper.sidebarWidth / 2 },	-- Jump Gate Connection
		{ icon = "maplegend_hw_01",					text = ReadText(20001, 601),	width = Helper.sidebarWidth,	height = Helper.sidebarWidth / 2,	color = "superhighwaycolor" },					-- Superhighway
		{ icon = "maplegend_hw_01",					text = ReadText(20001, 501),	width = Helper.sidebarWidth,	height = Helper.sidebarWidth / 2,	color = "highwaycolor" },						-- Local Highway
		{ icon = "mapob_jumpgate",					text = ReadText(20001, 701),	color = "gatecolor" },			-- Jump Gate
		{ icon = "mapob_transorbital_accelerator",	text = ReadText(20001, 1001),	color = "gatecolor" },			-- Accelarator
		{ icon = "mapob_superhighway",				text = ReadText(1001, 9810),	color = "highwaygatecolor" },	-- Superhighway Gate
		{ icon = "ship_s_fight_01",					text = ReadText(1001, 5200),	color = "playercolor" },		-- Owned
		{ icon = "ship_s_fight_01",					text = ReadText(1001, 5202),	color = "friendcolor" },		-- Neutral
		{ icon = "ship_s_fight_01",					text = ReadText(1001, 5201),	color = "enemycolor" },			-- Enemy
		-- stations
		{ text = ReadText(1001, 4) },																																					-- Stations
		{ icon = "mapob_playerhq",					text = ReadText(20102, 2011),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "playercolor" },	-- Headquarters
		{ icon = "maplegend_hq_01",					text = ReadText(1001, 9808),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Faction Headquarters
		{ icon = "mapob_shipyard",					text = ReadText(1001, 92),		width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Shipyard
		{ icon = "mapob_wharf",						text = ReadText(1001, 9805),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Wharf
		{ icon = "mapob_equipmentdock",				text = ReadText(1001, 9804),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Equipment Dock
		{ icon = "mapob_tradestation",				text = ReadText(1001, 9803),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Trading Station
		{ icon = "mapob_defensestation",			text = ReadText(1001, 9802),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Defence Platform
		{ icon = "mapob_piratestation",				text = ReadText(20102, 1511),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Free Port
		{ icon = "mapob_factory",					text = ReadText(20102, 1001),	width = 0.8 * Helper.sidebarWidth,	height = 0.8 * Helper.sidebarWidth,	color = "friendcolor" },	-- Factory
		-- xl ships
		{ text = ReadText(1001, 6) .. ReadText(1001, 120) .. " " .. ReadText(20111, 5041) },					-- Ships: XL
		{ icon = "ship_xl_fight_01",				text = ReadText(20221, 2011),	color = "friendcolor" },	-- Fighter
		--{ icon = "ship_xl_trade_01",				text = ReadText(20221, 4011),	color = "friendcolor" },	-- Freighter
		--{ icon = "ship_xl_mine_01",				text = ReadText(20221, 3041),	color = "friendcolor" },	-- Miner
		{ icon = "ship_xl_build_01",				text = ReadText(20221, 5021),	color = "friendcolor" },	-- Builder
		-- l ships
		{ text = ReadText(1001, 6) .. ReadText(1001, 120) .. " " .. ReadText(20111, 5031) },					-- Ships: XL
		{ icon = "ship_l_fight_01",					text = ReadText(20221, 2011),	color = "friendcolor" },	-- Fighter
		{ icon = "ship_l_trade_01",					text = ReadText(20221, 4011),	color = "friendcolor" },	-- Freighter
		{ icon = "ship_l_mine_01",					text = ReadText(20221, 3041),	color = "friendcolor" },	-- Miner
		-- m ships
		{ text = ReadText(1001, 6) .. ReadText(1001, 120) .. " " .. ReadText(20111, 5021) },					-- Ships: XL
		{ icon = "ship_m_fight_01",					text = ReadText(20221, 2011),	color = "friendcolor" },	-- Fighter
		{ icon = "ship_m_trade_01",					text = ReadText(20221, 3031),	color = "friendcolor" },	-- Transporter
		{ icon = "ship_m_mine_01",					text = ReadText(20221, 3041),	color = "friendcolor" },	-- Miner
		-- s ships
		{ text = ReadText(1001, 6) .. ReadText(1001, 120) .. " " .. ReadText(20111, 5011) },					-- Ships: XL
		{ icon = "ship_s_fight_01",					text = ReadText(20221, 2011),	color = "friendcolor" },	-- Fighter
		{ icon = "ship_s_trade_01",					text = ReadText(20221, 3031),	color = "friendcolor" },	-- Transporter
		{ icon = "ship_s_mine_01",					text = ReadText(20221, 3041),	color = "friendcolor" },	-- Miner
		-- xs ships
		{ text = ReadText(1001, 22) },																			-- Units
		{ icon = "ship_xs_fight_01",				text = ReadText(20101, 100401),	color = "friendcolor" },	-- Defence Drone
		{ icon = "ship_xs_trade_01",				text = ReadText(20101, 100101),	color = "friendcolor" },	-- Cargo Drone
		{ icon = "ship_xs_mine_01",					text = ReadText(20101, 100501),	color = "friendcolor" },	-- Mining Drone
		{ icon = "ship_xs_neutral_01",				text = ReadText(20101, 110201),	color = "friendcolor" },	-- Civilian Ship
		{ icon = "ship_xs_build_01",				text = ReadText(20101, 100301),	color = "friendcolor" },	-- Building Drone
		-- misc
		{ text = ReadText(1001, 2664) },																								-- Misc
		{ icon = "mapob_lasertower_xs",				text = ReadText(20201, 20501),	color = "friendcolor" },							-- Laser Tower Mk1
		{ icon = "mapob_lasertower_s",				text = ReadText(20201, 20601),	color = "friendcolor" },							-- Laser Tower Mk2
		{ icon = "mapob_mine",						text = ReadText(20201, 20201),	color = "friendcolor" },							-- Mine
		{ icon = "solid",							text = ReadText(1001, 1304),	width = 4,	height = 4,	color = "missilecolor" },	-- Missiles
		{ icon = "mapob_satellite_01",				text = ReadText(20201, 20301),	color = "friendcolor" },							-- Satellite
		{ icon = "mapob_satellite_02",				text = ReadText(20201, 20401),	color = "friendcolor" },							-- Advanced Satellite
		{ icon = "mapob_resourceprobe",				text = ReadText(20201, 20701),	color = "friendcolor" },							-- Resource Probe
		{ icon = "mapob_navbeacon",					text = ReadText(20201, 20801),	color = "friendcolor" },							-- Nav Beacon
		{ icon = "mapob_poi",						text = ReadText(1001, 9811),	color = "friendcolor" },							-- Point of Interest
		{ icon = "mapob_unknown",					text = ReadText(20109, 5001) },														-- Unknown Object
		{ icon = "npc_factionrep",					text = ReadText(20208, 10601),	color = "friendcolor" },							-- Faction Representative
		{ icon = "npc_missionactor",				text = ReadText(30260, 1901),	color = "missioncolor" },							-- Person of Interest
		{ icon = "npc_shadyguy",					text = ReadText(20208, 10801),	color = "friendcolor" },							-- Black Marketeer
		{ icon = "missionoffer_fight_active",		text = ReadText(1001, 3291),	color = "missioncolor" },							-- Mission Offers
		{ icon = "mapob_missiontarget",				text = ReadText(1001, 3325),	color = "missioncolor" },							-- Accepted Missions
	},
}



local orig = {}
local utRenaming = {}

local function init()
	--DebugError("my mod init")
   for _, menu in ipairs(Menus) do
       if menu.name == "MapMenu" then
             orig.menu = menu -- save entire menu, for other helper function access
       	      -- save original function
			 if GetVersionString() == "2.00 (334398)" or GetVersionString() == "2.20 (339509)" or GetVersionString() == "2.21 (341463)" or  GetVersionString() == "2.50 (337849)"   then --Check for Tested Versions (otherwise this change will be omited for compatibility)
				orig.setupInfoSubmenuRows=menu.setupInfoSubmenuRows
				menu.setupInfoSubmenuRows=utRenaming.setupInfoSubmenuRows
			end
			 orig.infoChangeObjectName=menu.infoChangeObjectName
			 menu.infoChangeObjectName=utRenaming.infoChangeObjectName
          break
      end
   end
end


if GetVersionString() == "2.00 (334398)" or GetVersionString() == "2.20 (339509)" or GetVersionString() == "2.21 (341463)"  then --Check for Tested Versions (otherwise this change will be omited for compatibility)
function utRenaming.setupInfoSubmenuRows(mode, inputtable, inputobject)
	local object64 = ConvertStringTo64Bit(tostring(inputobject))
	if not orig.menu.infocashtransferdetails or orig.menu.infocashtransferdetails[1] ~= inputobject then
		orig.menu.infocashtransferdetails = { inputobject, {0, 0} }
		-- TEMP for testing
		orig.menu.infodrops = {}
		--print("resetting cash transfer details: " .. orig.menu.infocashtransferdetails[2][1])
	end
	if not orig.menu.infomacrostolaunch then
		orig.menu.infomacrostolaunch = { lasertower = nil, mine = nil, navbeacon = nil, resourceprobe = nil, satellite = nil }
	end

	local indentsize = Helper.standardIndentStep

	local loadout = {}
	if mode == "ship" or mode == "station" then
		loadout = { ["component"] = {}, ["macro"] = {}, ["ware"] = {} }
		for i, upgradetype in ipairs(Helper.upgradetypes) do
			if upgradetype.supertype == "macro" then
				loadout.component[upgradetype.type] = {}
				local numslots = 0
				if C.IsComponentClass(inputobject, "defensible") then
					numslots = tonumber(C.GetNumUpgradeSlots(inputobject, "", upgradetype.type))
				end
				for j = 1, numslots do
					local current = C.GetUpgradeSlotCurrentComponent(inputobject, upgradetype.type, j)
					if current ~= 0 then
						table.insert(loadout.component[upgradetype.type], current)
					end
				end
			elseif upgradetype.supertype == "virtualmacro" then
				loadout.macro[upgradetype.type] = {}
				local numslots = tonumber(C.GetNumVirtualUpgradeSlots(inputobject, "", upgradetype.type))
				for j = 1, numslots do
					local current = ffi.string(C.GetVirtualUpgradeSlotCurrentMacro(inputobject, upgradetype.type, j))
					if current ~= "" then
						table.insert(loadout.macro[upgradetype.type], current)
					end
				end
			elseif upgradetype.supertype == "software" then
				loadout.ware[upgradetype.type] = {}
				local numslots = C.GetNumSoftwareSlots(inputobject, "")
				local buf = ffi.new("SoftwareSlot[?]", numslots)
				numslots = C.GetSoftwareSlots(buf, numslots, inputobject, "")
				for j = 0, numslots - 1 do
					local current = ffi.string(buf[j].current)
					if current ~= "" then
						table.insert(loadout.ware[upgradetype.type], current)
					end
				end
			elseif upgradetype.supertype == "ammo" then
				loadout.macro[upgradetype.type] = {}
			end
		end
	end

	local isplayerowned = GetComponentData(object64, "isplayerowned")
	local titlecolor = Helper.color.white
	if isplayerowned then
		titlecolor = orig.menu.holomapcolor.playercolor
		if object64 == C.GetPlayerObjectID() then
			titlecolor = orig.menu.holomapcolor.currentplayershipcolor
		end
	end
	local unknowntext = ReadText(1001, 3210)
	local cheatsecrecy = false
	-- secrecy stuff
	local nameinfo =					cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "name")
	local ownerinfo =					cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "owner")
	local defenceinfo_low =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "defence_level")
	local defenceinfo_high =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "defence_status")
	local operatorinfo =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "operator_name")
	local operatorinfo_details =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "operator_details")
	local operatorinfo_commands =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "operator_commands")
	local productioninfo_products =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_products")
	local productioninfo_rate =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_rate")
	local productioninfo_resources =	cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_resources")
	local productioninfo_time =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_time")
	local storageinfo_capacity =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "storage_capacity")
	local storageinfo_amounts =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "storage_amounts")
	local storageinfo_warelist =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "storage_warelist")
	local unitinfo_capacity =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_capacity")
	local unitinfo_amount =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_amount")
	local unitinfo_details =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_details")
	local equipment_mods =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "equipment_mods")

	if not isplayerowned then
		orig.menu.extendedinfo["info_weaponconfig"] = nil
	end

	--- title ---
	local row = inputtable:addRow(false, {fixed = true, bgColor = Helper.defaultTitleBackgroundColor})
	row[1]:setColSpan(13):createText(ReadText(1001, 2427), Helper.headerRowCenteredProperties)

	local objectname = Helper.unlockInfo(nameinfo, ffi.string(C.GetComponentName(inputobject)))
	if mode == "ship" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(8):setBackgroundColSpan(13):createText(objectname, Helper.headerRow1Properties)
		row[1].properties.color = titlecolor
		row[9]:setColSpan(5):createText(Helper.unlockInfo(nameinfo, ffi.string(C.GetObjectIDCode(inputobject))), Helper.headerRow1Properties)
		row[9].properties.halign = "right"
		row[9].properties.color = titlecolor

		local pilot, isdocked = GetComponentData(inputobject, "assignedpilot", "isdocked")
		pilot = ConvertIDTo64Bit(pilot)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: orig.menu.infoeditname cleared at the end of this function.
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight}):setText(editname)
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- "Owner"
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local loccontainer = nil
			if isdocked then
				loccontainer = ConvertStringTo64Bit(tostring(C.GetTopLevelContainer(inputobject)))
			end
			local objectlocid64 = ConvertStringTo64Bit(tostring(GetComponentData(object64, "sectorid")))
			local objectloc = C.IsInfoUnlockedForPlayer(objectlocid64, "name") and ffi.string(C.GetComponentName(objectlocid64)) or unknowntext
			if loccontainer then
				objectloc = ReadText(1001, 3248) .. " " .. ffi.string(C.GetComponentName(loccontainer)) .. ", " .. objectloc	-- Docked at
			end
			locrowdata = { false, ReadText(1001, 2943), objectloc }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local objecttype = C.IsInfoUnlockedForPlayer(inputobject, "name") and GetMacroData(GetComponentData(object64, "macro"), "name") or unknowntext
			locrowdata = { false, ReadText(1001, 94), objecttype }	-- Model
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local shield_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "shieldmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 2), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "shield")), true, 4, true, true, true) .. " / " .. shield_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "shieldpercent") .. "%)") end) or (unknowntext .. " / " .. shield_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9076), defenceinfo_low and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "maxunboostedforwardspeed")), true, 0, true) .. " " .. ReadText(1001, 113)) end) or (unknowntext .. " " .. ReadText(1001, 113)) }	-- Cruising Speed, m/s
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local dpstable = ffi.new("DPSData[?]", 6)
			local hasturrets = (defenceinfo_low and #loadout.component.turret > 0) and true or false
			local numtotalquadrants = C.GetDefensibleDPS(dpstable, inputobject, true, true, true, true, hasturrets, false, false)
			if not hasturrets then
				locrowdata = { false, ReadText(1001, 9092), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(dpstable[0].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- Weapon Output, MW
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			else
				for i = 0, numtotalquadrants - 1 do
					locrowdata = { false, (ReadText(1001, 9092) .. " (" .. ReadText(20220, dpstable[i].quadranttextid) .. ")"), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(dpstable[i].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- Weapon Output, MW
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end

			local sustainedfwddps = ffi.new("DPSData[?]", 1)
			C.GetDefensibleDPS(sustainedfwddps, inputobject, true, true, true, true, false, true, false)
			if sustainedfwddps[0].dps > 0 then
				locrowdata = { false, ReadText(1001, 9093), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(sustainedfwddps[0].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- TEMPTEXT nick, MW
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			local radarrange = defenceinfo_low and ConvertIntegerString((Helper.round(GetComponentData(object64, "maxradarrange")) / 1000), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local shipcombinedskill = math.floor(C.GetShipCombinedSkill(inputobject) * 15 / 100)
			local printedshipcombinedskill = unknowntext
			local locfont = inputfont
			local locfontcolor = Helper.standardColor
			if operatorinfo_details then
				printedshipcombinedskill = Helper.displaySkill(shipcombinedskill)
				locfontcolor = Helper.color.brightyellow
			end
			locrowdata = { false, ReadText(1001, 9427), printedshipcombinedskill }	-- Crew Skill
			row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
			row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indentsize })
			row[4]:setColSpan(10):createText(locrowdata[3], { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })

			locrowdata = { false, ReadText(1001, 1325), defenceinfo_high and (function() return ConvertIntegerString(tostring(GetComponentData(object64, "boardingstrength")), true, 0, true) end) or unknowntext }	-- Boarding Attack Strength
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end

		locrowdata = { "Personnel", ReadText(1001, 9400) }	-- Personnel
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local numorders = C.GetNumOrders(inputobject)
			local currentorders = ffi.new("Order[?]", numorders)
			local activeorder = ffi.new("Order")
			if numorders > 0 then
				numorders = C.GetOrders(currentorders, numorders, inputobject)
				activeorder = currentorders[0]
			else
				C.GetDefaultOrder(activeorder, inputobject)
			end
			local ordername = ""
			local orderdefinition = ffi.new("OrderDefinition")
			if activeorder.orderdef ~= nil and C.GetOrderDefinition(orderdefinition, activeorder.orderdef) then
				ordername = operatorinfo_commands and ffi.string(orderdefinition.name) or unknowntext
			end
			local objectlocid64 = ConvertStringTo64Bit(tostring(GetComponentData(object64, "sectorid")))
			local objectloc = (objectlocid64 ~= 0 and C.IsInfoUnlockedForPlayer(objectlocid64, "name")) and ffi.string(C.GetComponentName(objectlocid64)) or unknowntext
			local isbigship = C.IsComponentClass(inputobject, "ship_m") or C.IsComponentClass(inputobject, "ship_l") or C.IsComponentClass(inputobject, "ship_xl")
			local printedtitle = isbigship and ReadText(1001, 4848) or ReadText(1001, 4847)	-- Captain, Pilot
			local endcelltext = (numorders .. " " .. ReadText(1001, 9402))	-- Orders queued
			if numorders == 1 then
				endcelltext = (numorders .. " " .. ReadText(1001, 9401))	-- Order queued
			end
			numorders = operatorinfo_commands and tostring(numorders) or unknowntext
			locrowdata = ({ "Pilot", (printedtitle .. ReadText(1001, 120)), ordername, objectloc, endcelltext })	-- :
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (pilot or isplayerowned) and true or false, 1, indentsize)
			local printedpilotname = operatorinfo and (pilot and tostring(GetComponentData(pilot, "name")) or "") or unknowntext
			if (pilot or isplayerowned) and orig.menu.extendedinfo[locrowdata[1]] then
				if pilot then
					local adjustedskill = math.floor(C.GetEntityCombinedSkill(pilot, nil, "aipilot") * 15 / 100)
					local printedskill = operatorinfo_details and Helper.displaySkill(adjustedskill) or unknowntext
					local skilltable = GetComponentData(pilot, "skills")
					locrowdata = { { pilot, pilot, inputobject }, printedpilotname }
					if (pilot == C.GetPlayerID()) or not operatorinfo or C.IsUnit(inputobject) then
						locrowdata = { pilot, printedpilotname }
					end
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					local locfont = inputfont
					local locfontcolor = Helper.standardColor
					if operatorinfo_details then
						locfontcolor = Helper.color.brightyellow
					end
					row[2]:setColSpan(2)
					row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
					table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)

					if pilot ~= C.GetPlayerID() then
						for _, skillproperties in ipairs(skilltable) do
							local skillname = ReadText(1013, skillproperties.textid)
							local adjustedskill = math.floor(skillproperties.value * 15 / 15)
							local printedskill = operatorinfo_details and Helper.displaySkill(adjustedskill) or unknowntext
							row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
							row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skillproperties.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
							local locfont = inputfont
							local locfontcolor = Helper.standardColor
							if operatorinfo_details then
								locfontcolor = Helper.color.brightyellow
							end
							row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
						end
						if isplayerowned then
							local line_replace = isbigship and ReadText(1001, 9430) or ReadText(1001, 9431)	-- Replace captain with best crewmember, Replace pilot with best crewmember
							row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
							row[2]:setColSpan(12):createText(line_replace, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })

							-- button is clickable if:
							-- we have crew,
							-- we have a pilot,
							-- the pilot is not in a critical state (NPC_State_Machines),
							-- the controllable is not running an order in a critical state,
							-- and one of our crew members is better than the current pilot.
							-- NB: check to see if there is a pilot is necessary since there is a delay between pressing this button and the old pilot getting dismissed leading to errors in the later checks.
							row = inputtable:addRow("ReplacePilot", { bgColor = Helper.color.transparent })
							row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() locpilot = GetComponentData(inputobject, "assignedpilot") return ((orig.menu.infocrew.current.total > 0) and locpilot and not GetNPCBlackboard(locpilot, "$state_machine_critical") and not C.IsCurrentOrderCritical(inputobject) and orig.menu.infoSubmenuReplacePilot(inputobject, ConvertIDTo64Bit(locpilot), nil, true) and true or false) end }):setText(ReadText(1001, 57), { halign = "center", fontsize = config.mapFontSize })	-- Accept
							row[9].handlers.onClick = function() return orig.menu.infoSubmenuReplacePilot(inputobject, pilot) end
						end
					end
				else
					row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(7):createText(ReadText(1001, 9432) .. " " .. printedtitle, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })	-- Promote best crewmember to

					row = inputtable:addRow("ReplacePilot", { bgColor = Helper.color.transparent })
					row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (orig.menu.infocrew.current.total > 0) and true or false }):setText(ReadText(1001, 57), { halign = "center", fontsize = config.mapFontSize })	-- Accept
					row[9].handlers.onClick = function() return orig.menu.infoSubmenuReplacePilot(inputobject, nil) end
				end
			end

			local peoplecapacity = C.GetPeopleCapacity(inputobject, "", false)
			local totalcrewcapacity = orig.menu.infocrew.capacity
			local totalnumpeople = orig.menu.infocrew.total
			local aipilot = GetComponentData(inputobject, "assignedaipilot")
			if aipilot then
				aipilot = ConvertStringTo64Bit(tostring(aipilot))
				totalnumpeople = totalnumpeople + 1
			end
			local printedcapacity = operatorinfo and tostring(totalcrewcapacity) or unknowntext
			local printednumpeople = operatorinfo and tostring(totalnumpeople) or unknowntext
			locrowdata = { "Crew", ReadText(1001, 80), (printednumpeople .. " / " .. printedcapacity) }	-- Crew
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, ((operatorinfo and totalnumpeople > 0) and true or false), 1, indentsize)
			if operatorinfo and totalnumpeople > 0 and orig.menu.extendedinfo[locrowdata[1]] then
				-- pilot entry in crew sliders
				if pilot == C.GetPlayerID() and aipilot then
					printedtitle = ReadText(1001, 9403)	-- Relief Pilot
					printedpilotname = tostring(GetComponentData(aipilot, "name"))
				end
				locrowdata = { { "info_crewpilot", aipilot, inputobject }, (printedtitle .. " " .. printedpilotname), (((aipilot or pilot) and 1 or 0) .. " / " .. 1 ) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(13):createText("")

				locrowdata = ReadText(1001, 5207)	-- Unassigned
				local sliderrows = {}
				local slidercounter = 0
				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(locrowdata, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (2 * indentsize) })
				row[4]:setColSpan(10):createText(function() return ("(" .. tostring(orig.menu.infocrew.unassigned.total) .. ")") end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })
				local unassignedrow = row
				for i, roletable in ipairs(orig.menu.infocrew.current.roles) do
					if roletable.amount > 0 or roletable.canhire then
						slidercounter = slidercounter + 1
						-- can query: .id, .name, .desc, .amount, .numtiers, .canhire
						--{ 
						--	id = ffi.string(peopletable[i].id), 
						--	name = ffi.string(peopletable[i].name), 
						--	desc = ffi.string(peopletable[i].desc), 
						--	amount = peopletable[i].amount, 
						--	canhire = peopletable[i].canhire, 
						--	numtiers = peopletable[i].numtiers, 
						--	tiers = {} 
						--}
						locrowdata = ffi.string(roletable.id)
						row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
						--print("name: " .. ffi.string(roletable.name) .. ", canhire: " .. tostring(roletable.canhire))
						row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = roletable.amount + orig.menu.infocrew.reassigned.roles[i].amount, max = peoplecapacity, maxSelect = roletable.amount + orig.menu.infocrew.reassigned.roles[i].amount + orig.menu.infocrew.unassigned.total, x = Helper.standardTextOffsetx + (2 * indentsize), readOnly = not isplayerowned or not roletable.canhire }):setText(ffi.string(roletable.name), { fontsize = config.mapFontSize })
						sliderrows[slidercounter] = { ["row"] = row, ["roleindex"] = i,["id"] = roletable.id, ["name"] = roletable.name, ["desc"] = roletable.desc, ["amount"] = roletable.amount, ["numtiers"] = roletable.numtiers, ["canhire"] = roletable.canhire, ["tiers"] = {} }
			
						local numtiers = roletable.numtiers
						for j, tiertable in ipairs(roletable.tiers) do
							if not tiertable.hidden then
								-- can query: .name, .skilllevel, .amount
								--{ 
								--	name = ffi.string(tiertable[j].name), 
								--	skilllevel = tiertable[j].skilllevel, 
								--	amount = tiertable[j].amount, 
								--	persons = {} 
								--}
								--print("tier name: " .. ffi.string(tiertable.name) .. ", skill level: " .. tostring(tiertable.skilllevel) .. ", num: " .. tostring(tiertable.amount))
								locrowdata = (ffi.string(roletable.id) .. j)
								row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
								row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = tiertable.amount + orig.menu.infocrew.reassigned.roles[i].tiers[j].amount, max = peoplecapacity, maxSelect = tiertable.amount + orig.menu.infocrew.reassigned.roles[i].tiers[j].amount, x = Helper.standardTextOffsetx + (3 * indentsize), readOnly = not isplayerowned }):setText(ffi.string(tiertable.name), { fontsize = config.mapFontSize })
								sliderrows[slidercounter].tiers[j] = { ["row"] = row, ["roleindex"] = i, ["name"] = tiertable.name, ["skilllevel"] = tiertable.skilllevel, ["amount"] = tiertable.amount }
							end
						end
					end
				end
				if isplayerowned then
					row = inputtable:addRow("UpdateCrew", { bgColor = Helper.color.transparent })
					row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocrew.reassigned.total > 0) and (orig.menu.infocrew.unassigned.total == 0)) end }):setText(ReadText(1001, 2821), { halign = "center", fontsize = config.mapFontSize })	-- Confirm
					row[4].handlers.onClick = function() return orig.menu.infoSubmenuConfirmCrewChanges() end
					row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocrew.reassigned.total > 0) or (orig.menu.infocrew.unassigned.total > 0)) end }):setText(ReadText(1001, 3318), { halign = "center", fontsize = config.mapFontSize })	-- Reset
					row[9].handlers.onClick = function() return orig.menu.resetInfoSubmenu() end

					for i, role in ipairs(sliderrows) do

						-- TODO: cleanup these tables. not all data is used.
						local sliderupdatetable = { ["table"] = inputtable, ["row"] = role.row, ["col"] = 2, ["tierrows"] = {}, ["text"] = role.name, ["xoffset"] = role.row[2].properties.x, ["width"] = role.row[2].properties.width }
						for j, tier in ipairs(role.tiers) do
							table.insert(sliderupdatetable.tierrows, { ["row"] = tier.row, ["text"] = tier.name, ["xoffset"] = tier.row[2].properties.x, ["width"] = tier.row[2].properties.width })
						end

						role.row[2].handlers.onSliderCellChanged = function(_, newamount) return orig.menu.infoSubmenuUpdateCrewChanges(newamount, sliderrows, i, false, nil, sliderupdatetable) end
						role.row[2].handlers.onSliderCellConfirm = function() return orig.menu.refreshInfoFrame() end
						role.row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
						role.row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end
						for j, tier in ipairs(role.tiers) do
							tier.row[2].handlers.onSliderCellChanged = function(_, newamount) return orig.menu.infoSubmenuUpdateCrewChanges(newamount, sliderrows, i, true, j, sliderupdatetable) end
							tier.row[2].handlers.onSliderCellConfirm = function() return orig.menu.refreshInfoFrame() end
							tier.row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
							tier.row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end
						end
					end
				end

				locrowdata = { "Full Crew List", ReadText(1001, 9404) }	-- Full Crew List
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, operatorinfo_details, 2, indentsize)
				if operatorinfo_details and orig.menu.extendedinfo[locrowdata[1]] then
					-- pilot entry in full crew manifest
					locrowdata = { "PilotInFullCrew", printedtitle, "" }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, aipilot and true or false, 3, indentsize)
					if aipilot and orig.menu.extendedinfo[locrowdata[1]] then
						local name = GetComponentData(aipilot, "name")
						local printedname = operatorinfo and tostring(name) or unknowntext
						local adjustedcombinedskill = math.floor(GetComponentData(aipilot, "combinedskill") * 15 / 100)
						local extendinfoid = "info_crewpilot_full"
						local locrowdata = { "info_crewpilot_full", aipilot, inputobject }
						local printedskill = Helper.displaySkill(adjustedcombinedskill)
						local indent = 4 * indentsize
						row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(2):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
						row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, color = Helper.color.brightyellow })
						row[1]:createButton({ height = config.mapRowHeight }):setText(function() return orig.menu.extendedinfo[extendinfoid] and "-" or "+" end, { halign = "center" })
						row[1].handlers.onClick = function() return orig.menu.buttonExtendInfo(extendinfoid) end
						if orig.menu.extendedinfo[extendinfoid] then
							local skilltable = GetComponentData(aipilot, "skills")
							table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)
							for _, skillproperties in ipairs(skilltable) do
								local skillname = ReadText(1013, skillproperties.textid)
								local printedskill = operatorinfo_details and Helper.displaySkill(skillproperties.value) or unknowntext
								row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
								row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skillproperties.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (5 * indentsize) })
								local locfont = inputfont
								local locfontcolor = Helper.standardColor
								if operatorinfo_details then
									locfontcolor = Helper.color.brightyellow
								end
								row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
							end
						end
					end

					for i, roletable in ipairs(orig.menu.infocrew.current.roles) do
						if roletable.amount > 0 then
							locrowdata = { ("Role " .. i), tostring(roletable.name), tostring(roletable.amount) }
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (roletable.amount > 0) and true or false, 3, indentsize)
							if orig.menu.extendedinfo[locrowdata[1]] then
								for j, tiertable in ipairs(roletable.tiers) do
									if roletable.numtiers > 1 then
										locrowdata = { ("Role " .. i .. " Tier " .. j), tostring(tiertable.name), tostring(tiertable.amount) }
										row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (tiertable.amount > 0) and true or false, 4, indentsize)
									end
									if orig.menu.extendedinfo[locrowdata[1]] then
										for k, person in ipairs(tiertable.persons) do
											-- NB: adjusted to 5 points at the moment because more than 5 doesn't fit very comfortably in this orig.menu.
											local adjustedcombinedskill = math.floor(C.GetPersonCombinedSkill(inputobject, person, nil, nil) * 15 / 100)
											-- Note: extendinfoid and locrowdata[1] can be different - that wouldn't work when using orig.menu.addInfoSubmenuRow() though
											local extendinfoid = string.format("info_crewperson_r%d_t%d_p%d", i, j, k)
											local locrowdata = { "info_crewperson", person, inputobject }
											local printedname = ffi.string(C.GetPersonName(person, inputobject))
											local printedskill = Helper.displaySkill(adjustedcombinedskill)
											local indent = (roletable.numtiers > 1) and (5 * indentsize) or (4 * indentsize)
											row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
											row[2]:setColSpan(2):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
											row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, color = Helper.color.brightyellow })
											row[1]:createButton({ height = config.mapRowHeight }):setText(function() return orig.menu.extendedinfo[extendinfoid] and "-" or "+" end, { halign = "center" })
											row[1].handlers.onClick = function() return orig.menu.buttonExtendInfo(extendinfoid) end
											if orig.menu.extendedinfo[extendinfoid] then
												local numskills = C.GetNumSkills()
												local skilltable = ffi.new("Skill[?]", numskills + 1)
												numskills = C.GetPersonSkills(skilltable, person, inputobject)
												local sortedskilltable = {}
												for i = 1, numskills do
													table.insert(sortedskilltable, skilltable[i])
												end
												table.sort(sortedskilltable, function(a, b) return a.relevance > b.relevance end)
												for i, skill in ipairs(sortedskilltable) do
													local skillname = ReadText(1013, skill.textid)
													local indent = (roletable.numtiers > 1) and (6 * indentsize) or (5 * indentsize)
													local printedskill = Helper.displaySkill(skill.value)
													row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
													row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skill.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + indent })
													row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, color = Helper.color.brightyellow })
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end

		local storagemodules = GetStorageData(object64)
		local cargotable = {}
		local numwares = 0
		local sortedwarelist = {}
		for _, storagemodule in ipairs(storagemodules) do
			for _, ware in ipairs(storagemodule) do
				table.insert(sortedwarelist, ware)
			end
		end
		table.sort(sortedwarelist, function(a, b) return a.name < b.name end)
		for _, ware in ipairs(sortedwarelist) do
			table.insert(cargotable, { ware = ware.ware, amount = ware.amount })
			numwares = numwares + 1
		end
		local loccapacity = storageinfo_capacity and ConvertIntegerString(storagemodules.capacity, true, 0, true) or unknowntext
		local locamount = storageinfo_amounts and ConvertIntegerString(storagemodules.stored, true, 0, true) or unknowntext
		local printednumwares = storageinfo_amounts and tostring(numwares) or unknowntext
		locrowdata = { 
			"Storage", 
			(ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"),
			(ReadText(1001, 1402) .. ReadText(1001, 120)), 
			(storagemodules.estimated and unknowntext or (locamount .. " / " .. loccapacity .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (storageinfo_warelist and numwares > 0) and true or false)
		if storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			if isplayerowned then
				local numtrips = GetComponentData(object64, "numtrips")
				if numtrips > 0 then
					local cargoaftertrades = GetCargoAfterTradeOrders(object64, true)
					local totalvolume = 0
					for ware, amount in pairs(cargoaftertrades) do
						totalvolume = totalvolume + amount * GetWareData(ware, "volume")
					end
					locrowdata = { "FutureStorage", ReadText(1001, 8374) .. ReadText(1001, 120), ConvertIntegerString(totalvolume, true, 0, true) .. " / " .. loccapacity .. " " .. ReadText(1001, 110) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end
			-- TEMP for testing
			if isplayerowned then
				local stufftodrop = false
				for ware, numdrops in pairs(orig.menu.infodrops) do
					if numdrops > 0 then
						stufftodrop = true
						break
					end
				end
				-- add a "Drop" button
				row = inputtable:addRow("ConfirmDrops", { bgColor = Helper.color.transparent })
				row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = stufftodrop }):setText(ReadText(1001, 9405), { halign = "center", fontsize = config.mapFontSize })	-- Drop
				row[4].handlers.onClick = function() return orig.menu.infoSubmenuConfirmDrops(inputobject) end
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = stufftodrop }):setText(ReadText(1001, 64), { halign = "center", fontsize = config.mapFontSize })	-- Cancel
				row[9].handlers.onClick = function() return orig.menu.resetInfoSubmenu() end
			end
			local locpolicefaction = GetComponentData(GetComponentData(object64, "zoneid"), "policefaction")
			for _, wareentry in ipairs(cargotable) do
				local ware = wareentry.ware
				local amount = wareentry.amount
				if not orig.menu.infodrops[ware] then
					orig.menu.infodrops[ware] = 0
				end
				locrowdata = { ware, GetWareData(ware, "name"), amount }
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				-- TEMP for testing
				row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount - orig.menu.infodrops[ware], maxSelect = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = not isplayerowned }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })
				--row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })

				-- TEMP for testing
				if isplayerowned then
					--local oldamount = amount
					row[2].handlers.onSliderCellChanged = function(_, newamount) return orig.menu.infoSubmenuUpdateDrops(ware, amount, newamount) end
					--row[2].handlers.onSliderCellChanged = function(_, newamount) return (orig.menu.infodrops[ware] = amount - newamount) end
					row[2].handlers.onSliderCellConfirm = function() return orig.menu.refreshInfoFrame() end
					row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
					row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end

					locrowdata = "Drops"
					row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
					--row[2]:setColSpan(2):createText(locrowdata, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (2 * indentsize) })
					row[4]:setColSpan(10):createText(function() return (ReadText(1001, 9406) .. ReadText(1001, 120) .. " (" .. tostring(orig.menu.infodrops[ware]) .. ")") end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })	-- Dropping, :
				end
			end
		end

		local shipstoragecapacity = GetComponentData(inputobject, "shipstoragecapacity")
		if shipstoragecapacity > 0 then
			local numdockedships = 0
			if C.IsComponentClass(inputobject, "container") then
				numdockedships = C.GetNumDockedShips(inputobject, nil)
			end
			locrowdata = { "info_dockedships", ReadText(1001, 3265) }
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, numdockedships > 0 and true or false)
			if orig.menu.extendedinfo[locrowdata[1]] then
				local dockedships = ffi.new("UniverseID[?]", numdockedships)
				numdockedships = C.GetDockedShips(dockedships, numdockedships, inputobject, nil)
				local playerowneddockedships = {}
				local npcowneddockedships = {}
				for i = 0, numdockedships-1 do
					local locship = ConvertStringTo64Bit(tostring(dockedships[i]))
					if GetComponentData(locship, "isplayerowned") then
						table.insert(playerowneddockedships, locship)
					else
						table.insert(npcowneddockedships, locship)
					end
				end
				table.sort(playerowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)
				table.sort(npcowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)

				local totaldockedships = 0
				for i, shipid in ipairs(playerowneddockedships) do
					local shipname = ffi.string(C.GetComponentName(shipid))
					local iconid = GetComponentData(shipid, "icon")
					if iconid and iconid ~= "" then
						shipname = string.format("\027[%s] %s", iconid, shipname)
					end
					row = inputtable:addRow(("info_dockedship" .. i), { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(shipname, { color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
					row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
					totaldockedships = i
				end
				for i, shipid in ipairs(npcowneddockedships) do
					local shipname = ffi.string(C.GetComponentName(shipid))
					local iconid = GetComponentData(shipid, "icon")
					if iconid and iconid ~= "" then
						shipname = string.format("\027[%s] %s", iconid, shipname)
					end
					row = inputtable:addRow(("info_dockedship" .. totaldockedships+i), { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(shipname, { x = Helper.standardTextOffsetx + indentsize })
					row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", x = Helper.standardTextOffsetx + indentsize })
				end
			end
		end

		local nummissiletypes = C.GetNumAllMissiles(inputobject)
		local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes)
		nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject)
		local totalnummissiles = 0
		for i = 0, nummissiletypes - 1 do
			totalnummissiles = totalnummissiles + missilestoragetable[i].amount
		end
		local missilecapacity = 0
		if C.IsComponentClass(inputobject, "defensible") then
			missilecapacity = GetComponentData(inputobject, "missilecapacity")
		end
		local locmissilecapacity = defenceinfo_low and tostring(missilecapacity) or unknowntext
		local locnummissiles = defenceinfo_high and tostring(totalnummissiles) or unknowntext
		locrowdata = { "Ammunition", ReadText(1001, 2800), (locnummissiles .. " / " .. locmissilecapacity) }	-- Ammunition
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnummissiles > 0) and true or false)
		if defenceinfo_high and orig.menu.extendedinfo[locrowdata[1]] then
			for i = 0, nummissiletypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(missilestoragetable[i].macro), "name"), (tostring(missilestoragetable[i].amount) .. " / " .. tostring(missilestoragetable[i].capacity)) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end

		local numcountermeasuretypes = C.GetNumAllCountermeasures(inputobject)
		local countermeasurestoragetable = ffi.new("AmmoData[?]", numcountermeasuretypes)
		numcountermeasuretypes = C.GetAllCountermeasures(countermeasurestoragetable, numcountermeasuretypes, inputobject)
		local totalnumcountermeasures = 0
		for i = 0, numcountermeasuretypes - 1 do
			totalnumcountermeasures = totalnumcountermeasures + countermeasurestoragetable[i].amount
		end
		local countermeasurecapacity = GetComponentData(object64, "countermeasurecapacity")
		local loccountermeasurecapacity = defenceinfo_low and tostring(countermeasurecapacity) or unknowntext
		local locnumcountermeasures = defenceinfo_high and tostring(totalnumcountermeasures) or unknowntext
		locrowdata = { "Countermeasures", ReadText(20215, 1701), (locnumcountermeasures .. " / " .. loccountermeasurecapacity) }	-- Countermeasures
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnumcountermeasures > 0) and true or false)
		if orig.menu.extendedinfo[locrowdata[1]] then
			for i = 0, numcountermeasuretypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(countermeasurestoragetable[i].macro), "name"), (tostring(countermeasurestoragetable[i].amount) .. " / " .. tostring(countermeasurestoragetable[i].capacity)) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end

		local numlasertowertypes = C.GetNumAllLaserTowers(inputobject)
		local lasertowerstoragetable = ffi.new("AmmoData[?]", numlasertowertypes)
		numlasertowertypes = C.GetAllLaserTowers(lasertowerstoragetable, numlasertowertypes, inputobject)
		local totalnumlasertowers = 0
		for i = 0, numlasertowertypes - 1 do
			totalnumlasertowers = totalnumlasertowers + lasertowerstoragetable[i].amount
		end

		local numminetypes = C.GetNumAllMines(inputobject)
		local minestoragetable = ffi.new("AmmoData[?]", numminetypes)
		numminetypes = C.GetAllMines(minestoragetable, numminetypes, inputobject)
		local totalnummines = 0
		for i = 0, numminetypes - 1 do
			totalnummines = totalnummines + minestoragetable[i].amount
		end

		local numsatellitetypes = C.GetNumAllSatellites(inputobject)
		local satellitestoragetable = ffi.new("AmmoData[?]", numsatellitetypes)
		numsatellitetypes = C.GetAllSatellites(satellitestoragetable, numsatellitetypes, inputobject)
		local totalnumsatellites = 0
		for i = 0, numsatellitetypes - 1 do
			totalnumsatellites = totalnumsatellites + satellitestoragetable[i].amount
		end

		local numnavbeacontypes = C.GetNumAllNavBeacons(inputobject)
		local navbeaconstoragetable = ffi.new("AmmoData[?]", numnavbeacontypes)
		numnavbeacontypes = C.GetAllNavBeacons(navbeaconstoragetable, numnavbeacontypes, inputobject)
		local totalnumnavbeacons = 0
		for i = 0, numnavbeacontypes - 1 do
			totalnumnavbeacons = totalnumnavbeacons + navbeaconstoragetable[i].amount
		end

		local numresourceprobetypes = C.GetNumAllResourceProbes(inputobject)
		local resourceprobestoragetable = ffi.new("AmmoData[?]", numresourceprobetypes)
		numresourceprobetypes = C.GetAllResourceProbes(resourceprobestoragetable, numresourceprobetypes, inputobject)
		local totalnumresourceprobes = 0
		for i = 0, numresourceprobetypes - 1 do
			totalnumresourceprobes = totalnumresourceprobes + resourceprobestoragetable[i].amount
		end

		local totalnumdeployables = totalnumlasertowers + totalnummines + totalnumsatellites + totalnumnavbeacons + totalnumresourceprobes
		local deployablecapacity = C.GetDefensibleDeployableCapacity(inputobject)
		local printednumdeployables = defenceinfo_low and tostring(totalnumdeployables) or unknowntext
		local printeddeployablecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext

		locrowdata = { "info_deployables", ReadText(1001, 1332), (printednumdeployables .. " / " .. printeddeployablecapacity) }	-- Deployables
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumdeployables > 0))
		if defenceinfo_high and (totalnumdeployables > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			local printedlasertowercapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumlasertowers = defenceinfo_high and tostring(totalnumlasertowers) or unknowntext
			locrowdata = { "info_lasertowers", ReadText(1001, 1333), (printednumlasertowers .. " / " .. printedlasertowercapacity) }	-- Laser Towers
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumlasertowers > 0), 1, indentsize)
			if defenceinfo_high and (totalnumlasertowers > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchlasertower", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.lasertower) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchLasertower(inputobject, orig.menu.infomacrostolaunch.lasertower) end
				for i = 0, numlasertowertypes - 1 do
					locrowdata = { {("info_lasertower" .. (i+1)), "info_deploy", ffi.string(lasertowerstoragetable[i].macro)}, GetMacroData(ffi.string(lasertowerstoragetable[i].macro), "name"), (tostring(lasertowerstoragetable[i].amount) .. " / " .. tostring(lasertowerstoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printedminecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednummines = defenceinfo_high and tostring(totalnummines) or unknowntext
			locrowdata = { "info_mines", ReadText(1001, 1326), (printednummines .. " / " .. printedminecapacity) }	-- Mines
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnummines > 0), 1, indentsize)
			if defenceinfo_high and (totalnummines > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchmine", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.mine) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchMine(inputobject, orig.menu.infomacrostolaunch.mine) end
				for i = 0, numminetypes - 1 do
					locrowdata = { {("info_mine" .. (i+1)), "info_deploy", ffi.string(minestoragetable[i].macro)}, GetMacroData(ffi.string(minestoragetable[i].macro), "name"), (tostring(minestoragetable[i].amount) .. " / " .. tostring(minestoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printedsatellitecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumsatellites = defenceinfo_high and tostring(totalnumsatellites) or unknowntext
			locrowdata = { "info_satellites", ReadText(1001, 1327), (printednumsatellites .. " / " .. printedsatellitecapacity) }	-- Satellites
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumsatellites > 0), 1, indentsize)
			if defenceinfo_high and (totalnumsatellites > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchsatellite", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.satellite) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchSatellite(inputobject, orig.menu.infomacrostolaunch.satellite) end
				for i = 0, numsatellitetypes - 1 do
					locrowdata = { {("info_satellite" .. (i+1)), "info_deploy", ffi.string(satellitestoragetable[i].macro)}, GetMacroData(ffi.string(satellitestoragetable[i].macro), "name"), (tostring(satellitestoragetable[i].amount) .. " / " .. tostring(satellitestoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printednavbeaconcapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumnavbeacons = defenceinfo_high and tostring(totalnumnavbeacons) or unknowntext
			locrowdata = { "info_navbeacons", ReadText(1001, 1328), (printednumnavbeacons .. " / " .. printednavbeaconcapacity) }	-- Navigation Beacons
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumnavbeacons > 0), 1, indentsize)
			if defenceinfo_high and (totalnumnavbeacons > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchnavbeacon", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.navbeacon) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchNavBeacon(inputobject, orig.menu.infomacrostolaunch.navbeacon) end
				for i = 0, numnavbeacontypes - 1 do
					locrowdata = { {("info_navbeacon" .. (i+1)), "info_deploy", ffi.string(navbeaconstoragetable[i].macro)}, GetMacroData(ffi.string(navbeaconstoragetable[i].macro), "name"), (tostring(navbeaconstoragetable[i].amount) .. " / " .. tostring(navbeaconstoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end
		
			local printedresourceprobecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumresourceprobes = defenceinfo_high and tostring(totalnumresourceprobes) or unknowntext
			locrowdata = { "info_resourceprobes", ReadText(1001, 1329), (printednumresourceprobes .. " / " .. printedresourceprobecapacity) }	-- Resource Probes
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumresourceprobes > 0), 1, indentsize)
			if defenceinfo_high and (totalnumresourceprobes > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchresourceprobe", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.resourceprobe) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchResourceProbe(inputobject, orig.menu.infomacrostolaunch.resourceprobe) end
				for i = 0, numresourceprobetypes - 1 do
					locrowdata = { {("info_resourceprobe" .. (i+1)), "info_deploy", ffi.string(resourceprobestoragetable[i].macro)}, GetMacroData(ffi.string(resourceprobestoragetable[i].macro), "name"), (tostring(resourceprobestoragetable[i].amount) .. " / " .. tostring(resourceprobestoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end
		end

		local unitstoragetable = GetUnitStorageData(object64)
		local locunitcapacity = unitinfo_capacity and tostring(unitstoragetable.capacity) or unknowntext
		local locunitcount = unitinfo_capacity and tostring(unitstoragetable.stored) or unknowntext
		locrowdata = {"info_units", ReadText(1001, 8), (locunitcount .. " / " .. locunitcapacity)}	-- Drones
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (unitinfo_details and unitstoragetable.stored > 0) and true or false)
		if orig.menu.extendedinfo[locrowdata[1]] then
			for i = 1, #unitstoragetable do
				if unitstoragetable[i].amount > 0 or unitstoragetable[i].unavailable > 0 then
					locrowdata = { ("Unit" .. i), unitstoragetable[i].name, (unitstoragetable[i].amount .. " / " .. unitstoragetable.capacity .. " (" .. unitstoragetable[i].unavailable .. " " .. ReadText(1001, 9408) .. ")") }	-- Unavailable
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end
		end

		locrowdata = { "info_weaponconfig", ReadText(1001, 9409) }	-- Weapon Configuration
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, isplayerowned and (#loadout.component.weapon > 0) and true or false)
		if isplayerowned and orig.menu.extendedinfo[ locrowdata[1] ] and #loadout.component.weapon > 0 then
			locrowdata = { false, "", "", ReadText(1001, 9410), ReadText(1001, 9411) }	-- Primary, Secondary
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false)
			for i, gun in ipairs(loadout.component.weapon) do
				local gun = ConvertStringTo64Bit(tostring(gun))
				local numweapongroups = C.GetNumWeaponGroupsByWeapon(inputobject, gun)
				local rawweapongroups = ffi.new("UIWeaponGroup[?]", numweapongroups)
				numweapongroups = C.GetWeaponGroupsByWeapon(rawweapongroups, numweapongroups, inputobject, gun)
				local uiweapongroups = { primary = {}, secondary = {} }
				for j = 0, numweapongroups-1 do
					-- there are two sets: primary and secondary.
					-- each set has four groups.
					-- .primary tells you if this particular weapon is active in a group in the primary or secondary group set.
					-- .idx tells you which group in that group set it is active in.
					if rawweapongroups[j].primary then
						uiweapongroups.primary[rawweapongroups[j].idx] = true
					else
						uiweapongroups.secondary[rawweapongroups[j].idx] = true
					end
					--print("primary: " .. tostring(rawweapongroups[j].primary) .. ", idx: " .. tostring(rawweapongroups[j].idx))
				end

				row = inputtable:addRow(("info_weaponconfig" .. i), { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(ffi.string(C.GetComponentName(gun)))

				-- primary weapon groups
				for j = 1, 4 do
					row[3+j]:createCheckBox(uiweapongroups.primary[j], { width = config.mapRowHeight, height = config.mapRowHeight })
					row[3+j].handlers.onClick = function() orig.menu.infoSetWeaponGroup(inputobject, gun, true, j, not uiweapongroups.primary[j]) end
				end

				-- secondary weapon groups
				for j = 1, 4 do
					row[8+j]:createCheckBox(uiweapongroups.secondary[j], { width = config.mapRowHeight, height = config.mapRowHeight })
					row[8+j].handlers.onClick = function() orig.menu.infoSetWeaponGroup(inputobject, gun, false, j, not uiweapongroups.secondary[j]) end
				end

				if IsComponentClass(gun, "missilelauncher") then
					local nummissiletypes = C.GetNumAllMissiles(inputobject)
					local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes)
					nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject)

					local gunmacro = GetComponentData(gun, "macro")
					local dropdowndata = {}
					for j = 0, nummissiletypes-1 do
						local ammomacro = ffi.string(missilestoragetable[j].macro)
						if C.IsAmmoMacroCompatible(gunmacro, ammomacro) then
							table.insert(dropdowndata, {id = ammomacro, text = GetMacroData(ammomacro, "name"), icon = "", displayremoveoption = false})
						end
					end

					-- if the ship has no compatible ammunition in ammo storage, have the dropdown print "Out of ammo" and make it inactive.
					local currentammomacro = "empty"
					local dropdownactive = true
					if #dropdowndata == 0 then
						dropdownactive = false
						table.insert(dropdowndata, {id = "empty", text = ReadText(1001, 9412), icon = "", displayremoveoption = false})	-- Out of ammo
					else
						-- NB: currentammomacro can be null
						currentammomacro = ffi.string(C.GetCurrentAmmoOfWeapon(gun))
					end

					row = inputtable:addRow(("info_weaponconfig" .. i .. "_ammo"), { bgColor = Helper.color.transparent })
					row[2]:createText((ReadText(1001, 2800) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx + indentsize })	-- Ammunition, :
					row[3]:setColSpan(11):createDropDown(dropdowndata, {startOption = currentammomacro, active = dropdownactive})
					row[3].handlers.onDropDownConfirmed = function(_, newammomacro) C.SetAmmoOfWeapon(gun, newammomacro) end
				elseif pilot and IsComponentClass(gun, "bomblauncher") then
					local numbombtypes = C.GetNumAllInventoryBombs(pilot)
					local bombstoragetable = ffi.new("AmmoData[?]", numbombtypes)
					numbombtypes = C.GetAllInventoryBombs(bombstoragetable, numbombtypes, pilot)

					local gunmacro = GetComponentData(gun, "macro")
					local dropdowndata = {}
					for j = 0, numbombtypes-1 do
						local ammomacro = ffi.string(bombstoragetable[j].macro)
						if C.IsAmmoMacroCompatible(gunmacro, ammomacro) then
							table.insert(dropdowndata, {id = ammomacro, text = GetMacroData(ammomacro, "name"), icon = "", displayremoveoption = false})
						end
					end

					-- if the ship has no compatible ammunition in ammo storage, have the dropdown print "Out of ammo" and make it inactive.
					local currentammomacro = "empty"
					local dropdownactive = true
					if #dropdowndata == 0 then
						dropdownactive = false
						table.insert(dropdowndata, {id = "empty", text = ReadText(1001, 9412), icon = "", displayremoveoption = false})	-- Out of ammo
					else
						-- NB: currentammomacro can be null
						currentammomacro = ffi.string(C.GetCurrentAmmoOfWeapon(gun))
					end

					row = inputtable:addRow(("info_weaponconfig" .. i .. "_ammo"), { bgColor = Helper.color.transparent })
					row[2]:createText((ReadText(1001, 2800) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx + indentsize })	-- Ammunition, :
					row[3]:setColSpan(11):createDropDown(dropdowndata, {startOption = currentammomacro, active = dropdownactive})
					row[3].handlers.onDropDownConfirmed = function(_, newammomacro) C.SetAmmoOfWeapon(gun, newammomacro) end
				end
			end
		end

		locrowdata = { "info_turretbehaviour", ReadText(1001, 8612) }	-- Turret Behaviour
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, isplayerowned and (#loadout.component.turret > 0))
		if isplayerowned and orig.menu.extendedinfo[ locrowdata[1] ] and #loadout.component.turret > 0 then
			orig.menu.turrets = {}
			local numslots = tonumber(C.GetNumUpgradeSlots(inputobject, "", "turret"))
			for j = 1, numslots do
				local groupinfo = C.GetUpgradeSlotGroup(inputobject, "", "turret", j)
				if (ffi.string(groupinfo.path) == "..") and (ffi.string(groupinfo.group) == "") then
					local current = C.GetUpgradeSlotCurrentComponent(inputobject, "turret", j)
					if current ~= 0 then
						table.insert(orig.menu.turrets, current)
					end
				end
			end

			orig.menu.turretgroups = {}
			local n = C.GetNumUpgradeGroups(inputobject, "")
			local buf = ffi.new("UpgradeGroup[?]", n)
			n = C.GetUpgradeGroups(buf, n, inputobject, "")
			for i = 0, n - 1 do
				if (ffi.string(buf[i].path) ~= "..") or (ffi.string(buf[i].group) ~= "") then
					local group = { path = ffi.string(buf[i].path), group = ffi.string(buf[i].group) }
					local groupinfo = C.GetUpgradeGroupInfo(inputobject, "", group.path, group.group, "turret")
					if (groupinfo.count > 0) then
						group.operational = groupinfo.operational
						group.currentmacro = ffi.string(groupinfo.currentmacro)
						group.slotsize = ffi.string(groupinfo.slotsize)
						table.insert(orig.menu.turretgroups, group)
					end
				end
			end

			if (#orig.menu.turrets > 0) or (#orig.menu.turretgroups > 0) then
				local turretmodes = {
					[1] = { id = "attackenemies",	text = ReadText(1001, 8614),	icon = "",	displayremoveoption = false },
					[2] = { id = "defend",			text = ReadText(1001, 8613),	icon = "",	displayremoveoption = false },
					[3] = { id = "mining",			text = ReadText(1001, 8616),	icon = "",	displayremoveoption = false },
					[4] = { id = "missiledefence",	text = ReadText(1001, 8615),	icon = "",	displayremoveoption = false },
					[5] = { id = "autoassist",		text = ReadText(1001, 8617),	icon = "",	displayremoveoption = false },
					[6] = { id = "holdfire",		text = ReadText(1041, 10157),	icon = "",	displayremoveoption = false },
				}

				local row = inputtable:addRow("info_turretconfig", { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(ReadText(1001, 2963))
				row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return orig.menu.getDropDownTurretModeOption(inputobject, "all") end })
				row[4].handlers.onDropDownConfirmed = function(_, newturretmode) orig.menu.noupdate = false; C.SetAllTurretModes(inputobject, newturretmode) end
				row[4].handlers.onDropDownActivated = function () orig.menu.noupdate = true end

				for i, turret in ipairs(orig.menu.turrets) do
					local row = inputtable:addRow("info_turretconfig" .. i, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(ffi.string(C.GetComponentName(turret)))
					row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return orig.menu.getDropDownTurretModeOption(turret) end })
					row[4].handlers.onDropDownConfirmed = function(_, newturretmode) orig.menu.noupdate = false; C.SetWeaponMode(turret, newturretmode) end
					row[4].handlers.onDropDownActivated = function () orig.menu.noupdate = true end
				end

				for i, group in ipairs(orig.menu.turretgroups) do
					local row = inputtable:addRow("info_turretgroupconfig" .. i, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(ReadText(1001, 8023) .. " " .. i .. ((group.currentmacro ~= "") and (" (" .. orig.menu.getSlotSizeText(group.slotsize) .. " " .. GetMacroData(group.currentmacro, "shortname") .. ")") or ""), { color = (group.operational > 0) and Helper.color.white or Helper.color.red })
					row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return orig.menu.getDropDownTurretModeOption(inputobject, group.path, group.group) end, active = group.operational > 0 })
					row[4].handlers.onDropDownConfirmed = function(_, newturretmode) orig.menu.noupdate = false; C.SetTurretGroupMode(inputobject, group.path, group.group, newturretmode) end
					row[4].handlers.onDropDownActivated = function () orig.menu.noupdate = true end
				end
			end
		end

		local showloadout = defenceinfo_high and (#loadout.component.weapon > 0 or #loadout.component.turret > 0 or #loadout.component.shield > 0 or #loadout.component.engine > 0 or #loadout.macro.thruster > 0 or #loadout.ware.software > 0)
		locrowdata = { "Loadout", ReadText(1001, 9413) }	-- Loadout
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, showloadout)
		if showloadout and orig.menu.extendedinfo[locrowdata[1]] then
			if #loadout.component.weapon > 0 then
				locrowdata = { "Weapons", ReadText(1001, 1301) }	-- Weapons
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.weapon)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.turret > 0 then
				locrowdata = { "Turrets", ReadText(1001, 1319) }	-- Turrets
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.turret)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.shield > 0 then
				locrowdata = { "Shield Generators", ReadText(1001, 1317) }	-- Shield Generators
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.shield)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.engine > 0 then
				locrowdata = { "Engines", ReadText(1001, 1103) }	-- Engines
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.engine)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.macro.thruster > 0 then
				locrowdata = { "Thrusters", ReadText(1001, 8001) }	-- Thrusters
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					-- ships normally only have 1 set of thrusters. in case a ship has more, this will list all of them.
					for i, val in ipairs(loadout.macro.thruster) do
						locrowdata = { false, GetMacroData(val, "name") }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.ware.software > 0 then
				locrowdata = { "Software", ReadText(1001, 87) }	-- Software
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					for i, val in ipairs(loadout.ware.software) do
						locrowdata = { false, GetWareData(val, "name") }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
		end
		--print("numweapons: " .. tostring(#loadout.component.weapon) .. ", numturrets: " .. tostring(#loadout.component.turret) .. ", numshields: " .. tostring(#loadout.component.shield) .. ", numengines: " .. tostring(#loadout.component.engine) .. ", numthrusters: " .. tostring(#loadout.macro.thruster) .. ", numsoftware: " .. tostring(#loadout.ware.software))
		--[[
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata] then
			for datatype, content in pairs(loadout) do
				for category, subtable in pairs(content) do
					if #subtable > 0 then
						locrowdata = tostring(category)
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, (#subtable > 0 and true or false), 1, indentsize)
						if orig.menu.extendedinfo[locrowdata] then
							--print("category: " .. tostring(category) .. ", subtable: " .. tostring(subtable) .. ", numentries: " .. tostring(#subtable))
							for key, val in pairs(subtable) do
								--print("type of val: " .. type(val))
								-- software: ware (string), virtual: macro (string), else: componentid (cdata)
								if datatype == "component" then
									locrowdata = ffi.string(C.GetComponentName(val))
								elseif datatype == "macro" then
									locrowdata = GetMacroData(val, "name")
								elseif datatype == "ware" then
									locrowdata = GetWareData(val, "name")
								else
									locrowdata = ""
									print("ERROR: menu_map function orig.menu.setupInfoSubmenuRows(): unhandled datatype: " .. tostring(datatype))
								end
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
								--print("key: " .. tostring(key) .. ", val: " .. tostring(val))
							end
						end
					end
				end
			end
		end
		]]
		-- mods
		locrowdata = { "EquipmentMods", ReadText(1001, 8031) }
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, equipment_mods and GetComponentData(object64, "hasanymod"))
		if equipment_mods and orig.menu.extendedinfo[locrowdata[1]] then
			-- chassis
			local hasinstalledmod, installedmod = Helper.getInstalledModInfo("ship", inputobject)
			if hasinstalledmod then
				locrowdata = { ("EquipmentModsChassis"), ReadText(1001, 8008), installedmod.Name }
				row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "ship", installedmod, false, true, true, 1, indentsize)
			end
			-- weapon
			for i, weapon in ipairs(loadout.component.weapon) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("weapon", weapon)
				if hasinstalledmod then
					locrowdata = { ("EquipmentModsWeapon" .. i), ffi.string(C.GetComponentName(weapon)), installedmod.Name }
					row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "weapon", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- turret
			for i, turret in ipairs(loadout.component.turret) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("turret", turret)
				if hasinstalledmod then
					locrowdata = { ("EquipmentModsTurret" .. i), ffi.string(C.GetComponentName(turret)), installedmod.Name }
					row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "weapon", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- shield
			local shieldgroups = {}
			local n = C.GetNumShieldGroups(inputobject)
			local buf = ffi.new("ShieldGroup[?]", n)
			n = C.GetShieldGroups(buf, n, inputobject)
			for i = 0, n - 1 do
				local entry = {}
				entry.context = buf[i].context
				entry.group = ffi.string(buf[i].group)
				entry.component = buf[i].component

				table.insert(shieldgroups, entry)
			end
			for i, entry in ipairs(shieldgroups) do
				if (entry.context == inputobject) and (entry.group == "") then
					shieldgroups.hasMainGroup = true
					-- force maingroup to first index
					table.insert(shieldgroups, 1, entry)
					table.remove(shieldgroups, i + 1)
					break
				end
			end
			for i, shieldgroupdata in ipairs(shieldgroups) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("shield", inputobject, shieldgroupdata.context, shieldgroupdata.group)
				if hasinstalledmod then
					local name = GetMacroData(GetComponentData(ConvertStringTo64Bit(tostring(shieldgroupdata.component)), "macro"), "name")
					if (i == 1) and shieldgroups.hasMainGroup then
						name = ReadText(1001, 8044)
					end
					locrowdata = { ("EquipmentModsShield" .. i), name, installedmod.Name }
					row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "shield", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- engine
			local hasinstalledmod, installedmod = Helper.getInstalledModInfo("engine", inputobject)
			if hasinstalledmod then
				locrowdata = { ("EquipmentModsEngine"), ffi.string(C.GetComponentName(loadout.component.engine[1])), installedmod.Name }
				row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "engine", installedmod, false, true, true, 1, indentsize)
			end
		end
	elseif mode == "station" then
		local buildstorage = ConvertIDTo64Bit(GetComponentData(inputobject, "buildstorage"))

		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(8):setBackgroundColSpan(5):createText(objectname, Helper.headerRow1Properties)
		row[1].properties.color = titlecolor
		row[9]:setColSpan(5):createText(Helper.unlockInfo(nameinfo, ffi.string(C.GetObjectIDCode(inputobject))), Helper.headerRow1Properties)
		row[9].properties.halign = "right"
		row[9].properties.color = titlecolor

		if isplayerowned then
			local playercash = GetPlayerMoney()

			local cashcontainers = {inputobject, buildstorage}
			for i, container in ipairs(cashcontainers) do
				local containercash = GetAccountData(container, "money") or 0
				local sliderstart = orig.menu.infocashtransferdetails[2][i] + containercash
				local slidermax = math.max((containercash + playercash), sliderstart)
				-- NB: money is not transferred to the player until after slider changes are confirmed so slidermaxselect can be greater than slidermax.
				-- orig.menu.infocashtransferdetails[2][3-i] relies on the current state where cashcontainers only contains two entries with indices 1 and 2.
				local slidermaxselect = math.min(math.max((containercash + playercash - orig.menu.infocashtransferdetails[2][3-i]), sliderstart), slidermax)
				local slidertext = (i == 1) and ReadText(1001, 7710) or ReadText(1001, 9429)		-- Station Account, Funds for Station Construction

				row = inputtable:addRow("info_stationaccount" .. i, { bgColor = Helper.color.transparent })
				row[2]:setColSpan(12):createSliderCell({
					height = config.mapRowHeight,
					start = sliderstart, 
					min = math.min(containercash, 0),
					max = slidermax,
					maxSelect = slidermaxselect,
					suffix = ReadText(1001, 101) }):setText(slidertext, { fontsize = config.mapFontSize })

				row[2].handlers.onSliderCellChanged = function(_, value) 
					local idx = i
					local loccash = containercash
					return orig.menu.infoSubmenuUpdateTransferAmount(value, idx, loccash) end
				row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
				row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end
				row[2].handlers.onSliderCellConfirm = function() orig.menu.over = true end
			end

			row = inputtable:addRow("info_updateaccount", { bgColor = Helper.color.transparent })
			row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocashtransferdetails[2][1] ~= 0) or (orig.menu.infocashtransferdetails[2][2] ~= 0)) and true or false end }):setText(ReadText(1001, 2821), { halign = "center", fontsize = config.mapFontSize })	-- Confirm
			row[4].handlers.onClick = function() return orig.menu.infoSubmenuUpdateManagerAccount(inputobject, buildstorage) end
			row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocashtransferdetails[2][1] ~= 0) or (orig.menu.infocashtransferdetails[2][2] ~= 0)) and true or false end }):setText(ReadText(1001, 64), { halign = "center", fontsize = config.mapFontSize })	-- Cancel
			row[9].handlers.onClick = function() return orig.menu.resetInfoSubmenu() end
		end

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: orig.menu.infoeditname cleared at the end of this function.
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight}):setText(editname)
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(object64, "sector") }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local radarrange = defenceinfo_low and (Helper.round(GetComponentData(object64, "maxradarrange")) / 1000) or unknowntext
			locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9414), (GetComponentData(object64, "tradesubscription") and ReadText(1001, 2617) or ReadText(1001, 2618)) }	-- Updating Trade Offers
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			-- TODO: enable if boarding of stations is ever implemented.
			--[[
			local boardingresistance = 0
			if C.IsComponentClass(inputobject, "station") then
				boardingresistance = tostring(GetComponentData(inputobject, "boardingresistance"))
			end
			local printedboardingresistance = defenceinfo_high and boardingresistance or unknowntext
			locrowdata = { false, ReadText(1001, 1324), printedboardingresistance }	-- Boarding Resistance
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			]]
		end

		locrowdata = { "Personnel", ReadText(1001, 9400) }	-- Personnel
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local manager = GetComponentData(inputobject, "tradenpc")
			locrowdata = { "Manager", (manager and GetComponentData(manager, "isfemale") and ReadText(20208, 30302) or ReadText(20208, 30301)) }	-- Manager (female), Manager (male)
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, manager and true or false, 1, indentsize)
			if manager and orig.menu.extendedinfo[locrowdata[1]] then
				manager = ConvertIDTo64Bit(manager)
				local name = GetComponentData(manager, "name")
				local printedname = operatorinfo and tostring(name) or unknowntext
				local skilltable = GetComponentData(manager, "skills")
				locrowdata = operatorinfo and { "info_manager", manager, inputobject } or { "info_manager_unknown" }
				local indent = 2 * indentsize
				row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
				row[2]:setColSpan(12):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
				table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)

				if (manager ~= C.GetPlayerID()) then
					for _, subtable in ipairs(skilltable) do
						local skillname = ReadText(1013, subtable.textid)
						local printedskill = operatorinfo_details and Helper.displaySkill(subtable.value) or unknowntext
						row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (subtable.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
						--row[2]:setColSpan(7):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (subtable.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
						local locfont = inputfont
						local locfontcolor = Helper.standardColor
						if operatorinfo_details then
							locfontcolor = Helper.color.brightyellow
						end
						row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
						--row[9]:setColSpan(5):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
						--row = orig.menu.addInfoSubmenuRow(inputtable, row, { }, false, false, false, 3, indentsize)
					end
				end

				if isplayerowned then
					local recommendedfunds = GetComponentData(inputobject, "productionmoney")
					locrowdata = { "info_station_recommendedfunds", (ReadText(1001, 9434) .. ReadText(1001, 120)), ConvertMoneyString(recommendedfunds, false, true, nil, true) .. " " .. ReadText(1001, 101) }	-- Expected operating budget, :, Cr
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

					local traderestrictions = GetTradeRestrictions(inputobject)
					row = inputtable:addRow("RestrictTrade", { bgColor = Helper.color.transparent })
					row[1]:createCheckBox(traderestrictions.faction, { scaling = false, width = config.mapRowHeight, height = config.mapRowHeight, x = config.mapRowHeight + (2 * Helper.scaleX(indentsize)) })
					row[2]:setColSpan(12):createText(ReadText(1001, 4202), { fontsize = config.mapFontSize, x = Helper.standardTextOffsetx + (config.mapRowHeight * 2) + (3 * indentsize) })	-- Restrict trade to other factions
					row[1].handlers.onClick = function() return orig.menu.checkboxInfoSubmenuRestrictTrade(object64) end
				end
			end

			local shiptrader = GetComponentData(inputobject, "shiptrader")
			if shiptrader then
				shiptrader = ConvertIDTo64Bit(shiptrader)
				locrowdata = { "Ship Trader", (GetComponentData(shiptrader, "isfemale") and ReadText(20208, 30502) or ReadText(20208, 30501)) }	-- Ship Trader (female), Ship Trader (male)
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local name = GetComponentData(shiptrader, "name")
					local printedname = operatorinfo and tostring(name) or unknowntext
					locrowdata = operatorinfo and { "info_shiptrader", shiptrader, inputobject } or { "info_shiptrader_unknown" }
					local indent = 2 * indentsize
					row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(12):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
				end
			end

			-- can query: .current, .capacity, .optimal, .available, .maxavailable
			local workforceinfo = C.GetWorkForceInfo(inputobject, "")
			local printedcapacity = operatorinfo and tostring(workforceinfo.capacity) or unknowntext
			local printednumpeople = operatorinfo and tostring(workforceinfo.current) or unknowntext
			locrowdata = {"Work Force", ReadText(1001, 9415), (printednumpeople .. " / " .. printedcapacity)}	-- Workforce
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (operatorinfo and workforceinfo.current > 0) and true or false, 1, indentsize)
			if operatorinfo and orig.menu.extendedinfo[locrowdata[1]] then
				workforceinfo = C.GetWorkForceInfo(inputobject, "argon")
				locrowdata = {false, ReadText(20202, 101), workforceinfo.current}	-- Argon
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "boron")
				--locrowdata = {false, ReadText(20202, 201), workforceinfo.current}	-- Boron
				--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				workforceinfo = C.GetWorkForceInfo(inputobject, "paranid")
				locrowdata = {false, ReadText(20202, 401), workforceinfo.current}	-- Paranid
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "split")
				--locrowdata = {false, ReadText(20202, 301), workforceinfo.current}	-- Split
				--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				workforceinfo = C.GetWorkForceInfo(inputobject, "teladi")
				locrowdata = {false, ReadText(20202, 501), workforceinfo.current}	-- Teladi
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "terran")
				--locrowdata = {false, ReadText(20202, 701), workforceinfo.current}	-- Terran
				--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
			end

			local npctable = GetNPCs(inputobject)
			for i = #npctable, 1, -1 do
				if not GetComponentData(npctable[i], "isplayerowned") then
					table.remove(npctable, i)
				end
			end
			locrowdata = { "Player Employees Onboard", ReadText(1001, 9416), #npctable }	-- Player Employees On Board
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (#npctable > 0 and true or false), 1, indentsize)
			if orig.menu.extendedinfo[locrowdata[1]] then
				for i, npc in ipairs(npctable) do
					locrowdata = { "info_npconboard", ConvertIDTo64Bit(npc), inputobject }
					local indent = 2 * indentsize
					row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(GetComponentData(npc, "name"), { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
					row[4]:setColSpan(10):createText(GetComponentData(npc, "ownername"), { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
				end
			end
		end

		-- insert build storage details
		local storagemodules = GetStorageData(buildstorage)
		local cargotable = {}
		local numwares = 0
		local sortedwarelist = {}
		for _, storagemodule in ipairs(storagemodules) do
			for _, ware in ipairs(storagemodule) do
				table.insert(sortedwarelist, ware)
			end
		end
		table.sort(sortedwarelist, function(a, b) return a.name < b.name end)
		for _, ware in ipairs(sortedwarelist) do
			table.insert(cargotable, { ware = ware.ware, amount = ware.amount })
			numwares = numwares + 1
		end
		--print("storageinfo_warelist: " .. tostring(storageinfo_warelist) .. " numwares > 0: " .. tostring(numwares > 0))
		--print("buildstorage: " .. ffi.string(C.GetComponentName(buildstorage)) .. " " .. tostring(buildstorage) .. " numwares: " .. tostring(numwares))
		locrowdata = { "info_station_buildstorage", ReadText(20104, 80101) }
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, storageinfo_warelist and (numwares > 0))
		if storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(buildstorage, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(buildstorage, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " (" .. GetComponentData(buildstorage, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " (" .. unknowntext .. "%)")) }	-- Hull
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local loccapacity = storageinfo_capacity and storagemodules.capacity or unknowntext
			local locamount = storageinfo_amounts and storagemodules.stored or unknowntext
			local printedcapacity = ConvertIntegerString(loccapacity, true, 1, true)
			local printedamount = ConvertIntegerString(locamount, true, 1, true)
			local printedfullamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 0, true) or nil
			local printedfullcapacity = (type(loccapacity) == "number") and ConvertIntegerString(loccapacity, true, 0, true) or nil
			local printednumwares = storageinfo_amounts and ConvertIntegerString(numwares, true, 0, true) or unknowntext
			locrowdata = { "info_station_buildstorage_storage", (ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"), (ReadText(1001, 1402) .. ReadText(1001, 120)), (storagemodules.estimated and unknowntext or (printedamount .. " / " .. printedcapacity .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (numwares > 0) and true or false, 1, indentsize, nil, printedfullamount and (printedfullamount .. " / " .. printedfullcapacity .. " " .. ReadText(1001, 110)) or nil)	-- m^3
			if orig.menu.extendedinfo[locrowdata[1]] then
				for _, wareentry in ipairs(cargotable) do
					local ware = wareentry.ware
					local amount = wareentry.amount
					locrowdata = { GetWareData(ware, "name"), amount }
					row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize })
				end
			end
		end

		local productiontable = {}
		local productionmodules = GetProductionModules(object64)
		for i, prodmod in ipairs(productionmodules) do
			-- can query: proddata.cycletime, proddata.estimated, proddata.productionmethod, proddata.state, proddata.remainingcycletime, proddata.remainingtime, proddata.cycleprogress, proddata.efficiency (table), proddata.products (table), proddata.sresources (table), proddata.presources (table)
			-- proddata.state == "empty" == no production
				-- proddata.efficiency[#].product, proddata.efficiency[#].cycle, proddata.efficiency[#].primary
				-- proddata.products: numbered: product (table), proddata.products.efficiency
					-- proddata.products[#].ware, proddata.products[#].name, proddata.products[#].amount, proddata.products[#].component, proddata.products[#].cycle
				-- proddata.sresources: proddata.sresources.efficiency (no production methods currently use secondary resources)
				-- proddata.presources: numbered: presource (table), proddata.presources.efficiency
					-- proddata.presources[#].ware, proddata.presources[#].name, proddata.presources[#].amount, proddata.presources[#].component, proddata.presources[#].cycle
			local proddata = GetProductionModuleData(prodmod)
			if proddata.state ~= "empty" then
				local methodindex = nil
				for j, productionmethod in ipairs(productiontable) do
					if productionmethod.productionmethod == proddata.productionmethod then
						methodindex = j
						break
					end
				end
				if methodindex then
					table.insert(productiontable[methodindex], { products = {}, primaryresources = {}, efficiency = proddata.products.efficiency, cycletime = proddata.cycletime, cycletimeremaining = proddata.remainingcycletime, modulename = GetComponentData(prodmod, "name"), moduleindex = i })
				else
					table.insert(productiontable, { productionmethod = proddata.productionmethod, [1] = { products = {}, primaryresources = {}, efficiency = proddata.products.efficiency, cycletime = proddata.cycletime, cycletimeremaining = proddata.remainingcycletime, modulename = GetComponentData(prodmod, "name"), moduleindex = i } })
					methodindex = #productiontable
				end

				for _, product in ipairs(proddata.products) do
					table.insert(productiontable[methodindex][#productiontable[methodindex]].products, { ware = product.ware, name = product.name, amount = product.amount, component = product.component, cycle = product.cycle })
				end
				for _, resource in ipairs(proddata.presources) do
					table.insert(productiontable[methodindex][#productiontable[methodindex]].primaryresources, { ware = resource.ware, name = resource.name, amount = resource.amount, component = resource.component, cycle = resource.cycle })
				end
			end
		end
		table.sort(productiontable, orig.menu.productionSorter)
		locrowdata = { "Production", ReadText(1001, 1600) }	-- Production
		-- switch next two commented-out lines below if we want to make the number of production modules available even if all other information is crossed out.
		--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (#productiontable > 0) and true or false)
		--if #productiontable > 0 and orig.menu.extendedinfo[locrowdata[1]] then
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, productioninfo_products and (#productiontable > 0) and true or false)
		if productioninfo_products and #productiontable > 0 and orig.menu.extendedinfo[locrowdata[1]] then
			for i, productionmethod in ipairs(productiontable) do
				for j, productionmodule in ipairs(productionmethod) do
					if #productionmodule.products > 0 then
						locrowdata = { ("Method" .. i .. "Module" .. j), productioninfo_products and (productionmodule.modulename .. " " .. j) or unknowntext }	-- Production
						-- switch next two commented-out lines below if we want to make the individual production module sections accessible even if all information is crossed out.
						--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 1, indentsize)
						--if orig.menu.extendedinfo[locrowdata[1]] then
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, productioninfo_products and true or false, 1, indentsize)
						if productioninfo_products and orig.menu.extendedinfo[locrowdata[1]] then
							locrowdata = { false, (ReadText(1001, 9418) .. ReadText(1001, 120)) }	-- Wares produced per cycle, :
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)






							for _, product in ipairs(productionmodule.products) do
								locrowdata = { false, productioninfo_products and tostring(product.name) or unknowntext, productioninfo_rate and tostring(product.cycle) or unknowntext }
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)
							end

							-- TODO: @Nick consider: make efficiency dynamic as well to reflect changes?
							locrowdata = { false, (ReadText(1001, 1602) .. ReadText(1001, 120)), (productioninfo_rate and (productionmodule.cycletimeremaining > 0 and math.floor(productionmodule.efficiency * 100) or 0) .. "%" or unknowntext) }	-- Efficiency, :
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)

							local formattedtime = ConvertTimeString(productionmodule.cycletime, "%h:%M:%S")
							locrowdata = { false, ReadText(1001, 9419), productioninfo_time and formattedtime or unknowntext }	-- Time per cycle, d, h, min, s
							--locrowdata = { false, "Time per cycle", Helper.timeDuration(productionmodule.cycletime) }
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							locrowdata = { false, ReadText(1001, 9420) }	-- Time until current cycle completion, d, h, min, s
							row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
							row[2]:setColSpan(7):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
							--row[9]:setColSpan(5):createText(function() return orig.menu.infoSubmenuUpdateProductionTime(object64, productionmodule.moduleindex) end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont) })
							row[9]:setColSpan(5):createText(function() return productioninfo_rate and orig.menu.infoSubmenuUpdateProductionTime(object64, productionmodule.moduleindex) or unknowntext end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })
							--locrowdata = { false, "Time until current cycle completion", function() return Helper.timeDuration(productionmodule.cycletimeremaining) end }
							--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							locrowdata = { false, (ReadText(1001, 9421) .. ReadText(1001, 120)) }	--Resources needed per cycle, :
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							for _, resource in ipairs(productionmodule.primaryresources) do
								locrowdata = { false, productioninfo_resources and tostring(resource.name) or unknowntext, productioninfo_rate and tostring(resource.cycle) or unknowntext }
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)
							end
						end
					end
				end
			end
		end

		local products = {}
		local resources = {}
		for _, productionmethod in ipairs(productiontable) do
			for _, productionmodule in ipairs(productionmethod) do
				for _, product in ipairs(productionmodule.products) do
					-- can query: product.name, product.amount, product.component, product.cycle, product.ware
					if not products[product.ware] then
						--print("products. inserting " .. product.name)
						products[product.ware] = product
						products[product.ware].listed = false
					end
				end
				for _, resource in ipairs(productionmodule.primaryresources) do
					-- can query: resource.name, resource.amount, resource.component, resource.cycle, resource.ware
					if not resources[resource.ware] then
						--print("resources. inserting " .. resource.name)
						resources[resource.ware] = resource
						resources[resource.ware].listed = false
					end
				end
			end
		end
		storagemodules = {capacity = 0, stored = 0}
		if C.IsComponentClass(inputobject, "container") then
			storagemodules = GetStorageData(inputobject)
		end
		cargotable = { products = {text = ReadText(1001, 1610), numcatwares = 0, wares = {}}, resources = {text = ReadText(1001, 41), numcatwares = 0, wares = {}}, storage = {text = ReadText(1001, 1400), numcatwares = 0, wares = {}} }	-- Products, Resources, Storage
		local cargocatindex = { "products", "resources", "storage" }
		numwares = 0
		local sortedwarelist = {}
		-- numbered: ware (see below); storagemodule.name, storagemodule.consumption, storagemodule.stored, storagemodule.capacity
		for _, storagemodule in ipairs(storagemodules) do
			--print("storage module: " .. tostring(storagemodule.name) .. ", consumption: " .. tostring(storagemodule.consumption) .. ", stored: " .. tostring(storagemodule.stored) .. ", capacity: " .. tostring(storagemodule.capacity))
			-- can query: ware.ware, ware.name, ware.amount, ware.consumption, ware.volume
			for _, ware in ipairs(storagemodule) do
				--print("sortedwarelist. inserting stored ware: " .. ware.name)
				table.insert(sortedwarelist, ware)
				if resources[ware.ware] then
					--print("resource: " .. ware.name .. " is already listed.")
					resources[ware.ware].listed = true
				end
				if products[ware.ware] then
					--print("product: " .. ware.name .. " is already listed.")
					products[ware.ware].listed = true
				end
			end
		end
		for _, resource in pairs(resources) do
			if not resource.listed then
				--print("sortedwarelist. inserting resource: " .. resource.name)
				table.insert(sortedwarelist, resource)
			end
		end
		for _, product in pairs(products) do
			if not product.listed then
				--print("sortedwarelist. inserting product: " .. product.name)
				table.insert(sortedwarelist, product)
			end
		end
		table.sort(sortedwarelist, function(a, b) return a.name < b.name end)

		for _, ware in ipairs(sortedwarelist) do
			--print("ware: " .. tostring(ware) .. " " .. tostring(ware.name))
			local usage = "storage"
			if products[ware.ware] then
				usage = "products"
			elseif resources[ware.ware] then
				usage = "resources"
			end
			table.insert(cargotable[usage].wares, { ware = ware.ware, amount = ware.amount })
			cargotable[usage].numcatwares = cargotable[usage].numcatwares + 1
			numwares = numwares + 1
			--print("ware: " .. tostring(ware.name) .. ", usage: " .. usage .. ", consumption: " .. tostring(ware.consumption))
		end
		--print("estimated: " .. tostring(storagemodules.estimated) .. ", productionestimated: " .. tostring(storagemodules.productionestimated))
		local loccapacity = (storagemodules.capacity > 0) and storagemodules.capacity or 0
		local locamount = storageinfo_amounts and storagemodules.stored or unknowntext
		local printedcapacity = ConvertIntegerString(loccapacity, true, 1, true)
		local printedamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 1, true) or locamount
		local printedfullamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 0, true) or nil
		local printedfullcapacity = (type(loccapacity) == "number") and ConvertIntegerString(loccapacity, true, 0, true) or nil
		local printednumwares = storageinfo_amounts and ConvertIntegerString(numwares, true, 0, true) or unknowntext
		locrowdata = { "Storage", (ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"), (ReadText(1001, 1402) .. ReadText(1001, 120)), (storagemodules.estimated and unknowntext or (printedamount .. " / " .. printedcapacity .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (storageinfo_warelist and numwares > 0) and true or false, nil, nil, nil, printedfullamount and (printedfullamount .. " / " .. printedfullcapacity .. " " .. ReadText(1001, 110)) or nil)	-- m^3
		if storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			for i, usagecat in ipairs(cargocatindex) do
				if (cargotable[usagecat].numcatwares > 0) then
					--print("adding category: " .. cargotable[usagecat].text)
					locrowdata = { false, (cargotable[usagecat].text .. ReadText(1001, 120)) }	-- :
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata)
					for _, wareentry in ipairs(cargotable[usagecat].wares) do
						local ware = wareentry.ware
						local amount = wareentry.amount
						--print("ware: " .. tostring(ware) .. ", amount: " .. tostring(amount))
						locrowdata = { GetWareData(ware, "name"), amount }
						local printedwarecapacity = GetWareProductionLimit(inputobject, ware)
						if (printedwarecapacity < 1) or (printedwarecapacity < amount) then
							printedwarecapacity = amount
						end
						row = inputtable:addRow(true, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount, max = printedwarecapacity, readOnly = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize })
					end
				end
			end
		end

		local numdockedships = 0
		if C.IsComponentClass(inputobject, "container") then
			numdockedships = C.GetNumDockedShips(inputobject, nil)
		end
		locrowdata = { "info_dockedships", ReadText(1001, 3265) }
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, numdockedships > 0 and true or false)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local dockedships = ffi.new("UniverseID[?]", numdockedships)
			numdockedships = C.GetDockedShips(dockedships, numdockedships, inputobject, nil)
			local playerowneddockedships = {}
			local npcowneddockedships = {}
			for i = 0, numdockedships-1 do
				local locship = ConvertStringTo64Bit(tostring(dockedships[i]))
				if GetComponentData(locship, "isplayerowned") then
					table.insert(playerowneddockedships, locship)
				else
					table.insert(npcowneddockedships, locship)
				end
			end
			table.sort(playerowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)
			table.sort(npcowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)

			--local totaldockedships = 0
			for i, shipid in ipairs(playerowneddockedships) do
				local shipname = ffi.string(C.GetComponentName(shipid))
				local iconid = GetComponentData(shipid, "icon")
				if iconid and iconid ~= "" then
					shipname = string.format("\027[%s] %s", iconid, shipname)
				end
				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				--row = inputtable:addRow(("info_dockedship" .. i), { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(shipname, { color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
				row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
				--totaldockedships = i
			end
			for i, shipid in ipairs(npcowneddockedships) do
				local shipname = ffi.string(C.GetComponentName(shipid))
				local iconid = GetComponentData(shipid, "icon")
				if iconid and iconid ~= "" then
					shipname = string.format("\027[%s] %s", iconid, shipname)
				end
				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				--row = inputtable:addRow(("info_dockedship" .. totaldockedships+i), { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(shipname, { x = Helper.standardTextOffsetx + indentsize })
				row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", x = Helper.standardTextOffsetx + indentsize })
			end
		end

		local nummissiletypes = C.GetNumAllMissiles(inputobject)
		local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes)
		nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject)
		local totalnummissiles = 0
		for i = 0, nummissiletypes - 1 do
			totalnummissiles = totalnummissiles + missilestoragetable[i].amount
		end
		local missilecapacity = 0
		if C.IsComponentClass(inputobject, "defensible") then
			missilecapacity = GetComponentData(inputobject, "missilecapacity")
		end
		local locmissilecapacity = defenceinfo_low and tostring(missilecapacity) or unknowntext
		local locnummissiles = defenceinfo_high and tostring(totalnummissiles) or unknowntext
		locrowdata = { "Ammunition", ReadText(1001, 2800), (locnummissiles .. " / " .. locmissilecapacity) }	-- Ammunition
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnummissiles > 0) and true or false)
		if defenceinfo_high and orig.menu.extendedinfo[locrowdata[1]] then
			for i = 0, nummissiletypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(missilestoragetable[i].macro), "name"), (tostring(missilestoragetable[i].amount) .. " / " .. tostring(missilestoragetable[i].capacity)) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end

		local unitstoragetable = {capacity = 0, stored = 0}
		if C.IsComponentClass(inputobject, "defensible") then
			unitstoragetable = GetUnitStorageData(inputobject)
		end
		local locunitcapacity = unitinfo_capacity and tostring(unitstoragetable.capacity) or unknowntext
		local locunitcount = unitinfo_capacity and tostring(unitstoragetable.stored) or unknowntext
		locrowdata = {"Drones", ReadText(1001, 8), (locunitcount .. " / " .. locunitcapacity)}	-- Drones
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (unitinfo_details and unitstoragetable.stored > 0) and true or false)
		if unitinfo_details and orig.menu.extendedinfo[locrowdata[1]] then
			for i = 1, #unitstoragetable do
				if unitstoragetable[i].amount > 0 or unitstoragetable[i].unavailable > 0 then
					locrowdata = { false, unitstoragetable[i].name, (unitstoragetable[i].amount .. " / " .. unitstoragetable.capacity .. " (" .. unitstoragetable[i].unavailable .. " Unavailable)") }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end
		end

		local showloadout = defenceinfo_high and (#loadout.component.turret > 0 or #loadout.component.shield > 0)
		locrowdata = { "Loadout", ReadText(1001, 9413) }	-- Loadout 
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, showloadout)
		if showloadout and orig.menu.extendedinfo[locrowdata[1]] then
			if #loadout.component.turret > 0 then
				locrowdata = { "Turrets", ReadText(1001, 1319) }	-- turrets
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.turret)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.shield > 0 then
				locrowdata = { "Shield Generators", ReadText(1001, 1317) }	-- Shield Generators
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.shield)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
		end

		-- TODO: figure out and implement economy statistics
		locrowdata = { "Economy Statistics", ReadText(1001, 1131) }	-- Economy Statistics
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, false)

	elseif mode == "sector" then
		--print("sector ID: " .. tostring(inputobject))
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)
		row[1].properties.color = titlecolor

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight}):setText(editname)
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local stationtable = GetContainedStations(object64, true)
			local numstations = #stationtable
			local productiontable = {}
			local products = {}
			local sectorpopulation = 0
			for _, station in ipairs(stationtable) do
				local workforceinfo = C.GetWorkForceInfo(ConvertStringTo64Bit(tostring(station)), "")
				sectorpopulation = sectorpopulation + workforceinfo.current
				table.insert(productiontable, GetComponentData(station, "products"))
			end
			for _, entry in ipairs(productiontable) do
				for _, product in ipairs(entry) do
					local notincremented = true
					for compproduct, count in pairs(products) do
						if compproduct == product then
							products[product] = count + 1
							notincremented = false
							break
						end
					end
					if notincremented then
						products[product] = 1
					end
				end
			end
			local maxproductgrp = ReadText(1001, 9002)	-- Unknown
			local maxcount = 0
			for product, count in pairs(products) do
				if not maxproductgrp or (count > maxcount) then
					maxproductgrp = GetWareData(product, "groupName")
					maxcount = count
				end
			end

			-- TODO: review. currently looks at total known station workforce in the sector.
			locrowdata = { false, ReadText(1001, 9041), sectorpopulation }	-- Population
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9042), (numstations > 0 and numstations or 0) }	-- Known Stations
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9050), maxproductgrp }	-- Main Production
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end

		locrowdata = { "Natural Resources", ReadText(1001, 9423) }	-- Natural Resources
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local sunlight = (GetComponentData(object64, "sunlight") * 100 .. "%")
			locrowdata = { false, ReadText(1001, 2412), sunlight }	-- Sunlight
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			-- TODO: Add Region info: NB: Matthias says that yield numbers for regions could be too big to be useful, and that retrieving that info is very inefficient. But we'll try when the function is up.

		end
	elseif mode == "gate" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local isgateactive = GetComponentData(object64, "isactive")
			local gatedestinationid
			local gatedestination = unknowntext
			if isgateactive then
				gatedestinationid = GetComponentData(GetComponentData(object64, "destination"), "sectorid")
				local gatedestinationid64 = ConvertStringTo64Bit(tostring(gatedestinationid))
				gatedestination = C.IsInfoUnlockedForPlayer(gatedestinationid64, "name") and ffi.string(C.GetComponentName(gatedestinationid64)) or unknowntext
			end
			locrowdata = { false, ReadText(1001, 3215), tostring(gatedestination) }	-- (gate) Destination
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local destinationowner = unknowntext
			if gatedestination ~= unknowntext then
				destinationowner = GetComponentData(gatedestinationid, "ownername")
			end
			locrowdata = { false, ReadText(1001, 9424), tostring(destinationowner) }	-- Destination Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9425), (isgateactive and ReadText(1001, 2617) or ReadText(1001, 2618)) }	-- Active, Yes, No
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end
	elseif mode == "deployable" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: orig.menu.infoeditname cleared at the end of this function.
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight}):setText(editname)
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(inputobject, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(inputobject, "sector") }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(inputobject, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local radarrange = defenceinfo_low and GetComponentData(inputobject, "maxradarrange") or unknowntext

			if C.IsComponentClass(orig.menu.infoSubmenuObject, "mine") then
				-- add if mines are made selectable in the map again:
				--	detonation output (s), tracking capability (s), friend/foe (s), proximity (s)
			elseif C.IsComponentClass(orig.menu.infoSubmenuObject, "resourceprobe") then
				if radarrange and radarrange ~= unknowntext then
					radarrange = Helper.round(radarrange / 1000)
				end
				locrowdata = { "info_radarrange", ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 9082)) }	-- Scannning Range, km
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			elseif C.IsComponentClass(orig.menu.infoSubmenuObject, "satellite") then
				if radarrange and radarrange ~= unknowntext then
					radarrange = Helper.round(radarrange / 1000)
				end
				locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end
	elseif mode == "missionboard" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(inputobject, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(inputobject, "sector") }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end
	elseif mode == "asteroid" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local rawlength = GetComponentData(inputobject, "length")
			local rawwidth = GetComponentData(inputobject, "width")
			local rawheight = GetComponentData(inputobject, "height")
			local loclength = ConvertIntegerString(rawlength, true, 0, true)
			local locwidth = ConvertIntegerString(rawwidth, true, 0, true)
			local locheight = ConvertIntegerString(rawheight, true, 0, true)
			locrowdata = { false, ReadText(1001, 9229), (loclength .. ReadText(1001, 107) .. " " .. ReadText(1001, 42) .. " " .. locwidth .. ReadText(1001, 107) .. " " .. ReadText(1001, 42) .. " " .. locheight .. ReadText(1001, 107)) }	-- TEMPTEXT, m, x
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local rawvolume = rawlength * rawwidth * rawheight
			local locvolume = ConvertIntegerString(rawvolume, true, 0, true)
			locrowdata = { false, ReadText(1001, 1407), (locvolume .. " " .. ReadText(1001, 110)) }	-- Volume, m^3
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local wares = GetComponentData(inputobject, "wares")
			local hasyield = false
			if wares then
				for _, ware in ipairs(wares) do
					if ware.amount > 0 then
						hasyield = true
						break
					end
				end

				if hasyield then
					locrowdata = { false, ReadText(1001, 3214) .. ReadText(1001, 120) }	-- Yield, :
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

					for i, ware in ipairs(wares) do
						if ware.amount > 0 then
							local warename = GetWareData(ware.ware, "name")
							locrowdata = { false, warename, ware.amount }
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
						end
					end
				end
			end
		end
	else
		DebugError("orig.menu.setupInfoSubmenuRows(): called with unsupported mode: " .. tostring(mode) .. ".")
	end

	if orig.menu.infoeditname then
		orig.menu.infoeditname = nil
	end
end
end

if GetVersionString() == "2.50 (337849)" then --Check for Tested Versions (otherwise this change will be omited for compatibility)
function utRenaming.setupInfoSubmenuRows(mode, inputtable, inputobject)
	local object64 = ConvertStringTo64Bit(tostring(inputobject))
	if not orig.menu.infocashtransferdetails or orig.menu.infocashtransferdetails[1] ~= inputobject then
		orig.menu.infocashtransferdetails = { inputobject, {0, 0} }

		orig.menu.infodrops = {}
		--print("resetting cash transfer details: " .. orig.menu.infocashtransferdetails[2][1])
	end
	if not orig.menu.infomacrostolaunch then
		orig.menu.infomacrostolaunch = { lasertower = nil, mine = nil, navbeacon = nil, resourceprobe = nil, satellite = nil }
	end

	local indentsize = Helper.standardIndentStep

	local loadout = {}
	if mode == "ship" or mode == "station" then
		loadout = { ["component"] = {}, ["macro"] = {}, ["ware"] = {} }
		for i, upgradetype in ipairs(Helper.upgradetypes) do
			if upgradetype.supertype == "macro" then
				loadout.component[upgradetype.type] = {}
				local numslots = 0
				if C.IsComponentClass(inputobject, "defensible") then
					numslots = tonumber(C.GetNumUpgradeSlots(inputobject, "", upgradetype.type))
				end
				for j = 1, numslots do
					local current = C.GetUpgradeSlotCurrentComponent(inputobject, upgradetype.type, j)
					if current ~= 0 then
						table.insert(loadout.component[upgradetype.type], current)
					end
				end
			elseif upgradetype.supertype == "virtualmacro" then
				loadout.macro[upgradetype.type] = {}
				local numslots = tonumber(C.GetNumVirtualUpgradeSlots(inputobject, "", upgradetype.type))
				for j = 1, numslots do
					local current = ffi.string(C.GetVirtualUpgradeSlotCurrentMacro(inputobject, upgradetype.type, j))
					if current ~= "" then
						table.insert(loadout.macro[upgradetype.type], current)
					end
				end
			elseif upgradetype.supertype == "software" then
				loadout.ware[upgradetype.type] = {}
				local numslots = C.GetNumSoftwareSlots(inputobject, "")
				local buf = ffi.new("SoftwareSlot[?]", numslots)
				numslots = C.GetSoftwareSlots(buf, numslots, inputobject, "")
				for j = 0, numslots - 1 do
					local current = ffi.string(buf[j].current)
					if current ~= "" then
						table.insert(loadout.ware[upgradetype.type], current)
					end
				end
			elseif upgradetype.supertype == "ammo" then
				loadout.macro[upgradetype.type] = {}
			end
		end
	end

	local isplayerowned = GetComponentData(object64, "isplayerowned")
	local titlecolor = Helper.color.white
	if isplayerowned then
		titlecolor = orig.menu.holomapcolor.playercolor
		if object64 == C.GetPlayerObjectID() then
			titlecolor = orig.menu.holomapcolor.currentplayershipcolor
		end
	end
	local unknowntext = ReadText(1001, 3210)
	local cheatsecrecy = false
	-- secrecy stuff
	local nameinfo =					cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "name")
	local ownerinfo =					cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "owner")
	local defenceinfo_low =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "defence_level")
	local defenceinfo_high =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "defence_status")
	local operatorinfo =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "operator_name")
	local operatorinfo_details =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "operator_details")
	local operatorinfo_commands =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "operator_commands")
	local productioninfo_products =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_products")
	local productioninfo_rate =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_rate")
	local productioninfo_resources =	cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_resources")
	local productioninfo_time =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "production_time")
	local storageinfo_capacity =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "storage_capacity")
	local storageinfo_amounts =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "storage_amounts")
	local storageinfo_warelist =		cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "storage_warelist")
	local unitinfo_capacity =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_capacity")
	local unitinfo_amount =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_amount")
	local unitinfo_details =			cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "units_details")
	local equipment_mods =				cheatsecrecy or C.IsInfoUnlockedForPlayer(inputobject, "equipment_mods")

	if not isplayerowned then
		orig.menu.extendedinfo["info_weaponconfig"] = nil
	end

	--- title ---
	local row = inputtable:addRow(false, {fixed = true, bgColor = Helper.defaultTitleBackgroundColor})
	row[1]:setColSpan(13):createText(ReadText(1001, 2427), Helper.headerRowCenteredProperties)

	local objectname = Helper.unlockInfo(nameinfo, ffi.string(C.GetComponentName(inputobject)))
	if mode == "ship" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(8):setBackgroundColSpan(13):createText(objectname, Helper.headerRow1Properties)
		row[1].properties.color = titlecolor
		row[9]:setColSpan(5):createText(Helper.unlockInfo(nameinfo, ffi.string(C.GetObjectIDCode(inputobject))), Helper.headerRow1Properties)
		row[9].properties.halign = "right"
		row[9].properties.color = titlecolor

		local pilot, isdocked = GetComponentData(inputobject, "assignedpilot", "isdocked")
		pilot = ConvertIDTo64Bit(pilot)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: orig.menu.infoeditname cleared at the end of this function.
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = editname}):setText(editname)
				row[4].handlers.onEditBoxActivated = function(_, inputtable, editname) return Helper.updateEditBoxText(inputtable,4,10,editname) end
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- "Owner"
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local loccontainer = nil
			if isdocked then
				loccontainer = ConvertStringTo64Bit(tostring(C.GetTopLevelContainer(inputobject)))
			end
			local objectlocid64 = ConvertStringTo64Bit(tostring(GetComponentData(object64, "sectorid")))
			local objectloc = C.IsInfoUnlockedForPlayer(objectlocid64, "name") and ffi.string(C.GetComponentName(objectlocid64)) or unknowntext
			if loccontainer then
				objectloc = ReadText(1001, 3248) .. " " .. ffi.string(C.GetComponentName(loccontainer)) .. ", " .. objectloc	-- Docked at
			end
			locrowdata = { false, ReadText(1001, 2943), objectloc }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local objecttype = C.IsInfoUnlockedForPlayer(inputobject, "name") and GetMacroData(GetComponentData(object64, "macro"), "name") or unknowntext
			locrowdata = { false, ReadText(1001, 94), objecttype }	-- Model
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local shield_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "shieldmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 2), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "shield")), true, 4, true, true, true) .. " / " .. shield_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "shieldpercent") .. "%)") end) or (unknowntext .. " / " .. shield_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9076), defenceinfo_low and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "maxunboostedforwardspeed") or 0), true, 0, true) .. " " .. ReadText(1001, 113)) end) or (unknowntext .. " " .. ReadText(1001, 113)) }	-- Cruising Speed, m/s
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local dpstable = ffi.new("DPSData[?]", 6)
			local hasturrets = (defenceinfo_low and #loadout.component.turret > 0) and true or false
			local numtotalquadrants = C.GetDefensibleDPS(dpstable, inputobject, true, true, true, true, hasturrets, false, false)
			if not hasturrets then
				locrowdata = { false, ReadText(1001, 9092), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(dpstable[0].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- Weapon Output, MW
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			else
				for i = 0, numtotalquadrants - 1 do
					locrowdata = { false, (ReadText(1001, 9092) .. " (" .. ReadText(20220, dpstable[i].quadranttextid) .. ")"), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(dpstable[i].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- Weapon Output, MW
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end

			local sustainedfwddps = ffi.new("DPSData[?]", 1)
			C.GetDefensibleDPS(sustainedfwddps, inputobject, true, true, true, true, false, true, false)
			if sustainedfwddps[0].dps > 0 then
				locrowdata = { false, ReadText(1001, 9093), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(sustainedfwddps[0].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- TEMPTEXT nick, MW
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			local radarrange = defenceinfo_low and ConvertIntegerString((Helper.round(GetComponentData(object64, "maxradarrange")) / 1000), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local shipcombinedskill = math.floor(C.GetShipCombinedSkill(inputobject) * 15 / 100)
			local printedshipcombinedskill = unknowntext
			local locfont = inputfont
			local locfontcolor = Helper.standardColor
			if operatorinfo_details then
				printedshipcombinedskill = Helper.displaySkill(shipcombinedskill)
				locfontcolor = Helper.color.brightyellow
			end
			locrowdata = { false, ReadText(1001, 9427), printedshipcombinedskill }	-- Crew Skill
			row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
			row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indentsize })
			row[4]:setColSpan(10):createText(locrowdata[3], { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })

			locrowdata = { false, ReadText(1001, 1325), defenceinfo_high and (function() return ConvertIntegerString(GetComponentData(object64, "boardingstrength") or 0, true, 0, true) end) or unknowntext }	-- Boarding Attack Strength
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end

		locrowdata = { "Personnel", ReadText(1001, 9400) }	-- Personnel
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local numorders = C.GetNumOrders(inputobject)
			local currentorders = ffi.new("Order[?]", numorders)
			local activeorder = ffi.new("Order")
			if numorders > 0 then
				numorders = C.GetOrders(currentorders, numorders, inputobject)
				activeorder = currentorders[0]
			else
				C.GetDefaultOrder(activeorder, inputobject)
			end
			local ordername = ""
			local orderdefinition = ffi.new("OrderDefinition")
			if activeorder.orderdef ~= nil and C.GetOrderDefinition(orderdefinition, activeorder.orderdef) then
				ordername = operatorinfo_commands and ffi.string(orderdefinition.name) or unknowntext
			end
			local objectlocid64 = ConvertStringTo64Bit(tostring(GetComponentData(object64, "sectorid")))
			local objectloc = (objectlocid64 ~= 0 and C.IsInfoUnlockedForPlayer(objectlocid64, "name")) and ffi.string(C.GetComponentName(objectlocid64)) or unknowntext
			local isbigship = C.IsComponentClass(inputobject, "ship_m") or C.IsComponentClass(inputobject, "ship_l") or C.IsComponentClass(inputobject, "ship_xl")
			local printedtitle = isbigship and ReadText(1001, 4848) or ReadText(1001, 4847)	-- Captain, Pilot
			local endcelltext = (numorders .. " " .. ReadText(1001, 9402))	-- Orders queued
			if numorders == 1 then
				endcelltext = (numorders .. " " .. ReadText(1001, 9401))	-- Order queued
			end
			numorders = operatorinfo_commands and tostring(numorders) or unknowntext
			locrowdata = { "Pilot", (printedtitle .. ReadText(1001, 120)), ordername, objectloc, endcelltext }	-- :
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (pilot or isplayerowned) and true or false, 1, indentsize)
			local printedpilotname = operatorinfo and (pilot and tostring(GetComponentData(pilot, "name")) or "") or unknowntext
			if (pilot or isplayerowned) and orig.menu.extendedinfo[locrowdata[1]] then
				if pilot then
					local adjustedskill = math.floor(C.GetEntityCombinedSkill(pilot, nil, "aipilot") * 15 / 100)
					local printedskill = operatorinfo_details and Helper.displaySkill(adjustedskill) or unknowntext
					local skilltable = GetComponentData(pilot, "skills")
					locrowdata = { { pilot, pilot, inputobject }, printedpilotname }
					if (pilot == C.GetPlayerID()) or not operatorinfo or C.IsUnit(inputobject) then
						locrowdata = { pilot, printedpilotname }
					end
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					local locfont = inputfont
					local locfontcolor = Helper.standardColor
					if operatorinfo_details then
						locfontcolor = Helper.color.brightyellow
					end
					row[2]:setColSpan(2)
					row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
					table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)

					if pilot ~= C.GetPlayerID() then
						locrowdata = { "PilotSkills", ReadText(1001, 1918) }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 2, indentsize)
						if orig.menu.extendedinfo[locrowdata[1]] then
							for _, skillproperties in ipairs(skilltable) do
								local skillname = ReadText(1013, skillproperties.textid)
								local adjustedskill = math.floor(skillproperties.value * 15 / 15)
								local printedskill = operatorinfo_details and Helper.displaySkill(adjustedskill) or unknowntext
								row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
								row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skillproperties.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
								local locfont = inputfont
								local locfontcolor = Helper.standardColor
								if operatorinfo_details then
									locfontcolor = Helper.color.brightyellow
								end
								row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
							end
							if isplayerowned then
								local line_replace = isbigship and ReadText(1001, 9430) or ReadText(1001, 9431)	-- Replace captain with best crewmember, Replace pilot with best crewmember
								row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
								row[2]:setColSpan(12):createText(line_replace, { x = Helper.standardTextOffsetx + 2 * Helper.standardIndentStep, minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })

								-- button is clickable if:
								-- we have crew,
								-- we have a pilot,
								-- the pilot is not in a critical state (NPC_State_Machines),
								-- the controllable is not running an order in a critical state,
								-- and one of our crew members is better than the current pilot.
								-- NB: check to see if there is a pilot is necessary since there is a delay between pressing this button and the old pilot getting dismissed leading to errors in the later checks.
								row = inputtable:addRow("ReplacePilot", { bgColor = Helper.color.transparent })
								row[2]:setColSpan(2):createButton({ x = 2 * Helper.standardIndentStep, height = config.mapRowHeight, active = function() locpilot = GetComponentData(inputobject, "assignedpilot") return ((orig.menu.infocrew.current.total > 0) and locpilot and not GetNPCBlackboard(locpilot, "$state_machine_critical") and not C.IsCurrentOrderCritical(inputobject) and orig.menu.infoSubmenuReplacePilot(inputobject, ConvertIDTo64Bit(locpilot), nil, true) and true or false) end }):setText(ReadText(1001, 57), { halign = "center", fontsize = config.mapFontSize })	-- Accept
								row[2].handlers.onClick = function() return orig.menu.infoSubmenuReplacePilot(inputobject, pilot) end
							end
						end
					end
					
					if isplayerowned then



						local inventory = GetInventory(pilot)
						if next(inventory) then
							local onlineitems = OnlineGetUserItems(false)
							local persistentonlineitems = OnlineGetUserItems(true)
							for k, v in pairs(persistentonlineitems) do
								onlineitems[k] = v
							end








							local sortedWares = {}
							for ware, entry in pairs(inventory) do
								local ispersonalupgrade = GetWareData(ware, "ispersonalupgrade")
								if (not ispersonalupgrade) and (not onlineitems[ware]) then
									table.insert(sortedWares, { ware = ware, name = entry.name, amount = entry.amount })
								end
							end
							if #sortedWares > 0 then
								table.sort(sortedWares, Helper.sortName)

								locrowdata = { "PilotInventory", ReadText(1001, 2202) }
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 2, indentsize)
								if orig.menu.extendedinfo[locrowdata[1]] then
									for i, entry in ipairs(sortedWares) do
										locrowdata = { "PilotInventory" .. i, entry.name, entry.amount }
										row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)
									end

									row = inputtable:addRow("DropPilotInventory", { bgColor = Helper.color.transparent })

									row[2]:setColSpan(2):createButton({ x = 2 * Helper.standardIndentStep, height = config.mapRowHeight }):setText(ReadText(1001, 7733), { halign = "center", fontsize = config.mapFontSize })
									row[2].handlers.onClick = function() return orig.menu.buttonDropPilotInventory(pilot, sortedWares) end
								end
							end
						end
					end
				else
					row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(7):createText(ReadText(1001, 9432) .. " " .. printedtitle, { x = Helper.standardTextOffsetx + 2 * Helper.standardIndentStep, minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })	-- Promote best crewmember to

					row = inputtable:addRow("ReplacePilot", { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createButton({ x = 2 * Helper.standardIndentStep, height = config.mapRowHeight, active = (orig.menu.infocrew.current.total > 0) and true or false }):setText(ReadText(1001, 57), { halign = "center", fontsize = config.mapFontSize })	-- Accept
					row[2].handlers.onClick = function() return orig.menu.infoSubmenuReplacePilot(inputobject, nil) end
				end
			end

			local peoplecapacity = C.GetPeopleCapacity(inputobject, "", false)
			local totalcrewcapacity = orig.menu.infocrew.capacity + 1
			local totalnumpeople = orig.menu.infocrew.total
			local aipilot = GetComponentData(inputobject, "assignedaipilot")
			if aipilot then
				aipilot = ConvertStringTo64Bit(tostring(aipilot))
				totalnumpeople = totalnumpeople + 1
			end
			local printedcapacity = operatorinfo and tostring(totalcrewcapacity) or unknowntext
			local printednumpeople = operatorinfo and tostring(totalnumpeople) or unknowntext
			locrowdata = { "Crew", ReadText(1001, 80), (printednumpeople .. " / " .. printedcapacity) }	-- Crew
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, ((operatorinfo and totalnumpeople > 0) and true or false), 1, indentsize)
			if operatorinfo and totalnumpeople > 0 and orig.menu.extendedinfo[locrowdata[1]] then
				-- pilot entry in crew sliders
				if pilot == C.GetPlayerID() and aipilot then
					printedtitle = ReadText(1001, 9403)	-- Relief Pilot
					printedpilotname = tostring(GetComponentData(aipilot, "name"))
				end
				locrowdata = { { "info_crewpilot", aipilot, inputobject }, (printedtitle .. " " .. printedpilotname), (((aipilot or pilot) and 1 or 0) .. " / " .. 1 ) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(13):createText("")

				locrowdata = ReadText(1001, 5207)	-- Unassigned
				local sliderrows = {}
				local slidercounter = 0
				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(locrowdata, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (2 * indentsize) })
				row[4]:setColSpan(10):createText(function() return ("(" .. tostring(orig.menu.infocrew.unassigned.total) .. ")") end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })
				local unassignedrow = row
				for i, roletable in ipairs(orig.menu.infocrew.current.roles) do
					if roletable.amount > 0 or roletable.canhire then
						slidercounter = slidercounter + 1
						-- can query: .id, .name, .desc, .amount, .numtiers, .canhire
						--{ 
						--	id = ffi.string(peopletable[i].id), 
						--	name = ffi.string(peopletable[i].name), 
						--	desc = ffi.string(peopletable[i].desc), 
						--	amount = peopletable[i].amount, 
						--	canhire = peopletable[i].canhire, 
						--	numtiers = peopletable[i].numtiers, 
						--	tiers = {} 
						--}
						locrowdata = ffi.string(roletable.id)
						row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
						--print("name: " .. ffi.string(roletable.name) .. ", canhire: " .. tostring(roletable.canhire))
						row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = roletable.amount + orig.menu.infocrew.reassigned.roles[i].amount, max = peoplecapacity, maxSelect = roletable.amount + orig.menu.infocrew.reassigned.roles[i].amount + orig.menu.infocrew.unassigned.total, x = Helper.standardTextOffsetx + (2 * indentsize), readOnly = not isplayerowned or not roletable.canhire }):setText(ffi.string(roletable.name), { fontsize = config.mapFontSize })
						sliderrows[slidercounter] = { ["row"] = row, ["roleindex"] = i,["id"] = roletable.id, ["name"] = roletable.name, ["desc"] = roletable.desc, ["amount"] = roletable.amount, ["numtiers"] = roletable.numtiers, ["canhire"] = roletable.canhire, ["tiers"] = {} }
			
						local numtiers = roletable.numtiers
						for j, tiertable in ipairs(roletable.tiers) do
							if not tiertable.hidden then
								-- can query: .name, .skilllevel, .amount
								--{ 
								--	name = ffi.string(tiertable[j].name), 
								--	skilllevel = tiertable[j].skilllevel, 
								--	amount = tiertable[j].amount, 
								--	persons = {} 
								--}
								--print("tier name: " .. ffi.string(tiertable.name) .. ", skill level: " .. tostring(tiertable.skilllevel) .. ", num: " .. tostring(tiertable.amount))
								locrowdata = (ffi.string(roletable.id) .. j)
								row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
								row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = tiertable.amount + orig.menu.infocrew.reassigned.roles[i].tiers[j].amount, max = peoplecapacity, maxSelect = tiertable.amount + orig.menu.infocrew.reassigned.roles[i].tiers[j].amount, x = Helper.standardTextOffsetx + (3 * indentsize), readOnly = not isplayerowned }):setText(ffi.string(tiertable.name), { fontsize = config.mapFontSize })
								sliderrows[slidercounter].tiers[j] = { ["row"] = row, ["roleindex"] = i, ["name"] = tiertable.name, ["skilllevel"] = tiertable.skilllevel, ["amount"] = tiertable.amount }
							end
						end
					end
				end
				if isplayerowned then
					row = inputtable:addRow("UpdateCrew", { bgColor = Helper.color.transparent })
					row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocrew.reassigned.total > 0) and (orig.menu.infocrew.unassigned.total == 0)) end }):setText(ReadText(1001, 2821), { halign = "center", fontsize = config.mapFontSize })	-- Confirm
					row[4].handlers.onClick = function() return orig.menu.infoSubmenuConfirmCrewChanges() end
					row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocrew.reassigned.total > 0) or (orig.menu.infocrew.unassigned.total > 0)) end }):setText(ReadText(1001, 3318), { halign = "center", fontsize = config.mapFontSize })	-- Reset
					row[9].handlers.onClick = function() return orig.menu.resetInfoSubmenu() end

					for i, role in ipairs(sliderrows) do

						-- TODO: cleanup these tables. not all data is used.
						local sliderupdatetable = { ["table"] = inputtable, ["row"] = role.row, ["col"] = 2, ["tierrows"] = {}, ["text"] = role.name, ["xoffset"] = role.row[2].properties.x, ["width"] = role.row[2].properties.width }
						for j, tier in ipairs(role.tiers) do
							table.insert(sliderupdatetable.tierrows, { ["row"] = tier.row, ["text"] = tier.name, ["xoffset"] = tier.row[2].properties.x, ["width"] = tier.row[2].properties.width })
						end

						role.row[2].handlers.onSliderCellChanged = function(_, newamount) return orig.menu.infoSubmenuUpdateCrewChanges(newamount, sliderrows, i, false, nil, sliderupdatetable) end
						role.row[2].handlers.onSliderCellConfirm = function() return orig.menu.refreshInfoFrame() end
						role.row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
						role.row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end
						for j, tier in ipairs(role.tiers) do
							tier.row[2].handlers.onSliderCellChanged = function(_, newamount) return orig.menu.infoSubmenuUpdateCrewChanges(newamount, sliderrows, i, true, j, sliderupdatetable) end
							tier.row[2].handlers.onSliderCellConfirm = function() return orig.menu.refreshInfoFrame() end
							tier.row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
							tier.row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end
						end
					end
				end

				locrowdata = { "Full Crew List", ReadText(1001, 9404) }	-- Full Crew List
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, operatorinfo_details, 2, indentsize)
				if operatorinfo_details and orig.menu.extendedinfo[locrowdata[1]] then
					-- pilot entry in full crew manifest
					locrowdata = { "PilotInFullCrew", printedtitle, "" }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, aipilot and true or false, 3, indentsize)
					if aipilot and orig.menu.extendedinfo[locrowdata[1]] then
						local name = GetComponentData(aipilot, "name")
						local printedname = operatorinfo and tostring(name) or unknowntext
						local adjustedcombinedskill = math.floor(GetComponentData(aipilot, "combinedskill") * 15 / 100)
						local extendinfoid = "info_crewpilot_full"
						local locrowdata = { "info_crewpilot_full", aipilot, inputobject }
						local printedskill = Helper.displaySkill(adjustedcombinedskill)
						local indent = 4 * indentsize
						row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(2):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
						row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, color = Helper.color.brightyellow })
						row[1]:createButton({ height = config.mapRowHeight }):setText(function() return orig.menu.extendedinfo[extendinfoid] and "-" or "+" end, { halign = "center" })
						row[1].handlers.onClick = function() return orig.menu.buttonExtendInfo(extendinfoid) end
						if orig.menu.extendedinfo[extendinfoid] then
							local skilltable = GetComponentData(aipilot, "skills")
							table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)
							for _, skillproperties in ipairs(skilltable) do
								local skillname = ReadText(1013, skillproperties.textid)
								local printedskill = operatorinfo_details and Helper.displaySkill(skillproperties.value) or unknowntext
								row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
								row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skillproperties.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (5 * indentsize) })
								local locfont = inputfont
								local locfontcolor = Helper.standardColor
								if operatorinfo_details then
									locfontcolor = Helper.color.brightyellow
								end
								row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
							end
						end
					end

					for i, roletable in ipairs(orig.menu.infocrew.current.roles) do
						if roletable.amount > 0 then
							locrowdata = { ("Role " .. i), tostring(roletable.name), tostring(roletable.amount) }
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (roletable.amount > 0) and true or false, 3, indentsize)
							if orig.menu.extendedinfo[locrowdata[1]] then
								for j, tiertable in ipairs(roletable.tiers) do
									if roletable.numtiers > 1 then
										locrowdata = { ("Role " .. i .. " Tier " .. j), tostring(tiertable.name), tostring(tiertable.amount) }
										row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (tiertable.amount > 0) and true or false, 4, indentsize)
									end
									if orig.menu.extendedinfo[locrowdata[1]] then
										for k, person in ipairs(tiertable.persons) do
											-- NB: adjusted to 5 points at the moment because more than 5 doesn't fit very comfortably in this orig.menu.
											local adjustedcombinedskill = math.floor(C.GetPersonCombinedSkill(inputobject, person, nil, nil) * 15 / 100)
											-- Note: extendinfoid and locrowdata[1] can be different - that wouldn't work when using orig.menu.addInfoSubmenuRow() though
											local extendinfoid = string.format("info_crewperson_r%d_t%d_p%d", i, j, k)
											local locrowdata = { "info_crewperson", person, inputobject }
											local printedname = ffi.string(C.GetPersonName(person, inputobject))
											local printedskill = Helper.displaySkill(adjustedcombinedskill)
											local indent = (roletable.numtiers > 1) and (5 * indentsize) or (4 * indentsize)
											row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
											row[2]:setColSpan(2):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
											row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, color = Helper.color.brightyellow })
											row[1]:createButton({ height = config.mapRowHeight }):setText(function() return orig.menu.extendedinfo[extendinfoid] and "-" or "+" end, { halign = "center" })
											row[1].handlers.onClick = function() return orig.menu.buttonExtendInfo(extendinfoid) end
											if orig.menu.extendedinfo[extendinfoid] then
												local numskills = C.GetNumSkills()
												local skilltable = ffi.new("Skill[?]", numskills + 1)
												numskills = C.GetPersonSkills(skilltable, person, inputobject)
												local sortedskilltable = {}
												for i = 1, numskills do
													table.insert(sortedskilltable, skilltable[i])
												end
												table.sort(sortedskilltable, function(a, b) return a.relevance > b.relevance end)
												for i, skill in ipairs(sortedskilltable) do
													local skillname = ReadText(1013, skill.textid)
													local indent = (roletable.numtiers > 1) and (6 * indentsize) or (5 * indentsize)
													local printedskill = Helper.displaySkill(skill.value)
													row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
													row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skill.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + indent })
													row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, color = Helper.color.brightyellow })
												end
											end
										end
									end
								end
							end
						end
					end
				end
			end
		end

		local storagemodules = GetStorageData(object64)
		local cargotable = {}
		local numwares = 0
		local sortedwarelist = {}
		local simplewarelist = {}
		for _, storagemodule in ipairs(storagemodules) do
			for _, ware in ipairs(storagemodule) do
				table.insert(sortedwarelist, ware)
				simplewarelist[ware.ware] = true
			end
		end

		local isresupplyship = GetComponentData(object64, "cansupplyships")
		if isresupplyship then
			local n = C.GetNumMaxProductionStorage(object64)
			local buf = ffi.new("UIWareAmount[?]", n)
			n = C.GetMaxProductionStorage(buf, n, object64)
			for i = 0, n - 1 do
				local locwareid = ffi.string(buf[i].wareid)
				if not simplewarelist[locwareid] then
					local locware = {}
					locware["ware"] = locwareid
					locware["name"], locware["volume"] = GetWareData(locwareid, "name", "volume")
					locware["amount"] = 0
					locware["consumption"] = buf[i].amount
					table.insert(sortedwarelist, locware)
					--print("inserting " .. tostring(locware.name) .. ". id: " .. tostring(locware.ware) .. ", name: " .. tostring(locware.name) .. ", amount: " .. tostring(locware.amount) .. ", volume: " .. tostring(locware.volume) .. ", consumption: " .. tostring(locware.consumption))
				end
			end
		end

		table.sort(sortedwarelist, function(a, b) return a.name < b.name end)
		for _, ware in ipairs(sortedwarelist) do
			table.insert(cargotable, { ware = ware.ware, amount = ware.amount })
			numwares = numwares + 1
		end
		local loccapacity = storageinfo_capacity and ConvertIntegerString(storagemodules.capacity, true, 0, true) or unknowntext
		local locamount = storageinfo_amounts and ConvertIntegerString(storagemodules.stored, true, 0, true) or unknowntext
		local printednumwares = storageinfo_amounts and tostring(numwares) or unknowntext
		locrowdata = { 
			"Storage", 
			(ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"),
			storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo["Storage"] and "" or (ReadText(1001, 1402) .. ReadText(1001, 120)), 
			storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo["Storage"] and "" or (storagemodules.estimated and unknowntext or (locamount .. " / " .. loccapacity .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (storageinfo_warelist and numwares > 0) and true or false)
		if storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			-- slider showing total filled capacity
			row = inputtable:addRow("info_storage_totalused", { bgColor = Helper.color.transparent })
			row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = storagemodules.stored, max = storagemodules.capacity, suffix = ReadText(1001, 110), readOnly = true }):setText((ReadText(1001, 1402) .. ReadText(1001, 120)), { fontsize = config.mapFontSize, color = Helper.standardColor })

			if isplayerowned then
				local numtrips = GetComponentData(object64, "numtrips")
				if numtrips > 0 then
					local cargoaftertrades = GetCargoAfterTradeOrders(object64, true)
					local totalvolume = 0
					for ware, amount in pairs(cargoaftertrades) do
						totalvolume = totalvolume + amount * GetWareData(ware, "volume")
					end


					row = inputtable:addRow("info_storage_future", { bgColor = Helper.color.transparent })
					row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = totalvolume, max = storagemodules.capacity, suffix = ReadText(1001, 110), readOnly = true }):setText((ReadText(1001, 8374) .. ReadText(1001, 120)), { fontsize = config.mapFontSize, color = Helper.standardColor })
				end
			end


			if isplayerowned then
				local stufftodrop = false
				for ware, numdrops in pairs(orig.menu.infodrops) do
					if numdrops > 0 then
						stufftodrop = true
						break
					end
				end

				row = inputtable:addRow("ConfirmDrops", { bgColor = Helper.color.transparent })

				-- add a "Drop" button
				row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = stufftodrop }):setText(ReadText(1001, 9405), { halign = "center", fontsize = config.mapFontSize })	-- Drop
				row[4].handlers.onClick = function() return orig.menu.infoSubmenuConfirmDrops(inputobject) end
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = stufftodrop }):setText(ReadText(1001, 64), { halign = "center", fontsize = config.mapFontSize })	-- Cancel
				row[9].handlers.onClick = function() return orig.menu.resetInfoSubmenu() end
			end

			local locpolicefaction = GetComponentData(GetComponentData(object64, "zoneid"), "policefaction")
			for _, wareentry in ipairs(cargotable) do
				local ware = wareentry.ware
				local amount = wareentry.amount
				local targetamount = GetWareProductionLimit(object64, ware)
				if not orig.menu.infodrops[ware] then
					orig.menu.infodrops[ware] = 0
				end
				locrowdata = { ware, GetWareData(ware, "name"), amount }
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })

				if not isresupplyship then
					row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount - orig.menu.infodrops[ware], maxSelect = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = not isplayerowned, hideMaxValue = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })
					--row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })
				else
					-- applies even if targetamount == 0
					if targetamount then
						row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount - orig.menu.infodrops[ware], maxSelect = amount, max = math.max(targetamount, amount), readOnly = not isplayerowned }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })
					else
						row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount - orig.menu.infodrops[ware], maxSelect = amount, max = amount, readOnly = not isplayerowned, hideMaxValue = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })
					end
				end


				if isplayerowned then
					--local oldamount = amount
					row[2].handlers.onSliderCellChanged = function(_, newamount) return orig.menu.infoSubmenuUpdateDrops(ware, amount, newamount) end
					--row[2].handlers.onSliderCellChanged = function(_, newamount) return (orig.menu.infodrops[ware] = amount - newamount) end
					row[2].handlers.onSliderCellConfirm = function() return orig.menu.refreshInfoFrame() end
					row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
					row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end

					locrowdata = "Drops"
					row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
					--row[2]:setColSpan(2):createText(locrowdata, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (2 * indentsize) })
					row[4]:setColSpan(10):createText(function() return (orig.menu.infodrops[ware] ~= 0) and (ReadText(1001, 9406) .. ReadText(1001, 120) .. " (" .. tostring(orig.menu.infodrops[ware]) .. ")") or "" end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })	-- Dropping, :
				end
			end
		end

		local shipstoragecapacity = GetComponentData(inputobject, "shipstoragecapacity") or 0
		if shipstoragecapacity > 0 then
			local numdockedships = 0
			if C.IsComponentClass(inputobject, "container") then
				numdockedships = C.GetNumDockedShips(inputobject, nil)
			end
			locrowdata = { "info_dockedships", ReadText(1001, 3265) }
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, numdockedships > 0 and true or false)
			if orig.menu.extendedinfo[locrowdata[1]] then
				local dockedships = ffi.new("UniverseID[?]", numdockedships)
				numdockedships = C.GetDockedShips(dockedships, numdockedships, inputobject, nil)
				local playerowneddockedships = {}
				local npcowneddockedships = {}
				for i = 0, numdockedships-1 do
					local locship = ConvertStringTo64Bit(tostring(dockedships[i]))
					if GetComponentData(locship, "isplayerowned") then
						table.insert(playerowneddockedships, locship)
					else
						table.insert(npcowneddockedships, locship)
					end
				end
				table.sort(playerowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)
				table.sort(npcowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)

				local totaldockedships = 0
				for i, shipid in ipairs(playerowneddockedships) do
					local shipname = ffi.string(C.GetComponentName(shipid))
					local iconid = GetComponentData(shipid, "icon")
					if iconid and iconid ~= "" then
						shipname = string.format("\027[%s] %s", iconid, shipname)
					end
					row = inputtable:addRow(("info_dockedship" .. i), { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(shipname, { color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
					row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
					totaldockedships = i
				end
				for i, shipid in ipairs(npcowneddockedships) do
					local shipname = ffi.string(C.GetComponentName(shipid))
					local iconid = GetComponentData(shipid, "icon")
					if iconid and iconid ~= "" then
						shipname = string.format("\027[%s] %s", iconid, shipname)
					end
					row = inputtable:addRow(("info_dockedship" .. totaldockedships+i), { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(shipname, { x = Helper.standardTextOffsetx + indentsize })
					row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", x = Helper.standardTextOffsetx + indentsize })
				end
			end
		end

		local nummissiletypes = C.GetNumAllMissiles(inputobject)
		local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes)
		nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject)
		local totalnummissiles = 0
		for i = 0, nummissiletypes - 1 do
			totalnummissiles = totalnummissiles + missilestoragetable[i].amount
		end
		local missilecapacity = 0
		if C.IsComponentClass(inputobject, "defensible") then
			missilecapacity = GetComponentData(inputobject, "missilecapacity")
		end
		local locmissilecapacity = defenceinfo_low and tostring(missilecapacity) or unknowntext
		local locnummissiles = defenceinfo_high and tostring(totalnummissiles) or unknowntext
		locrowdata = { "Ammunition", ReadText(1001, 2800), (locnummissiles .. " / " .. locmissilecapacity) }	-- Ammunition
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnummissiles > 0) and true or false)
		if defenceinfo_high and orig.menu.extendedinfo[locrowdata[1]] then
			for i = 0, nummissiletypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(missilestoragetable[i].macro), "name"), (tostring(missilestoragetable[i].amount) .. " / " .. tostring(missilestoragetable[i].capacity)) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end

		local numcountermeasuretypes = C.GetNumAllCountermeasures(inputobject)
		local countermeasurestoragetable = ffi.new("AmmoData[?]", numcountermeasuretypes)
		numcountermeasuretypes = C.GetAllCountermeasures(countermeasurestoragetable, numcountermeasuretypes, inputobject)
		local totalnumcountermeasures = 0
		for i = 0, numcountermeasuretypes - 1 do
			totalnumcountermeasures = totalnumcountermeasures + countermeasurestoragetable[i].amount
		end
		local countermeasurecapacity = GetComponentData(object64, "countermeasurecapacity")
		local loccountermeasurecapacity = defenceinfo_low and tostring(countermeasurecapacity) or unknowntext
		local locnumcountermeasures = defenceinfo_high and tostring(totalnumcountermeasures) or unknowntext
		locrowdata = { "Countermeasures", ReadText(20215, 1701), (locnumcountermeasures .. " / " .. loccountermeasurecapacity) }	-- Countermeasures
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnumcountermeasures > 0) and true or false)
		if orig.menu.extendedinfo[locrowdata[1]] then
			for i = 0, numcountermeasuretypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(countermeasurestoragetable[i].macro), "name"), (tostring(countermeasurestoragetable[i].amount) .. " / " .. tostring(countermeasurestoragetable[i].capacity)) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end

		local numlasertowertypes = C.GetNumAllLaserTowers(inputobject)
		local lasertowerstoragetable = ffi.new("AmmoData[?]", numlasertowertypes)
		numlasertowertypes = C.GetAllLaserTowers(lasertowerstoragetable, numlasertowertypes, inputobject)
		local totalnumlasertowers = 0
		for i = 0, numlasertowertypes - 1 do
			totalnumlasertowers = totalnumlasertowers + lasertowerstoragetable[i].amount
		end

		local numminetypes = C.GetNumAllMines(inputobject)
		local minestoragetable = ffi.new("AmmoData[?]", numminetypes)
		numminetypes = C.GetAllMines(minestoragetable, numminetypes, inputobject)
		local totalnummines = 0
		for i = 0, numminetypes - 1 do
			totalnummines = totalnummines + minestoragetable[i].amount
		end

		local numsatellitetypes = C.GetNumAllSatellites(inputobject)
		local satellitestoragetable = ffi.new("AmmoData[?]", numsatellitetypes)
		numsatellitetypes = C.GetAllSatellites(satellitestoragetable, numsatellitetypes, inputobject)
		local totalnumsatellites = 0
		for i = 0, numsatellitetypes - 1 do
			totalnumsatellites = totalnumsatellites + satellitestoragetable[i].amount
		end

		local numnavbeacontypes = C.GetNumAllNavBeacons(inputobject)
		local navbeaconstoragetable = ffi.new("AmmoData[?]", numnavbeacontypes)
		numnavbeacontypes = C.GetAllNavBeacons(navbeaconstoragetable, numnavbeacontypes, inputobject)
		local totalnumnavbeacons = 0
		for i = 0, numnavbeacontypes - 1 do
			totalnumnavbeacons = totalnumnavbeacons + navbeaconstoragetable[i].amount
		end

		local numresourceprobetypes = C.GetNumAllResourceProbes(inputobject)
		local resourceprobestoragetable = ffi.new("AmmoData[?]", numresourceprobetypes)
		numresourceprobetypes = C.GetAllResourceProbes(resourceprobestoragetable, numresourceprobetypes, inputobject)
		local totalnumresourceprobes = 0
		for i = 0, numresourceprobetypes - 1 do
			totalnumresourceprobes = totalnumresourceprobes + resourceprobestoragetable[i].amount
		end

		local totalnumdeployables = totalnumlasertowers + totalnummines + totalnumsatellites + totalnumnavbeacons + totalnumresourceprobes
		local deployablecapacity = C.GetDefensibleDeployableCapacity(inputobject)
		local printednumdeployables = defenceinfo_low and tostring(totalnumdeployables) or unknowntext
		local printeddeployablecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext

		locrowdata = { "info_deployables", ReadText(1001, 1332), (printednumdeployables .. " / " .. printeddeployablecapacity) }	-- Deployables
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumdeployables > 0))
		if defenceinfo_high and (totalnumdeployables > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			local printedlasertowercapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumlasertowers = defenceinfo_high and tostring(totalnumlasertowers) or unknowntext
			locrowdata = { "info_lasertowers", ReadText(1001, 1333), (printednumlasertowers .. " / " .. printedlasertowercapacity) }	-- Laser Towers
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumlasertowers > 0), 1, indentsize)
			if defenceinfo_high and (totalnumlasertowers > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchlasertower", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.lasertower) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchLasertower(inputobject, orig.menu.infomacrostolaunch.lasertower) end
				for i = 0, numlasertowertypes - 1 do
					locrowdata = { {("info_lasertower" .. (i+1)), "info_deploy", ffi.string(lasertowerstoragetable[i].macro)}, GetMacroData(ffi.string(lasertowerstoragetable[i].macro), "name"), (tostring(lasertowerstoragetable[i].amount) .. " / " .. tostring(lasertowerstoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printedminecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednummines = defenceinfo_high and tostring(totalnummines) or unknowntext
			locrowdata = { "info_mines", ReadText(1001, 1326), (printednummines .. " / " .. printedminecapacity) }	-- Mines
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnummines > 0), 1, indentsize)
			if defenceinfo_high and (totalnummines > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchmine", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.mine) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchMine(inputobject, orig.menu.infomacrostolaunch.mine) end
				for i = 0, numminetypes - 1 do
					locrowdata = { {("info_mine" .. (i+1)), "info_deploy", ffi.string(minestoragetable[i].macro)}, GetMacroData(ffi.string(minestoragetable[i].macro), "name"), (tostring(minestoragetable[i].amount) .. " / " .. tostring(minestoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printedsatellitecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumsatellites = defenceinfo_high and tostring(totalnumsatellites) or unknowntext
			locrowdata = { "info_satellites", ReadText(1001, 1327), (printednumsatellites .. " / " .. printedsatellitecapacity) }	-- Satellites
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumsatellites > 0), 1, indentsize)
			if defenceinfo_high and (totalnumsatellites > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchsatellite", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.satellite) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchSatellite(inputobject, orig.menu.infomacrostolaunch.satellite) end
				for i = 0, numsatellitetypes - 1 do
					locrowdata = { {("info_satellite" .. (i+1)), "info_deploy", ffi.string(satellitestoragetable[i].macro)}, GetMacroData(ffi.string(satellitestoragetable[i].macro), "name"), (tostring(satellitestoragetable[i].amount) .. " / " .. tostring(satellitestoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printednavbeaconcapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumnavbeacons = defenceinfo_high and tostring(totalnumnavbeacons) or unknowntext
			locrowdata = { "info_navbeacons", ReadText(1001, 1328), (printednumnavbeacons .. " / " .. printednavbeaconcapacity) }	-- Navigation Beacons
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumnavbeacons > 0), 1, indentsize)
			if defenceinfo_high and (totalnumnavbeacons > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchnavbeacon", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.navbeacon) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchNavBeacon(inputobject, orig.menu.infomacrostolaunch.navbeacon) end
				for i = 0, numnavbeacontypes - 1 do
					locrowdata = { {("info_navbeacon" .. (i+1)), "info_deploy", ffi.string(navbeaconstoragetable[i].macro)}, GetMacroData(ffi.string(navbeaconstoragetable[i].macro), "name"), (tostring(navbeaconstoragetable[i].amount) .. " / " .. tostring(navbeaconstoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end
		
			local printedresourceprobecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumresourceprobes = defenceinfo_high and tostring(totalnumresourceprobes) or unknowntext
			locrowdata = { "info_resourceprobes", ReadText(1001, 1329), (printednumresourceprobes .. " / " .. printedresourceprobecapacity) }	-- Resource Probes
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumresourceprobes > 0), 1, indentsize)
			if defenceinfo_high and (totalnumresourceprobes > 0) and orig.menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchresourceprobe", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and orig.menu.infomacrostolaunch.resourceprobe) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return orig.menu.buttonLaunchResourceProbe(inputobject, orig.menu.infomacrostolaunch.resourceprobe) end
				for i = 0, numresourceprobetypes - 1 do
					locrowdata = { {("info_resourceprobe" .. (i+1)), "info_deploy", ffi.string(resourceprobestoragetable[i].macro)}, GetMacroData(ffi.string(resourceprobestoragetable[i].macro), "name"), (tostring(resourceprobestoragetable[i].amount) .. " / " .. tostring(resourceprobestoragetable[i].capacity)) }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end
		end

		local unitstoragetable = C.IsComponentClass(object64, "defensible") and GetUnitStorageData(object64) or { stored = 0, capacity = 0 } 
		local locunitcapacity = unitinfo_capacity and tostring(unitstoragetable.capacity) or unknowntext
		local locunitcount = unitinfo_capacity and tostring(unitstoragetable.stored) or unknowntext
		locrowdata = {"info_units", ReadText(1001, 8), (locunitcount .. " / " .. locunitcapacity)}	-- Drones
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (unitinfo_details and unitstoragetable.stored > 0) and true or false)
		if orig.menu.extendedinfo[locrowdata[1]] then
			for i = 1, #unitstoragetable do
				if unitstoragetable[i].amount > 0 or unitstoragetable[i].unavailable > 0 then
					locrowdata = { ("Unit" .. i), unitstoragetable[i].name, (unitstoragetable[i].amount .. " / " .. unitstoragetable.capacity .. " (" .. unitstoragetable[i].unavailable .. " " .. ReadText(1001, 9408) .. ")") }	-- Unavailable
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end
		end

		locrowdata = { "info_weaponconfig", ReadText(1001, 9409) }	-- Weapon Configuration
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, isplayerowned and (#loadout.component.weapon > 0) and true or false)
		if isplayerowned and orig.menu.extendedinfo[ locrowdata[1] ] and #loadout.component.weapon > 0 then
			locrowdata = { false, "", "", ReadText(1001, 9410), ReadText(1001, 9411) }	-- Primary, Secondary
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false)
			for i, gun in ipairs(loadout.component.weapon) do
				local gun = ConvertStringTo64Bit(tostring(gun))
				local numweapongroups = C.GetNumWeaponGroupsByWeapon(inputobject, gun)
				local rawweapongroups = ffi.new("UIWeaponGroup[?]", numweapongroups)
				numweapongroups = C.GetWeaponGroupsByWeapon(rawweapongroups, numweapongroups, inputobject, gun)
				local uiweapongroups = { primary = {}, secondary = {} }
				for j = 0, numweapongroups-1 do
					-- there are two sets: primary and secondary.
					-- each set has four groups.
					-- .primary tells you if this particular weapon is active in a group in the primary or secondary group set.
					-- .idx tells you which group in that group set it is active in.
					if rawweapongroups[j].primary then
						uiweapongroups.primary[rawweapongroups[j].idx] = true
					else
						uiweapongroups.secondary[rawweapongroups[j].idx] = true
					end
					--print("primary: " .. tostring(rawweapongroups[j].primary) .. ", idx: " .. tostring(rawweapongroups[j].idx))
				end

				row = inputtable:addRow(("info_weaponconfig" .. i), { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(ffi.string(C.GetComponentName(gun)))

				-- primary weapon groups
				for j = 1, 4 do
					row[3+j]:createCheckBox(uiweapongroups.primary[j], { width = config.mapRowHeight, height = config.mapRowHeight })
					row[3+j].handlers.onClick = function() orig.menu.infoSetWeaponGroup(inputobject, gun, true, j, not uiweapongroups.primary[j]) end
				end

				-- secondary weapon groups
				for j = 1, 4 do
					row[8+j]:createCheckBox(uiweapongroups.secondary[j], { width = config.mapRowHeight, height = config.mapRowHeight })
					row[8+j].handlers.onClick = function() orig.menu.infoSetWeaponGroup(inputobject, gun, false, j, not uiweapongroups.secondary[j]) end
				end

				if IsComponentClass(gun, "missilelauncher") then
					local nummissiletypes = C.GetNumAllMissiles(inputobject)
					local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes)
					nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject)

					local gunmacro = GetComponentData(gun, "macro")
					local dropdowndata = {}
					for j = 0, nummissiletypes-1 do
						local ammomacro = ffi.string(missilestoragetable[j].macro)
						if C.IsAmmoMacroCompatible(gunmacro, ammomacro) then
							table.insert(dropdowndata, {id = ammomacro, text = GetMacroData(ammomacro, "name"), icon = "", displayremoveoption = false})
						end
					end

					-- if the ship has no compatible ammunition in ammo storage, have the dropdown print "Out of ammo" and make it inactive.
					local currentammomacro = "empty"
					local dropdownactive = true
					if #dropdowndata == 0 then
						dropdownactive = false
						table.insert(dropdowndata, {id = "empty", text = ReadText(1001, 9412), icon = "", displayremoveoption = false})	-- Out of ammo
					else
						-- NB: currentammomacro can be null
						currentammomacro = ffi.string(C.GetCurrentAmmoOfWeapon(gun))
					end

					row = inputtable:addRow(("info_weaponconfig" .. i .. "_ammo"), { bgColor = Helper.color.transparent })
					row[2]:createText((ReadText(1001, 2800) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx + indentsize })	-- Ammunition, :
					row[3]:setColSpan(11):createDropDown(dropdowndata, {startOption = currentammomacro, active = dropdownactive})
					row[3].handlers.onDropDownConfirmed = function(_, newammomacro) C.SetAmmoOfWeapon(gun, newammomacro) end
				elseif pilot and IsComponentClass(gun, "bomblauncher") then
					local numbombtypes = C.GetNumAllInventoryBombs(pilot)
					local bombstoragetable = ffi.new("AmmoData[?]", numbombtypes)
					numbombtypes = C.GetAllInventoryBombs(bombstoragetable, numbombtypes, pilot)

					local gunmacro = GetComponentData(gun, "macro")
					local dropdowndata = {}
					for j = 0, numbombtypes-1 do
						local ammomacro = ffi.string(bombstoragetable[j].macro)
						if C.IsAmmoMacroCompatible(gunmacro, ammomacro) then
							table.insert(dropdowndata, {id = ammomacro, text = GetMacroData(ammomacro, "name"), icon = "", displayremoveoption = false})
						end
					end

					-- if the ship has no compatible ammunition in ammo storage, have the dropdown print "Out of ammo" and make it inactive.
					local currentammomacro = "empty"
					local dropdownactive = true
					if #dropdowndata == 0 then
						dropdownactive = false
						table.insert(dropdowndata, {id = "empty", text = ReadText(1001, 9412), icon = "", displayremoveoption = false})	-- Out of ammo
					else
						-- NB: currentammomacro can be null
						currentammomacro = ffi.string(C.GetCurrentAmmoOfWeapon(gun))
					end

					row = inputtable:addRow(("info_weaponconfig" .. i .. "_ammo"), { bgColor = Helper.color.transparent })
					row[2]:createText((ReadText(1001, 2800) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx + indentsize })	-- Ammunition, :
					row[3]:setColSpan(11):createDropDown(dropdowndata, {startOption = currentammomacro, active = dropdownactive})
					row[3].handlers.onDropDownConfirmed = function(_, newammomacro) C.SetAmmoOfWeapon(gun, newammomacro) end
				end
			end
		end

		locrowdata = { "info_turretbehaviour", ReadText(1001, 8612) }	-- Turret Behaviour
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, isplayerowned and (#loadout.component.turret > 0))
		if isplayerowned and orig.menu.extendedinfo[ locrowdata[1] ] and #loadout.component.turret > 0 then
			orig.menu.turrets = {}
			local numslots = tonumber(C.GetNumUpgradeSlots(inputobject, "", "turret"))
			for j = 1, numslots do
				local groupinfo = C.GetUpgradeSlotGroup(inputobject, "", "turret", j)
				if (ffi.string(groupinfo.path) == "..") and (ffi.string(groupinfo.group) == "") then
					local current = C.GetUpgradeSlotCurrentComponent(inputobject, "turret", j)
					if current ~= 0 then
						table.insert(orig.menu.turrets, current)
					end
				end
			end

			orig.menu.turretgroups = {}
			local n = C.GetNumUpgradeGroups(inputobject, "")
			local buf = ffi.new("UpgradeGroup[?]", n)
			n = C.GetUpgradeGroups(buf, n, inputobject, "")
			for i = 0, n - 1 do
				if (ffi.string(buf[i].path) ~= "..") or (ffi.string(buf[i].group) ~= "") then
					local group = { path = ffi.string(buf[i].path), group = ffi.string(buf[i].group) }
					local groupinfo = C.GetUpgradeGroupInfo(inputobject, "", group.path, group.group, "turret")
					if (groupinfo.count > 0) then
						group.operational = groupinfo.operational
						group.currentmacro = ffi.string(groupinfo.currentmacro)
						group.slotsize = ffi.string(groupinfo.slotsize)
						table.insert(orig.menu.turretgroups, group)
					end
				end
			end

			if (#orig.menu.turrets > 0) or (#orig.menu.turretgroups > 0) then
				local turretmodes = {
					[1] = { id = "attackenemies",	text = ReadText(1001, 8614),	icon = "",	displayremoveoption = false },
					[2] = { id = "defend",			text = ReadText(1001, 8613),	icon = "",	displayremoveoption = false },
					[3] = { id = "mining",			text = ReadText(1001, 8616),	icon = "",	displayremoveoption = false },
					[4] = { id = "missiledefence",	text = ReadText(1001, 8615),	icon = "",	displayremoveoption = false },
					[5] = { id = "autoassist",		text = ReadText(1001, 8617),	icon = "",	displayremoveoption = false },
					[6] = { id = "holdfire",		text = ReadText(1041, 10157),	icon = "",	displayremoveoption = false },
				}

				local row = inputtable:addRow("info_turretconfig", { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(ReadText(1001, 2963))
				row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return orig.menu.getDropDownTurretModeOption(inputobject, "all") end })
				row[4].handlers.onDropDownConfirmed = function(_, newturretmode) orig.menu.noupdate = false; C.SetAllTurretModes(inputobject, newturretmode) end
				row[4].handlers.onDropDownActivated = function () orig.menu.noupdate = true end

				for i, turret in ipairs(orig.menu.turrets) do
					local row = inputtable:addRow("info_turretconfig" .. i, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(ffi.string(C.GetComponentName(turret)))
					row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return orig.menu.getDropDownTurretModeOption(turret) end })
					row[4].handlers.onDropDownConfirmed = function(_, newturretmode) orig.menu.noupdate = false; C.SetWeaponMode(turret, newturretmode) end
					row[4].handlers.onDropDownActivated = function () orig.menu.noupdate = true end
				end

				for i, group in ipairs(orig.menu.turretgroups) do
					local row = inputtable:addRow("info_turretgroupconfig" .. i, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(ReadText(1001, 8023) .. " " .. i .. ((group.currentmacro ~= "") and (" (" .. orig.menu.getSlotSizeText(group.slotsize) .. " " .. GetMacroData(group.currentmacro, "shortname") .. ")") or ""), { color = (group.operational > 0) and Helper.color.white or Helper.color.red })
					row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return orig.menu.getDropDownTurretModeOption(inputobject, group.path, group.group) end, active = group.operational > 0 })
					row[4].handlers.onDropDownConfirmed = function(_, newturretmode) orig.menu.noupdate = false; C.SetTurretGroupMode(inputobject, group.path, group.group, newturretmode) end
					row[4].handlers.onDropDownActivated = function () orig.menu.noupdate = true end
				end
			end
		end

		local showloadout = defenceinfo_high and (#loadout.component.weapon > 0 or #loadout.component.turret > 0 or #loadout.component.shield > 0 or #loadout.component.engine > 0 or #loadout.macro.thruster > 0 or #loadout.ware.software > 0)
		locrowdata = { "Loadout", ReadText(1001, 9413) }	-- Loadout
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, showloadout)
		if showloadout and orig.menu.extendedinfo[locrowdata[1]] then
			if #loadout.component.weapon > 0 then
				locrowdata = { "Weapons", ReadText(1001, 1301) }	-- Weapons
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.weapon)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.turret > 0 then
				locrowdata = { "Turrets", ReadText(1001, 1319) }	-- Turrets
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.turret)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.shield > 0 then
				locrowdata = { "Shield Generators", ReadText(1001, 1317) }	-- Shield Generators
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.shield)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.engine > 0 then
				locrowdata = { "Engines", ReadText(1001, 1103) }	-- Engines
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.engine)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.macro.thruster > 0 then
				locrowdata = { "Thrusters", ReadText(1001, 8001) }	-- Thrusters
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					-- ships normally only have 1 set of thrusters. in case a ship has more, this will list all of them.
					for i, val in ipairs(loadout.macro.thruster) do
						locrowdata = { false, GetMacroData(val, "name") }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.ware.software > 0 then
				locrowdata = { "Software", ReadText(1001, 87) }	-- Software
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					for i, val in ipairs(loadout.ware.software) do
						locrowdata = { false, GetWareData(val, "name") }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
		end
		--print("numweapons: " .. tostring(#loadout.component.weapon) .. ", numturrets: " .. tostring(#loadout.component.turret) .. ", numshields: " .. tostring(#loadout.component.shield) .. ", numengines: " .. tostring(#loadout.component.engine) .. ", numthrusters: " .. tostring(#loadout.macro.thruster) .. ", numsoftware: " .. tostring(#loadout.ware.software))
		--[[
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata] then
			for datatype, content in pairs(loadout) do
				for category, subtable in pairs(content) do
					if #subtable > 0 then
						locrowdata = tostring(category)
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, (#subtable > 0 and true or false), 1, indentsize)
						if orig.menu.extendedinfo[locrowdata] then
							--print("category: " .. tostring(category) .. ", subtable: " .. tostring(subtable) .. ", numentries: " .. tostring(#subtable))
							for key, val in pairs(subtable) do
								--print("type of val: " .. type(val))
								-- software: ware (string), virtual: macro (string), else: componentid (cdata)
								if datatype == "component" then
									locrowdata = ffi.string(C.GetComponentName(val))
								elseif datatype == "macro" then
									locrowdata = GetMacroData(val, "name")
								elseif datatype == "ware" then
									locrowdata = GetWareData(val, "name")
								else
									locrowdata = ""
									print("ERROR: menu_map function orig.menu.setupInfoSubmenuRows(): unhandled datatype: " .. tostring(datatype))
								end
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
								--print("key: " .. tostring(key) .. ", val: " .. tostring(val))
							end
						end
					end
				end
			end
		end
		]]
		-- mods
		locrowdata = { "EquipmentMods", ReadText(1001, 8031) }
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, equipment_mods and GetComponentData(object64, "hasanymod"))
		if equipment_mods and orig.menu.extendedinfo[locrowdata[1]] then
			-- chassis
			local hasinstalledmod, installedmod = Helper.getInstalledModInfo("ship", inputobject)
			if hasinstalledmod then
				locrowdata = { ("EquipmentModsChassis"), ReadText(1001, 8008), installedmod.Name }
				row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "ship", installedmod, false, true, true, 1, indentsize)
			end
			-- weapon
			for i, weapon in ipairs(loadout.component.weapon) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("weapon", weapon)
				if hasinstalledmod then
					locrowdata = { ("EquipmentModsWeapon" .. i), ffi.string(C.GetComponentName(weapon)), installedmod.Name }
					row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "weapon", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- turret
			for i, turret in ipairs(loadout.component.turret) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("turret", turret)
				if hasinstalledmod then
					locrowdata = { ("EquipmentModsTurret" .. i), ffi.string(C.GetComponentName(turret)), installedmod.Name }
					row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "weapon", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- shield
			local shieldgroups = {}
			local n = C.GetNumShieldGroups(inputobject)
			local buf = ffi.new("ShieldGroup[?]", n)
			n = C.GetShieldGroups(buf, n, inputobject)
			for i = 0, n - 1 do
				local entry = {}
				entry.context = buf[i].context
				entry.group = ffi.string(buf[i].group)
				entry.component = buf[i].component

				table.insert(shieldgroups, entry)
			end
			for i, entry in ipairs(shieldgroups) do
				if (entry.context == inputobject) and (entry.group == "") then
					shieldgroups.hasMainGroup = true
					-- force maingroup to first index
					table.insert(shieldgroups, 1, entry)
					table.remove(shieldgroups, i + 1)
					break
				end
			end
			for i, shieldgroupdata in ipairs(shieldgroups) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("shield", inputobject, shieldgroupdata.context, shieldgroupdata.group)
				if hasinstalledmod then
					local name = GetMacroData(GetComponentData(ConvertStringTo64Bit(tostring(shieldgroupdata.component)), "macro"), "name")
					if (i == 1) and shieldgroups.hasMainGroup then
						name = ReadText(1001, 8044)
					end
					locrowdata = { ("EquipmentModsShield" .. i), name, installedmod.Name }
					row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "shield", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- engine
			local hasinstalledmod, installedmod = Helper.getInstalledModInfo("engine", inputobject)
			if hasinstalledmod then
				locrowdata = { ("EquipmentModsEngine"), ffi.string(C.GetComponentName(loadout.component.engine[1])), installedmod.Name }
				row = orig.menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "engine", installedmod, false, true, true, 1, indentsize)
			end
		end
	elseif mode == "station" then
		local buildstorage = ConvertIDTo64Bit(GetComponentData(inputobject, "buildstorage"))

		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(8):setBackgroundColSpan(5):createText(objectname, Helper.headerRow1Properties)
		row[1].properties.color = titlecolor
		row[9]:setColSpan(5):createText(Helper.unlockInfo(nameinfo, ffi.string(C.GetObjectIDCode(inputobject))), Helper.headerRow1Properties)
		row[9].properties.halign = "right"
		row[9].properties.color = titlecolor

		if isplayerowned then
			local playercash = GetPlayerMoney()

			local cashcontainers = {inputobject, buildstorage}
			for i, container in ipairs(cashcontainers) do
				local containercash = GetAccountData(container, "money") or 0
				local sliderstart = orig.menu.infocashtransferdetails[2][i] + containercash
				local slidermax = math.max((containercash + playercash), sliderstart)
				-- NB: money is not transferred to the player until after slider changes are confirmed so slidermaxselect can be greater than slidermax.
				-- orig.menu.infocashtransferdetails[2][3-i] relies on the current state where cashcontainers only contains two entries with indices 1 and 2.
				local slidermaxselect = math.min(math.max((containercash + playercash - orig.menu.infocashtransferdetails[2][3-i]), sliderstart), slidermax)
				local slidertext = (i == 1) and ReadText(1001, 7710) or ReadText(1001, 9429)		-- Station Account, Funds for Station Construction

				row = inputtable:addRow("info_stationaccount" .. i, { bgColor = Helper.color.transparent })
				row[2]:setColSpan(12):createSliderCell({
					height = config.mapRowHeight,
					start = sliderstart, 
					min = math.min(containercash, 0),
					max = slidermax,
					maxSelect = slidermaxselect,
					suffix = ReadText(1001, 101) }):setText(slidertext, { fontsize = config.mapFontSize })

				row[2].handlers.onSliderCellChanged = function(_, value) 
					local idx = i
					local loccash = containercash
					return orig.menu.infoSubmenuUpdateTransferAmount(value, idx, loccash) end
				row[2].handlers.onSliderCellActivated = function() orig.menu.noupdate = true end
				row[2].handlers.onSliderCellDeactivated = function() orig.menu.noupdate = false end
				row[2].handlers.onSliderCellConfirm = function() orig.menu.over = true end
			end

			row = inputtable:addRow("info_updateaccount", { bgColor = Helper.color.transparent })
			row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocashtransferdetails[2][1] ~= 0) or (orig.menu.infocashtransferdetails[2][2] ~= 0)) and true or false end }):setText(ReadText(1001, 2821), { halign = "center", fontsize = config.mapFontSize })	-- Confirm
			row[4].handlers.onClick = function() return orig.menu.infoSubmenuUpdateManagerAccount(inputobject, buildstorage) end
			row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((orig.menu.infocashtransferdetails[2][1] ~= 0) or (orig.menu.infocashtransferdetails[2][2] ~= 0)) and true or false end }):setText(ReadText(1001, 64), { halign = "center", fontsize = config.mapFontSize })	-- Cancel
			row[9].handlers.onClick = function() return orig.menu.resetInfoSubmenu() end
		end

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: orig.menu.infoeditname cleared at the end of this function.
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = editname}):setText(editname)
				row[4].handlers.onEditBoxActivated = function(_, inputtable, editname) return Helper.updateEditBoxText(inputtable,4,10,editname) end
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(object64, "sector") }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local radarrange = defenceinfo_low and (Helper.round(GetComponentData(object64, "maxradarrange")) / 1000) or unknowntext
			locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9414), (GetComponentData(object64, "tradesubscription") and ReadText(1001, 2617) or ReadText(1001, 2618)) }	-- Updating Trade Offers
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			-- TODO: enable if boarding of stations is ever implemented.
			--[[
			local boardingresistance = 0
			if C.IsComponentClass(inputobject, "station") then
				boardingresistance = tostring(GetComponentData(inputobject, "boardingresistance"))
			end
			local printedboardingresistance = defenceinfo_high and boardingresistance or unknowntext
			locrowdata = { false, ReadText(1001, 1324), printedboardingresistance }	-- Boarding Resistance
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			]]
		end

		locrowdata = { "Personnel", ReadText(1001, 9400) }	-- Personnel
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local manager = GetComponentData(inputobject, "tradenpc")
			locrowdata = { "Manager", (manager and GetComponentData(manager, "isfemale") and ReadText(20208, 30302) or ReadText(20208, 30301)) }	-- Manager (female), Manager (male)
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, manager and true or false, 1, indentsize)
			if manager and orig.menu.extendedinfo[locrowdata[1]] then
				manager = ConvertIDTo64Bit(manager)
				local name = GetComponentData(manager, "name")
				local printedname = operatorinfo and tostring(name) or unknowntext
				local skilltable = GetComponentData(manager, "skills")
				locrowdata = operatorinfo and { "info_manager", manager, inputobject } or { "info_manager_unknown" }
				local indent = 2 * indentsize
				row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
				row[2]:setColSpan(12):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
				table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)

				if (manager ~= C.GetPlayerID()) then
					for _, subtable in ipairs(skilltable) do
						local skillname = ReadText(1013, subtable.textid)
						local printedskill = operatorinfo_details and Helper.displaySkill(subtable.value) or unknowntext
						row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (subtable.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
						--row[2]:setColSpan(7):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (subtable.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
						local locfont = inputfont
						local locfontcolor = Helper.standardColor
						if operatorinfo_details then
							locfontcolor = Helper.color.brightyellow
						end
						row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
						--row[9]:setColSpan(5):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
						--row = orig.menu.addInfoSubmenuRow(inputtable, row, { }, false, false, false, 3, indentsize)
					end
				end

				if isplayerowned then
					local recommendedfunds = GetComponentData(inputobject, "productionmoney")
					locrowdata = { "info_station_recommendedfunds", (ReadText(1001, 9434) .. ReadText(1001, 120)), ConvertMoneyString(recommendedfunds, false, true, nil, true) .. " " .. ReadText(1001, 101) }	-- Expected operating budget, :, Cr
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

					local traderestrictions = GetTradeRestrictions(inputobject)
					row = inputtable:addRow("RestrictTrade", { bgColor = Helper.color.transparent })
					row[1]:createCheckBox(traderestrictions.faction, { scaling = false, width = config.mapRowHeight, height = config.mapRowHeight, x = config.mapRowHeight + (2 * Helper.scaleX(indentsize)) })
					row[2]:setColSpan(12):createText(ReadText(1001, 4202), { fontsize = config.mapFontSize, x = Helper.standardTextOffsetx + (config.mapRowHeight * 2) + (3 * indentsize) })	-- Restrict trade to other factions
					row[1].handlers.onClick = function() return orig.menu.checkboxInfoSubmenuRestrictTrade(object64) end
				end
			end

			local shiptrader = GetComponentData(inputobject, "shiptrader")
			if shiptrader then
				shiptrader = ConvertIDTo64Bit(shiptrader)
				locrowdata = { "Ship Trader", (GetComponentData(shiptrader, "isfemale") and ReadText(20208, 30502) or ReadText(20208, 30501)) }	-- Ship Trader (female), Ship Trader (male)
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local name = GetComponentData(shiptrader, "name")
					local printedname = operatorinfo and tostring(name) or unknowntext
					locrowdata = operatorinfo and { "info_shiptrader", shiptrader, inputobject } or { "info_shiptrader_unknown" }
					local indent = 2 * indentsize
					row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(12):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
				end
			end

			-- can query: .current, .capacity, .optimal, .available, .maxavailable
			local workforceinfo = C.GetWorkForceInfo(inputobject, "")
			local printedcapacity = operatorinfo and tostring(workforceinfo.capacity) or unknowntext
			local printednumpeople = operatorinfo and tostring(workforceinfo.current) or unknowntext
			locrowdata = {"Work Force", ReadText(1001, 9415), (printednumpeople .. " / " .. printedcapacity)}	-- Workforce
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (operatorinfo and workforceinfo.current > 0) and true or false, 1, indentsize)
			if operatorinfo and orig.menu.extendedinfo[locrowdata[1]] then
				workforceinfo = C.GetWorkForceInfo(inputobject, "argon")
				locrowdata = {false, ReadText(20202, 101), workforceinfo.current}	-- Argon
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "boron")
				--locrowdata = {false, ReadText(20202, 201), workforceinfo.current}	-- Boron
				--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				workforceinfo = C.GetWorkForceInfo(inputobject, "paranid")
				locrowdata = {false, ReadText(20202, 401), workforceinfo.current}	-- Paranid
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "split")
				--locrowdata = {false, ReadText(20202, 301), workforceinfo.current}	-- Split
				--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				workforceinfo = C.GetWorkForceInfo(inputobject, "teladi")
				locrowdata = {false, ReadText(20202, 501), workforceinfo.current}	-- Teladi
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "terran")
				--locrowdata = {false, ReadText(20202, 701), workforceinfo.current}	-- Terran
				--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
			end

			local npctable = GetNPCs(inputobject)
			for i = #npctable, 1, -1 do
				if not GetComponentData(npctable[i], "isplayerowned") then
					table.remove(npctable, i)
				end
			end
			locrowdata = { "Player Employees Onboard", ReadText(1001, 9416), #npctable }	-- Player Employees On Board
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (#npctable > 0 and true or false), 1, indentsize)
			if orig.menu.extendedinfo[locrowdata[1]] then
				for i, npc in ipairs(npctable) do
					locrowdata = { "info_npconboard", ConvertIDTo64Bit(npc), inputobject }
					local indent = 2 * indentsize
					row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(GetComponentData(npc, "name"), { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
					row[4]:setColSpan(10):createText(GetComponentData(npc, "ownername"), { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
				end
			end
		end

		-- insert build storage details
		local storagemodules = GetStorageData(buildstorage)
		local cargotable = {}
		local numwares = 0
		local sortedwarelist = {}
		for _, storagemodule in ipairs(storagemodules) do
			for _, ware in ipairs(storagemodule) do
				table.insert(sortedwarelist, ware)
			end
		end
		table.sort(sortedwarelist, function(a, b) return a.name < b.name end)
		for _, ware in ipairs(sortedwarelist) do
			table.insert(cargotable, { ware = ware.ware, amount = ware.amount })
			numwares = numwares + 1
		end
		--print("storageinfo_warelist: " .. tostring(storageinfo_warelist) .. " numwares > 0: " .. tostring(numwares > 0))
		--print("buildstorage: " .. ffi.string(C.GetComponentName(buildstorage)) .. " " .. tostring(buildstorage) .. " numwares: " .. tostring(numwares))
		locrowdata = { "info_station_buildstorage", ReadText(20104, 80101) }
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, storageinfo_warelist and (numwares > 0))
		if storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(buildstorage, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(buildstorage, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " (" .. GetComponentData(buildstorage, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " (" .. unknowntext .. "%)")) }	-- Hull
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local loccapacity = storageinfo_capacity and storagemodules.capacity or unknowntext
			local locamount = storageinfo_amounts and storagemodules.stored or unknowntext
			local printedcapacity = ConvertIntegerString(loccapacity, true, 1, true)
			local printedamount = ConvertIntegerString(locamount, true, 1, true)
			local printedfullamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 0, true) or nil
			local printedfullcapacity = (type(loccapacity) == "number") and ConvertIntegerString(loccapacity, true, 0, true) or nil
			local printednumwares = storageinfo_amounts and ConvertIntegerString(numwares, true, 0, true) or unknowntext
			locrowdata = { "info_station_buildstorage_storage", (ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"), (ReadText(1001, 1402) .. ReadText(1001, 120)), (storagemodules.estimated and unknowntext or (printedamount .. " / " .. printedcapacity .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (numwares > 0) and true or false, 1, indentsize, nil, printedfullamount and (printedfullamount .. " / " .. printedfullcapacity .. " " .. ReadText(1001, 110)) or nil)	-- m^3
			if orig.menu.extendedinfo[locrowdata[1]] then
				for _, wareentry in ipairs(cargotable) do
					local ware = wareentry.ware
					local amount = wareentry.amount
					locrowdata = { GetWareData(ware, "name"), amount }
					row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize })
				end
			end
		end

		local productiontable = {}
		local productionmodules = GetProductionModules(object64)
		for i, prodmod in ipairs(productionmodules) do
			-- can query: proddata.cycletime, proddata.estimated, proddata.productionmethod, proddata.state, proddata.remainingcycletime, proddata.remainingtime, proddata.cycleprogress, proddata.efficiency (table), proddata.products (table), proddata.sresources (table), proddata.presources (table)
			-- proddata.state == "empty" == no production
				-- proddata.efficiency[#].product, proddata.efficiency[#].cycle, proddata.efficiency[#].primary
				-- proddata.products: numbered: product (table), proddata.products.efficiency
					-- proddata.products[#].ware, proddata.products[#].name, proddata.products[#].amount, proddata.products[#].component, proddata.products[#].cycle
				-- proddata.sresources: proddata.sresources.efficiency (no production methods currently use secondary resources)
				-- proddata.presources: numbered: presource (table), proddata.presources.efficiency
					-- proddata.presources[#].ware, proddata.presources[#].name, proddata.presources[#].amount, proddata.presources[#].component, proddata.presources[#].cycle
			local proddata = GetProductionModuleData(prodmod)
			if proddata.state ~= "empty" then
				local methodindex = nil
				for j, productionmethod in ipairs(productiontable) do
					if productionmethod.productionmethod == proddata.productionmethod then
						methodindex = j
						break
					end
				end
				local name, ishacked = GetComponentData(prodmod, "name", "ishacked")
				if methodindex then
					table.insert(productiontable[methodindex], { products = {}, primaryresources = {}, efficiency = proddata.products.efficiency, cycletime = proddata.cycletime, cycletimeremaining = proddata.remainingcycletime, modulename = name, moduleindex = i, ishacked = ishacked })
				else
					table.insert(productiontable, { productionmethod = proddata.productionmethod, [1] = { products = {}, primaryresources = {}, efficiency = proddata.products.efficiency, cycletime = proddata.cycletime, cycletimeremaining = proddata.remainingcycletime, modulename = name, moduleindex = i, ishacked = ishacked } })
					methodindex = #productiontable
				end

				for _, product in ipairs(proddata.products) do
					table.insert(productiontable[methodindex][#productiontable[methodindex]].products, { ware = product.ware, name = product.name, amount = product.amount, component = product.component, cycle = product.cycle })
				end
				for _, resource in ipairs(proddata.presources) do
					table.insert(productiontable[methodindex][#productiontable[methodindex]].primaryresources, { ware = resource.ware, name = resource.name, amount = resource.amount, component = resource.component, cycle = resource.cycle })
				end
			end
		end
		table.sort(productiontable, orig.menu.productionSorter)
		locrowdata = { "Production", ReadText(1001, 1600) }	-- Production
		-- switch next two commented-out lines below if we want to make the number of production modules available even if all other information is crossed out.
		--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (#productiontable > 0) and true or false)
		--if #productiontable > 0 and orig.menu.extendedinfo[locrowdata[1]] then
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, productioninfo_products and (#productiontable > 0) and true or false)
		if productioninfo_products and #productiontable > 0 and orig.menu.extendedinfo[locrowdata[1]] then
			for i, productionmethod in ipairs(productiontable) do
				for j, productionmodule in ipairs(productionmethod) do
					if #productionmodule.products > 0 then
						locrowdata = { ("Method" .. i .. "Module" .. j), productioninfo_products and (productionmodule.modulename .. " " .. j) or unknowntext }	-- Production
						-- switch next two commented-out lines below if we want to make the individual production module sections accessible even if all information is crossed out.
						--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 1, indentsize)
						--if orig.menu.extendedinfo[locrowdata[1]] then
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, productioninfo_products and true or false, 1, indentsize)
						if productionmodule.ishacked then
							row[2].properties.color = Helper.color.red
						end
						if productioninfo_products and orig.menu.extendedinfo[locrowdata[1]] then




							if productionmodule.ishacked then
								locrowdata = { false, ReadText(1001, 8426) }
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
								row[2].properties.color = Helper.color.red

								locrowdata = { false, "" }
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
							end

							locrowdata = { false, ReadText(1001, 9418) .. ReadText(1001, 120) }	-- Wares produced per cycle, :
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							for _, product in ipairs(productionmodule.products) do
								locrowdata = { false, productioninfo_products and tostring(product.name) or unknowntext, productioninfo_rate and tostring(product.cycle) or unknowntext }
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)
							end

							-- TODO: @Nick consider: make efficiency dynamic as well to reflect changes?
							locrowdata = { false, (ReadText(1001, 1602) .. ReadText(1001, 120)), (productioninfo_rate and (productionmodule.cycletimeremaining > 0 and math.floor(productionmodule.efficiency * 100) or 0) .. "%" or unknowntext) }	-- Efficiency, :
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)

							local formattedtime = ConvertTimeString(productionmodule.cycletime, "%h:%M:%S")
							locrowdata = { false, ReadText(1001, 9419), productioninfo_time and formattedtime or unknowntext }	-- Time per cycle, d, h, min, s
							--locrowdata = { false, "Time per cycle", Helper.timeDuration(productionmodule.cycletime) }
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							locrowdata = { false, ReadText(1001, 9420) }	-- Time until current cycle completion, d, h, min, s
							row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
							row[2]:setColSpan(7):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
							--row[9]:setColSpan(5):createText(function() return orig.menu.infoSubmenuUpdateProductionTime(object64, productionmodule.moduleindex) end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont) })
							row[9]:setColSpan(5):createText(function() return productioninfo_rate and orig.menu.infoSubmenuUpdateProductionTime(object64, productionmodule.moduleindex) or unknowntext end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })
							--locrowdata = { false, "Time until current cycle completion", function() return Helper.timeDuration(productionmodule.cycletimeremaining) end }
							--row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							locrowdata = { false, (ReadText(1001, 9421) .. ReadText(1001, 120)) }	--Resources needed per cycle, :
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							for _, resource in ipairs(productionmodule.primaryresources) do
								locrowdata = { false, productioninfo_resources and tostring(resource.name) or unknowntext, productioninfo_rate and tostring(resource.cycle) or unknowntext }
								row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)
							end
						end
					end
				end
			end
		end

		local products = {}
		local resources = {}
		for _, productionmethod in ipairs(productiontable) do
			for _, productionmodule in ipairs(productionmethod) do
				for _, product in ipairs(productionmodule.products) do
					-- can query: product.name, product.amount, product.component, product.cycle, product.ware
					if not products[product.ware] then
						--print("products. inserting " .. product.name)
						products[product.ware] = product
						products[product.ware].listed = false
					end
				end
				for _, resource in ipairs(productionmodule.primaryresources) do
					-- can query: resource.name, resource.amount, resource.component, resource.cycle, resource.ware
					if not resources[resource.ware] then
						--print("resources. inserting " .. resource.name)
						resources[resource.ware] = resource
						resources[resource.ware].listed = false
					end
				end
			end
		end
		storagemodules = {capacity = 0, stored = 0}
		if C.IsComponentClass(inputobject, "container") then
			storagemodules = GetStorageData(inputobject)
		end
		cargotable = { products = {text = ReadText(1001, 1610), numcatwares = 0, wares = {}}, resources = {text = ReadText(1001, 41), numcatwares = 0, wares = {}}, storage = {text = ReadText(1001, 1400), numcatwares = 0, wares = {}} }	-- Products, Resources, Storage
		local cargocatindex = { "products", "resources", "storage" }
		numwares = 0
		local sortedwarelist = {}
		-- numbered: ware (see below); storagemodule.name, storagemodule.consumption, storagemodule.stored, storagemodule.capacity
		for _, storagemodule in ipairs(storagemodules) do
			--print("storage module: " .. tostring(storagemodule.name) .. ", consumption: " .. tostring(storagemodule.consumption) .. ", stored: " .. tostring(storagemodule.stored) .. ", capacity: " .. tostring(storagemodule.capacity))
			-- can query: ware.ware, ware.name, ware.amount, ware.consumption, ware.volume
			for _, ware in ipairs(storagemodule) do
				--print("sortedwarelist. inserting stored ware: " .. ware.name)
				table.insert(sortedwarelist, ware)
				if resources[ware.ware] then
					--print("resource: " .. ware.name .. " is already listed.")
					resources[ware.ware].listed = true
				end
				if products[ware.ware] then
					--print("product: " .. ware.name .. " is already listed.")
					products[ware.ware].listed = true
				end
			end
		end
		for _, resource in pairs(resources) do
			if not resource.listed then
				--print("sortedwarelist. inserting resource: " .. resource.name)
				table.insert(sortedwarelist, resource)
			end
		end
		for _, product in pairs(products) do
			if not product.listed then
				--print("sortedwarelist. inserting product: " .. product.name)
				table.insert(sortedwarelist, product)
			end
		end
		table.sort(sortedwarelist, function(a, b) return a.name < b.name end)

		for _, ware in ipairs(sortedwarelist) do
			--print("ware: " .. tostring(ware) .. " " .. tostring(ware.name))
			local usage = "storage"
			if products[ware.ware] then
				usage = "products"
			elseif resources[ware.ware] then
				usage = "resources"
			end
			table.insert(cargotable[usage].wares, { ware = ware.ware, amount = ware.amount })
			cargotable[usage].numcatwares = cargotable[usage].numcatwares + 1
			numwares = numwares + 1
			--print("ware: " .. tostring(ware.name) .. ", usage: " .. usage .. ", consumption: " .. tostring(ware.consumption))
		end
		--print("estimated: " .. tostring(storagemodules.estimated) .. ", productionestimated: " .. tostring(storagemodules.productionestimated))
		local loccapacity = (storagemodules.capacity > 0) and storagemodules.capacity or 0
		local locamount = storageinfo_amounts and storagemodules.stored or unknowntext
		local printedcapacity = ConvertIntegerString(loccapacity, true, 1, true)
		local printedamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 1, true) or locamount
		local printedfullamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 0, true) or nil
		local printedfullcapacity = (type(loccapacity) == "number") and ConvertIntegerString(loccapacity, true, 0, true) or nil
		local printednumwares = storageinfo_amounts and ConvertIntegerString(numwares, true, 0, true) or unknowntext
		locrowdata = { "Storage", (ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"), (ReadText(1001, 1402) .. ReadText(1001, 120)), (storagemodules.estimated and unknowntext or (printedamount .. " / " .. printedcapacity .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (storageinfo_warelist and numwares > 0) and true or false, nil, nil, nil, printedfullamount and (printedfullamount .. " / " .. printedfullcapacity .. " " .. ReadText(1001, 110)) or nil)	-- m^3
		if storageinfo_warelist and (numwares > 0) and orig.menu.extendedinfo[locrowdata[1]] then
			for i, usagecat in ipairs(cargocatindex) do
				if (cargotable[usagecat].numcatwares > 0) then
					--print("adding category: " .. cargotable[usagecat].text)
					locrowdata = { false, (cargotable[usagecat].text .. ReadText(1001, 120)) }	-- :
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata)
					for _, wareentry in ipairs(cargotable[usagecat].wares) do
						local ware = wareentry.ware
						local amount = wareentry.amount
						--print("ware: " .. tostring(ware) .. ", amount: " .. tostring(amount))
						locrowdata = { GetWareData(ware, "name"), amount }
						local printedwarecapacity = GetWareProductionLimit(inputobject, ware)
						if (printedwarecapacity < 1) or (printedwarecapacity < amount) then
							printedwarecapacity = amount
						end
						row = inputtable:addRow(true, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount, max = printedwarecapacity, readOnly = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize })
					end
				end
			end
		end

		local numdockedships = 0
		if C.IsComponentClass(inputobject, "container") then
			numdockedships = C.GetNumDockedShips(inputobject, nil)
		end
		locrowdata = { "info_dockedships", ReadText(1001, 3265) }
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, numdockedships > 0 and true or false)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local dockedships = ffi.new("UniverseID[?]", numdockedships)
			numdockedships = C.GetDockedShips(dockedships, numdockedships, inputobject, nil)
			local playerowneddockedships = {}
			local npcowneddockedships = {}
			for i = 0, numdockedships-1 do
				local locship = ConvertStringTo64Bit(tostring(dockedships[i]))
				if GetComponentData(locship, "isplayerowned") then
					table.insert(playerowneddockedships, locship)
				else
					table.insert(npcowneddockedships, locship)
				end
			end
			table.sort(playerowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)
			table.sort(npcowneddockedships, function(a, b) return GetComponentData(a, "size") > GetComponentData(b, "size") end)

			--local totaldockedships = 0
			for i, shipid in ipairs(playerowneddockedships) do
				local shipname = ffi.string(C.GetComponentName(shipid))
				local iconid = GetComponentData(shipid, "icon")
				if iconid and iconid ~= "" then
					shipname = string.format("\027[%s] %s", iconid, shipname)
				end
				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				--row = inputtable:addRow(("info_dockedship" .. i), { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(shipname, { color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
				row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", color = Helper.color.green, x = Helper.standardTextOffsetx + indentsize })
				--totaldockedships = i
			end
			for i, shipid in ipairs(npcowneddockedships) do
				local shipname = ffi.string(C.GetComponentName(shipid))
				local iconid = GetComponentData(shipid, "icon")
				if iconid and iconid ~= "" then
					shipname = string.format("\027[%s] %s", iconid, shipname)
				end
				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				--row = inputtable:addRow(("info_dockedship" .. totaldockedships+i), { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(shipname, { x = Helper.standardTextOffsetx + indentsize })
				row[4]:setColSpan(10):createText(("(" .. ffi.string(C.GetObjectIDCode(shipid)) .. ")"), { halign = "right", x = Helper.standardTextOffsetx + indentsize })
			end
		end

		local nummissiletypes = C.GetNumAllMissiles(inputobject)
		local missilestoragetable = ffi.new("AmmoData[?]", nummissiletypes)
		nummissiletypes = C.GetAllMissiles(missilestoragetable, nummissiletypes, inputobject)
		local totalnummissiles = 0
		for i = 0, nummissiletypes - 1 do
			totalnummissiles = totalnummissiles + missilestoragetable[i].amount
		end
		local missilecapacity = 0
		if C.IsComponentClass(inputobject, "defensible") then
			missilecapacity = GetComponentData(inputobject, "missilecapacity")
		end
		local locmissilecapacity = defenceinfo_low and tostring(missilecapacity) or unknowntext
		local locnummissiles = defenceinfo_high and tostring(totalnummissiles) or unknowntext
		locrowdata = { "Ammunition", ReadText(1001, 2800), (locnummissiles .. " / " .. locmissilecapacity) }	-- Ammunition
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnummissiles > 0) and true or false)
		if defenceinfo_high and orig.menu.extendedinfo[locrowdata[1]] then
			for i = 0, nummissiletypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(missilestoragetable[i].macro), "name"), (tostring(missilestoragetable[i].amount) .. " / " .. tostring(missilestoragetable[i].capacity)) }
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end

		local unitstoragetable = {capacity = 0, stored = 0}
		if C.IsComponentClass(inputobject, "defensible") then
			unitstoragetable = GetUnitStorageData(inputobject)
		end
		local locunitcapacity = unitinfo_capacity and tostring(unitstoragetable.capacity) or unknowntext
		local locunitcount = unitinfo_capacity and tostring(unitstoragetable.stored) or unknowntext
		locrowdata = {"Drones", ReadText(1001, 8), (locunitcount .. " / " .. locunitcapacity)}	-- Drones
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (unitinfo_details and unitstoragetable.stored > 0) and true or false)
		if unitinfo_details and orig.menu.extendedinfo[locrowdata[1]] then
			for i = 1, #unitstoragetable do
				if unitstoragetable[i].amount > 0 or unitstoragetable[i].unavailable > 0 then
					locrowdata = { false, unitstoragetable[i].name, (unitstoragetable[i].amount .. " / " .. unitstoragetable.capacity .. " (" .. unitstoragetable[i].unavailable .. " " .. ReadText(1001, 9408) .. ")") }
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end
		end

		local showloadout = defenceinfo_high and (#loadout.component.turret > 0 or #loadout.component.shield > 0)
		locrowdata = { "Loadout", ReadText(1001, 9413) }	-- Loadout 
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, showloadout)
		if showloadout and orig.menu.extendedinfo[locrowdata[1]] then
			if #loadout.component.turret > 0 then
				locrowdata = { "Turrets", ReadText(1001, 1319) }	-- turrets
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.turret)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.shield > 0 then
				locrowdata = { "Shield Generators", ReadText(1001, 1317) }	-- Shield Generators
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if orig.menu.extendedinfo[locrowdata[1]] then
					local locmacros = orig.menu.infoCombineLoadoutComponents(loadout.component.shield)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
		end

		-- TODO: figure out and implement economy statistics
		locrowdata = { "Economy Statistics", ReadText(1001, 1131) }	-- Economy Statistics
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, false)

	elseif mode == "sector" then
		--print("sector ID: " .. tostring(inputobject))
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)
		row[1].properties.color = titlecolor

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = editname}):setText(editname)
				row[4].handlers.onEditBoxActivated = function(_, inputtable, editname) return Helper.updateEditBoxText(inputtable,4,10,editname) end
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local stationtable = GetContainedStations(object64, true)
			local numstations = #stationtable
			local productiontable = {}
			local products = {}
			local sectorpopulation = 0
			for _, station in ipairs(stationtable) do
				local workforceinfo = C.GetWorkForceInfo(ConvertStringTo64Bit(tostring(station)), "")
				sectorpopulation = sectorpopulation + workforceinfo.current
				table.insert(productiontable, GetComponentData(station, "products"))
			end
			for _, entry in ipairs(productiontable) do
				for _, product in ipairs(entry) do
					local notincremented = true
					for compproduct, count in pairs(products) do
						if compproduct == product then
							products[product] = count + 1
							notincremented = false
							break
						end
					end
					if notincremented then
						products[product] = 1
					end
				end
			end
			local maxproductgrp = ReadText(1001, 9002)	-- Unknown
			local maxcount = 0
			for product, count in pairs(products) do
				if not maxproductgrp or (count > maxcount) then
					maxproductgrp = GetWareData(product, "groupName")
					maxcount = count
				end
			end

			-- TODO: review. currently looks at total known station workforce in the sector.
			locrowdata = { false, ReadText(1001, 9041), sectorpopulation }	-- Population
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9042), (numstations > 0 and numstations or 0) }	-- Known Stations
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9050), maxproductgrp }	-- Main Production
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end

		locrowdata = { "Natural Resources", ReadText(1001, 9423) }	-- Natural Resources
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local sunlight = (GetComponentData(object64, "sunlight") * 100 .. "%")
			locrowdata = { false, ReadText(1001, 2412), sunlight }	-- Sunlight
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			-- TODO: Add Region info: NB: Matthias says that yield numbers for regions could be too big to be useful, and that retrieving that info is very inefficient. But we'll try when the function is up.

		end
	elseif mode == "gate" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local isgateactive = GetComponentData(object64, "isactive")
			local gatedestinationid
			local gatedestination = unknowntext
			if isgateactive then
				gatedestinationid = GetComponentData(GetComponentData(object64, "destination"), "sectorid")
				local gatedestinationid64 = ConvertStringTo64Bit(tostring(gatedestinationid))
				gatedestination = C.IsInfoUnlockedForPlayer(gatedestinationid64, "name") and ffi.string(C.GetComponentName(gatedestinationid64)) or unknowntext
			end
			locrowdata = { false, ReadText(1001, 3215), tostring(gatedestination) }	-- (gate) Destination
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local destinationowner = unknowntext
			if gatedestination ~= unknowntext then
				destinationowner = GetComponentData(gatedestinationid, "ownername")
			end
			locrowdata = { false, ReadText(1001, 9424), tostring(destinationowner) }	-- Destination Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9425), (isgateactive and ReadText(1001, 2617) or ReadText(1001, 2618)) }	-- Active, Yes, No
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end
	elseif mode == "deployable" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: orig.menu.infoeditname cleared at the end of this function.
			if isplayerowned and orig.menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = editname}):setText(editname)
				row[4].handlers.onEditBoxActivated = function(_, inputtable, editname) return Helper.updateEditBoxText(inputtable,4,10,editname) end
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return orig.menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(inputobject, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(inputobject, "sector") }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(inputobject, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local radarrange = defenceinfo_low and GetComponentData(inputobject, "maxradarrange") or unknowntext

			if C.IsComponentClass(orig.menu.infoSubmenuObject, "mine") then
				-- add if mines are made selectable in the map again:
				--	detonation output (s), tracking capability (s), friend/foe (s), proximity (s)
			elseif C.IsComponentClass(orig.menu.infoSubmenuObject, "resourceprobe") then
				if radarrange and radarrange ~= unknowntext then
					radarrange = Helper.round(radarrange / 1000)
				end
				locrowdata = { "info_radarrange", ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 9082)) }	-- Scannning Range, km
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			elseif C.IsComponentClass(orig.menu.infoSubmenuObject, "satellite") then
				if radarrange and radarrange ~= unknowntext then
					radarrange = Helper.round(radarrange / 1000)
				end
				locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
				row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end
	elseif mode == "missionboard" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(inputobject, "ownername")) }	-- Owner
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(inputobject, "sector") }	-- Location
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hullmax")), true, 4, true, true, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hull")), true, 4, true, true, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end
	elseif mode == "asteroid" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if orig.menu.extendedinfo[locrowdata[1]] then
			local rawlength = GetComponentData(inputobject, "length")
			local rawwidth = GetComponentData(inputobject, "width")
			local rawheight = GetComponentData(inputobject, "height")
			local loclength = ConvertIntegerString(rawlength, true, 0, true)
			local locwidth = ConvertIntegerString(rawwidth, true, 0, true)
			local locheight = ConvertIntegerString(rawheight, true, 0, true)
			locrowdata = { false, ReadText(1001, 9229), (loclength .. ReadText(1001, 107) .. " " .. ReadText(1001, 42) .. " " .. locwidth .. ReadText(1001, 107) .. " " .. ReadText(1001, 42) .. " " .. locheight .. ReadText(1001, 107)) }	-- TEMPTEXT, m, x
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local rawvolume = rawlength * rawwidth * rawheight
			local locvolume = ConvertIntegerString(rawvolume, true, 0, true)
			locrowdata = { false, ReadText(1001, 1407), (locvolume .. " " .. ReadText(1001, 110)) }	-- Volume, m^3
			row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local wares = GetComponentData(inputobject, "wares")
			local hasyield = false
			if wares then
				for _, ware in ipairs(wares) do
					if ware.amount > 0 then
						hasyield = true
						break
					end
				end

				if hasyield then
					locrowdata = { false, ReadText(1001, 3214) .. ReadText(1001, 120) }	-- Yield, :
					row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

					for i, ware in ipairs(wares) do
						if ware.amount > 0 then
							local warename = GetWareData(ware.ware, "name")
							locrowdata = { false, warename, ware.amount }
							row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
						end
					end
				end
			end
		end
	elseif mode == "none" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_none", ReadText(1001, 6526) }
		row = orig.menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false)
	else
		DebugError("orig.menu.setupInfoSubmenuRows(): called with unsupported mode: " .. tostring(mode) .. ".")
	end

	if orig.menu.infoeditname then
		orig.menu.infoeditname = nil
	end
end
end

function utRenaming.infoChangeObjectName(objectid, text, textchanged)
    if textchanged then
		SetComponentName(objectid, text)
	end
    -- UniTrader change: Set Signal Universe/Object instead of actual renaming (whih is handled in MD)
    SignalObject(GetComponentData(objectid, "galaxyid" ) , "Object Name Updated" , { ConvertStringToLuaID(tostring(objectid)) , objectid } , text)
    -- UniTrader Changes end (next line was a if before, but i have some diffrent conditions)

	orig.menu.noupdate = false
	orig.menu.refreshInfoFrame()
end

init()