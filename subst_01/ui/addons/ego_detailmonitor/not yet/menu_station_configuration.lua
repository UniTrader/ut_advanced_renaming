-- section == cArch_configureStation
-- param == { 0, 0, container }
 
-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t UniverseID;
	typedef struct {
		const char* macro;
		const char* ware;
		const char* productionmethodid;
	} UIBlueprint;
	typedef struct {
		const char* name;
		const char* id;
		const char* source;
		bool deleteable;
	} UIConstructionPlan;
	typedef struct {
		const char* macro;
		uint32_t amount;
		bool optional;
	} UILoadoutAmmoData;
	typedef struct {
		const char* macro;
		const char* path;
		const char* group;
		uint32_t count;
		bool optional;
	} UILoadoutGroupData;
	typedef struct {
		const char* macro;
		const char* upgradetypename;
		size_t slot;
		bool optional;
	} UILoadoutMacroData;
	typedef struct {
		const char* ware;
	} UILoadoutSoftwareData;
	typedef struct {
		const char* macro;
		bool optional;
	} UILoadoutVirtualMacroData;
	typedef struct {
		uint32_t numweapons;
		uint32_t numturrets;
		uint32_t numshields;
		uint32_t numengines;
		uint32_t numturretgroups;
		uint32_t numshieldgroups;
		uint32_t numammo;
		uint32_t numunits;
		uint32_t numsoftware;
	} UILoadoutCounts;
	typedef struct {
		UILoadoutMacroData* weapons;
		uint32_t numweapons;
		UILoadoutMacroData* turrets;
		uint32_t numturrets;
		UILoadoutMacroData* shields;
		uint32_t numshields;
		UILoadoutMacroData* engines;
		uint32_t numengines;
		UILoadoutGroupData* turretgroups;
		uint32_t numturretgroups;
		UILoadoutGroupData* shieldgroups;
		uint32_t numshieldgroups;
		UILoadoutAmmoData* ammo;
		uint32_t numammo;
		UILoadoutAmmoData* units;
		uint32_t numunits;
		UILoadoutSoftwareData* software;
		uint32_t numsoftware;
		UILoadoutVirtualMacroData thruster;
	} UILoadout;
	typedef struct {
		const char* id;
		const char* name;
		const char* iconid;
		bool deleteable;
	} UILoadoutInfo;
	typedef struct {
		const char* upgradetype;
		size_t slot;
	} UILoadoutSlot;
	typedef struct {
		const float x;
		const float y;
		const float z;
		const float yaw;
		const float pitch;
		const float roll;
	} UIPosRot;
	typedef struct {
		const char* ware;
		const char* macro;
		int amount;
	} UIWareInfo;
	typedef struct {
		const char* path;
		const char* group;
	} UpgradeGroup;
	typedef struct {
		UniverseID currentcomponent;
		const char* currentmacro;
		const char* slotsize;
		uint32_t count;
		uint32_t total;
	} UpgradeGroupInfo;
	typedef struct {
		UniverseID reserverid;
		const char* ware;
		uint32_t amount;
		bool isbuyreservation;
		double eta;
	} WareReservationInfo;

	typedef struct {
		size_t idx;
		const char* macroid;
		UniverseID componentid;
		UIPosRot offset;
		const char* connectionid;
		size_t predecessoridx;
		const char* predecessorconnectionid;
		bool isfixed;
	} UIConstructionPlanEntry;
	void AddFloatingSequenceToConstructionPlan(UniverseID holomapid);
	void AddCopyToConstructionMap(UniverseID holomapid, size_t cp_idx, bool copysequence);
	void AddMacroToConstructionMap(UniverseID holomapid, const char* macroname, bool startdragging);
	bool CanBuildLoadout(UniverseID containerid, UniverseID defensibleid, const char* macroname, const char* loadoutid);
	void ClearBuildMapSelection(UniverseID holomapid);
	void DeselectMacroForConstructionMap(UniverseID holomapid);
	void GenerateModuleLoadout(UILoadout* result, UniverseID holomapid, size_t cp_idx, UniverseID defensibleid, float level);
	void GenerateModuleLoadoutCounts(UILoadoutCounts* result, UniverseID holomapid, size_t cp_idx, UniverseID defensibleid, float level);
	uint32_t GetAssignedConstructionVessels(UniverseID* result, uint32_t resultlen, UniverseID containerid);
	uint32_t GetBlueprints(UIBlueprint* result, uint32_t resultlen, const char* set, const char* category, const char* macroname);
	size_t GetBuildMapConstructionPlan(UniverseID holomapid, UniverseID defensibleid, bool usestoredplan, UIConstructionPlanEntry* result, uint32_t resultlen);
	uint32_t GetCargo(UIWareInfo* result, uint32_t resultlen, UniverseID containerid, const char* tags);
	uint32_t GetConstructionPlans(UIConstructionPlan* result, uint32_t resultlen);
	void GetConstructionMapItemLoadout(UILoadout* result, UniverseID holomapid, size_t itemidx, UniverseID defensibleid);
	void GetConstructionMapItemLoadoutCounts(UILoadoutCounts* result, UniverseID holomapid, size_t itemidx, UniverseID defensibleid);
	float GetContainerGlobalPriceFactor(UniverseID containerid);
	uint32_t GetContainerWareReservations(WareReservationInfo* result, uint32_t resultlen, UniverseID containerid);
	UniverseID GetContextByClass(UniverseID componentid, const char* classname, bool includeself);
	float GetCurrentBuildProgress(UniverseID containerid);
	void GetCurrentLoadout(UILoadout* result, UniverseID defensibleid, UniverseID moduleid);
	void GetCurrentLoadoutCounts(UILoadoutCounts* result, UniverseID defensibleid, UniverseID moduleid);
	void GetLoadout(UILoadout* result, UniverseID defensibleid, const char* macroname, const char* loadoutid);
	uint32_t GetLoadoutCounts(UILoadoutCounts* result, UniverseID defensibleid, const char* macroname, const char* loadoutid);
	uint32_t GetLoadoutsInfo(UILoadoutInfo* result, uint32_t resultlen, UniverseID componentid, const char* macroname);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	const char* GetMissingConstructionPlanBlueprints(UniverseID containerid, const char* constructionplanid);
	uint32_t GetNumAssignedConstructionVessels(UniverseID containerid);
	uint32_t GetNumBlueprints(const char* set, const char* category, const char* macroname);
	size_t GetNumBuildMapConstructionPlan(UniverseID holomapid, bool usestoredplan);
	uint32_t GetNumCargo(UniverseID containerid, const char* tags);
	uint32_t GetNumConstructionPlans(void);
	uint32_t GetNumContainerWareReservations(UniverseID containerid);
	uint32_t GetNumLoadoutsInfo(UniverseID componentid, const char* macroname);
	uint32_t GetNumRemovedConstructionPlanModules(UniverseID holomapid, UniverseID defensibleid, uint32_t* newIndex, bool usestoredplan);
	uint32_t GetNumUpgradeGroups(UniverseID destructibleid, const char* macroname);
	size_t GetNumUpgradeSlots(UniverseID destructibleid, const char* macroname, const char* upgradetypename);
	uint32_t GetNumWares(const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	bool GetPickedBuildMapEntry(UniverseID holomapid, UniverseID defensibleid, UIConstructionPlanEntry* result);
	void SelectPickedBuildMapEntry(UniverseID holomapid);
	bool GetPickedMapMacroSlot(UniverseID holomapid, UniverseID defensibleid, UniverseID moduleid, const char* macroname, bool ismodule, UILoadoutSlot* result);
	uint32_t GetRemovedConstructionPlanModules(UniverseID* result, uint32_t resultlen);
	size_t GetSelectedBuildMapEntry(UniverseID holomapid);
	UpgradeGroupInfo GetUpgradeGroupInfo(UniverseID destructibleid, const char* macroname, const char* path, const char* group, const char* upgradetypename);
	uint32_t GetUpgradeGroups(UpgradeGroup* result, uint32_t resultlen, UniverseID destructibleid, const char* macroname);
	const char* GetUpgradeSlotCurrentMacro(UniverseID objectid, UniverseID moduleid, const char* upgradetypename, size_t slot);
	UpgradeGroup GetUpgradeSlotGroup(UniverseID destructibleid, const char* macroname, const char* upgradetypename, size_t slot);
	uint32_t GetWares(const char** result, uint32_t resultlen, const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	bool IsIconValid(const char* iconid);
	bool IsMasterVersion(void);
	bool IsNextStartAnimationSkipped(bool reset);
	bool IsUpgradeGroupMacroCompatible(UniverseID destructibleid, const char* macroname, const char* path, const char* group, const char* upgradetypename, const char* upgrademacroname);
	bool IsUpgradeMacroCompatible(UniverseID objectid, UniverseID moduleid, const char* macroname, bool ismodule, const char* upgradetypename, size_t slot, const char* upgrademacroname);
	void ReleaseConstructionMapState(void);
	bool RemoveConstructionPlan(const char* source, const char* id);
	void RemoveItemFromConstructionMap(UniverseID holomapid, size_t itemidx);
	void ResetMapPlayerRotation(UniverseID holomapid);
	void SaveLoadout(const char* macroname, UILoadout uiloadout, const char* source, const char* id, bool overwrite, const char* name, const char* desc);
	void SaveMapConstructionPlan(UniverseID holomapid, const char* source, const char* id, bool overwrite, const char* name, const char* desc);
	void SelectBuildMapEntry(UniverseID holomapid, size_t cp_idx);
	void SetConstructionSequenceFromConstructionMap(UniverseID containerid, UniverseID holomapid);
	void SetContainerGlobalPriceFactor(UniverseID containerid, float value);
	void SetSelectedMapGroup(UniverseID holomapid, UniverseID destructibleid, const char* macroname, const char* path, const char* group);
	void SetSelectedMapMacroSlot(UniverseID holomapid, UniverseID defensibleid, UniverseID moduleid, const char* macroname, bool ismodule, const char* upgradetypename, size_t slot);
	void SetMapPicking(UniverseID holomapid, bool enable);
	void ShowConstructionMap(UniverseID holomapid, UniverseID stationid, const char* constructionplanid, bool restore);
	void ShowObjectConfigurationMap(UniverseID holomapid, UniverseID defensibleid, UniverseID moduleid, const char* macroname, bool ismodule, UILoadout uiloadout);
	bool ShuffleMapConstructionPlan(UniverseID holomapid, bool checkonly);
	void StartPanMap(UniverseID holomapid);
	void StartRotateMap(UniverseID holomapid);
	bool StopPanMap(UniverseID holomapid);
	bool StopRotateMap(UniverseID holomapid);
	void StoreConstructionMapState(UniverseID holomapid);
	void UpdateConstructionMapItemLoadout(UniverseID holomapid, size_t itemidx, UniverseID defensibleid, UILoadout uiloadout);
	void UpdateObjectConfigurationMap(UniverseID holomapid, UniverseID defensibleid, UniverseID moduleid, const char* macroname, bool ismodule, UILoadout uiloadout);
	void ZoomMap(UniverseID holomapid, float zoomstep);
	bool CanUndoConstructionMapChange(UniverseID holomapid);
	void UndoConstructionMapChange(UniverseID holomapid);
	bool CanRedoConstructionMapChange(UniverseID holomapid);
	void RedoConstructionMapChange(UniverseID holomapid);

	uint32_t PrepareBuildSequenceResources(UniverseID holomapid, UniverseID stationid);
	uint32_t GetBuildSequenceResources(UIWareInfo* result, uint32_t resultlen);
	uint32_t GetNumModuleRecycledResources(UniverseID moduleid);
	uint32_t GetModuleRecycledResources(UIWareInfo* result, uint32_t resultlen, UniverseID moduleid);
	uint32_t GetNumModuleNeededResources(UniverseID holomapid, size_t cp_idx);
	uint32_t GetModuleNeededResources(UIWareInfo* result, uint32_t resultlen, UniverseID holomapid, size_t cp_idx);
]]

local utf8 = require("utf8")

local menu = {
	name = "StationConfigurationMenu",
	newWareReservationWares = {},
}

local config = {
	mainLayer = 5,
	infoLayer = 4,
	contextLayer = 3,
	leftBar = {
		{ name = ReadText(1001, 2421),	icon = "stationbuildst_production",		mode = "moduletypes_production" },
		{ name = ReadText(1001, 2439),	icon = "stationbuildst_buildmodule",	mode = "moduletypes_build" },
		{ name = ReadText(1001, 2422),	icon = "stationbuildst_storage",		mode = "moduletypes_storage" },
		{ name = ReadText(1001, 2451),	icon = "stationbuildst_habitation",		mode = "moduletypes_habitation" },
		{ name = ReadText(1001, 2452),	icon = "stationbuildst_dock",			mode = "moduletypes_dock" },
		{ name = ReadText(1001, 2424),	icon = "stationbuildst_defense",		mode = "moduletypes_defence" },
		{ name = ReadText(1001, 2453),	icon = "stationbuildst_other",			mode = "moduletypes_other" },
		{ name = ReadText(1001, 2454),	icon = "stationbuildst_venture",		mode = "moduletypes_venture" },
	},
	leftBarLoadout = {
		{ name = ReadText(1001, 7901),	icon = "shipbuildst_turretgroups",		mode = "group" },
	},
	rightBar = {
		{ name = ReadText(1001, 7902), icon = "mapst_plotmanagement", mode = "construction" },
		{ name = ReadText(1001, 7903), icon = "stationbuildst_lsov", mode = "logical" }
	},
	equipmentBlueprintGroups = {
		{ type = "turret", library = "weapons_turrets" },
		{ type = "turret", library = "weapons_missileturrets" },
		{ type = "shield", library = "shieldgentypes" },
	},
	dropDownTextProperties = {
		halign = "center",
		font = Helper.standardFont,
		fontsize = Helper.scaleFont(Helper.standardFont, Helper.standardFontSize),
		color = Helper.color.white,
		x = 0,
		y = 0
	},
	scaleSize = 2,
	stateKeys = {
		{ "container", "UniverseID" },
		{ "buildstorage", "UniverseID" },
		{ "loadoutModuleIdx" },
	},
	sizeSorting = {
		["small"] = 1,
		["medium"] = 2,
		["large"] = 3,
		["extralarge"] = 4,
	},
}

local L = {
	["Reset view"] = ffi.string(C.GetLocalizedText(1026, 7911, ReadText(1026, 7902))),
}

local function init()
	Menus = Menus or {}
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
	menu.extendedentries = {}
	menu.extendedresourceentries = {}
end

function menu.cleanup()
	UnregisterEvent("newWareReservation", menu.newWareReservationCallback)

	menu.container = nil
	menu.buildstorage = nil
	menu.modules = {}
	menu.modulesMode = nil
	menu.planMode = nil
	menu.searchtext = ""
	menu.loadoutName = ""
	menu.loadout = nil
	menu.activatemap = nil
	menu.constructionplan = {}
	menu.constructionplans = {}
	menu.groupedmodules = {}
	menu.groupedupgrades = {}
	menu.groupedslots = {}
	menu.loadoutMode = nil
	menu.loadoutModule = {}
	menu.upgradetypeMode = nil
	menu.currentSlot = nil
	menu.slots = {}
	menu.groups = {}
	menu.newAccountValue = nil
	menu.newWareReservation = nil
	menu.newWareReservationWares = {}
	menu.selectedModule = nil
	menu.newSelectedModule = nil

	menu.picking = true

	SetMouseOverOverride(menu.map, nil)

	if menu.holomap ~= 0 then
		C.RemoveHoloMap()
		menu.holomap = 0
	end

	menu.frameworkData = {}
	menu.modulesData = {}
	menu.planData = {}
	menu.titleData = {}
	menu.mapData = {}

	menu.leftbartable = nil
	menu.rightbartable = nil
	menu.titlebartable = nil
	menu.map = nil
	menu.moduletable = nil
	menu.plantable = nil
	menu.editedLoadouts = {}

	menu.currentCPID = nil
	menu.currentCPName = nil
	menu.canundo = nil
	menu.canredo = nil

	menu.topRows = {}
	menu.selectedRows = {}
	menu.selectedCols = {}
	
	UnregisterAddonBindings("ego_detailmonitor", "undo")
end

-- button scripts

function menu.buttonLeftBar(mode, row)
	menu.prevModulesMode = menu.modulesMode
	AddUITriggeredEvent(menu.name, mode, menu.modulesMode == mode and "off" or "on")
	if menu.modulesMode == mode then
		PlaySound("ui_negative_back")
		menu.modulesMode = nil
	else
		menu.setdefaulttable = true
		PlaySound("ui_positive_select")
		menu.modulesMode = mode
	end
	
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.displayMenu()
end

function menu.buttonLeftBarLoadout(mode, row)
	menu.prevUpgradetypeMode = menu.upgradetypeMode
	AddUITriggeredEvent(menu.name, mode, menu.upgradetypeMode == mode and "off" or "on")
	if menu.upgradetypeMode == mode then
		PlaySound("ui_negative_back")
		menu.upgradetypeMode = nil
	else
		menu.setdefaulttable = true
		PlaySound("ui_positive_select")
		menu.upgradetypeMode = mode
	end
	menu.currentSlot = 1

	if menu.upgradetypeMode == "group" then
		local group = menu.groups[menu.currentSlot]
		C.SetSelectedMapGroup(menu.holomap, menu.loadoutModule.component, menu.loadoutModule.macro, group.path, group.group)
	else
		C.ClearSelectedMapMacroSlots(menu.holomap)
	end

	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.displayMenu()
end

function menu.deactivateModulesMode()
	menu.prevModulesMode = menu.modulesMode
	PlaySound("ui_negative_back")
	menu.modulesMode = nil
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.displayMenu()
end

function menu.deactivateUpgradetypeMode()
	menu.prevUpgradetypeMode = menu.upgradetypeMode
	PlaySound("ui_negative_back")
	menu.upgradetypeMode = nil
	menu.currentSlot = 1
	C.ClearSelectedMapMacroSlots(menu.holomap)
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.displayMenu()
end

function menu.buttonRightBar(mode, row)
	if mode == "logical" then
		C.StoreConstructionMapState(menu.holomap)
		menu.mapstate = ffi.new("HoloMapState")
		C.GetMapState(menu.holomap, menu.mapstate)

		Helper.closeMenuAndOpenNewMenu(menu, "StationOverviewMenu", { 0, 0, ConvertStringToLuaID(tostring(menu.container)) }, true)
		menu.cleanup()
	end
end

function menu.buttonSelectSlot(slot, row, col)
	if menu.currentSlot ~= slot then
		menu.currentSlot = slot
	end
	
	if menu.upgradetypeMode == "group" then
		local group = menu.groups[menu.currentSlot]
		C.SetSelectedMapGroup(menu.holomap, menu.loadoutModule.component, menu.loadoutModule.macro, group.path, group.group)
	end
	
	menu.topRows.modules = GetTopRow(menu.moduletable)
	menu.selectedRows.modules = row
	menu.selectedCols.modules = col
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.displayMenu()
end

function menu.buttonSelectGroupUpgrade(type, group, macro, row, col, keepcontext)
	if not keepcontext then
		menu.closeContextMenu()
	end

	local upgradetype = Helper.findUpgradeType(type)

	if (upgradetype.supertype == "group") then
		if macro ~= menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].macro then
			menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].macro = macro
			if (macro ~= "") and (menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].count == 0) then
				menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].count = 1
			elseif (macro == "") and (menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].count ~= 0) then
				menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].count = 0
			end
			
			menu.topRows.modules = GetTopRow(menu.moduletable)
			menu.selectedRows.modules = row
			menu.selectedCols.modules = col
			menu.topRows.plan = GetTopRow(menu.plantable)
			menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
			menu.refreshPlan()
			menu.displayMenu()
		end
	end

	if menu.holomap and (menu.holomap ~= 0) then
		Helper.callLoadoutFunction(menu.constructionplan[menu.loadoutMode].upgradeplan, nil, function (loadout, _) return C.UpdateObjectConfigurationMap(menu.holomap, menu.container, menu.loadoutModule.component, menu.loadoutModule.macro, true, loadout) end)
	end

	if keepcontext then
		menu.topRows.context = GetTopRow(menu.contexttable)
		menu.selectedRows.context = keepcontext
		menu.displayContextMenu()
	end
end

function menu.buttonClearEditbox(row)
	Helper.cancelEditBoxInput(menu.moduletable, row, 1)
	menu.searchtext = ""

	menu.displayMenu()
end

function menu.buttonExtendEntry(index, row)
	menu.extendEntry(menu.container, index)
	
	menu.topRows.modules = GetTopRow(menu.moduletable)
	menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
	menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = row
	menu.displayMenu()
end

function menu.buttonExtendResourceEntry(index, row)
	menu.extendResourceEntry(index)
	
	menu.topRows.modules = GetTopRow(menu.moduletable)
	menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
	menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = row
	menu.displayMenu()
end

function menu.buttonAddModule(macro, row, col)
	C.AddMacroToConstructionMap(menu.holomap, macro, true)
	SetMouseCursorOverride("crossarrows")
	SelectRow(menu.moduletable, row)
	SelectColumn(menu.moduletable, col)
	Helper.closeDropDownOptions(menu.titlebartable, 1, 2)
end

function menu.buttonRemoveModule(module)
	C.RemoveItemFromConstructionMap(menu.holomap, module.idx)
	menu.closeContextMenu()
	
	menu.topRows.modules = GetTopRow(menu.moduletable)
	menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
	menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.refreshPlan()
	menu.displayMenu()
end

function menu.buttonCopyModule(module, copysequence)
	C.AddCopyToConstructionMap(menu.holomap, module.idx, copysequence)
	menu.closeContextMenu()
end

function menu.buttonEditLoadout(module)
	local found
	for i, entry in ipairs(menu.constructionplan) do
		if entry.idx == module.idx then
			found = i
		end
	end

	if found then
		if not menu.loadoutMode then
			C.StoreConstructionMapState(menu.holomap)
			menu.mapstate = ffi.new("HoloMapState")
			C.GetMapState(menu.holomap, menu.mapstate)
		else
			table.insert(menu.editedLoadouts, menu.loadoutMode)
		end
		menu.loadoutMode = found
		menu.loadoutModule = module
		menu.currentSlot = 1
		menu.extendEntry(menu.container, tonumber(module.idx) + 1, true, true)

		Helper.callLoadoutFunction(module.upgradeplan, nil, function (loadout, _) return C.ShowObjectConfigurationMap(menu.holomap, menu.container, menu.loadoutModule.component, menu.loadoutModule.macro, true, loadout) end)

		menu.getUpgradeData(module.upgradeplan)

		menu.upgradetypeMode = "group"
		if menu.groups[menu.currentSlot] then
			local group = menu.groups[menu.currentSlot]
			C.SetSelectedMapGroup(menu.holomap, menu.loadoutModule.component, menu.loadoutModule.macro, group.path, group.group)
		end

		menu.closeContextMenu()

		menu.displayMainFrame()
		menu.displayMenu()
	end
end

function menu.buttonConfirmMoney()
	if menu.newAccountValue then
		local convertedComponent = ConvertStringTo64Bit(tostring(menu.buildstorage))
		local buildstoragemoney = GetComponentData(convertedComponent, "money")
		local amount = menu.newAccountValue - buildstoragemoney
		if amount > 0 then
			TransferPlayerMoneyTo(amount, convertedComponent)
		else
			TransferMoneyToPlayer(-amount, convertedComponent)
		end
		menu.newAccountValue = nil

		menu.topRows.plan = GetTopRow(menu.plantable)
		menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
		menu.displayMenu()
	end
end

function menu.buttonConfirm()
	C.SetConstructionSequenceFromConstructionMap(menu.container, menu.holomap)
	Helper.closeMenu(menu, "back")
	menu.cleanup()
end

function menu.showConstructionMap()
	C.ShowConstructionMap(menu.holomap, menu.container, "", true)
	if menu.mapstate then
		C.SetMapState(menu.holomap, menu.mapstate)
		menu.mapstate = nil
	end
end

function menu.buttonConfirmLoadout()
	menu.showConstructionMap()

	for i, _ in pairs(menu.editedLoadouts) do
		local entry = menu.constructionplan[i]
		if entry.idx ~= menu.loadoutModule.idx then
			Helper.callLoadoutFunction(entry.upgradeplan, nil, function (loadout, _) return C.UpdateConstructionMapItemLoadout(menu.holomap, entry.idx, menu.container, loadout) end)
		end
	end
	Helper.callLoadoutFunction(menu.constructionplan[menu.loadoutMode].upgradeplan, nil, function (loadout, _) return C.UpdateConstructionMapItemLoadout(menu.holomap, menu.loadoutModule.idx, menu.container, loadout) end)

	menu.loadoutMode = nil
	menu.loadoutModule = {}
	menu.editedLoadouts = {}

	menu.closeContextMenu()

	menu.displayMainFrame()
	menu.refreshPlan()
	menu.displayMenu()
end

function menu.buttonCancelLoadout()
	menu.showConstructionMap()

	menu.loadoutMode = nil
	menu.loadoutModule = {}
	menu.loadout = nil

	menu.closeContextMenu()
	
	menu.displayMainFrame()
	menu.refreshPlan()
	menu.displayMenu()
end

function menu.buttonContextEncyclopedia(selectedUpgrade)
	if selectedUpgrade.type == "module" then
		local library = GetMacroData(selectedUpgrade.macro, "infolibrary")
		Helper.closeMenuAndOpenNewMenu(menu, "EncyclopediaMenu", { 0, 0, "Stations", library, selectedUpgrade.macro })
		menu.cleanup()
	else
		local upgradetype = Helper.findUpgradeType(selectedUpgrade.type)

		if (upgradetype.supertype == "macro") or (upgradetype.supertype == "virtualmacro") or (upgradetype.supertype == "group") then
			local library = GetMacroData(selectedUpgrade.macro, "infolibrary")
			Helper.closeMenuAndOpenNewMenu(menu, "EncyclopediaMenu", { 0, 0, upgradetype.emode, library, selectedUpgrade.macro })
			menu.cleanup()
		elseif upgradetype.supertype == "software" then
			-- selectedUpgrade.software
		elseif upgradetype.supertype == "ammo" then
			local library = GetMacroData(selectedUpgrade.macro, "infolibrary")
			if upgradetype.emode then
				Helper.closeMenuAndOpenNewMenu(menu, "EncyclopediaMenu", { 0, 0, upgradetype.emode, library, selectedUpgrade.macro })
				menu.cleanup()
			end
		end
	end
end

function menu.buttonInteract(selectedData, button, row, col, posx, posy)
	menu.selectedUpgrade = selectedData
	local x, y = GetLocalMousePosition()
	if x == nil then
		-- gamepad case
		x = posx
		y = -posy
	end
	menu.displayContextFrame("equipment", Helper.scaleX(200), x + Helper.viewWidth / 2, Helper.viewHeight / 2 - y)
end

function menu.onDropDownActivated()
	menu.closeContextMenu()
end

function menu.dropdownLoad(_, id)
	if id ~= nil then
		C.ShowConstructionMap(menu.holomap, menu.container, id, false)
		menu.currentCPID = id
		menu.closeContextMenu()

		menu.topRows.modules = GetTopRow(menu.moduletable)
		menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
		menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
		menu.topRows.plan = GetTopRow(menu.plantable)
		menu.selectedRows.plan = 2
		menu.refreshPlan()
		menu.displayMenu()
	end
end

function menu.dropdownRemovedCP(_, id)
	C.RemoveConstructionPlan("local", id)
	if id == menu.currentCPID then
		menu.currentCPID = nil
		menu.currentCPName = nil
	end
	for i, plan in ipairs(menu.constructionplans) do
		if plan.id == id then
			table.remove(menu.constructionplans, i)
			break
		end
	end
end

function menu.dropdownLoadout(_, loadoutid)
	if loadoutid ~= nil then
		if menu.loadout ~= loadoutid then
			menu.loadout = loadoutid
			local preset
			for _, loadout in ipairs(menu.loadouts) do
				if loadout.id == menu.loadout then
					menu.loadoutName = loadout.name
					if loadout.preset then
						preset = loadout.preset
						menu.loadout = nil
						menu.loadoutName = ""
					end
					break
				end
			end
			local loadout
			if preset then
				loadout = Helper.getLoadoutHelper(C.GenerateModuleLoadout, C.GenerateModuleLoadoutCounts, menu.holomap, menu.loadoutModule.idx, menu.container, preset)
			else
				loadout = Helper.getLoadoutHelper(C.GetLoadout, C.GetLoadoutCounts, 0, menu.loadoutModule.macro, loadoutid)
			end
			local upgradeplan = Helper.convertLoadout(menu.loadoutModule.component, menu.loadoutModule.macro, loadout, nil)
			menu.getUpgradeData(upgradeplan)

			if menu.holomap and (menu.holomap ~= 0) then
				Helper.callLoadoutFunction(menu.constructionplan[menu.loadoutMode].upgradeplan, nil, function (loadout, _) return C.UpdateObjectConfigurationMap(menu.holomap, menu.container, menu.loadoutModule.component, menu.loadoutModule.macro, true, loadout) end)
			end

			menu.displayMenu()
		end
	end
end

function  menu.dropdownRemovedLoadout(_, loadoutid)
	local macro = (menu.loadoutModule.macro ~= "") and menu.loadoutModule.macro or GetComponentData(ConvertStringToLuaID(tostring(menu.loadoutModule.component)), "macro")
	C.RemoveLoadout("local", macro, loadoutid)
	if loadoutid == menu.loadout then
		menu.loadout = nil
		menu.loadoutName = nil
	end
	for i, loadout in ipairs(menu.loadouts) do
		if loadout.id == loadoutid then
			table.remove(menu.loadouts, i)
			break
		end
	end
end

function menu.buttonTitleSave()
	if menu.contextMode and (menu.contextMode.mode == "saveCP") then
		menu.closeContextMenu()
	else
		menu.displayContextFrame("saveCP", menu.titleData.dropdownWidth + menu.titleData.height + Helper.borderSize, menu.titleData.offsetX + menu.titleData.nameWidth + Helper.borderSize, menu.titleData.offsetY + menu.titleData.height + Helper.borderSize)
	end
end

function menu.buttonTitleSaveLoadout()
	if menu.contextMode and (menu.contextMode.mode == "saveLoadout") then
		menu.closeContextMenu()
	else
		menu.displayContextFrame("saveLoadout", menu.titleData.dropdownWidth + 3 * (menu.titleData.height + Helper.borderSize), menu.titleData.offsetX + menu.titleData.nameWidth + Helper.borderSize, menu.titleData.offsetY + menu.titleData.height + Helper.borderSize)
	end
end

function menu.buttonSave(overwrite)
	local source, id
	if overwrite then
		_, _, source = menu.checkCPNameID()
		id = menu.currentCPID
	end

	Helper.closeDropDownOptions(menu.titlebartable, 1, 2)
	C.SaveMapConstructionPlan(menu.holomap, source or "local", id or "player", id ~= nil, menu.currentCPName, "")
	menu.closeContextMenu()
	menu.refreshTitleBar()
end

function menu.buttonSaveLoadout(overwrite)
	local loadoutid
	if overwrite then
		loadoutid = menu.loadout
	end

	Helper.closeDropDownOptions(menu.titlebartable, 1, 2)
	local macro = (menu.loadoutModule.macro ~= "") and menu.loadoutModule.macro or GetComponentData(ConvertStringToLuaID(tostring(menu.loadoutModule.component)), "macro")
	if macro ~= "" then
		Helper.callLoadoutFunction(menu.constructionplan[menu.loadoutMode].upgradeplan, nil, function (loadout, _) return C.SaveLoadout(macro, loadout, "local", loadoutid or "player", loadoutid ~= nil, menu.loadoutName, "") end)
		menu.getPresetLoadouts()
	end
	menu.closeContextMenu()
	menu.refreshTitleBar()
end

function menu.buttonAssignConstructionVessel()
	C.StoreConstructionMapState(menu.holomap)
	menu.mapstate = ffi.new("HoloMapState")
	C.GetMapState(menu.holomap, menu.mapstate)

	Helper.closeMenuAndOpenNewMenu(menu, "MapMenu", { 0, 0, true, nil, nil, "selectCV", { ConvertStringToLuaID(tostring(menu.container)) } })
	menu.cleanup()
end

-- editbox scripts
function menu.onEditBoxActivated(_, oldtext)
	menu.oldEditBoxContent = oldtext
end

function menu.editboxSearchUpdateText(_, text, textchanged)
	if textchanged then
		menu.searchtext = text
	end

	menu.displayMenu()
end

function menu.editboxNameUpdateText(_, text, textchanged)
	if textchanged then
		local name = text
		if name == "" then
			name = menu.oldEditBoxContent
		end
		SetComponentName(ConvertStringToLuaID(tostring(menu.container)), name)
	end
	if text == "" then
		Helper.removeEditBoxScripts(menu, menu.titlebartable, 1, 1)
		SetCellContent(menu.titlebartable, Helper.createEditBox(Helper.createTextInfo(ffi.string(C.GetComponentName(menu.container)), "center", Helper.headerRow1Font, Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize), 255, 255, 255, 100), true, 0, 0, 0, 0, nil, nil, false), 1, 1)
		Helper.setEditBoxScript(menu, nil, menu.titlebartable, 1, 1, menu.editboxNameUpdateText)
	end
end

function menu.editboxCPNameUpdateText(_, text)
	menu.currentCPName = text
	menu.currentCPID = nil
end

function menu.editboxLoadoutNameUpdateText(_, text)
	menu.loadoutName = text
	menu.loadout = nil
end

function menu.slidercellSelectAmount(type, group, row, keepcontext, value)
	if not keepcontext then
		menu.closeContextMenu()
	end

	local upgradetype = Helper.findUpgradeType(type)

	if (upgradetype.supertype == "group") then
		if value ~= menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].count then
			menu.constructionplan[menu.loadoutMode].upgradeplan[type][group].count = value

			menu.selectedRows.modules = row
		end
	end

	if menu.holomap and (menu.holomap ~= 0) then
		Helper.callLoadoutFunction(menu.constructionplan[menu.loadoutMode].upgradeplan, nil, function (loadout, _) return C.UpdateObjectConfigurationMap(menu.holomap, menu.container, menu.loadoutModule.component, menu.loadoutModule.macro, true, loadout) end)
	end

	if keepcontext then
		menu.topRows.context = GetTopRow(menu.contexttable)
		menu.selectedRows.context = keepcontext
		menu.displayContextMenu()
	end
end

function menu.slidercellMoney(_, value)
	menu.newAccountValue = value
end

function menu.slidercellWarePriceOverride(ware, row, value)
	SetContainerWarePriceOverride(menu.buildstorage, ware, true, value)
	C.SetContainerGlobalPriceFactor(menu.buildstorage, -1)
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = row
end

function menu.slidercellGlobalWarePriceFactor(row, value)
	local modifier = Helper.round(value / 100, 2)
	C.SetContainerGlobalPriceFactor(menu.buildstorage, modifier)
	for _, ware in ipairs(menu.tradewares) do
		local newprice = ware.minprice + (ware.maxprice - ware.minprice) * modifier
		SetContainerWarePriceOverride(menu.buildstorage, ware.ware, true, newprice)
		Helper.setSliderCellValue(menu.plantable, ware.row, 2, newprice)
	end
	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = row
end

function menu.onSliderCellConfirm(slidercellID)
	if not menu.selectedRows.plan then
		menu.topRows.plan = GetTopRow(menu.plantable)
		menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	end
	menu.refreshPlan()
	menu.displayMenu()
end

function menu.checkboxToggleWareOverride(ware)
	ToggleFactionTradeWareOverride(ConvertStringTo64Bit(tostring(menu.buildstorage)), ware)

	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.displayMenu()
end

function menu.checkboxToggleGlobalWarePriceModifier()
	C.SetContainerGlobalPriceFactor(menu.buildstorage, (menu.globalpricefactor >= 0) and -1 or 1)
	if menu.globalpricefactor < 0 then
		for _, ware in ipairs(menu.tradewares) do
			SetContainerWarePriceOverride(menu.buildstorage, ware.ware, true, ware.maxprice)
		end
	end

	menu.topRows.plan = GetTopRow(menu.plantable)
	menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
	menu.displayMenu()
end

-- Menu member functions

function menu.hotkey(action)
	if action == "INPUT_ACTION_ADDON_DETAILMONITOR_UNDO" then
		menu.undoHelper(true)
	elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_REDO" then
		menu.undoHelper(false)
	end
end

function menu.undoHelper(undo)
	if undo then
		C.UndoConstructionMapChange(menu.holomap)
	else
		C.RedoConstructionMapChange(menu.holomap)
	end
	menu.refreshPlan()
	menu.displayMenu()
end

function menu.sorterModules(type, a, b)
	local aname, amakerrace, atier, asize, awaregroup = GetMacroData(a, "shortname", "makerrace", "tier", "size", "waregroup")
	local bname, bmakerrace, btier, bsize, bwaregroup = GetMacroData(b, "shortname", "makerrace", "tier", "size", "waregroup")
	if #amakerrace > 0 then
		amakerrace = amakerrace[1]
	else
		amakerrace = ""
	end
	if #bmakerrace > 0 then
		bmakerrace = bmakerrace[1]
	else
		bmakerrace = ""
	end

	if atier == btier then
		if type == "moduletypes_production" then
			if awaregroup == bwaregroup then
				if aname == bname then
					return amakerrace < bmakerrace
				end
				return aname < bname
			end
			return awaregroup < bwaregroup
		else
			if amakerrace == bmakerrace then
				if config.sizeSorting[asize] == config.sizeSorting[bsize] then
					return aname < bname
				end
				return config.sizeSorting[asize] < config.sizeSorting[bsize]
			end
			return amakerrace < bmakerrace
		end
	end
	return atier < btier
end

function menu.newWareReservationCallback(_, data)
	local containerid, ware, reserverid = string.match(data, "(.+);(.+);(.+)")
	if menu.buildstorage == ConvertStringTo64Bit(containerid) then
		PlaySound("notification_achievement")
		menu.newWareReservation = (menu.newWareReservation or 0) + 1
		if menu.newWareReservationWares[ware] then
			menu.newWareReservationWares[ware][reserverid] = true
		else
			menu.newWareReservationWares[ware] = { [reserverid] = true }
		end
		menu.topRows.plan = GetTopRow(menu.plantable)
		menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
		menu.displayMenu()
	end
end

function menu.onShowMenu(state)
	-- layout
	menu.scaleSize = Helper.scaleX(config.scaleSize)
	menu.frameworkData = {
		sidebarWidth = Helper.scaleX(Helper.sidebarWidth),
		offsetX = Helper.frameBorder,
		offsetY = Helper.frameBorder + 20,
	}
	menu.modulesData = {
		width = math.floor(0.25 * Helper.viewWidth) - menu.frameworkData.sidebarWidth - menu.frameworkData.offsetX - 2 * Helper.borderSize,
		offsetX = menu.frameworkData.sidebarWidth + menu.frameworkData.offsetX + 2 * Helper.borderSize,
		offsetY = Helper.frameBorder + Helper.borderSize,
	}
	menu.planData = {
		width = math.floor(0.25 * Helper.viewWidth) - menu.frameworkData.sidebarWidth - menu.frameworkData.offsetX - 2 * Helper.borderSize,
		offsetY = Helper.frameBorder + Helper.borderSize,
	}
	local width = (Helper.viewWidth - 2 * menu.modulesData.offsetX - menu.modulesData.width - menu.planData.width - 6 * Helper.borderSize) / 2
	menu.statsData = {
		width =  width,
		offsetX = menu.modulesData.offsetX + menu.modulesData.width + 3 * Helper.borderSize + width / 2,
		offsetY = Helper.frameBorder,
	}
	menu.titleData = {
		width =  Helper.viewWidth - 2 * menu.modulesData.offsetX - menu.modulesData.width - menu.planData.width - 4 * Helper.borderSize,
		height = Helper.scaleY(40),
		dropdownWidth = 6 * menu.frameworkData.sidebarWidth,
		offsetX = menu.modulesData.offsetX + menu.modulesData.width + 2 * Helper.borderSize,
		offsetY = Helper.frameBorder,
	}
	menu.titleData.nameWidth = menu.titleData.width - (menu.titleData.hasshuffle and 4 or 5) * (menu.titleData.height + Helper.borderSize) - menu.titleData.dropdownWidth - Helper.borderSize
	menu.planData.offsetX = menu.titleData.offsetX + menu.titleData.width + 2 * Helper.borderSize
	menu.mapData = {
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		offsetX = 0,
		offsetY = 0
	}

	menu.headerTextProperties = {
		font = Helper.headerRow1Font,
		fontsize = Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize),
		x = Helper.scaleX(Helper.headerRow1Offsetx),
		y = math.floor((menu.titleData.height - Helper.scaleY(Helper.headerRow1Height)) / 2 + Helper.scaleY(Helper.headerRow1Offsety)),
		minRowHeight = menu.titleData.height,
		scaling = false,
		cellBGColor = { r = 0, g = 0, b = 0, a = 0 },
		titleColor = Helper.defaultSimpleBackgroundColor,
	}

	menu.headerCenteredTextProperties = {
		font = Helper.headerRow1Font,
		fontsize = Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize),
		x = Helper.scaleX(Helper.headerRow1Offsetx),
		y = math.floor((menu.titleData.height - Helper.scaleY(Helper.headerRow1Height)) / 2 + Helper.scaleY(Helper.headerRow1Offsety)),
		minRowHeight = menu.titleData.height,
		scaling = false,
		halign = "center",
		cellBGColor = { r = 0, g = 0, b = 0, a = 0 },
		titleColor = Helper.defaultSimpleBackgroundColor,
	}

	menu.slidercellTextProperties = {
		font = Helper.headerRow1Font,
		fontsize = Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize),
		x = Helper.scaleX(Helper.headerRow1Offsetx),
	}

	menu.extraFontSize = Helper.scaleFont(Helper.standardFont, Helper.standardFontSize)

	-- parameters
	menu.container = ConvertIDTo64Bit(menu.param[3])
	menu.buildstorage = ConvertIDTo64Bit(GetComponentData(menu.container, "buildstorage")) or 0

	RegisterEvent("newWareReservation", menu.newWareReservationCallback)

	local sets = GetComponentData(menu.container, "modulesets")
	menu.set = sets[1] or ""

	-- prepare modules
	menu.modules = {}
	for _, entry in ipairs(config.leftBar) do
		menu.modules[entry.mode] = {}
		local n = C.GetNumBlueprints(menu.set, entry.mode, "")
		local buf = ffi.new("UIBlueprint[?]", n)
		n = C.GetBlueprints(buf, n, menu.set, entry.mode, "")
		for i = 0, n - 1 do
			table.insert(menu.modules[entry.mode], ffi.string(buf[i].macro))
		end
		table.sort(menu.modules[entry.mode], function (a, b) return menu.sorterModules(entry.mode, a, b) end)
		entry.active = n > 0
	end

	-- assemble possible upgrades (wares, macros)
	menu.upgradewares = {}
	for _, blueprintGroup in ipairs(config.equipmentBlueprintGroups) do
		local n = C.GetNumBlueprints(menu.set, blueprintGroup.library, "")
		local buf = ffi.new("UIBlueprint[?]", n)
		n = C.GetBlueprints(buf, n, menu.set, blueprintGroup.library, "")
		for i = 0, n - 1 do
			local entry = {}
			entry.macro = ffi.string(buf[i].macro)
			entry.ware = ffi.string(buf[i].ware)
			if menu.upgradewares[blueprintGroup.type] then
				table.insert(menu.upgradewares[blueprintGroup.type], entry)
			else
				menu.upgradewares[blueprintGroup.type] = { entry }
			end
		end
	end

	menu.searchtext = ""
	menu.loadoutName = ""
	menu.modulesMode = "moduletypes_production"
	menu.upgradetypeMode = "group"
	menu.planMode = "construction"

	menu.topRows = {}
	menu.selectedRows = {}
	menu.selectedCols = {}

	menu.editedLoadouts = {}

	if state then
		menu.state = state
	end

	menu.displayMainFrame()
	
	RegisterAddonBindings("ego_detailmonitor", "undo")
	Helper.setKeyBinding(menu, menu.hotkey)
end

function menu.onShowMenuSound()
	if not C.IsNextStartAnimationSkipped(false) then
		PlaySound("ui_config_station_open")
	else
		PlaySound("ui_menu_changed")
	end
end

function menu.displayLeftBar(frame)
	local leftBar = config.leftBar
	if menu.loadoutMode then
		leftBar = config.leftBarLoadout
	end

	local ftable = frame:addTable(1, { tabOrder = 2, width = menu.frameworkData.sidebarWidth, height = 0, x = menu.frameworkData.offsetX, y = menu.frameworkData.offsetY, scaling = false, borderEnabled = false, reserveScrollBar = false })

	local found = true
	for _, entry in ipairs(leftBar) do
		local active = true
		local selected = false
		local prevSelected = false
		if menu.loadoutMode then
			selected = entry.mode == menu.upgradetypeMode
			prevSelected = entry.mode == menu.prevUpgradetypeMode
			if entry.mode == "group" then
				active = active and (#menu.groups > 0)
			end
		else
			active = entry.active
			selected = entry.mode == menu.modulesMode
			prevSelected = entry.mode == menu.prevModulesMode
		end
		local row = ftable:addRow(active, { fixed = true })

		-- if nothing selected yet, select this one if active
		if (not found) and active then
			found = true
			menu.modulesMode = entry.mode
		end

		-- if selected, but not active, select next active entry
		if selected and (not active) then
			found = false
			selected = false
		end

		if selected then
			menu.selectedRows.left = row.index
		elseif prevSelected then
			menu.selectedRows.left = row.index
		end
		row[1]:createButton({ active = active, height = menu.frameworkData.sidebarWidth, mouseOverText = entry.name, bgColor = selected and Helper.defaultArrowRowBackgroundColor or Helper.defaultButtonBackgroundColor }):setIcon(entry.icon)
		if not menu.loadoutMode then
			row[1].handlers.onClick = function () return menu.buttonLeftBar(entry.mode, row.index) end
		else
			row[1].handlers.onClick = function () return menu.buttonLeftBarLoadout(entry.mode, row.index) end
		end
	end
	ftable:setTopRow(menu.topRows.left)
	ftable:setSelectedRow(menu.selectedRows.left)
	menu.topRows.left = nil
	menu.selectedRows.left = nil
end

function menu.createRightSideBar(frame)
	local offsetX = Helper.viewWidth - menu.frameworkData.offsetX - menu.frameworkData.sidebarWidth

	local ftable = frame:addTable(1, { tabOrder = 4, width = menu.frameworkData.sidebarWidth, height = 0, x = offsetX, y = menu.frameworkData.offsetY, scaling = false, borderEnabled = false, reserveScrollBar = false })

	for _, entry in ipairs(config.rightBar) do
		local row = ftable:addRow(true, { fixed = true })
		row[1]:createButton({ active = entry.active, height = menu.frameworkData.sidebarWidth, mouseOverText = entry.name, bgColor = (entry.mode == "construction") and Helper.defaultArrowRowBackgroundColor or Helper.defaultButtonBackgroundColor }):setIcon(entry.icon)
		row[1].handlers.onClick = function () return menu.buttonRightBar(entry.mode, row.index) end
	end
end

function menu.updateConstructionPlans()
	menu.constructionplans = {}
	local n = C.GetNumConstructionPlans()
	local buf = ffi.new("UIConstructionPlan[?]", n)
	n = C.GetConstructionPlans(buf, n)
	local ischeatversion = IsCheatVersion()
	for i = 0, n - 1 do
		local source = ffi.string(buf[i].source)
		if (source == "local") or ischeatversion then
			local id = ffi.string(buf[i].id)
			local result = ffi.string(C.GetMissingConstructionPlanBlueprints(menu.container, id))
			local active = result == ""
			local missingmacros = {}
			if (not active) and (string.find(result, "error") ~= 1) then
				for macro in string.gmatch(result, "([^;]+);") do
					missingmacros[macro] = true
				end
			end
			local missingmacronames = {}
			for macro, v in pairs(missingmacros) do
				table.insert(missingmacronames, GetMacroData(macro, "name"))
			end
			table.sort(missingmacronames)
			local blueprinttext = ""
			for i, name in ipairs(missingmacronames) do
				blueprinttext = blueprinttext .. "\n· " .. name
			end

			table.insert(menu.constructionplans, { id = id, name = ffi.string(buf[i].name), source = source, deleteable = buf[i].deleteable, active = active, mouseovertext = active and "" or (ReadText(1026, 7912) .. blueprinttext) })
		end
	end
end

function menu.createTitleBar(frame)
	menu.updateConstructionPlans()
	
	if menu.holomap and (menu.holomap ~= 0) then
		if menu.set ~= "headquarters_player" then
			menu.titleData.hasshuffle = C.ShuffleMapConstructionPlan(menu.holomap, true)
		else
			menu.titleData.hasshuffle = false
		end
	end

	local ftable = frame:addTable(menu.titleData.hasshuffle and 7 or 6, { tabOrder = 5, height = 0, x = menu.titleData.offsetX, y = menu.titleData.offsetY, scaling = false, reserveScrollBar = false })
	ftable:setColWidth(1, menu.titleData.nameWidth)
	ftable:setColWidth(2, menu.titleData.dropdownWidth)
	ftable:setColWidth(3, menu.titleData.height)
	ftable:setColWidth(4, menu.titleData.height)
	ftable:setColWidth(5, menu.titleData.height)
	ftable:setColWidth(6, menu.titleData.height)
	if menu.titleData.hasshuffle then
		ftable:setColWidth(7, menu.titleData.height)
	end
	
	local row = ftable:addRow(true, { fixed = true })
	if not menu.loadoutMode then
		-- name
		row[1]:createEditBox({ scaling = true }):setText(ffi.string(C.GetComponentName(menu.container)), { halign = "center", font = Helper.headerRow1Font, fontsize = Helper.headerRow1FontSize })
		row[1].handlers.onEditBoxDeactivated = menu.editboxNameUpdateText
		-- load
		local loadOptions = {}
		for _, plan in ipairs(menu.constructionplans) do
			table.insert(loadOptions, { id = plan.id, text = plan.name, icon = "", displayremoveoption = plan.deleteable, active = plan.active, mouseovertext = plan.mouseovertext })
		end
		table.sort(loadOptions, function (a, b) return a.text < b.text end)
		row[2]:createDropDown(loadOptions, { textOverride = ReadText(1001, 7904), optionWidth = menu.titleData.dropdownWidth + menu.titleData.height + Helper.borderSize }):setTextProperties(config.dropDownTextProperties)
		row[2].handlers.onDropDownConfirmed = menu.dropdownLoad
		row[2].handlers.onDropDownRemoved = menu.dropdownRemovedCP
		-- save
		row[3]:createButton({ active = true, height = menu.titleData.height, mouseOverText = ReadText(1026, 7901) }):setIcon("menu_save")
		row[3].handlers.onClick = menu.buttonTitleSave
		-- shuffle plan
		local offset = 0
		if menu.titleData.hasshuffle then
			row[4]:createButton({ active = true, height = menu.titleData.height, mouseOverText = ReadText(1026, 7910) }):setIcon("menu_shuffle")
			row[4].handlers.onClick = function () return C.ShuffleMapConstructionPlan(menu.holomap, false) end

			offset = 1
		end
		-- reset camera
		row[4 + offset]:createButton({ active = true, height = menu.titleData.height, mouseOverText = L["Reset view"] }):setIcon("menu_reset_view"):setHotkey("INPUT_STATE_DETAILMONITOR_RESET_VIEW", { displayIcon = false })
		row[4 + offset].handlers.onClick = function () return C.ResetMapPlayerRotation(menu.holomap) end
		-- undo
		menu.canundo = false
		if menu.holomap and (menu.holomap ~= 0) then
			menu.canundo = C.CanUndoConstructionMapChange(menu.holomap)
		end
		row[5 + offset]:createButton({ active = menu.canundo, height = menu.titleData.height, mouseOverText = ReadText(1026, 7903) .. " (" .. GetLocalizedKeyName("action", 278) .. ")" }):setIcon("menu_undo")
		row[5 + offset].handlers.onClick = function () return menu.undoHelper(true) end
		-- redo
		menu.canredo = false
		if menu.holomap and (menu.holomap ~= 0) then
			menu.canredo = C.CanRedoConstructionMapChange(menu.holomap)
		end
		row[6 + offset]:createButton({ active = menu.canredo, height = menu.titleData.height, mouseOverText = ReadText(1026, 7904) .. " (" .. GetLocalizedKeyName("action", 279) .. ")" }):setIcon("menu_redo")
		row[6 + offset].handlers.onClick = function () return menu.undoHelper(false) end
	else
		-- name
		row[1]:createEditBox({ scaling = true }):setText(ffi.string(C.GetComponentName(menu.container)), { halign = "center", font = Helper.headerRow1Font, fontsize = Helper.headerRow1FontSize })
		row[1].handlers.onEditBoxDeactivated = menu.editboxNameUpdateText
		-- load
		local loadoutOptions = {}
		if next(menu.loadouts) then
			for _, loadout in ipairs(menu.loadouts) do
				table.insert(loadoutOptions, { id = loadout.id, text = loadout.name, icon = "", displayremoveoption = loadout.deleteable, active = loadout.active, mouseovertext = loadout.mouseovertext })
			end
		end
		row[2]:setColSpan(menu.titleData.hasshuffle and 4 or 3):createDropDown(loadoutOptions, { textOverride = ReadText(1001, 7905), optionWidth = menu.titleData.dropdownWidth + (menu.titleData.hasshuffle and 4 or 3) * (menu.titleData.height + Helper.borderSize) }):setTextProperties(config.dropDownTextProperties)
		row[2].handlers.onDropDownConfirmed = menu.dropdownLoadout
		row[2].handlers.onDropDownRemoved = menu.dropdownRemovedLoadout
		local offset = menu.titleData.hasshuffle and 1 or 0
		-- save
		row[5 + offset]:createButton({ active = true, height = menu.titleData.height, mouseOverText = ReadText(1026, 7905) }):setIcon("menu_save")
		row[5 + offset].handlers.onClick = menu.buttonTitleSaveLoadout
		-- reset camera
		row[6 + offset]:createButton({ active = true, height = menu.titleData.height, mouseOverText = L["Reset view"] }):setIcon("menu_reset_view"):setHotkey("INPUT_STATE_DETAILMONITOR_RESET_VIEW", { displayIcon = false })
		row[6 + offset].handlers.onClick = function () return C.ResetMapPlayerRotation(menu.holomap) end
	end
end

function menu.refreshTitleBar()
	local text = {
		alignment = "center",
		fontname = Helper.standardFont,
		fontsize = Helper.scaleFont(Helper.standardFont, Helper.standardFontSize),
		color = Helper.color.white,
		x = 0,
		y = 0
	}

	menu.updateConstructionPlans()

	if not menu.loadoutMode then
		text.override = ReadText(1001, 7904)
		local loadOptions = {}
		for _, plan in ipairs(menu.constructionplans) do
			table.insert(loadOptions, { id = plan.id, text = plan.name, icon = "", displayremoveoption = plan.deleteable, active = plan.active, mouseovertext = plan.mouseovertext })
		end
		table.sort(loadOptions, function (a, b) return a.text < b.text end)
		
		-- editbox
		Helper.removeEditBoxScripts(menu, menu.titlebartable, 1, 1)
		SetCellContent(menu.titlebartable, Helper.createEditBox(Helper.createTextInfo(ffi.string(C.GetComponentName(menu.container)), "center", Helper.headerRow1Font, Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize), 255, 255, 255, 100), true, 0, 0, 0, 0, nil, nil, false), 1, 1)
		Helper.setEditBoxScript(menu, nil, menu.titlebartable, 1, 1, menu.editboxNameUpdateText)
		-- dropdown
		Helper.removeDropDownScripts(menu, menu.titlebartable, 1, 2)
		SetCellContent(menu.titlebartable, Helper.createDropDown(loadOptions, "", text, nil, true, true, 0, 0, 0, 0, nil, nil, "", menu.titleData.dropdownWidth + menu.titleData.height + Helper.borderSize), 1, 2)
		Helper.setDropDownScript(menu, nil, menu.titlebartable, 1, 2, nil, menu.dropdownLoad, menu.dropdownRemovedCP)
		-- save
		Helper.removeButtonScripts(menu, menu.titlebartable, 1, 3)
		SetCellContent(menu.titlebartable, Helper.createButton(nil, Helper.createButtonIcon("menu_save", nil, 255, 255, 255, 100), true, true, 0, 0, 0, menu.titleData.height, nil, nil, nil, ReadText(1026, 7901)), 1, 3)
		Helper.setButtonScript(menu, nil, menu.titlebartable, 1, 3, menu.buttonTitleSave)
	else
		text.override = ReadText(1001, 7905)
		local loadoutOptions = {}
		if next(menu.loadouts) then
			for _, loadout in ipairs(menu.loadouts) do
				table.insert(loadoutOptions, { id = loadout.id, text = loadout.name, icon = "", displayremoveoption = loadout.deleteable, active = loadout.active, mouseovertext = loadout.mouseovertext })
			end
		end

		local offset = 0
		if menu.titleData.hasshuffle then
			offset = 1
		end
		
		-- editbox
		Helper.removeEditBoxScripts(menu, menu.titlebartable, 1, 1)
		SetCellContent(menu.titlebartable, Helper.createEditBox(Helper.createTextInfo(ffi.string(C.GetComponentName(menu.container)), "center", Helper.headerRow1Font, Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize), 255, 255, 255, 100), true, 0, 0, 0, 0, nil, nil, false), 1, 1)
		Helper.setEditBoxScript(menu, nil, menu.titlebartable, 1, 1, menu.editboxNameUpdateText)
		-- dropdown
		Helper.removeDropDownScripts(menu, menu.titlebartable, 1, 2)
		SetCellContent(menu.titlebartable, Helper.createDropDown(loadoutOptions, "", text, nil, true, next(menu.loadouts) ~= nil, 0, 0, 0, 0, nil, nil, "", menu.titleData.dropdownWidth + (menu.titleData.hasshuffle and 4 or 3) * (menu.titleData.height + Helper.borderSize)), 1, 2)
		Helper.setDropDownScript(menu, nil, menu.titlebartable, 1, 2, nil, menu.dropdownLoadout, menu.dropdownRemovedLoadout)
		-- save
		Helper.removeButtonScripts(menu, menu.titlebartable, 1, 5 + offset)
		SetCellContent(menu.titlebartable, Helper.createButton(nil, Helper.createButtonIcon("menu_save", nil, 255, 255, 255, 100), true, true, 0, 0, 0, menu.titleData.height, nil, nil, nil, ReadText(1026, 7905)), 1, 5 + offset)
		Helper.setButtonScript(menu, nil, menu.titlebartable, 1, 5 + offset, menu.buttonTitleSaveLoadout)
	end
end

function menu.getPresetLoadouts()
	-- presets
	menu.loadouts = {}

	local n = C.GetNumLoadoutsInfo(menu.loadoutModule.component, menu.loadoutModule.macro)
	local buf = ffi.new("UILoadoutInfo[?]", n)
	n = C.GetLoadoutsInfo(buf, n, menu.loadoutModule.component, menu.loadoutModule.macro)
	for i = 0, n - 1 do
		local id = ffi.string(buf[i].id)
		local active = C.CanBuildLoadout(menu.buildstorage, 0, menu.loadoutModule.macro, id)
		table.insert(menu.loadouts, { id = id, name = ffi.string(buf[i].name), icon = ffi.string(buf[i].iconid), deleteable = buf[i].deleteable, active = active, mouseovertext = active and "" or ReadText(1026, 8011) })
	end
	table.sort(menu.loadouts, function (a, b) return a.name < b.name end)
	table.insert(menu.loadouts, 1, { id = "empty", name = ReadText(1001, 7941), icon = "", deleteable = false, preset = 0 })
	table.insert(menu.loadouts, 2, { id = "low", name = ReadText(1001, 7910), icon = "", deleteable = false, preset = 0.1 })
	table.insert(menu.loadouts, 3, { id = "medium", name = ReadText(1001, 7911), icon = "", deleteable = false, preset = 0.5 })
	table.insert(menu.loadouts, 4, { id = "high", name = ReadText(1001, 7912), icon = "", deleteable = false, preset = 1.0 })
end

function menu.getUpgradeData(upgradeplan)
	-- get preset loadouts
	menu.getPresetLoadouts()

	-- init upgradeplan
	menu.constructionplan[menu.loadoutMode].upgradeplan = {}
	for _, upgradetype in ipairs(Helper.upgradetypes) do
		menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype.type] = {}
	end

	-- assemble available slots/ammo/software
	menu.slots = {}
	if menu.loadoutModule.component ~= 0 then
		for i, upgradetype in ipairs(Helper.upgradetypes) do
			if upgradetype.supertype == "macro" then
				menu.slots[upgradetype.type] = {}
				for j = 1, tonumber(C.GetNumUpgradeSlots(menu.loadoutModule.component, "", upgradetype.type)) do
					-- convert index from lua to C-style
					menu.slots[upgradetype.type][j] = { currentmacro = ffi.string(C.GetUpgradeSlotCurrentMacro(menu.container, menu.loadoutModule.component, upgradetype.type, j)), possiblemacros = {} }
					menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype.type][j] = menu.slots[upgradetype.type][j].currentmacro
				end
			end
		end
	else
		for i, upgradetype in ipairs(Helper.upgradetypes) do
			if upgradetype.supertype == "macro" then
				menu.slots[upgradetype.type] = {}
				for j = 1, tonumber(C.GetNumUpgradeSlots(0, menu.loadoutModule.macro, upgradetype.type)) do
					-- convert index from lua to C-style
					menu.slots[upgradetype.type][j] = { currentmacro = "", possiblemacros = {} }
					menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype.type][j] = ""
				end
			end
		end
	end

	menu.groups = {}
	local n = C.GetNumUpgradeGroups(menu.loadoutModule.component, menu.loadoutModule.macro)
	local buf = ffi.new("UpgradeGroup[?]", n)
	n = C.GetUpgradeGroups(buf, n, menu.loadoutModule.component, menu.loadoutModule.macro)
	for i = 0, n - 1 do
		table.insert(menu.groups, { path = ffi.string(buf[i].path), group = ffi.string(buf[i].group) })
		local group = menu.groups[#menu.groups]
		for j, upgradetype in ipairs(Helper.upgradetypes) do
			if upgradetype.supertype == "group" then
				local groupinfo = C.GetUpgradeGroupInfo(menu.loadoutModule.component, menu.loadoutModule.macro, group.path, group.group, upgradetype.grouptype)
				menu.groups[#menu.groups][upgradetype.grouptype] = { count = groupinfo.count, total = groupinfo.total, slotsize = ffi.string(groupinfo.slotsize), currentmacro = ffi.string(groupinfo.currentmacro), possiblemacros = {} }
				menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype.type][#menu.groups] = { macro = ffi.string(groupinfo.currentmacro), count = groupinfo.count, path = group.path, group = group.group }
			end
		end
	end

	-- assemble possible upgrades per slot
	for type, slots in pairs(menu.slots) do
		for i, slot in ipairs(slots) do
			local wares = menu.upgradewares[type] or {}
			for _, upgradeware in ipairs(wares) do
				if upgradeware.macro ~= "" then
					if C.IsUpgradeMacroCompatible(menu.container, menu.loadoutModule.component, menu.loadoutModule.macro, true, type, i, upgradeware.macro) then
						table.insert(slot.possiblemacros, upgradeware.macro)
					end
				end
			end
		end
	end

	for i, group in ipairs(menu.groups) do
		for j, upgradetype in ipairs(Helper.upgradetypes) do
			if upgradetype.supertype == "group" then
				local wares = menu.upgradewares[upgradetype.grouptype] or {}
				for _, upgradeware in ipairs(wares) do
					if upgradeware.macro ~= "" then
						if C.IsUpgradeGroupMacroCompatible(menu.loadoutModule.component, menu.loadoutModule.macro, group.path, group.group, upgradetype.grouptype, upgradeware.macro) then
							table.insert(menu.groups[i][upgradetype.grouptype].possiblemacros, upgradeware.macro)
						end
					end
				end
			end
		end
	end

	if upgradeplan then
		for type, upgradelist in pairs(menu.constructionplan[menu.loadoutMode].upgradeplan) do
			local upgradetype = Helper.findUpgradeType(type)
			for key, upgrade in pairs(upgradelist) do
				if upgradetype.supertype == "group" then
					local found = false
					for key2, upgrade2 in pairs(upgradeplan[type]) do
						if (upgrade2.path == upgrade.path) and (upgrade2.group == upgrade.group) then
							found = true
							menu.constructionplan[menu.loadoutMode].upgradeplan[type][key].macro = upgrade2.macro or ""
							menu.constructionplan[menu.loadoutMode].upgradeplan[type][key].count = upgrade2.count or 0
							break
						end
					end
					if not found then
						menu.constructionplan[menu.loadoutMode].upgradeplan[type][key].macro = ""
						menu.constructionplan[menu.loadoutMode].upgradeplan[type][key].count = 0
					end
				else
					menu.constructionplan[menu.loadoutMode].upgradeplan[type][key] = upgradeplan[type][key] or ""
				end
			end
		end
	end
end

function menu.displayModules(frame)
	local count = 1
	if not menu.loadoutMode then
		local modules = menu.modules[menu.modulesMode] or {}
		menu.groupedmodules = {}
		for i, module in ipairs(modules) do
			if (menu.searchtext == "") or menu.filterModuleByText(module, menu.searchtext) then
				local group = math.ceil(count / 3)
				menu.groupedmodules[group] = menu.groupedmodules[group] or {}
				table.insert(menu.groupedmodules[group], module)
				count = count + 1
			end
		end
	else
		if menu.upgradetypeMode == "group" then
			local upgradegroup = menu.groups[menu.currentSlot]

			menu.groupedupgrades = {}
			for i, upgradetype in ipairs(Helper.upgradetypes) do
				local upgradegroupcount = 1
				if upgradetype.supertype == "group" then
					menu.groupedupgrades[upgradetype.grouptype] = {}
					if upgradegroup then
						for i, macro in ipairs(upgradegroup[upgradetype.grouptype].possiblemacros) do
							if (menu.searchtext == "") or menu.filterUpgradeByText(macro, menu.searchtext) then
								local group = math.ceil(upgradegroupcount / 3)
								menu.groupedupgrades[upgradetype.grouptype][group] = menu.groupedupgrades[upgradetype.grouptype][group] or {}
								table.insert(menu.groupedupgrades[upgradetype.grouptype][group], { macro = macro, icon = (C.IsIconValid("upgrade_" .. macro) and ("upgrade_" .. macro) or "upgrade_notfound"), name = GetMacroData(macro, "name") })
								upgradegroupcount = upgradegroupcount + 1
							end
						end
					end

					if upgradetype.allowempty then
						local group = math.ceil(upgradegroupcount / 3)
						menu.groupedupgrades[upgradetype.grouptype][group] = menu.groupedupgrades[upgradetype.grouptype][group] or {}
						table.insert(menu.groupedupgrades[upgradetype.grouptype][group], { macro = "", icon = "upgrade_empty", name = ReadText(1001, 7906) })
						upgradegroupcount = upgradegroupcount + 1
					end
				end
				count = count + upgradegroupcount - 1
			end
			count = count + 1
		end
	end
	count = count - 1
	
	local editboxheight = math.max(23, Helper.scaleY(Helper.standardTextHeight))

	if not menu.loadoutMode then
		if menu.modulesMode then
			local maxColumnWidth = math.floor((menu.modulesData.width - 2 * Helper.borderSize) / 3)
			local columnWidth = maxColumnWidth - math.floor(((count / 3 > 6) and Helper.scrollbarWidth or 0) / 3)

			local ftable = frame:addTable(4, { tabOrder = 1, width = menu.modulesData.width, height = 0, x = menu.modulesData.offsetX, y = menu.modulesData.offsetY, scaling = false, reserveScrollBar = false, highlightMode = "column", backgroundID = "solid", backgroundColor = Helper.color.transparent60 })
			if menu.setdefaulttable then
				ftable.properties.defaultInteractiveObject = true
				menu.setdefaulttable = nil
			end
			ftable:setColWidth(1, columnWidth)
			ftable:setColWidth(2, columnWidth)
			ftable:setColWidth(4, editboxheight)
			ftable:setDefaultColSpan(3, 2)

			local name = menu.getLeftBarEntry(menu.modulesMode).name or ""
			local row = ftable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
			row[1]:setColSpan(4):createText(name, menu.headerTextProperties)

			local row = ftable:addRow(true, { fixed = true })
			row[1]:setColSpan(3):createEditBox({  }):setText(menu.searchtext, {  }):setHotkey("INPUT_STATE_DETAILMONITOR_0", { displayIcon = true })
			row[1].handlers.onEditBoxDeactivated = menu.editboxSearchUpdateText
			row[4]:createButton({ height = editboxheight }):setText("X", { halign = "center", font = Helper.standardFontBold })
			row[4].handlers.onClick = function () return menu.buttonClearEditbox(row.index) end

			if next(menu.groupedmodules) then
				for _, group in ipairs(menu.groupedmodules) do
					local row = ftable:addRow(true, { bgColor = Helper.color.transparent, borderBelow = false })
					local row2 = ftable:addRow(false, { bgColor = Helper.color.transparent })
					for i = 1, 3 do
						if group[i] then
							local shortname, makericon, infolibrary, canclaimownership = GetMacroData(group[i], "shortname", "makericon", "infolibrary", "canclaimownership")
							AddKnownItem(infolibrary, group[i])
							local icon = C.IsIconValid("module_" .. group[i]) and ("module_" .. group[i]) or "module_notfound"
							row[i]:createButton({ width = columnWidth, height = columnWidth }):setIcon(icon)
							if menu.modulesMode == "moduletypes_production" then
								local icon = GetMacroData(group[i], "waregroupicon")
								if icon ~= "" then
									row[i]:setIcon2(icon, { color = Helper.defaultSliderCellValueColor })
								end
							elseif (menu.modulesMode == "moduletypes_storage") or (menu.modulesMode == "moduletypes_habitation") then
								local icon = "be_upgrade_size_" .. GetMacroData(group[i], "size")
								row[i]:setIcon2(icon, { color = Helper.defaultSliderCellValueColor })
							elseif canclaimownership then
								row[i]:setIcon2("be_upgrade_claiming", { color = Helper.defaultSliderCellValueColor })
							end
							if #makericon > 0 then
								local makertext = ""
								for i, icon in ipairs(makericon) do
									makertext = makertext .. ((i == 1) and "" or "\n") .. "\27[" .. icon .. "]"
								end
								local fontsize = Helper.scaleFont(Helper.standardFont, Helper.largeIconFontSize)
								local y = columnWidth / 2 - Helper.scaleY(Helper.largeIconTextHeight) / 2 - Helper.configButtonBorderSize
								row[i]:setText(makertext, { y = y, halign = "right", color = Helper.defaultSliderCellValueColor, fontsize = fontsize })
							end
							row[i].handlers.onClick = function () return menu.buttonAddModule(group[i], row.index, i) end
							if group[i] ~= "" then
								row[i].handlers.onRightClick = function (...) return menu.buttonInteract({ type = "module", name = GetMacroData(group[i], "name"), macro = group[i] }, ...) end
							end
							local extraText = TruncateText(shortname, Helper.standardFont, menu.extraFontSize, columnWidth - 2 * Helper.borderSize)
							row2[i]:createBoxText(extraText, { width = columnWidth, fontsize = menu.extraFontSize })
						end
					end
				end
			end

			ftable:setTopRow(menu.topRows.modules)
			ftable:setSelectedRow(menu.selectedRows.modules)
			ftable:setSelectedCol(menu.selectedCols.modules or 0)
		end
		menu.topRows.modules = nil
		menu.selectedRows.modules = nil
		menu.selectedCols.modules = nil
	else
		if menu.upgradetypeMode then
			local maxSlotWidth = math.floor((menu.modulesData.width - 8 * Helper.borderSize) / 9)
			local slotWidth = maxSlotWidth - math.floor(((count / 3 > 6) and Helper.scrollbarWidth or 0) / 9)
			local extraPixels = (menu.modulesData.width - 8 * Helper.borderSize) % 9
			local slotWidths = { slotWidth, slotWidth, slotWidth, slotWidth, slotWidth, slotWidth, slotWidth, slotWidth, slotWidth }
			if extraPixels > 0 then
				for i = 1, extraPixels do
					slotWidths[i] = slotWidths[i] + 1
				end
			end
			local columnWidths = {}
			local maxColumnWidth = 0
			for i = 1, 3 do
				columnWidths[i] = slotWidths[(i - 1) * 3 + 1] + slotWidths[(i - 1) * 3 + 2] + slotWidths[(i - 1) * 3 + 3] + 2 * Helper.borderSize
				maxColumnWidth = math.max(maxColumnWidth, columnWidths[i])
			end
			local slidercellWidth = menu.modulesData.width - math.floor((count / 3 > 6) and Helper.scrollbarWidth or 0)

			local ftable = frame:addTable(10, { tabOrder = 1, width = menu.modulesData.width, height = 0, x = menu.modulesData.offsetX, y = menu.modulesData.offsetY, scaling = false, reserveScrollBar = false, highlightMode = "column", backgroundID = "solid", backgroundColor = Helper.color.transparent60 })
			if menu.setdefaulttable then
				ftable.properties.defaultInteractiveObject = true
				menu.setdefaulttable = nil
			end
			for i = 1, 8 do
				ftable:setColWidth(i, slotWidths[i])
			end
			ftable:setColWidth(10, editboxheight)
			ftable:setDefaultColSpan(1, 3)
			ftable:setDefaultColSpan(4, 3)
			ftable:setDefaultColSpan(7, 4)

			local upgradetype = Helper.findUpgradeType(menu.upgradetypeMode)

			local name = menu.getLeftBarLoadoutEntry(menu.upgradetypeMode).name or ""
			local row = ftable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
			row[1]:setColSpan(10):createText(name, menu.headerTextProperties)

			if menu.upgradetypeMode == "group" then
				local groupcount = 1
				menu.groupedslots = {}
				for i, upgradegroup in ipairs(menu.groups) do
					local group = math.ceil(groupcount / 9)
					menu.groupedslots[group] = menu.groupedslots[group] or {}
					table.insert(menu.groupedslots[group], {groupcount, upgradegroup})
					groupcount = groupcount + 1
				end
			end

			for _, group in ipairs(menu.groupedslots) do
				local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				for i = 1, 9 do
					if group[i] then
						local colspan = (i == 9) and 2 or 1

						local bgcolor = Helper.defaultTitleBackgroundColor
						if group[i][1] == menu.currentSlot then
							bgcolor = Helper.defaultArrowRowBackgroundColor
						end

						local count, total = 0, 0
						if menu.upgradetypeMode == "group" then
							for _, upgradetype2 in ipairs(Helper.upgradetypes) do
								if upgradetype2.supertype == "group" then
									if menu.groups[group[i][1]][upgradetype2.grouptype].total > 0 then
										if upgradetype2.mergeslots then
											count = count + ((menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype2.type][group[i][1]].count > 0) and 1 or 0)
											total = total + 1
										else
											count = count + menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype2.type][group[i][1]].count
											total = total + menu.groups[group[i][1]][upgradetype2.grouptype].total
										end
									end
								end
							end
						end

						local mouseovertext = ""
						if upgradetype then
							mouseovertext = ReadText(1001, 66) .. " " .. group[i][1]
						else
							mouseovertext = ReadText(1001, 8023) .. " " .. group[i][1]
						end

						row[i]:setColSpan(colspan):createButton({ height = slotWidths[i], bgColor = bgcolor, mouseOverText = mouseovertext }):setText(group[i][1], { halign = "center", fontsize = Helper.scaleFont(Helper.standardFont, Helper.standardFontSize) })
						if total > 0 then
							local width = math.max(1, math.floor(count * (slotWidths[i] - 2 * menu.scaleSize) / total))
							row[i]:setIcon("solid", { color = Helper.color.white, width = width + 2 * Helper.configButtonBorderSize, height = menu.scaleSize + 2 * Helper.configButtonBorderSize, x = menu.scaleSize - Helper.configButtonBorderSize, y = slotWidths[i] - 2 * menu.scaleSize - Helper.configButtonBorderSize })
						end
						row[i].handlers.onClick = function () return menu.buttonSelectSlot(group[i][1], row.index, i) end
					end
				end
			end

			local row = ftable:addRow(true, { fixed = true })
			row[1]:setColSpan(9):createEditBox({  }):setText(menu.searchtext, {  }):setHotkey("INPUT_STATE_DETAILMONITOR_0", { displayIcon = true })
			row[1].handlers.onEditBoxDeactivated = menu.editboxSearchUpdateText
			row[10]:createButton({ height = editboxheight }):setText("X", { halign = "center", font = Helper.standardFontBold })
			row[10].handlers.onClick = function () return menu.buttonClearEditbox(row.index) end

			if next(menu.groupedupgrades) then
				if menu.upgradetypeMode == "group" then
					for i, upgradetype in ipairs(Helper.upgradetypes) do
						if upgradetype.supertype == "group" then
							if menu.groups[menu.currentSlot] and (menu.groups[menu.currentSlot][upgradetype.grouptype].total > 0) then
								local plandata = menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype.type][menu.currentSlot]
								local scale = {
									min       = 0,
									minSelect = (plandata.macro == "") and 0 or 1,
									max       = menu.groups[menu.currentSlot][upgradetype.grouptype].total,
								}
								scale.maxSelect = (plandata.macro == "") and 0 or scale.max
								scale.start = math.max(scale.minSelect, math.min(scale.maxSelect, plandata.count))

								local row = ftable:addRow(true, {  })
								local name = upgradetype.text.default
								if plandata.macro == "" then
									local slotsize = menu.groups[menu.currentSlot][upgradetype.grouptype].slotsize
									if slotsize ~= "" then
										name = upgradetype.text[slotsize]
									end
								else
									name = GetMacroData(plandata.macro, "name")
								end
								row[1]:setColSpan(10):createSliderCell({ width = slidercellWidth, height = Helper.headerRow1Height, valueColor = Helper.color.slidervalue, min = scale.min, minSelect = scale.minSelect, max = scale.max, maxSelect = scale.maxSelect, start = scale.start }):setText(name, menu.slidercellTextProperties)
								row[1].handlers.onSliderCellChanged = function (_, ...) return menu.slidercellSelectAmount(upgradetype.type, menu.currentSlot, row.index, false, ...) end

								for _, group in ipairs(menu.groupedupgrades[upgradetype.grouptype]) do
									local row = ftable:addRow(true, { bgColor = Helper.color.transparent, borderBelow = false })
									local row2 = ftable:addRow(false, { bgColor = Helper.color.transparent })
									for i = 1, 3 do
										if group[i] then
											local installicon, installcolor = ""
											if (group[i].macro ~= "") then
												if (group[i].macro == menu.groups[menu.currentSlot][upgradetype.grouptype].currentmacro) and (group[i].macro ~= plandata.macro) then
													installicon = "be_upgrade_uninstalled"
													installcolor = Helper.color.red
												elseif (group[i].macro == plandata.macro) then
													installicon = "be_upgrade_installed"
													installcolor = Helper.color.green
												end
											end

											local column = i * 3 - 2
											row[column]:createButton({ width = columnWidths[i], height = maxColumnWidth }):setIcon(group[i].icon):setIcon2(installicon, { color = installcolor })
											row[column].handlers.onClick = function () return menu.buttonSelectGroupUpgrade(upgradetype.type, menu.currentSlot, group[i].macro, row.index, column) end
											if group[i].macro ~= "" then
												row[column].handlers.onRightClick = function (...) return menu.buttonInteract({ type = upgradetype.type, name = group[i].name, macro = group[i].macro }, ...) end
											end

											local extraText = ""
											if group[i].macro ~= "" then
												local shortname, makerrace, infolibrary = GetMacroData(group[i].macro, "shortname", "makerrace", "infolibrary")
												extraText = TruncateText(shortname, Helper.standardFont, menu.extraFontSize, columnWidths[i] - 2 * Helper.borderSize)
												for i, racestring in ipairs(makerrace) do
													extraText = extraText .. ((i == 1) and "\n" or " - ") .. racestring
												end
												AddKnownItem(infolibrary, group[i].macro)
											else
												extraText = TruncateText(group[i].name, Helper.standardFont, menu.extraFontSize, columnWidths[i] - 2 * Helper.borderSize) .. "\n"
											end

											row2[column]:createBoxText(extraText, { width = columnWidths[i], fontsize = menu.extraFontSize })
										end
									end
								end
							end
						end
					end
				end
			end

			ftable:setTopRow(menu.topRows.modules)
			ftable:setSelectedRow(menu.selectedRows.modules)
			ftable:setSelectedCol(menu.selectedCols.modules or 0)
		end
		menu.topRows.modules = nil
		menu.selectedRows.modules = nil
		menu.selectedCols.modules = nil
	end
end

function menu.refreshPlan()
	-- do not refresh the plan while we are in loadout edit mode -> no construction map to get data from
	if not menu.loadoutMode then
		menu.neededresources = {}
		local numTotalResources = C.PrepareBuildSequenceResources(menu.holomap, menu.container)
		if numTotalResources > 0 then
			local buf = ffi.new("UIWareInfo[?]", numTotalResources)
			numTotalResources = C.GetBuildSequenceResources(buf, numTotalResources)
			for i = 0, numTotalResources - 1 do
				table.insert(menu.neededresources, { ware = ffi.string(buf[i].ware), amount = buf[i].amount })
			end
		end
		table.sort(menu.neededresources, menu.wareNameSorter)

		menu.buildstorageresources = {}
		local n = C.GetNumCargo(menu.buildstorage, "stationbuilding")
		local buf = ffi.new("UIWareInfo[?]", n)
		n = C.GetCargo(buf, n, menu.buildstorage, "stationbuilding")
		for i = 0, n - 1 do
			table.insert(menu.buildstorageresources, { ware = ffi.string(buf[i].ware), amount = buf[i].amount })
		end

		menu.constructionplan = {}
		menu.removedModules = {}
		if menu.holomap ~= 0 then
			local n = C.GetNumBuildMapConstructionPlan(menu.holomap, false)
			local buf = ffi.new("UIConstructionPlanEntry[?]", n)
			n = tonumber(C.GetBuildMapConstructionPlan(menu.holomap, menu.container, false, buf, n))
			for i = 0, n - 1 do
				local entry = {}
				entry.idx                   = buf[i].idx
				entry.macro                 = ffi.string(buf[i].macroid)
				entry.component             = buf[i].componentid
				entry.offset                = buf[i].offset
				entry.connection            = ffi.string(buf[i].connectionid)
				entry.predecessoridx        = buf[i].predecessoridx
				entry.predecessorconnection = ffi.string(buf[i].predecessorconnectionid)
				entry.isfixed               = buf[i].isfixed

				local loadout = Helper.getLoadoutHelper(C.GetConstructionMapItemLoadout, C.GetConstructionMapItemLoadoutCounts, menu.holomap, entry.idx, menu.container)
				entry.upgradeplan           = Helper.convertLoadout(entry.component, entry.macro, loadout, nil)

				entry.resources = {}
				local numModuleResources = C.GetNumModuleNeededResources(menu.holomap, buf[i].idx)
				if numModuleResources > 0 then
					local resourceBuffer = ffi.new("UIWareInfo[?]", numModuleResources)
					numModuleResources = C.GetModuleNeededResources(resourceBuffer, numModuleResources, menu.holomap, buf[i].idx)
					for j = 0, numModuleResources - 1 do
						table.insert(entry.resources, { ware = ffi.string(resourceBuffer[j].ware), amount = resourceBuffer[j].amount })
					end
					table.sort(entry.resources, menu.wareNameSorter)
				end

				table.insert(menu.constructionplan, entry)
			end
			local newIndex = ffi.new("uint32_t[1]", 0)
			local n = C.GetNumRemovedConstructionPlanModules(menu.holomap, menu.container, newIndex, false)
			menu.newModulesIndex = tonumber(newIndex[0]) + 1
			if n > 0 then
				local buf = ffi.new("UniverseID[?]", n)
				n = tonumber(C.GetRemovedConstructionPlanModules(buf, n))
				for i = 0, n - 1 do
					local compID = ConvertStringToLuaID(tostring(buf[i]))
					local loadout = Helper.getLoadoutHelper(C.GetCurrentLoadout, C.GetCurrentLoadoutCounts, menu.container, buf[i])

					local resources = {}
					local numModuleResources = C.GetNumModuleRecycledResources(buf[i])
					if numModuleResources > 0 then
						local resourceBuffer = ffi.new("UIWareInfo[?]", numModuleResources)
						numModuleResources = C.GetModuleRecycledResources(resourceBuffer, numModuleResources, buf[i])
						for j = 0, numModuleResources - 1 do
							table.insert(resources, { ware = ffi.string(resourceBuffer[j].ware), amount = -resourceBuffer[j].amount })
						end
						table.sort(resources, menu.wareNameSorter)
					end

					table.insert(menu.removedModules, { macro = GetComponentData(compID, "macro"), component = buf[i], upgradeplan = Helper.convertLoadout(buf[i], "", loadout, nil), resources = resources })
				end
			end

			-- errors & warnings
			menu.criticalerrors = {}
			menu.errors = {}
			menu.warnings = {}
			if (menu.newModulesIndex > 0) and (menu.newModulesIndex <= #menu.constructionplan) then
				local immediateresources = {}
				for i, resource in ipairs(menu.constructionplan[menu.newModulesIndex].resources) do
					immediateresources[i] = { ware = resource.ware, amount = resource.amount }
				end
				for i = #immediateresources, 1, -1 do
					local entry = immediateresources[i]
					local idx = menu.findWareIdx(menu.buildstorageresources, entry.ware)
					if idx then
						entry.amount = entry.amount - menu.buildstorageresources[idx].amount
						if entry.amount <= 0 then
							table.remove(immediateresources, i)
						end
					end
				end
				if #immediateresources > 0 then
					for i = #immediateresources, 1, -1 do
						local entry = immediateresources[i]
						for _, removedModule in ipairs(menu.removedModules) do
							local idx = menu.findWareIdx(removedModule.resources, entry.ware)
							if idx then
								entry.amount = entry.amount + removedModule.resources[idx].amount
								if entry.amount <= 0 then
									table.remove(immediateresources, i)
									break
								end
							end
						end
					end
					if #immediateresources > 0 then
						menu.warnings[1] = ReadText(1001, 7913)
					end
				end
			end

			menu.constructionvessels = {}
			Helper.ffiVLA(menu.constructionvessels, "UniverseID", C.GetNumAssignedConstructionVessels, C.GetAssignedConstructionVessels, menu.buildstorage)
			if #menu.constructionvessels == 0 then
				menu.errors[1] = ReadText(1001, 7914)
			end

			local haspier, hasdock = false, false
			for _, entry in ipairs(menu.constructionplan) do
				if IsMacroClass(entry.macro, "pier") then
					haspier = true
					if hasdock then
						break
					end
				end
				if IsMacroClass(entry.macro, "dockarea") then
					hasdock = true
					if haspier then
						break
					end
				end
			end
			if (not haspier) and (not hasdock) then
				menu.criticalerrors[1] = ReadText(1001, 7915)
			elseif not hasdock then
				menu.warnings[2] = ReadText(1001, 7916)
			elseif not haspier then
				menu.warnings[3] = ReadText(1001, 7917)
			end
		end
	end
end

function menu.getETAString(name, eta)
	local curtime = GetCurTime()
	if (eta > 0) then
		if (eta - curtime > 0) then
			return ConvertTimeString(eta - curtime, ReadText(1001, 204)) .. " - " .. name
		else
			return ConvertTimeString(0, ReadText(1001, 204)) .. " - " .. name
		end
	else
		return "- - : - -  - " .. name
	end
end

function menu.etaSorter(a, b)
	if (a.eta < 0) then
		return false
	elseif (b.eta < 0) then
		return true
	end
	return a.eta < b.eta
end

function menu.displayPlan(frame)
	-- BUTTONS
	local buttontable = frame:addTable(2, { tabOrder = 7, width = menu.planData.width, height = Helper.standardButtonHeight, x = menu.planData.offsetX, y = Helper.viewHeight - Helper.standardButtonHeight - Helper.frameBorder, reserveScrollBar = false, backgroundID = "solid", backgroundColor = Helper.color.transparent60 })
	local row = buttontable:addRow(true, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	if not menu.loadoutMode then
		row[1]:createButton({ active = #menu.criticalerrors == 0 }):setText(ReadText(1001, 7919), { halign = "center" })
		row[1].handlers.onClick = menu.buttonConfirm
		row[2].properties.uiTriggerID = "confirmmodulechanges"
		row[2]:createButton({  }):setText(ReadText(1001, 7918), { halign = "center" })
		row[2].handlers.onClick = function () return menu.closeMenu("back") end
		row[2].properties.uiTriggerID = "cancelmodulechanges"
	else
		row[1]:createButton({  }):setText(ReadText(1001, 7921), { halign = "center" })
		row[1].handlers.onClick = menu.buttonConfirmLoadout
		row[2]:createButton({  }):setText(ReadText(1001, 7920), { halign = "center" })
		row[2].handlers.onClick = menu.buttonCancelLoadout
	end
	
	if not menu.loadoutMode then
		-- STATUS
		local statustable = frame:addTable(1, { tabOrder = 8, width = menu.planData.width, x = menu.planData.offsetX, y = 0, reserveScrollBar = false, highlightMode = "off", skipTabChange = true, backgroundID = "solid", backgroundColor = Helper.color.transparent60 })

		local row = statustable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:createText(ReadText(1001, 7922), menu.headerTextProperties)
		
		local infoCount = 0
		local visibleHeight
		for _, errorentry in Helper.orderedPairs(menu.criticalerrors) do
			row = statustable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:createText(errorentry, { color = Helper.color.red, wordwrap = true })
			infoCount = infoCount + 1
			if infoCount == 3 then
				visibleHeight = statustable:getFullHeight()
			end
		end
		for _, errorentry in Helper.orderedPairs(menu.errors) do
			row = statustable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:createText(errorentry, { color = Helper.color.red, wordwrap = true })
			infoCount = infoCount + 1
			if infoCount == 3 then
				visibleHeight = statustable:getFullHeight()
			end
		end
		for _, warningentry in Helper.orderedPairs(menu.warnings) do
			row = statustable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:createText(warningentry, { color = Helper.color.orange, wordwrap = true })
			infoCount = infoCount + 1
			if infoCount == 3 then
				visibleHeight = statustable:getFullHeight()
			end
		end
		if (not next(menu.criticalerrors)) and (not next(menu.errors)) and (not next(menu.warnings)) then
			row = statustable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:createText(ReadText(1001, 7923), { color = Helper.color.green })
			infoCount = infoCount + 1
			if infoCount == 3 then
				visibleHeight = statustable:getFullHeight()
			end
		end

		if visibleHeight then
			statustable.properties.maxVisibleHeight = visibleHeight
		else
			statustable.properties.maxVisibleHeight = statustable:getFullHeight()
		end
		statustable.properties.y = buttontable.properties.y - statustable:getVisibleHeight() - 2 * Helper.borderSize

		-- CHANGES
		local ftable = frame:addTable(5, { tabOrder = 3, width = menu.planData.width, maxVisibleHeight = statustable.properties.y - menu.planData.offsetY, x = menu.planData.offsetX, y = menu.planData.offsetY, reserveScrollBar = true, backgroundID = "solid", backgroundColor = Helper.color.transparent60 })
		ftable:setColWidth(1, Helper.scaleY(Helper.standardTextHeight), false)
		ftable:setColWidth(2, Helper.scaleY(Helper.standardTextHeight), false)
		ftable:setColWidth(4, 0.3 * menu.planData.width, false)
		ftable:setColWidth(5, Helper.scaleY(Helper.standardTextHeight), false)

		-- modules
		local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(5):createText(ReadText(1001, 7924), menu.headerTextProperties)

		for i, entry in ipairs(menu.removedModules) do
			menu.displayModuleRow(ftable, i, entry, false, true)
		end
		for i = 1, #menu.constructionplan do
			menu.displayModuleRow(ftable, i, menu.constructionplan[i], i >= menu.newModulesIndex, false)
		end
		menu.totalprice = menu.calculateTotalPrice()

		menu.tradewares = {}
		local n = C.GetNumWares("stationbuilding", false, "", "")
		local buf = ffi.new("const char*[?]", n)
		n = C.GetWares(buf, n, "stationbuilding", false, "", "")
		for i = 0, n - 1 do
			table.insert(menu.tradewares, { ware = ffi.string(buf[i]) })
		end

		-- resources
		local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(5):createText(ReadText(1001, 7925), menu.headerTextProperties)
		-- have
		local row = ftable:addRow(true, {  })
		local isextended = menu.isResourceEntryExtended("buildstorage")
		row[1]:createButton({  }):setText(isextended and "-" or "+", { halign = "center" })
		row[1].handlers.onClick = function () return menu.buttonExtendResourceEntry("buildstorage", row.index) end
		row[2]:setColSpan(4):createText(ReadText(1001, 7926) .. (menu.newWareReservation and " \27G[+" .. menu.newWareReservation .. "]" or ""))
		if isextended then
			menu.newWareReservation = nil
			if #menu.buildstorageresources > 0 then
				for _, resource in ipairs(menu.buildstorageresources) do
					local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(GetWareData(resource.ware, "name"))
					row[4]:setColSpan(2):createText(ConvertIntegerString(resource.amount, true, 0, false), { halign = "right" })
				end
			else
				local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(5):createText("--- " .. ReadText(1001, 32) .. " ---", { halign = "center" })
			end
			-- reservations
			local reservations = {}
			local n = C.GetNumContainerWareReservations(menu.buildstorage)
			local buf = ffi.new("WareReservationInfo[?]", n)
			n = C.GetContainerWareReservations(buf, n, menu.buildstorage)
			for i = 0, n - 1 do
				local ware = ffi.string(buf[i].ware)
				if reservations[ware] then
					table.insert(reservations[ware], { reserver = buf[i].reserverid, amount = buf[i].amount, eta = buf[i].eta })
				else
					reservations[ware] = { { reserver = buf[i].reserverid, amount = buf[i].amount, eta = buf[i].eta } }
				end
			end
			for _, data in pairs(reservations) do
				table.sort(data, menu.etaSorter)
			end

			if next(reservations) then
				local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(5):createText(ReadText(1001, 7946), Helper.subHeaderTextProperties)
				for _, ware in ipairs(menu.tradewares) do
					if reservations[ware.ware] then
						local isextended = menu.isResourceEntryExtended("reservation" .. ware.ware, true)
						local titlerow = ftable:addRow(true, { bgColor = Helper.color.transparent })
						titlerow[1]:createButton({  }):setText(isextended and "-" or "+", { halign = "center" })
						titlerow[1].handlers.onClick = function () return menu.buttonExtendResourceEntry("reservation" .. ware.ware, row.index) end
						local color = Helper.color.white
						if menu.newWareReservationWares[ware.ware] then
							color = Helper.color.green
						end
						titlerow[2]:setColSpan(2):createText(GetWareData(ware.ware, "name"), { color = color })
						local total = 0
						for _, reservation in ipairs(reservations[ware.ware]) do
							total = total + reservation.amount
							if isextended then
								local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
								local reserverid = ConvertStringTo64Bit(tostring(reservation.reserver))
								local name = ffi.string(C.GetComponentName(reservation.reserver)) .. " (" .. ffi.string(C.GetObjectIDCode(reservation.reserver)) .. ")"
								local colorprefix = GetComponentData(reserverid, "isplayerowned") and "\27G" or ""
								row[2]:setColSpan(2):createText(function () return menu.getETAString(colorprefix .. name, reservation.eta) end, { font = Helper.standardFontMono, mouseOverText = name })
								local color = Helper.color.white
								if menu.newWareReservationWares[ware.ware] and menu.newWareReservationWares[ware.ware][tostring(reserverid)] then
									color = Helper.color.green
								end
								row[4]:setColSpan(2):createText(ConvertIntegerString(reservation.amount, true, 0, false), { halign = "right", color = color })
							end
						end
						titlerow[4]:setColSpan(2):createText(ConvertIntegerString(total, true, 0, false), { halign = "right" })
					end
				end
			end
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2 })
			menu.newWareReservationWares = {}
		end
		-- needed
		local row = ftable:addRow(true, {  })
		local isextended = menu.isResourceEntryExtended("neededresources")
		row[1]:createButton({  }):setText(isextended and "-" or "+", { halign = "center" })
		row[1].handlers.onClick = function () return menu.buttonExtendResourceEntry("neededresources", row.index) end
		row[2]:setColSpan(4):createText(ReadText(1001, 7927))
		if isextended then
			local shown = false
			for _, resource in ipairs(menu.neededresources) do
				if resource.amount > 0 then
					shown = true
					local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(GetWareData(resource.ware, "name"))
					row[4]:setColSpan(2):createText(ConvertIntegerString(resource.amount, true, 0, false), { halign = "right" })
				end
			end
			if not shown then
				local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(5):createText("--- " .. ReadText(1001, 32) .. " ---", { halign = "center" })
			end
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:createText("", { fontsize = 1, minRowHeight = Helper.standardTextHeight / 2 })
		end
		--config
		local row = ftable:addRow(true, {  })
		local isextended = menu.isResourceEntryExtended("resourceconfig")
		row[1]:createButton({  }):setText(isextended and "-" or "+", { halign = "center" })
		row[1].handlers.onClick = function () return menu.buttonExtendResourceEntry("resourceconfig", row.index) end
		row[1].properties.uiTriggerID = "extendresourceentry"
		row[2]:setColSpan(4):createText(ReadText(1001, 7928))
		if isextended then
			-- global price modifier
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[2]:setColSpan(4):createText(ReadText(1001, 7944), Helper.subHeaderTextProperties)
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			menu.globalpricefactor = C.GetContainerGlobalPriceFactor(menu.buildstorage)
			local hasvalidmodifier = menu.globalpricefactor >= 0
			row[2]:createCheckBox(hasvalidmodifier, { })
			row[2].handlers.onClick = menu.checkboxToggleGlobalWarePriceModifier
			row[3]:setColSpan(3):createText(ReadText(1001, 7945))
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			local currentfactor = menu.globalpricefactor * 100
			row[2]:setColSpan(4):createSliderCell({ height = Helper.standardTextHeight, valueColor = hasvalidmodifier and Helper.color.slidervalue or Helper.color.grey, min = 0, max = 100, start = hasvalidmodifier and currentfactor or 100, suffix = "%", readOnly = not hasvalidmodifier, hideMaxValue = true }):setText(ReadText(1001, 2808))
			row[2].handlers.onSliderCellChanged = function (_, ...) return menu.slidercellGlobalWarePriceFactor(row.index, ...) end
			-- trade restrictions
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[2]:setColSpan(4):createText(ReadText(1001, 7931), Helper.subHeaderTextProperties)

			local traderestrictions = GetTradeRestrictions(ConvertStringTo64Bit(tostring(menu.buildstorage)))
			for _, ware in ipairs(menu.tradewares) do
				local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				local restricted
				if next(traderestrictions.overrides) and (traderestrictions.overrides[ware.ware] ~= nil) then
					restricted = traderestrictions.overrides[ware.ware]
				else
					restricted = traderestrictions.faction
				end
				row[2]:createCheckBox(not restricted, { })
				row[2].handlers.onClick = function () return menu.checkboxToggleWareOverride(ware.ware) end
				row[3]:setColSpan(3):createText(GetWareData(ware.ware, "name"))

				local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				ware.row = row.index
				ware.minprice, ware.maxprice = GetWareData(ware.ware, "minprice", "maxprice")
				local currentprice = GetContainerWarePrice(menu.buildstorage, ware.ware, true, true)
				row[2]:setColSpan(4):createSliderCell({ height = Helper.standardTextHeight, valueColor = restricted and Helper.color.grey or Helper.color.slidervalue, min = ware.minprice, max = ware.maxprice, start = currentprice, suffix = ReadText(1001, 101), readOnly = restricted, hideMaxValue = true }):setText(ReadText(1001, 2808))
				row[2].handlers.onSliderCellChanged = function (_, ...) return menu.slidercellWarePriceOverride(ware.ware, row.index, ...) end
			end
			-- price
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[2]:setColSpan(4):createText(ReadText(1001, 7929), Helper.subHeaderTextProperties)
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[2]:setColSpan(4):createText(ConvertMoneyString(menu.totalprice, false, true, 0, true) .. " " .. ReadText(1001, 101), { halign = "right" })
			-- account
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[2]:setColSpan(4):createText(ReadText(1001, 7930), Helper.subHeaderTextProperties)
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			local buildstoragemoney = GetComponentData(ConvertStringTo64Bit(tostring(menu.buildstorage)), "money")
			local playermoney = GetPlayerMoney()
			local min = 0
			local max = buildstoragemoney + playermoney
			local start = math.max(min, math.min(max, menu.newAccountValue or buildstoragemoney))
			row[2]:setColSpan(4):createSliderCell({ height = Helper.standardTextHeight, valueColor = Helper.color.slidervalue, min = min, max = max, start = start, suffix = ReadText(1001, 101), hideMaxValue = true })
			row[2].handlers.onSliderCellChanged = menu.slidercellMoney
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[2]:setColSpan(2):createButton({ active = (menu.newAccountValue ~= nil) and (menu.newAccountValue ~= buildstoragemoney) }):setText(ReadText(1001, 2821), { halign = "center" })
			row[2].handlers.onClick = menu.buttonConfirmMoney
			row[2].properties.uiTriggerID = "confirmcredits"
		end

		-- CVs
		local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(5):createText(ReadText(1001, 7932), menu.headerTextProperties)

		if #menu.constructionvessels > 0 then
			for _, component in ipairs(menu.constructionvessels) do
				row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(5):createText(ffi.string(C.GetComponentName(component)))
			end
		else
			row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:setColSpan(5):createText(ReadText(1001, 7933))
		end
		row = ftable:addRow(true, { bgColor = Helper.color.transparent })
		row[1]:setColSpan(5):createButton({ active = #menu.constructionvessels == 0 }):setText(ReadText(1001, 7934), { halign = "center" })
		row[1].handlers.onClick = menu.buttonAssignConstructionVessel
		row[1].properties.uiTriggerID = "assignhirebuilder"

		ftable:setTopRow(menu.topRows.plan)
		ftable:setSelectedRow(menu.selectedRows.plan)
		menu.topRows.plan = nil
		menu.selectedRows.plan = nil
	else
		-- EQUIPMENT
		local ftable = frame:addTable(5, { tabOrder = 3, width = menu.planData.width, maxVisibleHeight = buttontable.properties.y - menu.planData.offsetY, x = menu.planData.offsetX, y = menu.planData.offsetY, reserveScrollBar = true, skipTabChange = true, highlightMode = "off", backgroundID = "solid", backgroundColor = Helper.color.transparent60 })
		ftable:setColWidth(1, Helper.standardTextHeight)
		ftable:setColWidth(2, Helper.standardTextHeight)
		ftable:setColWidth(4, 0.3 * menu.planData.width)
		ftable:setColWidth(5, Helper.standardTextHeight)

		local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(5):createText(ReadText(1001, 7935), menu.headerTextProperties)

		local removedEquipment = {}
		local currentEquipment = {}
		local newEquipment = {}
		for i, upgradetype in ipairs(Helper.upgradetypes) do
			local slots = menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype.type]
			local first = true
			for slot, macro in pairs(slots) do
				if first or (not upgradetype.mergeslots) then
					first = false
					if upgradetype.supertype == "group" then
						local data = macro
						local oldslotdata = menu.groups[slot][upgradetype.grouptype]

						if data.macro ~= "" then
							local i = menu.findUpgradeMacro(upgradetype.grouptype, data.macro)
							if not i then
								break
							end
							local upgradeware = menu.upgradewares[upgradetype.grouptype][i]

							if oldslotdata.currentmacro ~= "" then
								local j = menu.findUpgradeMacro(upgradetype.grouptype, oldslotdata.currentmacro)
								if not j then
									break
								end
								local oldupgradeware = menu.upgradewares[upgradetype.grouptype][j]

								if data.macro == oldslotdata.currentmacro then
									if upgradetype.mergeslots then
										menu.insertWare(currentEquipment, upgradeware.ware, (upgradetype.mergeslots and #slots or data.count))
									else
										if oldslotdata.count < data.count then
											menu.insertWare(currentEquipment, upgradeware.ware, oldslotdata.count)
											menu.insertWare(newEquipment, upgradeware.ware, data.count - oldslotdata.count)
										elseif oldslotdata.count > data.count then
											menu.insertWare(currentEquipment, upgradeware.ware, data.count)
											menu.insertWare(removedEquipment, upgradeware.ware, oldslotdata.count - data.count)
										else
											menu.insertWare(currentEquipment, upgradeware.ware, (upgradetype.mergeslots and #slots or data.count))
										end
									end
								else
									menu.insertWare(removedEquipment, oldupgradeware.ware, (upgradetype.mergeslots and #slots or oldslotdata.count))
									menu.insertWare(newEquipment, upgradeware.ware, (upgradetype.mergeslots and #slots or data.count))
								end
							else
								menu.insertWare(newEquipment, upgradeware.ware, (upgradetype.mergeslots and #slots or data.count))
							end
						elseif oldslotdata.currentmacro ~= "" then
							local j = menu.findUpgradeMacro(upgradetype.grouptype, oldslotdata.currentmacro)
							if not j then
								break
							end
							local oldupgradeware = menu.upgradewares[upgradetype.grouptype][j]

							menu.insertWare(removedEquipment, oldupgradeware.ware, (upgradetype.mergeslots and #slots or oldslotdata.count))
						end
					end
				end
			end
		end

		if (#removedEquipment > 0) or (#currentEquipment > 0) or (#newEquipment > 0) then
			for _, entry in ipairs(removedEquipment) do
				row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(5):createText(entry.amount .. ReadText(1001, 42) .. " " .. GetWareData(entry.ware, "name"), { color = Helper.color.red })
			end
			for _, entry in ipairs(currentEquipment) do
				row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(5):createText(entry.amount .. ReadText(1001, 42) .. " " .. GetWareData(entry.ware, "name"))
			end
			for _, entry in ipairs(newEquipment) do
				row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(5):createText(entry.amount .. ReadText(1001, 42) .. " " .. GetWareData(entry.ware, "name"), { color = Helper.color.green })
			end
		else
			row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:setColSpan(5):createText("--- " .. ReadText(1001, 7936) .. " ---", { halign = "center" } )
		end
	end
end

function menu.displayModuleInfo(frame)
	local ftable = frame:addTable(2, { tabOrder = 0, width = menu.statsData.width, x = menu.statsData.offsetX, y = 0, reserveScrollBar = false, backgroundID = "solid", backgroundColor = Helper.color.transparent60 })

	local name, infolibrary = GetMacroData(menu.selectedModule.macro, "name", "infolibrary")

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createText(name, menu.headerCenteredTextProperties)

	local data = GetLibraryEntry(infolibrary, menu.selectedModule.macro)

	if infolibrary == "moduletypes_production" and data.allowproduction then
		local product = data.products[1].ware
		-- product
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:createText(ReadText(1001, 1624))
		local amount = Helper.round(data.products[1].amount * 3600 / data.products[1].cycle)
		row[2]:createText(amount .. ReadText(1001, 42) .. " " .. GetWareData(product, "name") .. " / " .. ReadText(1001, 102))
		-- resources
		local resources = data.products[1].resources
		if #resources > 0 then
			for i, resource in ipairs(resources) do
				local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
				if i == 1 then
					row[1]:createText(ReadText(1001, 7403))
				end
				local amount = Helper.round(resource.amount * 3600 / data.products[1].cycle)
				row[2]:createText(amount .. ReadText(1001, 42) .. " " .. GetWareData(resource.ware, "name") .. " / " .. ReadText(1001, 102))
			end
		else
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:createText(ReadText(1001, 7403))
			row[2]:createText("---")
		end
	elseif infolibrary == "moduletypes_storage" then
		if data.storagecapacity > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:createText(ReadText(1001, 9063))
			row[2]:createText(ConvertIntegerString(data.storagecapacity, true, 0, true) .. " " .. ReadText(1001, 110))
		end
	elseif infolibrary == "moduletypes_habitation" then
		if data.workforcecapacity > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:createText(ReadText(1001, 9611))
			row[2]:createText(ConvertIntegerString(data.workforcecapacity, true, 0, true))
		end
		if #data.workforceresources > 0 then
			for i, resource in ipairs(data.workforceresources) do
				local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
				if i == 1 then
					row[1]:createText(string.format(ReadText(1001, 7957), ConvertIntegerString(data.workforcecapacity, true, 0, true, false)))
				end
				local amount = Helper.round(resource.amount * 3600 / resource.cycle * data.workforcecapacity / data.workforceproductamount)
				row[2]:createText(amount .. ReadText(1001, 42) .. " " .. resource.name .. " / " .. ReadText(1001, 102))
			end
		end
	end
	-- docks
	if (data.docks_xl > 0) or (data.docks_l > 0) or (data.docks_m > 0) or (data.docks_s > 0) then
		local first = true
		if data.docks_xl > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			if first then
				first = false
				row[1]:createText(ReadText(1001, 7949))
			end
			row[2]:createText(data.docks_xl .. ReadText(1001, 42) .. " " .. ReadText(1001, 7950))
		end
		if data.docks_l > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			if first then
				first = false
				row[1]:createText(ReadText(1001, 7949))
			end
			row[2]:createText(data.docks_l .. ReadText(1001, 42) .. " " .. ReadText(1001, 7951))
		end
		if data.docks_m > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			if first then
				first = false
				row[1]:createText(ReadText(1001, 7949))
			end
			row[2]:createText(data.docks_m .. ReadText(1001, 42) .. " " .. ReadText(1001, 7952))
		end
		if data.docks_s > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			if first then
				first = false
				row[1]:createText(ReadText(1001, 7949))
			end
			row[2]:createText(data.docks_s .. ReadText(1001, 42) .. " " .. ReadText(1001, 7953))
		end
	end
	-- launchtubes
	if (data.launchtubes_m > 0) or (data.launchtubes_s > 0) then
		local first = true
		if data.launchtubes_m > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			if first then
				first = false
				row[1]:createText(ReadText(1001, 7954))
			end
			row[2]:createText(data.launchtubes_m .. ReadText(1001, 42) .. " " .. ReadText(1001, 7955))
		end
		if data.launchtubes_s > 0 then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			if first then
				first = false
				row[1]:createText(ReadText(1001, 7954))
			end
			row[2]:createText(data.launchtubes_s .. ReadText(1001, 42) .. " " .. ReadText(1001, 7956))
		end
	end
	-- ship storage
	if data.shipstoragecapacity > 0 then
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:createText(ReadText(1001, 9612))
		row[2]:createText(data.shipstoragecapacity)
	end
	-- turrets
	local numturrets = C.GetNumUpgradeSlots(menu.selectedModule.component, menu.selectedModule.macro, "turret")
	if numturrets > 0 then
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:createText(ReadText(1001, 1319))
		row[2]:createText(tonumber(numturrets))
	end

	ftable.properties.y = Helper.viewHeight - ftable:getVisibleHeight() - menu.statsData.offsetY
end

function menu.displayModuleRow(ftable, index, entry, added, removed)
	local isextended = menu.isEntryExtended(menu.container, (removed and "rem" or "") .. index)

	local color = Helper.color.white
	if removed then
		color = Helper.color.red
	elseif added then
		color = Helper.color.green
	end

	local row = ftable:addRow({ ismodule = true, idx = entry.idx, module = entry, removed = removed }, {  })
	row[1]:createButton({ active = removed or added }):setText(isextended and "-" or "+", { halign = "center" })
	row[1].handlers.onClick = function () return menu.buttonExtendEntry((removed and "rem" or "") .. index, row.index) end
	row[2]:setColSpan(2):setBackgroundColSpan(3):createText(GetMacroData(entry.macro, "name"), { color = color, mouseOverText = menu.getLoadoutSummary(entry.upgradeplan) })
	local ismissingresources = false
	if IsComponentConstruction(ConvertStringTo64Bit(tostring(entry.component))) then
		local buildingprocessor = GetComponentData(menu.container, "buildingprocessor")
		ismissingresources = GetComponentData(buildingprocessor, "ismissingresources")
	end
	row[4]:createText(function () return menu.getBuildProgress(entry.component, added, removed) end, { halign = "right", color = color, mouseOverText = ismissingresources and ReadText(1026, 3223) or "" })
	local active = false
	for i, upgradetype in ipairs(Helper.upgradetypes) do
		if upgradetype.supertype == "macro" then
			if C.GetNumUpgradeSlots(entry.component, entry.macro, upgradetype.type) > 0 then
				active = true
				break
			end
		end
	end
	if active and (not removed) then
		row[5]:createButton({  }):setIcon("menu_edit")
		row[5].handlers.onClick = function () return menu.buttonEditLoadout(entry) end
	else
		row[2]:setBackgroundColSpan(4)
	end

	local ware = GetMacroData(entry.macro, "ware")
	if not ware then
		DebugError("No ware defined for module macro '" .. entry.macro .. "'. [Florian]")
	else
		if removed or added then
			if isextended then
				for _, resource in ipairs(entry.resources) do
					local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(GetWareData(resource.ware, "name"))
					row[4]:setColSpan(2):createText(resource.amount, { halign = "right" })
				end
			end
		end
	end
end

function menu.findWareIdx(array, ware)
	for i, v in ipairs(array) do
		if v.ware == ware then
			return i
		end
	end
end

function menu.insertWare(array, ware, count)
	local i = menu.findWareIdx(array, ware)
	if i then
		array[i].amount = array[i].amount + count
	else
		table.insert(array, { ware = ware, amount = count })
	end
end

function menu.getLoadoutSummary(upgradeplan)
	local wareAmounts = {}

	for i, upgradetype in ipairs(Helper.upgradetypes) do
		local slots = upgradeplan[upgradetype.type]
		local first = true
		for slot, macro in pairs(slots) do
			if first or (not upgradetype.mergeslots) then
				first = false
				if upgradetype.supertype == "group" then
					local data = macro
					if data.macro ~= "" then
						local i = menu.findUpgradeMacro(upgradetype.grouptype, data.macro)
						if not i then
							break
						end
						local upgradeware = menu.upgradewares[upgradetype.grouptype][i]
						menu.insertWare(wareAmounts, upgradeware.ware, (upgradetype.mergeslots and #slots or data.count))
					end
				end
			end
		end
	end

	local summary = ReadText(1001, 7935) .. ReadText(1001, 120)
	for _, entry in ipairs(wareAmounts) do
		summary = summary .. "\n" .. entry.amount .. ReadText(1001, 42) .. " " .. GetWareData(entry.ware, "name")
	end
	return summary
end

function menu.getBuildProgress(component, added, removed)
	local buildprogress = (removed or (not added)) and 100 or 0
	if IsComponentConstruction(ConvertStringTo64Bit(tostring(component))) then
		buildprogress = math.floor(C.GetCurrentBuildProgress(menu.container))
		if removed then
			buildprogress = 100 - buildprogress
		end
		
		local buildingprocessor = GetComponentData(menu.container, "buildingprocessor")
		local ismissingresources = GetComponentData(buildingprocessor, "ismissingresources")
		buildprogress = (ismissingresources and "\27Y\27[warning](" or "(") .. ConvertTimeString(C.GetBuildProcessorEstimatedTimeLeft(ConvertIDTo64Bit(buildingprocessor)), "%h:%M:%S") .. ")\27X  " .. buildprogress
	elseif added then
		buildprogress = "-"
	end

	return buildprogress .. " %"
end

function menu.calculateTotalPrice()
	local price = 0
	for _, resource in ipairs(menu.neededresources) do
		if resource.amount > 0 then
			price = price + RoundTotalTradePrice(resource.amount * tonumber(GetContainerWarePrice(menu.buildstorage, resource.ware, true, true)))
		end
	end
	return price
end

function menu.wareNameSorter(a, b)
	local aname = GetWareData(a.ware, "name")
	local bname = GetWareData(b.ware, "name")

	return aname < bname
end

function menu.displayMainFrame()
	Helper.removeAllWidgetScripts(menu, config.mainLayer)

	menu.mainFrame = Helper.createFrameHandle(menu, {
		layer = config.mainLayer,
		standardButtons = { back = true, close = true },
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		x = 0,
		y = 0,
	})

	-- right sidebar
	menu.createRightSideBar(menu.mainFrame)

	-- title bar
	menu.createTitleBar(menu.mainFrame)

	-- construction map
	menu.mainFrame:addRenderTarget({width = menu.mapData.width, height = menu.mapData.height, x = menu.mapData.offsetX, y = menu.mapData.offsetY, scaling = false, alpha = 100})

	menu.mainFrame:display()
end

function menu.displayContextFrame(mode, width, x, y)
	PlaySound("ui_positive_click")
	menu.contextMode = { mode = mode, width = width, x = x, y = y }
	if mode == "saveCP" then
		menu.createCPSaveContext()
	elseif mode == "saveLoadout" then
		menu.createLoadoutSaveContext()
	elseif mode == "equipment" then
		menu.createEquipmentContext()
	elseif mode == "module" then
		menu.createModuleContext()
	end
end

function menu.createModuleContext()
	Helper.removeAllWidgetScripts(menu, config.contextLayer)

	menu.contextFrame = Helper.createFrameHandle(menu, {
		layer = config.contextLayer,
		standardButtons = { close = true },
		backgroundID = "solid",
		backgroundColor = Helper.color.semitransparent,
		width = menu.contextMode.width,
		x = menu.contextMode.x,
		y = menu.contextMode.y,
		autoFrameHeight = true,
	})

	local ftable = menu.contextFrame:addTable(1, { tabOrder = 5, reserveScrollBar = false })

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createText(GetMacroData(ffi.string(menu.contextData.item.macro), "name"), Helper.subHeaderTextProperties)

	local active = false
	for i, upgradetype in ipairs(Helper.upgradetypes) do
		if upgradetype.supertype == "macro" then
			if C.GetNumUpgradeSlots(menu.contextData.item.component, menu.contextData.item.macro, upgradetype.type) > 0 then
				active = true
				break
			end
		end
	end
	if active then
		local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:createButton({ active = true, bgColor = Helper.color.transparent }):setText(ReadText(1001, 7938), { color = Helper.color.white })
		row[1].handlers.onClick = function () return menu.buttonEditLoadout(menu.contextData.item) end
	end

	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createButton({ active = not menu.contextData.item.isfixed, bgColor = Helper.color.transparent }):setText(ReadText(1001, 7947), { color = Helper.color.white })
	row[1].handlers.onClick = function () return menu.buttonCopyModule(menu.contextData.item, false) end

	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createButton({ active = not menu.contextData.item.isfixed, bgColor = Helper.color.transparent }):setText(ReadText(1001, 7948), { color = Helper.color.white })
	row[1].handlers.onClick = function () return menu.buttonCopyModule(menu.contextData.item, true) end

	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createButton({ active = not menu.contextData.item.isfixed, bgColor = Helper.color.transparent }):setText(ReadText(1001, 7937), { color = Helper.color.white })
	row[1].handlers.onClick = function () return menu.buttonRemoveModule(menu.contextData.item) end

	menu.contextFrame:display()
end

function menu.createEquipmentContext()
	Helper.removeAllWidgetScripts(menu, config.contextLayer)

	menu.contextFrame = Helper.createFrameHandle(menu, {
		layer = config.contextLayer,
		standardButtons = { close = true },
		backgroundID = "solid",
		backgroundColor = Helper.color.semitransparent,
		width = menu.contextMode.width,
		x = menu.contextMode.x,
		y = menu.contextMode.y,
		autoFrameHeight = true,
	})

	local ftable = menu.contextFrame:addTable(1, { tabOrder = 5, reserveScrollBar = false })

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createText(menu.selectedUpgrade.name, Helper.subHeaderTextProperties)

	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createButton({ active = true, bgColor = Helper.color.transparent }):setText(ReadText(1001, 2400), { color = Helper.color.white })
	row[1].handlers.onClick = function () return menu.buttonContextEncyclopedia(menu.selectedUpgrade) end

	menu.contextFrame:display()
end

function menu.checkCPNameID()
	local ismasterversion = C.IsMasterVersion()
	local canoverwrite = false
	local cansaveasnew = false
	local source = ""
	if menu.currentCPID then
		local found = false
		for _, plan in ipairs(menu.constructionplans) do
			if plan.id == menu.currentCPID then
				found = true
				source = plan.source
				if (source == "local") or ((source == "library") and (not ismasterversion)) then
					canoverwrite = true
				end
				menu.currentCPName = plan.name
				break
			end
		end
		if not found then
			menu.currentCPID = nil
		end
	end
	if (not menu.currentCPID) and menu.currentCPName and (menu.currentCPName ~= "") then
		cansaveasnew = true
		for _, plan in ipairs(menu.constructionplans) do
			if plan.name == menu.currentCPName then
				source = plan.source
				if (source == "local") or ((source == "library") and (not ismasterversion)) then
					canoverwrite = true
				end
				cansaveasnew = false
				menu.currentCPID = plan.id
				break
			end
		end
	end

	return canoverwrite, cansaveasnew, source
end

function menu.createCPSaveContext()
	Helper.removeAllWidgetScripts(menu, config.contextLayer)

	menu.contextFrame = Helper.createFrameHandle(menu, {
		layer = config.contextLayer,
		standardButtons = { close = true },
		width = menu.contextMode.width,
		x = menu.contextMode.x,
		y = menu.contextMode.y,
		autoFrameHeight = true,
	})

	local ftable = menu.contextFrame:addTable(2, { tabOrder = 6, scaling = false, borderEnabled = false, reserveScrollBar = false })
	ftable:setDefaultCellProperties("button", { height = Helper.standardTextHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = Helper.standardFontSize, halign = "center" })

	local canoverwrite, cansaveasnew, source = menu.checkCPNameID()

	local row = ftable:addRow(true, { fixed = true })
	row[1]:setColSpan(2):createEditBox({ height = menu.titleData.height }):setText(menu.currentCPName or "", { halign = "center", font = Helper.headerRow1Font, fontsize = Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize) })
	row[1].handlers.onTextChanged = menu.editboxCPNameUpdateText

	row = ftable:addRow(true, { scaling = true, fixed = true })
	row[1]:createButton({ active = menu.checkOverwriteActive, mouseOverText = ReadText(1026, 7906) }):setText(ReadText(1001, 7907), {  })
	row[1].handlers.onClick = function () return menu.buttonSave(true) end
	row[2]:createButton({ active = menu.checkSaveNewActive, mouseOverText = ReadText(1026, 7907) }):setText(ReadText(1001, 7909), {  })
	row[2].handlers.onClick = function () return menu.buttonSave(false) end

	menu.contextFrame:display()
end

function menu.checkOverwriteActive()
	local canoverwrite, cansaveasnew, source = menu.checkCPNameID()
	return canoverwrite
end

function menu.checkSaveNewActive()
	local canoverwrite, cansaveasnew, source = menu.checkCPNameID()
	return cansaveasnew
end

function menu.checkLoadoutNameID()
	local canoverwrite = false
	local cansaveasnew = false
	if menu.loadout then
		local found = false
		for _, loadout in ipairs(menu.loadouts) do
			if loadout.id == menu.loadout then
				menu.loadoutName = loadout.name
				break
			end
		end
		if not found then
			menu.loadout = nil
		end
	end
	if (not menu.loadout) and menu.loadoutName and (menu.loadoutName ~= "") then
		cansaveasnew = true
		for _, loadout in ipairs(menu.loadouts) do
			if loadout.name == menu.loadoutName then
				canoverwrite = true
				cansaveasnew = false
				menu.loadout = loadout.id
				break
			end
		end
	end

	return canoverwrite, cansaveasnew
end

function menu.createLoadoutSaveContext()
	Helper.removeAllWidgetScripts(menu, config.contextLayer)

	menu.contextFrame = Helper.createFrameHandle(menu, {
		layer = config.contextLayer,
		standardButtons = { close = true },
		width = menu.contextMode.width,
		x = menu.contextMode.x,
		y = menu.contextMode.y,
		autoFrameHeight = true,
	})

	local ftable = menu.contextFrame:addTable(2, { tabOrder = 6, scaling = false, borderEnabled = false, reserveScrollBar = false })
	ftable:setDefaultCellProperties("button", { height = Helper.standardTextHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = Helper.standardFontSize, halign = "center" })

	-- magic
	local canoverwrite, cansaveasnew = menu.checkLoadoutNameID()

	local row = ftable:addRow(true, { fixed = true })
	row[1]:setColSpan(2):createEditBox({ height = menu.titleData.height }):setText(menu.loadoutName or "", { halign = "center", font = Helper.headerRow1Font, fontsize = Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize) })
	row[1].handlers.onTextChanged = menu.editboxLoadoutNameUpdateText

	row = ftable:addRow(true, { scaling = true, fixed = true })
	row[1]:createButton({ active = menu.checkLoadoutOverwriteActive, mouseOverText = ReadText(1026, 7908) }):setText(ReadText(1001, 7908), {  })
	row[1].handlers.onClick = function () return menu.buttonSaveLoadout(true) end
	row[2]:createButton({ active = menu.checkLoadoutSaveNewActive, mouseOverText = ReadText(1026, 7909) }):setText(ReadText(1001, 7909), {  })
	row[2].handlers.onClick = function () return menu.buttonSaveLoadout(false) end

	menu.contextFrame:display()
end

function menu.checkLoadoutOverwriteActive()
	local canoverwrite, cansaveasnew = menu.checkLoadoutNameID()
	return canoverwrite
end

function menu.checkLoadoutSaveNewActive()
	local canoverwrite, cansaveasnew = menu.checkLoadoutNameID()
	return cansaveasnew
end

function menu.displayMenu()
	-- Remove possible button scripts from previous view
	Helper.removeAllWidgetScripts(menu, config.infoLayer)
	Helper.currentTableRow = {}
	Helper.closeDropDownOptions(menu.titlebartable, 1, 2)

	menu.infoFrame = Helper.createFrameHandle(menu, {
		layer = config.infoLayer,
		standardButtons = {},
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		x = 0,
		y = 0,
	})

	menu.displayLeftBar(menu.infoFrame)

	menu.displayModules(menu.infoFrame)

	menu.displayPlan(menu.infoFrame)

	if menu.selectedModule then
		menu.displayModuleInfo(menu.infoFrame)
	end

	menu.infoFrame:display()
end

function menu.displayContextMenu()
	-- Remove possible button scripts from previous view
	Helper.removeAllWidgetScripts(menu, config.contextLayer)
	PlaySound("ui_positive_click")

	local width = 0
	local setup = Helper.createTableSetup(menu)
	
	if menu.contextMode == 2 then
		width = 300

		local upgradetype = Helper.findUpgradeType(menu.contextData.upgradetype)
		local upgradetype2 = Helper.findUpgradeTypeByGroupType(upgradetype.type)
		local slotdata
		if menu.upgradetypeMode == "group" then
			slotdata = menu.groups[menu.currentSlot][upgradetype2.grouptype]
		end
		local plandata
		if menu.upgradetypeMode == "group" then
			plandata = menu.constructionplan[menu.loadoutMode].upgradeplan[upgradetype2.type][menu.currentSlot]
		end
		local prefix = ""
		if upgradetype.mergeslots then
			prefix = #menu.slots[upgradetype.type] .. ReadText(1001, 42) .. " "
		end

		if menu.upgradetypeMode == "group" then
			local name = upgradetype2.text.default
			if plandata.macro == "" then
				if slotdata.slotsize ~= "" then
					name = upgradetype2.text[slotdata.slotsize]
				end
			else
				name = GetMacroData(plandata.macro, "name")
			end
			if not upgradetype2.mergeslots then
				local minselect = (plandata.macro == "") and 0 or 1
				local maxselect = (plandata.macro == "") and 0 or slotdata.total

				local scale = {
					min       = 0,
					minselect = minselect,
					max       = slotdata.total,
					maxselect = maxselect,
					start     = math.max(minselect, math.min(maxselect, plandata.count)),
					step      = 1,
					suffix    = "",
					exceedmax = false
				}
				setup:addSimpleRow({
					Helper.createSliderCell(Helper.createTextInfo(name, "left", Helper.headerRow1Font, Helper.headerRow1FontSize, 255, 255, 255, 100), false, 0, 0, 0, Helper.headerRow1Height, nil, Helper.color.slidervalue, scale, "")
				}, nil, {1})
			else
				setup:addSimpleRow({
					Helper.createFontString(name, false, "left", 255, 255, 255, 100)
				}, nil, {1})
			end
		end

		for k, macro in ipairs(slotdata.possiblemacros) do
			local name = prefix .. GetMacroData(macro, "name")

			local color = Helper.color.white
			if (macro == slotdata.currentmacro) and (macro ~= plandata.macro) then
				color = Helper.color.red
			elseif (macro == plandata.macro) then
				color = Helper.color.green
			end

			setup:addSimpleRow({
				Helper.createButton(Helper.createTextInfo(name, "left", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), color.r, color.g, color.b, color.a, Helper.standardTextOffsetx), nil, true, true, 0, 0, width, Helper.standardTextHeight)
			}, nil, {1})
		end

		if upgradetype.allowempty then
			local name = ReadText(1001, 7906)

			local color = Helper.color.white
			if ("" == slotdata.currentmacro) and ("" ~= plandata) then
				color = Helper.color.red
			elseif ("" == plandata) then
				color = Helper.color.green
			end

			setup:addSimpleRow({
				Helper.createButton(Helper.createTextInfo(name, "left", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), color.r, color.g, color.b, color.a, Helper.standardTextOffsetx), nil, true, true, 0, 0, width, Helper.standardTextHeight)
			}, nil, {1})
		end
	end
	
	local contextdesc = setup:createCustomWidthTable({width}, false, true, true, 4, 0, menu.contextData.offsetX, menu.contextData.offsetY, 0, true, menu.topRows.context, menu.selectedRows.context, nil, nil, "column")
	menu.topRows.context = nil
	menu.selectedRows.context = nil

	Helper.displayFrame(menu, {contextdesc}, false, "", "", {}, nil, config.contextLayer)
end

function menu.setUpContextMenuScripts(uitable)
	local nooflines = 1
	if menu.contextMode == 2 then
		local upgradetype = Helper.findUpgradeType(menu.contextData.upgradetype)
		local upgradetype2 = Helper.findUpgradeTypeByGroupType(upgradetype.type)
		local slotdata = menu.slots[upgradetype.type][menu.contextData.slot]

		if menu.upgradetypeMode == "group" then
			if not upgradetype.mergeslots then
				local line = nooflines
				Helper.setSliderCellScript(menu, nil, uitable, nooflines, 1, function (_, ...) return menu.slidercellSelectAmount(upgradetype2.type, menu.currentSlot, nil, line, ...) end)
			end
			nooflines = nooflines + 1
		end

		for k, macro in ipairs(slotdata.possiblemacros) do
			local line = nooflines
			if menu.upgradetypeMode == "group" then
				Helper.setButtonScript(menu, nil, uitable, nooflines, 1, function () return menu.buttonSelectGroupUpgrade(upgradetype2.type, menu.currentSlot, macro, nil, nil, line) end)
			end
			nooflines = nooflines + 1
		end

		if upgradetype.allowempty then
			local line = nooflines
			if menu.upgradetypeMode == "group" then
				Helper.setButtonScript(menu, nil, uitable, nooflines, 1, function () return menu.buttonSelectGroupUpgrade(upgradetype2.type, menu.currentSlot, "", nil, nil, line) end)
			end
		end
	end
end

function menu.viewCreated(layer, ...)
	if layer == config.mainLayer then
		menu.rightbartable, menu.titlebartable, menu.map = ...
	
		if menu.activatemap == nil then
			menu.activatemap = true
		end
	elseif layer == config.infoLayer then
		if not menu.loadoutMode then
			menu.leftbartable, menu.moduletable, menu.planbutton, menu.planstatus, menu.plantable, menu.moduleinfotable = ...
		else
			menu.leftbartable, menu.moduletable, menu.planbutton, menu.plantable, menu.moduleinfotable = ...
		end
	elseif layer == config.contextLayer then
		menu.contexttable = ...

		menu.setUpContextMenuScripts(menu.contexttable)
	end

	-- clear descriptors again
	Helper.releaseDescriptors()
end

menu.updateInterval = 0.01

function menu.onUpdate()
	if menu.activatemap then
		-- pass relative screenspace of the holomap rendertarget to the holomap (value range = -1 .. 1)
		local renderX0, renderX1, renderY0, renderY1 = Helper.getRelativeRenderTargetSize(menu, config.mainLayer, menu.map)
		local rendertargetTexture = GetRenderTargetTexture(menu.map)
		if rendertargetTexture then
			menu.holomap = C.AddHoloMap(rendertargetTexture, renderX0, renderX1, renderY0, renderY1, menu.mapData.width / menu.mapData.height, 1)
			if menu.holomap ~= 0 then
				menu.showConstructionMap()
			end

			menu.activatemap = false
			menu.refreshPlan()
			local refresh = true
			if menu.state then
				refresh = not menu.onRestoreState(menu.state)
				menu.state = nil
			end
			if refresh then
				menu.displayMainFrame()
				menu.displayMenu()
			end
		end
	end

	if (menu.newSelectedModule and ((menu.selectedModule == nil) or (menu.newSelectedModule.idx ~= menu.selectedModule.idx))) or ((menu.newSelectedModule == nil) and menu.selectedModule) then
		menu.selectedModule = menu.newSelectedModule
		menu.topRows.modules = GetTopRow(menu.moduletable)
		menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
		menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
		menu.topRows.plan = GetTopRow(menu.plantable)
		menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
		menu.refreshPlan()
		menu.displayMenu()
	end

	menu.mainFrame:update()
	menu.infoFrame:update()
	if menu.contextFrame then
		menu.contextFrame:update()
	end

	if menu.holomap ~= 0 then
		if menu.picking ~= menu.pickstate then
			menu.pickstate = menu.picking
			C.SetMapPicking(menu.holomap, menu.pickstate)
		end

		if menu.map then
			local x, y = GetRenderTargetMousePosition(menu.map)
			C.SetMapRelativeMousePosition(menu.holomap, (x and y) ~= nil, x or 0, y or 0)
		end

		local pickedentry = ffi.new("UIConstructionPlanEntry")
		local haspick = C.GetPickedBuildMapEntry(menu.holomap, menu.container, pickedentry)
		
		if menu.allowpanning and menu.leftdown then
			local offset = table.pack(GetLocalMousePosition())
			if Helper.comparePositions(menu.leftdown.position, offset, 2) then
				C.StartPanMap(menu.holomap)
				if haspick then
					if menu.selectedModule and (pickedentry.idx == menu.selectedModule.idx) then
						menu.keepcursor = true
					end
				end
				menu.allowpanning = nil
			end
		end

		if haspick then
			local macro = ffi.string(pickedentry.macroid)
			if macro ~= menu.mouseOverMacro then
				menu.mouseOverMacro = macro
				SetMouseOverOverride(menu.map, GetMacroData(macro, "name"))
				local selectedIdx = C.GetSelectedBuildMapEntry(menu.holomap)
				if ((pickedentry.idx == selectedIdx) or (pickedentry.idx == #menu.constructionplan)) and (not pickedentry.isfixed) then
					SetMouseCursorOverride("crossarrows")
				end
			end
		elseif menu.mouseOverMacro then
			menu.mouseOverMacro = nil
			SetMouseOverOverride(menu.map, nil)
			if not menu.keepcursor then
				SetMouseCursorOverride("default")
			end
		end

		if not menu.loadoutMode then
			local offset = 0
			if menu.titleData.hasshuffle then
				offset = 1
			end

			local canundo = C.CanUndoConstructionMapChange(menu.holomap)
			if canundo ~= menu.canundo then
				menu.canundo = canundo
				Helper.removeButtonScripts(menu, menu.titlebartable, 1, 5 + offset)
				SetCellContent(menu.titlebartable, Helper.createButton(nil, Helper.createButtonIcon("menu_undo", nil, 255, 255, 255, 100, nil, nil, 0, 0), true, canundo, 0, 0, 0, menu.titleData.height, nil, nil, nil, ReadText(1026, 7903) .. " (" .. GetLocalizedKeyName("action", 278) .. ")"), 1, 5 + offset)
				Helper.setButtonScript(menu, nil, menu.titlebartable, 1, 5 + offset, function () return menu.undoHelper(true) end)
			end
			
			local canredo = C.CanRedoConstructionMapChange(menu.holomap)
			if canredo ~= menu.canredo then
				menu.canredo = canredo
				Helper.removeButtonScripts(menu, menu.titlebartable, 1, 6 + offset)
				SetCellContent(menu.titlebartable, Helper.createButton(nil, Helper.createButtonIcon("menu_redo", nil, 255, 255, 255, 100, nil, nil, 0, 0), true, canredo, 0, 0, 0, menu.titleData.height, nil, nil, nil, ReadText(1026, 7904) .. " (" .. GetLocalizedKeyName("action", 279) .. ")"), 1, 6 + offset)
				Helper.setButtonScript(menu, nil, menu.titlebartable, 1, 6 + offset, function () return menu.undoHelper(false) end)
			end
		end
	end
end

function menu.onRowChanged(row, rowdata, uitable)
	if not menu.loadoutMode then
		if uitable == menu.plantable then
			if menu.holomap ~= 0 then
				if (type(rowdata) == "table") and rowdata.ismodule and (not rowdata.removed) then
					menu.newSelectedModule = rowdata.module
					C.SelectBuildMapEntry(menu.holomap, rowdata.idx)
				else
					menu.newSelectedModule = nil
					C.ClearBuildMapSelection(menu.holomap)
				end
			end
		end
	end
end

function menu.onSelectElement()
end

function menu.closeMenu(dueToClose)
	if dueToClose == "back" then
		if menu.loadoutMode then
			menu.buttonCancelLoadout()
			return
		end
	end
	if dueToClose == "close" then
		C.ReleaseConstructionMapState()
	end
	Helper.closeMenu(menu, dueToClose)
	menu.cleanup()
end

function menu.onCloseElement(dueToClose)
	if menu.contextMode then
		menu.closeContextMenu()
		return
	end

	if menu.loadoutMode then
		if menu.upgradetypeMode and (dueToClose == "back") then
			menu.deactivateUpgradetypeMode()
			return
		end
	else
		if menu.modulesMode and (dueToClose == "back") then
			menu.deactivateModulesMode()
			return
		end
	end

	menu.closeMenu(dueToClose)
end

function menu.closeContextMenu()
	Helper.clearFrame(menu, config.contextLayer)

	-- REMOVE this block once the mouse out/over event order is correct -> This should be unnessecary due to the global tablemouseout event reseting the picking
	if menu.currentMouseOverTable and (
		(menu.currentMouseOverTable == menu.contexttable)
	) then
		menu.picking = true
		menu.currentMouseOverTable = nil
	end
	-- END

	menu.contextFrame = nil
	menu.contextMode = nil
end

-- rendertarget mouse input helper
function menu.onRenderTargetMouseDown()
	menu.leftdown = { time = GetCurRealTime(), position = table.pack(GetLocalMousePosition()) }
	menu.allowpanning = true
end

function menu.onRenderTargetMouseUp()
	local refreshplan = false
	local display = false

	menu.allowpanning = false
	SetMouseCursorOverride("default")
	menu.keepcursor = false
	if C.StopPanMap(menu.holomap) then
		menu.topRows.modules = GetTopRow(menu.moduletable)
		menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
		menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
		menu.topRows.plan = GetTopRow(menu.plantable)
		menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
		refreshplan = true
		display = true
	end

	local offset = table.pack(GetLocalMousePosition())
	-- Check if the mouse button was down less than 0.2 seconds and the mouse was not moved more than a distance of 2px
	if (menu.leftdown and menu.leftdown.time + 0.2 > GetCurRealTime()) and (not Helper.comparePositions(menu.leftdown.position, offset, 2)) then
		menu.closeContextMenu()
		Helper.closeDropDownOptions(menu.titlebartable, 1, 2)

		if not menu.loadoutMode then
			C.SelectPickedBuildMapEntry(menu.holomap)
			C.AddFloatingSequenceToConstructionPlan(menu.holomap)
			menu.topRows.modules = GetTopRow(menu.moduletable)
			menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
			menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
			
			local newplanrow
			local pickedentry = ffi.new("UIConstructionPlanEntry")
			if C.GetPickedBuildMapEntry(menu.holomap, menu.container, pickedentry) then
				if not pickedentry.isfixed then
					SetMouseCursorOverride("crossarrows")
				end
				for row, rowdata in pairs(menu.rowDataMap[menu.plantable]) do
					if (type(rowdata) == "table") and rowdata.ismodule and (not rowdata.removed) then
						if rowdata.idx == pickedentry.idx then
							menu.selectedModule = rowdata.module
							newplanrow = row
							break
						end
					end
				end
			else
				if Helper.currentTableRow[menu.plantable] <= #menu.constructionplan + 2 then
					menu.selectedModule = nil
					newplanrow = #menu.constructionplan + 3
				end
			end
			menu.topRows.plan = GetTopRow(menu.plantable)
			menu.selectedRows.plan = newplanrow or Helper.currentTableRow[menu.plantable]
			
			refreshplan = true
			display = true
		else
			local pickedslot = ffi.new("UILoadoutSlot")
			if C.GetPickedMapMacroSlot(menu.holomap, menu.container, menu.loadoutModule.component, menu.loadoutModule.macro, true, pickedslot) then
				local groupinfo = C.GetUpgradeSlotGroup(menu.loadoutModule.component, menu.loadoutModule.macro, pickedslot.upgradetype, pickedslot.slot)
				menu.upgradetypeMode = "group"
				menu.currentSlot = menu.findGroupIndex(ffi.string(groupinfo.path), ffi.string(groupinfo.group))
				if menu.upgradetypeMode == "group" then
					local group = menu.groups[menu.currentSlot]
					C.SetSelectedMapGroup(menu.holomap, menu.loadoutModule.component, menu.loadoutModule.macro, group.path, group.group)
				end
				display = true
			end
		end
	end
	menu.leftdown = nil

	if refreshplan then
		menu.refreshPlan()
	end
	if display then
		menu.displayMenu()
	end
end

function menu.onRenderTargetRightMouseDown()
	local valid = false
	local pickedentry = ffi.new("UIConstructionPlanEntry")
	local valid = C.GetPickedBuildMapEntry(menu.holomap, menu.container, pickedentry)
	local item = menu.findConstructionPlanEntry(pickedentry.idx)
	if not item then
		item = {}
		valid = false
	end
	menu.rightdown = { time = GetCurRealTime(), position = table.pack(GetLocalMousePosition()), item = item, itemvalid = valid }
	C.StartRotateMap(menu.holomap)
end

function menu.onRenderTargetRightMouseUp()
	if C.StopRotateMap(menu.holomap) then
		menu.topRows.modules = GetTopRow(menu.moduletable)
		menu.selectedRows.modules = Helper.currentTableRow[menu.moduletable]
		menu.selectedCols.modules = Helper.currentTableCol[menu.moduletable]
		menu.topRows.plan = GetTopRow(menu.plantable)
		menu.selectedRows.plan = Helper.currentTableRow[menu.plantable]
		menu.refreshPlan()
		menu.displayMenu()
	end

	local offset = table.pack(GetLocalMousePosition())
	-- Check if the mouse button was down less than 0.2 seconds and the mouse was moved more than a distance of 2px
	if (menu.rightdown.time + 0.2 > GetCurRealTime()) and (not Helper.comparePositions(menu.rightdown.position, offset, 2)) then
		menu.closeContextMenu()

		if not menu.loadoutMode then
			if menu.rightdown.itemvalid then
				local x, y = GetLocalMousePosition()
				if x == nil then
					-- gamepad case
					x = posx
					y = -posy
				end
				menu.contextData = { item = menu.rightdown.item }
				menu.displayContextFrame("module", Helper.scaleX(200), x + Helper.viewWidth / 2, Helper.viewHeight / 2 - y)
			end
		else
			local pickedslot = ffi.new("UILoadoutSlot")
			if C.GetPickedMapMacroSlot(menu.holomap, menu.container, menu.loadoutModule.component, menu.loadoutModule.macro, true, pickedslot) then
				local groupinfo = C.GetUpgradeSlotGroup(menu.loadoutModule.component, menu.loadoutModule.macro, pickedslot.upgradetype, pickedslot.slot)
				menu.upgradetypeMode = "group"
				menu.currentSlot = menu.findGroupIndex(ffi.string(groupinfo.path), ffi.string(groupinfo.group))
				if menu.upgradetypeMode == "group" then
					local group = menu.groups[menu.currentSlot]
					C.SetSelectedMapGroup(menu.holomap, menu.loadoutModule.component, menu.loadoutModule.macro, group.path, group.group)
				end
				menu.displayMenu()

				menu.contextMode = 2
				menu.contextData = { offsetX = offset[1] + Helper.viewWidth / 2, offsetY = Helper.viewHeight / 2 - offset[2], upgradetype = ffi.string(pickedslot.upgradetype), slot = tonumber(pickedslot.slot) }
				menu.displayContextMenu()
			end
		end
	end
	menu.rightdown = nil
end

function menu.onRenderTargetScrollDown()
	C.ZoomMap(menu.holomap, 1)
end

function menu.onRenderTargetScrollUp()
	C.ZoomMap(menu.holomap, -1)
end

function menu.onSaveState()
	local state = {}

	if menu.holomap ~= 0 then
		if not menu.loadoutMode then
			C.StoreConstructionMapState(menu.holomap)
		end
		local mapstate = ffi.new("HoloMapState")
		C.GetMapState(menu.holomap, mapstate)
		state.map = { offset = { x = mapstate.offset.x, y = mapstate.offset.y, z = mapstate.offset.z, yaw = mapstate.offset.yaw, pitch = mapstate.offset.pitch, roll = mapstate.offset.roll,}, cameradistance = mapstate.cameradistance }
	end

	for _, key in ipairs(config.stateKeys) do
		if key[1] == "loadoutModuleIdx" then
			if menu.loadoutMode then
				state[key[1]] = tonumber(menu.loadoutModule.idx)
			end
		else
			state[key[1]] = menu[key[1]]
		end
	end
	return state
end

function menu.onRestoreState(state)
	local mapstate
	if state.map then
		local offset = ffi.new("UIPosRot", {
			x = state.map.offset.x, 
			y = state.map.offset.y, 
			z = state.map.offset.z, 
			yaw = state.map.offset.yaw, 
			pitch = state.map.offset.pitch, 
			roll = state.map.offset.roll
		})
		mapstate = ffi.new("HoloMapState", {
			offset = offset, 
			cameradistance = state.map.cameradistance
		})
	end

	local module
	for _, key in ipairs(config.stateKeys) do
		if key[1] == "loadoutModuleIdx" then
			if state[key[1]] then
				local idx = ConvertStringTo64Bit(tostring(state[key[1]]))
				for i, entry in ipairs(menu.constructionplan) do
					if entry.idx == state[key[1]] then
						module = entry
						break
					end
				end
			end
		else
			if key[2] == "UniverseID" then
				menu[key[1]] = ConvertIDTo64Bit(state[key[1]])
			else
				menu[key[1]] = state[key[1]]
			end
		end
	end

	local returnvalue
	if module then
		menu.buttonEditLoadout(module)
		returnvalue = true
	end

	if mapstate then
		C.SetMapState(menu.holomap, mapstate)
	end

	return returnvalue
end

-- table mouse input helper
function menu.onTableMouseOut(uitable, row)
	if menu.currentMouseOverTable and (uitable == menu.currentMouseOverTable) then
		menu.currentMouseOverTable = nil
		if menu.holomap ~= 0 then
			menu.picking = true
		end
	end
end

function menu.onTableMouseOver(uitable, row)
	menu.currentMouseOverTable = uitable
	if menu.holomap ~= 0 then
		menu.picking = false
	end
end

function menu.filterModuleByText(module, text)
	text = utf8.lower(text)

	if string.find(utf8.lower(module), text, 1, true) then
		return true
	end

	return false
end

function menu.filterUpgradeByText(upgrade, text)
	text = utf8.lower(text)

	if string.find(utf8.lower(upgrade), text, 1, true) then
		return true
	end

	return false
end

function menu.isEntryExtended(container, index)
	for i, entry in ipairs(menu.extendedentries) do
		if entry.id == container then
			return entry.plan[index]
		end
	end
	return false
end

function menu.extendEntry(container, index, force, exclusive)
	local found = false
	for i, entry in ipairs(menu.extendedentries) do
		if entry.id == container then
			found = true
			if exclusive then
				entry.plan = {}
			end
			if (not force) and entry.plan[index] then
				entry.plan[index] = nil
			else
				entry.plan[index] = true
			end
			break
		end
	end
	if not found then
		table.insert(menu.extendedentries, {id = container, plan = { [index] = true } })
	end
end

function menu.isResourceEntryExtended(id, default)
	if (default ~= nil) and (menu.extendedresourceentries[id] == nil) then
		menu.extendedresourceentries[id] = default
	end
	return menu.extendedresourceentries[id]
end

function menu.extendResourceEntry(id)
	menu.extendedresourceentries[id] = not menu.extendedresourceentries[id]
end

function menu.getLeftBarEntry(mode)
	for i, entry in ipairs(config.leftBar) do
		if entry.mode == mode then
			return entry
		end
	end

	return {}
end

function menu.getLeftBarLoadoutEntry(mode)
	for i, entry in ipairs(config.leftBarLoadout) do
		if entry.mode == mode then
			return entry
		end
	end

	return {}
end

function menu.findUpgradeMacro(type, macro)
	for i, upgradeware in ipairs(menu.upgradewares[type] or {}) do
		if upgradeware.macro == macro then
			return i
		end
	end
	DebugError("The equipment macro '" .. macro .. "' is not in the player's blueprint list. This should never happen. [Florian]")
end

function menu.findGroupIndex(path, group)
	for i, groupinfo in ipairs(menu.groups) do
		if (groupinfo.path == path) and (groupinfo.group == group) then
			return i
		end
	end
end

function menu.findConstructionPlanEntry(idx)
	for _, entry in ipairs(menu.constructionplan) do
		if entry.idx == idx then
			return entry
		end
	end
end

init()
