
-- section == gMain_map
-- param == { 0, 0, showzone, focuscomponent [, history] [, mode, modeparam] }
 
-- modes: - "orderparam_object",	param: { returnfunction, paramdata, toprow, ordercontrollable } 
--		  - "orderparam_position",	param: { returnfunction, paramdata, toprow, ordercontrollable } 
--		  - "selectbuildlocation",	param: { returnsection, { 0, 0, trader, buildership_or_module, object, macro } }
--		  - "tradecontext",			param: { station, initialtradingship, iswareexchange, shadyOnly }
--		  - "selectCV",				param: { buildstorage }
--		  - "infomode",				param: { mode, ... }
--		  - "boardingcontext",		param: { target, boardingships }
--		  - "hire",					param: { returnsection, npc_or_context, ishiring[, npctemplate] }
--		  - "sellships",			param: { shipyard, ships }

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t BuildTaskID;
	typedef uint64_t MissionID;
	typedef uint64_t NPCSeed;
	typedef uint64_t TradeID;
	typedef uint64_t UniverseID;
	typedef struct {
		const char* macro;
		const char* ware;
		uint32_t amount;
		uint32_t capacity;
	} AmmoData;
	typedef struct {
		const char* id;
		const char* text;
	} BoardingBehaviour;
	typedef struct {
		const char* id;
		const char* text;
	} BoardingPhase;
	typedef struct {
		uint32_t approach;
		uint32_t insertion;
	} BoardingRiskThresholds;
	typedef struct {
		BuildTaskID id;
		UniverseID buildingcontainer;
		UniverseID component;
		const char* macro;
		const char* factionid;
		UniverseID buildercomponent;
		int64_t price;
		bool ismissingresources;
		uint32_t queueposition;
	} BuildTaskInfo;
	typedef struct {
		const char* newroleid;
		NPCSeed seed;
		uint32_t amount;
	} CrewTransferContainer;
	typedef struct {
		const char* id;
		const char* name;
	} ControlPostInfo;
	typedef struct {
		const char* id;
		const char* name;
		const char* description;
	} ResponseInfo;
	typedef struct {
		const char* id;
		const char* name;
		const char* description;
		uint32_t numresponses;
		const char* defaultresponse;
		bool ask;
	} SignalInfo;
	typedef struct {
		const char* name;
		const char* transport;
		uint32_t spaceused;
		uint32_t capacity;
	} StorageInfo;
	typedef struct {
		int x;
		int y;
	} Coord2D;
	typedef struct {
		float x;
		float y;
		float z;
	} Coord3D;
	typedef struct {
		float dps;
		uint32_t quadranttextid;
	} DPSData;
	typedef struct {
		const char* factionID;
		const char* factionName;
		const char* factionIcon;
	} FactionDetails;
	typedef struct {
		const char* missionName;
		const char* missionDescription;
		int difficulty;
		int upkeepalertlevel;
		const char* threadType;
		const char* mainType;
		const char* subType;
		const char* subTypeName;
		const char* faction;
		int64_t reward;
		const char* rewardText;
		size_t numBriefingObjectives;
		int activeBriefingStep;
		const char* opposingFaction;
		const char* license;
		float timeLeft;
		double duration;
		bool abortable;
		bool hasObjective;
		UniverseID associatedComponent;
		UniverseID threadMissionID;
	} MissionDetails;
	typedef struct {
		const char* id;
		const char* name;
	} MissionGroupDetails;
	typedef struct {
		const char* text;
		int step;
	} MissionObjectiveStep;
	typedef struct {
		const char* id;
		const char* name;
		const char* icon;
		const char* description;
		const char* category;
		const char* categoryname;
		bool infinite;
		uint32_t requiredSkill;
	} OrderDefinition;
	typedef struct {
		size_t queueidx;
		const char* state;
		const char* statename;
		const char* orderdef;
		size_t actualparams;
		bool enabled;
		bool isinfinite;
		bool issyncpointreached;
		bool istemporder;
	} Order;
	typedef struct {
		const char* id;
		const char* name;
		const char* desc;
		uint32_t amount;
		uint32_t numtiers;
		bool canhire;
	} PeopleInfo;
	typedef struct {
		const char* name;
		int32_t skilllevel;
		uint32_t amount;
	} RoleTierData;
	typedef struct {
		UniverseID context;
		const char* group;
		UniverseID component;
	} ShieldGroup;
	typedef struct {
		uint32_t textid;
		uint32_t value;
		uint32_t relevance;
	} Skill;
	typedef struct {
		UniverseID softtargetID;
		const char* softtargetConnectionName;
	} SofttargetDetails;
	typedef struct {
		const char* max;
		const char* current;
	} SoftwareSlot;
	typedef struct {
		uint32_t id;
		bool reached;
	} SyncPointInfo;
	typedef struct {
		const char* shape;
		const char* name;
		uint32_t requiredSkill;
		float radius;
		bool rollMembers;
		bool rollFormation;
		size_t maxShipsPerLine;
	} UIFormationInfo;
	typedef struct {
		const char* file;
		const char* icon;
		bool ispersonal;
	} UILogo;
	typedef struct {
		const char* icon;
		Color color;
		uint32_t volume_s;
		uint32_t volume_m;
		uint32_t volume_l;
	} UIMapTradeVolumeParameter;
	typedef struct {
		const char* id;
		const char* name;
	} UIModuleSet;
	typedef struct {
		const float x;
		const float y;
		const float z;
		const float yaw;
		const float pitch;
		const float roll;
	} UIPosRot;
	typedef struct {
		bool primary;
		uint32_t idx;
	} UIWeaponGroup;
	typedef struct {
		const char* path;
		const char* group;
	} UpgradeGroup;
	typedef struct {
		UniverseID currentcomponent;
		const char* currentmacro;
		const char* slotsize;
		uint32_t count;
		uint32_t operational;
		uint32_t total;
	} UpgradeGroupInfo;
	typedef struct {
		const char* id;
		const char* name;
		bool active;
	} WeaponSystemInfo;
	typedef struct {
		uint32_t current;
		uint32_t capacity;
		uint32_t optimal;
		uint32_t available;
		uint32_t maxavailable;
		double timeuntilnextupdate;
	} WorkForceInfo;
	typedef struct {
		const char* wareid;
		int32_t amount;
	} YieldInfo;

	typedef struct {
		UIPosRot offset;
		float cameradistance;
	} HoloMapState;
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
	bool AbortBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid);
	void AbortMission(MissionID missionid);
	bool AddAttackerToBoardingOperation(UniverseID defensibletargetid, UniverseID defensibleboarderid, const char* boarderfactionid, const char* actionid, uint32_t* marinetieramounts, int32_t* marinetierskilllevels, uint32_t nummarinetiers);
	UniverseID AddHoloMap(const char* texturename, float x0, float x1, float y0, float y1, float aspectx, float aspecty);
	void AddPlayerMoney(int64_t money);
	void AddResearch(const char* wareid);
	void AddSimilarMapComponentsToSelection(UniverseID holomapid, UniverseID componentid);
	bool AdjustOrder(UniverseID controllableid, size_t idx, size_t newidx, bool enabled, bool forcestates, bool checkonly);
	bool GetAskToSignalForControllable(const char* signalid, UniverseID controllableid);
	bool GetAskToSignalForFaction(const char* signalid, const char* factionid);
	uint32_t GetAttackersOfBoardingOperation(UniverseID* result, uint32_t resultlen, UniverseID defensibletargetid, const char* boarderfactionid);
	bool CanContainerMineTransport(UniverseID containerid, const char* transportname);
	bool CanContainerTransport(UniverseID containerid, const char* transportname);
	bool CanControllableHaveControlEntity(UniverseID controllableid, const char* postid);
	bool CanPlayerCommTarget(UniverseID componentid);
	void ChangeMapBuildPlot(UniverseID holomapid, float x, float y, float z);
	void CheatDockingTraffic(void);
	void ClearSelectedMapComponents(UniverseID holomapid);
	void ClearMapBuildPlot(UniverseID holomapid);
	void ClearMapTradeFilterByMinTotalVolume(UniverseID holomapid);
	void ClearMapTradeFilterByWare(UniverseID holomapid);
	bool CreateBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid, uint32_t approachthreshold, uint32_t insertionthreshold);
	UniverseID CreateNPCFromPerson(NPCSeed person, UniverseID controllableid);
	uint32_t CreateOrder(UniverseID controllableid, const char* orderid, bool default);
	bool DropCargo(UniverseID containerid, const char* wareid, uint32_t amount);
	void EnableAllCheats(void);
	bool EnableOrder(UniverseID controllableid, size_t idx);
	bool EnablePlannedDefaultOrder(UniverseID controllableid, bool checkonly);
	void EndGuidance(void);
	bool ExtendBuildPlot(UniverseID stationid, Coord3D poschange, Coord3D negchange, bool allowreduction);
	bool FilterComponentByText(UniverseID componentid, uint32_t numtexts, const char** textarray, bool includecontainedobjects);
	UniverseID GetActiveMissionComponentID(void);
	uint64_t GetActiveMissionID();
	uint32_t GetAllBoardingBehaviours(BoardingBehaviour* result, uint32_t resultlen);
	uint32_t GetAllBoardingPhases(BoardingPhase* result, uint32_t resultlen);
	uint32_t GetAllControlPosts(ControlPostInfo* result, uint32_t resultlen);
	uint32_t GetAllCountermeasures(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllInventoryBombs(AmmoData* result, uint32_t resultlen, UniverseID entityid);
	uint32_t GetAllLaserTowers(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllMines(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllMissiles(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllNavBeacons(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllResourceProbes(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllSatellites(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllModuleSets(UIModuleSet* result, uint32_t resultlen);
	uint32_t GetAllowedWeaponSystems(WeaponSystemInfo* result, uint32_t resultlen, UniverseID defensibleid, size_t orderidx, bool usedefault);
	uint32_t GetAllResponsesToSignal(ResponseInfo* result, uint32_t resultlen, const char* signalid);
	uint32_t GetAllSignals(SignalInfo* result, uint32_t resultlen);
	const char* GetBoardingActionOfAttacker(UniverseID defensibletargetid, UniverseID defensibleboarderid, const char* boarderfactionid);
	uint32_t GetBoardingCasualtiesOfTier(int32_t marinetierskilllevel, UniverseID defensibletargetid, const char* boarderfactionid);
	bool GetBoardingMarineTierAmountsFromAttacker(uint32_t* resultmarinetieramounts, int32_t* inputmarinetierskilllevels, uint32_t inputnummarinetiers, UniverseID defensibletargetid, UniverseID defensibleboarderid, const char* boarderfactionid);
	BoardingRiskThresholds GetBoardingRiskThresholds(UniverseID defensibletargetid, const char* boarderfactionid);
	uint32_t GetBoardingStrengthOfControllableTierAmounts(UniverseID controllableid, uint32_t* marinetieramounts, int32_t* marinetierskilllevels, uint32_t nummarinetiers);
	int64_t GetBuilderHiringFee(void);
	bool GetBuildMapStationLocation(UniverseID holomapid, UIPosRot* location);
	double GetBuildProcessorEstimatedTimeLeft(UniverseID buildprocessorid);
	Coord3D GetBuildPlotCenterOffset(UniverseID stationid);
	int64_t GetBuildPlotPrice(UniverseID sectorid, UIPosRot location, float x, float y, float z, const char* factionid);
	Coord3D GetBuildPlotSize(UniverseID stationid);
	double GetBuildTaskDuration(UniverseID containerid, BuildTaskID id);
	uint32_t GetBuildTasks(BuildTaskInfo* result, uint32_t resultlen, UniverseID containerid, bool isinprogress, bool includeupgrade);
	uint32_t GetCargoTransportTypes(StorageInfo* result, uint32_t resultlen, UniverseID containerid, bool merge, bool aftertradeorders);
	Coord2D GetCenteredMousePos(void);
	UniverseID GetCommonContext(UniverseID componentid, UniverseID othercomponentid, bool includeself, bool includeother, UniverseID limitid, bool includelimit);
	const char* GetComponentClass(UniverseID componentid);
	const char* GetComponentName(UniverseID componentid);
	int GetConfigSetting(const char*const setting);
	UniverseID GetContextByClass(UniverseID componentid, const char* classname, bool includeself);
	const char* GetCurrentAmmoOfWeapon(UniverseID weaponid);
	const char* GetCurrentBoardingPhase(UniverseID defensibletargetid, const char* boarderfactionid);
	double GetCurrentGameTime(void);
	uint32_t GetCurrentMissionOffers(uint64_t* result, uint32_t resultlen, bool showninbbs);
	UILogo GetCurrentPlayerLogo(void);
	bool GetDefaultOrder(Order* result, UniverseID controllableid);
	const char* GetDefaultResponseToSignalForControllable(const char* signalid, UniverseID controllableid);
	const char* GetDefaultResponseToSignalForFaction(const char* signalid, const char* factionid);
	uint32_t GetDefensibleDPS(DPSData* result, UniverseID defensibleid, bool primary, bool secondary, bool lasers, bool missiles, bool turrets, bool includeheat, bool includeinactive);
	uint32_t GetDefensibleDeployableCapacity(UniverseID defensibleid);
	uint32_t GetDockedShips(UniverseID* result, uint32_t resultlen, UniverseID dockingbayorcontainerid, const char* factionid);
	int32_t GetEntityCombinedSkill(UniverseID entityid, const char* role, const char* postid);
	FactionDetails GetFactionDetails(const char* factionid);
	uint32_t GetFormationShapes(UIFormationInfo* result, uint32_t resultlen);
	uint32_t GetFreeCountermeasureStorageAfterTradeOrders(UniverseID defensibleid);
	uint32_t GetFreeDeployableStorageAfterTradeOrders(UniverseID defensibleid);
	uint32_t GetFreeMissileStorageAfterTradeOrders(UniverseID defensibleid);
	uint32_t GetFreePeopleCapacity(UniverseID controllableid);
	uint32_t GetIllegalToFactions(const char** result, uint32_t resultlen, const char* wareid);
	UniverseID GetInstantiatedPerson(NPCSeed person, UniverseID controllableid);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	uint32_t GetMapComponentMissions(MissionID* result, uint32_t resultlen, UniverseID holomapid, UniverseID componentid);
	UniverseID GetMapPositionOnEcliptic(UniverseID holomapid, UIPosRot* position);
	uint32_t GetMapRenderedComponents(UniverseID* result, uint32_t resultlen, UniverseID holomapid);
	uint32_t GetMapSelectedComponents(UniverseID* result, uint32_t resultlen, UniverseID holomapid);
	void GetMapState(UniverseID holomapid, HoloMapState* state);
	UIMapTradeVolumeParameter GetMapTradeVolumeParameter(void);
	uint32_t GetMineablesAtSectorPos(YieldInfo* result, uint32_t resultlen, UniverseID sectorid, Coord3D position);
	Coord3D GetMinimumBuildPlotCenterOffset(UniverseID stationid);
	Coord3D GetMinimumBuildPlotSize(UniverseID stationid);
	MissionGroupDetails GetMissionGroupDetails(MissionID missionid);
	uint32_t GetMissionThreadSubMissions(MissionID* result, uint32_t resultlen, MissionID missionid);
	MissionDetails GetMissionIDDetails(uint64_t missionid);
	MissionObjectiveStep GetMissionObjectiveStep(uint64_t missionid, size_t objectiveIndex);
	uint32_t GetNumAllBoardingBehaviours(void);
	uint32_t GetNumAllBoardingPhases(void);
	uint32_t GetNumAllControlPosts(void);
	uint32_t GetNumAllCountermeasures(UniverseID defensibleid);
	uint32_t GetNumAllInventoryBombs(UniverseID entityid);
	uint32_t GetNumAllLaserTowers(UniverseID defensibleid);
	uint32_t GetNumAllMines(UniverseID defensibleid);
	uint32_t GetNumAllMissiles(UniverseID defensibleid);
	uint32_t GetNumAllNavBeacons(UniverseID defensibleid);
	uint32_t GetNumAllResourceProbes(UniverseID defensibleid);
	uint32_t GetNumAllSatellites(UniverseID defensibleid);
	uint32_t GetNumAllModuleSets();
	uint32_t GetNumAllowedWeaponSystems(void);
	uint32_t GetNumAllResponsesToSignal(const char* signalid);
	uint32_t GetNumAllRoles(void);
	uint32_t GetNumAllSignals(void);
	uint32_t GetNumAttackersOfBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid);
	uint32_t GetNumBuildTasks(UniverseID containerid, bool isinprogress, bool includeupgrade);
	uint32_t GetNumCargoTransportTypes(UniverseID containerid, bool merge);
	uint32_t GetNumCurrentMissionOffers(bool showninbbs);
	uint32_t GetNumDockedShips(UniverseID dockingbayorcontainerid, const char* factionid);
	uint32_t GetNumFormationShapes(void);
	uint32_t GetNumIllegalToFactions(const char* wareid);
	uint32_t GetNumMapComponentMissions(UniverseID holomapid, UniverseID componentid);
	uint32_t GetNumMapRenderedComponents(UniverseID holomapid);
	uint32_t GetNumMapSelectedComponents(UniverseID holomapid);
	uint32_t GetNumMineablesAtSectorPos(UniverseID sectorid, Coord3D position);
	uint32_t GetNumMissionThreadSubMissions(MissionID missionid);
	uint32_t GetNumObjectsWithSyncPoint(uint32_t syncid, bool onlyreached);
	uint32_t GetNumOrderDefinitions(void);
	uint32_t GetNumOrders(UniverseID controllableid);
	uint32_t GetNumPersonSuitableControlPosts(UniverseID controllableid, UniverseID personcontrollableid, NPCSeed person, bool free);
	size_t GetNumPlannedStationModules(UniverseID defensibleid, bool includeall);
	uint32_t GetNumPlayerShipBuildTasks(bool isinprogress, bool includeupgrade);
	uint32_t GetNumSkills(void);
	uint32_t GetNumShieldGroups(UniverseID defensibleid);
	uint32_t GetNumSoftwareSlots(UniverseID controllableid, const char* macroname);
	uint32_t GetNumStationModules(UniverseID stationid, bool includeconstructions, bool includewrecks);
	uint32_t GetNumSuitableControlPosts(UniverseID controllableid, UniverseID entityid, bool free);
	uint32_t GetNumTiersOfRole(const char* role);
	size_t GetNumTradeComputerOrders(UniverseID controllableid);
	uint32_t GetNumUpgradeGroups(UniverseID destructibleid, const char* macroname);
	size_t GetNumUpgradeSlots(UniverseID destructibleid, const char* macroname, const char* upgradetypename);
	size_t GetNumVirtualUpgradeSlots(UniverseID objectid, const char* macroname, const char* upgradetypename);
	uint32_t GetNumWares(const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	uint32_t GetNumWeaponGroupsByWeapon(UniverseID defensibleid, UniverseID weaponid);
	const char* GetObjectIDCode(UniverseID objectid);
	UIPosRot GetObjectPositionInSector(UniverseID objectid);
	bool GetOrderDefinition(OrderDefinition* result, const char* orderdef);
	uint32_t GetOrderDefinitions(OrderDefinition* result, uint32_t resultlen);
	uint32_t GetOrders(Order* result, uint32_t resultlen, UniverseID controllableid);
	FactionDetails GetOwnerDetails(UniverseID componentid);
	Coord3D GetPaidBuildPlotCenterOffset(UniverseID stationid);
	Coord3D GetPaidBuildPlotSize(UniverseID stationid);
	UniverseID GetParentComponent(UniverseID componentid);
	uint32_t GetPeople(PeopleInfo* result, uint32_t resultlen, UniverseID controllableid);
	uint32_t GetPeopleCapacity(UniverseID controllableid, const char* macroname, bool includecrew);
	int32_t GetPersonCombinedSkill(UniverseID controllableid, NPCSeed person, const char* role, const char* postid);
	const char* GetPersonName(NPCSeed person, UniverseID controllableid);
	const char* GetPersonRole(NPCSeed person, UniverseID controllableid);
	uint32_t GetPersonSkills(Skill* result, NPCSeed person, UniverseID controllableid);
	uint32_t GetPersonSuitableControlPosts(ControlPostInfo* result, uint32_t resultlen, UniverseID controllableid, UniverseID personcontrollableid, NPCSeed person, bool free);
	int32_t GetPersonTier(NPCSeed npc, const char* role, UniverseID controllableid);
	UniverseID GetPickedMapComponent(UniverseID holomapid);
	MissionID GetPickedMapMission(UniverseID holomapid);
	UniverseID GetPickedMapMissionOffer(UniverseID holomapid);
	UniverseID GetPickedMapOrder(UniverseID holomapid, Order* result, bool* intermediate);
	TradeID GetPickedMapTradeOffer(UniverseID holomapid);
	bool GetPlannedDefaultOrder(Order* result, UniverseID controllableid);
	size_t GetPlannedStationModules(UIConstructionPlanEntry* result, uint32_t resultlen, UniverseID defensibleid, bool includeall);
	UniverseID GetPlayerComputerID(void);
	UniverseID GetPlayerContainerID(void);
	UniverseID GetPlayerControlledShipID(void);
	UniverseID GetPlayerID(void);
	UniverseID GetPlayerObjectID(void);
	UniverseID GetPlayerOccupiedShipID(void);
	uint32_t GetPlayerShipBuildTasks(BuildTaskInfo* result, uint32_t resultlen, bool isinprogress, bool includeupgrade);
	const char* GetRealComponentClass(UniverseID componentid);
	uint32_t GetRoleTierNPCs(NPCSeed* result, uint32_t resultlen, UniverseID controllableid, const char* role, int32_t skilllevel);
	uint32_t GetRoleTiers(RoleTierData* result, uint32_t resultlen, UniverseID controllableid, const char* role);
	UniverseID GetSectorControlStation(UniverseID sectorid);
	uint32_t GetShieldGroups(ShieldGroup* result, uint32_t resultlen, UniverseID defensibleid);
	int32_t GetShipCombinedSkill(UniverseID shipid);
	SofttargetDetails GetSofttarget(void);
	uint32_t GetSoftwareSlots(SoftwareSlot* result, uint32_t resultlen, UniverseID controllableid, const char* macroname);
	uint32_t GetStationModules(UniverseID* result, uint32_t resultlen, UniverseID stationid, bool includeconstructions, bool includewrecks);
	uint32_t GetSuitableControlPosts(ControlPostInfo* result, uint32_t resultlen, UniverseID controllableid, UniverseID entityid, bool free);
	bool GetSyncPointInfo(UniverseID controllableid, size_t orderidx, SyncPointInfo* result);
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	uint32_t GetTiersOfRole(RoleTierData* result, uint32_t resultlen, const char* role);
	UniverseID GetTopLevelContainer(UniverseID componentid);
	const char* GetTurretGroupMode(UniverseID defensibleid, const char* path, const char* group);
	UpgradeGroupInfo GetUpgradeGroupInfo(UniverseID destructibleid, const char* macroname, const char* path, const char* group, const char* upgradetypename);
	uint32_t GetUpgradeGroups(UpgradeGroup* result, uint32_t resultlen, UniverseID destructibleid, const char* macroname);
	UniverseID GetUpgradeSlotCurrentComponent(UniverseID destructibleid, const char* upgradetypename, size_t slot);
	UpgradeGroup GetUpgradeSlotGroup(UniverseID destructibleid, const char* macroname, const char* upgradetypename, size_t slot);
	const char* GetVirtualUpgradeSlotCurrentMacro(UniverseID defensibleid, const char* upgradetypename, size_t slot);
	uint32_t GetWares(const char** result, uint32_t resultlen, const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	uint32_t GetWeaponGroupsByWeapon(UIWeaponGroup* result, uint32_t resultlen, UniverseID defensibleid, UniverseID weaponid);
	const char* GetWeaponMode(UniverseID weaponid);
	const char* GetWingName(UniverseID controllableid);
	WorkForceInfo GetWorkForceInfo(UniverseID containerid, const char* raceid);
	UniverseID GetZoneAt(UniverseID sectorid, UIPosRot* uioffset);
	bool HasControllableOwnResponse(UniverseID controllableid, const char* signalid);
	bool IsAmmoMacroCompatible(const char* weaponmacroname, const char* ammomacroname);
	bool IsBuilderBusy(UniverseID shipid);
	bool IsComponentClass(UniverseID componentid, const char* classname);
	bool IsComponentOperational(UniverseID componentid);
	bool IsContestedSector(UniverseID sectorid);
	bool IsControlPressed(void);
	bool IsCurrentOrderCritical(UniverseID controllableid);
	bool IsDefensibleBeingBoardedBy(UniverseID defensibleid, const char* factionid);
	bool IsHQ(UniverseID stationid);
	bool IsFactionHQ(UniverseID stationid);
	bool IsIconValid(const char* iconid);
	bool IsInfoUnlockedForPlayer(UniverseID componentid, const char* infostring);
	bool IsMasterVersion(void);
	bool IsObjectKnown(const UniverseID componentid);
	bool IsOrderSelectableFor(const char* orderdefid, UniverseID controllableid);
	bool IsPerson(NPCSeed person, UniverseID controllableid);
	bool IsPlayerCameraTargetViewPossible(UniverseID targetid, bool force);
	bool IsRealComponentClass(UniverseID componentid, const char* classname);
	bool IsShiftPressed(void);
	bool IsUnit(UniverseID controllableid);
	void LaunchLaserTower(UniverseID defensibleid, const char* lasertowermacroname);
	void LaunchMine(UniverseID defensibleid, const char* minemacroname);
	void LaunchNavBeacon(UniverseID defensibleid, const char* navbeaconmacroname);
	void LaunchResourceProbe(UniverseID defensibleid, const char* resourceprobemacroname);
	void LaunchSatellite(UniverseID defensibleid, const char* satellitemacroname);
	void PayBuildPlotSize(UniverseID stationid, Coord3D plotsize, Coord3D plotcenter);
	void ReassignPeople(UniverseID controllableid, CrewTransferContainer* reassignedcrew, uint32_t amount);
	void ReleaseConstructionMapState(void);
	void ReleaseOrderSyncPoint(uint32_t syncid);
	bool RemoveAllOrders(UniverseID controllableid);
	bool RemoveAttackerFromBoardingOperation(UniverseID defensibleboarderid);
	bool RemoveBuildPlot(UniverseID stationid);
	void RemoveCommander(UniverseID controllableid);
	void RemoveHoloMap(void);
	bool RemoveOrder(UniverseID controllableid, size_t idx, bool playercancelled, bool checkonly);
	void RemoveOrderSyncPointID(UniverseID controllableid, size_t orderidx);
	void RemovePlannedDefaultOrder(UniverseID controllableid);
	UniverseID ReserveBuildPlot(UniverseID sectorid, const char* factionid, const char* set, UIPosRot location, float x, float y, float z);
	bool ResetResponseToSignalForControllable(const char* signalid, UniverseID controllableid);
	void RevealEncyclopedia(void);
	void RevealMap(void);
	void RevealStations(void);
	bool SetActiveMission(MissionID missionid);
	void SelectSimilarMapComponents(UniverseID holomapid, UniverseID componentid);
	void SellPlayerShip(UniverseID shipid, UniverseID shipyardid);
	void SetAllowedWeaponSystems(UniverseID defensibleid, size_t orderidx, bool usedefault, WeaponSystemInfo* uiweaponsysteminfo, uint32_t numuiweaponsysteminfo);
	void SetAllTurretModes(UniverseID defensibleid, const char* mode);
	bool SetAmmoOfWeapon(UniverseID weaponid, const char* newammomacro);
	void SetAssignment(UniverseID controllableid, const char* assignment);
	bool SetCommander(UniverseID controllableid, UniverseID commanderid, const char* assignment);
	bool SetDefaultResponseToSignalForControllable(const char* newresponse, bool ask, const char* signalid, UniverseID controllableid);
	bool SetDefaultResponseToSignalForFaction(const char* newresponse, bool ask, const char* signalid, const char* factionid);
	void SetFocusMapComponent(UniverseID holomapid, UniverseID componentid, bool resetplayerpan);
	UIFormationInfo SetFormationShape(UniverseID objectid, const char* formationshape);
	bool SetEntityToPost(UniverseID controllableid, UniverseID entityid, const char* postid);
	void SetGuidance(UniverseID componentid, UIPosRot offset);
	void SetMapFilterString(UniverseID holomapid, uint32_t numtexts, const char** textarray);
	void SetMapPanOffset(UniverseID holomapid, UniverseID offsetcomponentid);
	void SetMapPicking(UniverseID holomapid, bool enable);
	void SetMapRelativeMousePosition(UniverseID holomapid, bool valid, float x, float y);
	void SetMapRenderAllOrderQueues(UniverseID holomapid, bool value);
	void SetMapRenderCargoContents(UniverseID holomapid, bool value);
	void SetMapRenderCivilianShips(UniverseID holomapid, bool value);
	void SetMapRenderCrewInfo(UniverseID holomapid, bool value);
	void SetMapRenderDockedShipInfos(UniverseID holomapid, bool value);
	void SetMapRenderEclipticLines(UniverseID holomapid, bool value);
	void SetMapRenderMissionGuidance(UniverseID holomapid, MissionID missionid);
	void SetMapRenderMissionOffers(UniverseID holomapid, bool value);
	void SetMapRenderResourceInfo(UniverseID holomapid, bool value);
	void SetMapRenderTradeOffers(UniverseID holomapid, bool value);
	void SetMapRenderWorkForceInfo(UniverseID holomapid, bool value);
	void SetMapState(UniverseID holomapid, HoloMapState state);
	void SetMapStationInfoBoxMargin(UniverseID holomapid, const char* margin, uint32_t width);
	void SetMapTargetDistance(UniverseID holomapid, float distance);
	void SetMapTopTradesCount(UniverseID holomapid, uint32_t count);
	void SetMapTradeFilterByMaxPrice(UniverseID holomapid, int64_t price);
	void SetMapTradeFilterByMinTotalVolume(UniverseID holomapid, uint32_t minvolume);
	void SetMapTradeFilterByWare(UniverseID holomapid, const char** wareids, uint32_t numwareids);
	void SetMapTradeFilterByWareTransport(UniverseID holomapid, const char** transporttypes, uint32_t numtransporttypes);
	void SetMapAlertFilter(UniverseID holomapid, uint32_t alertlevel);
	bool SetOrderSyncPointID(UniverseID controllableid, size_t orderidx, uint32_t syncid, bool checkonly);
	void SetPlayerCameraCockpitView(bool force);
	void SetPlayerCameraTargetView(UniverseID targetid, bool force);
	void SetSelectedMapComponent(UniverseID holomapid, UniverseID componentid);
	void SetSelectedMapComponents(UniverseID holomapid, UniverseID* componentids, uint32_t numcomponentids);
	bool SetSofttarget(UniverseID componentid, const char*const connectionname);
	void SetTurretGroupMode(UniverseID defensibleid, const char* path, const char* group, const char* mode);
	void SetWeaponGroup(UniverseID defensibleid, UniverseID weaponid, bool primary, uint32_t groupidx, bool value);
	void SetWeaponMode(UniverseID weaponid, const char* mode);
	void ShowBuildPlotPlacementMap(UniverseID holomapid, UniverseID sectorid);
	void ShowUniverseMap(UniverseID holomapid, bool setoffset, bool showzone, bool forcebuildershipicons);
	void SignalObjectWithNPCSeed(UniverseID objecttosignalid, const char* param, NPCSeed person, UniverseID controllableid);
	void SpawnObjectAtPos(const char* macroname, UniverseID sectorid, UIPosRot offset);
	bool StartBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid);
	void StartPanMap(UniverseID holomapid);
	void StartRotateMap(UniverseID holomapid);
	bool StopPanMap(UniverseID holomapid);
	bool StopRotateMap(UniverseID holomapid);
	void ZoomMap(UniverseID holomapid, float zoomstep);
	void StartMapBoxSelect(UniverseID holomapid, bool selectenemies);
	void StopMapBoxSelect(UniverseID holomapid);
	bool UpdateAttackerOfBoardingOperation(UniverseID defensibletargetid, UniverseID defensibleboarderid, const char* boarderfactionid, const char* actionid, uint32_t* marinetieramounts, int32_t* marinetierskilllevels, uint32_t nummarinetiers);
	bool UpdateBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid, uint32_t approachthreshold, uint32_t insertionthreshold);
	void UpdateMapBuildPlot(UniverseID holomapid);
]]

local utf8 = require("utf8")

local menu = {
	name = "MapMenu",
	white = { r = 255, g = 255, b = 255, a = 100 },
	grey = { r = 128, g = 128, b = 128, a = 100 },
	darkgrey = { r = 64, g = 64, b = 64, a = 100 },
	red = { r = 255, g = 0, b = 0, a = 100 },
	green = { r = 0, g = 255, b = 0, a = 100 },
	infoTableMode = "objectlist",
	displayedFilterLayer = "layer_trade",
	mouseCursorOverrides = { [1] = "default" },
	currentMouseCursor = "default",
	picking = true,
	missionOfferMode = "guild",
	missionMode = "guild",
	expandedMissionGroups = {},
	infoMode = "objectinfo",
	highlightLeftBar = {},
}

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
					info = ReadText(1001, 3288),
					param = "orderqueue",
				},
				[2] = {
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
	mapfilterversion = 10,

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

__CORE_DETAILMONITOR_MAPFILTER = __CORE_DETAILMONITOR_MAPFILTER or {
	version = config.mapfilterversion,
	["layer_trade"] = true,
	["layer_fight"] = false,
	["layer_think"] = true,
	["layer_build"] = false,
	["layer_diplo"] = false,
	["layer_mining"] = true,
	["layer_other"] = true,
	["trade_storage_container"] = true,
	["trade_storage_solid"] = true,
	["trade_storage_liquid"] = true,
	["trade_price_maxprice"] = 5000,
	["trade_offer_number"] = 3,
	["trade_volume"] = 0,
	["think_alert"] = 3,
	["mining_resource_display"] = true,
	["other_misc_orderqueue"] = true,
	["other_misc_cargo"] = true,
	["other_misc_missions"] = true,
	["other_misc_workforce"] = true,
	["other_misc_crew"] = true,
	["other_misc_ecliptic"] = true,
	["other_misc_dockedships"] = true,
	["other_misc_civilian"] = true,
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
	menu.extendedmoduletypes = {}
	menu.extendedsubordinates = {}
	menu.extendeddockedships = {}
	menu.extendedconstruction = {}
	menu.extendedproperty = { ships = true, stations = true }
	menu.extendedorders = {}
	menu.extendedinfo = { ["info_generalinformation"] = true }
	menu.infocrew = { ["object"] = nil, ["capacity"] = 0, ["total"] = 0, ["current"] = { ["total"] = 0, ["roles"] = {} }, ["reassigned"] = { ["total"] = 0, ["roles"] = {} }, ["unassigned"] = { ["total"] = 0, ["persons"] = {} } }
	menu.holomap = 0

	if __CORE_DETAILMONITOR_MAPFILTER.version < config.mapfilterversion then
		menu.upgradeMapFilterVersion()
	end
end

function menu.cleanup()
	if not menu.minimized then
		UnregisterAddonBindings("ego_detailmonitor")
		menu.arrowsRegistered = nil
		UnregisterEvent("updateHolomap", menu.updateHolomap)
		UnregisterEvent("info_updatePeople", menu.infoUpdatePeople)

		if menu.contextMenuMode == "trade" then
			if C.IsComponentOperational(menu.contextMenuData.currentShip) then
				SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), false)
			end
			if menu.contextMenuData.wareexchange then
				if C.IsComponentOperational(menu.contextMenuData.component) then
					SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), false)
				end
			end
		end
	end

	unregisterForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)

	if menu.mode == "hire" then
		menu.searchTableMode = nil
	elseif menu.mode == "selectCV" then
		for k, v in pairs(menu.layerBackup) do
			__CORE_DETAILMONITOR_MAPFILTER[k] = v
		end
	end
	menu.hireShip = nil
	menu.hireIsPost = nil
	menu.hireRole = nil

	menu.title = nil
	menu.activatemap = nil
	menu.setrow = nil
	menu.settoprow = nil
	menu.setcol = nil
	menu.mode = nil
	menu.modeparam = {}
	menu.createInfoFrameRunning = nil
	menu.createMainFrameRunning = nil
	menu.lastUpdateHolomapTime = nil
	menu.noupdate = nil
	if menu.holomap ~= 0 then
		C.RemoveHoloMap()
		menu.holomap = 0
	end
	menu.autopilottarget = nil
	menu.softtarget = nil
	menu.lastactivetable = nil
	menu.focuscomponent = nil
	menu.currentsector = nil
	menu.orderQueueMode = nil
	menu.selectedcomponents = {}
	menu.closemapwithmenu = nil
	menu.oldmode = nil
	menu.oldInfoTableMode = nil
	menu.shownShipCargo = nil

	menu.boardingData = {}
	menu.boardingtable_shipselection = {}
	menu.queuecontextrefresh = nil
	menu.contexttoprow = nil
	menu.contextselectedrow = nil

	menu.infoSubmenuObject = nil
	menu.infocashtransferdetails = nil
	menu.infodrops = {}
	menu.infocrew.object = nil
	menu.resetcrew = nil
	menu.infomacrostolaunch = {}
	menu.infoeditname = nil

	menu.plots = {}
	menu.plotDoNotUpdate = nil
	menu.table_plotlist = {}
	menu.plotsliders = {}
	menu.plotbuttons = {}
	menu.plots_initialized = nil
	--menu.setplotrow = nil
	--menu.setplottoprow = nil
	-- do not clean this up to reselect the last selected plot if re-accessing the map. for example, from the station configuration menu.
	--menu.plotData = {}

	menu.missionOfferList = {}
	menu.missionList = {}
	menu.missionDoNotUpdate = nil

	menu.rendertargetWidth = nil
	menu.rendertargetHeight = nil
	menu.editboxHeight = nil
	menu.sideBarWidth = nil

	menu.searchtext = {}
	menu.holomapcolor = {}
	menu.ownerDetails = nil

	menu.selectedorder = nil
	menu.buttonline = nil
	menu.orderdefs = {}
	menu.orderdefsbycategory = {}

	menu.turrets = {}
	menu.turretgroups = {}

	menu.mainFrame = nil
	if ((menu.infoTableMode == "info") and ((menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced"))) or (menu.infoTableMode == "plots") then
		menu.infoTableMode = "objectlist"
	end
	menu.infoFrame = nil
	menu.infoTableData = {}
	menu.contextMenuMode = nil
	menu.contextMenuData = {}
	menu.contextFrame = nil

	menu.topRows = {}
	menu.selectedRows = {}
	menu.selectedCols = {}

	menu.highlightedbordercomponent = nil
	menu.highlightedbordermoduletype = nil
	menu.highlightedplannedmodule = nil
	menu.highlightedbordersection = nil
	menu.highlightedborderstationcategory = nil
	menu.highlightedconstruction = nil

	menu.lock = nil
	menu.leftdown = nil
	menu.rightdown = nil

	menu.panningmap = nil
	menu.rotatingmap = nil

	menu.refreshed = nil
	menu.picking = true
	menu.pickstate = nil

	menu.playerInfo = nil
	menu.searchField = nil
	menu.sideBar = nil
	selectedShipsTable = nil
	menu.topLevel = nil
	menu.map = nil

	menu.infoTable = nil
	menu.infoTable2 = nil
	menu.infoTable3 = nil

	menu.contextMenu = nil

	if menu.sound_ambient then
		StopPlayingSound(menu.sound_ambient)
	end
	if menu.sound_panmap then
		StopPlayingSound(menu.sound_panmap)
	end
	if menu.sound_rotatemap and menu.sound_rotatemap.sound then
		StopPlayingSound(menu.sound_rotatemap.sound)
	end
	if menu.sound_zoom then
		StopPlayingSound(menu.sound_zoom)
	end
	menu.sound_ambient = nil
	menu.sound_panmap = nil
	menu.sound_rotatemap = nil
	menu.sound_zoom = nil

	menu.sound_selectedelement = nil

	menu.lastzoom = nil
	menu.zoom_newdir = nil

	menu.clearMouseCursorOverrides()
end

-- Menu member functions

-- button scripts
function menu.updateMapAndInfoFrame()
	if menu.holomap ~= 0 then
		C.ClearSelectedMapComponents(menu.holomap)
	end
	menu.createInfoFrame()
end

function menu.buttonBoardingAddShip()
	-- TODO: implement boarding_selectplayerobject mode and return to boarding menu if object is selected.
	--if not menu.boardingData.contextmenudata then
	--	menu.boardingData.contextmenudata = menu.contextMenuData
	--end
	menu.mode = "boarding_selectplayerobject"
	menu.infoTableMode = "propertyowned"
	menu.boardingData.changed = true
	menu.closeContextMenu()
	menu.refreshMainFrame = true
	menu.refreshInfoFrame()
end

function menu.buttonBoardingRemoveShip(shipid)
	menu.boardingData.shipdata[shipid] = nil
	for i, locship in ipairs(menu.contextMenuData.boarders) do
		if locship == shipid then
			table.remove(menu.contextMenuData.boarders, i)
			break
		end
	end
	for i, locship in ipairs(menu.boardingData.ships) do
		if locship == shipid then
			table.remove(menu.boardingData.ships, i)
			break
		end
	end
	if not C.RemoveAttackerFromBoardingOperation(shipid) then
		DebugError("Failed to remove " .. ffi.string(C.GetComponentName(shipid) .. " " .. tostring(shipid) .. " from boarding operation."))
	end
	menu.boardingData.changed = true
	if #menu.boardingData.ships > 0 then
		menu.refreshContextFrame()
	else
		menu.closeContextMenu()
	end
end

function menu.buttonUpdateBoardingOperation(alreadystarted)
	--print("risk 1 threshold: " .. tostring(menu.boardingData.riskleveldata[menu.boardingData.risk1].threshold) .. ", risk 2 threshold: " .. tostring(menu.boardingData.riskleveldata[menu.boardingData.risk2].threshold))
	if not alreadystarted then
		if not C.CreateBoardingOperation(menu.boardingData.target, "player", menu.boardingData.riskleveldata[menu.boardingData.risk1].threshold, menu.boardingData.riskleveldata[menu.boardingData.risk2].threshold) then
			DebugError("Failed to create boarding operation involving target: " .. ffi.string(C.GetComponentName(menu.boardingData.target)) .. " " .. tostring(menu.boardingData.target))
		end
	else
		C.UpdateBoardingOperation(menu.boardingData.target, "player", menu.boardingData.riskleveldata[menu.boardingData.risk1].threshold, menu.boardingData.riskleveldata[menu.boardingData.risk2].threshold)
	end

	for _, shipid in pairs(menu.boardingData.ships) do
		--print("adding " .. ffi.string(C.GetComponentName(shipid)))
		menu.addShipToBoardingOperation(shipid, menu.boardingData.shipdata[shipid])
	end

	if not alreadystarted then
		if not C.StartBoardingOperation(menu.boardingData.target, "player") then
			DebugError("Failed to start boarding operation involving target: " .. ffi.string(C.GetComponentName(menu.boardingData.target)) .. " " .. tostring(menu.boardingData.target))
		end
	end

	-- reset boarding data to retrieve new information from boarding operation.
	menu.boardingData.ships = {}
	menu.boardingData.shipdata = {}
	menu.boardingData.changed = false
	-- in case of emergency, press below.
	--C.AbortBoardingOperation(menu.boardingData.target, "player")
	menu.refreshContextFrame()
end

function menu.buttonExtendModuleType(station, type)
	menu.extendModuleType(station, type)

	menu.settoprow = GetTopRow(menu.infoTable)
	menu.createInfoFrame()
end

function menu.buttonExtendSubordinate(name)
	if menu.isSubordinateExtended(name) then
		menu.extendedsubordinates[name] = nil
	else
		menu.extendedsubordinates[name] = true
	end
	menu.settoprow = GetTopRow(menu.infoTable)
	menu.createInfoFrame()
end

function menu.buttonExtendDockedShips(name)
	if menu.isDockedShipsExtended(name) then
		menu.extendeddockedships[name] = nil
	else
		menu.extendeddockedships[name] = true
	end
	menu.settoprow = GetTopRow(menu.infoTable)
	menu.createInfoFrame()
end

function menu.buttonExtendConstruction(name)
	if menu.isConstructionExtended(name) then
		menu.extendedconstruction[name] = nil
	else
		menu.extendedconstruction[name] = true
	end
	menu.settoprow = GetTopRow(menu.infoTable)
	menu.createInfoFrame()
end

function menu.buttonExtendProperty(name)
	if menu.isPropertyExtended(name) then
		menu.extendedproperty[name] = nil
	else
		menu.extendedproperty[name] = true
	end
	menu.settoprow = GetTopRow(menu.infoTable)
	menu.createInfoFrame()
end

function menu.buttonExtendOrder(controllable, orderidx)
	menu.extendOrder(controllable, orderidx)
	menu.refreshInfoFrame()
end

function menu.buttonLaunchLasertower(defensible, macro)
	C.LaunchLaserTower(defensible, macro)
	menu.refreshInfoFrame()
end

function menu.buttonLaunchMine(defensible, macro)
	C.LaunchMine(defensible, macro)
	menu.refreshInfoFrame()
end

function menu.buttonLaunchNavBeacon(defensible, macro)
	C.LaunchNavBeacon(defensible, macro)
	menu.refreshInfoFrame()
end

function menu.buttonLaunchResourceProbe(defensible, macro)
	C.LaunchResourceProbe(defensible, macro)
	menu.refreshInfoFrame()
end

function menu.buttonLaunchSatellite(defensible, macro)
	C.LaunchSatellite(defensible, macro)
	menu.refreshInfoFrame()
end

function menu.buttonToggleObjectList(objectlistparam)
	local oldidx, newidx
	for i, entry in ipairs(config.leftBar) do
		if entry.mode then
			if type(entry.mode) == "table" then
				for _, mode in ipairs(entry.mode) do
					if mode == menu.infoTableMode then
						oldidx = i
					end
					if mode == objectlistparam then
						newidx = i
					end
				end
			else
				if entry.mode == menu.infoTableMode then
					oldidx = i
				end
				if entry.mode == objectlistparam then
					newidx = i
				end
			end
		end
		if oldidx and newidx then
			break
		end
	end
	if newidx then
		Helper.updateButtonColor(menu.sideBar, newidx, 1, Helper.defaultArrowRowBackgroundColor)
	end
	if oldidx then
		Helper.updateButtonColor(menu.sideBar, oldidx, 1, Helper.defaultButtonBackgroundColor)
	end

	menu.createInfoFrameRunning = true
	if (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
		menu.missionModeCurrent = nil
		C.SetMapRenderMissionGuidance(menu.holomap, 0)
		if menu.missionModeContext then
			menu.closeContextMenu()
			menu.missionModeContext = nil
		end
	end
	AddUITriggeredEvent(menu.name, objectlistparam, menu.infoTableMode == objectlistparam and "off" or "on")
	if menu.infoTableMode == objectlistparam then
		menu.settoprow = GetTopRow(menu.infoTable)
		PlaySound("ui_negative_back")
		menu.infoTableMode = nil
		if oldidx then
			SelectRow(menu.sideBar, oldidx)
		end
	else
		menu.infoTable = nil
		PlaySound("ui_positive_select")
		if (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
			if menu.missionModeContext then
				menu.closeContextMenu()
				menu.missionModeContext = nil
			end
		elseif menu.infoTableMode == "info" then
			if (menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced") or (menu.infoMode == "factionresponses") or (menu.infoMode == "controllableresponses") then
				menu.infoSubmenuObject = nil
			end
		end
		menu.infoTableMode = objectlistparam
		if newidx then
			SelectRow(menu.sideBar, newidx)
		end
		if menu.infoTableMode == "plots" then
			menu.updatePlotData("plots_new", true)
			menu.storeCurrentPlots()
			--menu.plotDoNotUpdate = true
			menu.mode = "selectbuildlocation"
			C.ShowBuildPlotPlacementMap(menu.holomap, menu.currentsector)
		elseif (menu.mode ~= "selectCV") and (menu.mode ~= "hire") then
			menu.plots_initialized = nil
			menu.plotData = {}
			menu.mode = nil
			menu.removeMouseCursorOverride(3)
			C.ShowUniverseMap(menu.holomap, false, false, false)
		end
		if menu.infoTableMode == "missionoffer" then
			menu.updateMissionOfferList(true)
		end
		Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.SetMapFilterString(menu.holomap, numtexts, texts) end, "text")
		menu.applyFilterSettings()
	end
	menu.createInfoFrame()
end

function menu.deactivateObjectList()
	local oldidx
	for i, entry in ipairs(config.leftBar) do
		if entry.mode then
			if type(entry.mode) == "table" then
				for _, mode in ipairs(entry.mode) do
					if mode == menu.infoTableMode then
						oldidx = i
					end
				end
			else
				if entry.mode == menu.infoTableMode then
					oldidx = i
				end
			end
		end
		if oldidx then
			break
		end
	end

	if oldidx then
		Helper.updateButtonColor(menu.sideBar, oldidx, 1, Helper.defaultButtonBackgroundColor)
	end

	menu.createInfoFrameRunning = true
	if (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
		C.SetMapRenderMissionGuidance(menu.holomap, 0)
		if menu.missionModeContext then
			menu.closeContextMenu()
			menu.missionModeContext = nil
		end
	end
	
	menu.settoprow = GetTopRow(menu.infoTable)
	PlaySound("ui_negative_back")
	menu.infoTableMode = nil
	if oldidx then
		SelectRow(menu.sideBar, oldidx)
	end

	menu.createInfoFrame()
end

function menu.buttonToggleRightBar(searchlistmode)
	AddUITriggeredEvent(menu.name, searchlistmode, menu.searchTableMode == searchlistmode and "off" or menu.displayedFilterLayer)
	if menu.searchTableMode == searchlistmode then
		PlaySound("ui_negative_back")
		menu.searchTableMode = nil
	else
		PlaySound("ui_positive_select")
		menu.searchTableMode = searchlistmode
	end
	menu.refreshMainFrame = true
end

function menu.buttonResetView()
	if menu.holomap and (menu.holomap ~= 0) then
		C.ResetMapPlayerRotation(menu.holomap)
		C.SetFocusMapComponent(menu.holomap, C.GetPlayerObjectID(), true)
		if menu.infoTableMode == "objectlist" then
			menu.refreshInfoFrame()
		end
	end
end

function menu.buttonNewOrder(orderid, default)
	if orderid then
		if orderid == "TradePerform" then
			Helper.closeMenuForNewConversation(menu, "gTrade_offerselect", ConvertStringToLuaID(tostring(C.GetPlayerComputerID())), { 0, 0, true, ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)) })
			menu.cleanup()
		elseif menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
			C.CreateOrder(menu.infoSubmenuObject, orderid, default)
			local buf = ffi.new("Order")
			if C.GetPlannedDefaultOrder(buf, menu.infoSubmenuObject) then
				menu.infoTableData.planneddefaultorder.state = ffi.string(buf.state)
				menu.infoTableData.planneddefaultorder.statename = ffi.string(buf.statename)
				menu.infoTableData.planneddefaultorder.orderdef = ffi.string(buf.orderdef)
				menu.infoTableData.planneddefaultorder.actualparams = tonumber(buf.actualparams)
				menu.infoTableData.planneddefaultorder.enabled = buf.enabled

				local found = false
				for _, orderdef in ipairs(menu.orderdefs) do
					if (orderdef.id == menu.infoTableData.planneddefaultorder.orderdef) then
						menu.infoTableData.planneddefaultorder.orderdefref = orderdef
						found = true
						break
					end
				end
				if not found then
					DebugError("Planned default order of '" .. tostring(menu.infoSubmenuObject) .. "' is of unknown definition '" .. ffi.string(buf.orderdef) .. "' [Florian]")
				end
			end

			menu.closeContextMenu()
			if default then
				menu.orderQueueMode = "plandefaultorder"
			else
				menu.selectedorder = { #menu.infoTableData.orders + 1 }
				menu.extendOrder(menu.infoSubmenuObject, #menu.infoTableData.orders + 1)
			end
			menu.refreshInfoFrame()
		else
			DebugError("menu.buttonNewOrder: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
		end
	else
		menu.contextMenuMode = "neworder"
		menu.contextMenuData = { default = default }
		menu.createContextFrame(280, Helper.viewHeight - menu.infoTableOffsetY, menu.infoTableOffsetX + menu.infoTableWidth + config.contextBorder, menu.infoTableOffsetY)
	end
end

function menu.buttonOrderUp(order)
	local oldidx, newidx, enable
	oldidx = order
	if menu.infoTableData.disabledmarker == order then
		newidx = order
		enable = true
	else
		newidx = order - 1
		enable = menu.infoTableData.orders[order].enabled
	end

	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		if C.AdjustOrder(menu.infoSubmenuObject, oldidx, newidx, enable, false, false) then
			menu.swapExtendedOrder(menu.infoSubmenuObject, oldidx, newidx)
			menu.refreshInfoFrame()
		end
	else
		DebugError("menu.buttonOrderUp: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonOrderDown(order)
	local oldidx, newidx, enable
	oldidx = order
	if menu.infoTableData.disabledmarker == order + 1 then
		newidx = order
		enable = false
	else
		newidx = order + 1
		enable = menu.infoTableData.orders[order].enabled
	end

	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		if C.AdjustOrder(menu.infoSubmenuObject, oldidx, newidx, enable, false, false) then
			menu.swapExtendedOrder(menu.infoSubmenuObject, oldidx, newidx)
			menu.refreshInfoFrame()
		end
	else
		DebugError("menu.buttonOrderDown: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonRemoveOrder(order)
	if menu.removeOrder(order) then
		menu.refreshInfoFrame()
	end
end

function menu.removeOrder(orderidx)
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		if C.RemoveOrder(menu.infoSubmenuObject, orderidx, false, false) then
			menu.removeExtendedOrder(menu.infoSubmenuObject, orderidx)
			if orderidx == #menu.infoTableData.orders then
				menu.selectedorder = (orderidx > 1) and { (orderidx - 1) } or nil
			end
			if menu.selectedorder and (type(menu.selectedorder[1]) == "number") then
				menu.selectedorder = { math.min(menu.selectedorder[1], #menu.infoTableData.orders - 1) }
			end
		
			return true
		end
	else
		DebugError("menu.removeOrder: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end

	return false
end

function menu.buttonStartOrders()
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		for i, order in ipairs(menu.infoTableData.orders) do
			if order.state == "disabled" then
				C.EnableOrder(menu.infoSubmenuObject, i)
			end
			if order.state == "setup" then
				break
			end
		end
		menu.refreshInfoFrame()
	else
		DebugError("menu.buttonStartOrders: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonDeleteAllOrders()
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		for i = #menu.infoTableData.orders, 1, -1 do
			if C.RemoveOrder(menu.infoSubmenuObject, i, false, false) then
				menu.removeExtendedOrder(menu.infoSubmenuObject, i)
			end
		end
		menu.refreshInfoFrame()
	else
		DebugError("menu.buttonDeleteAllOrders: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonDefaultOrderDiscard()
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		C.RemovePlannedDefaultOrder(menu.infoSubmenuObject)
	else
		DebugError("menu.buttonDefaultOrderDiscard: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end

	menu.orderQueueMode = nil
	menu.refreshInfoFrame(0, 0)
end

function menu.buttonDefaultOrderConfirm()
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		C.EnablePlannedDefaultOrder(menu.infoSubmenuObject, false)
	else
		DebugError("menu.buttonDefaultOrderConfirm: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end

	menu.orderQueueMode = nil
	menu.refreshInfoFrame(0, 0)
end

function menu.buttonSetOrderParam(order, param, index, value)
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		local paramdata
		if order == "default" then
			paramdata = menu.infoTableData.defaultorder.params[param]
		elseif order == "planneddefault" then
			paramdata = menu.infoTableData.planneddefaultorder.params[param]
		else
			paramdata = menu.infoTableData.orders[order].params[param]
		end

		local type, oldvalue
		if paramdata.type == "list" then
			type = paramdata.inputparams.type
			if not type then
				DebugError("Order parameter of type 'list' does not specify a input parameter 'type' [Florian]")
			end
			if index then
				oldvalue = paramdata.value[index]
			end
		else
			type = paramdata.type
			oldvalue = paramdata.value
		end

		if type == "bool" then
			SetOrderParam(ConvertStringToLuaID(tostring(menu.infoSubmenuObject)), order, param, index, not (oldvalue ~= 0))
			menu.refreshInfoFrame()
		elseif type == "object" then
			menu.infoTableMode = "objectlist"
			menu.currentOrderQueueMode = menu.infoMode
			menu.mode = "orderparam_object"
			local controllable = ConvertStringToLuaID(tostring(menu.infoSubmenuObject))
			menu.modeparam = { function (value) return menu.setOrderParamFromMode(controllable, order, param, index, value) end, paramdata, GetTopRow(menu.infoTable), controllable }

			local orderdefid
			if order == "default" then
				orderdefid = menu.infoTableData.defaultorder.orderdefref.id
			elseif order == "planneddefault" then
				orderdefid = menu.infoTableData.planneddefaultorder.orderdefref.id
			else
				orderdefid = menu.infoTableData.orders[order].orderdefref.id
			end
			if (orderdefid == "Attack") then
				menu.setMouseCursorOverride("targetred", 3)
			else
				menu.setMouseCursorOverride("target", 3)
			end

			menu.settoprow = 0

			menu.closeContextMenu()
			menu.refreshInfoFrame()
		elseif type == "ware" then
			if value then
				SetOrderParam(ConvertStringToLuaID(tostring(menu.infoSubmenuObject)), order, param, index, value)
				menu.closeContextMenu()
				menu.refreshInfoFrame()
			else
				menu.contextMenuMode = "set_orderparam_ware"
				menu.contextMenuData = { order = order, param = param, index = index }
				menu.createContextFrame(280, Helper.viewHeight - 100, menu.infoTableOffsetX + menu.infoTableWidth + config.contextBorder, 100)
			end
		elseif type == "macro" then
			-- TODO
		elseif type == "position" then
			menu.currentOrderQueueMode = menu.infoMode
			menu.mode = "orderparam_position"
			local controllable = ConvertStringToLuaID(tostring(menu.infoSubmenuObject))
			menu.modeparam = { function (value) return menu.setOrderParamFromMode(controllable, order, param, index, value) end, paramdata, GetTopRow(menu.infoTable), controllable }

			menu.setMouseCursorOverride("target", 3)

			menu.settoprow = 0
			menu.closeContextMenu()
			menu.refreshInfoFrame()
		elseif type == "formationshape" then
			if value then
				SetOrderParam(ConvertStringToLuaID(tostring(menu.infoSubmenuObject)), order, param, index, value)
				menu.closeContextMenu()
				menu.refreshInfoFrame()
			else
				menu.contextMenuMode = "set_orderparam_formationshape"
				menu.contextMenuData = { order = order, param = param, index = index }
				menu.createContextFrame(280, Helper.viewHeight - 200, menu.infoTableOffsetX + menu.infoTableWidth + config.contextBorder, 200)
			end
		else
			DebugError("Unsupported order parameter type '" .. tostring(type) .. "' [Florian]")
		end
	else
		DebugError("menu.buttonSetOrderParam: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.slidercellSetOrderParam(order, param, index, value)
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		local paramdata
		if order == "default" then
			paramdata = menu.infoTableData.defaultorder.params[param]
		elseif order == "planneddefault" then
			paramdata = menu.infoTableData.planneddefaultorder.params[param]
		else
			paramdata = menu.infoTableData.orders[order].params[param]
		end

		local type, oldvalue
		if paramdata.type == "list" then
			type = paramdata.inputparams.type
			if not type then
				DebugError("Order parameter of type 'list' does not specify a input parameter 'type' [Florian]")
			end
			if index then
				oldvalue = paramdata.value[index]
			end
		else
			type = paramdata.type
			oldvalue = paramdata.value
		end

		if type == "number" or type == "length" then
			if value then
				menu.noupdate = true
				SetOrderParam(ConvertStringToLuaID(tostring(menu.infoSubmenuObject)), order, param, index, value)
			end
		elseif type == "time" then
			if value then
				menu.noupdate = true
				SetOrderParam(ConvertStringToLuaID(tostring(menu.infoSubmenuObject)), order, param, index, value * 60)
			end
		elseif type == "money" then
			if value then
				menu.noupdate = true
				SetOrderParam(ConvertStringToLuaID(tostring(menu.infoSubmenuObject)), order, param, index, value * 100)
			end
		end
	else
		DebugError("menu.slidercellSetOrderParam: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonRemoveListParam(order, param, index)
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		RemoveOrderListParam(ConvertStringToLuaID(tostring(menu.infoSubmenuObject)), order, param, index)

		menu.refreshInfoFrame()
	else
		DebugError("menu.buttonRemoveListParam: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonNewPlot()
	--print("x: " .. tostring(menu.plotData.size.x) .. ", y: " .. tostring(menu.plotData.size.y) .. ", z: " .. tostring(menu.plotData.size.z))
	menu.plotData.active = true
	C.ChangeMapBuildPlot(menu.holomap, menu.plotData.size.x * 1000, menu.plotData.size.y * 1000, menu.plotData.size.z * 1000)
end

function menu.buttonRemovePlot(station)
	if not station then
		DebugError("menu.buttonRemovePlot called with no station set. station: " .. tostring(station))
		return
	end

	local newselection = nil
	if menu.plotData.component == station then
		newselection = "plots_new"
	end
	local breaknext = nil
	for i, plot in ipairs(menu.plots) do
		if station == plot.station then
			if C.RemoveBuildPlot(station) then
				plot.removed = true
				breaknext = true
			end
		elseif breaknext then
			if newselection then
				newselection = plot.station
			end
			break
		end
	end

	if newselection then
		menu.updatePlotData(newselection, true)
	end
	menu.refreshInfoFrame()
end

function menu.orderMoveWait(component, sector, offset, clear)
	if not C.IsOrderSelectableFor("MoveWait", component) then
		return
	end

	if clear then
		C.RemoveAllOrders(component)
	end
	local orderidx = C.CreateOrder(component, "MoveWait", false)
	SetOrderParam(ConvertStringToLuaID(tostring(component)), orderidx, 1, nil, { ConvertStringToLuaID(tostring(sector)), {offset.x, offset.y,offset.z} })
	C.EnableOrder(component, orderidx)

	return orderidx
end

function menu.selectCV(component)
	local convertedComponent = ConvertStringTo64Bit(tostring(component))
	if not C.IsBuilderBusy(component) then
		if not GetComponentData(convertedComponent, "isplayerowned") then
			local playermoney = GetPlayerMoney()
			local fee = tonumber(C.GetBuilderHiringFee())
			if playermoney >= fee then
				TransferPlayerMoneyTo(fee, convertedComponent)
			else
				return
			end
		end

		menu.orderDeployToStation(component, ConvertIDTo64Bit(menu.modeparam[1]), false)

		Helper.closeMenu(menu, "back")
		menu.cleanup()
	end
end

function menu.orderDeployToStation(component, station, clear)
	if not C.IsOrderSelectableFor("DeployToStation", component) then
		return
	end

	if clear then
		C.RemoveAllOrders(component)
	end
	local orderidx = C.CreateOrder(component, "DeployToStation", false)
	SetOrderParam(ConvertStringToLuaID(tostring(component)), orderidx, 1, nil, ConvertStringToLuaID(tostring(station)))
	C.EnableOrder(component, orderidx)
end

function menu.orderAttack(component, target, clear)
	if not C.IsOrderSelectableFor("Attack", component) then
		return
	end

	if clear then
		C.RemoveAllOrders(component)
	end
	local orderidx = C.CreateOrder(component, "Attack", false)
	SetOrderParam(ConvertStringToLuaID(tostring(component)), orderidx, 1, nil, ConvertStringToLuaID(tostring(target)))
	C.EnableOrder(component, orderidx)

	return orderidx
end

function menu.orderAttackMultiple(component, maintarget, secondarytargets, clear)
	if not C.IsOrderSelectableFor("Attack", component) then
		return
	end

	if clear then
		C.RemoveAllOrders(component)
	end
	local orderidx = C.CreateOrder(component, "Attack", false)
	SetOrderParam(ConvertStringToLuaID(tostring(component)), orderidx, 1, nil, ConvertStringToLuaID(tostring(maintarget)))
	for _, secondarytarget in ipairs(secondarytargets) do
		SetOrderParam(ConvertStringToLuaID(tostring(component)), orderidx, 2, nil, ConvertStringToLuaID(tostring(secondarytarget)))
	end
	C.EnableOrder(component, orderidx)

	return orderidx
end

function menu.buttonContextTrade(wareexchange)
	menu.contextMenuMode = "trade"
	menu.contextMenuData = { component = menu.contextMenuData.component, currentShip = menu.contextMenuData.currentShip, shadyOnly = menu.contextMenuData.shadyOnly, orders = {}, xoffset = menu.contextMenuData.xoffset, yoffset = menu.contextMenuData.yoffset, wareexchange = wareexchange }

	local numwarerows, numinforows = menu.initTradeContextData()
	menu.updateTradeContextDimensions(numwarerows, numinforows)

	if menu.contextMenuData.xoffset + menu.tradeContext.width > Helper.viewWidth then
		menu.contextMenuData.xoffset = Helper.viewWidth - menu.tradeContext.width - config.contextBorder
	end
	local height = menu.tradeContext.shipheight + menu.tradeContext.buttonheight + 1 * Helper.borderSize
	if menu.contextMenuData.yoffset + height > Helper.viewHeight then
		menu.contextMenuData.yoffset = Helper.viewHeight - height - config.contextBorder
	end

	menu.createContextFrame(menu.tradeContext.width, height, menu.contextMenuData.xoffset, menu.contextMenuData.yoffset)
end

function menu.buttonContextResearch()
	Helper.closeMenuAndOpenNewMenu(menu, "ResearchMenu", {0, 0}, true)
	menu.cleanup()
end

function menu.buttonConfirmTrade()
	-- Station buys first
	for id, amount in pairs(menu.contextMenuData.orders) do
		if amount > 0 then
			AddTradeToShipQueue(ConvertStringToLuaID(tostring(id)), ConvertStringTo64Bit(tostring(menu.contextMenuData.currentShip)), amount, menu.contextMenuData.immediate)
		end
	end
	-- Station sells
	for id, amount in pairs(menu.contextMenuData.orders) do
		if amount < 0 then
			AddTradeToShipQueue(ConvertStringToLuaID(tostring(id)), ConvertStringTo64Bit(tostring(menu.contextMenuData.currentShip)), -amount, menu.contextMenuData.immediate)
		end
	end
	if menu.contextMenuData.immediate then
		SignalObject(ConvertStringTo64Bit(tostring(C.GetPlayerID())), "docked_player_trade_added", ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)))
	end
	menu.closeContextMenu("back")
	if (menu.infoTableMode == "info") and ((menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced")) then
		menu.refreshInfoFrame()
	elseif (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
		menu.refreshIF = getElapsedTime()
	end
end

function menu.buttonCancelTrade()
	menu.closeContextMenu("back")
end

function menu.buttonDockToTrade()
	local ship = menu.contextMenuData.currentShip
	local container = menu.contextMenuData.component
	if not C.IsOrderSelectableFor("Player_DockToTrade", ship) then
		return
	end
	local orderidx = C.CreateOrder(ship, "Player_DockToTrade", false)
	SetOrderParam(ship, orderidx, 1, nil, ConvertStringToLuaID(tostring(container)))
	C.EnableOrder(ship, orderidx)

	menu.closeContextMenu("back")
end

function menu.buttonMissionAbort()
	C.AbortMission(menu.contextMenuData.missionid)
	menu.closeContextMenu()
	menu.refreshIF = getElapsedTime()
end

function menu.buttonMissionBriefing()
	local missionid
	if menu.contextMenuData.threadMissionID ~= 0 then
		missionid = menu.contextMenuData.threadMissionID
	else
		missionid = menu.contextMenuData.missionid
	end
	menu.closeContextMenu()
	Helper.closeMenuAndOpenNewMenu(menu, "MissionBriefingMenu", { 0, 0, ConvertStringToLuaID(tostring(missionid)), false })
	menu.cleanup()
end

function menu.buttonMissionActivate()
	local active = menu.contextMenuData.missionid == C.GetActiveMissionID()
	for _, submissionEntry in ipairs(menu.contextMenuData.subMissions) do
		if submissionEntry.active then
			active = true
		end
	end
	if active then
		C.SetActiveMission(0)
	else
		C.SetActiveMission(menu.contextMenuData.missionid)
	end
	menu.closeContextMenu()
	menu.refreshIF = getElapsedTime()
end

function menu.buttonMissionOfferBriefing()
	local offerid = menu.contextMenuData.missionid
	menu.closeContextMenu()
	Helper.closeMenuAndOpenNewMenu(menu, "MissionBriefingMenu", { 0, 0, offerid, true })
	menu.cleanup()
end

function menu.buttonMissionOfferAccept()
	local offerid = menu.contextMenuData.missionid
	local offeractor = menu.contextMenuData.offeractor
	menu.closeContextMenu()
	SignalObject(offeractor, "accept", ConvertStringToLuaID(tostring(offerid)))

	if menu.missionOfferList then
		if menu.missionOfferMode == "guild" then
			for _, data in ipairs(menu.missionOfferList[menu.missionOfferMode] or {}) do
				local found = false
				for _, entry in ipairs(data.missions) do
					if ConvertStringTo64Bit(entry.ID) == offerid then
						found = true
						entry.accepted = true
						menu.highlightLeftBar["mission"] = true
						menu.refreshMainFrame = true
						break
					end
				end
				if found then
					break
				end
			end
		else
			for i, entry in ipairs(menu.missionOfferList[menu.missionOfferMode] or {}) do
				if ConvertStringTo64Bit(entry.ID) == offerid then
					entry.accepted = true
					menu.highlightLeftBar["mission"] = true
					menu.refreshMainFrame = true
					break
				end
			end
		end
	end
	menu.refreshIF = getElapsedTime()
end

function menu.buttonSellShips()
	TransferMoneyToPlayer(menu.contextMenuData.totalprice, menu.contextMenuData.shipyard)
	for i, data in ipairs(menu.contextMenuData.ships) do
		if #data[2] == 0 then
			C.SellPlayerShip(data[1], menu.contextMenuData.shipyard)
		end
	end
	menu.closeContextMenu()
end

function menu.buttonInfoSubMode(mode, col)
	if mode ~= menu.infoMode then
		menu.infoMode = mode

		AddUITriggeredEvent(menu.name, menu.infoMode)

		menu.selectedCols.orderqueuetabs = col
		menu.refreshInfoFrame(1, col)
	end
end

function menu.buttonMissionSubMode(mode, col)
	if mode ~= menu.missionMode then
		menu.closeContextMenu()
		menu.missionMode = mode
		menu.updateMissions()

		AddUITriggeredEvent(menu.name, menu.missionMode)

		menu.missionModeCurrent = "tabs"
		menu.refreshInfoFrame(nil, col)
	end
end

function menu.buttonMissionOfferSubMode(mode, col)
	if mode ~= menu.missionOfferMode then
		menu.closeContextMenu()
		menu.missionOfferMode = mode
		menu.updateMissionOfferList(true)

		AddUITriggeredEvent(menu.name, menu.missionOfferMode)

		menu.missionModeCurrent = "tabs"
		menu.refreshInfoFrame(nil, col)
	end
end

function menu.buttonExpandMissionGroup(id, row, contextCallback)
	menu.missionModeCurrent = id
	if menu.expandedMissionGroups[id] then
		menu.expandedMissionGroups[id] = nil
	else
		menu.expandedMissionGroups[id] = true
	end
	menu.setrow = row
	menu.closeContextMenu()
	if contextCallback then
		contextCallback()
	end
	menu.refreshInfoFrame()
end

function menu.onMissionOfferRemoved(event, id)
	if id == menu.contextMenuData.missionid then
		menu.contextMenuData.expired = true

		Helper.removeButtonScripts(menu, menu.contextbottomtable, menu.contextMenuData.bottomLines, 1)
		SetCellContent(menu.contextbottomtable, Helper.createButton(Helper.createTextInfo(ReadText(1001, 6402), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight), menu.contextMenuData.bottomLines, 1)
		Helper.removeButtonScripts(menu, menu.contextbottomtable, menu.contextMenuData.bottomLines, 2)
		SetCellContent(menu.contextbottomtable, Helper.createButton(Helper.createTextInfo("-", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight), menu.contextMenuData.bottomLines, 2)
	end
end

function menu.onMissionRemoved(event, id)
	if id == menu.contextMenuData.missionid then
		menu.contextMenuData.expired = true

		Helper.removeButtonScripts(menu, menu.contextbottomtable, menu.contextMenuData.bottomLines - 1, 1)
		SetCellContent(menu.contextbottomtable, Helper.createButton(Helper.createTextInfo(ReadText(1001, 6403), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight), menu.contextMenuData.bottomLines - 1, 1)
		Helper.removeButtonScripts(menu, menu.contextbottomtable, menu.contextMenuData.bottomLines - 1, 2)
		SetCellContent(menu.contextbottomtable, Helper.createButton(Helper.createTextInfo("-", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight), menu.contextMenuData.bottomLines - 1, 2)

		Helper.removeButtonScripts(menu, menu.contextbottomtable, menu.contextMenuData.bottomLines, 1)
		SetCellContent(menu.contextbottomtable, Helper.createButton(Helper.createTextInfo("-", "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, false, 0, 0, 0, Helper.standardButtonHeight), menu.contextMenuData.bottomLines, 1)
	end
end

function menu.buttonSelectSector()
	if menu.checkForOrderParamObject(menu.currentsector) then
		menu.modeparam[1](ConvertStringToLuaID(tostring(menu.currentsector)))
	end
end

function menu.buttonRemoveOrderSyncPoint(orderidx)
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		local order = menu.infoTableData.orders[orderidx]

		C.RemoveOrderSyncPointID(menu.infoSubmenuObject, orderidx)
		menu.refreshInfoFrame()
	else
		DebugError("menu.buttonRemoveOrderSyncPoint: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonSetFilterLayer(mode, row, col)
	__CORE_DETAILMONITOR_MAPFILTER[mode] = not __CORE_DETAILMONITOR_MAPFILTER[mode]
	AddUITriggeredEvent(menu.name, mode .. "_toggle", __CORE_DETAILMONITOR_MAPFILTER[mode] and "true" or "false")
	menu.applyFilterSettings()
	menu.refreshMainFrame = true
end

function menu.buttonFilterSwitch(mode, row, col)
	if menu.displayedFilterLayer ~= mode then
		menu.displayedFilterLayer = mode

		AddUITriggeredEvent(menu.name, menu.displayedFilterLayer)

		menu.refreshMainFrame = true
	end
end

function menu.buttonWeaponConfig(component, orderidx, usedefault)
	menu.contextMenuMode = "weaponconfig"
	menu.contextMenuData = { component = component, orderidx = orderidx, usedefault = usedefault, weaponsystems = {} }

	local n = C.GetNumAllowedWeaponSystems()
	local buf = ffi.new("WeaponSystemInfo[?]", n)
	n = C.GetAllowedWeaponSystems(buf, n, ConvertIDTo64Bit(component), menu.contextMenuData.orderidx or 0, menu.contextMenuData.usedefault)
	for i = 0, n - 1 do
		table.insert(menu.contextMenuData.weaponsystems, { id = ffi.string(buf[i].id), name = ffi.string(buf[i].name), active = buf[i].active })
	end
	if not menu.contextMenuData.usedefault then
		for _, entry in ipairs(menu.contextMenuData.weaponsystems) do
			if entry.id == "default" then
				menu.contextMenuData.default = entry.active
			end
		end
	end

	menu.createContextFrame(280, Helper.viewHeight - 100, menu.infoTableOffsetX + menu.infoTableWidth + config.contextBorder, 100)
end

function menu.buttonClearWeaponConfig()
	for i, entry in ipairs(menu.contextMenuData.weaponsystems) do
		menu.contextMenuData.weaponsystems[i].active = false
	end
	menu.createContextFrame()
end

function menu.buttonCancelWeaponConfig()
	menu.closeContextMenu()
end

function menu.buttonConfirmWeaponConfig()
	local weaponsystems = ffi.new("WeaponSystemInfo[?]", #menu.contextMenuData.weaponsystems)
	for i, entry in ipairs(menu.contextMenuData.weaponsystems) do
		weaponsystems[i - 1].id = Helper.ffiNewString(entry.id)
		weaponsystems[i - 1].active = entry.active
	end
	C.SetAllowedWeaponSystems(menu.contextMenuData.component, menu.contextMenuData.orderidx or 0, menu.contextMenuData.usedefault, weaponsystems, #menu.contextMenuData.weaponsystems)
	menu.closeContextMenu()
end

function menu.buttonHire()
	local playerMoney = GetPlayerMoney()	
	local npcseed = menu.modeparam[4]
	local npc, object
	if npcseed then
		object = ConvertIDTo64Bit(menu.modeparam[2])
	else
		npc = ConvertIDTo64Bit(menu.modeparam[2])
	end
	local ishiring = menu.modeparam[3] ~= 0
	local fee
	if ishiring and npc then
		fee = GetNPCBlackboard(npc, "$HiringFee")
	else
		fee = 0
	end
	if fee then
		fee = RoundTotalTradePrice(fee)
	else
		DebugError("menu.buttonHire(): Could not find hiring fee. [Florian]")
		fee = 0
	end

	if (not ishiring) or (playerMoney >= fee) then
		if ishiring then
			TransferPlayerMoneyTo(fee, GetContextByClass(npc or object, "container", true))
		end
		Helper.closeMenuForSection(menu, menu.modeparam[1], { ConvertStringToLuaID(tostring(menu.hireShip)), menu.hireRole, menu.hireIsPost })
		menu.cleanup()
	else
		menu.refreshMainFrame = true
	end
end

function menu.buttonSelectHandler()
	if menu.mode == "hire" then
		if GetComponentData(menu.contextMenuData.component, "isplayerowned") and C.IsComponentClass(menu.contextMenuData.component, "controllable") then
			if menu.hireShip ~= menu.contextMenuData.component then
				menu.hireShip = menu.contextMenuData.component
				menu.hireRole = nil
				menu.hireIsPost = nil

				menu.refreshMainFrame = true
			end
		end
	elseif menu.mode == "selectCV" then
		menu.selectCV(menu.contextMenuData.component)
	elseif menu.mode == "orderparam_object" then
		if menu.checkForOrderParamObject(menu.contextMenuData.component) then
			menu.modeparam[1](ConvertStringToLuaID(tostring(menu.contextMenuData.component)))
		end
	end
	menu.closeContextMenu()
end

function menu.plotModeUpdateValue(dimension, valchange)
	local axis = "x"
	local bigaxis = "X"
	if dimension == "posY" or dimension == "negY" then
		axis = "y"
		bigaxis = "Y"
	elseif dimension == "posZ" or dimension == "negZ" then
		axis = "z"
		bigaxis = "Z"
	end
	menu.plotData.size[axis] = menu.plotData.dimensions["pos" .. bigaxis] + menu.plotData.dimensions["neg" .. bigaxis]
	menu.plotModeUpdatePrice()
	menu.updatePlotSize(dimension, axis, valchange)
end

function menu.plotModeUpdatePrice()
	if not menu.plotData.price then
		return
	end
	--print("size.x: " .. tostring(menu.plotData.size.x * 1000) .. ", boughtrawsize.x: " .. tostring(menu.plotData.boughtrawsize.x) .. ". size.y: " .. tostring(menu.plotData.size.y * 1000) .. ", boughtrawsize.y: " .. tostring(menu.plotData.boughtrawsize.y) .. ". size.z: " .. tostring(menu.plotData.size.z * 1000) .. ", boughtrawsize.z: " .. tostring(menu.plotData.boughtrawsize.z))
	local numchanged = 3
	local x = menu.plotData.size.x * 1000
	if x == menu.plotData.boughtrawsize.x then
		numchanged = numchanged - 1
	end
	local y = menu.plotData.size.y * 1000
	if y == menu.plotData.boughtrawsize.y then
		numchanged = numchanged - 1
	end
	local z = menu.plotData.size.z * 1000
	if z == menu.plotData.boughtrawsize.z then
		numchanged = numchanged - 1
	end

	local owner = GetComponentData(ConvertStringTo64Bit(tostring(menu.plotData.component)), "owner")
	menu.plotData.price = tonumber(C.GetBuildPlotPrice(menu.plotData.sector, menu.plotData.position, x, y, z, owner)) - tonumber(C.GetBuildPlotPrice(menu.plotData.sector, menu.plotData.position, menu.plotData.boughtrawsize.x, menu.plotData.boughtrawsize.y, menu.plotData.boughtrawsize.z, owner))
	menu.plotData.affordable = GetPlayerMoney() >= menu.plotData.price

	if numchanged > 0 and menu.plotData.fullypaid then
		menu.plotData.fullypaid = false
	end
end

function menu.buttonBuyPlot()
	local station = menu.plotData.component
	local size = { x = menu.plotData.size.x * 1000, y = menu.plotData.size.y * 1000, z = menu.plotData.size.z * 1000 }
	if not menu.plotData.price or GetPlayerMoney() < menu.plotData.price then
		DebugError("menu.buttonBuyPlot() called but there is no price or the player cannot afford the plot. price: " .. tostring(menu.plotData.price) .. ", player cash: " .. tostring(GetPlayerMoney()))
		return
	end
	local offset = C.GetBuildPlotCenterOffset(station)
	for _, plot in ipairs(menu.plots) do
		if plot.station == station then
			plot.boughtrawcenteroffset = offset
			break
		end
	end
	local controlstation = C.GetSectorControlStation(menu.plotData.sector)
	TransferPlayerMoneyTo(menu.plotData.price, ConvertStringTo64Bit(tostring(controlstation)))
	C.PayBuildPlotSize(station, size, offset)
	menu.updatePlotData()
	menu.refreshInfoFrame()
end

function menu.slidercellPlotValue(_, value, dimension, fullsize)
	if not dimension then
		DebugError("menu.slidercellPlotValue(): no dimension passed in.")
		return
	end
	if fullsize then
		menu.plotData.size[dimension] = value
		menu.updatePlotSize()
	else
		local valchange = value - menu.plotData.dimensions[dimension]
		menu.plotData.dimensions[dimension] = value
		menu.plotModeUpdateValue(dimension, valchange)
	end
end

function menu.tradeContextCostAndStorageUpdateHelper(storagetype, ware)
	menu.updateTradeCost()
	if not menu.contextMenuData.wareexchange then
		-- profit
		local profit = menu.contextMenuData.referenceprofit
		local profitcolor = Helper.color.white
		if profit < 0 then
			profitcolor = Helper.color.red
		elseif profit > 0 then
			profitcolor = Helper.color.green
		end
		Helper.updateCellText(menu.contextbuttontable, menu.tradeContext.numinforows + 1, 4, ConvertMoneyString(profit, false, true, nil, true) .. " " .. ReadText(1001, 101), profitcolor)
		-- transaction value
		local total = menu.contextMenuData.totalbuyprofit - menu.contextMenuData.totalsellcost
		local transactioncolor = Helper.color.white
		if total < 0 then
			transactioncolor = Helper.color.red
		elseif total > 0 then
			transactioncolor = Helper.color.green
		end
		Helper.updateCellText(menu.contextbuttontable, menu.tradeContext.numinforows + 2, 4, ConvertMoneyString(total, false, true, nil, true) .. " " .. ReadText(1001, 101), transactioncolor)
	end
	-- ship
	for i, waredata in ipairs(menu.contextMenuData.waredatalist) do
		if waredata.ware == ware then
			local content = menu.getTradeContextRowContent(waredata)
			if content[2].text then
				Helper.updateCellText(menu.contextshiptable, 3 + i, 2, content[2].text, content[2].color)
			end
			if content[3].text then
				Helper.updateCellText(menu.contextshiptable, 3 + i, 3, content[3].text, content[3].color)
			end
			if content[6].text then
				Helper.updateCellText(menu.contextshiptable, 3 + i, 6, content[6].text, content[6].color)
			end
			if content[7].text then
				Helper.updateCellText(menu.contextshiptable, 3 + i, 7, content[7].text, content[7].color)
			end
			break
		end
	end

	-- storage
	local storagecontent = menu.getTradeContextShipStorageContent()
	for i, content in ipairs(storagecontent) do
		if i <= menu.tradeContext.numinforows then
			Helper.setSliderCellValue(menu.contextbuttontable, 2 + i, 1, content.scale.start)
		end
	end
	if menu.contextMenuData.wareexchange then
		storagecontent = menu.getTradeContextShipStorageContent(true)
		for i, content in ipairs(storagecontent) do
			if i <= menu.tradeContext.numinforows then
				Helper.setSliderCellValue(menu.contextbuttontable, 2 + i, 2, content.scale.start)
			end
		end
	end
end

function menu.orderAmountHelper(sellid, buyid, newvalue)
	if newvalue > 0 then
		if sellid then
			menu.contextMenuData.orders[ConvertIDTo64Bit(sellid)] = 0
		end
		if buyid then
			menu.contextMenuData.orders[ConvertIDTo64Bit(buyid)] = newvalue
		end
	elseif newvalue < 0 then
		if sellid then
			menu.contextMenuData.orders[ConvertIDTo64Bit(sellid)] = newvalue
		end
		if buyid then
			menu.contextMenuData.orders[ConvertIDTo64Bit(buyid)] = 0
		end
	else
		if sellid then
			menu.contextMenuData.orders[ConvertIDTo64Bit(sellid)] = 0
		end
		if buyid then
			menu.contextMenuData.orders[ConvertIDTo64Bit(buyid)] = 0
		end
	end
end

function menu.slidercellBoardingAssignedMarines(ship, marinelevel, newvalue)
	local change = newvalue - menu.boardingData.shipdata[ship].assignedgroupmarines[marinelevel]
	--print("assigned group marines: " .. menu.boardingData.shipdata[ship].assignedgroupmarines[marinelevel] .. ", newvalue: " .. tostring(newvalue) .. ", change: " .. tostring(change))

	menu.boardingData.shipdata[ship].assignedgroupmarines[marinelevel] = newvalue
	--print("recording " .. tostring(newvalue) .. " assigned group marines from " .. ffi.string(C.GetComponentName(ship)))

	if (change > 0) then
		--print("adding")
		if (newvalue > menu.boardingData.shipdata[ship].marines[marinelevel]) then
			local numtoadd = menu.boardingData.shipdata[ship].marines[marinelevel]
			local remaining = newvalue - numtoadd
			menu.boardingData.shipdata[ship].assignedmarines[marinelevel] = numtoadd
			--print("recording " .. tostring(numtoadd) .. " assigned marines from " .. ffi.string(C.GetComponentName(ship)) .. ". remaining: " .. tostring(remaining))

			if remaining > 0 then
				for _, subordinate in ipairs(menu.boardingData.shipdata[ship].subordinates) do
					--print("subordinate: " .. ffi.string(C.GetComponentName(subordinate)) .. " " .. tostring(subordinate) .. " level: " .. tostring(marinelevel) .. ", subordinate marines: " .. tostring(menu.boardingData.shipdata[subordinate].marines[marinelevel]) .. ", assigned subordinate marines: " .. tostring(menu.boardingData.shipdata[subordinate].assignedmarines[marinelevel]))
					if menu.boardingData.shipdata[subordinate].marines[marinelevel] and (menu.boardingData.shipdata[subordinate].marines[marinelevel] > 0) then
						numtoadd = math.min(remaining, menu.boardingData.shipdata[subordinate].marines[marinelevel])
						remaining = remaining - numtoadd
						menu.boardingData.shipdata[subordinate].assignedmarines[marinelevel] = numtoadd
						--print("recording " .. tostring(numtoadd) .. " assigned marines from " .. ffi.string(C.GetComponentName(subordinate)) .. ". remaining: " .. tostring(remaining))
						if remaining < 1 then
							--print("done adding")
							break
						end
					end
				end
			end
		else
			menu.boardingData.shipdata[ship].assignedmarines[marinelevel] = newvalue
			--print("recording " .. tostring(menu.boardingData.shipdata[ship].assignedmarines[marinelevel]) .. " assigned marines from " .. ffi.string(C.GetComponentName(ship)))
		end
	else
		--print("removing. change: " .. tostring(change) .. ", numassignedmarines: " .. tostring(menu.boardingData.shipdata[ship].assignedmarines[marinelevel]))
		if (-change > menu.boardingData.shipdata[ship].assignedmarines[marinelevel]) then
			local numtosubtract = menu.boardingData.shipdata[ship].assignedmarines[marinelevel]
			local remaining = -change - numtosubtract
			menu.boardingData.shipdata[ship].assignedmarines[marinelevel] = menu.boardingData.shipdata[ship].assignedmarines[marinelevel] - numtosubtract

			if remaining > 0 then
				for _, subordinate in ipairs(menu.boardingData.shipdata[ship].subordinates) do
					--print("subordinate: " .. ffi.string(C.GetComponentName(subordinate)) .. " " .. tostring(subordinate) .. " level: " .. tostring(marinelevel) .. ", assigned subordinate marines: " .. tostring(menu.boardingData.shipdata[subordinate].assignedmarines[marinelevel]))
					if (menu.boardingData.shipdata[subordinate].assignedmarines[marinelevel] > 0) then
						numtosubtract = math.min(remaining, menu.boardingData.shipdata[subordinate].assignedmarines[marinelevel])
						remaining = remaining - numtosubtract
						menu.boardingData.shipdata[subordinate].assignedmarines[marinelevel] = menu.boardingData.shipdata[subordinate].assignedmarines[marinelevel] - numtosubtract
						--print("recording removal of " .. tostring(numtosubtract) .. " assigned marines from " .. ffi.string(C.GetComponentName(subordinate)) .. ". remaining: " .. tostring(remaining))
						if remaining < 1 then
							--print("done removing")
							break
						end
					end
				end
			end
		else
			menu.boardingData.shipdata[ship].assignedmarines[marinelevel] = menu.boardingData.shipdata[ship].assignedmarines[marinelevel] + change
			--print("recording " .. tostring(menu.boardingData.shipdata[ship].assignedmarines[marinelevel]) .. " assigned marines from " .. ffi.string(C.GetComponentName(ship)))
		end
	end
	menu.boardingData.changed = true
end

function menu.slidercellShipCargo(sellid, buyid, ware, cargoamount, value)
	menu.tradeAmountChanged = ware

	local oldsellvalue = sellid and (menu.contextMenuData.orders[ConvertIDTo64Bit(sellid)] or 0) or 0
	local oldbuyvalue = buyid and (menu.contextMenuData.orders[ConvertIDTo64Bit(buyid)] or 0) or 0
	menu.orderAmountHelper(sellid, buyid, cargoamount - value)
	local newsellvalue = sellid and (menu.contextMenuData.orders[ConvertIDTo64Bit(sellid)] or 0) or 0
	local newbuyvalue = buyid and (menu.contextMenuData.orders[ConvertIDTo64Bit(buyid)] or 0) or 0

	local change = oldsellvalue - newsellvalue + oldbuyvalue - newbuyvalue
	if change > 0 then
		change = AddCargo(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), ware, change, true)
		if menu.contextMenuData.wareexchange then
			RemoveCargo(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), ware, change, true)
		end
	elseif change < 0 then
		if menu.contextMenuData.wareexchange then
			change = -AddCargo(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), ware, -change, true)
		end
		RemoveCargo(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), ware, -change, true)
	end

	-- fix order amounts in case adding cargo failed
	value = cargoamount - oldsellvalue - oldbuyvalue + change
	menu.orderAmountHelper(sellid, buyid, cargoamount - value)

	menu.tradeContextCostAndStorageUpdateHelper("cargo", ware)
end

function menu.slidercellShipAmmo(sellid, buyid, ware, ammoamount, value)
	menu.tradeAmountChanged = ware

	local oldsellvalue = sellid and (menu.contextMenuData.orders[ConvertIDTo64Bit(sellid)] or 0) or 0
	local oldbuyvalue = buyid and (menu.contextMenuData.orders[ConvertIDTo64Bit(buyid)] or 0) or 0
	menu.orderAmountHelper(sellid, buyid, ammoamount - value)
	local newsellvalue = sellid and (menu.contextMenuData.orders[ConvertIDTo64Bit(sellid)] or 0) or 0
	local newbuyvalue = buyid and (menu.contextMenuData.orders[ConvertIDTo64Bit(buyid)] or 0) or 0

	local waremacro = GetWareData(ware, "component")
	local change = oldsellvalue - newsellvalue + oldbuyvalue - newbuyvalue
	if change > 0 then
		change = AddAmmo(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), waremacro, change, false, true)
		if menu.contextMenuData.wareexchange then
			RemoveAmmo(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), waremacro, change, false, true)
		end
	elseif change < 0 then
		if menu.contextMenuData.wareexchange then
			change = -AddAmmo(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), waremacro, -change, false, true)
		end
		RemoveAmmo(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), waremacro, -change, false, true)
	end

	-- fix order amounts in case adding cargo failed
	value = ammoamount - oldsellvalue - oldbuyvalue + change
	menu.orderAmountHelper(sellid, buyid, ammoamount - value)

	menu.tradeContextCostAndStorageUpdateHelper("ammo", ware)
end

function menu.onSliderCellDown()
	if menu.contextMenuMode == "trade" then
		menu.tradeSliderLock = true
	end
end

function menu.slidercellTradeConfirmed(ware)
	if menu.tradeAmountChanged then
		menu.tradeAmountChanged = nil
		menu.showOptionalWarningWare = nil
	else
		menu.showOptionalWarningWare = ware
	end

	--menu.topRows.contextoffertable = GetTopRow(menu.contextoffertable)
	--menu.selectedRows.contextoffertable = Helper.currentTableRow[menu.contextoffertable]
	menu.topRows.contextshiptable = GetTopRow(menu.contextshiptable)
	menu.selectedRows.contextshiptable = Helper.currentTableRow[menu.contextshiptable]
	menu.tradeSliderLock = nil
	menu.createContextFrame()
end

function menu.dropdownBoardingSetAction(ship, newaction)
	menu.boardingData.shipdata[ship].action = newaction
	menu.boardingData.changed = true
end

function menu.dropdownBoardingSetRisk(newrisklevel, phaseindex)
	--print("newrisklevel: " .. tostring(newrisklevel))
	local stage = ("risk" .. phaseindex)
	menu.boardingData[stage] = newrisklevel
	menu.boardingData.changed = true
end

function menu.dropdownShip(_, shipid)
	local shipid64 = ConvertStringTo64Bit(shipid)
	if shipid64 ~= menu.contextMenuData.currentShip then
		if C.IsComponentOperational(menu.contextMenuData.currentShip) then
			SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), false)
		end

		menu.contextMenuData.currentShip = shipid64
		SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), false)

		menu.contextMenuData.orders = {}

		menu.initTradeContextData()

		--menu.topRows.contextoffertable = GetTopRow(menu.contextoffertable)
		--menu.selectedRows.contextoffertable = Helper.currentTableRow[menu.contextoffertable]
		menu.topRows.contextshiptable = GetTopRow(menu.contextshiptable)
		menu.selectedRows.contextshiptable = Helper.currentTableRow[menu.contextshiptable]
		menu.createContextFrame()
	end
end

function menu.dropdownNewSyncPoint(orderidx, idstring)
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
		local id = tonumber(idstring)

		if id == 0 then
			C.RemoveOrderSyncPointID(menu.infoSubmenuObject, orderidx)
		else
			C.SetOrderSyncPointID(menu.infoSubmenuObject, orderidx, id, false)
		end

		menu.refreshInfoFrame()
	else
		DebugError("menu.dropdownNewSyncPoint: function called with invalid object: " .. ffi.string(C.GetComponentName(menu.infoSubmenuObject)) .. " " .. tostring(menu.infoSubmenuObject))
	end
end

function menu.buttonReleaseSyncPoint(i)
	C.ReleaseOrderSyncPoint(i)
	menu.refreshInfoFrame()
end

function menu.dropdownModuleSet(_, idstring)
	menu.plotData.set = idstring
	menu.noupdate = false
end

-- mode: "factionresponses", "controllableresponses"
function menu.dropdownOrdersSetResponse(_, newresponseid, factionorcontrollable, signalid, mode)
	if mode ~= "factionresponses" and mode ~= "controllableresponses" then
		DebugError("menu.dropdownOrdersSetResponse called with invalid mode set. only 'factionresponses' and 'controllableresponses' are supported at this time. mode: " .. tostring(mode))
		return
	elseif not factionorcontrollable then
		DebugError("menu.dropdownOrdersSetResponse called with invalid faction or controllable set. factionorcontrollable: " .. tostring(factionorcontrollable))
		return
	elseif not signalid then
		DebugError("menu.dropdownOrdersSetResponse called with invalid signal id set. signalid: " .. tostring(signalid))
		return
	end

	if newresponseid == "reset" then
		if mode == "controllableresponses" then
			if not C.ResetResponseToSignalForControllable(signalid, factionorcontrollable) then
				DebugError("Failed resetting response to signal " .. tostring(signalid) .. " for controllable " .. ffi.string(C.GetComponentName(factionorcontrollable)) .. " " .. tostring(factionorcontrollable))
			end
		else
			local factionobjects = GetContainedObjectsByOwner(factionorcontrollable)
			for _, object in ipairs(factionobjects) do
				local object64 = ConvertIDTo64Bit(object)
				if C.IsComponentClass(object64, "controllable") then
					if not C.ResetResponseToSignalForControllable(signalid, object64) then
						DebugError("Failed resetting response to signal " .. tostring(signalid) .. " for controllable " .. ffi.string(C.GetComponentName(object64)) .. " " .. tostring(object64))
					end
				end
			end
		end
	else
		local ask
		if mode == "controllableresponses" then
			ask = C.GetAskToSignalForControllable(signalid, factionorcontrollable)
			C.SetDefaultResponseToSignalForControllable(newresponseid, ask, signalid, factionorcontrollable)
		else
			ask = C.GetAskToSignalForFaction(signalid, factionorcontrollable)
			C.SetDefaultResponseToSignalForFaction(newresponseid, ask, signalid, factionorcontrollable)
		end
	end
	menu.refreshInfoFrame()
end

function menu.dropdownHireRole(_, idstring)
	menu.noupdate = false
	if idstring ~= nil then
		local type, id = string.match(idstring, "(.+):(.+)")
		menu.hireIsPost = type == "post"
		menu.hireRole = id

		menu.refreshMainFrame = true
	end
end

function menu.dropdownBehaviourFormation(_, shape)
	if shape ~= nil then
		local info = C.SetFormationShape(menu.infoSubmenuObject, shape)
		shape = ffi.string(info.shape)

		if (shape ~= "") then
			local subordinates = GetSubordinates(menu.infoSubmenuObject)
			for i = #subordinates, 1, -1 do
				local subordinate = ConvertIDTo64Bit(subordinates[i])

				local numorders = C.GetNumOrders(subordinate)
				local currentorders = ffi.new("Order[?]", numorders)
				numorders = C.GetOrders(currentorders, numorders, subordinate)
				for j = 1, numorders do
					if ffi.string(currentorders[0].orderdef) == "Escort" then
						SetOrderParam(subordinate, j, 2, nil, shape) -- shape
						SetOrderParam(subordinate, j, 3, nil, info.radius) -- radius
						SetOrderParam(subordinate, j, 4, nil, info.rollMembers) -- rollmembers
						SetOrderParam(subordinate, j, 5, nil, info.rollFormation) -- rollformation
						SetOrderParam(subordinate, j, 6, nil, tonumber(info.maxShipsPerLine)) -- maxshipsperline
					end
				end

				local currentdefaultorder = ffi.new("Order")
				if C.GetDefaultOrder(currentdefaultorder, subordinate) then
					if ffi.string(currentdefaultorder.orderdef) == "Escort" then
						SetOrderParam(subordinate, "default", 2, nil, shape) -- shape
						SetOrderParam(subordinate, "default", 3, nil, info.radius) -- radius
						SetOrderParam(subordinate, "default", 4, nil, info.rollMembers) -- rollmembers
						SetOrderParam(subordinate, "default", 5, nil, info.rollFormation) -- rollformation
						SetOrderParam(subordinate, "default", 6, nil, tonumber(info.maxShipsPerLine)) -- maxshipsperline
					end
				end
			end
		end
	end
end

function menu.checkboxSetWeaponConfig(system, value)
	if system == "default" then
		menu.contextMenuData.default = value
	end
	for i, entry in ipairs(menu.contextMenuData.weaponsystems) do
		if entry.id == system then
			menu.contextMenuData.weaponsystems[i].active = value
		end
	end
	menu.createContextFrame()
end

function menu.checkboxInfoSubmenuRestrictTrade(station)
	ToggleFactionTradeRestriction(station)
	menu.refreshInfoFrame()
end

-- mode: "factionresponses", "controllableresponses"
function menu.checkboxOrdersSetAsk(factionorcontrollable, signalid, mode)
	if mode ~= "factionresponses" and mode ~= "controllableresponses" then
		DebugError("menu.checkboxOrdersSetAsk called with invalid mode set. only 'factionresponses' and 'controllableresponses' are supported at this time. mode: " .. tostring(mode))
		return
	elseif not factionorcontrollable then
		DebugError("menu.checkboxOrdersSetAsk called with invalid faction or controllable set. factionorcontrollable: " .. tostring(factionorcontrollable))
		return
	elseif not signalid then
		DebugError("menu.checkboxOrdersSetAsk called with invalid signal id set. signalid: " .. tostring(signalid))
		return
	end

	local ask
	local response
	if mode == "controllableresponses" then
		ask = not C.GetAskToSignalForControllable(signalid, factionorcontrollable)
		response = C.GetDefaultResponseToSignalForControllable(signalid, factionorcontrollable)
		C.SetDefaultResponseToSignalForControllable(response, ask, signalid, factionorcontrollable)
	else
		ask = not C.GetAskToSignalForFaction(signalid, factionorcontrollable)
		response = C.GetDefaultResponseToSignalForFaction(signalid, factionorcontrollable)
		C.SetDefaultResponseToSignalForFaction(response, ask, signalid, factionorcontrollable)
	end
	menu.refreshInfoFrame()
end

function menu.checkboxOrdersSetOverride(controllable, signalid, mode, checked)
	if mode ~= "controllableresponses" then
		DebugError("menu.checkboxOrdersSetOverride called with invalid mode set. only 'controllableresponses' is supported at this time. mode: " .. tostring(mode))
		return
	elseif not controllable then
		DebugError("menu.checkboxOrdersSetOverride called with invalid faction or controllable set. controllable: " .. tostring(controllable))
		return
	elseif not signalid then
		DebugError("menu.checkboxOrdersSetOverride called with invalid signal id set. signalid: " .. tostring(signalid))
		return
	end

	if checked then
		if not C.ResetResponseToSignalForControllable(signalid, controllable) then
			DebugError("Failed resetting response to signal " .. tostring(signalid) .. " for controllable " .. ffi.string(C.GetComponentName(controllable)) .. " " .. tostring(controllable))
		end
	else
		local faction = GetComponentData(controllable, "owner")
		local deffactresponse = ffi.string(C.GetDefaultResponseToSignalForFaction(signalid, faction))
		local ask = C.GetAskToSignalForControllable(signalid, controllable)
		C.SetDefaultResponseToSignalForControllable(deffactresponse, ask, signalid, controllable)
	end

	menu.refreshInfoFrame()
end

function menu.storeCurrentPlots()
	menu.currentPlots = {}
	local playerobjects = GetContainedStationsByOwner("player", nil, true)
	for _, station in ipairs(playerobjects) do
		local station64 = ConvertStringTo64Bit(tostring(station))
		local rawsize = C.GetBuildPlotSize(station64)
		local plotcenter = C.GetBuildPlotCenterOffset(station64)
		menu.currentPlots[tostring(station64)] = {
			posX = math.ceil((rawsize.x / 2 + plotcenter.x) / 1000),
			negX = math.floor((rawsize.x / 2 - plotcenter.x) / 1000),
			posY = math.ceil((rawsize.y / 2 + plotcenter.y) / 1000),
			negY = math.floor((rawsize.y / 2 - plotcenter.y) / 1000),
			posZ = math.ceil((rawsize.z / 2 + plotcenter.z) / 1000),
			negZ = math.floor((rawsize.z / 2 - plotcenter.z) / 1000),
		}
	end
end

function menu.updatePlotData(station, donotrefresh)
	if not station then
		if not menu.plotData.component then
			DebugError("menu.updatePlotData(): no station passed in. station: " .. tostring(station) .. ", menu.plotData.component: " .. tostring(menu.plotData.component) .. ".")
			return
		end
		station = menu.plotData.component
	end

	if station ~= "plots_new" then
		local station64 = ConvertStringTo64Bit(tostring(station))
		local rawsize = C.GetBuildPlotSize(station)
		local plotcenter = C.GetBuildPlotCenterOffset(station)
		local sets = GetComponentData(station64, "modulesets")
		local sector = GetComponentData(station64, "sectorid")
		local owner = GetComponentData(station64, "owner")
		local boughtrawsize = C.GetPaidBuildPlotSize(station)
		local playermoney = GetPlayerMoney()
		local minimumrawsize = C.GetMinimumBuildPlotSize(station)
		local minimumcenter = C.GetMinimumBuildPlotCenterOffset(station)

		menu.plotData.name = ffi.string(C.GetComponentName(station))
		menu.plotData.component = station
		menu.plotData.set = sets[1] or ""
		menu.plotData.placed = true
		menu.plotData.sector = ConvertIDTo64Bit(sector)
		menu.plotData.permanent = (C.GetNumStationModules(station, true, true) > 0) and true or false
		menu.plotData.isinownedspace = (GetComponentData(sector, "owner") ~= "ownerless") and (GetComponentData(sector, "owner") ~= "xenon")
		menu.plotData.paid = (not menu.plotData.isinownedspace or boughtrawsize.x > 0 or boughtrawsize.y > 0 or boughtrawsize.z > 0) and true or false
		menu.plotData.fullypaid = (not menu.plotData.isinownedspace or (boughtrawsize.x >= rawsize.x and boughtrawsize.y >= rawsize.y and boughtrawsize.z >= rawsize.z)) and true or false
		menu.plotData.size = { x = Helper.round(rawsize.x / 1000), y = Helper.round(rawsize.y / 1000), z = Helper.round(rawsize.z / 1000) }
		menu.plotData.dimensions = {
			posX = math.ceil((rawsize.x / 2 + plotcenter.x) / 1000),
			negX = math.floor((rawsize.x / 2 - plotcenter.x) / 1000),
			posY = math.ceil((rawsize.y / 2 + plotcenter.y) / 1000),
			negY = math.floor((rawsize.y / 2 - plotcenter.y) / 1000),
			posZ = math.ceil((rawsize.z / 2 + plotcenter.z) / 1000),
			negZ = math.floor((rawsize.z / 2 - plotcenter.z) / 1000),
		}
		menu.plotData.minimumdimensions = {
			posX = math.ceil((minimumrawsize.x / 2 + minimumcenter.x) / 1000),
			negX = math.floor((minimumrawsize.x / 2 - minimumcenter.x) / 1000),
			posY = math.ceil((minimumrawsize.y / 2 + minimumcenter.y) / 1000),
			negY = math.floor((minimumrawsize.y / 2 - minimumcenter.y) / 1000),
			posZ = math.ceil((minimumrawsize.z / 2 + minimumcenter.z) / 1000),
			negZ = math.floor((minimumrawsize.z / 2 - minimumcenter.z) / 1000),
		}

		if not menu.plotData.isinownedspace and (rawsize.x > boughtrawsize.x or rawsize.y > boughtrawsize.y or rawsize.z > boughtrawsize.z) then
			C.PayBuildPlotSize(station, rawsize, plotcenter)
			boughtrawsize = C.GetPaidBuildPlotSize(station)
			local found
			for _, plot in ipairs(menu.plots) do
				if plot.station == station then
					plot.boughtrawcenteroffset = plotcenter
					found = true
					break
				end
			end
			if not found then
				table.insert(menu.plots, { station = station, paid = true, fullypaid = true, permanent = (C.GetNumStationModules(station, true, true) > 0) and true or false, boughtrawcenteroffset = plotcenter, removed = nil })
			end
		end
		menu.plotData.boughtrawsize = { x = boughtrawsize.x, y = boughtrawsize.y, z = boughtrawsize.z }
		--print("fullypaid: " .. tostring(menu.plotData.fullypaid) .. ", boughtsize: " .. tostring(boughtrawsize.x) .. " x " .. tostring(boughtrawsize.y) .. " x " .. tostring(boughtrawsize.z) .. ", size: " .. tostring(rawsize.x) .. " x " .. tostring(rawsize.y) .. " x " .. tostring(rawsize.z))

		for _, plot in ipairs(menu.plots) do
			if station == plot.station then
				menu.plotData.boughtrawcenteroffset = plot.boughtrawcenteroffset
				break
			end
		end

		local pos = ffi.new("UIPosRot")
		pos = C.GetObjectPositionInSector(station)
		menu.plotData.position = pos
		menu.plotData.price = tonumber(C.GetBuildPlotPrice(menu.plotData.sector, menu.plotData.position, rawsize.x, rawsize.y, rawsize.z, owner)) - tonumber(C.GetBuildPlotPrice(menu.plotData.sector, menu.plotData.position, menu.plotData.boughtrawsize.x, menu.plotData.boughtrawsize.y, menu.plotData.boughtrawsize.z, owner))
		menu.plotData.affordable = playermoney >= menu.plotData.price
	else
		menu.plotData = {
			name = ReadText(1001, 9200),	-- New Plot
			set = "factory",
			active = false,
			placed = false,
			sector = menu.currentsector,
			permanent = false,
			isinownedspace = (GetComponentData(ConvertStringTo64Bit(tostring(menu.currentsector)), "owner") ~= "ownerless") and (GetComponentData(ConvertStringTo64Bit(tostring(menu.currentsector)), "owner") ~= "xenon"),
			paid = false,
			fullypaid = false,
			boughtrawsize = { x = 0, y = 0, z = 0 },
			size = { x = 4, y = 4, z = 4 },
			dimensions = { posX = 2, negX = 2, posY = 2, negY = 2, posZ = 2, negZ = 2 },
			minimumdimensions = { posX = 0, negX = 0, posY = 0, negY = 0, posZ = 0, negZ = 0 },
			affordable = false,
			removed = nil
		}
	end

	if menu.currentsector ~= menu.plotData.sector then
		menu.currentsector = menu.plotData.sector
		C.ShowBuildPlotPlacementMap(menu.holomap, menu.currentsector)
	end

	if not donotrefresh and menu.plotsliders then
		-- if slider setup (3-slider or 6-slider) and plotData don't match, refresh the menu at the next opportunity.
		if (menu.plotsliders[1].dimension == "x" and menu.plotData.placed) or (menu.plotsliders[1].dimension ~= "x" and not menu.plotData.placed) then
			menu.over = true
		else
			menu.updatePlotWidgets()
		end
	end
end

function menu.updatePlotWidgets()
	for _, slider in ipairs(menu.plotsliders) do
		local sliderproperties = { min = 0, minselect = 2, max = config.maxPlotSize, start = menu.plotData.size[slider.dimension], step = 2, suffix = ReadText(1001, 108) }
		local boughtdimensions = {}
		if menu.plotData.paid then
			boughtdimensions = {
				posX = math.ceil((menu.plotData.boughtrawsize.x / 2 + menu.plotData.boughtrawcenteroffset.x) / 1000),
				negX = math.floor((menu.plotData.boughtrawsize.x / 2 - menu.plotData.boughtrawcenteroffset.x) / 1000),
				posY = math.ceil((menu.plotData.boughtrawsize.y / 2 + menu.plotData.boughtrawcenteroffset.y) / 1000),
				negY = math.floor((menu.plotData.boughtrawsize.y / 2 - menu.plotData.boughtrawcenteroffset.y) / 1000),
				posZ = math.ceil((menu.plotData.boughtrawsize.z / 2 + menu.plotData.boughtrawcenteroffset.z) / 1000),
				negZ = math.floor((menu.plotData.boughtrawsize.z / 2 - menu.plotData.boughtrawcenteroffset.z) / 1000),
			}
		end
		if menu.plotData.placed then
			local locdimension = menu.plotData.dimensions[slider.dimension]
			local minimumdimension = menu.plotData.minimumdimensions[slider.dimension] or 0
			local boughtdimension = menu.plotData.paid and boughtdimensions[slider.dimension] or 0
			local locpaireddimension = menu.plotData.dimensions[config.plotPairedDimension[slider.dimension]]

			local minselect = math.max(menu.plotData.permanent and math.max(boughtdimension, minimumdimension) or boughtdimension, (locpaireddimension == 0 and 1 or 0))
			sliderproperties = { 
				min = 0,
				minselect = minselect,
				max = (locpaireddimension > config.maxPlotSize) and locpaireddimension or config.maxPlotSize,
				maxselect = (locpaireddimension > config.maxPlotSize) and locpaireddimension or (config.maxPlotSize - locpaireddimension),
				start = locdimension,
				step = 1,
				suffix = ReadText(1001, 108) 
			}
			if sliderproperties.start < sliderproperties.minselect then
				print("menu.updatePlotWidgets(): start < minselect [Florian]")
				sliderproperties.start = sliderproperties.minselect
			end
		end
		--print("dimension: " .. tostring(slider.dimension) .. ", paired: " .. tostring(config.plotPairedDimension[slider.dimension]) .. ", row: " .. tostring(slider.row) .. ", value: " .. tostring(menu.plotData.dimensions[slider.dimension]) )
		--Helper.setSliderCellValue(slider.table.id, slider.row, slider.col, menu.plotData.dimensions[slider.dimension])

		-- NB: necessary at the moment to set max in addition to changing slider value.
		Helper.removeSliderCellScripts(menu, slider.table.id, slider.row, slider.col)
		SetCellContent(
					slider.table.id,
					Helper.createSliderCell(
						Helper.createTextInfo(
							slider.cell.properties.text.text,
							"left",
							Helper.standardFont,
							slider.cell.properties.text.fontsize,
							Helper.standardColor.r, 
							Helper.standardColor.g, 
							Helper.standardColor.b, 
							Helper.standardColor.a, 
							0,
							0), 
						nil,
						nil,
						nil,
						nil,
						config.mapRowHeight,
						slider.cell.properties.bgColor,
						nil,
						sliderproperties),
					slider.row,
					slider.col)
		Helper.setSliderCellScript(menu, nil, slider.table.id, slider.row, slider.col, function(_, val) return menu.slidercellPlotValue(_, val, slider.dimension, not menu.plotData.placed) end, nil, nil, nil, function() return menu.refreshInfoFrame() end)
	end

	-- NB: this is simply to reset the button's active attribute.
	for _, button in ipairs(menu.plotbuttons) do
		if button.rowdata == "createplot" then
			local activate
			if button.col == 2 then
				activate = (menu.plotData.placed and menu.plotData.paid and (menu.plotData.size.x * 1000 > menu.plotData.boughtrawsize.x or menu.plotData.size.y * 1000 > menu.plotData.boughtrawsize.y or menu.plotData.size.z * 1000 > menu.plotData.boughtrawsize.z) and not menu.plotData.permanent) and true or false
			elseif button.col == 3 then
				activate = not menu.plotData.placed
			end
			Helper.removeButtonScripts(menu, button.table.id, button.row, button.col)
			SetCellContent(
						button.table.id,
						Helper.createButton(
							Helper.createTextInfo(
								button.cell.properties.text.text,
								"center",
								Helper.standardFont,
								button.cell.properties.text.fontsize,
								Helper.standardColor.r, 
								Helper.standardColor.g, 
								Helper.standardColor.b, 
								Helper.standardColor.a, 
								0,
								0), 
							nil,
							false,
							activate),
						button.row,
						button.col)
			Helper.setButtonScript(menu, nil, button.table.id, button.row, button.col, button.script)
		elseif button.rowdata == "buyplot" then
			local activate
			if button.col == 2 then
				activate = false
			elseif button.col == 3 then
				activate = (menu.plotData.placed and not menu.plotData.fullypaid and menu.plotData.isinownedspace and menu.plotData.affordable) and true or false
			end
			local mouseovertext = ""
			if menu.plotData.placed and (not menu.plotData.fullypaid) and menu.plotData.isinownedspace and (not menu.plotData.affordable) then
				mouseovertext = ReadText(1026, 3222)
			end
			Helper.removeButtonScripts(menu, button.table.id, button.row, button.col)
			SetCellContent(
						button.table.id,
						Helper.createButton(
							Helper.createTextInfo(
								button.cell.properties.text.text,
								"center",
								Helper.standardFont,
								button.cell.properties.text.fontsize,
								Helper.standardColor.r, 
								Helper.standardColor.g, 
								Helper.standardColor.b, 
								Helper.standardColor.a, 
								0,
								0), 
							nil,
							false,
							activate,
							nil,
							nil,
							nil,
							nil,
							nil,
							nil,
							nil,
							mouseovertext
						),
						button.row,
						button.col)
			Helper.setButtonScript(menu, nil, button.table.id, button.row, button.col, button.script)
		elseif button.rowdata == "initiateconstruction" then
			--local danger = menu.plotData.placed and not menu.plotData.fullypaid and menu.plotData.isinownedspace
			--local buttoncolor = danger and Helper.color.red or nil
			--local textcolor = danger and Helper.color.black or Helper.standardColor
			--local textfont = danger and Helper.standardFontBold or Helper.standardFont
			Helper.removeButtonScripts(menu, button.table.id, button.row, button.col)
			SetCellContent(
						button.table.id,
						Helper.createButton(
							Helper.createTextInfo(
								button.cell.properties.text.text,
								"center",
								Helper.standardFont,
								button.cell.properties.text.fontsize,
								Helper.standardColor.r, 
								Helper.standardColor.g, 
								Helper.standardColor.b, 
								Helper.standardColor.a, 
								0,
								0), 
							nil,
							false,
							menu.plotData.placed),
						button.row,
						button.col)
			Helper.setButtonScript(menu, nil, button.table.id, button.row, button.col, button.script)
		end
	end
end

function menu.resetPlotSize(cleanup)
	if not menu.plotData.placed then
		DebugError("menu.resetPlotSize: tried to resize a plot that has not yet been placed.")
		return
	end
	if menu.plotData.paid then
		local wantedcenteroffset = menu.plotData.boughtrawcenteroffset
		--print("wantedcenteroffset.x: " .. tostring(wantedcenteroffset.x) .. ", wantedcenteroffset.y: " .. tostring(wantedcenteroffset.y) .. ", wantedcenteroffset.z: " .. tostring(wantedcenteroffset.z))
		local boughtdimensions = {
			posX = math.ceil((menu.plotData.boughtrawsize.x / 2 + wantedcenteroffset.x) / 1000),
			negX = math.floor((menu.plotData.boughtrawsize.x / 2 - wantedcenteroffset.x) / 1000),
			posY = math.ceil((menu.plotData.boughtrawsize.y / 2 + wantedcenteroffset.y) / 1000),
			negY = math.floor((menu.plotData.boughtrawsize.y / 2 - wantedcenteroffset.y) / 1000),
			posZ = math.ceil((menu.plotData.boughtrawsize.z / 2 + wantedcenteroffset.z) / 1000),
			negZ = math.floor((menu.plotData.boughtrawsize.z / 2 - wantedcenteroffset.z) / 1000),
		}
		local posSizeChange = { x = (boughtdimensions.posX - menu.plotData.dimensions.posX) * 1000, y = (boughtdimensions.posY - menu.plotData.dimensions.posY) * 1000, z = (boughtdimensions.posZ - menu.plotData.dimensions.posZ) * 1000 }
		local negSizeChange = { x = (boughtdimensions.negX - menu.plotData.dimensions.negX) * 1000, y = (boughtdimensions.negY - menu.plotData.dimensions.negY) * 1000, z = (boughtdimensions.negZ - menu.plotData.dimensions.negZ) * 1000 }
		--print("poschangeX: " .. tostring(posSizeChange.x) .. ", possizechangeY: " .. tostring(posSizeChange.y) .. ", possizechangeZ: " .. tostring(posSizeChange.z) .. "\nnegchangeX: " .. tostring(negSizeChange.x) .. ", negsizechangeY: " .. tostring(negSizeChange.y) .. ", negsizechangeZ: " .. tostring(negSizeChange.z))
		if C.ExtendBuildPlot(menu.plotData.component, posSizeChange, negSizeChange, true) then
			local plotcenteroffset = C.GetBuildPlotCenterOffset(menu.plotData.component)
			menu.plotData.size = { x = menu.plotData.boughtrawsize.x / 1000, y = menu.plotData.boughtrawsize.y / 1000, z = menu.plotData.boughtrawsize.z / 1000 }
			menu.plotData.dimensions = {
				posX = math.ceil((menu.plotData.boughtrawsize.x / 2 + plotcenteroffset.x) / 1000),
				negX = math.floor((menu.plotData.boughtrawsize.x / 2 - plotcenteroffset.x) / 1000),
				posY = math.ceil((menu.plotData.boughtrawsize.y / 2 + plotcenteroffset.y) / 1000),
				negY = math.floor((menu.plotData.boughtrawsize.y / 2 - plotcenteroffset.y) / 1000),
				posZ = math.ceil((menu.plotData.boughtrawsize.z / 2 + plotcenteroffset.z) / 1000),
				negZ = math.floor((menu.plotData.boughtrawsize.z / 2 - plotcenteroffset.z) / 1000),
			}
			--print("menu.resetPlotSize: successfully reset build plot of station: " .. ffi.string(C.GetComponentName(menu.plotData.component)) .. ". posSizeChange.x: " .. tostring(posSizeChange.x) .. ", posSizeChange.y: " .. tostring(posSizeChange.y) .. ", posSizeChange.z: " .. tostring(posSizeChange.z) .. ", negSizeChange.x: " .. tostring(negSizeChange.x) .. ", negSizeChange.y: " .. tostring(negSizeChange.y) .. ", negSizeChange.z: " .. tostring(negSizeChange.z) .. ".")
			if not cleanup then
				C.UpdateMapBuildPlot(menu.holomap)
			end
		else
			DebugError("menu.resetPlotSize: failed to reset build plot of station: " .. ffi.string(C.GetComponentName(menu.plotData.component)) .. "\nposSizeChange.x: " .. tostring(posSizeChange.x) .. ", posSizeChange.y: " .. tostring(posSizeChange.y) .. ", posSizeChange.z: " .. tostring(posSizeChange.z) .. "\nnegSizeChange.x: " .. tostring(negSizeChange.x) .. ", negSizeChange.y: " .. tostring(negSizeChange.y) .. ", negSizeChange.z: " .. tostring(negSizeChange.z))
		end
		if not menu.plotData.fullypaid and menu.plotData.price == 0 then
			menu.plotData.fullypaid = true
		end
		menu.updatePlotData(menu.plotData.component, cleanup)
		if not cleanup then
			menu.refreshInfoFrame()
		end
	end
end

function menu.updatePlotSize(dimension, axis, valchange)
	if menu.plotData.active then
		C.ChangeMapBuildPlot(menu.holomap, menu.plotData.size.x * 1000, menu.plotData.size.y * 1000, menu.plotData.size.z * 1000)
	elseif menu.plotData.placed then
		local posSizeChange = { x = 0, y = 0, z = 0 }
		local negSizeChange = { x = 0, y = 0, z = 0 }
		if dimension == "posX" or dimension == "posY" or dimension == "posZ" then
			posSizeChange[axis] = valchange * 1000
		elseif dimension == "negX" or dimension == "negY" or dimension == "negZ" then
			negSizeChange[axis] = valchange * 1000
		else
			DebugError("menu.updatePlotSize: dimension passed in: " .. tostring(dimension) .. " indicates neither positive nor negative.")
			return
		end
		if C.ExtendBuildPlot(menu.plotData.component, posSizeChange, negSizeChange, true) then
			--print("menu.updatePlotSize: successfully extended build plot of station: " .. ffi.string(C.GetComponentName(menu.plotData.component)) .. ". posSizeChange.x: " .. tostring(posSizeChange.x) .. ", posSizeChange.y: " .. tostring(posSizeChange.y) .. ", posSizeChange.z: " .. tostring(posSizeChange.z) .. ", negSizeChange.x: " .. tostring(negSizeChange.x) .. ", negSizeChange.y: " .. tostring(negSizeChange.y) .. ", negSizeChange.z: " .. tostring(negSizeChange.z) .. ".")
			C.UpdateMapBuildPlot(menu.holomap)
			if not menu.plotData.isinownedspace then
				local rawsize = C.GetBuildPlotSize(menu.plotData.component)
				local plotcenter = C.GetBuildPlotCenterOffset(menu.plotData.component)
				for _, plot in ipairs(menu.plots) do
					if plot.station == menu.plotData.component then
						plot.boughtrawcenteroffset = plotcenter
						break
					end
				end
				C.PayBuildPlotSize(menu.plotData.component, rawsize, plotcenter)
			end
		else
			DebugError("menu.updatePlotSize: failed to extend build plot of station: " .. ffi.string(C.GetComponentName(menu.plotData.component)) .. ". posSizeChange.x: " .. tostring(posSizeChange.x) .. ", posSizeChange.y: " .. tostring(posSizeChange.y) .. ", posSizeChange.z: " .. tostring(posSizeChange.z) .. ", negSizeChange.x: " .. tostring(negSizeChange.x) .. ", negSizeChange.y: " .. tostring(negSizeChange.y) .. ", negSizeChange.z: " .. tostring(negSizeChange.z) .. ".")
		end
	end
end

function menu.plotInitiateConstruction(station)
	if not station then
		DebugError("menu.plotInitiateConstruction(): no station passed in. station: " .. tostring(station))
		return
	end
	menu.setplotrow = Helper.currentTableRow[menu.infoTable]
	menu.setplottoprow = GetTopRow(menu.infoTable)
	for _, plot in ipairs(menu.plots) do
		if plot.station == station then
			plot.permanent = true
			break
		end
	end

	AddUITriggeredEvent(menu.name, "initiateconstruction_license", menu.plotData.fullypaid)

	Helper.closeMenuAndOpenNewMenu(menu, "StationConfigurationMenu", { 0, 0, station })
	menu.cleanup()
end

-- shortcuts
function menu.hotkey(action)
	local rowdata = Helper.getCurrentRowData(menu, menu.infoTable)
	local selectedcomponent
	if next(menu.selectedcomponents) then
		for id, _ in pairs(menu.selectedcomponents) do
			selectedcomponent = ConvertStringTo64Bit(id)
			if IsValidComponent(selectedcomponent) then
				break
			end
			selectedcomponent = nil
		end
	end

	if action == "INPUT_ACTION_ADDON_DETAILMONITOR_CLOSE_MAP" then
		menu.onCloseElement("close")
	elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_MISSIONS" then
		if menu.infoTableMode ~= "mission" then
			if menu.mode ~= "hire" then
				menu.infoTableMode = "mission"
				menu.refreshMainFrame = true
				menu.refreshInfoFrame()
			end
		end
	elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_ZONE_VIEW" then
		if menu.holomap and (menu.holomap ~= 0) then
			C.SetMapTargetDistance(menu.holomap, 20000)
			C.ResetMapPlayerRotation(menu.holomap)
			C.SetFocusMapComponent(menu.holomap, C.GetPlayerObjectID(), true)
			if menu.infoTableMode == "objectlist" then
				menu.refreshInfoFrame()
			end
		end
	elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_SECTOR_VIEW" then
		if menu.holomap and (menu.holomap ~= 0) then
			C.SetMapTargetDistance(menu.holomap, 2000000)
			C.ResetMapPlayerRotation(menu.holomap)
			C.SetFocusMapComponent(menu.holomap, C.GetPlayerObjectID(), true)
			if menu.infoTableMode == "objectlist" then
				menu.refreshInfoFrame()
			end
		end
	elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_F1" then
		C.SetPlayerCameraCockpitView(true)
	elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_T" then
		menu.target(nil, nil, selectedcomponent)
	elseif selectedcomponent then
		if action == "INPUT_ACTION_ADDON_DETAILMONITOR_C" then
			if (not menu.mode) and IsComponentOperational(selectedcomponent) and GetComponentData(selectedcomponent, "caninitiatecomm") then
				menu.openComm(selectedcomponent)
			end
		elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_I" then
			if (not menu.mode) and IsInfoUnlockedForPlayer(selectedcomponent, "name") and CanViewLiveData(selectedcomponent) then
				menu.openDetails(selectedcomponent)
			end
		elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_P" then
			menu.plotCourse(selectedcomponent)
		elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_A_SHIFT" then
			if IsSameComponent(menu.autopilottarget, selectedcomponent) then
				StopAutoPilot()
			else
				StartAutoPilot(selectedcomponent)
			end

			menu.settoprow = GetTopRow(menu.infoTable)
			menu.setrow = Helper.currentTableRow[menu.infoTable]
			if not menu.createInfoFrameRunning then
				menu.createInfoFrame()
			end
		elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_F3" then
			if C.IsPlayerCameraTargetViewPossible(selectedcomponent, true) then
				if menu.target(selectedcomponent, true) then
					C.SetPlayerCameraTargetView(selectedcomponent, true)
				end
			end
		elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_REMOVE_ORDER" then
			local lastorderidx = C.GetNumOrders(selectedcomponent)
			if GetComponentData(selectedcomponent, "isplayerowned") and C.RemoveOrder(selectedcomponent, lastorderidx, false, true) then
				if C.RemoveOrder(selectedcomponent, lastorderidx, false, false) then
					if (menu.infoTableMode == "info") and (menu.infoMode == "orderqueue") then
						menu.removeExtendedOrder(selectedcomponent, lastorderidx)
						if lastorderidx == #menu.infoTableData.orders then
							menu.selectedorder = (lastorderidx > 1) and { (lastorderidx - 1) } or nil
						end
						if menu.selectedorder and (type(menu.selectedorder[1]) == "number") then
							menu.selectedorder = { math.min(menu.selectedorder[1], #menu.infoTableData.orders - 1) }
						end
					end
				end
			end
		end
	end
	if rowdata and (type(rowdata) == "table") then
		if action == "INPUT_ACTION_ADDON_DETAILMONITOR_RIGHT" or action == "INPUT_ACTION_ADDON_DETAILMONITOR_LEFT" then
			if (menu.lastactivetable == menu.infoTable) and (not menu.createInfoFrameRunning) then
				if (rowdata[1] == "property") then
					local isextended = menu.isPropertyExtended(tostring(rowdata[2]))
					if ((action == "INPUT_ACTION_ADDON_DETAILMONITOR_RIGHT") and (not isextended)) or ((action == "INPUT_ACTION_ADDON_DETAILMONITOR_LEFT") and isextended) then
						if rowdata[1] == "property" then
							if IsComponentClass(rowdata[2], "station") then
								if (not menu.mode) then
									menu.buttonExtendProperty(tostring(rowdata[2]))
								end
							elseif IsComponentClass(rowdata[2], "ship") then
								local subordinates = menu.infoTableData.subordinates[tostring(rowdata[2])]
								if #subordinates > 0 then
									menu.buttonExtendProperty(tostring(rowdata[2]))
								end
							end
						end
					elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_LEFT" then
						if rowdata[1] == "property" then
							local commander = GetCommander(rowdata[2])
							if commander then
								menu.settoprow = GetTopRow(menu.infoTable)
								menu.updateMapAndInfoFrame()
							end
						end
					end
				elseif rowdata[1] == "moduletype" then
					local isextended = menu.isModuleTypeExtended(rowdata[2], rowdata[3])
					if ((action == "INPUT_ACTION_ADDON_DETAILMONITOR_RIGHT") and (not isextended)) or ((action == "INPUT_ACTION_ADDON_DETAILMONITOR_LEFT") and isextended) then
						menu.extendSectionAndRefresh(rowdata)
					elseif action == "INPUT_ACTION_ADDON_DETAILMONITOR_LEFT" then
						menu.settoprow = GetTopRow(menu.infoTable)
						menu.highlightedbordercomponent = rowdata[2]
						menu.highlightedbordermoduletype = nil
						if not menu.createInfoFrameRunning then
							menu.createInfoFrame()
						end
					end
				elseif rowdata[1] == "module" then
					if action == "INPUT_ACTION_ADDON_DETAILMONITOR_LEFT" then
						menu.settoprow = GetTopRow(menu.infoTable)
						menu.highlightedbordercomponent = rowdata[5]
						menu.highlightedbordermoduletype = rowdata[3]
						menu.removeSelectedComponent(rowdata[2])
						if not menu.createInfoFrameRunning then
							menu.createInfoFrame()
						end
					end
				end
			end
		end
	end
end

function menu.target(component, allowfirstperson, fallbackcomponent)
	local refresh = false
	if component == nil then
		component = C.GetPickedMapComponent(menu.holomap)
		if not C.IsComponentClass(component, "sector") then
			if C.IsComponentClass(component, "object") then
				menu.addSelectedComponent(component, true, true)
				refresh = true
			end
		else
			component = fallbackcomponent
		end
	end
	local playersector = C.GetContextByClass(C.GetPlayerID(), "sector", false)
	local targetsector = C.GetContextByClass(component, "sector", false)
	if (not menu.mode) and (component ~= C.GetPlayerControlledShipID()) and (allowfirstperson or (not IsFirstPerson())) and (playersector == targetsector) then
		local success = C.SetSofttarget(component, "")
		if success then
			PlaySound("ui_target_set")
			if not menu.createInfoFrameRunning then
				menu.createInfoFrame()
			end
			return true
		else
			PlaySound("ui_target_set_fail")
		end
	else
		PlaySound("ui_target_set_fail")
	end
	if refresh then
		menu.refreshInfoFrame()
	end
	return false
end

function menu.openComm(component)
	local entities = Helper.getSuitableControlEntities(component, true)
	if #entities == 1 then
		if menu.conversationMenu then
			Helper.closeMenuForSubConversation(menu, "default", entities[1], component)
		else
			Helper.closeMenuForNewConversation(menu, "default", entities[1], component)
		end
	else
		Helper.closeMenuForNewConversation(menu, "gMain_propertyResult", ConvertStringToLuaID(tostring(C.GetPlayerComputerID())), component)
	end
	menu.cleanup()
end

function menu.openCommWithActor(actor)
	if menu.conversationMenu then
		Helper.closeMenuForSubConversation(menu, "default", actor)
	else
		Helper.closeMenuForNewConversation(menu, "default", actor)
	end
	menu.cleanup()
end

function menu.openDetails(component)
	menu.infoTableMode = "info"
	menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(component))
	menu.refreshMainFrame = true
	menu.refreshInfoFrame()
end

function menu.openStandingOrders(component)
	menu.infoTableMode = "info"
	menu.infoMode = "controllableresponses"
	menu.infoSubmenuObject = component
	menu.refreshMainFrame = true
	menu.refreshInfoFrame()
end

function menu.filterTradeStorage(setting)
	local count = 0
	for i, option in ipairs(setting) do
		if menu.getFilterOption(option.id) then
			count = count + 1
		end
	end
	local transport = ffi.new("const char*[?]", count)
	local i = 0
	for _, option in ipairs(setting) do
		if menu.getFilterOption(option.id) then
			transport[i] = Helper.ffiNewString(option.param)
			i = i + 1
		end
	end

	C.SetMapTradeFilterByWareTransport(menu.holomap, transport, count)
end

function menu.filterTradeWares(setting)
	local rawwarelist = menu.getFilterOption(setting.id) or {}
	local warelist = ffi.new("const char*[?]", #rawwarelist)
	for i, ware in ipairs(rawwarelist) do
		warelist[i - 1] = Helper.ffiNewString(ware)
	end
	if #rawwarelist > 0 then
		C.SetMapTradeFilterByWare(menu.holomap, warelist, #rawwarelist)
	else
		C.ClearMapTradeFilterByWare(menu.holomap)
	end
	menu.refreshMainFrame = true
end

function menu.filterTradePrice(setting)
	for _, option in ipairs(setting) do
		local value = menu.getFilterOption(option.id) or false
		if option.param == "maxprice" then
			C.SetMapTradeFilterByMaxPrice(menu.holomap, value)
		end
	end
end

function menu.filterTradeOffer(setting)
	for _, option in ipairs(setting) do
		local value = menu.getFilterOption(option.id) or false
		if option.param == "number" then
			C.SetMapTopTradesCount(menu.holomap, value)
		end
	end
end

function menu.filterTradeVolume(setting, override)
	for _, option in ipairs(setting) do
		if option.param == "volume" then
			local value = override
			if value == nil then
				value = menu.getFilterOption(option.id) or false
			end
			if value == 0 then
				C.ClearMapTradeFilterByMinTotalVolume(menu.holomap)
			else
				C.SetMapTradeFilterByMinTotalVolume(menu.holomap, value)
			end
		end
	end
	menu.refreshInfoFrame()
end

function menu.filterThink(value)
	for _, setting in ipairs(config.layersettings["layer_think"]) do
		if value then
			setting.callback(setting)
		else
			setting.callback(setting, false)
		end
	end
end

function menu.filterThinkAlert(setting, override)
	for _, option in ipairs(setting) do
		local value = override
		if value == nil then
			value = menu.getFilterOption(option.id) or false
		end
		if option.param == "alert" then
			C.SetMapAlertFilter(menu.holomap, value)
		end
	end
	menu.refreshInfoFrame()
end

function menu.filterMining(value)
	for _, setting in ipairs(config.layersettings["layer_mining"]) do
		if value then
			setting.callback(setting)
		else
			setting.callback(setting, false)
		end
	end
end

function menu.filterMiningResources(setting, override)
	for _, option in ipairs(setting) do
		local value = override
		if value == nil then
			value = menu.getFilterOption(option.id) or false
		end
		if option.param == "display" then
			C.SetMapRenderResourceInfo(menu.holomap, value)
		end
	end
end

function menu.filterOther(value)
	for _, setting in ipairs(config.layersettings["layer_other"]) do
		if value then
			setting.callback(setting)
		else
			setting.callback(setting, false)
		end
	end
end

function menu.filterOtherStation(setting, override)
	for _, option in ipairs(setting) do
		local value = override
		if value == nil then
			value = menu.getFilterOption(option.id) or false
		end
		if option.param == "cargo" then
			C.SetMapRenderCargoContents(menu.holomap, value)
		elseif option.param == "missions" then
			C.SetMapRenderMissionOffers(menu.holomap, value)
		elseif option.param == "workforce" then
			C.SetMapRenderWorkForceInfo(menu.holomap, value)
		elseif option.param == "dockedships" then
			C.SetMapRenderDockedShipInfos(menu.holomap, value)
		elseif option.param == "civilian" then
			C.SetMapRenderCivilianShips(menu.holomap, value)
		end
	end
end

function menu.filterOtherShip(setting, override)
	for _, option in ipairs(setting) do
		local value = override
		if value == nil then
			value = menu.getFilterOption(option.id) or false
		end
		if option.param == "orderqueue" then
			C.SetMapRenderAllOrderQueues(menu.holomap, value)
		elseif option.param == "crew" then
			C.SetMapRenderCrewInfo(menu.holomap, value)
		end
	end
end

function menu.filterOtherMisc(setting, override)
	for _, option in ipairs(setting) do
		local value = override
		if value == nil then
			value = menu.getFilterOption(option.id) or false
		end
		if option.param == "ecliptic" then
			C.SetMapRenderEclipticLines(menu.holomap, value)
		end
	end
end

-- menu display
function menu.onShowMenu(state)
	-- Init variables
	menu.borderOffset = Helper.frameBorder
	menu.sellShipsWidth = Helper.scaleX(300)
	menu.selectWidth = Helper.scaleX(250)
	menu.searchtext = {}

	-- Handle menu parameters
	menu.importMenuParameters()
	if state then
		menu.onRestoreState(state)
	end


	-- main frame
	menu.editboxHeight = math.max(23, Helper.scaleY(Helper.standardTextHeight))

	menu.sideBarWidth = Helper.scaleX(Helper.sidebarWidth)
	menu.playerInfo = {
		width = 0.3 * Helper.viewWidth,
		height = 3 * (Helper.scaleY(Helper.standardTextHeight) + Helper.borderSize),
		offsetX = menu.borderOffset,
		offsetY = menu.borderOffset,
		fontsize = Helper.scaleFont(Helper.standardFont, Helper.standardFontSize),
	}
	menu.sideBarOffsetX = menu.borderOffset
	menu.sideBarOffsetY = menu.playerInfo.offsetY + menu.playerInfo.height + menu.borderOffset / 2 + menu.sideBarWidth / 2

	-- infoTable
	menu.infoTableWidth = menu.playerInfo.width - menu.sideBarWidth - 2 * Helper.borderSize
	menu.infoTableOffsetX = menu.sideBarOffsetX + menu.sideBarWidth + 2 * Helper.borderSize
	menu.infoTableOffsetY = menu.playerInfo.offsetY + menu.playerInfo.height + menu.borderOffset / 2

	-- searchfield
	menu.searchFieldData = {
		width = menu.playerInfo.width - menu.sideBarWidth - 2 * Helper.borderSize,
		offsetX = Helper.viewWidth - menu.playerInfo.width - menu.borderOffset,
		offsetY = menu.borderOffset,
	}

	-- map
	menu.rendertargetWidth = Helper.viewWidth
	menu.rendertargetHeight = Helper.viewHeight

	-- selected ships
	menu.selectedShipsTableData = {
		height = Helper.scaleY(20),
		width = Helper.scaleX(50),
		maxCols = 6,
		fontsize = Helper.scaleFont(Helper.standardFont, Helper.standardFontSize),
	}

	Helper.setTabScrollCallback(menu, menu.onTabScroll)
	registerForEvent("inputModeChanged", getElement("Scene.UIContract"), menu.onInputModeChanged)

	menu.sound_ambient = StartPlayingSound("ui_map_ambient")
	menu.displayMenu(true)

	Helper.setKeyBinding(menu, menu.hotkey)
end

function menu.onMinimizeMenu()
	UnregisterAddonBindings("ego_detailmonitor")
	UnregisterEvent("updateHolomap", menu.updateHolomap)
	UnregisterEvent("info_updatePeople", menu.infoUpdatePeople)
	if menu.holomap ~= 0 then
		menu.mapstate = ffi.new("HoloMapState")
		C.GetMapState(menu.holomap, menu.mapstate)
		C.RemoveHoloMap()
		menu.holomap = 0
	end
end

function menu.onRestoreMenu()
	if not menu.sound_ambient then
		menu.sound_ambient = StartPlayingSound("ui_map_ambient")
	end
	menu.displayMenu()
end

function menu.onSaveState()
	local state = {}

	if menu.holomap ~= 0 then
		local mapstate = ffi.new("HoloMapState")
		C.GetMapState(menu.holomap, mapstate)
		state.map = { offset = { x = mapstate.offset.x, y = mapstate.offset.y, z = mapstate.offset.z, yaw = mapstate.offset.yaw, pitch = mapstate.offset.pitch, roll = mapstate.offset.roll,}, cameradistance = mapstate.cameradistance }
	end

	for _, key in ipairs(config.stateKeys) do
		state[key[1]] = menu[key[1]]
	end
	return state
end

function menu.onRestoreState(state)
	if state.map then
		local offset = ffi.new("UIPosRot", {
			x = state.map.offset.x, 
			y = state.map.offset.y, 
			z = state.map.offset.z, 
			yaw = state.map.offset.yaw, 
			pitch = state.map.offset.pitch, 
			roll = state.map.offset.roll
		})
		menu.mapstate = ffi.new("HoloMapState", {
			offset = offset, 
			cameradistance = state.map.cameradistance
		})
	end

	for _, key in ipairs(config.stateKeys) do
		if key[2] == "UniverseID" then
			menu[key[1]] = ConvertIDTo64Bit(state[key[1]])
		else
			menu[key[1]] = state[key[1]]
		end
	end
end

function menu.displayMenu(firsttime)
	-- register lua events
	RegisterEvent("updateHolomap", menu.updateHolomap)
	RegisterEvent("info_updatePeople", menu.infoUpdatePeople)

	-- Register bindings
	RegisterAddonBindings("ego_detailmonitor", "map")
	RegisterAddonBindings("ego_detailmonitor", "comm")
	RegisterAddonBindings("ego_detailmonitor", "autopilot")
	RegisterAddonBindings("ego_detailmonitor", "undo")

	menu.selectedcomponents = {}
	menu.renderedComponents = {}

	menu.prepareColors()
	menu.prepareEconomyWares()

	-- create frames
	menu.topRows = {}
	menu.selectedRows = {}
	menu.selectedCols = {}
	menu.activatemap = nil
	local curtime = getElapsedTime()
	menu.lastupdatetime = curtime
	menu.lastrefresh = curtime
	menu.lastHighlightCheck = curtime

	if menu.mode == "infomode" then
		menu.infoTableMode = menu.modeparam[1]

		if menu.infoTableMode == "info" then
			menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(menu.modeparam[2]))
			if menu.infoMode == "objectinfo" then
				if menu.modeparam[3] then
					menu.extendedinfo = {}
					for _, loccategory in ipairs(menu.modeparam[3]) do
						menu.extendedinfo[loccategory] = true
					end
				end
			end
		elseif menu.infoTableMode == "mission" then
			if menu.modeparam[2] then
				menu.missionMode = menu.modeparam[2]
			end
			if menu.modeparam[3] then
				menu.missionModeCurrent = menu.modeparam[3]
			end
		end

		menu.mode = nil
		menu.modeparam = {}
	elseif menu.mode == "hire" then
		menu.infoTableMode = "propertyowned"
		menu.searchTableMode = "hire"
	elseif menu.mode == "sellships" then
		local ships = {}
		for _, ship in ipairs(menu.modeparam[2]) do
			table.insert(ships, ConvertIDTo64Bit(ship))
		end
		menu.contextMenuData = { shipyard = ConvertIDTo64Bit(menu.modeparam[1]), ships = ships, xoffset = menu.modeparam[3], yoffset = menu.modeparam[4] }
		menu.contextMenuMode = "sellships"
		menu.createContextFrame(menu.sellShipsWidth)
	elseif menu.mode == "selectCV" then
		menu.infoTableMode = "objectlist"
		table.insert(menu.searchtext, { text = ReadText(1014, 803), blockRemove = true })
		menu.layerBackup = {}
		for _, entry in ipairs(config.layers) do
			local oldvalue = __CORE_DETAILMONITOR_MAPFILTER[entry.mode]
			__CORE_DETAILMONITOR_MAPFILTER[entry.mode] = false
			menu.layerBackup[entry.mode] = oldvalue
		end
	end
	
	if menu.mode == "tradecontext" then
		local shadyOnly = false
		if menu.modeparam[4] then
			shadyOnly = menu.modeparam[4] ~= 0
		end

		menu.contextMenuMode = "trade"
		menu.contextMenuData = { component = ConvertIDTo64Bit(menu.modeparam[1]), currentShip = ConvertIDTo64Bit(menu.modeparam[2]), shadyOnly = shadyOnly, orders = {}, xoffset = Helper.viewWidth / 2 - config.tradeContextMenuWidth / 2, yoffset = Helper.frameBorder, wareexchange = wareexchange }

		local numwarerows, numinforows = menu.initTradeContextData()
		menu.updateTradeContextDimensions(numwarerows, numinforows)

		if menu.contextMenuData.xoffset + menu.tradeContext.width > Helper.viewWidth then
			menu.contextMenuData.xoffset = Helper.viewWidth - menu.tradeContext.width - config.contextBorder
		end
		menu.contextMenuData.tradeModeHeight = menu.tradeContext.shipheight + menu.tradeContext.buttonheight + 1 * Helper.borderSize
		if menu.contextMenuData.yoffset + menu.contextMenuData.tradeModeHeight > Helper.viewHeight then
			menu.contextMenuData.yoffset = Helper.viewHeight - menu.contextMenuData.tradeModeHeight - config.contextBorder
		end

		menu.createMainFrame(nil, menu.contextMenuData.tradeModeHeight)

		menu.contextMenuData.yoffset = menu.contextMenuData.yoffset + menu.topLevelHeight
		menu.createContextFrame(menu.tradeContext.width, menu.contextMenuData.tradeModeHeight, menu.contextMenuData.xoffset, menu.contextMenuData.yoffset)
	elseif menu.mode == "boardingcontext" then
		-- accessing boarding menu from outside the map
		local width = Helper.viewWidth * 0.6
		local height = Helper.viewHeight * 0.7
		local xoffset = Helper.viewWidth * 0.2
		local yoffset = Helper.viewHeight * 0.15
		menu.closemapwithmenu = true
		menu.contextMenuMode = "boardingcontext"
		menu.contextMenuData = { target = menu.modeparam[1], boarders = menu.modeparam[2] }
		menu.createContextFrame(width, height, xoffset, yoffset)
	else
		menu.createMainFrame(firsttime)

		if firsttime then
			AddUITriggeredEvent(menu.name, menu.infoTableMode)
		end
		menu.createInfoFrame()
	end
end

-- create main frame (sideBar, navBar, map)
function menu.createMainFrame(firsttime, height)
	menu.createMainFrameRunning = true
	-- remove old data
	Helper.removeAllWidgetScripts(menu, config.mainFrameLayer)

	menu.mainFrame = Helper.createFrameHandle(menu, {
		layer = config.mainFrameLayer,
		standardButtons = { back = true, close = true, minimize = (not menu.conversationMenu) },
		width = Helper.viewWidth,
		height = Helper.viewHeight,
		x = 0,
		y = 0,
	})

	-- player info
	menu.createPlayerInfo(menu.mainFrame, menu.playerInfo.width, menu.playerInfo.height, menu.playerInfo.offsetX, menu.playerInfo.offsetY)
	if menu.mode ~= "tradecontext" then
		-- search field
		menu.createSearchField(menu.mainFrame, menu.searchFieldData.width, 0, menu.searchFieldData.offsetX, menu.searchFieldData.offsetY)
		-- sideBar
		menu.createSideBar(firsttime, menu.mainFrame, menu.sideBarWidth, 0, menu.sideBarOffsetX, menu.sideBarOffsetY)
		-- rightBar
		menu.createRightBar(menu.mainFrame, menu.sideBarWidth, 0, Helper.viewWidth - menu.sideBarWidth - menu.borderOffset, menu.searchFieldData.offsetY)
		-- selected ships
		menu.createSelectedShips(menu.mainFrame)
	end
	-- top level
	menu.createTopLevel(menu.mainFrame)
	if menu.mode ~= "tradecontext" then
		-- map
		menu.mainFrame:addRenderTarget({width = menu.rendertargetWidth, height = menu.rendertargetHeight, x = 0, y = 0, scaling = false, alpha = 98})
	end

	if menu.mode == "tradecontext" then
		menu.mainFrame.properties.backgroundID = "solid"
		menu.mainFrame.properties.backgroundColor = Helper.color.semitransparent
		if height then
			menu.mainFrame.properties.height = height + menu.topLevelHeight + 2 * Helper.frameBorder
		end
	end

	menu.mainFrame:display()
end

-- (re)create info frame (infoTable)
function menu.createInfoFrame()
	menu.createInfoFrameRunning = true
	menu.refreshed = true
	menu.noupdate = false

	-- remove old data
	Helper.clearDataForRefresh(menu, config.infoFrameLayer)

	menu.emptyFontStringSmall = Helper.createFontString("", false, Helper.standardHalignment, Helper.standardColor.r, Helper.standardColor.g, Helper.standardColor.b, Helper.standardColor.a, Helper.standardFont, 1, false, Helper.headerRow1Offsetx, Helper.headerRow1Offsety, 2)

	-- infoTable
	local infoTableHeight = Helper.viewHeight - menu.infoTableOffsetY - menu.borderOffset

	menu.infoFrame = Helper.createFrameHandle(menu, {
		x = menu.infoTableOffsetX,
		y = menu.infoTableOffsetY,
		width = menu.infoTableWidth,
		height = infoTableHeight,
		layer = config.infoFrameLayer,
		backgroundID = "solid",
		backgroundColor = Helper.color.semitransparent,
		standardButtons = {},
		showBrackets = false,
		autoFrameHeight = true
	})

	menu.autopilottarget = GetAutoPilotTarget()
	menu.softtarget = C.GetSofttarget().softtargetID
	menu.populateUpkeepMissionData()

	if menu.infoTableMode ~= "info" and menu.mode ~= "orderparam_object" then
		menu.infoSubmenuObject = nil
		menu.infocashtransferdetails = nil
		menu.infodrops = {}
		menu.infocrew.object = nil
		menu.infomacrostolaunch = {}
	end

	if menu.contextMenuMode ~= "trade" then
		if (menu.infoTableMode ~= "info") and (menu.infoTableMode ~= "missionoffer") and (menu.infoTableMode ~= "mission") then
			if not menu.arrowsRegistered then
				RegisterAddonBindings("ego_detailmonitor", "map_arrows")
				menu.arrowsRegistered = true
			end
		else
			if menu.arrowsRegistered then
				UnregisterAddonBindings("ego_detailmonitor", "map_arrows")
				menu.arrowsRegistered = nil
			end
		end
	end

	if menu.holomap ~= 0 then
		if menu.infoTableMode then
			C.SetMapStationInfoBoxMargin(menu.holomap, "left", menu.infoTableOffsetX + menu.infoTableWidth + config.contextBorder)
		else
			C.SetMapStationInfoBoxMargin(menu.holomap, "left", 0)
		end
	end

	local infotabledesc, infotabledesc2
	menu.infoTableData = {}
	if menu.infoTableMode == "objectlist" then
		infotabledesc, infotabledesc2 = menu.createObjectList(menu.infoFrame)
	elseif menu.infoTableMode == "propertyowned" then
		infotabledesc = menu.createPropertyOwned(menu.infoFrame)
	elseif menu.infoTableMode == "plots" then
		menu.createPlotMode(menu.infoFrame)
	elseif menu.infoTableMode == "info" then
		if menu.infoMode == "objectinfo" then
			menu.infoFrame.properties.autoFrameHeight = false
			menu.createInfoSubmenu(menu.infoFrame)
		elseif menu.infoMode == "factionresponses" or menu.infoMode == "controllableresponses" then
			menu.createOrdersMenu(menu.infoFrame, menu.infoMode)
		elseif menu.infoMode == "orderqueue" then
			menu.createOrderQueue(menu.infoFrame, menu.infoMode)
		elseif menu.infoMode == "orderqueue_advanced" then
			menu.createOrderQueue(menu.infoFrame, menu.infoMode)
		end
	elseif menu.infoTableMode == "missionoffer" then
		menu.createMissionMode(menu.infoFrame)
	elseif menu.infoTableMode == "mission" then
		menu.createMissionMode(menu.infoFrame)
	elseif menu.infoTableMode == "cheats" then
		menu.createCheats(menu.infoframe)
	else
		-- empty
		menu.infoFrame.properties.backgroundID = ""
		menu.infoFrame.properties.showBrackets = false
		menu.infoFrame.properties.autoFrameHeight = false
		menu.infoFrame:addTable(0)
	end

	if menu.infoFrame then
		menu.infoFrame:display()
	else
		-- create legacy info frame
		-- NOTE: descriptor table is {infotabledesc} if infotabledesc2 == nil
		Helper.displayFrame(menu, {infotabledesc, infotabledesc2}, false, "solid", "", {}, nil, config.infoFrameLayer, Helper.color.semitransparent, nil, false, true, nil, nil, menu.infoTableWidth, infoTableHeight, menu.infoTableOffsetX, menu.infoTableOffsetY)
	end

	if menu.holomap and (menu.holomap ~= 0) then
		menu.setSelectedMapComponents()
	end
end

-- create context frame
function menu.createContextFrame(width, height, xoffset, yoffset)
	PlaySound("ui_positive_click")
	Helper.removeAllWidgetScripts(menu, config.contextFrameLayer)

	menu.contextMenuData = menu.contextMenuData or {}
	if width then
		menu.contextMenuData.width = width
	end
	if height then
		menu.contextMenuData.height = height
	end
	if xoffset then
		menu.contextMenuData.xoffset = xoffset
	end
	if yoffset then
		menu.contextMenuData.yoffset = yoffset
	end

	local frameData
	if menu.contextMenuData.height then
		frameData = {width = menu.contextMenuData.width + 2 * Helper.borderSize, height = menu.contextMenuData.height + 2 * Helper.borderSize, x = menu.contextMenuData.xoffset - Helper.borderSize, y = menu.contextMenuData.yoffset - Helper.borderSize}
	end

	menu.contextFrame = Helper.createFrameHandle(menu, {
		x = menu.contextMenuData.xoffset - 2 * Helper.borderSize,
		y = menu.contextMenuData.yoffset,
		width = menu.contextMenuData.width + 2 * Helper.borderSize,
		layer = config.contextFrameLayer,
		backgroundID = "solid",
		backgroundColor = Helper.color.semitransparent,
		standardButtons = { close = true },
	})

	if menu.contextMenuMode == "neworder" then
		menu.createNewOrderContext(menu.contextFrame)
	elseif menu.contextMenuMode == "set_orderparam_ware" then
		menu.createOrderparamWareContext(menu.contextFrame)
	elseif menu.contextMenuMode == "set_orderparam_formationshape" then
		menu.createOrderparamFormationShapeContext(menu.contextFrame)
	elseif menu.contextMenuMode == "trade" then
		menu.contextFrame = nil
		menu.createTradeContext(frameData, menu.contextMenuData.width + menu.tradeContext.widthcorrection, menu.contextMenuData.height, Helper.borderSize, Helper.borderSize)
	elseif menu.contextMenuMode == "mission" then
		menu.createMissionContext(menu.contextFrame)
	elseif menu.contextMenuMode == "boardingcontext" then
		menu.oldmode = menu.mode
		menu.mode = "boardingcontext"
		menu.oldInfoTableMode = menu.infoTableMode
		menu.infoTableMode = nil
		menu.refreshInfoFrame()
		menu.createBoardingContext(menu.contextFrame, menu.contextMenuData.target, menu.contextMenuData.boarders)
	elseif menu.contextMenuMode == "weaponconfig" then
		menu.createWeaponConfigContext(menu.contextFrame)
	elseif menu.contextMenuMode == "sellships" then
		menu.createSellShipsContext(menu.contextFrame)
	elseif menu.contextMenuMode == "select" then
		menu.createSelectContext(menu.contextFrame)
	elseif menu.contextMenuMode == "info_actor" then
		menu.createInfoActorContext(menu.contextFrame)
	end
	
	if menu.contextFrame then
		-- only add one border as the table y offset already is part of frame:getUsedHeight()
		menu.contextFrame.properties.height = menu.contextFrame:getUsedHeight() + Helper.borderSize
		menu.contextFrame:display()
	elseif frameData == nil then
		DebugError("Context menu without height specified, but MWT frame was deleted. [Florian]")
	end
end

-- handle created frames
function menu.viewCreated(layer, ...)
	if layer == config.mainFrameLayer then
		if menu.mode ~= "tradecontext" then
			menu.playerInfoTable, menu.searchField, menu.sideBar, menu.rightBar, menu.selectedShipsTable, menu.topLevel, menu.map = ...

			if menu.activatemap == nil then
				menu.activatemap = true
			end
		else
			menu.playerInfoTable, menu.topLevel = ...
		end
		menu.createMainFrameRunning = false
	elseif layer == config.infoFrameLayer then
		menu.infoTable, menu.infoTable2, menu.infoTable3 = ...
		
		menu.createInfoFrameRunning = false
	elseif layer == config.contextFrameLayer then
		if menu.contextMenuMode == "neworder" then
			menu.contexttable = ...
		elseif menu.contextMenuMode == "set_orderparam_ware" then
			menu.contexttable = ...
		elseif menu.contextMenuMode == "set_orderparam_formationshape" then
			menu.contexttable = ...
		elseif menu.contextMenuMode == "trade" then
			menu.contextshiptable, menu.contextbuttontable = ...

			C.SetTableNextConnectedTable(menu.contextshiptable, menu.contextbuttontable);
			C.SetTablePreviousConnectedTable(menu.contextbuttontable, menu.contextshiptable);

			menu.setupTradeContextScripts(menu.contextshiptable, menu.contextbuttontable)
		elseif menu.contextMenuMode == "mission" then
			menu.contextdesctable, menu.contextobjectivetable, menu.contextbottomtable = ...

			if menu.contextMenuData.isoffer then
				RegisterEvent("missionofferremoved", menu.onMissionOfferRemoved)
			else
				RegisterEvent("missionremoved", menu.onMissionRemoved)
			end
		elseif menu.contextMenuMode == "weaponconfig" then
			menu.contexttable = ...
		elseif menu.contextMenuMode == "sellships" then
			menu.contexttable = ...
		elseif menu.contextMenuMode == "select" then
			menu.contexttable = ...
		end
	end

	-- clear descriptors again
	Helper.releaseDescriptors()
end

function menu.refreshContextFrame()
	Helper.removeAllWidgetScripts(menu, menu.contextFrameLayer)

	menu.contextFrame = Helper.createFrameHandle(menu, {
		x = menu.contextMenuData.xoffset - 2 * Helper.borderSize,
		y = menu.contextMenuData.yoffset,
		width = menu.contextMenuData.width + 2 * Helper.borderSize,
		layer = config.contextFrameLayer,
		backgroundID = "solid",
		backgroundColor = Helper.color.semitransparent,
		standardButtons = { close = true },
	})

	if menu.contextMenuMode == "boardingcontext" then
		menu.contexttoprow = GetTopRow(menu.boardingtable_shipselection.id)
		menu.contextselectedrow = Helper.currentTableRow[menu.boardingtable_shipselection.id]

		menu.createBoardingContext(menu.contextFrame, menu.contextMenuData.target, menu.contextMenuData.boarders)
	end

	if menu.contextFrame then
		-- only add one border as the table y offset already is part of frame:getUsedHeight()
		menu.contextFrame.properties.height = menu.contextFrame:getUsedHeight() + Helper.borderSize
		menu.contextFrame:display()
	end
end

function menu.refreshInfoFrame(setrow, setcol)
	if menu.mode == "tradecontext" then
		return
	end
	if not menu.createInfoFrameRunning then
		menu.settoprow = menu.settoprow or GetTopRow(menu.infoTable)
		if menu.setplottoprow then
			menu.settoprow = menu.setplottoprow
			menu.setplottoprow = nil
		end
		if (menu.infoTableMode ~= "objectlist") and (menu.infoTableMode ~= "propertyowned") then
			menu.setrow = setrow or Helper.currentTableRow[menu.infoTable]
			if menu.setplotrow then
				menu.setrow = menu.setplotrow
				menu.setplotrow = nil
			end
			menu.setcol = setcol or Helper.currentTableCol[menu.infoTable]
		end

		menu.selectedRows.infotable2 = nil
		if menu.infoTable2 then
			menu.selectedRows.infotable2 = Helper.currentTableRow[menu.infoTable2]
		end
		if menu.orderHeaderTable and menu.lastactivetable == menu.orderHeaderTable.id then
			menu.selectedRows.orderHeaderTable = Helper.currentTableRow[menu.orderHeaderTable.id] or 1
			menu.selectedCols.orderHeaderTable = Helper.currentTableCol[menu.orderHeaderTable.id]
		end
		menu.createInfoFrame()
	end
end

function menu.extendSectionAndRefresh(rowdata)
	menu.extendModuleType(rowdata[2], rowdata[3])
	menu.settoprow = GetTopRow(menu.infoTable)
	menu.updateMapAndInfoFrame()
end

function menu.getContainerNameAndColors(container, iteration, issquadleader, showScanLevel)
	local convertedContainer = ConvertIDTo64Bit(container)
	local isplayer = GetComponentData(container, "isplayerowned")
	local revealpercent = GetComponentData(container, "revealpercent")
	local unlocked = IsInfoUnlockedForPlayer(container, "name")

	local name = Helper.unlockInfo(unlocked, GetComponentData(container, "name") .. " (" .. ffi.string(C.GetObjectIDCode(convertedContainer)) .. ")") .. (((not showScanLevel) or isplayer) and "" or " (" .. revealpercent .. " %)")
	local font = Helper.standardFont
	local color = Helper.standardColor

	local bgcolor = issquadleader and Helper.defaultSimpleBackgroundColor or Helper.color.transparent
	if (menu.mode == "orderparam_object") and (not menu.checkForOrderParamObject(convertedContainer)) then
		bgcolor = menu.darkgrey
	elseif (menu.mode == "selectCV") and C.IsBuilderBusy(convertedContainer) then
		name = "\27R" .. ReadText(1001, 7943) .. "\27X - " .. name
		color = menu.grey
	end

	if not menu.mode then 
		if convertedContainer == menu.softtarget then
			name = config.softtargetmarker_l .. name
			font = Helper.standardFontBold
		end
		if IsSameComponent(menu.autopilottarget, container) then
			name = config.autopilotmarker .. name
		end
	end
	if IsComponentClass(container, "ship") then
		local iconid = GetComponentData(container, "icon")
		if iconid and iconid ~= "" then
			name = string.format("\027[%s] %s", iconid, name)
		end
	end
	local mouseover = "" --name
	for i = 1, iteration do
		name = "    " .. name
	end

	if GetComponentData(container, "ismissiontarget") then
		color = menu.holomapcolor.missioncolor
	elseif GetComponentData(container, "isonlineobject") then
		color = menu.holomapcolor.visitorcolor
	elseif not unlocked then
		color = menu.grey
	elseif isplayer then
		if convertedContainer == C.GetPlayerObjectID() then
			color = menu.holomapcolor.currentplayershipcolor
		else
			color = menu.holomapcolor.playercolor
		end
	elseif GetComponentData(container, "isenemy") then
		color = menu.holomapcolor.enemycolor
	end

	return name, color, bgcolor, font, mouseover
end

function menu.updateRenderedComponents()
	menu.renderedComponents = {}
	menu.renderedComponentsRef = {}
	if menu.holomap and (menu.holomap ~= 0) then
		Helper.ffiVLA(menu.renderedComponents, "UniverseID", C.GetNumMapRenderedComponents, C.GetMapRenderedComponents, menu.holomap)
		for i = #menu.renderedComponents, 1, -1 do
			local id = ConvertStringTo64Bit(tostring(menu.renderedComponents[i]))
			if IsValidComponent(id) then
				local ismasstraffic, isenemy = GetComponentData(id, "ismasstraffic", "isenemy")
				if ismasstraffic and (not isenemy) then
					table.remove(menu.renderedComponents, i)
				else
					menu.renderedComponentsRef[ConvertStringTo64Bit(tostring(id))] = true
				end
			else
				table.remove(menu.renderedComponents, i)
			end
		end

		-- make sure the holomap is up before using the focuscomponent to init selectedcomponents
		if #menu.renderedComponents > 0 then
			if menu.focuscomponent then
				menu.infoTable = nil
				menu.highlightedbordercomponent = nil
				menu.highlightedbordermoduletype = nil
				menu.highlightedplannedmodule = nil
				menu.highlightedbordersection = nil
				menu.highlightedborderstationcategory = nil
				menu.highlightedconstruction = nil
				if menu.selectfocuscomponent then
					menu.addSelectedComponent(menu.focuscomponent)
					menu.selectfocuscomponent = nil
				end
				menu.focuscomponent = nil
			end
		end
	end

	-- Always show target component
	local softtarget = C.GetSofttarget().softtargetID
	if softtarget ~= 0 then
		if not menu.renderedComponentsRef[ConvertStringTo64Bit(tostring(softtarget))] then
			table.insert(menu.renderedComponents, softtarget)
			menu.renderedComponentsRef[ConvertStringTo64Bit(tostring(softtarget))] = true
		end
	end

	-- Always show selected components
	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		if IsValidComponent(selectedcomponent) then
			if not menu.renderedComponentsRef[selectedcomponent] then
				table.insert(menu.renderedComponents, selectedcomponent)
				menu.renderedComponentsRef[selectedcomponent] = true
			end
		end
	end

	table.sort(menu.renderedComponents, Helper.sortUniverseIDName)
end

function menu.isObjectValid(object)
	if (menu.infoTableMode == "objectlist") and (menu.mode ~= "sellship") and C.IsComponentClass(object, "gate") then
		return true
	elseif not C.IsComponentClass(object, "ship") and not C.IsRealComponentClass(object, "station") then
		return false
	elseif (menu.mode == "sellship") and not (C.IsComponentClass(object, "ship") and GetComponentData(ConvertStringTo64Bit(tostring(object)), "issellable")) then
		return false
	elseif C.IsUnit(object) then
		return false
	elseif not C.IsObjectKnown(object) then
		return false
	end
	return true
end

-- Object List

function menu.createObjectList(frame)
	-- TODO: Move to config table?
	menu.infoTableData.maxIcons = 5
	menu.infoTableData.shipIconWidth = 26
	local maxicons = menu.infoTableData.maxIcons

	local objecttable = menu.infoFrame:addTable(5 + maxicons, { tabOrder = 1, multiSelect = true })
	objecttable:setDefaultCellProperties("text", { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize })
	objecttable:setDefaultCellProperties("button", { height = config.mapRowHeight })
	objecttable:setDefaultCellProperties("icon",   { height = config.mapRowHeight })
	objecttable:setDefaultComplexCellProperties("button", "text", { fontsize = config.mapFontSize })
	--  [+/-] [Object Name] [Top Level Shield/Hull Bar] [Location] [Sub_1] [Sub_2] [Sub_3] ... [Sub_N or Shield/Hull Bar]
	objecttable:setColWidth(1, Helper.scaleY(config.mapRowHeight), false)
	objecttable:setColWidthMinPercent(2, 20)
	objecttable:setColWidth(3, menu.infoTableData.shipIconWidth)
	objecttable:setColWidthMinPercent(4, 10)
	objecttable:setColWidth(5, menu.infoTableData.shipIconWidth)
	for i = 1, maxicons do
		objecttable:setColWidth(5 + i, menu.infoTableData.shipIconWidth)
	end
	objecttable:setDefaultBackgroundColSpan(2, 4 + maxicons)

	-- title section
	if menu.currentsector ~= 0 then	
		-- title
		menu.title = ReadText(20001, 201) .. ReadText(1001, 120) .. " " .. ffi.string(C.GetComponentName(menu.currentsector))
		menu.infoTableData.ownerDetails = C.GetOwnerDetails(menu.currentsector)

		if menu.mode == "orderparam_object" then
			local sectorallowed = false
			if menu.modeparam[2].inputparams.class then
				if type(menu.modeparam[2].inputparams.class) == "table" then
					for _, class in ipairs(menu.modeparam[2].inputparams.class) do
						if class == "sector" then
							sectorallowed = menu.checkForOrderParamObject(menu.currentsector)
							break
						end
					end
				else
					DebugError("Order parameter '" .. menu.modeparam[2].name .. "' - input parameter class is not a list. [Florian]")
				end
			end
			
			local row = objecttable:addRow(sectorallowed, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
			row[1]:setColSpan(3):createText(menu.title, Helper.headerRowCenteredProperties)
			row[4]:setColSpan(2 + maxicons):createButton({ active = sectorallowed, height = Helper.headerRow1Height, mouseOverText = ReadText(1001, 3228) }):setText(ReadText(1001, 14), { halign = "center" })
			row[4].handlers.onClick = menu.buttonSelectSector
		else
			local row = objecttable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
			row[1]:setColSpan(5 + maxicons):createText(menu.title, Helper.headerRowCenteredProperties)
		end

		-- owner
		if ffi.string(menu.infoTableData.ownerDetails.factionIcon) ~= "" then
			local locsectorname = ffi.string(menu.infoTableData.ownerDetails.factionName)
			if C.IsContestedSector(menu.currentsector) then
				locsectorname = locsectorname .. " " .. ReadText(1001, 3247)
			end
			
			local row = objecttable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
			row[1]:createIcon(ffi.string(menu.infoTableData.ownerDetails.factionIcon))
			row[2]:setColSpan(4 + maxicons):createText(locsectorname)
		end
	end

	-- object section
	menu.infoTableData.playerStations = { }
	menu.infoTableData.npcStations = { }
	menu.infoTableData.moduledata = { }
	menu.infoTableData.playerShips = { }
	menu.infoTableData.npcShips = { }
	menu.infoTableData.subordinates = { }
	menu.infoTableData.dockedships = { }
	menu.infoTableData.constructions = { }

	menu.updateRenderedComponents()
	for _, id in ipairs(menu.renderedComponents) do
		local convertedID = ConvertStringToLuaID(tostring(id))
		if menu.isObjectValid(id) then
			if menu.mode == "selectCV" then
				if C.IsComponentClass(id, "ship") and GetComponentData(convertedID, "primarypurpose") == "build" then
					if GetComponentData(convertedID, "isplayerowned") then
						table.insert(menu.infoTableData.playerShips, convertedID)
					else
						table.insert(menu.infoTableData.npcShips, convertedID)
					end
				end
			else
				if C.IsComponentClass(id, "ship") or C.IsRealComponentClass(id, "station") then
					-- Determine subordinates that may appear in the menu
					local subordinates = {}
					if C.IsComponentClass(id, "controllable") then
						subordinates = GetSubordinates(convertedID)
					end
					for i = #subordinates, 1, -1 do
						local subordinate = ConvertIDTo64Bit(subordinates[i])
						if not menu.isObjectValid(subordinate) then
							table.remove(subordinates, i)
						elseif menu.renderedComponentsRef[subordinate] then
							subordinates.hasRendered = true
						end
					end
					menu.infoTableData.subordinates[tostring(convertedID)] = subordinates

					local dockedships = {}
					if C.IsComponentClass(id, "container") then
						Helper.ffiVLA(dockedships, "UniverseID", C.GetNumDockedShips, C.GetDockedShips, id, nil)
					end
					for i = #dockedships, 1, -1 do
						local convertedID = ConvertStringToLuaID(tostring(dockedships[i]))
						local commander = GetCommander(convertedID)
						if (not commander) or (not menu.renderedComponentsRef[ConvertIDTo64Bit(commander)]) then
							dockedships[i] = convertedID
						else
							table.remove(dockedships, i)
						end
					end
					menu.infoTableData.dockedships[tostring(convertedID)] = dockedships

					if C.IsComponentClass(id, "ship") then
						local commander = GetCommander(convertedID)
						local isdocked = GetComponentData(convertedID, "isdocked")
						local dockcontainer = C.GetContextByClass(id, "container", false)
						if (not commander) or (not menu.renderedComponentsRef[ConvertIDTo64Bit(commander)]) then
							if (not isdocked) or (not menu.renderedComponentsRef[ConvertStringTo64Bit(tostring(dockcontainer))]) then
								if GetComponentData(convertedID, "isplayerowned") then
									table.insert(menu.infoTableData.playerShips, convertedID)
								else
									table.insert(menu.infoTableData.npcShips, convertedID)
								end
							end
						end
					elseif C.IsRealComponentClass(id, "station") then
						local isplayerowned = GetComponentData(convertedID, "isplayerowned")
						if isplayerowned then
							table.insert(menu.infoTableData.playerStations, convertedID)
						else
							table.insert(menu.infoTableData.npcStations, convertedID)
						end

						local modules = {}
						local n = C.GetNumStationModules(id, not isplayerowned, false)
						local buf = ffi.new("UniverseID[?]", n)
						n = C.GetStationModules(buf, n, id, not isplayerowned, false)
						for i = 0, n - 1 do
							local module = ConvertStringTo64Bit(tostring(buf[i]))
							local type = GetModuleType(module)
							if modules[type] then
								table.insert(modules[type], buf[i])
							else
								modules[type] = { buf[i] }
							end
						end
						if isplayerowned then
							local n = C.GetNumPlannedStationModules(id, false)
							local buf = ffi.new("UIConstructionPlanEntry[?]", n)
							n = C.GetPlannedStationModules(buf, n, id, false)
							for i = 0, tonumber(n) - 1 do
								local module, type
								if buf[i].componentid ~= 0 then
									module = ConvertStringTo64Bit(tostring(buf[i].componentid))
									type = GetModuleType(module)
								else
									module = ffi.string(buf[i].macroid)
									type = GetModuleType(nil, module)
								end
								if modules[type] then
									table.insert(modules[type], module)
								else
									modules[type] = { module }
								end
							end
						end
						menu.infoTableData.moduledata[tostring(convertedID)] = modules

						local constructions = {}
						-- builds in progress
						local n = C.GetNumBuildTasks(id, true, false)
						local buf = ffi.new("BuildTaskInfo[?]", n)
						n = C.GetBuildTasks(buf, n, id, true, false)
						for i = 0, n - 1 do
							table.insert(constructions, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = ffi.string(buf[i].factionid), buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = true })
						end
						-- other builds
						local n = C.GetNumBuildTasks(id, false, false)
						local buf = ffi.new("BuildTaskInfo[?]", n)
						n = C.GetBuildTasks(buf, n, id, false, false)
						for i = 0, n - 1 do
							table.insert(constructions, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = ffi.string(buf[i].factionid), buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = false })
						end
						menu.infoTableData.constructions[tostring(convertedID)] = constructions
					end
				end
			end
		end
	end

	-- TODO? if menu.mode ~= "sellship" then
	if menu.mode ~= "selectCV" then
		menu.createPropertySection("ownedstations", objecttable, ReadText(1001, 3276), menu.infoTableData.playerStations, "-- " .. ReadText(1001, 33) .. " --", true)
	end
	menu.createPropertySection("ownedships", objecttable, ReadText(1001, 8301), menu.infoTableData.playerShips, "-- " .. ReadText(1001, 34) .. " --")
	if menu.mode ~= "selectCV" then
		menu.createPropertySection("npcstations", objecttable, ReadText(1001,8302), menu.infoTableData.npcStations, "-- " .. ReadText(1001, 33) .. " --", true)
	end
	menu.createPropertySection("npcships", objecttable, ReadText(1001,8303), menu.infoTableData.npcShips, "-- " .. ReadText(1001, 34) .. " --")

	menu.numFixedRows = objecttable.numfixedrows

	menu.settoprow = ((not menu.settoprow) or (menu.settoprow == 0)) and ((menu.setrow and menu.setrow > 31) and (menu.setrow - 27) or 3) or menu.settoprow
	objecttable:setTopRow(menu.settoprow)
	if menu.infoTable then
		local result = GetShiftStartEndRow(menu.infoTable)
		if result then
			objecttable:setShiftStartEnd(table.unpack(result))
		end
	end
	objecttable:setSelectedRow(menu.sethighlightborderrow or menu.setrow)
	menu.setrow = nil
	menu.settoprow = nil
	menu.setcol = nil
	menu.sethighlightborderrow = nil
end

-- Property Owned

function menu.createPropertyOwned(frame)
	-- TODO: Move to config table?
	menu.infoTableData.maxIcons = 5
	menu.infoTableData.shipIconWidth = 26
	local maxicons = menu.infoTableData.maxIcons

	local ftable = menu.infoFrame:addTable(5 + maxicons, { tabOrder = 1, multiSelect = true })
	ftable:setDefaultCellProperties("text", { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize })
	ftable:setDefaultCellProperties("button", { height = config.mapRowHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = config.mapFontSize })

	--  [+/-] [Object Name] [Top Level Shield/Hull Bar] [Location] [Sub_1] [Sub_2] [Sub_3] ... [Sub_N or Shield/Hull Bar]
	ftable:setColWidth(1, Helper.scaleY(config.mapRowHeight), false)
	ftable:setDefaultBackgroundColSpan(2, 4 + maxicons)
	ftable:setColWidthMinPercent(2, 14)
	ftable:setColWidth(3, menu.infoTableData.shipIconWidth)
	ftable:setColWidthMinPercent(4, 10)
	ftable:setColWidth(5, 2.5 * menu.infoTableData.shipIconWidth)
	for i = 1, maxicons do
		ftable:setColWidth(5 + i, menu.infoTableData.shipIconWidth)
	end

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(5 + maxicons):createText(ReadText(1001, 1000), Helper.headerRowCenteredProperties)

	menu.infoTableData.stations = { }
	menu.infoTableData.fleetLeaderShips = { }
	menu.infoTableData.unassignedShips = { }
	menu.infoTableData.constructionShips = { }
	menu.infoTableData.subordinates = { }
	menu.infoTableData.dockedships = { }
	menu.infoTableData.constructions = { }
	menu.infoTableData.moduledata = { }

	local playerobjects = GetContainedObjectsByOwner("player")
	for _, object in ipairs(playerobjects) do
		local object64 = ConvertIDTo64Bit(object)
		if menu.isObjectValid(object64) then
			-- Determine subordinates that may appear in the menu
			local subordinates = {}
			if C.IsComponentClass(object64, "controllable") then
				subordinates = GetSubordinates(object)
			end
			for i = #subordinates, 1, -1 do
				local subordinate = subordinates[i]
				if not menu.isObjectValid(ConvertIDTo64Bit(subordinate)) then
					table.remove(subordinates, i)
				end
			end
			subordinates.hasRendered = #subordinates > 0
			menu.infoTableData.subordinates[tostring(object)] = subordinates
			-- Find docked ships
			local dockedships = {}
			if C.IsComponentClass(object64, "container") then
				Helper.ffiVLA(dockedships, "UniverseID", C.GetNumDockedShips, C.GetDockedShips, object64, nil)
			end
			for i = #dockedships, 1, -1 do
				local convertedID = ConvertStringToLuaID(tostring(dockedships[i]))
				local loccommander = GetCommander(convertedID)
				if (not loccommander) or (not menu.renderedComponentsRef[ConvertIDTo64Bit(loccommander)]) then
					dockedships[i] = convertedID
				else
					table.remove(dockedships, i)
				end
			end
			menu.infoTableData.dockedships[tostring(object)] = dockedships
			-- Check if object is station, fleet leader or unassigned
			local commander
			if C.IsComponentClass(object64, "controllable") then
				commander = GetCommander(object)
			end
			if not commander then
				if C.IsRealComponentClass(object64, "station") then
					table.insert(menu.infoTableData.stations, object)
				elseif #subordinates > 0 then
					table.insert(menu.infoTableData.fleetLeaderShips, object)
				else
					table.insert(menu.infoTableData.unassignedShips, object)
				end
			end

			if C.IsRealComponentClass(object64, "station") then
				local modules = {}
				local n = C.GetNumStationModules(object64, false, false)
				local buf = ffi.new("UniverseID[?]", n)
				n = C.GetStationModules(buf, n, object64, false, false)
				for i = 0, n - 1 do
					local module = ConvertStringTo64Bit(tostring(buf[i]))
					local type = GetModuleType(module)
					if modules[type] then
						table.insert(modules[type], buf[i])
					else
						modules[type] = { buf[i] }
					end
				end
				local n = C.GetNumPlannedStationModules(object64, false)
				local buf = ffi.new("UIConstructionPlanEntry[?]", n)
				n = C.GetPlannedStationModules(buf, n, object64, false)
				for i = 0, tonumber(n) - 1 do
					local module, type
					if buf[i].componentid ~= 0 then
						module = ConvertStringTo64Bit(tostring(buf[i].componentid))
						type = GetModuleType(module)
					else
						module = ffi.string(buf[i].macroid)
						type = GetModuleType(nil, module)
					end
					if modules[type] then
						table.insert(modules[type], module)
					else
						modules[type] = { module }
					end
				end
				menu.infoTableData.moduledata[tostring(object)] = modules

				local constructions = {}
				-- builds in progress
				local n = C.GetNumBuildTasks(object64, true, false)
				local buf = ffi.new("BuildTaskInfo[?]", n)
				n = C.GetBuildTasks(buf, n, object64, true, false)
				for i = 0, n - 1 do
					table.insert(constructions, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = ffi.string(buf[i].factionid), buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = true })
				end
				-- other builds
				local n = C.GetNumBuildTasks(object64, false, false)
				local buf = ffi.new("BuildTaskInfo[?]", n)
				n = C.GetBuildTasks(buf, n, object64, false, false)
				for i = 0, n - 1 do
					table.insert(constructions, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = ffi.string(buf[i].factionid), buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = false })
				end
				menu.infoTableData.constructions[tostring(object)] = constructions
			end
		end
	end

	local n = C.GetNumPlayerShipBuildTasks(true, false)
	local buf = ffi.new("BuildTaskInfo[?]", n)
	n = C.GetPlayerShipBuildTasks(buf, n, true, false)
	for i = 0, n - 1 do
		local factionid = ffi.string(buf[i].factionid)
		if factionid == "player" then
			table.insert(menu.infoTableData.constructionShips, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = factionid, buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = true })
		end
	end
	local n = C.GetNumPlayerShipBuildTasks(false, false)
	local buf = ffi.new("BuildTaskInfo[?]", n)
	n = C.GetPlayerShipBuildTasks(buf, n, false, false)
	for i = 0, n - 1 do
		local factionid = ffi.string(buf[i].factionid)
		if factionid == "player" then
			table.insert(menu.infoTableData.constructionShips, { id = buf[i].id, buildingcontainer = buf[i].buildingcontainer, component = buf[i].component, macro = ffi.string(buf[i].macro), factionid = factionid, buildercomponent = buf[i].buildercomponent, price = buf[i].price, ismissingresources = buf[i].ismissingresources, queueposition = buf[i].queueposition, inprogress = false })
		end
	end

	-- TODO? if menu.mode ~= "sellship" then
	if menu.mode ~= "selectCV" then
		menu.createPropertySection("ownedstations", ftable, ReadText(1001, 4), menu.infoTableData.stations, "-- " .. ReadText(1001, 33) .. " --", true)
	end
	menu.createPropertySection("ownedfleets", ftable, ReadText(1001, 8326), menu.infoTableData.fleetLeaderShips, "-- " .. ReadText(1001, 34) .. " --")			-- {1001,8326} = Fleets
	menu.createPropertySection("ownedships", ftable, ReadText(1001, 8327), menu.infoTableData.unassignedShips, "-- " .. ReadText(1001, 34) .. " --")	-- {1001,8327} = Unassigned Ships
	menu.createConstructionSection("constructionships", ftable, ReadText(1001, 8328), menu.infoTableData.constructionShips)

	menu.numFixedRows = ftable.numfixedrows

	ftable:setTopRow(menu.settoprow)
	if menu.infoTable then
		local result = GetShiftStartEndRow(menu.infoTable)
		if result then
			ftable:setShiftStartEnd(table.unpack(result))
		end
	end
	ftable:setSelectedRow(menu.sethighlightborderrow or menu.setrow)
	menu.setrow = nil
	menu.settoprow = nil
	menu.setcol = nil
	menu.sethighlightborderrow = nil
end

function menu.createPropertySection(id, ftable, name, array, nonetext, showmodules)
	local maxicons = menu.infoTableData.maxIcons

	local row = ftable:addRow(false)
	row[1]:setColSpan(5 + maxicons):createText(name, Helper.headerRowCenteredProperties)

	if id == menu.highlightedbordersection then
		menu.sethighlightborderrow = row.index + 1
	end

	if #array > 0 then
		for _, component in ipairs(array) do
			menu.createPropertyRow(ftable, component, 0, nil, showmodules)
		end
	else
		row = ftable:addRow(id, { bgColor = Helper.color.transparent })
		row[2]:setColSpan(4 + maxicons):createText(nonetext)
	end
end

function menu.getOrderInfo(ship)
	if not GetComponentData(ship, "isplayerowned") then
		return
	end

	local waiticon = ""
	local orderdefinition = ffi.new("OrderDefinition")
	if C.GetOrderDefinition(orderdefinition, "Wait") then
		waiticon = ffi.string(orderdefinition.icon)
	end

	local orders, defaultorder = {}, {}
	local n = C.GetNumOrders(ship)
	local buf = ffi.new("Order[?]", n)
	n = C.GetOrders(buf, n, ship)
	for i = 0, n - 1 do
		local order = {}
		order.state = ffi.string(buf[i].state)
		order.statename = ffi.string(buf[i].statename)
		order.orderdef = ffi.string(buf[i].orderdef)
		order.actualparams = tonumber(buf[i].actualparams)
		order.enabled = buf[i].enabled
		order.isinfinite = buf[i].isinfinite
		order.issyncpointreached = buf[i].issyncpointreached
		order.istemporder = buf[i].istemporder

		local orderdefinition = ffi.new("OrderDefinition")
		if order.orderdef ~= nil and C.GetOrderDefinition(orderdefinition, order.orderdef) then
			order.orderdef = {}
			order.orderdef.id = ffi.string(orderdefinition.id)
			order.orderdef.icon = ffi.string(orderdefinition.icon)
		else
			order.orderdef = { id = "", icon = "" }
		end

		table.insert(orders, order)
	end

	local hasrealorders = false
	for _, order in ipairs(orders) do
		if order.enabled and (not order.istemporder) then
			hasrealorders = true
			break
		end
	end
	
	local buf = ffi.new("Order")
	if C.GetDefaultOrder(buf, ship) then
		defaultorder.state = ffi.string(buf.state)
		defaultorder.statename = ffi.string(buf.statename)
		defaultorder.orderdef = ffi.string(buf.orderdef)
		defaultorder.actualparams = tonumber(buf.actualparams)
		defaultorder.enabled = buf.enabled
		defaultorder.issyncpointreached = buf.issyncpointreached
		defaultorder.istemporder = buf.istemporder

		local orderdefinition = ffi.new("OrderDefinition")
		if defaultorder.orderdef ~= nil and C.GetOrderDefinition(orderdefinition, defaultorder.orderdef) then
			defaultorder.orderdef = {}
			defaultorder.orderdef.id = ffi.string(orderdefinition.id)
			defaultorder.orderdef.icon = ffi.string(orderdefinition.icon)
		else
			defaultorder.orderdef = { id = "", icon = "" }
		end
	end

	local icon, color = ""
	if #orders > 0 then
		-- there is an order
		local order = orders[1]
		icon = order.orderdef.icon
		-- change icon to wait if the order is in the wait part
		if (order.orderdef.id == "MoveWait") or (order.orderdef.id == "MoveToObject") or (order.orderdef.id == "DockAndWait") then
			if order.issyncpointreached then
				icon = waiticon
			end
		end
		-- if all orders are temp they were spawned by a defaultorder
		if not hasrealorders then
			color = Helper.color.blue
		end
	elseif next(defaultorder) then
		-- there is a defaultorder
		icon = defaultorder.orderdef.icon
		-- change icon to wait if the order is in the wait part
		if (defaultorder.orderdef.id == "MoveWait") or (defaultorder.orderdef.id == "MoveToObject") or (defaultorder.orderdef.id == "DockAndWait") then
			if defaultorder.issyncpointreached then
				icon = waiticon
			end
		end
		color = Helper.color.blue
	end

	if icon ~= "" then
		icon = (color and Helper.convertColorToText(color) or "") .. "\27[" .. icon .. "]\27X"
	end
	return icon
end

function menu.createPropertyRow(ftable, component, iteration, commanderlocation, showmodules)
	local maxicons = menu.infoTableData.maxIcons

	local subordinates = menu.infoTableData.subordinates[tostring(component)] or {}
	local dockedships = menu.infoTableData.dockedships[tostring(component)] or {}
	local constructions = menu.infoTableData.constructions[tostring(component)] or {}
	local moduledata = menu.infoTableData.moduledata[tostring(component)] or {}
	local convertedComponent = ConvertStringTo64Bit(tostring(component))

	if (#menu.searchtext == 0) or Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.FilterComponentByText(convertedComponent, numtexts, texts, true) end, "text") then
		if (not menu.isPropertyExtended(tostring(component))) and (menu.isCommander(component) or menu.isDockContext(convertedComponent)) or menu.isConstructionContext(convertedComponent) then
			menu.extendedproperty[tostring(component)] = true
		end

		local isstation = IsComponentClass(component, "station")
		local isdoublerow = (iteration == 0 and (isstation or #subordinates > 0))
		local name, color, bgcolor, font, mouseover = menu.getContainerNameAndColors(component, iteration, isdoublerow, false)
		local alertString = ""
		if menu.getFilterOption("layer_think") then
			local alertStatus = menu.getContainerAlertLevel(component)
			local minAlertLevel = menu.getFilterOption("think_alert")
			if (minAlertLevel ~= 0) and alertStatus >= minAlertLevel then
				local color = Helper.color.white
				if alertStatus == 1 then
					color = menu.holomapcolor.lowalertcolor
				elseif alertStatus == 2 then
					color = menu.holomapcolor.mediumalertcolor
				else
					color = menu.holomapcolor.highalertcolor
				end
				alertString = string.format("\027#FF%02x%02x%02x#", color.r, color.g, color.b) .. "\027[workshop_error]\027X"
			end
		end

		if menu.mode == "selectCV" then
			if C.IsBuilderBusy(convertedComponent) then
				mouseover = "\027R" .. ReadText(1001, 7939) .. "\027X"
			elseif not GetComponentData(component, "isplayerowned") then
				local fee = tonumber(C.GetBuilderHiringFee())
				mouseover = ((fee > GetPlayerMoney()) and "\027R" or "\027G") .. ReadText(1001, 7940) .. ReadText(1001, 120) .. " " .. ConvertMoneyString(fee, false, true, nil, true) .. " " .. ReadText(1001, 101) .. "\027X"
			end
		end

		local row = ftable:addRow({"property", component, nil, iteration}, { bgColor = bgcolor, multiSelected = menu.isSelectedComponent(component) })
		if (menu.getNumSelectedComponents() == 1) and menu.isSelectedComponent(component) then
			menu.setrow = row.index
		end
		if IsSameComponent(component, menu.highlightedbordercomponent) then
			menu.sethighlightborderrow = row.index
		end

		-- Set up columns
		--  [+/-] [Object Name] [Top Level Shield/Hull Bar] [Location] [Sub_1] [Sub_2] [Sub_3] ... [Sub_N or Shield/Hull Bar]
		if (showmodules and next(moduledata)) or subordinates.hasRendered or (#dockedships > 0) or (isstation and (#constructions > 0)) then
			row[1]:createButton():setText(menu.isPropertyExtended(tostring(component)) and "-" or "+", { halign = "center" })
			row[1].handlers.onClick = function () return menu.buttonExtendProperty(tostring(component)) end
		end

		local location, locationtext, isdocked, aipilot = GetComponentData(component, "sectorid", "sector", "isdocked", "assignedaipilot")
		local displaylocation = location and not (commanderlocation and IsSameComponent(location, commanderlocation))
		local currentordericon = IsComponentClass(component, "ship") and menu.getOrderInfo(convertedComponent) or ""
		local wingtypes = menu.getPropertyOwnedWingData(component, maxicons)

		local namecolspan = isdoublerow and 1 or 2
		if menu.infoTableMode == "objectlist" then
			displaylocation = false
		end
		if not displaylocation then
			if (currentordericon ~= "") or isdocked then
				namecolspan = namecolspan + (isdoublerow and 1 or (maxicons - 2))
			else
				namecolspan = namecolspan + (isdoublerow and (2 + maxicons - #wingtypes) or (maxicons))
			end
		end
		if isdoublerow then
			if displaylocation or (currentordericon ~= "") or isdocked then
				row[3 + namecolspan]:setColSpan(1 + maxicons - #wingtypes)
			end
		else
			if displaylocation or (currentordericon ~= "") or isdocked then
				row[3 + namecolspan]:setColSpan(2 + maxicons - namecolspan)
			end
		end

		if (currentordericon ~= "") or isdocked then
			local numicons = ((currentordericon ~= "") and 1 or 0) + (isdocked and 1 or 0)
			local spacewidth = C.GetTextWidth(" ", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize))
			locationtext = TruncateText(locationtext, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), row[3 + namecolspan]:getColSpanWidth() - Helper.scaleX(Helper.standardTextOffsetx) - numicons * (Helper.scaleY(config.mapRowHeight) + spacewidth))
			if currentordericon ~= "" then
				locationtext = locationtext .. " " .. currentordericon
			end
			if isdocked then
				locationtext = locationtext .. " " .. "\27[order_dockat]"
			end
		end

		if isdoublerow then
			if isstation then
				row[2]:setColSpan(namecolspan)
				local namelines = GetTextLines(alertString .. name, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), row[2]:getWidth() - 2 * Helper.scaleX(Helper.standardTextOffsetx))
				local stationname = namelines[1] .. "\n" .. ""
				for i = 2, #namelines do
					stationname = stationname .. namelines[i]
					if i ~= #namelines then
						stationname = stationname .. " "
					end
				end
				row[2]:createText(stationname, { font = font, color = color, mouseOverText = mouseover })
			else
				row[2]:setColSpan(namecolspan):createText(string.format("%s\n\027#FF%02x%02x%02x#%s", ffi.string(C.GetWingName(convertedComponent)), color.r, color.g, color.b, alertString .. name), { font = font, mouseOverText = mouseover })
			end
			row[2 + namecolspan]:createObjectShieldHullBar(component, { height = config.mapRowHeight })
			if displaylocation or (currentordericon ~= "") or isdocked then
				if displaylocation then
					row[3 + namecolspan]:createText(locationtext .. "\n", { halign = "right" })
				else
					local text = (currentordericon ~= "") and currentordericon or ""
					if isdocked then
						text = text .. " \27[order_dockat]"
					end
					row[3 + namecolspan]:createText(text .. "\n", { halign = "right" })
				end
			end
			for i, wingdata in ipairs(wingtypes) do
				local colidx = 5 + maxicons - #wingtypes + i
				if wingdata.icon then
					row[colidx]:createText(string.format("\027[%s]\n%d", wingdata.icon, wingdata.count), { halign = "center" })
				else
					row[colidx]:createText(string.format("...\n%d", wingdata.count), { halign = "center" })
				end
			end
		else
			row[2]:setColSpan(namecolspan + 1):createText(alertString .. name, { font = font, color = color, mouseOverText = mouseover })
			if displaylocation or (currentordericon ~= "") or isdocked then
				if displaylocation then
					row[3 + namecolspan]:createText(locationtext, { halign = "right" })
				else
					local text = (currentordericon ~= "") and currentordericon or ""
					if isdocked then
						text = text .. " \27[order_dockat]"
					end
					row[3 + namecolspan]:createText(text, { halign = "right" })
				end
			end
			row[5 + maxicons]:createObjectShieldHullBar(component)
		end

		if row[1].type == "button" then
			row[1].properties.height = row[2]:getMinTextHeight(false)
		end

		if IsComponentClass(component, "station") then
			AddKnownItem("stationtypes", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_xl") then
			AddKnownItem("shiptypes_xl", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_l") then
			AddKnownItem("shiptypes_l", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_m") then
			AddKnownItem("shiptypes_m", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_s") then
			AddKnownItem("shiptypes_s", GetComponentData(component, "macro"))
		elseif IsComponentClass(component, "ship_xs") then
			AddKnownItem("shiptypes_xs", GetComponentData(component, "macro"))
		end

		if menu.isPropertyExtended(tostring(component)) then
			-- modules
			if showmodules then
				menu.createModuleSection(ftable, component, moduledata)
			end
			-- subordinates
			if subordinates.hasRendered then
				if (not menu.isSubordinateExtended(tostring(component))) and menu.isCommander(component) then
					menu.extendedsubordinates[tostring(component)] = true
				end
				local issubordinateextended = menu.isSubordinateExtended(tostring(component))
				local hassubordinateheader = isstation or (#dockedships > 0)
				if hassubordinateheader then
					local row = ftable:addRow({"subordinates", component}, { bgColor = Helper.color.transparent })
					row[1]:createButton():setText(issubordinateextended and "-" or "+", { halign = "center" })
					row[1].handlers.onClick = function () return menu.buttonExtendSubordinate(tostring(component)) end
					local text = ReadText(1001, 1503)
					for i = 1, iteration + 1 do
						text = "    " .. text
					end
					row[2]:setColSpan(3):createText(text)
					if IsSameComponent(component, menu.highlightedbordercomponent) and (menu.highlightedborderstationcategory == "subordinates") then
						menu.sethighlightborderrow = row.index
					end
				end
				if (not hassubordinateheader) or issubordinateextended then
					for _, subordinate in ipairs(subordinates) do
						if (menu.infoTableMode ~= "objectlist") or menu.renderedComponentsRef[ConvertIDTo64Bit(subordinate)] then
							menu.createPropertyRow(ftable, subordinate, iteration + (hassubordinateheader and 2 or 1), location or commanderlocation)
						end
					end
				end
			end
			-- dockedships
			if #dockedships > 0 then
				if (not menu.isDockedShipsExtended(tostring(component))) and menu.isDockContext(convertedComponent) then
					menu.extendeddockedships[tostring(component)] = true
				end

				local isdockedshipsextended = menu.isDockedShipsExtended(tostring(component))
				local row = ftable:addRow({"dockedships", component}, { bgColor = Helper.color.transparent })
				row[1]:createButton():setText(isdockedshipsextended and "-" or "+", { halign = "center" })
				row[1].handlers.onClick = function () return menu.buttonExtendDockedShips(tostring(component)) end
				local text = ReadText(1001, 3265)
				for i = 1, iteration + 1 do
					text = "    " .. text
				end
				row[2]:setColSpan(3):createText(text)
				if IsSameComponent(component, menu.highlightedbordercomponent) and (menu.highlightedborderstationcategory == "dockedships") then
					menu.sethighlightborderrow = row.index
				end
				if isdockedshipsextended then
					for _, dockedship in ipairs(dockedships) do
						menu.createPropertyRow(ftable, dockedship, iteration + 2, location or commanderlocation)
					end
				end
			end
			if isstation then
				-- construction
				if #constructions > 0 then
					menu.createConstructionSubSection(ftable, component, constructions)
				end
			end
		end
	end
end

function menu.createModuleSection(ftable, component, moduledata)
	for _, moduletype in ipairs(config.moduletypes) do
		local modules = moduledata[moduletype.type] or {}
		if next(modules) then
			if (not menu.isModuleTypeExtended(component, moduletype.type)) then
				for _, module in ipairs(modules) do
					if menu.isSelectedComponent(module) then
						menu.extendModuleType(component, moduletype.type, true)
						break
					end
				end
			end

			local istypeextended = menu.isModuleTypeExtended(component, moduletype.type)

			local bgcolor = Helper.color.transparent
			if (menu.mode == "orderparam_object") then
				bgcolor = menu.darkgrey
			end

			local row = ftable:addRow({"moduletype", component, moduletype.type, iteration}, { bgColor = bgcolor })
			if IsSameComponent(component, menu.highlightedbordercomponent) and (moduletype.type == menu.highlightedbordermoduletype) then
				menu.sethighlightborderrow = row.index
			end

			row[1]:createButton():setText(istypeextended and "-" or "+", { halign = "center" })
			row[1].handlers.onClick = function () return menu.buttonExtendModuleType(component, moduletype.type) end
			row[2]:setColSpan(3):createText("    " .. moduletype.name)

			if istypeextended then
				for _, module in ipairs(modules) do
					if type(module) == "string" then
						local name = GetMacroData(module, "name")
						local bgcolor = Helper.color.transparent
						if menu.mode == "orderparam_object" then
							bgcolor = menu.darkgrey
						end
						local row = ftable:addRow({"module", nil, moduletype.type, iteration, component, module}, { bgColor = bgcolor })

						if IsSameComponent(component, menu.highlightedbordercomponent) and (moduletype.type == menu.highlightedbordermoduletype) and (module == menu.highlightedplannedmodule) then
							menu.sethighlightborderrow = row.index
						end

						row[2]:setColSpan(3):createText(function () return menu.getBuildProgress(component, "        " .. name, 0) end, { color = color, mouseOverText = name })
					else
						local moduleunlocked = isplayer or IsInfoUnlockedForPlayer(ConvertStringToLuaID(tostring(module)), "name")

						local color = (not moduleunlocked) and menu.grey or nil
						local bgcolor = Helper.color.transparent
						if (menu.mode == "orderparam_object") and (not menu.checkForOrderParamObject(module)) then
							bgcolor = menu.darkgrey
						end

						local row = ftable:addRow({"module", ConvertStringToLuaID(tostring(module)), moduletype.type, iteration, component}, { bgColor = bgcolor, multiSelected = menu.isSelectedComponent(module) })
						if IsSameComponent(ConvertStringToLuaID(tostring(module)), menu.highlightedbordercomponent) then
							menu.sethighlightborderrow = row.index
						end
						local name = moduleunlocked and ffi.string(C.GetComponentName(module)) or ReadText(1001, 3210)
						row[2]:setColSpan(3):createText(function () return menu.getBuildProgress(component, "        " .. name, module) end, { color = color, mouseOverText = name })
						if IsComponentConstruction(ConvertStringTo64Bit(tostring(module))) then
							local buildingprocessor = GetComponentData(component, "buildingprocessor")
							local ismissingresources = GetComponentData(buildingprocessor, "ismissingresources")
							row[5]:setColSpan(1 + menu.infoTableData.maxIcons):createText(function () return menu.getBuildTime(ConvertIDTo64Bit(buildingprocessor), module, ismissingresources) end, { halign = "right", color = color, mouseOverText = ismissingresources and ReadText(1026, 3223) or "" })
						end
					end
				end
			end
		end
	end
end

function menu.createConstructionSubSection(ftable, component, constructions)
	for i, construction in ipairs(constructions) do
		if menu.isSelectedComponent(construction.component) then
			menu.extendedconstruction[tostring(component)] = true
		end
	end
	local isconstructionextended = menu.isConstructionExtended(tostring(component))
	local row = ftable:addRow({"constructions", component}, { bgColor = Helper.color.transparent })
	row[1]:createButton():setText(isconstructionextended and "-" or "+", { halign = "center" })
	row[1].handlers.onClick = function () return menu.buttonExtendConstruction(tostring(component)) end
	row[2]:setColSpan(3):createText("    " .. ReadText(1001, 3266))
	if IsSameComponent(component, menu.highlightedbordercomponent) and (menu.highlightedborderstationcategory == "constructions") then
		menu.sethighlightborderrow = row.index
	end
	if isconstructionextended then
		for i, construction in ipairs(constructions) do
			menu.createConstructionRow(ftable, component, construction, 2)
		end
	end
end

function menu.createConstructionSection(id, ftable, name, constructions)
	if #constructions > 0 then
		local maxicons = menu.infoTableData.maxIcons

		local row = ftable:addRow(false)
		row[1]:setColSpan(5 + maxicons):createText(name, Helper.headerRowCenteredProperties)

		if id == menu.highlightedbordersection then
			menu.sethighlightborderrow = row.index + 1
		end

		for i, construction in ipairs(constructions) do
			menu.createConstructionRow(ftable, nil, construction, 1)
		end
	end
end

function menu.createConstructionRow(ftable, component, construction, iteration)
	local name = ReadText(20109, 5101)
	if construction.component ~= 0 then
		name = ffi.string(C.GetComponentName(construction.component))
	elseif construction.macro ~= "" then
		name = GetMacroData(construction.macro, "name")
	end
	for i = 1, iteration do
		name = "    " .. name
	end
	local color = (construction.factionid == "player") and menu.holomapcolor.playercolor or Helper.color.white
	local bgcolor = Helper.color.transparent
	if menu.mode == "orderparam_object" then
		bgcolor = menu.darkgrey
	end

	local row = ftable:addRow({ "construction", component, construction }, { bgColor = bgcolor, multiSelected = menu.isSelectedComponent(construction.component) })
	if menu.highlightedconstruction and (construction.id == menu.highlightedconstruction.id) then
		menu.sethighlightborderrow = row.index
	end
	if (construction.component ~= 0) and IsSameComponent(ConvertStringTo64Bit(tostring(construction.component)), menu.highlightedbordercomponent) then
		menu.sethighlightborderrow = row.index
	end

	if construction.inprogress then
		row[2]:setColSpan(4):createText(function () return menu.getShipBuildProgress(construction.component, name .. " (" .. ffi.string(C.GetObjectIDCode(construction.component)) .. ")") end, { color = color, mouseOverText = construction.ismissingresources and ReadText(1026, 3223) or "" })
		row[6]:setColSpan(5):createText(function () return (construction.ismissingresources and "\27Y\27[warning] " or "") .. ConvertTimeString(C.GetBuildProcessorEstimatedTimeLeft(construction.buildercomponent), "%h:%M:%S") end, { halign = "right", color = color, mouseOverText = construction.ismissingresources and ReadText(1026, 3223) or "" })
	else
		local duration = C.GetBuildTaskDuration(construction.buildingcontainer, construction.id)
		row[2]:setColSpan(4):createText(name, { color = color })
		row[6]:setColSpan(5):createText("#" .. construction.queueposition .. " - " .. ConvertTimeString(duration, "%h:%M:%S"), { halign = "right", color = color })
	end
end

function menu.getPropertyOwnedWingData(component, maxentries)
	local shiptyperanks = { }
	local shiptypedata = { }
	menu.getPropertyOwnedWingDataInternal(component, shiptyperanks, shiptypedata)
	table.sort(shiptyperanks)
	local result = { }
	for _, shiptyperank in ipairs(shiptyperanks) do
		-- insert at front
		table.insert(result, 1, shiptypedata[shiptyperank])
	end
	-- If there are too many entries, accumulate counts in last entry and invalidate icon
	while maxentries and #result > maxentries do
		local removed = table.remove(result)
		result[maxentries].count = result[maxentries].count + removed.count
		result[maxentries].icon = nil
	end
	return result
end

function menu.getPropertyOwnedWingDataInternal(component, shiptyperanks, shiptypedata)
	local shiptyperank
	local shipclass = "xs"
	if IsComponentClass(component, "ship_xl") then
		shiptyperank = 50
		shipclass = "xl"
	elseif IsComponentClass(component, "ship_l") then
		shiptyperank = 40
		shipclass = "l"
	elseif IsComponentClass(component, "ship_m") then
		shiptyperank = 30
		shipclass = "m"
	elseif IsComponentClass(component, "ship_s") then
		shiptyperank = 20
		shipclass = "s"
	elseif IsComponentClass(component, "ship_xs") then
		shiptyperank = 10
		shipclass = "xs"
	end
	if shiptyperank then
		local purpose = GetComponentData(component, "primarypurpose")
		if purpose == "fight" then
			shiptyperank = shiptyperank + 4
		elseif purpose == "trade" then
			shiptyperank = shiptyperank + 3
		elseif purpose == "mine" then
			shiptyperank = shiptyperank + 2
		elseif purpose == "build" then
			shiptyperank = shiptyperank + 1
		else
			purpose = "neutral"
		end
		if not shiptypedata[shiptyperank] then
			table.insert(shiptyperanks, shiptyperank)
			shiptypedata[shiptyperank] = { icon = string.format("ship_%s_%s_01", shipclass, purpose), count = 0 }
		end
		shiptypedata[shiptyperank].count = shiptypedata[shiptyperank].count + 1
	end

	local subordinates = menu.infoTableData.subordinates[tostring(component)]
	if subordinates == nil then
		-- component is not rendered but we still need the subordinates for accurate wing counts
		subordinates = GetSubordinates(component)
		for i = #subordinates, 1, -1 do
			local subordinate = subordinates[i]
			if not menu.isObjectValid(ConvertIDTo64Bit(subordinate)) then
				table.remove(subordinates, i)
			end
		end
	end
	menu.infoTableData.subordinates[tostring(component)] = subordinates
	for _, subordinate in ipairs(subordinates) do
		menu.getPropertyOwnedWingDataInternal(subordinate, shiptyperanks, shiptypedata)
	end
end

function menu.populateUpkeepMissionData()
	menu.upkeepMissionData = {}

	local numMissions = GetNumMissions()
	for i = 1, numMissions do
		local missionID, name, description, difficulty, threadtype, maintype, subtype, subtypename, faction, reward, rewardtext, _, _, _, _, _, missiontime, _, abortable, disableguidance, associatedcomponent, alertLevel = GetMissionDetails(i)
				
		if maintype == "upkeep" then
			local container = ConvertIDTo64Bit(GetContextByClass(associatedcomponent, "container", true))

			if menu.upkeepMissionData[tostring(container)] then
				table.insert(menu.upkeepMissionData[tostring(container)], { missionID = missionID, alertLevel = alertLevel })
			else
				menu.upkeepMissionData[tostring(container)] = { { missionID = missionID, alertLevel = alertLevel } }
			end
		end
	end
end

function menu.getContainerAlertLevel(component)
	component = ConvertStringTo64Bit(tostring(component))
	local highestAlertLevel = 0
	if menu.upkeepMissionData[tostring(component)] then
		for _, entry in ipairs(menu.upkeepMissionData[tostring(component)]) do
			highestAlertLevel = math.max(highestAlertLevel, entry.alertLevel)
		end
	end

	return highestAlertLevel
end

function menu.getBuildProgress(station, name, component)
	local buildprogress = 100
	if IsComponentConstruction(ConvertStringTo64Bit(tostring(component))) then
		buildprogress = math.floor(C.GetCurrentBuildProgress(ConvertIDTo64Bit(station)))
	elseif component == 0 then
		buildprogress = "-"
	end

	if buildprogress == 100 then
		return name
	else
		return name .. " (" .. buildprogress .. " %)"
	end
end

function menu.getBuildTime(buildingprocessor, component, ismissingresources)
	if IsComponentConstruction(ConvertStringTo64Bit(tostring(component))) then
		return (ismissingresources and "\27Y\27[warning] " or "") .. ConvertTimeString(C.GetBuildProcessorEstimatedTimeLeft(buildingprocessor), "%h:%M:%S")
	else
		return ""
	end
end

function menu.getShipBuildProgress(ship, name)
	local buildprogress = 100
	if IsComponentConstruction(ConvertStringTo64Bit(tostring(ship))) then
		buildprogress = math.floor(C.GetCurrentBuildProgress(ship))
	elseif ship == 0 then
		buildprogress = "-"
	end

	if buildprogress == 100 then
		return name
	else
		return name .. " (" .. buildprogress .. " %)"
	end
end

-- Order Queue

function menu.displayOrderParam(ftable, orderidx, order, paramidx, param, listidx)
	local value = param.value
	local ismissing = value == nil
	local isplayeroccupiedship = menu.infoSubmenuObject == C.GetPlayerOccupiedShipID()

	if not ismissing then
		value = menu.getParamValue(param.type, value)
	end

	local paramcolor = menu.white
	if ismissing then
		paramcolor = menu.red
	elseif order.state == "setup" then
		paramcolor = menu.green
	end

	if listidx then
		local row = ftable:addRow({ orderidx, paramidx, listidx }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == orderidx) and (menu.selectedorder[2] == paramidx) and (menu.selectedorder[3] == listidx) then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[2]:createText("  " .. param.text .. ReadText(1001, 120))
		local active = (not isplayeroccupiedship) and (((order.state == "setup") and (paramidx <= (order.actualparams + 1))) or ((order.state ~= "setup") and param.editable))
		row[3]:setColSpan(5):createButton({ active = active }):setText(value and tostring(value) or "", { halign = "center", color = paramcolor })
		row[3].handlers.onClick = function () return menu.buttonSetOrderParam(orderidx, paramidx, listidx) end
		row[8]:createButton({ active = active }):setText("x", { halign = "center", color = paramcolor })
		row[8].handlers.onClick = function () return menu.buttonRemoveListParam(orderidx, paramidx, listidx) end
	elseif config.complexOrderParams[param.type] then
		local data = config.complexOrderParams[param.type].data(param.value)
		for _, subparam in ipairs(config.complexOrderParams[param.type]) do
			local subparam2 = { text = subparam.name, value = subparam.value(data), type = subparam.type, editable = param.editable }
			menu.displayOrderParam(ftable, orderidx, order, paramidx, subparam2)
		end
	elseif param.inputparams and (param.type == "number" or param.type == "length" or param.type == "time" or param.type == "money") then
		local defaultmax = 50000
		local minselect = math.max(0, param.inputparams.min or 0)
		local maxselect = math.max(0, param.inputparams.max or defaultmax)
		local curvalue = tonumber(param.value)
		local startvalue = param.inputparams.startvalue
		local step = (param.inputparams.step and (param.inputparams.step >= 1)) and param.inputparams.step or 1
		local usetimeformat = false

		local suffix = ""
		if param.type == "length" then
			suffix = ReadText(1001, 107)
		elseif param.type == "time" then
			suffix = ReadText(1001, 103)
			usetimeformat = true
			minselect = math.floor(minselect / 60)
			maxselect = math.floor(maxselect / 60)
			curvalue = curvalue and math.floor(curvalue / 60)
			startvalue = startvalue and math.floor(startvalue / 60)
			step = math.ceil(step / 60)
		elseif param.type == "money" then
			suffix = ReadText(1001, 101)
		end

		local useinfinite = false
		if param.hasinfinitevalue then
			useinfinite = true
			infinitevalue = param.infinitevalue
		end

		local slidercellProperties = { 
			height = config.mapRowHeight,
			bgColor = Helper.color.transparent,
			readOnly = readonly,
			min       = math.min(minselect, 0),
			minSelect = minselect,
			max       = math.max(maxselect, 0),
			maxSelect = maxselect,
			start     = math.max(minselect, math.min(maxselect, curvalue or startvalue or minselect)),
			step      = step,
			suffix    = suffix,
			exceedMaxValue = false,
			readOnly = isplayeroccupiedship or (((order.state ~= "setup") or (paramidx > (order.actualparams + 1))) and ((order.state == "setup") and (not param.editable))),
			hideMaxValue = param.hasinfinitevalue,
			useInfiniteValue = useinfinite,
			infiniteValue = infinitevalue,
			useTimeFormat = usetimeformat,
		}

		local row = ftable:addRow({ orderidx, paramidx, listidx }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == orderidx) and (menu.selectedorder[2] == paramidx) and (menu.selectedorder[3] == listidx) then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[2]:createText("  " .. param.text .. ReadText(1001, 120))
		row[3]:setColSpan(6):createSliderCell(slidercellProperties):setText("", { fontsize = config.mapFontSize, color = paramcolor })
		row[3].handlers.onSliderCellChanged = function (_, value) return menu.slidercellSetOrderParam(orderidx, paramidx, listidx, value) end
		row[3].handlers.onSliderCellConfirm = function() menu.noupdate = false; return menu.refreshInfoFrame() end
	elseif param.type == "bool" then
		local row = ftable:addRow({ orderidx, paramidx, listidx }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == orderidx) and (menu.selectedorder[2] == paramidx) and (menu.selectedorder[3] == listidx) then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[2]:createText("  " .. param.text .. ReadText(1001, 120))
		local active = (not isplayeroccupiedship) and (((order.state == "setup") and (paramidx <= (order.actualparams + 1))) or ((order.state ~= "setup") and param.editable))
		local rawvalue = param.value ~= 0
		if ismissing then
			rawvalue = false
		end
		row[3]:createCheckBox(rawvalue, { active = active, width = config.mapRowHeight })
		row[3].handlers.onClick = function () return menu.buttonSetOrderParam(orderidx, paramidx, listidx) end
	else
		local row = ftable:addRow({ orderidx, paramidx, listidx }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == orderidx) and (menu.selectedorder[2] == paramidx) and (menu.selectedorder[3] == listidx) then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[2]:createText("  " .. param.text .. ReadText(1001, 120))
		row[3]:setColSpan(6)
		local active = (not isplayeroccupiedship) and (((order.state == "setup") and (paramidx <= (order.actualparams + 1))) or ((order.state ~= "setup") and param.editable))
		local text = value and tostring(value) or ""
		local height = math.max(config.mapRowHeight, math.ceil(C.GetTextHeight(text, Helper.standardFont, Helper.standardFontSize, row[3]:getWidth())) + Helper.borderSize)
		row[3]:createButton({ active = active, height = height }):setText(text, { halign = "center", color = paramcolor, y = (height - config.mapRowHeight) / 2 })
		row[3].handlers.onClick = function () return menu.buttonSetOrderParam(orderidx, paramidx, listidx) end
	end
end

-- mode: "factionresponses", "controllableresponses"
function menu.createOrdersMenu(inputframe, mode)
	-- keep synced with start of menu.createOrderQueue()
	menu.infoTableData.ships = menu.getShipList(true)
	if not menu.infoSubmenuObject then
		for id, _ in pairs(menu.selectedcomponents) do
			local selectedcomponent = ConvertStringTo64Bit(id)
			if GetComponentData(selectedcomponent, "isplayerowned") and C.IsComponentClass(selectedcomponent, "ship") then
				menu.infoSubmenuObject = selectedcomponent
				break
			end
		end
		if not menu.infoSubmenuObject then
			if #menu.infoTableData.ships > 0 then
				menu.infoSubmenuObject = ConvertIDTo64Bit(menu.infoTableData.ships[1].shipid)
			else
				menu.infoSubmenuObject = 0
			end
		end
	end
	menu.addSelectedComponent(menu.infoSubmenuObject, true)

	menu.signals = {}
	local numsignals = C.GetNumAllSignals()
	local allsignals = ffi.new("SignalInfo[?]", numsignals)
	numsignals = C.GetAllSignals(allsignals, numsignals)
	for i = 0, numsignals - 1 do
		local signalid = ffi.string(allsignals[i].id)
		table.insert(menu.signals, {id = signalid, name = ffi.string(allsignals[i].name), description = ffi.string(allsignals[i].description), responses = {}})

		local numresponses = C.GetNumAllResponsesToSignal(signalid)
		local allresponses = ffi.new("ResponseInfo[?]", numresponses)
		numresponses = C.GetAllResponsesToSignal(allresponses, numresponses, signalid)
		for j = 0, numresponses - 1 do
			table.insert(menu.signals[#menu.signals].responses, {id = ffi.string(allresponses[j].id), name = ffi.string(allresponses[j].name), description = ffi.string(allresponses[j].description)})
		end
	end

	local ordertable = menu.createOrdersMenuHeader(inputframe)

	local textproperties = {height = config.mapRowHeight, fontsize = config.mapFontSize}
	if mode == "controllableresponses" then
		-- allow this menu to be opened with invalid object selected, and handle invalid object in the called function.
		menu.createResponsesForControllable(ordertable, menu.infoSubmenuObject, textproperties, mode)
	else
		-- Global Standing Orders only applies to the player faction, regardless of what objects are selected.
		menu.createResponsesForFaction(ordertable, "player", textproperties, mode)
	end
	if menu.isInfoModeValidFor(menu.infoSubmenuObject, mode) and ((mode == "controllableresponses") or (mode == "factionresponses")) then
		ordertable:setSelectedRow(menu.setrow)
		ordertable:setSelectedCol(menu.setcol or 0)
	end

	menu.settoprow = nil
	menu.setrow = nil
	menu.setcol = nil
end

function menu.createOrdersMenuHeader(frame)
	-- sync with tab table in menu.createOrderQueue()
	local buttonwidth = menu.sideBarWidth
	menu.orderHeaderTable = frame:addTable(8, { tabOrder = 1 })
	menu.orderHeaderTable:setColWidth(1, config.mapRowHeight, false)
	menu.orderHeaderTable:setColWidth(2, menu.sideBarWidth - config.mapRowHeight - Helper.borderSize, false)
	menu.orderHeaderTable:setColWidth(3, menu.sideBarWidth, false)
	menu.orderHeaderTable:setColWidth(4, menu.sideBarWidth, false)
	menu.orderHeaderTable:setColWidth(5, menu.sideBarWidth, false)
	menu.orderHeaderTable:setColWidth(6, menu.sideBarWidth, false)
	menu.orderHeaderTable:setColWidthPercent(8, 30)
	menu.orderHeaderTable:setDefaultColSpan(1, 1)
	menu.orderHeaderTable:setDefaultColSpan(2, 7)

	local row = menu.orderHeaderTable:addRow("orders_tabs", { fixed = true, bgColor = Helper.color.transparent })
	for i, entry in ipairs(config.infoCategories) do
		local bgcolor = Helper.defaultTitleBackgroundColor
		local color = Helper.color.white
		if entry.category == menu.infoMode then
			bgcolor = Helper.defaultArrowRowBackgroundColor
		end

		local colindex = i
		if i == 1 then
			row[colindex]:setColSpan(2)
		else
			colindex = colindex + 1
		end

		local shown = true
		if entry.category == "orderqueue_advanced" then
			if C.IsMasterVersion() and (C.GetConfigSetting("advancedorderqueue") <= 0) then
				shown = false
			end
		end

		if shown then
			row[colindex]:createButton({ active = menu.isInfoModeValidFor(menu.infoSubmenuObject, entry.category), height = menu.sideBarWidth, bgColor = bgcolor, mouseOverText = entry.name, scaling = false }):setIcon(entry.icon, { color = color})
			row[colindex].handlers.onClick = function () return menu.buttonInfoSubMode(entry.category, colindex) end
		end
	end

	if menu.selectedRows.orderHeaderTable then
		menu.orderHeaderTable.properties.defaultInteractiveObject = true
		menu.orderHeaderTable:setSelectedRow(menu.selectedRows.orderHeaderTable)
		menu.orderHeaderTable:setSelectedCol(menu.selectedCols.orderHeaderTable or 0)
		menu.selectedRows.orderHeaderTable = nil
		menu.selectedCols.orderHeaderTable = nil
	end

	return menu.orderHeaderTable
end

function menu.createResponsesForFaction(ftable, faction, textproperties, mode, yoffset)
	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(8):createText(ReadText(1001, 9301), Helper.headerRowCenteredProperties)	-- Global Standing Orders

	for _, signalentry in ipairs(menu.signals) do
		local signalid = signalentry.id
		local defask = C.GetAskToSignalForFaction(signalid, faction)
		local defresponse = ffi.string(C.GetDefaultResponseToSignalForFaction(signalid, faction))
		local locresponses = {}
		for _, responseentry in ipairs(signalentry.responses) do
			table.insert(locresponses, { id = responseentry.id, text = responseentry.name, icon = "", displayremoveoption = false })
		end
		table.insert(locresponses, { id = "reset", text = ReadText(1001, 9310), icon = "", displayremoveoption = false })	-- Reset standing orders of all ships for this scenario

		row = ftable:addRow(false, {bgColor = Helper.color.transparent})
		row[1]:setColSpan(8):createText(ReadText(1001, 9320) .. " " .. tostring(signalentry.name) .. ReadText(1001, 120), textproperties)	-- Default global response to, :

		row = ftable:addRow("orders_" .. (tostring(signalid) .. "_response"), {bgColor = Helper.color.transparent})
		row[1]:setColSpan(8):createDropDown(locresponses, {height = config.mapRowHeight, startOption = defresponse}):setTextProperties({fontsize = config.mapFontSize})
		row[1].handlers.onDropDownConfirmed = function(_, newresponseid) return menu.dropdownOrdersSetResponse(_, newresponseid, faction, signalid, mode) end
		row[1].handlers.onDropDownActivated = function () menu.noupdate = true end

		row = ftable:addRow("orders_" .. tostring(signalid) .. "_ask", {bgColor = Helper.color.transparent})
		row[1]:createCheckBox(defask, { width = config.mapRowHeight, height = config.mapRowHeight })
		row[1].handlers.onClick = function() return menu.checkboxOrdersSetAsk(faction, signalid, mode) end
		row[2]:createText(ReadText(1001, 9330), textproperties)	-- Notify me if incident occurs
	end
end

function menu.createResponsesForControllable(ftable, controllable, textproperties, mode, yoffset)
	local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(8):createText(ReadText(1001, 8362), Helper.headerRowCenteredProperties)

	local isvalid = menu.isInfoModeValidFor(menu.infoSubmenuObject, mode)
	local faction = GetComponentData(controllable, "owner")
	for _, signalentry in ipairs(menu.signals) do
		local signalid = signalentry.id
		local defask = false
		local defresponse = ""
		local deffactresponse = ""
		if isvalid then
			defask = C.GetAskToSignalForControllable(signalid, controllable)
			defresponse = ffi.string(C.GetDefaultResponseToSignalForControllable(signalid, controllable))
			deffactresponse = ffi.string(C.GetDefaultResponseToSignalForFaction(signalid, faction))
		end
		local deffactresponsename = ""
		local hasownresponse = C.HasControllableOwnResponse(controllable, signalid)

		local locresponses = {}
		for _, responseentry in ipairs(signalentry.responses) do
			if responseentry.id == deffactresponse then
				deffactresponsename = responseentry.name
				break
			end
		end
		for _, responseentry in ipairs(signalentry.responses) do
			table.insert(locresponses, { id = responseentry.id, text = responseentry.name, text2 = (deffactresponse ~= responseentry.id) and ("[" .. ReadText(1001, 8366) .. ReadText(1001, 120) .. " " .. deffactresponsename .. "]") or "", icon = "", displayremoveoption = false })
		end
		--table.insert(locresponses, { id = "reset", text = ReadText(1001, 9311), icon = "", displayremoveoption = false })	-- Reset standing orders of this ship for this scenario

		row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:setColSpan(8):createText(ReadText(1001, 9321) .. " " .. tostring(signalentry.name) .. ReadText(1001, 120), textproperties)	-- Default response to, :
		
		local rowdata = "orders_" .. tostring(signalid) .. "_global"
		row = ftable:addRow({ rowdata }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == rowdata) then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[1]:createCheckBox(not hasownresponse, { width = config.mapRowHeight, height = config.mapRowHeight, active = isvalid })
		row[1].handlers.onClick = function(_, checked) return menu.checkboxOrdersSetOverride(controllable, signalid, mode, checked) end
		row[2]:setColSpan(7):createText(ReadText(1001, 8367), textproperties)

		local rowdata = "orders_" .. tostring(signalid) .. "_response"
		row = ftable:addRow({ rowdata }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == rowdata) then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[1]:setColSpan(8):createDropDown(locresponses, { height = config.mapRowHeight, startOption = defresponse, active = isvalid and hasownresponse }):setTextProperties({fontsize = config.mapFontSize}):setText2Properties({ fontsize = config.mapFontSize, halign = "right" })
		row[1].handlers.onDropDownConfirmed = function(_, newresponseid) return menu.dropdownOrdersSetResponse(_, newresponseid, controllable, signalid, mode) end
		row[1].handlers.onDropDownActivated = function () menu.noupdate = true end
		
		local rowdata = "orders_" .. tostring(signalid) .. "_ask"
		row = ftable:addRow({ rowdata }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == rowdata) then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[1]:createCheckBox(defask, { width = config.mapRowHeight, height = config.mapRowHeight, active = isvalid and hasownresponse })
		row[1].handlers.onClick = function() return menu.checkboxOrdersSetAsk(controllable, signalid, mode) end
		row[2]:setColSpan(7):createText(ReadText(1001, 9330), textproperties)	-- Notify me if incident occurs
		row[2].properties.color = hasownresponse and Helper.color.white or Helper.color.grey

		row = ftable:addRow(false, {bgColor = Helper.color.transparent})
		row[1]:setColSpan(8):createText("")
	end
end

function menu.createOrderQueue(frame, mode)
	-- keep synced with start of menu.createOrdersMenu()
	menu.infoTableData.ships = menu.getShipList(true)
	if not menu.infoSubmenuObject then
		for id, _ in pairs(menu.selectedcomponents) do
			local selectedcomponent = ConvertStringTo64Bit(id)
			if GetComponentData(selectedcomponent, "isplayerowned") and C.IsComponentClass(selectedcomponent, "ship") then
				menu.infoSubmenuObject = selectedcomponent
				break
			end
		end
		if not menu.infoSubmenuObject then
			if #menu.infoTableData.ships > 0 then
				menu.infoSubmenuObject = ConvertIDTo64Bit(menu.infoTableData.ships[1].shipid)
			else
				menu.infoSubmenuObject = 0
			end
		end
	end
	menu.addSelectedComponent(menu.infoSubmenuObject, true)

	-- Possible orders
	menu.orderdefs = {}
	
	local n = C.GetNumOrderDefinitions()
	local buf = ffi.new("OrderDefinition[?]", n)
	n = C.GetOrderDefinitions(buf, n)
	for i = 0, n - 1 do
		local entry = {}
		entry.id = ffi.string(buf[i].id)
		entry.name = ffi.string(buf[i].name)
		entry.description = ffi.string(buf[i].description)
		entry.category = ffi.string(buf[i].category)
		entry.categoryname = ffi.string(buf[i].categoryname)
		entry.infinite = buf[i].infinite
		entry.requiredSkill = buf[i].requiredSkill
		table.insert(menu.orderdefs, entry)
	end

	menu.orderdefsbycategory = {}
	for _, orderdef in ipairs(menu.orderdefs) do
		if menu.orderdefsbycategory[orderdef.category] then
			table.insert(menu.orderdefsbycategory[orderdef.category], orderdef)
		else
			menu.orderdefsbycategory[orderdef.category] = { orderdef }
		end
	end

	-- Current orders
	menu.infoTableData.orders = {}
	menu.infoTableData.defaultorder = {}
	menu.infoTableData.planneddefaultorder = {}

	if menu.isInfoModeValidFor(menu.infoSubmenuObject, mode) then
		local n = C.GetNumOrders(menu.infoSubmenuObject)
		local buf = ffi.new("Order[?]", n)
		n = C.GetOrders(buf, n, menu.infoSubmenuObject)
		for i = 0, n - 1 do
			local entry = {}
			entry.state = ffi.string(buf[i].state)
			entry.statename = ffi.string(buf[i].statename)
			entry.orderdef = ffi.string(buf[i].orderdef)
			entry.actualparams = tonumber(buf[i].actualparams)
			entry.enabled = buf[i].enabled
			entry.isinfinite = buf[i].isinfinite
			table.insert(menu.infoTableData.orders, entry)
		end
	
		local buf = ffi.new("Order")
		if C.GetDefaultOrder(buf, menu.infoSubmenuObject) then
			menu.infoTableData.defaultorder.state = ffi.string(buf.state)
			menu.infoTableData.defaultorder.statename = ffi.string(buf.statename)
			menu.infoTableData.defaultorder.orderdef = ffi.string(buf.orderdef)
			menu.infoTableData.defaultorder.actualparams = tonumber(buf.actualparams)
			menu.infoTableData.defaultorder.enabled = buf.enabled

			local found = false
			for _, orderdef in ipairs(menu.orderdefs) do
				if (orderdef.id == menu.infoTableData.defaultorder.orderdef) then
					menu.infoTableData.defaultorder.orderdefref = orderdef
					found = true
					break
				end
			end
			if not found then
				DebugError("Default order of '" .. tostring(menu.infoSubmenuObject) .. "' is of unknown definition '" .. ffi.string(buf.orderdef) .. "' [Florian]")
			end
		end
	
		local buf = ffi.new("Order")
		if C.GetPlannedDefaultOrder(buf, menu.infoSubmenuObject) then
			menu.infoTableData.planneddefaultorder.state = ffi.string(buf.state)
			menu.infoTableData.planneddefaultorder.statename = ffi.string(buf.statename)
			menu.infoTableData.planneddefaultorder.orderdef = ffi.string(buf.orderdef)
			menu.infoTableData.planneddefaultorder.actualparams = tonumber(buf.actualparams)
			menu.infoTableData.planneddefaultorder.enabled = buf.enabled

			local found = false
			for _, orderdef in ipairs(menu.orderdefs) do
				if (orderdef.id == menu.infoTableData.planneddefaultorder.orderdef) then
					menu.infoTableData.planneddefaultorder.orderdefref = orderdef
					found = true
					break
				end
			end
			if not found then
				DebugError("Planned default order of '" .. tostring(menu.infoSubmenuObject) .. "' is of unknown definition '" .. ffi.string(buf.orderdef) .. "' [Florian]")
			end
		end

		menu.infoTableData.commander = GetCommander(menu.infoSubmenuObject)
	end

	if not menu.selectedorder then
		menu.setcol = nil
	else
		if menu.selectedorder.object ~= menu.infoSubmenuObject then
			menu.selectedorder = nil
			menu.setrow = nil
			menu.setcol = nil
		end
	end

	local ftable = frame:addTable(8, { tabOrder = 1 })
	ftable:setColWidth(1, Helper.standardTextHeight)
	ftable:setColWidth(2, frame.properties.width / 3 - Helper.scaleY(Helper.standardTextHeight) - Helper.borderSize, false)
	ftable:setColWidthPercent(3, 33)
	ftable:setColWidth(5, Helper.standardTextHeight)
	ftable:setColWidth(6, Helper.standardTextHeight)
	ftable:setColWidth(7, Helper.standardTextHeight)
	ftable:setColWidth(8, Helper.standardTextHeight)

	ftable:setDefaultCellProperties("button", { height = config.mapRowHeight })

	-- isvalid == controllable.isclass.ship and controllable.isplayerowned
	local isvalid = menu.isInfoModeValidFor(menu.infoSubmenuObject, mode)
	local playeroccupiedship64 = C.GetPlayerOccupiedShipID()
	local isplayeroccupiedship = menu.infoSubmenuObject == playeroccupiedship64

	local color = menu.holomapcolor.playercolor
	if not isvalid then
		color = Helper.color.white
		if GetComponentData(menu.infoSubmenuObject, "isonlineobject") then
			color = menu.holomapcolor.visitorcolor
		elseif GetComponentData(menu.infoSubmenuObject, "isenemy") then
			color = menu.holomapcolor.enemycolor
		elseif GetComponentData(menu.infoSubmenuObject, "isfriend") then
			color = menu.holomapcolor.friendcolor
		end
	elseif menu.infoSubmenuObject == C.GetPlayerObjectID() then
		color = menu.holomapcolor.currentplayershipcolor
	end

	--- title ---
	local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(8):createText((mode == "orderqueue") and ReadText(1001, 8360) or ReadText(1001, 8361), Helper.headerRowCenteredProperties)
	--- name ---
	local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(3):setBackgroundColSpan(8):createText(ffi.string(C.GetComponentName(menu.infoSubmenuObject)), Helper.headerRow1Properties)
	row[1].properties.color = color
	row[4]:setColSpan(5):createText(ffi.string(C.GetObjectIDCode(menu.infoSubmenuObject)), Helper.headerRow1Properties)
	row[4].properties.color = color
	row[4].properties.halign = "right"
	
	---- pilot info ----
	local aipilot, formation, isplayerowned = GetComponentData(menu.infoSubmenuObject, "assignedaipilot", "formation", "isplayerowned")
	if isvalid or isplayerowned then
		--- name ---
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:setColSpan(2):createText(aipilot and GetComponentData(aipilot, "postname") or "-" .. ReadText(1001, 120))
		row[3]:setColSpan(6):createText(aipilot and GetComponentData(aipilot, "name") or "-")
		--- skills ---
		local adjustedskill = aipilot and math.floor(C.GetEntityCombinedSkill(ConvertIDTo64Bit(aipilot), nil, "aipilot") * 5 / 100) or 0
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:setColSpan(2):createText(ReadText(1001, 9124) .. ReadText(1001, 120))
		row[3]:setColSpan(6):createText(aipilot and (string.rep(utf8.char(9733), adjustedskill) .. string.rep(utf8.char(9734), 5 - adjustedskill)) or "-", { font = aipilot and Helper.starFont or nil, color = aipilot and Helper.color.brightyellow or nil })
		--- commander ---
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:setColSpan(2):createText(ReadText(1001, 1112) .. ReadText(1001, 120))
		row[3]:setColSpan(6):createText(menu.infoTableData.commander and GetComponentData(menu.infoTableData.commander, "name") or "-")
		--- subordinates ---
		local subordinates = GetSubordinates(menu.infoSubmenuObject, nil, true)
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:setColSpan(2):createText(ReadText(1001, 1503) .. ReadText(1001, 120))
		row[3]:setColSpan(6):createText(#subordinates)
		--- formation ---
		local n = C.GetNumFormationShapes()
		local buf = ffi.new("UIFormationInfo[?]", n)
		n = C.GetFormationShapes(buf, n)
		local formationshapes = {}
		for i = 0, n - 1 do
			table.insert(formationshapes, { name = ffi.string(buf[i].name), shape = ffi.string(buf[i].shape), requiredSkill = buf[i].requiredSkill })
		end
		table.sort(formationshapes, Helper.sortName)
		local formationOptions = {}
		for _, data in ipairs(formationshapes) do
			table.insert(formationOptions, { id = data.shape, text = data.name, text2 = string.rep(utf8.char(9733), data.requiredSkill) .. string.rep(utf8.char(9734), 5 - data.requiredSkill), icon = "", displayremoveoption = false, active = data.requiredSkill <= adjustedskill })
		end
		local row = ftable:addRow({ "formation" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "formation") then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[1]:setColSpan(2):createText(ReadText(1001, 8307) .. ReadText(1001, 120))
		row[3]:setColSpan(6):createDropDown(formationOptions, { height = config.mapRowHeight, startOption = formation, active = isvalid and (#subordinates > 0), textOverride = (#subordinates == 0) and ReadText(20223, 11) or nil  }):setTextProperties({ fontsize = config.mapFontSize }):setText2Properties({ font = Helper.starFont, fontsize = config.mapFontSize, color = Helper.color.brightyellow, halign = "right" })
		row[3].handlers.onDropDownConfirmed = menu.dropdownBehaviourFormation
		row[3].handlers.onDropDownActivated = function () menu.noupdate = true end
	end

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(8):createText(" ")

	---- actual order queue ----
	--- title ---
	local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(8):createText((mode == "orderqueue") and ReadText(1001, 3225) or ReadText(1001, 8318), Helper.headerRowCenteredProperties)

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(8):createText(" ", { minRowHeight = 1, fontsize = 1 })

	--- orders ---
	menu.infoTableData.disabledmarker = nil
	for i, order in ipairs(menu.infoTableData.orders) do
		local nextorder = menu.infoTableData.orders[i + 1]
		if i == 1 and ((order.state == "setup") or (order.state == "disabled")) then
			menu.infoTableData.disabledmarker = 1
		elseif (not menu.infoTableData.disabledmarker) and ((nextorder and ((nextorder.state == "setup") or (nextorder.state == "disabled"))) or (i == #menu.infoTableData.orders)) then
			menu.infoTableData.disabledmarker = i + 1
		end
		-- red line
		if menu.infoTableData.disabledmarker == i then
			if next(menu.infoTableData.defaultorder) then
				local row = ftable:addRow(false, { bgColor = Helper.color.darkgrey })
				row[1]:setBackgroundColSpan(2)
				row[2]:setColSpan(7):createText(ReadText(1001, 8320) .. ReadText(1001, 120) .. " " .. menu.infoTableData.defaultorder.orderdefref.name, { font = Helper.standardFontBold })
			end

			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:setColSpan(8):createText(ReadText(1001, 8319), { halign = "center", titleColor = Helper.color.red })
		end

		-- orderdef
		local found = false
		for _, orderdef in ipairs(menu.orderdefs) do
			if (orderdef.id == order.orderdef) then
				order.orderdefref = orderdef
				found = true
				break
			end
		end
		if not found then
			break
		end

		-- params
		order.params = GetOrderParams(menu.infoSubmenuObject, i)

		-- hasrequiredparams
		order.hasrequiredparams = false
		for _, param in ipairs(order.params) do
			if param.type ~= "internal" then
				order.hasrequiredparams = true
				break
			end
		end

		-- sync point
		order.syncPointInfo = ffi.new("SyncPointInfo")
		order.hasSyncPoint = C.GetSyncPointInfo(menu.infoSubmenuObject, i, order.syncPointInfo)

		local color = menu.white
		if order.state == "started" or order.state == "critical" or order.state == "finish" then
			color = menu.green
		end

		local isextended = menu.isOrderExtended(menu.infoSubmenuObject, i)

		-- sort out parameters for AdjustOrder()
		local oldidx, newupidx, newdownidx, enableup, enabledown
		oldidx = i
		if menu.infoTableData.disabledmarker == i + 1 then
			newupidx = i - 1
			newdownidx = i
			enableup = true
			enabledown = false
		elseif menu.infoTableData.disabledmarker == i then
			newupidx = i
			newdownidx = i + 1
			enableup = true
			enabledown = false
		else
			newupidx = i - 1
			newdownidx = i + 1
			enableup = order.enabled
			enabledown = order.enabled
		end

		-- state color
		local statecolor = "\27X"
		if order.state == "setup" then
			statecolor = "\27R"
		elseif order.state == "disabled" then
			statecolor = "\27O"
		end

		local row = ftable:addRow({ i }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and menu.selectedorder[1] == i then
			menu.setrow = row.index
			menu.setcol = nil
		end
		-- extend
		row[1]:createButton({ active = order.hasrequiredparams }):setText(isextended and "-" or "+", { halign = "center" })
		row[1].handlers.onClick = function () return menu.buttonExtendOrder(menu.infoSubmenuObject, i) end
		-- name
		row[2]:setColSpan(2):createText(order.orderdefref.name)
		-- state
		row[4]:createText(statecolor .. " [" .. order.statename .. "]", { halign = "right" })
		-- weapon config
		row[5]:createButton({ active = isvalid and not isplayeroccupiedship }):setText("*", { halign = "center" })
		row[5].handlers.onClick = function () return menu.buttonWeaponConfig(menu.infoSubmenuObject, i, false) end
		-- up
		row[6]:createButton({ active = isvalid and (not isplayeroccupiedship) and C.AdjustOrder(menu.infoSubmenuObject, oldidx, newupidx, enableup, false, true) }):setIcon("table_arrow_inv_up")
		row[6].handlers.onClick = function () return menu.buttonOrderUp(i) end
		-- down
		row[7]:createButton({ active = isvalid and (not isplayeroccupiedship) and C.AdjustOrder(menu.infoSubmenuObject, oldidx, newdownidx, enabledown, false, true) }):setIcon("table_arrow_inv_down")
		row[7].handlers.onClick = function () return menu.buttonOrderDown(i) end
		-- remove
		row[8]:createButton({ active = C.RemoveOrder(menu.infoSubmenuObject, i, false, true) }):setText("x", { halign = "center" })
		row[8].handlers.onClick = function () return menu.buttonRemoveOrder(i) end
		row[8].properties.uiTriggerID = "deleteorder"

		if isextended then
			for j, param in ipairs(order.params) do
				if (not param.advanced) or (mode == "orderqueue_advanced") then
					if param.type == "list" then
						if param.value then
							for k, entry in ipairs(param.value) do
								local param2 = { text = param.text .. " #" .. k, value = entry, type = param.inputparams.type, editable = param.editable }
								menu.displayOrderParam(ftable, i, order, j, param2, k)
							end
						end

						local row = ftable:addRow({ i, j, "new" }, { bgColor = Helper.color.transparent })
						if menu.selectedorder and (menu.selectedorder[1] == i) and (menu.selectedorder[2] == j) and (menu.selectedorder[3] == "new") then
							menu.setrow = row.index
							menu.setcol = nil
						end
						local active = isvalid and (not isplayeroccupiedship) and (((order.state == "setup") and (j <= (order.actualparams + 1))) or ((order.state ~= "setup") and param.editable))
						row[2]:setColSpan(7):createButton({ active = active }):setText("  " .. string.format(ReadText(1001, 3235), param.text), { halign = "center" })
						row[2].handlers.onClick = function () return menu.buttonSetOrderParam(i, j) end
					elseif (param.type ~= "internal") then
						menu.displayOrderParam(ftable, i, order, j, param)
					end
				end
			end
			-- sync point option
			if mode == "orderqueue_advanced" then
				if (order.orderdefref.id == "MoveWait") or (order.orderdefref.id == "Wait") or (order.orderdefref.id == "DockAndWait") then
					local syncPointOptions = { [1] = { id = 0, text = ReadText(1001, 3236), icon = "", displayremoveoption = false } }
					for i = 1, 10 do
						table.insert(syncPointOptions, { id = i, text = ReadText(20401, i), icon = "", displayremoveoption = false })
					end

					local row = ftable:addRow({ i, nil, "syncoption" }, { bgColor = Helper.color.transparent })
					if menu.selectedorder and (menu.selectedorder[1] == i) and (menu.selectedorder[3] == "syncoption") then
						menu.setrow = row.index
						menu.setcol = nil
					end
					row[2]:createText("  " .. ReadText(1001, 3237))
					row[3]:setColSpan(6):createDropDown(syncPointOptions, { height = config.mapRowHeight, startOption = order.syncPointInfo.id, active = isvalid and (not isplayeroccupiedship) and order.isinfinite }):setTextProperties({ fontsize = config.mapFontSize, halign = "center" })
					row[3].handlers.onDropDownConfirmed = function (_, id) return menu.dropdownNewSyncPoint(i, id) end
					row[3].handlers.onDropDownActivated = function () menu.noupdate = true end
				end
			end
		end

		-- sync point info
		if order.hasSyncPoint then
			local color = Helper.color.red
			if order.syncPointInfo.reached then
				color = Helper.color.green
			end

			local row = ftable:addRow({ i, nil, "syncinfo" }, { bgColor = Helper.color.transparent })
			if menu.selectedorder and (menu.selectedorder[1] == i) and (menu.selectedorder[3] == "syncinfo") then
				menu.setrow = row.index
				menu.setcol = nil
			end
			row[1]:setColSpan(7):createBoxText(ReadText(1001, 3237) .. ReadText(1001, 120) .. " " .. ReadText(20401, order.syncPointInfo.id), { halign = "center", boxColor = color })
			row[8]:createButton({ active = isvalid and not isplayeroccupiedship }):setText("x", { halign = "center" })
			row[8].handlers.onClick = function () return menu.buttonRemoveOrderSyncPoint(i) end
		end
	end

	-- red line
	if (menu.infoTableData.disabledmarker == nil) or (menu.infoTableData.disabledmarker == (#menu.infoTableData.orders + 1)) then
		if next(menu.infoTableData.defaultorder) then
			local row = ftable:addRow(false, { bgColor = Helper.color.darkgrey })
			row[1]:setBackgroundColSpan(2)
			row[2]:setColSpan(7):createText(ReadText(1001, 8320) .. ReadText(1001, 120) .. " " .. menu.infoTableData.defaultorder.orderdefref.name, { font = Helper.standardFontBold })
		end

		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:setColSpan(8):createText(ReadText(1001, 8319), { halign = "center", titleColor = Helper.color.red })
	end

	local hasstartableorders = false
	local hasremoveableorders = false
	for i, order in ipairs(menu.infoTableData.orders) do
		if C.RemoveOrder(menu.infoSubmenuObject, i, false, true) then
			hasremoveableorders = true
		end
		if order.state == "disabled" then
			hasstartableorders = true
			break;
		end
		if order.state == "setup" then
			break;
		end
	end

	if mode == "orderqueue_advanced" then
		local row = ftable:addRow({ "neworder" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "neworder") then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[1]:setColSpan(8):createButton({ active = isvalid and not isplayeroccupiedship }):setText(ReadText(1001, 3238), { halign = "center" })
		row[1].handlers.onClick = function () return menu.buttonNewOrder(nil, false) end
	end

	local row = ftable:addRow({ "buttons" }, { bgColor = Helper.color.transparent })
	if menu.selectedorder and (menu.selectedorder[1] == "buttons") then
		menu.setrow = row.index
	end
	row[1]:setColSpan(2):createButton({ active = isvalid and hasremoveableorders }):setText(ReadText(1001, 3239), { halign = "center" })
	row[1].handlers.onClick = menu.buttonDeleteAllOrders
	row[1].properties.uiTriggerID = "deleteallorders"
	row[4]:setColSpan(5):createButton({ active = isvalid and (not isplayeroccupiedship) and hasstartableorders }):setText(ReadText(1001, 3240), { halign = "center" })
	row[4].handlers.onClick = menu.buttonStartOrders
	row[4].properties.uiTriggerID = "startorderqueue"

	if mode == "orderqueue_advanced" then
		local hassyncpoints = false
		for i = 1, 10 do
			if C.GetNumObjectsWithSyncPoint(i, false) > 0 then
				hassyncpoints = true
				break
			end
		end

		if hassyncpoints then
			local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:setColSpan(8):createText(" ", { minRowHeight = 1, fontsize = 1 })
			--- title ---
			local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
			row[1]:setColSpan(8):createText(ReadText(1001, 8323), Helper.headerRowCenteredProperties)

			for i = 1, 10 do
				local totalobjects = C.GetNumObjectsWithSyncPoint(i, false)
				local reachedobjects = C.GetNumObjectsWithSyncPoint(i, true)

				if totalobjects > 0 then
					local row = ftable:addRow({"sync", i}, { bgColor = Helper.color.transparent })
					if menu.selectedorder and (menu.selectedorder[1] == "sync") and (menu.selectedorder[2] == i) then
						menu.setrow = row.index
						menu.setcol = nil
					end
					row[1]:setColSpan(2):createText(ReadText(20401, i) .. " (" .. string.format(ReadText(1001, 3229), reachedobjects, totalobjects) .. ")")
					row[3]:setColSpan(6):createButton({ active = (reachedobjects > 0) }):setText(ReadText(1001, 8324), { halign = "center" })
					row[3].handlers.onClick = function () return menu.buttonReleaseSyncPoint(i) end
				end
			end
		end
	end

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(8):createText(" ")

	---- default order ----
	--- title ---
	local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(8):createText(ReadText(1001, 8320), Helper.headerRowCenteredProperties)

	if menu.orderQueueMode == "plandefaultorder" then
		menu.displayPlannedDefaultBehaviour(ftable, mode)
	else
		menu.displayDefaultBehaviour(ftable, mode)
	end

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(8):createText(" ")

	---- standing orders ----
	menu.signals = {}
	local numsignals = C.GetNumAllSignals()
	local allsignals = ffi.new("SignalInfo[?]", numsignals)
	numsignals = C.GetAllSignals(allsignals, numsignals)
	for i = 0, numsignals - 1 do
		local signalid = ffi.string(allsignals[i].id)
		table.insert(menu.signals, {id = signalid, name = ffi.string(allsignals[i].name), description = ffi.string(allsignals[i].description), responses = {}})

		local numresponses = C.GetNumAllResponsesToSignal(signalid)
		local allresponses = ffi.new("ResponseInfo[?]", numresponses)
		numresponses = C.GetAllResponsesToSignal(allresponses, numresponses, signalid)
		for j = 0, numresponses - 1 do
			table.insert(menu.signals[#menu.signals].responses, {id = ffi.string(allresponses[j].id), name = ffi.string(allresponses[j].name), description = ffi.string(allresponses[j].description)})
		end
	end

	menu.createResponsesForControllable(ftable, menu.infoSubmenuObject, { height = config.mapRowHeight, fontsize = config.mapFontSize }, "controllableresponses")

	ftable:setTopRow(menu.settoprow)
	ftable:setSelectedRow(menu.setrow)
	ftable:setSelectedCol(menu.setcol or 0)

	menu.settoprow = nil
	menu.setrow = nil
	menu.setcol = nil

	--- tabs ---
	local tabtable = menu.createOrdersMenuHeader(frame)
	tabtable:setSelectedCol(menu.selectedCols.orderqueuetabs or 0)
	menu.selectedCols.orderqueuetabs = nil

	ftable.properties.y = tabtable.properties.y + tabtable:getVisibleHeight() + Helper.borderSize
	tabtable.properties.nextTable = ftable.index
	ftable.properties.prevTable = tabtable.index
end

function menu.displayDefaultBehaviour(ftable, mode)
	local isvalid = menu.isInfoModeValidFor(menu.infoSubmenuObject, mode)
	local playeroccupiedship64 = C.GetPlayerOccupiedShipID()
	local isplayeroccupiedship = menu.infoSubmenuObject == playeroccupiedship64

	local order = menu.infoTableData.defaultorder

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(8):createText(" ", { minRowHeight = 1, fontsize = 1 })

	if next(order) then
		order.params = GetOrderParams(menu.infoSubmenuObject, "default")
		-- note
		local row = ftable:addRow({ "default1" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "default1") then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[1]:setColSpan(8):createText(ReadText(1001, 8363) .. ReadText(1001, 120))
		-- name
		local active = ((menu.infoTableData.commander == nil) or IsSameComponent(menu.infoTableData.commander, ConvertStringTo64Bit(tostring(playeroccupiedship64)))) and isvalid and (not isplayeroccupiedship)
		local row = ftable:addRow({ "default2" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "default2") then
			menu.setrow = row.index
			menu.setcol = nil
		end
		local printedSkillReq = math.floor(order.orderdefref.requiredSkill * 5 / 100)
		row[1]:setColSpan(2):createText(ReadText(1001, 8364) .. ReadText(1001, 120))
		row[3]:setColSpan(6):createButton({ active = active }):setText(order.orderdefref.name):setText2(string.rep(utf8.char(9733), printedSkillReq) .. string.rep(utf8.char(9734), 5 - printedSkillReq), { font = Helper.starFont, halign = "right", color = Helper.color.brightyellow })
		row[3].handlers.onClick = function () return menu.buttonNewOrder(nil, true) end
		row[3].properties.uiTriggerID = "DefaultBehaviour"
		-- weapon config - TODO
		--row[7]:createButton({ active = isvalid and not isplayeroccupiedship }):setText("*", { halign = "center" })
		--row[7].handlers.onClick = function () return menu.buttonWeaponConfig(menu.infoSubmenuObject, nil, true) end

		for j, param in ipairs(order.params) do
			if (not param.hasinfinitevalue) and ((not param.advanced) or (mode == "orderqueue_advanced")) then
				if param.type == "list" then
					if param.value then
						for k, entry in ipairs(param.value) do
							local param2 = { text = param.text .. " #" .. k, value = entry, type = param.inputparams.type, editable = param.editable }
							menu.displayOrderParam(ftable, "default", order, j, param2, k)
						end
					end

					local row = ftable:addRow({ i, j, "new" }, { bgColor = Helper.color.transparent })
					if menu.selectedorder and (menu.selectedorder[1] == i) and (menu.selectedorder[2] == j) and (menu.selectedorder[3] == "new") then
						menu.setrow = row.index
						menu.setcol = nil
					end
					local active = isvalid and (not isplayeroccupiedship) and (((order.state == "setup") and (j <= (order.actualparams + 1))) or ((order.state ~= "setup") and param.editable))
					row[2]:setColSpan(7):createButton({ active = active }):setText("  " .. string.format(ReadText(1001, 3235), param.text), { halign = "center" })
					row[2].handlers.onClick = function () return menu.buttonSetOrderParam("default", j) end
				elseif (param.type ~= "internal") then
					menu.displayOrderParam(ftable, "default", order, j, param)
				end
			end
		end
	else
		local row = ftable:addRow({ "default" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "default") then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[2]:setColSpan(6):createText(ReadText(1001, 8320) .. ReadText(1001, 120) .. " ---")
		local active = ((menu.infoTableData.commander == nil) or IsSameComponent(menu.infoTableData.commander, ConvertStringTo64Bit(tostring(playeroccupiedship64)))) and isvalid and (not isplayeroccupiedship)
		row[8]:createButton({ active = active }):setIcon("menu_edit")
		row[8].handlers.onClick = function () return menu.buttonNewOrder(nil, true) end
	end

	local row = ftable:addRow({ "defaultbuttons" }, { bgColor = Helper.color.transparent })
	if menu.selectedorder and (menu.selectedorder[1] == "buttons") then
		menu.setrow = row.index
	end
	row[1]:setColSpan(2):createButton({ active = false }):setText(ReadText(1001, 2821), { halign = "center" })
	row[4]:setColSpan(5):createButton({ active = false }):setText(ReadText(1001, 64), { halign = "center" })
end

function menu.displayPlannedDefaultBehaviour(ftable, mode)
	local isvalid = menu.isInfoModeValidFor(menu.infoSubmenuObject, mode)
	local playeroccupiedship64 = C.GetPlayerOccupiedShipID()
	local isplayeroccupiedship = menu.infoSubmenuObject == playeroccupiedship64

	menu.setcol = nil

	local order = menu.infoTableData.planneddefaultorder

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(8):createText(" ", { minRowHeight = 1, fontsize = 1 })

	if next(order) then
		order.params = GetOrderParams(menu.infoSubmenuObject, "planneddefault")

		-- note
		local row = ftable:addRow({ "default1" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "default1") then
			menu.setrow = row.index
			menu.setcol = nil
		end
		row[1]:setColSpan(8):createText(ReadText(1001, 8365) .. ReadText(1001, 120), { font = Helper.standardFontBold })
		-- name
		local active = ((menu.infoTableData.commander == nil) or IsSameComponent(menu.infoTableData.commander, ConvertStringTo64Bit(tostring(playeroccupiedship64)))) and isvalid and (not isplayeroccupiedship)
		local row = ftable:addRow({ "default2" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "default2") then
			menu.setrow = row.index
			menu.setcol = nil
		end
		local printedSkillReq = math.floor(order.orderdefref.requiredSkill * 5 / 100)
		row[1]:setColSpan(2):createText(ReadText(1001, 8320) .. ReadText(1001, 120))
		row[3]:setColSpan(6):createButton({ active = active }):setText(order.orderdefref.name):setText2(string.rep(utf8.char(9733), printedSkillReq) .. string.rep(utf8.char(9734), 5 - printedSkillReq), { font = Helper.starFont, halign = "right", color = Helper.color.brightyellow })
		row[3].handlers.onClick = function () return menu.buttonNewOrder(nil, true) end

		for j, param in ipairs(order.params) do
			if (not param.hasinfinitevalue) and ((not param.advanced) or (mode == "orderqueue_advanced")) then
				if param.type == "list" then
					if param.value then
						for k, entry in ipairs(param.value) do
							local param2 = { text = param.text .. " #" .. k, value = entry, type = param.inputparams.type, editable = param.editable }
							menu.displayOrderParam(ftable, "planneddefault", order, j, param2, k)
						end
					end

					local row = ftable:addRow({ i, j, "new" }, { bgColor = Helper.color.transparent })
					if menu.selectedorder and (menu.selectedorder[1] == i) and (menu.selectedorder[2] == j) and (menu.selectedorder[3] == "new") then
						menu.setrow = row.index
						menu.setcol = nil
					end
					local active = isvalid and (not isplayeroccupiedship) and (((order.state == "setup") and (j <= (order.actualparams + 1))) or ((order.state ~= "setup") and param.editable))
					row[2]:setColSpan(7):createButton({ active = active }):setText("  " .. string.format(ReadText(1001, 3235), param.text), { halign = "center" })
					row[2].handlers.onClick = function () return menu.buttonSetOrderParam("planneddefault", j) end
				elseif (param.type ~= "internal") then
					menu.displayOrderParam(ftable, "planneddefault", order, j, param)
				end
			end
		end
	else
		local row = ftable:addRow({ "planneddefault" }, { bgColor = Helper.color.transparent })
		if menu.selectedorder and (menu.selectedorder[1] == "planneddefault") then
			menu.setrow = row.index
		end
		row[2]:setColSpan(6):createText(ReadText(1001, 8322) .. ReadText(1001, 120) .. " ---")
		local active = ((menu.infoTableData.commander == nil) or IsSameComponent(menu.infoTableData.commander, ConvertStringTo64Bit(tostring(playeroccupiedship64)))) and isvalid and (not isplayeroccupiedship)
		row[8]:createButton({ active = active }):setIcon("menu_edit")
		row[8].handlers.onClick = function () return menu.buttonNewOrder(nil, true) end
	end

	local row = ftable:addRow({ "defaultbuttons" }, { bgColor = Helper.color.transparent })
	if menu.selectedorder and (menu.selectedorder[1] == "buttons") then
		menu.setrow = row.index
	end
	row[1]:setColSpan(2):createButton({ active = isvalid and next(order) and C.EnablePlannedDefaultOrder(menu.infoSubmenuObject, true) }):setText(ReadText(1001, 2821), { halign = "center" })
	row[1].handlers.onClick = menu.buttonDefaultOrderConfirm
	row[4]:setColSpan(5):createButton():setText(ReadText(1001, 64), { halign = "center" })
	row[4].handlers.onClick = menu.buttonDefaultOrderDiscard
end

function menu.createPlotMode(inputframe)
	local textproperties = { height = config.mapRowHeight, fontsize = config.mapFontSize }

	menu.initPlotList()

	menu.table_plotlist = inputframe:addTable(4, {tabOrder = 1})
	menu.table_plotlist:setColWidth(4, Helper.scaleY(textproperties.height), false)
	menu.table_plotlist:setColWidthPercent(2, 30)
	menu.table_plotlist:setColWidthPercent(3, 5)

	local row = menu.table_plotlist:addRow(false, {fixed = true, bgColor = Helper.defaultTitleBackgroundColor})
	row[1]:setColSpan(4):createText(ReadText(1001, 9201), Helper.headerRowCenteredProperties)	-- Your Plots

	local maxVisibleHeight
	local numplotentries = #menu.plots + 1
	for i, plot in ipairs(menu.plots) do
		local station64 = plot.station
		local stationname = ffi.string(C.GetComponentName(station64))
		row = menu.table_plotlist:addRow(station64)
		row[1]:setBackgroundColSpan(3):createText((stationname), textproperties)
		row[1].properties.color = function() return plot.fullypaid and Helper.standardColor or Helper.color.red end

		row[2]:createText((ReadText(1001, 9210) .. " " .. i), textproperties)	-- Plot
		row[2].properties.halign = "right"
		row[2].properties.x = 0
		row[2].properties.color = function() return plot.fullypaid and Helper.standardColor or Helper.color.red end

		row[3]:createText(function() return (plot.fullypaid and "" or "!") end, textproperties)
		row[3].properties.halign = "left"
		row[3].properties.font = Helper.standardFontBold
		row[3].properties.color = Helper.color.red

		row[4]:createButton({ active = not plot.permanent }):setText("x", {halign = "center"})
		row[4].handlers.onClick = function() return menu.buttonRemovePlot(station64) end

		if i == 10 then
			maxVisibleHeight = menu.table_plotlist:getFullHeight()
		end
	end
	row = menu.table_plotlist:addRow("plots_new")
	row[1]:setBackgroundColSpan(4):createText(ReadText(1001, 9200), textproperties)	-- New Plot
	row[2]:createText((ReadText(1001, 9210) .. " " .. tostring(numplotentries)), textproperties)	-- Plot
	row[2].properties.halign = "right"
	row[2].properties.x = 0

	if maxVisibleHeight then
		menu.table_plotlist.properties.maxVisibleHeight = maxVisibleHeight
	end

	if not menu.plotData.component and not menu.plots_initialized then
		for id, _ in pairs(menu.selectedcomponents) do
			local station = ConvertStringTo64Bit(id)
			if GetComponentData(station, "isplayerowned") and C.IsComponentClass(station, "station") then
				menu.updatePlotData(station, true)

				for _, row in ipairs(menu.table_plotlist.rows) do
					if row.rowdata == station then
						menu.setplotrow = row.index
						menu.setplottoprow = (row.index - 12) > 1 and (row.index - 12) or 1
						break
					end
				end

				break
			end
		end
	end
	menu.plots_initialized = true

	if menu.setplotrow then
		menu.setrow = menu.setplotrow
		menu.setplotrow = nil
		if menu.setplottoprow then
			menu.settoprow = menu.setplottoprow
			menu.setplottoprow = nil
		end
	end

	if menu.setrow then
		menu.table_plotlist:setSelectedRow(menu.setrow)
		menu.plotDoNotUpdate = true
		menu.setrow = nil
		if menu.settoprow then
			menu.table_plotlist:setTopRow(menu.settoprow)
			menu.settoprow = nil
		end
	else
		menu.table_plotlist:setTopRow((row.index - 12) > 1 and (row.index - 12) or 1)
		menu.table_plotlist:setSelectedRow(row.index)
	end

	local table_plotdetails = inputframe:addTable(3, { tabOrder = 2 })
	table_plotdetails:setColWidthPercent(1, 40)

	row = table_plotdetails:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(3):createText(function() return menu.plotData.name or "" end, Helper.headerRowCenteredProperties)

	if IsCheatVersion() then
		local setOptions = {}
		local n = C.GetNumAllModuleSets()
		local buf = ffi.new("UIModuleSet[?]", n)
		n = C.GetAllModuleSets(buf, n)
		for i = 0, n - 1 do
			table.insert(setOptions, { id = ffi.string(buf[i].id), text = ffi.string(buf[i].name), icon = "", displayremoveoption = false })
		end
		table.sort(setOptions, function (a, b) return a.text < b.text end)

		row = table_plotdetails:addRow(true)
		row[1]:setColSpan(3):createDropDown(setOptions, { height = config.mapRowHeight, startOption = menu.plotData.set, active = not menu.plotData.placed and not menu.plotData.active }):setTextProperties({fontsize = config.mapFontSize})
		row[1].handlers.onDropDownConfirmed = function(_, idstring) return menu.dropdownModuleSet(_, idstring) end
		row[1].handlers.onDropDownActivated = function () menu.noupdate = true end
	end

	menu.plotsliders = {}
	menu.plotbuttons = {}
	local dimensions = { [1] = { dimension = "posX", text = ReadText(1001, 9220) },
						 [2] = { dimension = "negX", text = ReadText(1001, 9221) },
						 [3] = { dimension = "posY", text = ReadText(1001, 9222) },
						 [4] = { dimension = "negY", text = ReadText(1001, 9223) },
						 [5] = { dimension = "posZ", text = ReadText(1001, 9224) },
						 [6] = { dimension = "negZ", text = ReadText(1001, 9225) },
					}
	local boughtdimensions = {}
	if menu.plotData.paid then
		boughtdimensions = {
			posX = math.ceil((menu.plotData.boughtrawsize.x / 2 + menu.plotData.boughtrawcenteroffset.x) / 1000),
			negX = math.floor((menu.plotData.boughtrawsize.x / 2 - menu.plotData.boughtrawcenteroffset.x) / 1000),
			posY = math.ceil((menu.plotData.boughtrawsize.y / 2 + menu.plotData.boughtrawcenteroffset.y) / 1000),
			negY = math.floor((menu.plotData.boughtrawsize.y / 2 - menu.plotData.boughtrawcenteroffset.y) / 1000),
			posZ = math.ceil((menu.plotData.boughtrawsize.z / 2 + menu.plotData.boughtrawcenteroffset.z) / 1000),
			negZ = math.floor((menu.plotData.boughtrawsize.z / 2 - menu.plotData.boughtrawcenteroffset.z) / 1000),
		}
	end

	for i, dimension in ipairs(dimensions) do
		row = table_plotdetails:addRow(true, {bgColor = Helper.color.transparent})
		local locdimension = menu.plotData.dimensions[dimension.dimension]
		local minimumdimension = menu.plotData.minimumdimensions[dimension.dimension] or 0
		local boughtdimension = menu.plotData.paid and boughtdimensions[dimension.dimension] or 0
		local locpaireddimension = menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]]

		local minselect = math.max(menu.plotData.permanent and math.max(boughtdimension, minimumdimension) or boughtdimension, (locpaireddimension == 0 and 1 or 0))
		local maxselect = (menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]] > config.maxPlotSize) and menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]] or (config.maxPlotSize - menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]])
		local max = (menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]] > config.maxPlotSize) and menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]] or config.maxPlotSize
		if maxselect > max then
			print("maxselect > max. axis: " .. tostring(dimension.dimension) .. " maxselect: " .. tostring(maxselect) .. ", max: " .. tostring(max) .. ", paired value: " .. tostring(menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]]))
		end
		if locdimension < minselect then
			print("menu.updatePlotWidgets(): start < minselect [Florian]")
			locdimension = minselect
		end

		-- increased minSelect to 1 because it looks like slider text is rounding to the nearest integer (and shows 0.5 as 0). so smallest possible plot size is 2x2x2.
		row[1]:setColSpan(3):createSliderCell({ 
			height = config.mapRowHeight,
			bgColor = Helper.color.transparent,
			min = 0,
			minSelect = minselect,
			max = (locpaireddimension > config.maxPlotSize) and locpaireddimension or config.maxPlotSize,
			maxSelect = (locpaireddimension > config.maxPlotSize) and locpaireddimension or (config.maxPlotSize - locpaireddimension),
			start = locdimension,
			step = 1,
			suffix = ReadText(1001, 108) 
		}):setText(dimension.text, {fontsize = config.mapFontSize})
		--row[1]:setColSpan(3):createSliderCell({ height = config.mapRowHeight, min = 0, minSelect = (menu.plotData.paid or menu.plotData.permanent) and menu.plotData.dimensions[dimension.dimension] or 1, max = 9, maxSelect = config.maxPlotSize - menu.plotData.dimensions[config.plotPairedDimension[dimension.dimension]], start = menu.plotData.dimensions[dimension.dimension], step = 1, suffix = ReadText(1001, 108) }):setText(dimension.text, {fontsize = config.mapFontSize})
		row[1].handlers.onSliderCellChanged = function(_, val) return menu.slidercellPlotValue(_, val, dimension.dimension) end
		row[1].handlers.onSliderCellConfirm = function() return menu.refreshInfoFrame() end
		table.insert(menu.plotsliders, { table = table_plotdetails, cell = row[1], row = row.index, col = 1, dimension = dimension.dimension })
	end

	row = table_plotdetails:addRow("createplot", {bgColor = Helper.color.transparent})
	row[2]:createButton({ height = config.mapRowHeight, active = (menu.plotData.isinownedspace and menu.plotData.placed and menu.plotData.paid and (menu.plotData.size.x * 1000 > menu.plotData.boughtrawsize.x or menu.plotData.size.y * 1000 > menu.plotData.boughtrawsize.y or menu.plotData.size.z * 1000 > menu.plotData.boughtrawsize.z) and not menu.plotData.permanent) and true or false }):setText(ReadText(1001, 9230), { halign = "center", fontsize = config.mapFontSize })	-- Reset size
	row[2].handlers.onClick = function() return menu.resetPlotSize() end
	table.insert(menu.plotbuttons, { table = table_plotdetails, cell = row[2], row = row.index, col = 2, rowdata = "createplot", script = function() return menu.resetPlotSize() end })

	row[3]:createButton({ height = config.mapRowHeight, active = not menu.plotData.placed }):setText(ReadText(1001, 9231), { halign = "center", fontsize = config.mapFontSize })	-- Create new plot
	row[3].handlers.onClick = function() return menu.buttonNewPlot() end
	row[3].properties.uiTriggerID = "createnewplot"

	table.insert(menu.plotbuttons, { table = table_plotdetails, cell = row[3], row = row.index, col = 3, rowdata = "createplot", script = function() return menu.buttonNewPlot() end })

	table_plotdetails:setSelectedRow(menu.selectedRows.infotable2)
	menu.selectedRows.infotable2 = nil

	row = table_plotdetails:addRow(false, {bgColor = Helper.defaultTitleBackgroundColor})
	row[1]:setColSpan(3):createText(ReadText(1001, 9202), Helper.headerRowCenteredProperties)	-- Real Estate Transfer Tax

	row = table_plotdetails:addRow(false, {bgColor = Helper.color.transparent})
	row2 = table_plotdetails:addRow("buyplot", {bgColor = Helper.color.transparent})

	row[1]:setColSpan(2):createText(function() return (not menu.plotData.placed and ReadText(1001, 9240)) or ((menu.plotData.fullypaid or not menu.plotData.isinownedspace) and ReadText(1001, 9241)) or (ReadText(1001, 9242) .. ReadText(1001, 120)) end, textproperties)	-- Place or select plot to see required fees., You own this plot., Fee to acquire plot licence, :
	row[3]:createText(function() return (menu.plotData.placed and not menu.plotData.fullypaid and menu.plotData.isinownedspace and (ConvertMoneyString(tostring(menu.plotData.price), false, true, 0, true) .. " " .. ReadText(1001, 101))) or "" end, textproperties)
	row[3].properties.halign = "right"

	-- TODO: activate after there is a distinction between a holomap-only plot and a real one.
	--row2[2]:createButton({active = false, height = config.mapRowHeight}):setText(ReadText(1001, 9232), {halign = "center", fontsize = config.mapFontSize})	-- Ignore licence
	--row2[2]:createButton({active = not menu.plotData.fullypaid and menu.plotData.isinownedspace, height = config.mapRowHeight}):setText(ReadText(1001, 9232), {halign = "center", fontsize = config.mapFontSize})	-- Ignore licence
	--row2[2].handlers.onClick = function() return menu.buttonIgnorePlotLicence() end
	--table.insert(menu.plotbuttons, { table = table_plotdetails, cell = row2[2], row = row2.index, col = 2, rowdata = "buyplot", script = function() return menu.buttonIgnorePlotLicence() end })
	local mouseovertext = ""
	if menu.plotData.placed and (not menu.plotData.fullypaid) and menu.plotData.isinownedspace and (not menu.plotData.affordable) then
		mouseovertext = ReadText(1026, 3222)
	end
	row2[3]:createButton({ active = menu.plotData.placed and not menu.plotData.fullypaid and menu.plotData.isinownedspace and menu.plotData.affordable, height = config.mapRowHeight, mouseOverText = mouseovertext }):setText(ReadText(1001, 9233), { halign = "center", fontsize = config.mapFontSize })	-- Buy licence
	row2[3].handlers.onClick = function() return menu.buttonBuyPlot() end
	row2[3].properties.uiTriggerID = "buyplot"
	table.insert(menu.plotbuttons, { table = table_plotdetails, cell = row2[3], row = row2.index, col = 3, rowdata = "buyplot", script = function() return menu.buttonBuyPlot() end })

	row = table_plotdetails:addRow(false, {bgColor = Helper.defaultTitleBackgroundColor})
	row[1]:setColSpan(3):createText(ReadText(1001, 9234), Helper.headerRowCenteredProperties)	-- Continue to Construction

	row = table_plotdetails:addRow(false, {bgColor = Helper.color.transparent})
	textproperties.height = config.mapRowHeight * 2
	textproperties.wordwrap = true
	row2 = table_plotdetails:addRow("initiateconstruction", {bgColor = Helper.color.transparent})

	row[1]:setColSpan(3):createText(function() return (not menu.plotData.placed and ReadText(1001, 9243)) or ((menu.plotData.fullypaid or not menu.plotData.isinownedspace) and ReadText(1001, 9244)) or ReadText(1001, 9245) end, textproperties)	-- Place or select plot to initiate construction., Click continue to initiate construction., Building without a licence will be seen as a hostile act by the local government.
	row[1].properties.color = function() return menu.plotData.placed and menu.plotData.isinownedspace and not menu.plotData.fullypaid and Helper.color.red or Helper.standardColor end
	row2[3]:createButton({active = menu.plotData.placed, height = config.mapRowHeight}):setText(ReadText(1001, 9235), {halign = "center", fontsize = config.mapFontSize})	-- Continue
	row2[3].handlers.onClick = function() return menu.plotInitiateConstruction(menu.plotData.component) end
	row2[3].properties.uiTriggerID = "initiateconstruction"

	table.insert(menu.plotbuttons, { table = table_plotdetails, cell = row2[3], row = row2.index, col = 3, rowdata = "initiateconstruction", script = function() return menu.plotInitiateConstruction(menu.plotData.component) end })

	table_plotdetails.properties.y = menu.table_plotlist:getVisibleHeight() + Helper.borderSize

	menu.table_plotlist.properties.nextTable = table_plotdetails.index
	table_plotdetails.properties.prevTable = menu.table_plotlist.index
end

function menu.createFilterMode(ftable, numCols)
	local title = ""
	local row = ftable:addRow("tabs", { fixed = true, bgColor = Helper.color.transparent })
	for i, entry in ipairs(config.layers) do
		local icon = entry.icon
		local bgcolor = Helper.defaultTitleBackgroundColor
		-- active filter groups get different colors
		if entry.mode == menu.displayedFilterLayer then
			title = entry.name
			bgcolor = Helper.defaultArrowRowBackgroundColor
		end
		if not menu.getFilterOption(entry.mode) then
			icon = icon .. "_disabled"
		end

		local colindex = i
		if i > 1 then
			colindex = colindex + 2
		end

		row[colindex]:setColSpan((i == 1) and 3 or 1):createButton({ height = menu.sideBarWidth, bgColor = bgcolor, mouseOverText = entry.name, scaling = false }):setIcon(icon, { })
		row[colindex].handlers.onClick = function () return menu.buttonFilterSwitch(entry.mode, row.index, colindex) end
	end

	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	local color = Helper.color.white
	if not __CORE_DETAILMONITOR_MAPFILTER[menu.displayedFilterLayer] then
		--color = Helper.color.grey
	end
	row[1]:setColSpan(2):createButton({ height = Helper.headerRow1Height }):setIcon("menu_on_off", { color = color})
	row[1].handlers.onClick = function () return menu.buttonSetFilterLayer(menu.displayedFilterLayer, row.index, 1) end
	row[3]:setColSpan(numCols - 2):createText(title, Helper.headerRowCenteredProperties)

	local settings = config.layersettings[menu.displayedFilterLayer]
	for _, setting in ipairs(settings) do
		local row = ftable:addRow(false, { bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(numCols):createText(setting.caption, Helper.subHeaderTextProperties)

		if setting.type == "dropdownlist" then
			local list = menu.getFilterOption(setting.id) or {}
			for i, curOption in ipairs(list) do
				local index = i

				local row = ftable:addRow(true, {  })
				row[1]:setColSpan(numCols - 1):createDropDown(setting.listOptions(list, curOption), { height = config.mapRowHeight, startOption = curOption, mouseOverText = setting.info }):setTextProperties({ fontsize = config.mapFontSize })
				row[1].handlers.onDropDownConfirmed = function (_, id) return menu.setFilterOption(menu.displayedFilterLayer, setting, setting.id, id, index) end
				row[1].handlers.onDropDownActivated = function () menu.noupdate = true end
				row[numCols]:createButton({  }):setText("x", { halign = "center" })
				row[numCols].handlers.onClick = function () return menu.removeFilterOption(setting, setting.id, index) end
			end
			if #list < 8 then
				local row = ftable:addRow(true, {  })
				row[1]:setColSpan(numCols):createDropDown(setting.listOptions(list), { height = config.mapRowHeight, startOption = curOption, textOverride = setting.overrideText, mouseOverText = setting.info }):setTextProperties({ fontsize = config.mapFontSize })
				row[1].handlers.onDropDownConfirmed = function (_, id) return menu.setFilterOption(menu.displayedFilterLayer, setting, setting.id, id) end
				row[1].handlers.onDropDownActivated = function () menu.noupdate = true end
			end
		else
			for _, option in ipairs(setting) do
				if setting.type == "checkbox" then
					local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
					row[1]:createCheckBox(menu.getFilterOption(option.id) or false, { scaling = false, width = Helper.scaleY(config.mapRowHeight), height = Helper.scaleY(config.mapRowHeight) })
					row[1].handlers.onClick = function () return menu.setFilterOption(menu.displayedFilterLayer, setting, option.id) end
					row[2]:setColSpan(numCols - 1):createText(option.name, { mouseOverText = option.info })
				elseif setting.type == "slidercell" then
					option.scale.start = math.max(option.scale.min, math.min(option.scale.max, menu.getFilterOption(option.id))) or option.scale.max
					local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
					row[1]:setColSpan(numCols):createSliderCell({ height = config.mapRowHeight, min = option.scale.min, minSelect = option.scale.minSelect, max = option.scale.max, maxSelect = option.scale.maxSelect, start = option.scale.start, step = option.scale.step, suffix = option.scale.suffix, exceedMaxValue = option.scale.exceedmax, mouseOverText = option.info }):setText(option.name, {fontsize = config.mapFontSize})
					row[1].handlers.onSliderCellChanged = function (_, value) menu.noupdate = true; return menu.setFilterOption(menu.displayedFilterLayer, setting, option.id, value) end
					row[1].handlers.onSliderCellConfirm = function() menu.noupdate = false end
				elseif setting.type == "dropdown" then
					local listOptions = option.listOptions()
					local row = ftable:addRow(true, {  })
					row[1]:setColSpan(numCols):createDropDown(listOptions, { height = config.mapRowHeight, startOption = menu.getFilterOption(option.id), mouseOverText = option.info }):setTextProperties({ fontsize = config.mapFontSize }):setText2Properties({ fontsize = config.mapFontSize, halign = "right" })
					row[1].handlers.onDropDownConfirmed = function (_, id) return menu.setFilterOption(menu.displayedFilterLayer, setting, option.id, id) end
					row[1].handlers.onDropDownActivated = function () menu.noupdate = true end
				end
			end
		end
	end

	ftable:setTopRow(menu.topRows.filterTable)
	ftable:setSelectedRow(menu.selectedRows.filterTable)
	ftable:setSelectedCol(menu.selectedCols.filterTable or 0)

	menu.topRows.filterTable = nil
	menu.selectedRows.filterTable = nil
	menu.selectedCols.filterTable = nil
end

function menu.createLegendMode(ftable, numCols)
	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(numCols):createText(ReadText(1001, 9801), Helper.headerRowCenteredProperties)

	for _, entry in ipairs(config.legend) do
		local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
		if entry.icon then
			local iconheight = entry.height or 1.5 * config.mapRowHeight
			local iconwidth  = entry.width  or 1.5 * config.mapRowHeight
			local iconx = 0
			if iconwidth < (1.5 * config.mapRowHeight) then
				iconx = (1.5 * config.mapRowHeight - iconwidth) / 2
			end
			local color
			if entry.color then
				if type(entry.color) == "string" then
					color = menu.holomapcolor[entry.color]
				else
					color = entry.color
				end
			end
			row[1]:setColSpan(3):createIcon(entry.icon, { width = iconwidth, height = iconheight, x = iconx, color = color })
			local texty = 0
			local textheight = math.max(math.max(entry.minRowHeight or 0, Helper.standardTextHeight), iconheight)
			if textheight > Helper.standardTextHeight then
				texty = (textheight - Helper.standardTextHeight) / 2
			end
			row[4]:setColSpan(numCols - 3):createText(entry.text, { minRowHeight = entry.minRowHeight, y = texty })
		else
			row[1]:setColSpan(numCols):createText(entry.text, Helper.subHeaderTextProperties)
			row[1].properties.halign = "center"
		end
	end

	ftable:setTopRow(menu.topRows.filterTable)
	ftable:setSelectedRow(menu.selectedRows.filterTable)
	ftable:setSelectedCol(menu.selectedCols.filterTable or 0)

	menu.topRows.filterTable = nil
	menu.selectedRows.filterTable = nil
	menu.selectedCols.filterTable = nil
end

function menu.createHireMode(ftable, numCols)
	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(numCols):createText(ishiring and ReadText(1001, 3500) or ReadText(1001, 3264), Helper.headerRowCenteredProperties)

	AddUITriggeredEvent(menu.name, "menu_hiremode")

	local npcseed = ConvertIDTo64Bit(menu.modeparam[4])
	local npc, object
	if npcseed then
		object = ConvertIDTo64Bit(menu.modeparam[2])
	else
		npc = ConvertIDTo64Bit(menu.modeparam[2])
	end
	local ishiring = menu.modeparam[3] ~= 0
	local name, npczone
	if npc then
		name, npczone = GetComponentData(npc, "name", "zoneid")
	else
		name = ffi.string(C.GetPersonName(npcseed, object))
		npczone = GetComponentData(object, "zoneid")
	end
	local topcontainer = C.GetTopLevelContainer(npc or object)
	local isOnLonelyShip = false
	if C.IsComponentClass(topcontainer, "ship") and (C.GetNumDockedShips(topcontainer, nil) == 0) then
		isOnLonelyShip = true
	end
	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(5):createText(ReadText(1001, 2809))
	row[6]:setColSpan(numCols - 5):createText(name, { halign = "right" })
	-- Skills
	local possiblePostsAndRoles = {}
	local n = C.GetNumAllControlPosts()
	local buf = ffi.new("ControlPostInfo[?]", n)
	n = C.GetAllControlPosts(buf, n)
	for i = 0, n - 1 do
		table.insert(possiblePostsAndRoles, { name = ffi.string(buf[i].name), post = ffi.string(buf[i].id) })
	end
	table.insert(possiblePostsAndRoles, { name = ReadText(20208, 20103), role = "service" })
	table.insert(possiblePostsAndRoles, { name = ReadText(20208, 20203), role = "marine" })
	table.sort(possiblePostsAndRoles, Helper.sortName)

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(numCols):createText(ReadText(1001, 3257))
	for _, entry in ipairs(possiblePostsAndRoles) do
		local adjustedskill
		if npc then
			adjustedskill = math.floor(C.GetEntityCombinedSkill(npc, entry.role, entry.post) * 5 / 100)
		else
			adjustedskill = math.floor(C.GetPersonCombinedSkill(object, npcseed, entry.role, entry.post) * 5 / 100)
		end
		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(5):createText("   " .. entry.name)
		row[6]:setColSpan(numCols - 5):createText(string.rep(utf8.char(9733), adjustedskill) .. string.rep(utf8.char(9734), 5 - adjustedskill), { font = Helper.starFont, halign = "right", color = Helper.color.brightyellow })
	end
	-- Object
	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(numCols):createText(ReadText(1001, 3258))
	local row = ftable:addRow(false, { fixed = true })
	local shipname = ""
	if menu.hireShip then
		shipname = ffi.string(C.GetComponentName(menu.hireShip)) .. " (" .. ffi.string(C.GetObjectIDCode(menu.hireShip)) .. ")"
		row[1]:setColSpan(numCols):createText(shipname, { halign = "center" })
	else
		row[1]:setColSpan(numCols):createText("---", { halign = "center" })
	end

	-- Possible Roles
	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(numCols):createText(ReadText(1001, 3259))
	local row = ftable:addRow(true, { fixed = true })
	if not isOnLonelyShip then
		if menu.hireShip then
			local roleOptions = {}
			local n, buf
			if npc then
				n = C.GetNumSuitableControlPosts(menu.hireShip, npc, true)
				buf = ffi.new("ControlPostInfo[?]", n)
				n = C.GetSuitableControlPosts(buf, n, menu.hireShip, npc, true)
			else
				n = C.GetNumPersonSuitableControlPosts(menu.hireShip, object, npcseed, true)
				buf = ffi.new("ControlPostInfo[?]", n)
				n = C.GetPersonSuitableControlPosts(buf, n, menu.hireShip, object, npcseed, true)
			end
			for i = 0, n - 1 do
				table.insert(roleOptions, { id = "post:" .. ffi.string(buf[i].id), text = ffi.string(buf[i].name), icon = "", displayremoveoption = false })
			end
			if C.GetFreePeopleCapacity(menu.hireShip) > 0 then
				table.insert(roleOptions, { id = "role:service", text = ReadText(20208, 20103), icon = "", displayremoveoption = false })
				table.insert(roleOptions, { id = "role:marine", text = ReadText(20208, 20203), icon = "", displayremoveoption = false })
			end
			table.sort(roleOptions, function (a, b) return a.text < b.text end)
			
			local context = C.GetCommonContext(npc or object, menu.hireShip, true, true, ConvertIDTo64Bit(npczone), false)
			if context ~= 0 then
				if #roleOptions > 0 then
					local startOption = menu.hireRole and ((menu.hireIsPost and "post:" or "role:") .. menu.hireRole) or ""
					row[1]:setColSpan(numCols):createDropDown(roleOptions, { startOption = startOption, height = config.mapRowHeight }):setTextProperties({ halign = "center" })
					row[1].handlers.onDropDownConfirmed = menu.dropdownHireRole
					row[1].properties.uiTriggerID = "npcrole"
					row[1].handlers.onDropDownActivated = function () menu.noupdate = true end
				else
					row[1]:setColSpan(numCols):createText(string.format(ReadText(1001, 3260), shipname), { halign = "center", color = Helper.color.red })
				end
			else
				row[1]:setColSpan(numCols):createText(ReadText(1001, 8369), { halign = "center", color = Helper.color.red })
			end
		else
			row[1]:setColSpan(numCols):createText(ReadText(1001, 3261), { halign = "center" })
		end
	else
		row[1]:setColSpan(numCols):createText(ReadText(1001, 8368), { halign = "center", color = Helper.color.red })
	end
	local fee
	if ishiring and npc then
		fee = GetNPCBlackboard(npc, "$HiringFee")
	end
	local balance = GetPlayerMoney()
	if fee then
		balance = GetPlayerMoney() - fee
	end
	if ishiring then
		if fee then
			-- Fee
			local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
			row[1]:setColSpan(5):createText(ReadText(1001, 3501))
			row[6]:setColSpan(numCols - 5):createText(ConvertMoneyString(fee, false, true, nil, true) .. " " .. ReadText(1001, 101), { halign = "right" })
		end
		-- Final Balance
		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(5):createText(ReadText(1001, 2004))
		row[6]:setColSpan(numCols - 5):createText(ConvertMoneyString(balance, false, true, nil, true) .. " " .. ReadText(1001, 101), { halign = "right", color = (balance < 0) and Helper.color.red or Helper.color.white })
	end
	-- Buttons
	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	local mouseovertext = ""
	if not menu.hireShip then
		mouseovertext = ReadText(1026, 3220)
	elseif not menu.hireRole then
		mouseovertext = ReadText(1026, 3221)
	elseif ishiring and (balance < 0) then
		mouseovertext = ReadText(1026, 3222)
	end
	row[1]:setColSpan(5):createButton({ active = (menu.hireRole ~= nil) and ((not ishiring) or (balance >= 0)), mouseOverText = mouseovertext }):setText(ishiring and ReadText(1001, 3262) or ReadText(1001, 3263), { halign = "center" })
	row[1].handlers.onClick = menu.buttonHire
	row[1].properties.uiTriggerID = "hire_ok"

	row[6]:setColSpan(numCols - 5):createButton():setText(ReadText(1001, 64), { halign = "center" })
	row[6].handlers.onClick = function () return menu.onCloseElement("back") end
	row[6].properties.uiTriggerID = "hire_cancel"

end

function menu.createInfoSubmenu(inputframe)
	local mode = ""
	local frameheight = inputframe.properties.height
	if not menu.infoSubmenuObject or menu.infoSubmenuObject == 0 then
		-- only get the first selected item. if multiple items selected, whose information do we show?
		for id, content in pairs(menu.selectedcomponents) do
			menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(id))
			break
		end
		if not menu.infoSubmenuObject or menu.infoSubmenuObject == 0 then
			menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(C.GetPlayerOccupiedShipID()))
			if not menu.infoSubmenuObject or menu.infoSubmenuObject == 0 then
				menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(C.GetPlayerContainerID()))
			end
		end
	end

	AddUITriggeredEvent(menu.name, "infomenu_open", menu.infoSubmenuObject)

	if C.IsComponentClass(menu.infoSubmenuObject, "ship") then
		mode = "ship"
	elseif C.IsRealComponentClass(menu.infoSubmenuObject, "station") then
		mode = "station"
	elseif C.IsComponentClass(menu.infoSubmenuObject, "sector") then
		mode = "sector"
	elseif C.IsComponentClass(menu.infoSubmenuObject, "gate") then
		mode = "gate"
	elseif C.IsComponentClass(menu.infoSubmenuObject, "mine") or C.IsComponentClass(menu.infoSubmenuObject, "navbeacon") or C.IsComponentClass(menu.infoSubmenuObject, "resourceprobe") or C.IsComponentClass(menu.infoSubmenuObject, "satellite") then
		mode = "deployable"
	elseif C.IsComponentClass(menu.infoSubmenuObject, "missionboard") then
		mode = "missionboard"
	elseif C.IsComponentClass(menu.infoSubmenuObject, "asteroid") then
		mode = "asteroid"
	else
		DebugError("menu.createInfoSubmenu(): Selected component " .. tostring(menu.infoSubmenuObject) .. " of class " .. ffi.string(C.GetComponentClass(menu.infoSubmenuObject)) .. " is unsupported. Support?")
	end

	if C.IsComponentClass(menu.infoSubmenuObject, "ship") and (menu.resetcrew or (menu.infocrew.object ~= menu.infoSubmenuObject)) then
		menu.infoSubmenuPrepareCrewInfo()
		menu.resetcrew = nil
	end

	-- add 4 columns between cols 4 and 5, and after col 5. col 5 -> 9, cols 4-7 and 9-12 mapRowHeight. cols 8 and 13 (width-buttonwidth)/4-(mapRowHeight*4), assuming that width is greater than mapRowHeight*4.
	local table_info = inputframe:addTable( 13, { tabOrder = 1 } )
	table_info:setColWidth(1, config.mapRowHeight)
	table_info:setColWidthMinPercent(2, 20)
	table_info:setColWidthMinPercent(3, 20)

	table_info:setColWidth(4, config.mapRowHeight)
	table_info:setColWidth(5, config.mapRowHeight)
	table_info:setColWidth(6, config.mapRowHeight)
	table_info:setColWidth(7, config.mapRowHeight)

	table_info:setColWidth(9, config.mapRowHeight)
	table_info:setColWidth(10, config.mapRowHeight)
	table_info:setColWidth(11, config.mapRowHeight)
	table_info:setColWidth(12, config.mapRowHeight)


	menu.setupInfoSubmenuRows(mode, table_info, menu.infoSubmenuObject)

	local table_button_bottom = inputframe:addTable(2, { tabOrder = 2 })
	if GetComponentData(menu.infoSubmenuObject, "isplayerowned") and (mode == "ship" or mode == "station") then
		table_button_bottom:setColWidthPercent(2, 50)

		row = table_button_bottom:addRow("info_button_bottom", { fixed = true, bgColor = Helper.color.transparent })
		if mode == "ship" then
			row[2]:createButton({ active = true }):setText(ReadText(1001, 1137), { halign = "center" })	-- Ship Overview
			row[2].handlers.onClick = function() Helper.closeMenuAndOpenNewMenu(menu, "ShipConfigurationMenu", { 0, 0, nil, "upgrade", { tostring(menu.infoSubmenuObject) } }) menu.cleanup() end
		elseif mode == "station" then
			row[1]:createButton({ active = true }):setText(ReadText(1001, 1136), { halign = "center" })	-- Configure Station
			row[1].handlers.onClick = function() Helper.closeMenuAndOpenNewMenu(menu, "StationConfigurationMenu", { 0, 0, menu.infoSubmenuObject }) menu.cleanup() end
			row[2]:createButton({ active = true }):setText(ReadText(1001, 1138), { halign = "center" })	-- Station Overview
			row[2].handlers.onClick = function() Helper.closeMenuAndOpenNewMenu(menu, "StationOverviewMenu", { 0, 0, menu.infoSubmenuObject }) menu.cleanup() end
		end
	end
	table_button_bottom.properties.y = frameheight - table_button_bottom:getFullHeight() - Helper.borderSize

	local table_description = inputframe:addTable(1, {  })
	row = table_description:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:createText(ReadText(1001, 2404), Helper.headerRowCenteredProperties)

	row = table_description:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:createText(GetComponentData(ConvertStringTo64Bit(tostring(menu.infoSubmenuObject)), "description"), { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, wordwrap = true })

	if menu.setrow then
		table_info:setSelectedRow(menu.setrow)
		menu.setrow = nil
		if menu.settoprow then
			table_info:setTopRow(menu.settoprow)
			menu.settoprow = nil
		end
	end

	local table_header = menu.createOrdersMenuHeader(inputframe)
	table_info.properties.y = table_header.properties.y + table_header:getFullHeight() + Helper.borderSize
	table_description.properties.y = table_button_bottom.properties.y - table_description:getFullHeight() - Helper.borderSize

	table_info.properties.maxVisibleHeight = table_description.properties.y - table_info.properties.y - Helper.borderSize

	table_header.properties.nextTable = table_info.index
	table_info.properties.prevTable = table_header.index
end

function menu.setupInfoSubmenuRows(mode, inputtable, inputobject)
	local object64 = ConvertStringTo64Bit(tostring(inputobject))
	if not menu.infocashtransferdetails or menu.infocashtransferdetails[1] ~= inputobject then
		menu.infocashtransferdetails = { inputobject, {0, 0} }
		-- TEMP for testing
		menu.infodrops = {}
		--print("resetting cash transfer details: " .. menu.infocashtransferdetails[2][1])
	end
	if not menu.infomacrostolaunch then
		menu.infomacrostolaunch = { lasertower = nil, mine = nil, navbeacon = nil, resourceprobe = nil, satellite = nil }
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
		titlecolor = menu.holomapcolor.playercolor
		if object64 == C.GetPlayerObjectID() then
			titlecolor = menu.holomapcolor.currentplayershipcolor
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
		menu.extendedinfo["info_weaponconfig"] = nil
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: menu.infoeditname cleared at the end of this function.
			if isplayerowned and menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				-- Changed by UniTrader: Edit Unformatted Name if available
				-- Original Line:
				-- row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				local editname = ((GetNPCBlackboard(C.GetPlayerID()) , "$unformatted_names")[inputobject]) or objectname
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = editname })
				-- End change by UniTrader
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- "Owner"
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

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
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local objecttype = C.IsInfoUnlockedForPlayer(inputobject, "name") and GetMacroData(GetComponentData(object64, "macro"), "name") or unknowntext
			locrowdata = { false, ReadText(1001, 94), objecttype }	-- Model
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "hullmax")), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "hull")), true, 0, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local shield_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "shieldmax")), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 2), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "shield")), true, 0, true) .. " / " .. shield_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "shieldpercent") .. "%)") end) or (unknowntext .. " / " .. shield_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9076), defenceinfo_low and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "maxunboostedforwardspeed")), true, 0, true) .. " " .. ReadText(1001, 113)) end) or (unknowntext .. " " .. ReadText(1001, 113)) }	-- Cruising Speed, m/s
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local dpstable = ffi.new("DPSData[?]", 6)
			local hasturrets = (defenceinfo_low and #loadout.component.turret > 0) and true or false
			local numtotalquadrants = C.GetDefensibleDPS(dpstable, inputobject, true, true, true, true, hasturrets, false, false)
			if not hasturrets then
				locrowdata = { false, ReadText(1001, 9092), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(dpstable[0].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- Weapon Output, MW
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			else
				for i = 0, numtotalquadrants - 1 do
					locrowdata = { false, (ReadText(1001, 9092) .. " (" .. ReadText(20220, dpstable[i].quadranttextid) .. ")"), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(dpstable[i].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- Weapon Output, MW
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end

			local sustainedfwddps = ffi.new("DPSData[?]", 1)
			C.GetDefensibleDPS(sustainedfwddps, inputobject, true, true, true, true, false, true, false)
			if sustainedfwddps[0].dps > 0 then
				locrowdata = { false, ReadText(1001, 9093), defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(sustainedfwddps[0].dps), true, 0, true) .. " " .. ReadText(1001, 119)) end) or (unknowntext .. " " .. ReadText(1001, 119)) }	-- TEMPTEXT nick, MW
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			local radarrange = defenceinfo_low and ConvertIntegerString((Helper.round(GetComponentData(object64, "maxradarrange")) / 1000), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local shipcombinedskill = math.floor(C.GetShipCombinedSkill(inputobject) * 5 / 100)
			local printedshipcombinedskill = unknowntext
			local locfont = inputfont
			local locfontcolor = Helper.standardColor
			if operatorinfo_details then
				printedshipcombinedskill = (string.rep(utf8.char(9733), shipcombinedskill) .. string.rep(utf8.char(9734), 5 - shipcombinedskill))
				locfont = Helper.starFont
				locfontcolor = Helper.color.brightyellow
			end
			locrowdata = { false, ReadText(1001, 9427), printedshipcombinedskill }	-- Crew Skill
			row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
			row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indentsize })
			row[4]:setColSpan(10):createText(locrowdata[3], { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })

			locrowdata = { false, ReadText(1001, 1325), defenceinfo_high and (function() return ConvertIntegerString(tostring(GetComponentData(object64, "boardingstrength")), true, 0, true) end) or unknowntext }	-- Boarding Attack Strength
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end

		locrowdata = { "Personnel", ReadText(1001, 9400) }	-- Personnel
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
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
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (pilot or isplayerowned) and true or false, 1, indentsize)
			local printedpilotname = operatorinfo and (pilot and tostring(GetComponentData(pilot, "name")) or "") or unknowntext
			if (pilot or isplayerowned) and menu.extendedinfo[locrowdata[1]] then
				if pilot then
					local adjustedskill = math.floor(C.GetEntityCombinedSkill(pilot, nil, "aipilot") * 5 / 100)
					local printedskill = operatorinfo_details and (string.rep(utf8.char(9733), adjustedskill) .. string.rep(utf8.char(9734), 5 - adjustedskill)) or unknowntext
					local skilltable = GetComponentData(pilot, "skills")
					locrowdata = { { pilot, pilot, inputobject }, printedpilotname }
					if (pilot == C.GetPlayerID()) or not operatorinfo or C.IsUnit(inputobject) then
						locrowdata = { pilot, printedpilotname }
					end
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					local locfont = inputfont
					local locfontcolor = Helper.standardColor
					if operatorinfo_details then
						locfont = Helper.starFont
						locfontcolor = Helper.color.brightyellow
					end
					row[2]:setColSpan(2)
					row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
					table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)

					if pilot ~= C.GetPlayerID() then
						for _, skillproperties in ipairs(skilltable) do
							local skillname = ReadText(1013, skillproperties.textid)
							local adjustedskill = math.floor(skillproperties.value * 5 / 15)
							local printedskill = operatorinfo_details and (string.rep(utf8.char(9733), adjustedskill) .. string.rep(utf8.char(9734), 5 - adjustedskill)) or unknowntext
							row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
							row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skillproperties.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
							local locfont = inputfont
							local locfontcolor = Helper.standardColor
							if operatorinfo_details then
								locfont = Helper.starFont
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
							row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() locpilot = GetComponentData(inputobject, "assignedpilot") return ((menu.infocrew.current.total > 0) and locpilot and not GetNPCBlackboard(locpilot, "$state_machine_critical") and not C.IsCurrentOrderCritical(inputobject) and menu.infoSubmenuReplacePilot(inputobject, ConvertIDTo64Bit(locpilot), nil, true) and true or false) end }):setText(ReadText(1001, 57), { halign = "center", fontsize = config.mapFontSize })	-- Accept
							row[9].handlers.onClick = function() return menu.infoSubmenuReplacePilot(inputobject, pilot) end
						end
					end
				else
					row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(7):createText(ReadText(1001, 9432) .. " " .. printedtitle, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })	-- Promote best crewmember to

					row = inputtable:addRow("ReplacePilot", { bgColor = Helper.color.transparent })
					row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (menu.infocrew.current.total > 0) and true or false }):setText(ReadText(1001, 57), { halign = "center", fontsize = config.mapFontSize })	-- Accept
					row[9].handlers.onClick = function() return menu.infoSubmenuReplacePilot(inputobject, nil) end
				end
			end

			local peoplecapacity = C.GetPeopleCapacity(inputobject, "", false)
			local totalcrewcapacity = menu.infocrew.capacity
			local totalnumpeople = menu.infocrew.total
			local aipilot = GetComponentData(inputobject, "assignedaipilot")
			if aipilot then
				aipilot = ConvertStringTo64Bit(tostring(aipilot))
				totalnumpeople = totalnumpeople + 1
			end
			local printedcapacity = operatorinfo and tostring(totalcrewcapacity) or unknowntext
			local printednumpeople = operatorinfo and tostring(totalnumpeople) or unknowntext
			locrowdata = { "Crew", ReadText(1001, 80), (printednumpeople .. " / " .. printedcapacity) }	-- Crew
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, ((operatorinfo and totalnumpeople > 0) and true or false), 1, indentsize)
			if operatorinfo and totalnumpeople > 0 and menu.extendedinfo[locrowdata[1]] then
				-- pilot entry in crew sliders
				if pilot == C.GetPlayerID() and aipilot then
					printedtitle = ReadText(1001, 9403)	-- Relief Pilot
					printedpilotname = tostring(GetComponentData(aipilot, "name"))
				end
				locrowdata = { { "info_crewpilot", aipilot, inputobject }, (printedtitle .. " " .. printedpilotname), (((aipilot or pilot) and 1 or 0) .. " / " .. 1 ) }
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				row[1]:setColSpan(13):createText("")

				locrowdata = ReadText(1001, 5207)	-- Unassigned
				local sliderrows = {}
				local slidercounter = 0
				row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
				row[2]:setColSpan(2):createText(locrowdata, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (2 * indentsize) })
				row[4]:setColSpan(10):createText(function() return ("(" .. tostring(menu.infocrew.unassigned.total) .. ")") end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })
				local unassignedrow = row
				for i, roletable in ipairs(menu.infocrew.current.roles) do
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
						row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = roletable.amount + menu.infocrew.reassigned.roles[i].amount, max = peoplecapacity, maxSelect = roletable.amount + menu.infocrew.reassigned.roles[i].amount + menu.infocrew.unassigned.total, x = Helper.standardTextOffsetx + (2 * indentsize), readOnly = not isplayerowned or not roletable.canhire }):setText(ffi.string(roletable.name), { fontsize = config.mapFontSize })
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
								row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = tiertable.amount + menu.infocrew.reassigned.roles[i].tiers[j].amount, max = peoplecapacity, maxSelect = tiertable.amount + menu.infocrew.reassigned.roles[i].tiers[j].amount, x = Helper.standardTextOffsetx + (3 * indentsize), readOnly = not isplayerowned }):setText(ffi.string(tiertable.name), { fontsize = config.mapFontSize })
								sliderrows[slidercounter].tiers[j] = { ["row"] = row, ["roleindex"] = i, ["name"] = tiertable.name, ["skilllevel"] = tiertable.skilllevel, ["amount"] = tiertable.amount }
							end
						end
					end
				end
				if isplayerowned then
					row = inputtable:addRow("UpdateCrew", { bgColor = Helper.color.transparent })
					row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((menu.infocrew.reassigned.total > 0) and (menu.infocrew.unassigned.total == 0)) end }):setText(ReadText(1001, 2821), { halign = "center", fontsize = config.mapFontSize })	-- Confirm
					row[4].handlers.onClick = function() return menu.infoSubmenuConfirmCrewChanges() end
					row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((menu.infocrew.reassigned.total > 0) or (menu.infocrew.unassigned.total > 0)) end }):setText(ReadText(1001, 3318), { halign = "center", fontsize = config.mapFontSize })	-- Reset
					row[9].handlers.onClick = function() return menu.resetInfoSubmenu() end

					for i, role in ipairs(sliderrows) do

						-- TODO: cleanup these tables. not all data is used.
						local sliderupdatetable = { ["table"] = inputtable, ["row"] = role.row, ["col"] = 2, ["tierrows"] = {}, ["text"] = role.name, ["xoffset"] = role.row[2].properties.x, ["width"] = role.row[2].properties.width }
						for j, tier in ipairs(role.tiers) do
							table.insert(sliderupdatetable.tierrows, { ["row"] = tier.row, ["text"] = tier.name, ["xoffset"] = tier.row[2].properties.x, ["width"] = tier.row[2].properties.width })
						end

						role.row[2].handlers.onSliderCellChanged = function(_, newamount) return menu.infoSubmenuUpdateCrewChanges(newamount, sliderrows, i, false, nil, sliderupdatetable) end
						role.row[2].handlers.onSliderCellConfirm = function() return menu.refreshInfoFrame() end
						role.row[2].handlers.onSliderCellActivated = function() menu.noupdate = true end
						role.row[2].handlers.onSliderCellDeactivated = function() menu.noupdate = false end
						for j, tier in ipairs(role.tiers) do
							tier.row[2].handlers.onSliderCellChanged = function(_, newamount) return menu.infoSubmenuUpdateCrewChanges(newamount, sliderrows, i, true, j, sliderupdatetable) end
							tier.row[2].handlers.onSliderCellConfirm = function() return menu.refreshInfoFrame() end
							tier.row[2].handlers.onSliderCellActivated = function() menu.noupdate = true end
							tier.row[2].handlers.onSliderCellDeactivated = function() menu.noupdate = false end
						end
					end
				end

				locrowdata = { "Full Crew List", ReadText(1001, 9404) }	-- Full Crew List
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, operatorinfo_details, 2, indentsize)
				if operatorinfo_details and menu.extendedinfo[locrowdata[1]] then
					-- pilot entry in full crew manifest
					locrowdata = { "PilotInFullCrew", printedtitle, "" }
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, aipilot and true or false, 3, indentsize)
					if aipilot and menu.extendedinfo[locrowdata[1]] then
						local name = GetComponentData(aipilot, "name")
						local printedname = operatorinfo and tostring(name) or unknowntext
						local adjustedcombinedskill = math.floor(GetComponentData(aipilot, "combinedskill") * 5 / 100)
						local extendinfoid = "info_crewpilot_full"
						local locrowdata = { "info_crewpilot_full", aipilot, inputobject }
						local printedskill = string.rep(utf8.char(9733), adjustedcombinedskill) .. string.rep(utf8.char(9734), 5 - adjustedcombinedskill)
						local indent = 4 * indentsize
						row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(2):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
						row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.starFont, color = Helper.color.brightyellow })
						row[1]:createButton({ height = config.mapRowHeight }):setText(function() return menu.extendedinfo[extendinfoid] and "-" or "+" end, { halign = "center" })
						row[1].handlers.onClick = function() return menu.buttonExtendInfo(extendinfoid) end
						if menu.extendedinfo[extendinfoid] then
							local skilltable = GetComponentData(aipilot, "skills")
							table.sort(skilltable, function(a, b) return a.relevance > b.relevance end)
							for _, skillproperties in ipairs(skilltable) do
								local skillname = ReadText(1013, skillproperties.textid)
								local adjustedskill = math.floor(skillproperties.value * 5 / 15)
								local printedskill = operatorinfo_details and (string.rep(utf8.char(9733), adjustedskill) .. string.rep(utf8.char(9734), 5 - adjustedskill)) or unknowntext
								row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
								row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skillproperties.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (5 * indentsize) })
								local locfont = inputfont
								local locfontcolor = Helper.standardColor
								if operatorinfo_details then
									locfont = Helper.starFont
									locfontcolor = Helper.color.brightyellow
								end
								row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
							end
						end
					end

					for i, roletable in ipairs(menu.infocrew.current.roles) do
						if roletable.amount > 0 then
							locrowdata = { ("Role " .. i), tostring(roletable.name), tostring(roletable.amount) }
							row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (roletable.amount > 0) and true or false, 3, indentsize)
							if menu.extendedinfo[locrowdata[1]] then
								for j, tiertable in ipairs(roletable.tiers) do
									if roletable.numtiers > 1 then
										locrowdata = { ("Role " .. i .. " Tier " .. j), tostring(tiertable.name), tostring(tiertable.amount) }
										row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (tiertable.amount > 0) and true or false, 4, indentsize)
									end
									if menu.extendedinfo[locrowdata[1]] then
										for k, person in ipairs(tiertable.persons) do
											-- NB: adjusted to 5 points at the moment because more than 5 doesn't fit very comfortably in this menu.
											local adjustedcombinedskill = math.floor(C.GetPersonCombinedSkill(inputobject, person, nil, nil) * 5 / 100)
											-- Note: extendinfoid and locrowdata[1] can be different - that wouldn't work when using menu.addInfoSubmenuRow() though
											local extendinfoid = string.format("info_crewperson_r%d_t%d_p%d", i, j, k)
											local locrowdata = { "info_crewperson", person, inputobject }
											local printedname = ffi.string(C.GetPersonName(person, inputobject))
											local printedskill = string.rep(utf8.char(9733), adjustedcombinedskill) .. string.rep(utf8.char(9734), 5 - adjustedcombinedskill)
											local indent = (roletable.numtiers > 1) and (5 * indentsize) or (4 * indentsize)
											row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
											row[2]:setColSpan(2):createText(printedname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + indent })
											row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.starFont, color = Helper.color.brightyellow })
											row[1]:createButton({ height = config.mapRowHeight }):setText(function() return menu.extendedinfo[extendinfoid] and "-" or "+" end, { halign = "center" })
											row[1].handlers.onClick = function() return menu.buttonExtendInfo(extendinfoid) end
											if menu.extendedinfo[extendinfoid] then
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
													local skillvalue = math.floor(skill.value * 5 / 15)
													local indent = (roletable.numtiers > 1) and (6 * indentsize) or (5 * indentsize)
													local printedskill = string.rep(utf8.char(9733), skillvalue) .. string.rep(utf8.char(9734), 5 - skillvalue)
													row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
													row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (skill.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + indent })
													row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.starFont, color = Helper.color.brightyellow })
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (storageinfo_warelist and numwares > 0) and true or false)
		if storageinfo_warelist and (numwares > 0) and menu.extendedinfo[locrowdata[1]] then
			-- TEMP for testing
			if isplayerowned then
				local stufftodrop = false
				for ware, numdrops in pairs(menu.infodrops) do
					if numdrops > 0 then
						stufftodrop = true
						break
					end
				end
				-- add a "Drop" button
				row = inputtable:addRow("ConfirmDrops", { bgColor = Helper.color.transparent })
				row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = stufftodrop }):setText(ReadText(1001, 9405), { halign = "center", fontsize = config.mapFontSize })	-- Drop
				row[4].handlers.onClick = function() return menu.infoSubmenuConfirmDrops(inputobject) end
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = stufftodrop }):setText(ReadText(1001, 64), { halign = "center", fontsize = config.mapFontSize })	-- Cancel
				row[9].handlers.onClick = function() return menu.resetInfoSubmenu() end
			end
			local locpolicefaction = GetComponentData(GetComponentData(object64, "zoneid"), "policefaction")
			for _, wareentry in ipairs(cargotable) do
				local ware = wareentry.ware
				local amount = wareentry.amount
				if not menu.infodrops[ware] then
					menu.infodrops[ware] = 0
				end
				locrowdata = { ware, GetWareData(ware, "name"), amount }
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				-- TEMP for testing
				row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount - menu.infodrops[ware], maxSelect = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = not isplayerowned }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })
				--row[2]:setColSpan(12):createSliderCell({ height = config.mapRowHeight, start = amount, max = math.floor(storagemodules.capacity / GetWareData(ware, "volume")), readOnly = true }):setText(GetWareData(ware, "name"), { fontsize = config.mapFontSize, color = locpolicefaction and (IsWareIllegalTo(ware, GetComponentData(object64, "owner"), locpolicefaction) and Helper.color.orange) or Helper.standardColor })

				-- TEMP for testing
				if isplayerowned then
					--local oldamount = amount
					row[2].handlers.onSliderCellChanged = function(_, newamount) return menu.infoSubmenuUpdateDrops(ware, amount, newamount) end
					--row[2].handlers.onSliderCellChanged = function(_, newamount) return (menu.infodrops[ware] = amount - newamount) end
					row[2].handlers.onSliderCellConfirm = function() return menu.refreshInfoFrame() end
					row[2].handlers.onSliderCellActivated = function() menu.noupdate = true end
					row[2].handlers.onSliderCellDeactivated = function() menu.noupdate = false end

					locrowdata = "Drops"
					row = inputtable:addRow(locrowdata, { bgColor = Helper.color.transparent })
					--row[2]:setColSpan(2):createText(locrowdata, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (2 * indentsize) })
					row[4]:setColSpan(10):createText(function() return (ReadText(1001, 9406) .. ReadText(1001, 120) .. " (" .. tostring(menu.infodrops[ware]) .. ")") end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })	-- Dropping, :
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
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, numdockedships > 0 and true or false)
			if menu.extendedinfo[locrowdata[1]] then
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnummissiles > 0) and true or false)
		if defenceinfo_high and menu.extendedinfo[locrowdata[1]] then
			for i = 0, nummissiletypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(missilestoragetable[i].macro), "name"), (tostring(missilestoragetable[i].amount) .. " / " .. tostring(missilestoragetable[i].capacity)) }
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnumcountermeasures > 0) and true or false)
		if menu.extendedinfo[locrowdata[1]] then
			for i = 0, numcountermeasuretypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(countermeasurestoragetable[i].macro), "name"), (tostring(countermeasurestoragetable[i].amount) .. " / " .. tostring(countermeasurestoragetable[i].capacity)) }
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumdeployables > 0))
		if defenceinfo_high and (totalnumdeployables > 0) and menu.extendedinfo[locrowdata[1]] then
			local printedlasertowercapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumlasertowers = defenceinfo_high and tostring(totalnumlasertowers) or unknowntext
			locrowdata = { "info_lasertowers", ReadText(1001, 1333), (printednumlasertowers .. " / " .. printedlasertowercapacity) }	-- Laser Towers
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumlasertowers > 0), 1, indentsize)
			if defenceinfo_high and (totalnumlasertowers > 0) and menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchlasertower", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and menu.infomacrostolaunch.lasertower) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return menu.buttonLaunchLasertower(inputobject, menu.infomacrostolaunch.lasertower) end
				for i = 0, numlasertowertypes - 1 do
					locrowdata = { {("info_lasertower" .. (i+1)), "info_deploy", ffi.string(lasertowerstoragetable[i].macro)}, GetMacroData(ffi.string(lasertowerstoragetable[i].macro), "name"), (tostring(lasertowerstoragetable[i].amount) .. " / " .. tostring(lasertowerstoragetable[i].capacity)) }
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printedminecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednummines = defenceinfo_high and tostring(totalnummines) or unknowntext
			locrowdata = { "info_mines", ReadText(1001, 1326), (printednummines .. " / " .. printedminecapacity) }	-- Mines
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnummines > 0), 1, indentsize)
			if defenceinfo_high and (totalnummines > 0) and menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchmine", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and menu.infomacrostolaunch.mine) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return menu.buttonLaunchMine(inputobject, menu.infomacrostolaunch.mine) end
				for i = 0, numminetypes - 1 do
					locrowdata = { {("info_mine" .. (i+1)), "info_deploy", ffi.string(minestoragetable[i].macro)}, GetMacroData(ffi.string(minestoragetable[i].macro), "name"), (tostring(minestoragetable[i].amount) .. " / " .. tostring(minestoragetable[i].capacity)) }
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printedsatellitecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumsatellites = defenceinfo_high and tostring(totalnumsatellites) or unknowntext
			locrowdata = { "info_satellites", ReadText(1001, 1327), (printednumsatellites .. " / " .. printedsatellitecapacity) }	-- Satellites
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumsatellites > 0), 1, indentsize)
			if defenceinfo_high and (totalnumsatellites > 0) and menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchsatellite", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and menu.infomacrostolaunch.satellite) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return menu.buttonLaunchSatellite(inputobject, menu.infomacrostolaunch.satellite) end
				for i = 0, numsatellitetypes - 1 do
					locrowdata = { {("info_satellite" .. (i+1)), "info_deploy", ffi.string(satellitestoragetable[i].macro)}, GetMacroData(ffi.string(satellitestoragetable[i].macro), "name"), (tostring(satellitestoragetable[i].amount) .. " / " .. tostring(satellitestoragetable[i].capacity)) }
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end

			local printednavbeaconcapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumnavbeacons = defenceinfo_high and tostring(totalnumnavbeacons) or unknowntext
			locrowdata = { "info_navbeacons", ReadText(1001, 1328), (printednumnavbeacons .. " / " .. printednavbeaconcapacity) }	-- Navigation Beacons
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumnavbeacons > 0), 1, indentsize)
			if defenceinfo_high and (totalnumnavbeacons > 0) and menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchnavbeacon", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and menu.infomacrostolaunch.navbeacon) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return menu.buttonLaunchNavBeacon(inputobject, menu.infomacrostolaunch.navbeacon) end
				for i = 0, numnavbeacontypes - 1 do
					locrowdata = { {("info_navbeacon" .. (i+1)), "info_deploy", ffi.string(navbeaconstoragetable[i].macro)}, GetMacroData(ffi.string(navbeaconstoragetable[i].macro), "name"), (tostring(navbeaconstoragetable[i].amount) .. " / " .. tostring(navbeaconstoragetable[i].capacity)) }
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end
		
			local printedresourceprobecapacity = defenceinfo_low and tostring(deployablecapacity) or unknowntext
			local printednumresourceprobes = defenceinfo_high and tostring(totalnumresourceprobes) or unknowntext
			locrowdata = { "info_resourceprobes", ReadText(1001, 1329), (printednumresourceprobes .. " / " .. printedresourceprobecapacity) }	-- Resource Probes
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, defenceinfo_high and (totalnumresourceprobes > 0), 1, indentsize)
			if defenceinfo_high and (totalnumresourceprobes > 0) and menu.extendedinfo[locrowdata[1]] then
				row = inputtable:addRow("info_launchresourceprobe", { bgColor = Helper.color.transparent })
				row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = (isplayerowned and not isdocked and menu.infomacrostolaunch.resourceprobe) and true or false }):setText(ReadText(1001, 9407), { fontsize = config.mapFontSize, halign = "center" })	-- Deploy
				row[9].handlers.onClick = function() return menu.buttonLaunchResourceProbe(inputobject, menu.infomacrostolaunch.resourceprobe) end
				for i = 0, numresourceprobetypes - 1 do
					locrowdata = { {("info_resourceprobe" .. (i+1)), "info_deploy", ffi.string(resourceprobestoragetable[i].macro)}, GetMacroData(ffi.string(resourceprobestoragetable[i].macro), "name"), (tostring(resourceprobestoragetable[i].amount) .. " / " .. tostring(resourceprobestoragetable[i].capacity)) }
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
				end
			end
		end

		local unitstoragetable = GetUnitStorageData(object64)
		local locunitcapacity = unitinfo_capacity and tostring(unitstoragetable.capacity) or unknowntext
		local locunitcount = unitinfo_capacity and tostring(unitstoragetable.stored) or unknowntext
		locrowdata = {"info_units", ReadText(1001, 8), (locunitcount .. " / " .. locunitcapacity)}	-- Drones
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (unitinfo_details and unitstoragetable.stored > 0) and true or false)
		if menu.extendedinfo[locrowdata[1]] then
			for i = 1, #unitstoragetable do
				if unitstoragetable[i].amount > 0 or unitstoragetable[i].unavailable > 0 then
					locrowdata = { ("Unit" .. i), unitstoragetable[i].name, (unitstoragetable[i].amount .. " / " .. unitstoragetable.capacity .. " (" .. unitstoragetable[i].unavailable .. " " .. ReadText(1001, 9408) .. ")") }	-- Unavailable
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end
		end

		locrowdata = { "info_weaponconfig", ReadText(1001, 9409) }	-- Weapon Configuration
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, isplayerowned and (#loadout.component.weapon > 0) and true or false)
		if isplayerowned and menu.extendedinfo[ locrowdata[1] ] and #loadout.component.weapon > 0 then
			locrowdata = { false, "", "", ReadText(1001, 9410), ReadText(1001, 9411) }	-- Primary, Secondary
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false)
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
					row[3+j].handlers.onClick = function() menu.infoSetWeaponGroup(inputobject, gun, true, j, not uiweapongroups.primary[j]) end
				end

				-- secondary weapon groups
				for j = 1, 4 do
					row[8+j]:createCheckBox(uiweapongroups.secondary[j], { width = config.mapRowHeight, height = config.mapRowHeight })
					row[8+j].handlers.onClick = function() menu.infoSetWeaponGroup(inputobject, gun, false, j, not uiweapongroups.secondary[j]) end
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, isplayerowned and (#loadout.component.turret > 0))
		if isplayerowned and menu.extendedinfo[ locrowdata[1] ] and #loadout.component.turret > 0 then
			menu.turrets = {}
			local numslots = tonumber(C.GetNumUpgradeSlots(inputobject, "", "turret"))
			for j = 1, numslots do
				local groupinfo = C.GetUpgradeSlotGroup(inputobject, "", "turret", j)
				if (ffi.string(groupinfo.path) == "..") and (ffi.string(groupinfo.group) == "") then
					local current = C.GetUpgradeSlotCurrentComponent(inputobject, "turret", j)
					if current ~= 0 then
						table.insert(menu.turrets, current)
					end
				end
			end

			menu.turretgroups = {}
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
						table.insert(menu.turretgroups, group)
					end
				end
			end

			if (#menu.turrets > 0) or (#menu.turretgroups > 0) then
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
				row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return menu.getDropDownTurretModeOption(inputobject, "all") end })
				row[4].handlers.onDropDownConfirmed = function(_, newturretmode) menu.noupdate = false; C.SetAllTurretModes(inputobject, newturretmode) end
				row[4].handlers.onDropDownActivated = function () menu.noupdate = true end

				for i, turret in ipairs(menu.turrets) do
					local row = inputtable:addRow("info_turretconfig" .. i, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(ffi.string(C.GetComponentName(turret)))
					row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return menu.getDropDownTurretModeOption(turret) end })
					row[4].handlers.onDropDownConfirmed = function(_, newturretmode) menu.noupdate = false; C.SetWeaponMode(turret, newturretmode) end
					row[4].handlers.onDropDownActivated = function () menu.noupdate = true end
				end

				for i, group in ipairs(menu.turretgroups) do
					local row = inputtable:addRow("info_turretgroupconfig" .. i, { bgColor = Helper.color.transparent })
					row[2]:setColSpan(2):createText(ReadText(1001, 8023) .. " " .. i .. ((group.currentmacro ~= "") and (" (" .. menu.getSlotSizeText(group.slotsize) .. " " .. GetMacroData(group.currentmacro, "shortname") .. ")") or ""), { color = (group.operational > 0) and Helper.color.white or Helper.color.red })
					row[4]:setColSpan(10):createDropDown(turretmodes, { startOption = function () return menu.getDropDownTurretModeOption(inputobject, group.path, group.group) end, active = group.operational > 0 })
					row[4].handlers.onDropDownConfirmed = function(_, newturretmode) menu.noupdate = false; C.SetTurretGroupMode(inputobject, group.path, group.group, newturretmode) end
					row[4].handlers.onDropDownActivated = function () menu.noupdate = true end
				end
			end
		end

		local showloadout = defenceinfo_high and (#loadout.component.weapon > 0 or #loadout.component.turret > 0 or #loadout.component.shield > 0 or #loadout.component.engine > 0 or #loadout.macro.thruster > 0 or #loadout.ware.software > 0)
		locrowdata = { "Loadout", ReadText(1001, 9413) }	-- Loadout
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, showloadout)
		if showloadout and menu.extendedinfo[locrowdata[1]] then
			if #loadout.component.weapon > 0 then
				locrowdata = { "Weapons", ReadText(1001, 1301) }	-- Weapons
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					local locmacros = menu.infoCombineLoadoutComponents(loadout.component.weapon)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.turret > 0 then
				locrowdata = { "Turrets", ReadText(1001, 1319) }	-- Turrets
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					local locmacros = menu.infoCombineLoadoutComponents(loadout.component.turret)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.shield > 0 then
				locrowdata = { "Shield Generators", ReadText(1001, 1317) }	-- Shield Generators
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					local locmacros = menu.infoCombineLoadoutComponents(loadout.component.shield)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.engine > 0 then
				locrowdata = { "Engines", ReadText(1001, 1103) }	-- Engines
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					local locmacros = menu.infoCombineLoadoutComponents(loadout.component.engine)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.macro.thruster > 0 then
				locrowdata = { "Thrusters", ReadText(1001, 8001) }	-- Thrusters
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					-- ships normally only have 1 set of thrusters. in case a ship has more, this will list all of them.
					for i, val in ipairs(loadout.macro.thruster) do
						locrowdata = { false, GetMacroData(val, "name") }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.ware.software > 0 then
				locrowdata = { "Software", ReadText(1001, 87) }	-- Software
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					for i, val in ipairs(loadout.ware.software) do
						locrowdata = { false, GetWareData(val, "name") }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
		end
		--print("numweapons: " .. tostring(#loadout.component.weapon) .. ", numturrets: " .. tostring(#loadout.component.turret) .. ", numshields: " .. tostring(#loadout.component.shield) .. ", numengines: " .. tostring(#loadout.component.engine) .. ", numthrusters: " .. tostring(#loadout.macro.thruster) .. ", numsoftware: " .. tostring(#loadout.ware.software))
		--[[
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata] then
			for datatype, content in pairs(loadout) do
				for category, subtable in pairs(content) do
					if #subtable > 0 then
						locrowdata = tostring(category)
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, (#subtable > 0 and true or false), 1, indentsize)
						if menu.extendedinfo[locrowdata] then
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
									print("ERROR: menu_map function menu.setupInfoSubmenuRows(): unhandled datatype: " .. tostring(datatype))
								end
								row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, equipment_mods and GetComponentData(object64, "hasanymod"))
		if equipment_mods and menu.extendedinfo[locrowdata[1]] then
			-- chassis
			local hasinstalledmod, installedmod = Helper.getInstalledModInfo("ship", inputobject)
			if hasinstalledmod then
				locrowdata = { ("EquipmentModsChassis"), ReadText(1001, 8008), installedmod.Name }
				row = menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "ship", installedmod, false, true, true, 1, indentsize)
			end
			-- weapon
			for i, weapon in ipairs(loadout.component.weapon) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("weapon", weapon)
				if hasinstalledmod then
					locrowdata = { ("EquipmentModsWeapon" .. i), ffi.string(C.GetComponentName(weapon)), installedmod.Name }
					row = menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "weapon", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- turret
			for _, turret in ipairs(loadout.component.turret) do
				local hasinstalledmod, installedmod = Helper.getInstalledModInfo("turret", turret)
				if hasinstalledmod then
					locrowdata = { ("EquipmentModsTurret" .. i), ffi.string(C.GetComponentName(turret)), installedmod.Name }
					row = menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "turret", installedmod, false, true, true, 1, indentsize)
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
					row = menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "shield", installedmod, false, true, true, 1, indentsize)
				end
			end
			-- engine
			local hasinstalledmod, installedmod = Helper.getInstalledModInfo("engine", inputobject)
			if hasinstalledmod then
				locrowdata = { ("EquipmentModsEngine"), ffi.string(C.GetComponentName(loadout.component.engine[1])), installedmod.Name }
				row = menu.addEquipmentModInfoRow(inputtable, row, locrowdata, "engine", installedmod, false, true, true, 1, indentsize)
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
				local sliderstart = menu.infocashtransferdetails[2][i] + containercash
				local slidermax = math.max((containercash + playercash), sliderstart)
				-- NB: money is not transferred to the player until after slider changes are confirmed so slidermaxselect can be greater than slidermax.
				-- menu.infocashtransferdetails[2][3-i] relies on the current state where cashcontainers only contains two entries with indices 1 and 2.
				local slidermaxselect = math.min(math.max((containercash + playercash - menu.infocashtransferdetails[2][3-i]), sliderstart), slidermax)
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
					return menu.infoSubmenuUpdateTransferAmount(value, idx, loccash) end
				row[2].handlers.onSliderCellActivated = function() menu.noupdate = true end
				row[2].handlers.onSliderCellDeactivated = function() menu.noupdate = false end
				row[2].handlers.onSliderCellConfirm = function() menu.over = true end
			end

			row = inputtable:addRow("info_updateaccount", { bgColor = Helper.color.transparent })
			row[4]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((menu.infocashtransferdetails[2][1] ~= 0) or (menu.infocashtransferdetails[2][2] ~= 0)) and true or false end }):setText(ReadText(1001, 2821), { halign = "center", fontsize = config.mapFontSize })	-- Confirm
			row[4].handlers.onClick = function() return menu.infoSubmenuUpdateManagerAccount(inputobject, buildstorage) end
			row[9]:setColSpan(5):createButton({ height = config.mapRowHeight, active = function() return ((menu.infocashtransferdetails[2][1] ~= 0) or (menu.infocashtransferdetails[2][2] ~= 0)) and true or false end }):setText(ReadText(1001, 64), { halign = "center", fontsize = config.mapFontSize })	-- Cancel
			row[9].handlers.onClick = function() return menu.resetInfoSubmenu() end
		end

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: menu.infoeditname cleared at the end of this function.
			if isplayerowned and menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- Owner
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(object64, "sector") }	-- Location
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(object64, "hullmax")), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(object64, "hull")), true, 0, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local radarrange = defenceinfo_low and (Helper.round(GetComponentData(object64, "maxradarrange")) / 1000) or unknowntext
			locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9414), (GetComponentData(object64, "tradesubscription") and ReadText(1001, 2617) or ReadText(1001, 2618)) }	-- Updating Trade Offers
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			-- TODO: enable if boarding of stations is ever implemented.
			--[[
			local boardingresistance = 0
			if C.IsComponentClass(inputobject, "station") then
				boardingresistance = tostring(GetComponentData(inputobject, "boardingresistance"))
			end
			local printedboardingresistance = defenceinfo_high and boardingresistance or unknowntext
			locrowdata = { false, ReadText(1001, 1324), printedboardingresistance }	-- Boarding Resistance
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			]]
		end

		locrowdata = { "Personnel", ReadText(1001, 9400) }	-- Personnel
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			local manager = GetComponentData(inputobject, "tradenpc")
			locrowdata = { "Manager", (manager and GetComponentData(manager, "isfemale") and ReadText(20208, 30302) or ReadText(20208, 30301)) }	-- Manager (female), Manager (male)
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, manager and true or false, 1, indentsize)
			if manager and menu.extendedinfo[locrowdata[1]] then
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
						local adjustedskill = math.floor(subtable.value * 5 / 15)
						local printedskill = operatorinfo_details and (string.rep(utf8.char(9733), adjustedskill) .. string.rep(utf8.char(9734), 5 - adjustedskill)) or unknowntext
						row = inputtable:addRow(false, { bgColor = Helper.color.transparent })
						row[2]:setColSpan(2):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (subtable.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
						--row[2]:setColSpan(7):createText(skillname, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = (subtable.relevance > 0) and Helper.standardFontBold or inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
						local locfont = inputfont
						local locfontcolor = Helper.standardColor
						if operatorinfo_details then
							locfont = Helper.starFont
							locfontcolor = Helper.color.brightyellow
						end
						row[4]:setColSpan(10):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
						--row[9]:setColSpan(5):createText(printedskill, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = locfont, color = locfontcolor })
						--row = menu.addInfoSubmenuRow(inputtable, row, { }, false, false, false, 3, indentsize)
					end
				end

				if isplayerowned then
					local recommendedfunds = GetComponentData(inputobject, "productionmoney")
					locrowdata = { "info_station_recommendedfunds", (ReadText(1001, 9434) .. ReadText(1001, 120)), ConvertMoneyString(recommendedfunds, false, true, nil, true) .. " " .. ReadText(1001, 101) }	-- Expected operating budget, :, Cr
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

					local traderestrictions = GetTradeRestrictions(inputobject)
					row = inputtable:addRow("RestrictTrade", { bgColor = Helper.color.transparent })
					row[1]:createCheckBox(traderestrictions.faction, { scaling = false, width = config.mapRowHeight, height = config.mapRowHeight, x = config.mapRowHeight + (2 * Helper.scaleX(indentsize)) })
					row[2]:setColSpan(12):createText(ReadText(1001, 4202), { fontsize = config.mapFontSize, x = Helper.standardTextOffsetx + (config.mapRowHeight * 2) + (3 * indentsize) })	-- Restrict trade to other factions
					row[1].handlers.onClick = function() return menu.checkboxInfoSubmenuRestrictTrade(object64) end
				end
			end

			local shiptrader = GetComponentData(inputobject, "shiptrader")
			if shiptrader then
				shiptrader = ConvertIDTo64Bit(shiptrader)
				locrowdata = { "Ship Trader", (GetComponentData(shiptrader, "isfemale") and ReadText(20208, 30502) or ReadText(20208, 30501)) }	-- Ship Trader (female), Ship Trader (male)
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
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
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (operatorinfo and workforceinfo.current > 0) and true or false, 1, indentsize)
			if operatorinfo and menu.extendedinfo[locrowdata[1]] then
				workforceinfo = C.GetWorkForceInfo(inputobject, "argon")
				locrowdata = {false, ReadText(20202, 101), workforceinfo.current}	-- Argon
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "boron")
				--locrowdata = {false, ReadText(20202, 201), workforceinfo.current}	-- Boron
				--row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				workforceinfo = C.GetWorkForceInfo(inputobject, "paranid")
				locrowdata = {false, ReadText(20202, 401), workforceinfo.current}	-- Paranid
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "split")
				--locrowdata = {false, ReadText(20202, 301), workforceinfo.current}	-- Split
				--row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				workforceinfo = C.GetWorkForceInfo(inputobject, "teladi")
				locrowdata = {false, ReadText(20202, 501), workforceinfo.current}	-- Teladi
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

				--workforceinfo = C.GetWorkForceInfo(inputobject, "terran")
				--locrowdata = {false, ReadText(20202, 701), workforceinfo.current}	-- Terran
				--row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
			end

			local npctable = GetNPCs(inputobject)
			for i = #npctable, 1, -1 do
				if not GetComponentData(npctable[i], "isplayerowned") then
					table.remove(npctable, i)
				end
			end
			locrowdata = { "Player Employees Onboard", ReadText(1001, 9416), #npctable }	-- Player Employees On Board
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (#npctable > 0 and true or false), 1, indentsize)
			if menu.extendedinfo[locrowdata[1]] then
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, storageinfo_warelist and (numwares > 0))
		if storageinfo_warelist and (numwares > 0) and menu.extendedinfo[locrowdata[1]] then
			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(buildstorage, "hullmax")), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(buildstorage, "hull")), true, 0, true) .. " / " .. hull_max .. " (" .. GetComponentData(buildstorage, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " (" .. unknowntext .. "%)")) }	-- Hull
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local loccapacity = storageinfo_capacity and storagemodules.capacity or unknowntext
			local locamount = storageinfo_amounts and storagemodules.stored or unknowntext
			local printedcapacity = loccapacity
			local printedcapacityunit = ""
			if type(printedcapacity) == "number" then
				for i = 1, 4 do
					if (printedcapacity / 1000) < 1 then
						break
					else
						printedcapacity = Helper.round(printedcapacity / 1000)
						if i == 1 then
							printedcapacityunit = ReadText(1001, 300)	-- k
						elseif i == 2 then
							printedcapacityunit = ReadText(1001, 301)	-- M
						elseif i == 3 then
							printedcapacityunit = ReadText(1001, 302)	-- G
						else
							printedcapacityunit = ReadText(1001, 303)	-- T
						end
					end
				end
			end
			printedcapacity = (type(printedcapacity) == "number") and ConvertIntegerString(printedcapacity, true, 0, true)
			local printedamount = locamount
			local printedamountunit = ""
			if type(printedamount) == "number" then
				for i = 1, 4 do
					if (printedamount / 1000) < 1 then
						break
					else
						printedamount = Helper.round(printedamount / 1000)
						if i == 1 then
							printedamountunit = ReadText(1001, 300)	-- k
						elseif i == 2 then
							printedamountunit = ReadText(1001, 301)	-- M
						elseif i == 3 then
							printedamountunit = ReadText(1001, 302)	-- G
						else
							printedamountunit = ReadText(1001, 303)	-- T
						end
					end
				end
			end
			printedamount = (type(printedamount) == "number") and ConvertIntegerString(printedamount, true, 0, true) or printedamount
			local printedfullamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 0, true) or nil
			local printedfullcapacity = (type(loccapacity) == "number") and ConvertIntegerString(loccapacity, true, 0, true) or nil
			local printednumwares = storageinfo_amounts and ConvertIntegerString(numwares, true, 0, true) or unknowntext
			locrowdata = { "info_station_buildstorage_storage", (ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"), (ReadText(1001, 1402) .. ReadText(1001, 120)), (storagemodules.estimated and unknowntext or (printedamount .. printedamountunit .. " / " .. printedcapacity .. printedcapacityunit .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (numwares > 0) and true or false, 1, indentsize, nil, printedfullamount and (printedfullamount .. " / " .. printedfullcapacity .. " " .. ReadText(1001, 110)) or nil)	-- m^3
			if menu.extendedinfo[locrowdata[1]] then
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
		table.sort(productiontable, menu.productionSorter)
		locrowdata = { "Production", ReadText(1001, 1600) }	-- Production
		-- switch next two commented-out lines below if we want to make the number of production modules available even if all other information is crossed out.
		--row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (#productiontable > 0) and true or false)
		--if #productiontable > 0 and menu.extendedinfo[locrowdata[1]] then
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, productioninfo_products and (#productiontable > 0) and true or false)
		if productioninfo_products and #productiontable > 0 and menu.extendedinfo[locrowdata[1]] then
			for i, productionmethod in ipairs(productiontable) do
				for j, productionmodule in ipairs(productionmethod) do
					if #productionmodule.products > 0 then
						locrowdata = { ("Method" .. i .. "Module" .. j), productioninfo_products and (productionmodule.modulename .. " " .. j) or unknowntext }	-- Production
						-- switch next two commented-out lines below if we want to make the individual production module sections accessible even if all information is crossed out.
						--row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true, 1, indentsize)
						--if menu.extendedinfo[locrowdata[1]] then
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, productioninfo_products and true or false, 1, indentsize)
						if productioninfo_products and menu.extendedinfo[locrowdata[1]] then
							locrowdata = { false, (ReadText(1001, 9418) .. ReadText(1001, 120)) }	-- Wares produced per cycle, :
							row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							for _, product in ipairs(productionmodule.products) do
								locrowdata = { false, productioninfo_products and tostring(product.name) or unknowntext, productioninfo_rate and tostring(product.cycle) or unknowntext }
								row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)
							end

							-- TODO: @Nick consider: make efficiency dynamic as well to reflect changes?
							locrowdata = { false, (ReadText(1001, 1602) .. ReadText(1001, 120)), (productioninfo_rate and (productionmodule.cycletimeremaining > 0 and math.floor(productionmodule.efficiency * 100) or 0) .. "%" or unknowntext) }	-- Efficiency, :
							row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)

							local formattedtime = ConvertTimeString(productionmodule.cycletime, "%h:%M:%S")
							locrowdata = { false, ReadText(1001, 9419), productioninfo_time and formattedtime or unknowntext }	-- Time per cycle, d, h, min, s
							--locrowdata = { false, "Time per cycle", Helper.timeDuration(productionmodule.cycletime) }
							row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							locrowdata = { false, ReadText(1001, 9420) }	-- Time until current cycle completion, d, h, min, s
							row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
							row[2]:setColSpan(7):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = Helper.standardTextOffsetx + (3 * indentsize) })
							--row[9]:setColSpan(5):createText(function() return menu.infoSubmenuUpdateProductionTime(object64, productionmodule.moduleindex) end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont) })
							row[9]:setColSpan(5):createText(function() return productioninfo_rate and menu.infoSubmenuUpdateProductionTime(object64, productionmodule.moduleindex) or unknowntext end, { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont })
							--locrowdata = { false, "Time until current cycle completion", function() return Helper.timeDuration(productionmodule.cycletimeremaining) end }
							--row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							locrowdata = { false, (ReadText(1001, 9421) .. ReadText(1001, 120)) }	--Resources needed per cycle, :
							row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)

							for _, resource in ipairs(productionmodule.primaryresources) do
								locrowdata = { false, productioninfo_resources and tostring(resource.name) or unknowntext, productioninfo_rate and tostring(resource.cycle) or unknowntext }
								row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 3, indentsize)
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
		local printedcapacity = storageinfo_capacity and loccapacity or unknowntext
		local printedcapacityunit = ""
		if type(printedcapacity) == "number" then
			for i = 1, 4 do
				if (printedcapacity / 1000) < 1 then
					break
				else
					printedcapacity = Helper.round(printedcapacity / 1000)
					if i == 1 then
						printedcapacityunit = ReadText(1001, 300)	-- k
					elseif i == 2 then
						printedcapacityunit = ReadText(1001, 301)	-- M
					elseif i == 3 then
						printedcapacityunit = ReadText(1001, 302)	-- G
					else
						printedcapacityunit = ReadText(1001, 303)	-- T
					end
				end
			end
		end
		if type(printedcapacity) == "number" then
			printedcapacity = ConvertIntegerString(printedcapacity, true, 0, true)
		end
		local printedamount = locamount
		local printedamountunit = ""
		if type(printedamount) == "number" then
			for i = 1, 4 do
				if (printedamount / 1000) < 1 then
					break
				else
					printedamount = Helper.round(printedamount / 1000)
					if i == 1 then
						printedamountunit = ReadText(1001, 300)	-- k
					elseif i == 2 then
						printedamountunit = ReadText(1001, 301)	-- M
					elseif i == 3 then
						printedamountunit = ReadText(1001, 302)	-- G
					else
						printedamountunit = ReadText(1001, 303)	-- T
					end
				end
			end
		end
		printedamount = (type(printedamount) == "number") and ConvertIntegerString(printedamount, true, 0, true) or printedamount
		local printedfullamount = (type(locamount) == "number") and ConvertIntegerString(locamount, true, 0, true) or nil
		local printedfullcapacity = (type(loccapacity) == "number") and ConvertIntegerString(loccapacity, true, 0, true) or nil
		local printednumwares = storageinfo_amounts and ConvertIntegerString(numwares, true, 0, true) or unknowntext
		locrowdata = { "Storage", (ReadText(1001, 1400) .. " (" .. printednumwares .. " " .. ((printednumwares == "1") and ReadText(1001, 45) or ReadText(1001, 46)) .. ")"), (ReadText(1001, 1402) .. ReadText(1001, 120)), (storagemodules.estimated and unknowntext or (printedamount .. printedamountunit .. " / " .. printedcapacity .. printedcapacityunit .. " " .. ReadText(1001, 110))) }	-- Storage, Ware, Wares, Filled Capacity, :, m^3
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (storageinfo_warelist and numwares > 0) and true or false, nil, nil, nil, printedfullamount and (printedfullamount .. " / " .. printedfullcapacity .. " " .. ReadText(1001, 110)) or nil)	-- m^3
		if storageinfo_warelist and (numwares > 0) and menu.extendedinfo[locrowdata[1]] then
			for i, usagecat in ipairs(cargocatindex) do
				if (cargotable[usagecat].numcatwares > 0) then
					--print("adding category: " .. cargotable[usagecat].text)
					locrowdata = { false, (cargotable[usagecat].text .. ReadText(1001, 120)) }	-- :
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata)
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, numdockedships > 0 and true or false)
		if menu.extendedinfo[locrowdata[1]] then
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
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (defenceinfo_high and totalnummissiles > 0) and true or false)
		if defenceinfo_high and menu.extendedinfo[locrowdata[1]] then
			for i = 0, nummissiletypes - 1 do
				locrowdata = { false, GetMacroData(ffi.string(missilestoragetable[i].macro), "name"), (tostring(missilestoragetable[i].amount) .. " / " .. tostring(missilestoragetable[i].capacity)) }
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end

		local unitstoragetable = {capacity = 0, stored = 0}
		if C.IsComponentClass(inputobject, "defensible") then
			unitstoragetable = GetUnitStorageData(inputobject)
		end
		local locunitcapacity = unitinfo_capacity and tostring(unitstoragetable.capacity) or unknowntext
		local locunitcount = unitinfo_capacity and tostring(unitstoragetable.stored) or unknowntext
		locrowdata = {"Drones", ReadText(1001, 8), (locunitcount .. " / " .. locunitcapacity)}	-- Drones
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, (unitinfo_details and unitstoragetable.stored > 0) and true or false)
		if unitinfo_details and menu.extendedinfo[locrowdata[1]] then
			for i = 1, #unitstoragetable do
				if unitstoragetable[i].amount > 0 or unitstoragetable[i].unavailable > 0 then
					locrowdata = { false, unitstoragetable[i].name, (unitstoragetable[i].amount .. " / " .. unitstoragetable.capacity .. " (" .. unitstoragetable[i].unavailable .. " Unavailable)") }
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
				end
			end
		end

		local showloadout = defenceinfo_high and (#loadout.component.turret > 0 or #loadout.component.shield > 0)
		locrowdata = { "Loadout", ReadText(1001, 9413) }	-- Loadout 
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, showloadout)
		if showloadout and menu.extendedinfo[locrowdata[1]] then
			if #loadout.component.turret > 0 then
				locrowdata = { "Turrets", ReadText(1001, 1319) }	-- turrets
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					local locmacros = menu.infoCombineLoadoutComponents(loadout.component.turret)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
			if #loadout.component.shield > 0 then
				locrowdata = { "Shield Generators", ReadText(1001, 1317) }	-- Shield Generators
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, true, true, 1, indentsize)
				if menu.extendedinfo[locrowdata[1]] then
					local locmacros = menu.infoCombineLoadoutComponents(loadout.component.shield)
					local i = 0
					for macro, num in pairs(locmacros) do
						i = i + 1
						locrowdata = { false, GetMacroData(macro, "name"), num }
						row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
					end
				end
			end
		end

		-- TODO: figure out and implement economy statistics
		locrowdata = { "Economy Statistics", ReadText(1001, 1131) }	-- Economy Statistics
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, false)

	elseif mode == "sector" then
		--print("sector ID: " .. tostring(inputobject))
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)
		row[1].properties.color = titlecolor

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			if isplayerowned and menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(object64, "ownername")) }	-- Owner
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

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
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9042), (numstations > 0 and numstations or 0) }	-- Known Stations
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9050), maxproductgrp }	-- Main Production
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end

		locrowdata = { "Natural Resources", ReadText(1001, 9423) }	-- Natural Resources
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			local sunlight = (GetComponentData(object64, "sunlight") * 100 .. "%")
			locrowdata = { false, ReadText(1001, 2412), sunlight }	-- Sunlight
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			-- TODO: Add Region info: NB: Matthias says that yield numbers for regions could be too big to be useful, and that retrieving that info is very inefficient. But we'll try when the function is up.

		end
	elseif mode == "gate" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			local isgateactive = GetComponentData(object64, "isactive")
			local gatedestinationid
			local gatedestination = unknowntext
			if isgateactive then
				gatedestinationid = GetComponentData(GetComponentData(object64, "destination"), "sectorid")
				local gatedestinationid64 = ConvertStringTo64Bit(tostring(gatedestinationid))
				gatedestination = C.IsInfoUnlockedForPlayer(gatedestinationid64, "name") and ffi.string(C.GetComponentName(gatedestinationid64)) or unknowntext
			end
			locrowdata = { false, ReadText(1001, 3215), tostring(gatedestination) }	-- (gate) Destination
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local destinationowner = unknowntext
			if gatedestination ~= unknowntext then
				destinationowner = GetComponentData(gatedestinationid, "ownername")
			end
			locrowdata = { false, ReadText(1001, 9424), tostring(destinationowner) }	-- Destination Owner
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 9425), (isgateactive and ReadText(1001, 2617) or ReadText(1001, 2618)) }	-- Active, Yes, No
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end
	elseif mode == "deployable" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			locrowdata = { "info_name", ReadText(1001, 2809), objectname }	-- Name
			-- NB: menu.infoeditname cleared at the end of this function.
			if isplayerowned and menu.infoeditname then
				row = inputtable:addRow(locrowdata[1], { bgColor = Helper.color.transparent })
				row[1]:setBackgroundColSpan(13)
				row[2]:setColSpan(2):createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx + (1 * indentsize) })
				row[4]:setColSpan(10):createEditBox({ height = config.mapRowHeight, defaultText = objectname })
				row[4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return menu.infoChangeObjectName(inputobject, text, textchanged) end
			else
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end

			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(inputobject, "ownername")) }	-- Owner
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(inputobject, "sector") }	-- Location
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hullmax")), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hull")), true, 0, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(inputobject, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local radarrange = defenceinfo_low and GetComponentData(inputobject, "maxradarrange") or unknowntext

			if C.IsComponentClass(menu.infoSubmenuObject, "mine") then
				-- add if mines are made selectable in the map again:
				--	detonation output (s), tracking capability (s), friend/foe (s), proximity (s)
			elseif C.IsComponentClass(menu.infoSubmenuObject, "resourceprobe") then
				if radarrange and radarrange ~= unknowntext then
					radarrange = Helper.round(radarrange / 1000)
				end
				locrowdata = { "info_radarrange", ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 9082)) }	-- Scannning Range, km
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			elseif C.IsComponentClass(menu.infoSubmenuObject, "satellite") then
				if radarrange and radarrange ~= unknowntext then
					radarrange = Helper.round(radarrange / 1000)
				end
				locrowdata = { false, ReadText(1001, 2426), (radarrange .. " " .. ReadText(1001, 108)) }	-- Radar Range, km
				row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
			end
		end
	elseif mode == "missionboard" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			locrowdata = { false, ReadText(1001, 9040), Helper.unlockInfo(ownerinfo, GetComponentData(inputobject, "ownername")) }	-- Owner
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			locrowdata = { false, ReadText(1001, 2943), GetComponentData(inputobject, "sector") }	-- Location
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local hull_max = defenceinfo_low and ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hullmax")), true, 0, true) or unknowntext
			locrowdata = { false, ReadText(1001, 1), (defenceinfo_high and (function() return (ConvertIntegerString(Helper.round(GetComponentData(inputobject, "hull")), true, 0, true) .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. GetComponentData(object64, "hullpercent") .. "%)") end) or (unknowntext .. " / " .. hull_max .. " " .. ReadText(1001, 118) .. " (" .. unknowntext .. "%)")) }	-- Hull, MJ
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)
		end
	elseif mode == "asteroid" then
		local row = inputtable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
		row[1]:setColSpan(13):createText(objectname, Helper.headerRow1Properties)

		local locrowdata = { "info_generalinformation", ReadText(1001, 1111) }	-- General Information
		row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, true, true, true)
		if menu.extendedinfo[locrowdata[1]] then
			local rawlength = GetComponentData(inputobject, "length")
			local rawwidth = GetComponentData(inputobject, "width")
			local rawheight = GetComponentData(inputobject, "height")
			local loclength = ConvertIntegerString(rawlength, true, 0, true)
			local locwidth = ConvertIntegerString(rawwidth, true, 0, true)
			local locheight = ConvertIntegerString(rawheight, true, 0, true)
			locrowdata = { false, ReadText(1001, 9229), (loclength .. ReadText(1001, 107) .. " " .. ReadText(1001, 42) .. " " .. locwidth .. ReadText(1001, 107) .. " " .. ReadText(1001, 42) .. " " .. locheight .. ReadText(1001, 107)) }	-- TEMPTEXT, m, x
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

			local rawvolume = rawlength * rawwidth * rawheight
			local locvolume = ConvertIntegerString(rawvolume, true, 0, true)
			locrowdata = { false, ReadText(1001, 1407), (locvolume .. " " .. ReadText(1001, 110)) }	-- Volume, m^3
			row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

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
					row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 1, indentsize)

					for i, ware in ipairs(wares) do
						if ware.amount > 0 then
							local warename = GetWareData(ware.ware, "name")
							locrowdata = { false, warename, ware.amount }
							row = menu.addInfoSubmenuRow(inputtable, row, locrowdata, false, false, false, 2, indentsize)
						end
					end
				end
			end
		end
	else
		DebugError("menu.setupInfoSubmenuRows(): called with unsupported mode: " .. tostring(mode) .. ".")
	end

	if menu.infoeditname then
		menu.infoeditname = nil
	end
end

-- NB: numcolumns has to match number of entries in inputrowdata.
function menu.addInfoSubmenuRow(inputtable, inputrow, inputrowdata, isheader, withbutton, buttonactive, indent, indentsize, inputfont, mouseovertext)
	if not indent then
		indent = 0
	end
	if not indentsize then
		indentsize = Helper.standardIndentStep
	end

	if not inputfont then
		inputfont = Helper.standardFont
		if isheader then
			inputfont = Helper.standardFontBold
		end
	end

	local rowbgcolor = Helper.defaultSimpleBackgroundColor
	if not isheader then
		rowbgcolor = Helper.color.transparent
	end

	if not mouseovertext then
		mouseovertext = ""
	end

	if type(inputrowdata) ~= "table" then
		DebugError("menu.addInfoSubmenuRow(): inputrowdata is not a table. inputrowdata: " .. tostring(inputrowdata) .. ".")
		inputrow = inputtable:addRow(inputrowdata, { bgColor = rowbgcolor })
	else
		inputrow = inputtable:addRow(inputrowdata[1], { bgColor = rowbgcolor })
	end

	if not buttonactive then
		buttonactive = false
	end

	if withbutton then
		inputrow[1]:createButton({ height = config.mapRowHeight, active = buttonactive }):setText(function() return (buttonactive and menu.extendedinfo[inputrowdata[1]]) and "-" or "+" end, { halign = "center" })
		inputrow[1].handlers.onClick = function() return menu.buttonExtendInfo(inputrowdata[1]) end
		inputrow[1].properties.uiTriggerID = inputrowdata[1] .. "_toggle"
	end

	for i, val in ipairs(inputrowdata) do
		if i ~= 1 and type(val) == "number" then
			inputrowdata[i] = tostring(val)
		end
	end

	local xoffset = Helper.standardTextOffsetx + (indent * indentsize)

	if type(inputrowdata) ~= "table" then
		inputrow[2]:setColSpan(12)
		inputrow[2]:createText(inputrowdata, { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = xoffset, mouseOverText = mouseovertext })
	else
		inputrow[2]:setBackgroundColSpan(12)
		if #inputrowdata == 2 then
			inputrow[2]:setColSpan(12):createText(inputrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = xoffset, mouseOverText = mouseovertext })
		elseif #inputrowdata == 3 then
			local row2span = 2
			if (type(inputrowdata[2]) ~= "function") and (type(inputrowdata[3]) ~= "function") then
				local str1width = C.GetTextWidth(inputrowdata[2], inputfont, Helper.scaleFont(inputfont, config.mapFontSize)) + Helper.scaleX(xoffset)
				local str2width = C.GetTextWidth(inputrowdata[3], inputfont, Helper.scaleFont(inputfont, config.mapFontSize))
				if (str1width > (inputrow[2]:getWidth() + inputrow[3]:getWidth() + Helper.borderSize)) and (str1width > str2width) then
					row2span = 7
				elseif str1width < inputrow[2]:getWidth() then
					row2span = 1
				end
			end
			inputrow[2]:setColSpan(row2span):createText(inputrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = xoffset, mouseOverText = mouseovertext })
			inputrow[14-(12-row2span)]:setColSpan(12-row2span):createText(inputrowdata[3], { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, mouseOverText = mouseovertext })
		elseif #inputrowdata == 4 then
			inputrow[2]:setColSpan(2):createText(inputrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = xoffset, mouseOverText = mouseovertext })
			inputrow[4]:setColSpan(5):createText(inputrowdata[3], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, mouseOverText = mouseovertext })
			inputrow[9]:setColSpan(5):createText(inputrowdata[4], { halign = "right", minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, mouseOverText = mouseovertext })
		elseif #inputrowdata == 5 then
			inputrow[2]:createText(inputrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, x = xoffset, mouseOverText = mouseovertext })
			inputrow[3]:createText(inputrowdata[3], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, mouseOverText = mouseovertext })
			inputrow[4]:setColSpan(5):createText(inputrowdata[4], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, mouseOverText = mouseovertext })
			inputrow[9]:setColSpan(5):createText(inputrowdata[5], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = inputfont, mouseOverText = mouseovertext })
		else
			DebugError("menu.addInfoSubmenuRow(): inputrowdata has an invalid number of entries: " .. tostring(#inputrowdata) .. ". only up to four entries supported.")
		end
	end

	return inputrow
end

function menu.addEquipmentModInfoRow(ftable, row, rowdata, modclass, installedmod, isheader, withbutton, buttonactive, indent, indentsize, inputfont)
	local color = Helper.modQualities[installedmod.Quality].color
	rowdata[2] = rowdata[2] .. "  \27[" .. Helper.modQualities[installedmod.Quality].icon2 .. "]"
	rowdata[3] = string.format("\027#FF%02x%02x%02x#", color.r, color.g, color.b) .. rowdata[3]
	row = menu.addInfoSubmenuRow(ftable, row, rowdata, isheader, withbutton, buttonactive, indent, indentsize, inputfont)
	if menu.extendedinfo[rowdata[1]] then
		-- default property
		for i, property in ipairs(Helper.modProperties[modclass]) do
			if property.key == installedmod.PropertyType then
				if installedmod[property.key] ~= property.basevalue then
					local effectcolor
					if installedmod[property.key] > property.basevalue then
						effectcolor = property.pos_effect and Helper.color.green or Helper.color.red
					else
						effectcolor = property.pos_effect and Helper.color.red or Helper.color.green
					end

					local rowdata = { rowdata[1] .. property.key, property.text, string.format("\027#FF%02x%02x%02x#", effectcolor.r, effectcolor.g, effectcolor.b) .. property.eval(installedmod[property.key]) }
					row = menu.addInfoSubmenuRow(ftable, row, rowdata, false, false, false, indent + 1, indentsize, Helper.standardFontBold)
				end
				break
			end
		end
		-- other properties
		for i, property in ipairs(Helper.modProperties[modclass]) do
			if property.key ~= installedmod.PropertyType then
				if installedmod[property.key] ~= property.basevalue then
					local effectcolor
					if installedmod[property.key] > property.basevalue then
						effectcolor = property.pos_effect and Helper.color.green or Helper.color.red
					else
						effectcolor = property.pos_effect and Helper.color.red or Helper.color.green
					end

					local rowdata = { rowdata[1] .. property.key, property.text, string.format("\027#FF%02x%02x%02x#", effectcolor.r, effectcolor.g, effectcolor.b) .. property.eval(installedmod[property.key]) }
					row = menu.addInfoSubmenuRow(ftable, row, rowdata, false, false, false, indent + 1, indentsize)
				end
			end
		end
	end

	return row
end

function menu.resetInfoSubmenu()
	menu.resetcrew = true
	menu.infocashtransferdetails[2] = {0, 0}
	-- TEMP for testing
	menu.infodrops = {}

	menu.settoprow = GetTopRow(menu.infoTable)
	menu.refreshInfoFrame()
end

function menu.infoSubmenuPrepareCrewInfo()
	local locobject = menu.infoSubmenuObject
	if not C.IsComponentClass(locobject, "ship") then
		DebugError("menu.infoSubmenuPrepareCrewInfo() called on " .. ffi.string(C.GetComponentName(locobject)) .. " which is not of class ship.")
	else
		--menu.infocrew = { 
		--	["object"] = nil, 
		--	["capacity"] = 0, 
		--	["total"] = 0, 
		--	["current"] = { ["total"] = 0, ["roles"] = {} }, 
		--	["unassigned"] = { ["total"] = 0, ["persons"] = {} }, 
		--	["reassigned"] = { ["total"] = 0, ["roles"] = {} } 
		--}
		menu.infocrew.object = locobject
		menu.infocrew.current.total = 0
		menu.infocrew.unassigned.total = 0
		menu.infocrew.reassigned.total = 0
		menu.infocrew.total = 0
		menu.infocrew.capacity = C.GetPeopleCapacity(locobject, "", true)

		local numpeople = C.GetNumAllRoles()
		local peopletable = ffi.new("PeopleInfo[?]", numpeople)
		numpeople = C.GetPeople(peopletable, numpeople, locobject)
		for i = 0, numpeople - 1 do
			menu.infocrew.current.roles[i + 1] = { id = ffi.string(peopletable[i].id), name = ffi.string(peopletable[i].name), desc = ffi.string(peopletable[i].desc), amount = peopletable[i].amount, canhire = peopletable[i].canhire, numtiers = peopletable[i].numtiers, tiers = {} }
			menu.infocrew.reassigned.roles[i + 1] = { id = ffi.string(peopletable[i].id), name = ffi.string(peopletable[i].name), desc = ffi.string(peopletable[i].desc), amount = 0, canhire = peopletable[i].canhire, numtiers = peopletable[i].numtiers, tiers = {} }
			menu.infocrew.current.total = menu.infocrew.current.total + peopletable[i].amount
			menu.infocrew.total = menu.infocrew.current.total + menu.infocrew.unassigned.total + menu.infocrew.reassigned.total
		
			local numtiers = peopletable[i].numtiers
			local tiertable = ffi.new("RoleTierData[?]", numtiers)
			numtiers = C.GetRoleTiers(tiertable, numtiers, locobject, menu.infocrew.current.roles[i + 1].id)
			for j = 0, numtiers - 1 do
				menu.infocrew.current.roles[i + 1].tiers[j + 1] = { name = ffi.string(tiertable[j].name), skilllevel = tiertable[j].skilllevel, amount = tiertable[j].amount, persons = {} }
				menu.infocrew.reassigned.roles[i + 1].tiers[j + 1] = { name = ffi.string(tiertable[j].name), skilllevel = tiertable[j].skilllevel, amount = 0, persons = {} }

				local numpersons = tiertable[j].amount
				local persontable = ffi.new("NPCSeed[?]", numpersons)
				numpersons = C.GetRoleTierNPCs(persontable, numpersons, locobject, menu.infocrew.current.roles[i + 1].id, menu.infocrew.current.roles[i + 1].tiers[j + 1].skilllevel)
				for k = 0, numpersons - 1 do
					table.insert(menu.infocrew.current.roles[i + 1].tiers[j + 1].persons, persontable[k])
				end
			end
			if numtiers == 0 then
				menu.infocrew.current.roles[i + 1].tiers[1] = { hidden = true, name = "temp", skilllevel = 0, amount = peopletable[i].amount, persons = {} }
				menu.infocrew.reassigned.roles[i + 1].tiers[1] = { hidden = true, name = "temp", skilllevel = 0, amount = 0, persons = {} }

				local numpersons = peopletable[i].amount
				local persontable = ffi.new("NPCSeed[?]", numpersons)
				numpersons = C.GetRoleTierNPCs(persontable, numpersons, locobject, menu.infocrew.current.roles[i + 1].id, 0)
				for k = 0, numpersons - 1 do
					table.insert(menu.infocrew.current.roles[i + 1].tiers[1].persons, persontable[k])
				end
			end
		end
		for i, roletable in ipairs(menu.infocrew.current.roles) do
			for j, tiertable in ipairs(roletable.tiers) do
				--int32_t GetPersonCombinedSkill(UniverseID controllableid, NPCSeed person, const char* role, const char* postid);
				table.sort(tiertable.persons, function(a, b) return C.GetPersonCombinedSkill(menu.infoSubmenuObject, a, nil, nil) > C.GetPersonCombinedSkill(menu.infoSubmenuObject, b, nil, nil) end)
			end
		end
	end
end

function menu.productionSorter(a, b)
	local aname = a[1].products[1] and a[1].products[1].name or ""
	local bname = b[1].products[1] and b[1].products[1].name or ""
	return aname < bname
end

-- TEMP for testing
function menu.infoSubmenuConfirmDrops(object)
	local isplayeroccupiedship = (object == C.GetPlayerOccupiedShipID())
	for ware, amount in pairs(menu.infodrops) do
		if amount > 0 then
			local s = (amount > 1) and "s" or ""
			if isplayeroccupiedship then
				SignalObject(ConvertStringTo64Bit(tostring(C.GetPlayerID())), "playerdrop", {ware, amount})
			elseif C.DropCargo(object, ware, amount) then
				--print(ffi.string(C.GetComponentName(object)) .. " successfully dropped " .. tostring(amount) .. " unit" .. s .. " of " .. tostring(ware) .. ".")
			else
				print(ffi.string(C.GetComponentName(object)) .. "'s attempt to drop " .. tostring(amount) .. " unit" .. s .. " of " .. tostring(ware) .. " was unsuccessful.")
			end
		end
	end
	menu.infodrops = {}
	menu.refreshInfoFrame()
end

function menu.infoSubmenuUpdateDrops(ware, oldamount, newamount)
	menu.infodrops[ware] = oldamount - newamount
end

function menu.infoSubmenuUpdateCrewChanges(newamount, slidertable, sliderindex, istier, tierindex, sliderupdatetable)
	--print("peopletype: " .. ffi.string(slidertable[sliderindex].name) .. ", current actual amount: " .. (menu.infocrew.current.roles[slidertable[sliderindex].roleindex].amount + menu.infocrew.reassigned.roles[slidertable[sliderindex].roleindex].amount) .. ", new amount: " .. newamount)
	local oldamount = menu.infocrew.current.roles[slidertable[sliderindex].roleindex].amount + menu.infocrew.reassigned.roles[slidertable[sliderindex].roleindex].amount
	if istier then
		oldamount = menu.infocrew.current.roles[slidertable[sliderindex].roleindex].tiers[tierindex].amount + menu.infocrew.reassigned.roles[slidertable[sliderindex].roleindex].tiers[tierindex].amount
	end
	local amountchange = newamount - oldamount
	local linkedtiers = {}
	-- TODO: review. there was a problem when reducing from tier after reducing from category and adding back from category without confirming. might get fixed after slider updating is fixed.
	--print("newamount: " .. newamount .. ", oldamount: " .. oldamount .. ", amount to change: " .. amountchange)

	if amountchange < 0 then
		-- reduce
		--print("reducing")
		local amountchanged = 0
		local done
		if menu.infocrew.reassigned.total > 0 then
			for i, roletable in ipairs(menu.infocrew.reassigned.roles) do
				-- can query: .id, .name, .desc, .amount, .numtiers, .canhire
				if roletable.id == slidertable[sliderindex].id then
					for j, tiertable in ipairs(roletable.tiers) do
						--print("role: " .. tostring(roletable.id) .. ", tier: " .. tostring(j))
						local go
						if istier then
							-- can query: name, skilllevel, amount
							if tiertable.skilllevel == slidertable[sliderindex].tiers[tierindex].skilllevel then
								go = true
							end
						else
							go = true
						end
						if go then
							for k = #tiertable.persons, 1, -1 do
								if amountchanged ~= amountchange then
									if type(tiertable.persons[k].person) == "table" then
										DebugError("menu.infoSubmenuUpdateCrewChanges(): person " .. k .. " from reassigned is of type table.")
									end
									table.insert(menu.infocrew.unassigned.persons, { ["person"] = tiertable.persons[k].person, ["oldrole"] = roletable.id })
									menu.infocrew.unassigned.total = menu.infocrew.unassigned.total + 1

									table.remove(menu.infocrew.reassigned.roles[i].tiers[j].persons, k)
									menu.infocrew.reassigned.roles[i].tiers[j].amount = menu.infocrew.reassigned.roles[i].tiers[j].amount - 1
									menu.infocrew.reassigned.roles[i].amount = menu.infocrew.reassigned.roles[i].amount - 1
									menu.infocrew.reassigned.total = menu.infocrew.reassigned.total - 1

									if #linkedtiers > 0 then
										local linkdone
										for l, linkedtier in ipairs(linkedtiers) do
											if linkedtier.index == j then
												linkedtier.amount = linkedtier.amount - 1
												linkdone = true
												break
											end
										end
										if not linkdone then
											table.insert(linkedtiers, { index = j, amount = -1 })
										end
									else
										table.insert(linkedtiers, { index = j, amount = -1 })
									end
									amountchanged = amountchanged - 1
								else
									done = true
									break
								end
							end
							go = nil
						end
						if done then
							break
						end
					end
				end
			end
		end
		if not done then
			for i, roletable in ipairs(menu.infocrew.current.roles) do
				-- can query: .id, .name, .desc, .amount, .numtiers, .canhire
				if roletable.id == slidertable[sliderindex].id then
					for j, tiertable in ipairs(roletable.tiers) do
						--print("role: " .. tostring(roletable.id) .. ", tier: " .. tostring(j))
						local go
						if istier then
							-- can query: name, skilllevel, amount
							if tiertable.skilllevel == slidertable[sliderindex].tiers[tierindex].skilllevel then
								go = true
							end
						else
							go = true
						end
						if go then
							for k = #tiertable.persons, 1, -1 do
								if amountchanged ~= amountchange then
									if type(tiertable.persons[k]) == "table" then
										DebugError("menu.infoSubmenuUpdateCrewChanges(): person " .. k .. " from current is of type table.")
									end
									table.insert(menu.infocrew.unassigned.persons, { ["person"] = tiertable.persons[k], ["oldrole"] = roletable.id })
									menu.infocrew.unassigned.total = menu.infocrew.unassigned.total + 1

									table.remove(menu.infocrew.current.roles[i].tiers[j].persons, k)
									menu.infocrew.current.roles[i].tiers[j].amount = menu.infocrew.current.roles[i].tiers[j].amount - 1
									menu.infocrew.current.roles[i].amount = menu.infocrew.current.roles[i].amount - 1
									menu.infocrew.current.total = menu.infocrew.current.total - 1

									if #linkedtiers > 0 then
										local linkdone
										for l, linkedtier in ipairs(linkedtiers) do
											if linkedtier.index == j then
												linkedtier.amount = linkedtier.amount - 1
												linkdone = true
												break
											end
										end
										if not linkdone then
											table.insert(linkedtiers, { index = j, amount = -1 })
										end
									else
										table.insert(linkedtiers, { index = j, amount = -1 })
									end
									amountchanged = amountchanged - 1
								else
									done = true
									break
								end
							end
							go = nil
						end
						if done then
							break
						end
					end
				end
			end
		end
	else
		-- add
		--print("adding")
		if menu.infocrew.unassigned.total < 1 then
			DebugError("menu.infoSubmenuUpdateCrewChanges(): tried reallocating crew with none unassigned.")
		else
			for i, roletable in ipairs(menu.infocrew.current.roles) do
				if roletable.id == slidertable[sliderindex].id then
					local amountchanged = 0
					local done
					for j = #menu.infocrew.unassigned.persons, 1, -1 do
						if amountchanged ~= amountchange then
							local newtier = C.GetPersonTier(menu.infocrew.unassigned.persons[j].person, roletable.id, menu.infoSubmenuObject)
							local newcombinedskill = C.GetPersonCombinedSkill(menu.infoSubmenuObject, menu.infocrew.unassigned.persons[j].person, roletable.id, nil)
							if menu.infocrew.reassigned.roles[i].id ~= roletable.id then
								DebugError("menu.infoSubmenuUpdateCrewChanges(): reassigned role id: " .. tostring(menu.infocrew.reassigned.roles[i].id) .. " does not match current role id: " .. tostring(roletable.id) .. ".")
							end
							for k, tiertable in ipairs(roletable.tiers) do
								if newtier == tiertable.skilllevel then
									table.insert(menu.infocrew.reassigned.roles[i].tiers[k].persons, { ["person"] = menu.infocrew.unassigned.persons[j].person, ["oldrole"] = menu.infocrew.unassigned.persons[j].oldrole, ["newrole"] = roletable.id, ["newtier"] = newtier, ["combinedskill"] = newcombinedskill })
									menu.infocrew.reassigned.roles[i].tiers[k].amount = menu.infocrew.reassigned.roles[i].tiers[k].amount + 1
									menu.infocrew.reassigned.roles[i].amount = menu.infocrew.reassigned.roles[i].amount + 1
									menu.infocrew.reassigned.total = menu.infocrew.reassigned.total + 1

									if #linkedtiers > 0 then
										local linkdone
										for l, linkedtier in ipairs(linkedtiers) do
											if linkedtier.index == k then
												linkedtier.amount = linkedtier.amount + 1
												linkdone = true
												break
											end
										end
										if not linkdone then
											table.insert(linkedtiers, { index = k, amount = 1 })
										end
									else
										table.insert(linkedtiers, { index = k, amount = 1 })
									end
									break
								end
							end

							table.remove(menu.infocrew.unassigned.persons, j)
							menu.infocrew.unassigned.total = menu.infocrew.unassigned.total - 1

							amountchanged = amountchanged + 1
						else
							done = true
							break
						end
					end
					if done then
						break
					end
				end
			end
		end
	end

	-- update all linked sliders.
	--local sliderupdatetable = { ["table"] = inputtable, ["row"] = role.row, ["col"] = 2, ["tierrows"] = {}, ["text"] = role.name, ["xoffset"] = role.row[2].properties.x, ["width"] = role.row[2].properties.width }
	if type(sliderupdatetable) == "table" and #sliderupdatetable.tierrows > 0 then
		-- update linked category slider
		local linkedrows = { {["row"] = sliderupdatetable.row, ["amount"] = sliderupdatetable.row[sliderupdatetable.col].properties.start + amountchange} }
		--local linkedrows = { {["row"] = sliderupdatetable.row, ["amount"] = newamount} }
		if not istier then
			-- update linked tier slider/s
			if linkedtiers then
				linkedrows = {}
				for i, linkedtier in ipairs(linkedtiers) do
					table.insert(linkedrows, {["row"] = sliderupdatetable.tierrows[linkedtier.index].row, ["amount"] = sliderupdatetable.tierrows[linkedtier.index].row[sliderupdatetable.col].properties.start + linkedtier.amount})
				end
			end
		end
		for i, linkedrow in ipairs(linkedrows) do
			local newlinkedslidervalue = linkedrow.amount
			--print("is tier? " .. tostring(istier) .. ", linked row: " .. tostring(linkedrow.row.index) .. ", category row: " .. tostring(sliderupdatetable.row.index))
			linkedrow.row[sliderupdatetable.col].properties.start = newlinkedslidervalue
			if istier then
				sliderupdatetable.tierrows[tierindex].row[sliderupdatetable.col].properties.start = newamount
			else
				sliderupdatetable.row[sliderupdatetable.col].properties.start = newamount
			end
			--linkedrow.row[sliderupdatetable.col].properties.maxSelect = (menu.infocrew.current.roles[slidertable[sliderindex].roleindex].amount + menu.infocrew.reassigned.roles[slidertable[sliderindex].roleindex].amount + menu.infocrew.unassigned.total)
			--linkedrow.row[sliderupdatetable.col].properties.maxSelect = istier and (menu.infocrew.current.roles[slidertable[sliderindex].roleindex].amount + menu.infocrew.reassigned.roles[slidertable[sliderindex].roleindex].amount + menu.infocrew.unassigned.total) or (linkedrow.row[sliderupdatetable.col].properties.start)
			Helper.setSliderCellValue(sliderupdatetable.table.id, linkedrow.row.index, sliderupdatetable.col, newlinkedslidervalue)
		end
	end
end

function menu.infoSubmenuConfirmCrewChanges()
	--print("reassigning " .. menu.infocrew.reassigned.total .. " crew members.")
	local reassignedcrew = ffi.new("CrewTransferContainer[?]", menu.infocrew.reassigned.total)
	local crewcounter = 0
	for i, roletable in ipairs(menu.infocrew.reassigned.roles) do
		for j, tiertable in ipairs(roletable.tiers) do
			for k, persontable in ipairs(tiertable.persons) do
				--print("evaluating person " .. k .. ": " .. tostring(persontable.person))
				crewcounter = crewcounter + 1
				reassignedcrew[crewcounter - 1].seed = persontable.person
				reassignedcrew[crewcounter - 1].newroleid = Helper.ffiNewString(persontable.newrole)
				--print(tostring(crewcounter) .. ": reassigning person " .. k .. " with seed " .. tostring(persontable.person) .. " to role " .. tostring(persontable.newrole))

				table.insert(menu.infocrew.current.roles[i].tiers[j].persons, persontable.person)
				menu.infocrew.current.roles[i].tiers[j].amount = menu.infocrew.current.roles[i].tiers[j].amount + 1
				menu.infocrew.current.roles[i].amount = menu.infocrew.current.roles[i].amount + 1
				menu.infocrew.current.total = menu.infocrew.current.total + 1

				menu.infocrew.reassigned.roles[i].tiers[j].amount = menu.infocrew.reassigned.roles[i].tiers[j].amount - 1
				menu.infocrew.reassigned.roles[i].amount = menu.infocrew.reassigned.roles[i].amount - 1
				menu.infocrew.reassigned.total = menu.infocrew.reassigned.total - 1
			end
			menu.infocrew.reassigned.roles[i].tiers[j].persons = {}
		end
	end
	C.ReassignPeople(menu.infoSubmenuObject, reassignedcrew, crewcounter)
	menu.refreshInfoFrame()
end

function menu.infoSubmenuReplacePilot(ship, oldpilot, newpilot, checkonly, contextmenu)
	local oldpilotluaid = oldpilot and ConvertStringToLuaID(tostring(oldpilot))
	local post = oldpilot and GetComponentData(oldpilotluaid, "poststring") or "aipilot"

	if not C.CanControllableHaveControlEntity(ship, post) then
		return false
	end

	-- select best pilot from entire crew for now.
	local bestpilot = newpilot or oldpilot or nil
	local bestcombinedskill = (newpilot and C.GetPersonCombinedSkill(ship, newpilot, nil, post)) or (oldpilot and GetComponentData(oldpilotluaid, "combinedskill")) or -1
	--if oldpilot then
	--	print("old pilot: " .. ffi.string(C.GetComponentName(oldpilot)) .. " (" .. tostring(oldpilot) .. ")" .. ", combined skill: " .. tostring(bestcombinedskill))
	--end
	if not newpilot then
		-- if we want to restrict pilot candidates to people with a particular role, do that here.
		for i, roletable in ipairs(menu.infocrew.current.roles) do
			if (roletable.id == "service") or (roletable.id == "marine") then
				for j, tiertable in ipairs(roletable.tiers) do
					for k, person in ipairs(tiertable.persons) do
						local evalcombinedskill = C.GetPersonCombinedSkill(ship, person, nil, post)
						if evalcombinedskill > bestcombinedskill then
							bestpilot = person
							bestcombinedskill = evalcombinedskill
						end
					end
				end
			end
		end
	end

	--print("bestpilot: " .. tostring(bestpilot))
	if bestpilot == oldpilot then
		--print("the old pilot: " .. ffi.string(C.GetComponentName(oldpilot)) .. " is already the best pilot in the crew. nothing changed.")
		return false
	elseif checkonly then
		--print("there is a better pilot available in the crew: " .. ffi.string(C.GetPersonName(bestpilot, ship)) .. ", combined skill: " .. tostring(bestcombinedskill))
		return true
	end
	--[[
	if C.GetInstantiatedPerson(bestpilot, ship) ~= 0 then
		print(ffi.string(C.GetPersonName(bestpilot, ship)) .. " is instantiated.")
	end
	print("best pilot is " .. ffi.string(C.GetPersonName(bestpilot, ship)) .. " with combinedskill: " .. tostring(bestcombinedskill))
	--]]

	if oldpilot then
		-- MD handles assignment of new pilot in this case.
		C.SignalObjectWithNPCSeed(oldpilot, "npc__control_dismissed", bestpilot, ship)
	else
		newpilot = C.CreateNPCFromPerson(bestpilot, ship)
		--print("person converted to NPC: " .. ffi.string(C.GetComponentName(newpilot)) .. " (" .. tostring(newpilot) .. ")")
		if C.SetEntityToPost(ship, newpilot, post) then
			SignalObject(ConvertStringTo64Bit(tostring(newpilot)), "npc_state_reinit")
			--print("new pilot set")
		else
			DebugError("menu.infoSubmenuReplacePilot(): failed setting new pilot.")
		end

		menu.infoSubmenuPrepareCrewInfo()
	end

	if contextmenu then
		menu.closeContextMenu()
	end
	menu.refreshInfoFrame()
end

function menu.infoSubmenuUpdateTransferAmount(value, idx, containercash)
	if not value then
		DebugError("menu.infoSubmenuUpdateTransferAmount with no value")
		return
	end
	if not idx then
		DebugError("menu.infoSubmenuUpdateTransferAmount with no idx")
		return
	end
	if not containercash then
		DebugError("menu.infoSubmenuUpdateTransferAmount with no containercash")
		return
	end

	menu.infocashtransferdetails[2][idx] = value - containercash
	-- do not refresh. prevents smoothly dragging the slider.
end

function menu.infoSubmenuUpdateManagerAccount(station, buildstorage)
	if not station then
		DebugError("menu.infoSubmenuUpdateManagerAccount called with no station set.")
		return
	end
	if not buildstorage then
		DebugError("menu.infoSubmenuUpdateManagerAccount called with no buildstorage set.")
		return
	end

	TransferPlayerMoneyTo((menu.infocashtransferdetails[2][1]), station)
	--print("transferring " .. tostring(menu.infocashtransferdetails[2][1]) .. " to station: " .. ffi.string(C.GetComponentName(station)))
	TransferPlayerMoneyTo((menu.infocashtransferdetails[2][2]), buildstorage)
	--print("transferring " .. tostring(menu.infocashtransferdetails[2][2]) .. " to buildstorage: " .. ffi.string(C.GetComponentName(buildstorage)))
	menu.infocashtransferdetails[2] = {0, 0}
	menu.refreshInfoFrame()
end

function menu.infoSubmenuUpdateProductionTime(object64, moduleindex)
	local productionmodules = GetProductionModules(object64)
	if not productionmodules then
		print("no production modules found.")
		return ""
	end
	local productiondata = GetProductionModuleData(productionmodules[moduleindex])
	if not productiondata then
		print("no production data found.")
		return ""
	end
	local s = productiondata.remainingcycletime
	if not s then
		print("error: remaining cycle time is: " .. tostring(s))
		return ""
	end
	local formattedtime = ConvertTimeString(s, "%h:%M:%S")
	return formattedtime
end

function menu.buttonExtendInfo(buttondata)
	if menu.extendedinfo[buttondata] then
		menu.extendedinfo[buttondata] = nil
	else
		menu.extendedinfo[buttondata] = true
	end
	menu.settoprow = GetTopRow(menu.infoTable)

	menu.refreshInfoFrame()
end

function menu.createMissionMode(frame)
	menu.setrow = 3
	menu.missionDoNotUpdate = true

	if menu.infoTableMode == "missionoffer" then
		menu.updateMissionOfferList()
	elseif menu.infoTableMode == "mission" then
		menu.updateMissions()

		if menu.missionMode == menu.activeMissionMode then
			if menu.highlightLeftBar[menu.infoTableMode] then
				menu.highlightLeftBar[menu.infoTableMode] = nil
				menu.refreshMainFrame = true
			end
		end
	end

	local ftable = menu.infoFrame:addTable(9 , { tabOrder = 1 })
	ftable:setDefaultCellProperties("text", { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize })
	ftable:setDefaultCellProperties("button", { height = config.mapRowHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = config.mapFontSize })

	ftable:setColWidth(1, Helper.scaleY(config.mapRowHeight), false)
	ftable:setColWidth(2, Helper.scaleY(config.mapRowHeight), false)
	-- in smaller resolutions, e.g. 1280x720, this can get negative due to different scalings used (this would be solved if we unify the scaling support as planned)
	ftable:setColWidth(3, math.max(1, menu.sideBarWidth - 2 * (Helper.scaleY(config.mapRowHeight) + Helper.borderSize)), false)
	ftable:setColWidth(4, menu.sideBarWidth / 2, false)
	ftable:setColWidth(5, menu.sideBarWidth / 2 - Helper.borderSize, false)
	ftable:setColWidth(6, menu.sideBarWidth, false)
	ftable:setColWidth(7, menu.sideBarWidth, false)
	ftable:setColWidthPercent(9, 20)

	ftable:setDefaultBackgroundColSpan(2, 8)

	local title = ""

	local row = ftable:addRow("tabs", { fixed = true, bgColor = Helper.color.transparent })
	if menu.missionModeCurrent == "tabs" then
		menu.setrow = row.index
	else
		menu.setcol = nil
	end
	local categories = (menu.infoTableMode == "missionoffer") and config.missionOfferCategories or config.missionCategories
	for i, entry in ipairs(categories) do
		local bgcolor = Helper.defaultTitleBackgroundColor
		local color = Helper.color.white
		if menu.infoTableMode == "missionoffer" then
			if entry.category == menu.missionOfferMode then
				title = entry.name
				bgcolor = Helper.defaultArrowRowBackgroundColor
			end
		else
			if entry.category == menu.missionMode then
				title = entry.name
				bgcolor = Helper.defaultArrowRowBackgroundColor
			end
			if entry.category == menu.activeMissionMode then
				color = Helper.color.mission
			end
		end

		local colindex = i
		if i == 1 then
			row[colindex]:setColSpan(3)
		elseif i == 2 then
			colindex = colindex + 2
			row[colindex]:setColSpan(2)
		else
			colindex = colindex + 3
		end

		row[colindex]:createButton({ height = menu.sideBarWidth, bgColor = bgcolor, mouseOverText = entry.name, scaling = false }):setIcon(entry.icon, { color = color})
		if menu.infoTableMode == "missionoffer" then
			row[colindex].handlers.onClick = function () return menu.buttonMissionOfferSubMode(entry.category, colindex) end
		else
			row[colindex].handlers.onClick = function () return menu.buttonMissionSubMode(entry.category, colindex) end
		end
	end

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:setColSpan(9):createText(title, Helper.headerRowCenteredProperties)

	if menu.infoTableMode == "missionoffer" then
		local found = false
		if menu.missionOfferMode == "guild" then
			for _, data in ipairs(menu.missionOfferList[menu.missionOfferMode]) do
				if #data.missions > 0 then
					found = true

					-- check if we need to expand for the current selected mission
					for _, entry in ipairs(data.missions) do
						if entry.ID == menu.missionModeCurrent then
							menu.expandedMissionGroups[data.id] = true
						end
					end

					local isexpanded = menu.expandedMissionGroups[data.id]
					local row = ftable:addRow(data.id, { bgColor = Helper.color.transparent })
					if data.id == menu.missionModeCurrent then
						menu.setrow = row.index
					end
					row[1]:createButton():setText(isexpanded and "-" or "+", { halign = "center" })
					row[1].handlers.onClick = function () return menu.buttonExpandMissionGroup(data.id, row.index) end
					row[2]:setColSpan(7):createText(data.name)
					row[9]:createText((#data.missions == 1) and ReadText(1001, 3335) or string.format(ReadText(1001, 3336), #data.missions), { halign = "right" })
			
					if isexpanded then
						for _, entry in ipairs(data.missions) do
							menu.addMissionRow(ftable, entry, 1)
						end
					end
				end
			end
		else
			for _, entry in ipairs(menu.missionOfferList[menu.missionOfferMode]) do
				found = true
				menu.addMissionRow(ftable, entry)
			end
		end
		if not found then
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:setColSpan(9):createText("--- " .. ReadText(1001, 3302) .. " ---", { halign = "center" })
		end
	elseif menu.infoTableMode == "mission" then
		local found = false
		if menu.missionMode == "guild" then
			for _, data in ipairs(menu.missionList[menu.missionMode]) do
				found = true

				-- check if we need to expand for the current selected mission
				for _, entry in ipairs(data.missions) do
					if entry.ID == menu.missionModeCurrent then
						menu.expandedMissionGroups[data.id] = true
					end
					for i, submission in ipairs(entry.subMissions) do
						if submission.ID == menu.missionModeCurrent then
							menu.expandedMissionGroups[data.id] = true
							menu.expandedMissionGroups[entry.ID] = true
						end
					end
				end

				local isexpanded = menu.expandedMissionGroups[data.id]
				local row = ftable:addRow(data.id, { bgColor = Helper.color.transparent })
				if data.id == menu.missionModeCurrent then
					menu.setrow = row.index
				end

				local color = Helper.color.white
				if data.active then
					color = Helper.color.mission
				end

				row[1]:createButton():setText(isexpanded and "-" or "+", { halign = "center" })
				row[1].handlers.onClick = function () return menu.buttonExpandMissionGroup(data.id, row.index) end
				row[2]:setColSpan(7):createText(data.name, { color = color })
				row[9]:createText((#data.missions == 1) and ReadText(1001, 3337) or string.format(ReadText(1001, 3338), #data.missions), { halign = "right", color = color })
			
				if isexpanded then
					local hadThreadMission = false
					for _, entry in ipairs(data.missions) do
						if entry.threadtype ~= "" then
							hadThreadMission = true
						end
						if hadThreadMission and (entry.threadtype == "") then
							-- first non thread mission after threads
							hadThreadMission = false
							local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
							row[1]:setColSpan(9):createText("")
						end
						menu.addMissionRow(ftable, entry, 1)
					end
				end
			end
		elseif menu.missionMode == "upkeep" then
			for containeridstring, data in pairs(menu.missionList[menu.missionMode]) do
				found = true

				-- check if we need to expand for the current selected mission
				for _, entry in ipairs(data.missions) do
					if entry.ID == menu.missionModeCurrent then
						menu.expandedMissionGroups[containeridstring] = true
					end
					for i, submission in ipairs(entry.subMissions) do
						if submission.ID == menu.missionModeCurrent then
							menu.expandedMissionGroups[containeridstring] = true
							menu.expandedMissionGroups[entry.ID] = true
						end
					end
				end

				local isexpanded = menu.expandedMissionGroups[containeridstring]
				local row = ftable:addRow(containeridstring, { bgColor = Helper.color.transparent })
				if containeridstring == menu.missionModeCurrent then
					menu.setrow = row.index
				end

				local color = Helper.color.white
				if data.active then
					color = Helper.color.mission
				end

				row[1]:createButton():setText(isexpanded and "-" or "+", { halign = "center" })
				row[1].handlers.onClick = function () return menu.buttonExpandMissionGroup(containeridstring, row.index) end
				row[2]:setColSpan(7):createText(ffi.string(C.GetComponentName(ConvertStringTo64Bit(containeridstring))), { color = color })
				row[9]:createText((#data.missions == 1) and ReadText(1001, 3337) or string.format(ReadText(1001, 3338), #data.missions), { halign = "right", color = color })
			
				if isexpanded then
					local hadThreadMission = false
					for _, entry in ipairs(data.missions) do
						if entry.threadtype ~= "" then
							hadThreadMission = true
						end
						if hadThreadMission and (entry.threadtype == "") then
							-- first non thread mission after threads
							hadThreadMission = false
							local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
							row[1]:setColSpan(9):createText("")
						end
						menu.addMissionRow(ftable, entry, 1)
					end
				end
			end
		else
			local hadThreadMission = false
			for _, entry in ipairs(menu.missionList[menu.missionMode]) do
				found = true
				if entry.threadtype ~= "" then
					hadThreadMission = true
				end
				if hadThreadMission and (entry.threadtype == "") then
					-- first non thread mission after threads
					hadThreadMission = false
					local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
					row[1]:setColSpan(9):createText("")
				end
				menu.addMissionRow(ftable, entry)
			end
		end
		if not found then
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:setColSpan(9):createText("--- " .. ReadText(1001, 3302) .. " ---", { halign = "center" })
		end
	end

	ftable:setTopRow(menu.settoprow)
	ftable:setSelectedRow(menu.setrow)
	ftable:setSelectedCol(menu.setcol or 0)
	menu.setrow = nil
	menu.settoprow = nil
	menu.setcol = nil
end

function menu.addMissionRow(ftable, missionentry, indented, seqidx)
	local name = missionentry.name
	if seqidx then
		name = seqidx .. ReadText(1001, 120) .. " " .. name
	end
	local icon = "\27[" .. "missionoffer_" .. missionentry.type .. "_active" .. "]"
	local color = Helper.color.white
	if missionentry.active then
		color = Helper.color.mission
	elseif missionentry.accepted then
		name = ReadText(1001, 6404) .. " - " .. name
		color = Helper.color.mission
		missionentry.duration = 0
	elseif missionentry.expired then
		name = ReadText(1001, 6402) .. " - " .. name
		color = Helper.color.grey
		missionentry.duration = 0
	end
	local faction = ""
	if missionentry.faction ~= "" then
		faction = GetFactionData(missionentry.faction, "shortname")
	end
	if missionentry.faction == "player" then
		faction = ""
	end
	local reward = missionentry.rewardtext
	if missionentry.reward > 0 then
		reward = ConvertMoneyString(missionentry.reward, false, true, 7, true) .. " " .. ReadText(1001, 101)
	end
	local difficulty = ""
	if missionentry.difficulty ~= 0 then
		difficulty = ConvertMissionLevelString(missionentry.difficulty)
	end

	local bgColor = Helper.defaultSimpleBackgroundColor
	if #missionentry.subMissions > 0 then
		bgColor = Helper.color.transparent
	elseif missionentry.expired then
		bgColor = Helper.color.darkgrey
	end

	local row = ftable:addRow((missionentry.expired or missionentry.accepted) and true or { missionentry.ID }, { bgColor = bgColor })
	if missionentry.ID == menu.missionModeCurrent then
		menu.setrow = row.index
	end

	if #missionentry.subMissions > 0 then
		local isexpanded = menu.expandedMissionGroups[missionentry.ID]

		if indented == 1 then
			row[1]:setBackgroundColSpan(9)
			row[2]:createButton():setText(isexpanded and "-" or "+", { halign = "center" })
			row[2].handlers.onClick = function () return menu.buttonExpandMissionGroup(missionentry.ID, row.index, function() return menu.showMissionContext(missionentry.ID) end) end
			row[3]:setColSpan(7):createText(name, { color = color })
		else
			row[1]:setBackgroundColSpan(9):createButton():setText(isexpanded and "-" or "+", { halign = "center" })
			row[1].handlers.onClick = function () return menu.buttonExpandMissionGroup(missionentry.ID, row.index, function() return menu.showMissionContext(missionentry.ID) end) end
			row[2]:setColSpan(8):createText(name, { color = color })
		end

		if isexpanded then
			for i, submission in ipairs(missionentry.subMissions) do
				menu.addMissionRow(ftable, submission, (indented or 0) + 1, (missionentry.threadtype == "sequential") and i or nil)
			end
		end
	else
		if indented == 2 then
			row[1]:setBackgroundColSpan(9):setColSpan(2)
			row[1].properties.cellBGColor = Helper.color.transparent
			row[3]:setColSpan(2):createText(icon .. "\n" .. faction, { color = color })
			row[5]:setColSpan(4):createText(name .. "\n" .. reward, { color = color })
			row[9]:createText(function () return menu.getMissionTimeAndDifficulty(missionentry.ID, difficulty) end, { color = color, halign = "right" })
		elseif indented == 1 then
			row[1]:setBackgroundColSpan(9)
			row[1].properties.cellBGColor = Helper.color.transparent
			row[2]:setColSpan(3):createText(icon .. "\n" .. faction, { color = color })
			row[5]:setColSpan(4):createText(name .. "\n" .. reward, { color = color })
			row[9]:createText(function () return menu.getMissionTimeAndDifficulty(missionentry.ID, difficulty) end, { color = color, halign = "right" })
		else
			row[1]:setColSpan(4):setBackgroundColSpan(9):createText(icon .. "\n" .. faction, { color = color })
			row[5]:setColSpan(4):createText(name .. "\n" .. reward, { color = color })
			row[9]:createText(function () return menu.getMissionTimeAndDifficulty(missionentry.ID, difficulty) end, { color = color, halign = "right" })
		end
	end
end

function menu.getMissionTimeAndDifficulty(missionid, difficulty)
	local rawduration = 0
	if menu.infoTableMode == "mission" then
		menu.updateMissions()

		local found = false
		for category, entries in pairs(menu.missionList or {}) do
			for _, entry in ipairs(entries) do
				if entry.ID == missionid then
					found = true
					break
				end
			end
		end
		if found then
			local missiondetails = C.GetMissionIDDetails(ConvertStringTo64Bit(missionid))
			rawduration = (missiondetails.duration and missiondetails.duration > 0) and missiondetails.duration or (missiondetails.timeLeft or -1)
		end
	else
		menu.updateMissionOfferList()

		local found = false
		local expired = false
		for i, entry in ipairs(menu.missionOfferList or {}) do
			if entry.ID == missionid then
				found = true
				expired = entry.expired or entry.accepted
				break
			end
		end
		if found and (not expired) then
			local name, description, offerdifficulty, threadtype, maintype, subtype, subtypename, faction, reward, rewardtext, briefingobjectives, activebriefingstep, briefingmissions, oppfaction, licence, missiontime, offerduration, _, _, _, _, actor = GetMissionOfferDetails(ConvertStringToLuaID(missionid))
			rawduration = offerduration
		end
	end

	local duration = ""
	if rawduration > 0 then
		duration = ConvertTimeString(rawduration, (rawduration > 3600) and "%h:%M:%S" or "%M:%S")
	end
	
	return duration .. "\n" .. difficulty
end

function menu.updateMissionOfferList(clear)
	if (not menu.missionOfferList) or (not next(menu.missionOfferList)) then
		clear = true
	end
	if clear then
		menu.missionOfferList = {}
		for _, entry in ipairs(config.missionOfferCategories) do
			menu.missionOfferList[entry.category] = {}
		end
	end

	local missionOfferList, missionOfferIDs = {}, {}
	Helper.ffiVLA(missionOfferList, "uint64_t", C.GetNumCurrentMissionOffers, C.GetCurrentMissionOffers, true)
	for i, id in ipairs(missionOfferList) do
		missionOfferIDs[tostring(id)] = i
	end

	for _, entry in ipairs(config.missionOfferCategories) do
		if entry.category == "guild" then
			for i, data in ipairs(menu.missionOfferList[entry.category]) do
				for j = #data.missions, 1, -1 do
					if missionOfferIDs[data.missions[j].ID] then
						missionOfferIDs[menu.missionOfferList[entry.category][i].missions[j].ID] = nil
					else
						if not menu.missionOfferList[entry.category][i].missions[j].accepted then
							menu.missionOfferList[entry.category][i].missions[j].expired = true
						end
					end
				end
			end
		else
			for i = #menu.missionOfferList[entry.category], 1, -1 do
				if missionOfferIDs[menu.missionOfferList[entry.category][i].ID] then
					missionOfferIDs[menu.missionOfferList[entry.category][i].ID] = nil
				else
					if not menu.missionOfferList[entry.category][i].accepted then
						menu.missionOfferList[entry.category][i].expired = true
					end
				end
			end
		end
	end
	
	for id in pairs(missionOfferIDs) do
		local name, description, difficulty, threadtype, maintype, subtype, subtypename, faction, reward, rewardtext, briefingobjectives, activebriefingstep, briefingmissions, oppfaction, licence, missiontime, duration, _, _, _, _, actor = GetMissionOfferDetails(ConvertStringToLuaID(id))
		local missionGroup = C.GetMissionGroupDetails(ConvertStringTo64Bit(id))
		local groupID, groupName = ffi.string(missionGroup.id), ffi.string(missionGroup.name)
		if maintype ~= "tutorial" then
			local entry = {
				["name"] = name,
				["description"] = description,
				["difficulty"] = difficulty,
				["missionGroup"] = { id = groupID, name = groupName },
				["threadtype"] = threadtype,
				["type"] = subtype,
				["faction"] = faction or "",
				["oppfaction"] = oppfaction or "",
				["licence"] = licence,
				["reward"] = reward,
				["rewardtext"] = rewardtext,
				["briefingobjectives"] = briefingobjectives,
				["activebriefingstep"] = activebriefingstep,
				["duration"] = duration,
				["missiontime"] = missiontime,
				["ID"] = id,
				["actor"] = actor,
				["subMissions"] = {},
			}

			if entry.missionGroup.id ~= "" then
				local index = 0
				for i, data in ipairs(menu.missionOfferList["guild"]) do
					if data.id == entry.missionGroup.id then
						index = i
						break
					end
				end
				if index ~= 0 then
					table.insert(menu.missionOfferList["guild"][index].missions, entry)
				else
					table.insert(menu.missionOfferList["guild"], { id = entry.missionGroup.id, name = entry.missionGroup.name, missions = { entry } })
				end
			else
				table.insert(menu.missionOfferList["other"], entry)
			end
		end
	end

	table.sort(menu.missionOfferList["guild"], Helper.sortName)
end

function menu.getMissionInfoHelper(mission)
	local missionID, name, description, difficulty, threadtype, maintype, subtype, subtypename, faction, reward, rewardtext, _, _, _, _, _, missiontime, _, abortable, disableguidance, associatedcomponent, upkeepalertlevel, hasobjective, threadmissionid = GetMissionDetails(mission)
	local missionid64 = ConvertIDTo64Bit(missionID)
	local missionGroup = C.GetMissionGroupDetails(missionid64)
	local groupID, groupName = ffi.string(missionGroup.id), ffi.string(missionGroup.name)
	local objectiveText, timeout, progressname, curProgress, maxProgress = GetMissionObjective(mission)
	local subMissions, buf = {}, {}
	local subactive = false
	Helper.ffiVLA(buf, "MissionID", C.GetNumMissionThreadSubMissions, C.GetMissionThreadSubMissions, missionid64)
	for _, submission in ipairs(buf) do
		local submissionEntry = menu.getMissionIDInfoHelper(submission)
		table.insert(subMissions, submissionEntry)
		if submissionEntry.active then
			subactive = true
		end
	end
	local entry = {
		["active"] = (mission == GetActiveMission()) or subactive,
		["name"] = name,
		["description"] = description,
		["difficulty"] = difficulty,
		["missionGroup"] = { id = groupID, name = groupName },
		["threadtype"] = threadtype,
		["maintype"] = maintype,
		["type"] = subtype,
		["faction"] = faction,
		["reward"] = reward,
		["rewardtext"] = rewardtext,
		["duration"] = (timeout and timeout ~= -1) and timeout or (missiontime or -1),		-- timeout can be nil, if mission has no objective
		["ID"] = tostring(missionid64),
		["associatedcomponent"] = ConvertIDTo64Bit(associatedcomponent),
		["abortable"] = abortable,
		["threadMissionID"] = ConvertIDTo64Bit(threadmissionid) or 0,
		["subMissions"] = subMissions,
	}

	return entry
end

function menu.getMissionIDInfoHelper(missionID)
	local missionGroup = C.GetMissionGroupDetails(missionID)
	local groupID, groupName = ffi.string(missionGroup.id), ffi.string(missionGroup.name)
	local subMissions, buf = {}, {}
	local subactive = false
	Helper.ffiVLA(buf, "MissionID", C.GetNumMissionThreadSubMissions, C.GetMissionThreadSubMissions, missionID)
	for _, submission in ipairs(buf) do
		local submissionEntry = menu.getMissionIDInfoHelper(submission)
		table.insert(subMissions, submissionEntry)
		if submissionEntry.active then
			subactive = true
		end
	end
	local missiondetails = C.GetMissionIDDetails(missionID)
	local entry = {
		["active"] = (missionID == C.GetActiveMissionID()) or subactive,
		["name"] = ffi.string(missiondetails.missionName),
		["description"] = ffi.string(missiondetails.missionDescription),
		["difficulty"] = missiondetails.difficulty,
		["missionGroup"] = { id = groupID, name = groupName },
		["threadtype"] = ffi.string(missiondetails.threadType),
		["maintype"] = ffi.string(missiondetails.mainType),
		["type"] = ffi.string(missiondetails.subType),
		["faction"] = ffi.string(missiondetails.faction),
		["reward"] = tonumber(missiondetails.reward) / 100,
		["rewardtext"] = ffi.string(missiondetails.rewardText),
		["duration"] = (missiondetails.duration and missiondetails.duration > 0) and missiondetails.duration or (missiondetails.timeLeft or -1),
		["ID"] = tostring(ConvertStringTo64Bit(tostring(missionID))),
		["associatedcomponent"] = missiondetails.associatedComponent,
		["abortable"] = missiondetails.abortable,
		["threadMissionID"] = missiondetails.threadMissionID,
		["subMissions"] = subMissions,
	}

	return entry
end

function menu.addMissionToList(entry)
	if entry.maintype == "upkeep" then
		local container = C.GetContextByClass(entry.associatedcomponent, "container", true)
		local buildanchor = GetBuildAnchor(ConvertStringTo64Bit(tostring(container)))
		local containeridstring = buildanchor and tostring(buildanchor) or tostring(container)

		if menu.missionList["upkeep"][containeridstring] then
			if entry.active then
				menu.missionList["upkeep"][containeridstring].active = true
			end
			table.insert(menu.missionList["upkeep"][containeridstring].missions, entry)
		else
			menu.missionList["upkeep"][containeridstring] = { active = entry.active, missions = { entry } }
		end
		if entry.active then
			menu.activeMissionMode = "upkeep"
		end
	else
		if entry.maintype == "guidance" then
			table.insert(menu.missionList["guidance"], entry)
			if entry.active then
				menu.activeMissionMode = "guidance"
			end
		else
			if entry.missionGroup.id ~= "" then
				local index = 0
				for i, data in ipairs(menu.missionList["guild"]) do
					if data.id == entry.missionGroup.id then
						index = i
						break
					end
				end
				if index ~= 0 then
					if entry.active then
						menu.missionList["guild"][index].active = true
					end
					table.insert(menu.missionList["guild"][index].missions, entry)
				else
					table.insert(menu.missionList["guild"], { id = entry.missionGroup.id, name = entry.missionGroup.name, active = entry.active, missions = { entry } })
				end
				if entry.active then
					menu.activeMissionMode = "guild"
				end
			else
				table.insert(menu.missionList["other"], entry)
				if entry.active then
					menu.activeMissionMode = "other"
				end
			end
		end
	end
end

function menu.updateMissions()
	menu.missionList = {}
	menu.activeMissionMode = nil
	for _, entry in ipairs(config.missionCategories) do
		menu.missionList[entry.category] = {}
	end

	local numMissions = GetNumMissions()
	for i = 1, numMissions do
		local entry = menu.getMissionInfoHelper(i)
		if maintype ~= "tutorial" then
			if entry.threadMissionID == 0 then
				menu.addMissionToList(entry)
			end
		end
	end

	for _, entry in ipairs(config.missionCategories) do
		if (entry.category == "guild") or (entry.category == "upkeep") then
			for _, data in pairs(menu.missionList[entry.category]) do
				table.sort(data.missions, menu.missionListSorter)
			end
		else
			table.sort(menu.missionList[entry.category], menu.missionListSorter)
		end
	end
end

function menu.missionListSorter(a, b)
	if ((a.threadtype ~= "") and (b.threadtype ~= "")) or ((a.threadtype == "") and (b.threadtype == "")) then
		return config.missionMainTypeOrder[a.maintype] < config.missionMainTypeOrder[b.maintype]
	end

	return a.threadtype ~= ""
end

function menu.createCheats(frame)
	-- (cheat only)
	local cheats = {
		[1] = {
			name = "Enable All Cheats",
			info = "Reveal stations, encyclopedia, map, research and adds money and seta.",
			callback = C.EnableAllCheats,
			shortcut = {"action", 290}, -- INPUT_ACTION_DEBUG_FEATURE_3
		},
		[2] = {
			name = "Reveal map",
			callback = C.RevealMap,
		},
		[3] = {
			name = "Reveal stations",
			callback = C.RevealStations,
		},
		[4] = {
			name = "Cheat 1bn Credits",
			callback = function () return C.AddPlayerMoney(100000000000) end,
		},
		[5] = {
			name = "Cheat SETA",
			callback = function () return AddInventory(nil, "inv_timewarp", 1) end,
		},
		[6] = {
			name = "Reveal encyclopedia",
			info = "Also reveals the map and completes all research.",
			callback = C.RevealEncyclopedia,
		},
		[7] = {
			name = "Spawn CVs",
			section = "gDebug_deployCVs",
		},
		[8] = {
			name = "Fill nearby Build Storages",
			section = "gDebug_station_buildresources",
		},
		[9] = {
			name = "Inc Crew skill",
			section = "gDebug_crewskill",
		},
		[10] = {
			name = "Open Flowchart Test",
			menu = "StationOverviewMenu",
		},
		[11] = {
			name = "Cheat All Research",
			callback = menu.cheatAllResearch,
		},
		[12] = {
			name = "Cheat Docking Traffic",
			sectionparam = C.CheatDockingTraffic,
			shortcut = {"action", 291}, -- INPUT_ACTION_DEBUG_FEATURE_4
		},
	}

	local ftable = menu.infoFrame:addTable(1 , { tabOrder = 1 })
	ftable:setDefaultCellProperties("text", { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize })
	ftable:setDefaultCellProperties("button", { height = config.mapRowHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = config.mapFontSize })

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.defaultTitleBackgroundColor })
	row[1]:createText("Cheats", Helper.headerRowCenteredProperties)

	for _, cheat in ipairs(cheats) do
		local row = ftable:addRow(true, {  })
		local shortcut = ""
		if cheat.shortcut then
			shortcut = " \27A(" .. GetLocalizedKeyName(cheat.shortcut[1], cheat.shortcut[2]) .. ")"
		end
		row[1]:createButton({ mouseOverText = cheat.info or "" }):setText(cheat.name .. shortcut)
		if cheat.callback then
			row[1].handlers.onClick = function () return cheat.callback() end
		elseif cheat.menu then
			row[1].handlers.onClick = function () Helper.closeMenuAndOpenNewMenu(menu, cheat.menu, {0, 0}) menu.cleanup() end
		elseif cheat.section then
			row[1].handlers.onClick = function () Helper.closeMenuForNewConversation(menu, cheat.section, ConvertStringToLuaID(tostring(C.GetPlayerComputerID())), nil, true) menu.cleanup() end
		end
	end
end

function menu.cheatAllResearch()
	local researchwares = {
		"research_module_defence",
		"research_module_habitation",
		"research_module_production",
		"research_module_storage",
		"research_module_dock",
		"research_module_build",
		"research_teleportation",
		"research_teleportation_range_01",
		"research_teleportation_range_02",
		"research_teleportation_range_03",
		"research_radioreceiver",
		"research_sensorbooster",
		"research_tradeinterface",
	}

	for _, research in ipairs(researchwares) do
		C.AddResearch(research)
	end
end

function menu.createPlayerInfo(frame, width, height, offsetx, offsety)
	local ftable = frame:addTable(1, { tabOrder = 0, width = width, height = height, x = offsetx, y = offsety, scaling = false })

	local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent60 })
	local icon = row[1]:createIcon(function () local logo = C.GetCurrentPlayerLogo(); return ffi.string(logo.icon) end, { width = height, height = height })

	local textheight = math.ceil(C.GetTextHeight(Helper.playerInfoTextLeft(), Helper.standardFont, menu.playerInfo.fontsize, width - height - Helper.borderSize))
	icon:setText(Helper.playerInfoTextLeft,	{ fontsize = menu.playerInfo.fontsize, halign = "left",  x = height + Helper.borderSize, y = (height - textheight) / 2 })
	icon:setText2(Helper.playerInfoTextRight,	{ fontsize = menu.playerInfo.fontsize, halign = "right", x = Helper.borderSize,          y = (height - textheight) / 2 })
end

function menu.createSearchField(frame, width, height, offsetx, offsety)
	local editboxwidth = menu.infoTableWidth - Helper.round(2.5 * menu.editboxHeight) - Helper.borderSize

	local numCols = 6 + #config.layers
	local ftable = frame:addTable(numCols, { tabOrder = 4, width = width, height = height, x = offsetx, y = offsety, skipTabChange = true, backgroundID = "solid", backgroundColor = Helper.color.semitransparent })
	ftable:setDefaultCellProperties("text", { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize })
	ftable:setDefaultCellProperties("button", { height = config.mapRowHeight })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = config.mapFontSize })

	ftable:setColWidth(1, Helper.scaleY(config.mapRowHeight), false)
	ftable:setColWidth(2, math.max(1, Helper.scaleY(Helper.headerRow1Height) - Helper.scaleY(config.mapRowHeight) - Helper.borderSize), false)
	ftable:setColWidth(3, menu.sideBarWidth - Helper.scaleY(Helper.headerRow1Height) - Helper.borderSize, false)
	for i = 2, #config.layers do
		ftable:setColWidth(i + 2, menu.sideBarWidth, false)
	end
	ftable:setColWidth(numCols - 1, Helper.scaleY(config.mapRowHeight), false)
	ftable:setColWidth(numCols, Helper.scaleY(config.mapRowHeight), false)

	-- search field
	local row = ftable:addRow(true, { fixed = true })
	-- toggle trade filter
	local colspan = 1
	if menu.editboxHeight > Helper.scaleY(config.mapRowHeight) then
		colspan = 2
	end
	local entry = config.layers[1]
	local icon = entry.icon
	if not menu.getFilterOption(entry.mode) then
		icon = icon .. "_disabled"
	end
	row[1]:setColSpan(colspan):createButton({ height = menu.editboxHeight, bgColor = bgcolor, mouseOverText = entry.name, scaling = false }):setIcon(icon, { })
	row[1].handlers.onClick = function () return menu.buttonSetFilterLayer(entry.mode, row.index, 1) end
	-- reset camera view
	row[colspan + 1]:setColSpan(1):createButton({ active = true, height = menu.editboxHeight, mouseOverText = ffi.string(C.GetLocalizedText(1026, 7911, ReadText(1026, 7902))), bgColor = {r = 33, g = 46, b = 55, a = 40}, scaling = false }):setIcon("menu_reset_view"):setHotkey("INPUT_STATE_DETAILMONITOR_RESET_VIEW", { displayIcon = false })
	row[colspan + 1].handlers.onClick = menu.buttonResetView
	-- editbox
	row[colspan + 2]:setColSpan(numCols - colspan - 1):createEditBox({ height = menu.editboxHeight, defaultText = ReadText(1001, 3250), scaling = false }):setText("", { x = Helper.standardTextOffsetx, scaling = true }):setHotkey("INPUT_STATE_DETAILMONITOR_0", { displayIcon = true })
	row[colspan + 2].handlers.onEditBoxDeactivated = menu.searchTextConfirmed
	local editboxRowHeight = row:getHeight()

	-- search terms
	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	for i = 1, math.min(3, #menu.searchtext) do
		local col = i
		local colspan = 1
		if col == 1 then
			colspan = 6
		else
			col = col + 5
		end

		row[col]:setColSpan(colspan)
		local truncatedString = TruncateText(menu.searchtext[i].text, Helper.standardFont, Helper.scaleFont(Helper.standardFont, config.mapFontSize), row[col]:getWidth() - 2 * Helper.scaleX(10))

		if menu.searchtext[i].blockRemove then
			row[col]:createText(truncatedString, { halign = "center", cellBGColor = Helper.defaultButtonBackgroundColor })
		else
			row[col]:createButton():setText(truncatedString, { halign = "center" }):setText2("X", { halign = "right" })
			row[col].handlers.onClick = function () return menu.buttonRemoveSearchEntry(i) end
		end
	end

	local setting = config.layersettings["layer_trade"][1]
	local warefilter = menu.getFilterOption(setting.id) or {}
	if #menu.searchtext < 3 then
		for i = 1, math.min(3 - #menu.searchtext, #warefilter) do
			local col = i + #menu.searchtext
			local colspan = 1
			if col == 1 then
				colspan = 6
			else
				col = col + 5
			end

			row[col]:setColSpan(colspan)
			local truncatedString = TruncateText(GetWareData(warefilter[i], "name"), Helper.standardFont, Helper.scaleFont(Helper.standardFont, config.mapFontSize), row[col]:getWidth() - 2 * Helper.scaleX(10))

			row[col]:createButton():setText(truncatedString, { halign = "center" }):setText2("X", { halign = "right" })
			row[col].handlers.onClick = function () return menu.removeFilterOption(setting, setting.id, i) end
			row[col].properties.uiTriggerID = "removefilteroption"
		end
	end

	if (#menu.searchtext + #warefilter) > 3 then
		row[5 + #config.layers]:setColSpan(2):createText(string.format("%+d", (#menu.searchtext + #warefilter) - 3))
	else
		row[5 + #config.layers]:setColSpan(2):createText("")
	end

	if menu.searchTableMode then
		if menu.holomap ~= 0 then
			C.SetMapStationInfoBoxMargin(menu.holomap, "right", menu.infoTableOffsetX + menu.infoTableWidth + config.contextBorder)
		end
		if (#menu.searchtext + #warefilter) > 0 then
			local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
			row[1]:createText("")
		end

		if menu.searchTableMode == "filter" then
			menu.createFilterMode(ftable, numCols)
		elseif menu.searchTableMode == "legend" then
			menu.createLegendMode(ftable, numCols)
		elseif menu.searchTableMode == "hire" then
			menu.createHireMode(ftable, numCols)
		end
	else
		if menu.holomap ~= 0 then
			C.SetMapStationInfoBoxMargin(menu.holomap, "right", 0)
		end
		--[[
		local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		for i, entry in ipairs(config.layers) do
			local icon = entry.icon
			if not menu.getFilterOption(entry.mode) then
				icon = icon .. "_disabled"
			end

			local colindex = i
			if i > 1 then
				colindex = colindex + 2
			end

			row[colindex]:setColSpan((i == 1) and 3 or 1):createButton({ height = menu.sideBarWidth / 2, width = menu.sideBarWidth / 2 , bgColor = bgcolor, mouseOverText = entry.name, scaling = false }):setIcon(icon, { })
			row[colindex].handlers.onClick = function () return menu.buttonSetFilterLayer(entry.mode, row.index, 1) end
		end--]]
	end
end

function menu.buttonRemoveSearchEntry(index)
	local colspan = 1
	if menu.editboxHeight > Helper.scaleY(config.mapRowHeight) then
		colspan = 2
	end
	Helper.cancelEditBoxInput(menu.searchField, 1, colspan + 2)

	table.remove(menu.searchtext, index)
	Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.SetMapFilterString(menu.holomap, numtexts, texts) end, "text")
	menu.refreshMainFrame = true

	menu.refreshInfoFrame()
end

function menu.createSideBar(firsttime, frame, width, height, offsetx, offsety)
	local spacingHeight = menu.sideBarWidth / 4
	local ftable = frame:addTable(1, { tabOrder = 3, width = width, height = height, x = offsetx, y = offsety, scaling = false, borderEnabled = false, reserveScrollBar = false })

	local firstactive
	for _, entry in ipairs(config.leftBar) do
		if (entry.condition == nil) or entry.condition() then
			if not entry.spacing then
				local active = true
				if menu.mode == "selectCV" then
					if (entry.mode ~= "objectlist") and (entry.mode ~= "propertyowned") then
						active = false
					end
				elseif menu.mode == "hire" then
					if entry.mode ~= "propertyowned" then
						active = false
					end
				elseif menu.mode == "orderparam_object" then
					if (entry.mode ~= "objectlist") and (entry.mode ~= "propertyowned") then
						active = false
					end
				end
				if active then
					local selectedmode = false
					if type(entry.mode) == "table" then
						for _, mode in ipairs(entry.mode) do
							if mode == menu.infoTableMode then
								selectedmode = true
								break
							end
						end
					else
						if entry.mode == menu.infoTableMode then
							selectedmode = true
						end
					end
					if selectedmode then
						firstactive = nil
						break
					end
					if not firstactive then
						firstactive = entry.mode
					end
				end
			end
		end
	end
	if firstactive and firsttime then
		menu.infoTableMode = firstactive
		firstactive = nil
	end

	for _, entry in ipairs(config.leftBar) do
		if (entry.condition == nil) or entry.condition() then
			if entry.spacing then
				local row = ftable:addRow(false, { fixed = true })
				row[1]:createIcon("mapst_seperator_line", { width = menu.sideBarWidth, height = spacingHeight })
			else
				local mode = entry.mode
				if type(entry.mode) == "table" then
					mode = mode[1]
				end
				local row = ftable:addRow(true, { fixed = true })
				local active = true
				if menu.mode == "selectCV" then
					if (mode ~= "objectlist") and (mode ~= "propertyowned") then
						active = false
					end
				elseif menu.mode == "hire" then
					if mode ~= "propertyowned" then
						active = false
					end
				elseif menu.mode == "orderparam_object" then
					if (mode ~= "objectlist") and (mode ~= "propertyowned") then
						active = false
					end
				end
				local bgcolor = Helper.defaultTitleBackgroundColor
				if type(entry.mode) == "table" then
					for _, mode in ipairs(entry.mode) do
						if mode == menu.infoTableMode then
							bgcolor = Helper.defaultArrowRowBackgroundColor
							break
						end
					end
				else
					if entry.mode == menu.infoTableMode then
						bgcolor = Helper.defaultArrowRowBackgroundColor
					end
				end
				local color = Helper.color.white
				if menu.highlightLeftBar[mode] then
					color = Helper.color.mission
				end
				row[1]:createButton({ active = active, height = menu.sideBarWidth, bgColor = bgcolor, mouseOverText = entry.name }):setIcon(entry.icon, { color = color })
				row[1].handlers.onClick = function () return menu.buttonToggleObjectList(mode) end
			end
		end
	end

	ftable:setSelectedRow(menu.selectedRows.sideBar)
	menu.selectedRows.sideBar = nil
end

function menu.createRightBar(frame, width, height, offsetx, offsety)
	local spacingHeight = menu.sideBarWidth / 4
	local ftable = frame:addTable(1, { tabOrder = 5, width = width, height = height, x = offsetx, y = offsety, scaling = false, borderEnabled = false, reserveScrollBar = false, skipTabChange = true })

	for _, entry in ipairs(config.rightBar) do
		if (entry.condition == nil) or entry.condition() then
			if entry.spacing then
				local row = ftable:addRow(false, { fixed = true })
				row[1]:createIcon("mapst_seperator_line", { width = menu.sideBarWidth, height = spacingHeight })
			else
				local mode = entry.mode
				if type(entry.mode) == "table" then
					mode = mode[1]
				end
				local row = ftable:addRow(true, { fixed = true })
				local active = true
				if menu.mode == "selectCV" then
					active = false
				elseif menu.mode == "hire" then
					active = false
				end
				local bgcolor = Helper.defaultTitleBackgroundColor
				if type(entry.mode) == "table" then
					for _, mode in ipairs(entry.mode) do
						if mode == menu.infoTableMode then
							bgcolor = Helper.defaultArrowRowBackgroundColor
							break
						end
					end
				else
					if entry.mode == menu.infoTableMode then
						bgcolor = Helper.defaultArrowRowBackgroundColor
					end
				end
				row[1]:createButton({ active = active, height = menu.sideBarWidth, bgColor = bgcolor, mouseOverText = entry.name }):setIcon(entry.icon)
				row[1].handlers.onClick = function () return menu.buttonToggleRightBar(mode) end
			end
		end
	end

	ftable:setSelectedRow(menu.selectedRows.rightBar)
	menu.selectedRows.rightBar = nil
end

function menu.createSelectedShips(frame)
	if menu.getNumSelectedComponents() == 0 then
		-- nothing to do
		frame:addTable(1, { tabOrder = 0, width = 1, scaling = false, reserveScrollBar = false })
		return
	end

	-- sort ships
	local selectedobjects = {}
	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		if C.IsObjectKnown(selectedcomponent) then
			local class = ffi.string(C.GetComponentClass(selectedcomponent))
			local icon, primarypurpose, hullpercent, shieldpercent, isplayerowned, isenemy = GetComponentData(selectedcomponent, "icon", "primarypurpose", "hullpercent", "shieldpercent", "isplayerowned", "isenemy")
			local color = "neutral"
			if isplayerowned then
				color = "player"
			elseif isenemy then
				color = "enemy"
			end
			local i = menu.findEntryByShipIcon(selectedobjects, icon, color)
			if i then
				selectedobjects[i].count			= selectedobjects[i].count			+ 1
				selectedobjects[i].hullpercent		= selectedobjects[i].hullpercent	+ hullpercent
				selectedobjects[i].shieldpercent	= selectedobjects[i].shieldpercent	+ shieldpercent
			else
				table.insert(selectedobjects, { icon = icon, color = color, class = class, purpose = primarypurpose, count = 1, hullpercent = hullpercent, shieldpercent = shieldpercent })
			end
		end
	end
	table.sort(selectedobjects, menu.sortShipsByClassAndPurpose)

	if #selectedobjects == 0 then
		-- nothing to do
		frame:addTable(1, { tabOrder = 0, width = 1, scaling = false, reserveScrollBar = false })
		return
	end

	-- display
	local numcolumns = 2 * menu.selectedShipsTableData.maxCols
	local width = numcolumns * (menu.selectedShipsTableData.width / 2 + Helper.borderSize) - Helper.borderSize
	local ftable = frame:addTable(numcolumns, { tabOrder = 21, width = width, x = Helper.viewWidth / 2 - width / 2, y = 0, scaling = false, reserveScrollBar = false, skipTabChange = true })
	for i = 1, numcolumns do
		ftable:setColWidth(i, menu.selectedShipsTableData.width / 2)
	end
	ftable:setDefaultBackgroundColSpan(1, numcolumns)
	ftable:setDefaultComplexCellProperties("icon", "text", { font = Helper.standardFontOutlined, fontsize = menu.selectedShipsTableData.fontsize })
	ftable:setDefaultComplexCellProperties("button", "text", { fontsize = menu.selectedShipsTableData.fontsize })
	ftable:setDefaultComplexCellProperties("button", "text2", { fontsize = menu.selectedShipsTableData.fontsize })

	-- title
	local row = ftable:addRow(false, { fixed = true, borderBelow = false, bgColor = Helper.color.transparent, scaling = true })
	row[1]:setColSpan(numcolumns):createText(ReadText(1001, 3251), { halign = "center", font = Helper.standardFontBoldOutlined, fontsize = Helper.headerRow1FontSize })
	-- line
	local row = ftable:addRow(false, { fixed = true, borderBelow = false, bgColor = Helper.color.white })
	row[1]:setColSpan(numcolumns):createText("", { height = 2 })
	-- example text used
	local textheight = math.ceil(C.GetTextHeight(ReadText(1001, 42) .. "1", Helper.standardFontOutlined, menu.selectedShipsTableData.fontsize, 0))
	-- ship rows
	for i = 1, math.floor(#selectedobjects / menu.selectedShipsTableData.maxCols) + 1 do
		local numshipcolums = math.min(#selectedobjects - (i -1) * menu.selectedShipsTableData.maxCols, menu.selectedShipsTableData.maxCols)
		local row = ftable:addRow(false, { fixed = true, borderBelow = false, bgColor = Helper.color.transparent })
		for j = 1, numshipcolums do
			local shipindex = (i - 1) * menu.selectedShipsTableData.maxCols + j
			local shipentry = selectedobjects[shipindex]
			local colindex = (j + 0.5 * (menu.selectedShipsTableData.maxCols - numshipcolums)) * 2 - 1
			local color = menu.holomapcolor.friendcolor
			if shipentry.color == "player" then
				color = menu.holomapcolor.playercolor
			elseif shipentry.color == "enemy" then
				color = menu.holomapcolor.enemycolor
			end
			row[colindex]:setColSpan(2):createIcon(C.IsIconValid(shipentry.icon) and shipentry.icon or "solid", { height = menu.selectedShipsTableData.height, width = menu.selectedShipsTableData.height + Helper.borderSize, color = color }):setText(ReadText(1001, 42) .. shipentry.count, { halign = "right", x = Helper.standardTextOffsetx, y = (menu.selectedShipsTableData.height - textheight) / 2 })
		end
		local row = ftable:addRow(false, { fixed = true, borderBelow = false, bgColor = Helper.color.transparent })
		for j = 1, numshipcolums do
			local shipindex = (i - 1) * menu.selectedShipsTableData.maxCols + j
			local shipentry = selectedobjects[shipindex]
			local colindex = (j + 0.5 * (menu.selectedShipsTableData.maxCols - numshipcolums)) * 2 - 1
			row[colindex]:setColSpan(2):createShieldHullBar(shipentry.shieldpercent, shipentry.hullpercent, { height = 10 })
		end
	end

	if menu.getNumSelectedComponents() == 1 then
		local component = next(menu.selectedcomponents)
		local selectedcomponent = ConvertStringTo64Bit(component)
		local isplayerowned = GetComponentData(selectedcomponent, "isplayerowned")
		if C.IsComponentClass(selectedcomponent, "ship") and isplayerowned then
			local curtime = getElapsedTime()
			if (not menu.shownShipCargo) or (menu.shownShipCargo.ship ~= selectedcomponent) or (menu.shownShipCargo.time + 60 < curtime) then
				--menu.shownShipCargo = { ship = selectedcomponent, time = curtime }
				local cargo = GetCargoAfterTradeOrders(selectedcomponent, true)
				local wares = {}
				for ware, amount in pairs(cargo) do
					table.insert(wares, { ware = ware, name = GetWareData(ware, "name"), amount = amount })
				end
				table.sort(wares, function (a, b) return a.amount > b.amount end)
				if #wares > 0 then
					-- remaining cargo
					local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
					row[1]:setColSpan(numcolumns):createText(ReadText(1001, 8355), { halign = "center", font = Helper.standardFontOutlined, fontsize = menu.selectedShipsTableData.fontsize })
					-- line
					local row = ftable:addRow(false, { fixed = true, borderBelow = false, bgColor = Helper.color.white })
					row[1]:setColSpan(numcolumns):createText("", { height = 2 })
					-- cargo list
					local setting = config.layersettings["layer_trade"][1]
					local list = menu.getFilterOption(setting.id) or {}
					for i, entry in ipairs(wares) do
						local index
						for j, ware in ipairs(list) do
							if ware == entry.ware then
								index = j
								break
							end
						end

						local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
						local color = ((#list == 0) or index) and Helper.color.white or Helper.color.darkgrey
						row[1]:setColSpan(numcolumns):createButton({ bgColor = Helper.color.transparent }):setText(entry.name, { color = color }):setText2(entry.amount, { halign = "right", color = color })
						if index then
							row[1].handlers.onClick = function () return menu.removeFilterOption(setting, setting.id, index) end
						else
							row[1].handlers.onClick = function () return menu.setFilterOption("layer_trade", setting, setting.id, entry.ware) end
						end
						if (#wares > 5) and (i == 4) then
							break
						end
					end
					if #wares > 5 then
						local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent, scaling = true })
						row[1]:setColSpan(numcolumns):createText("+" .. (#wares - 4) .. " " .. ReadText(1001, 46))
					end
				end
			end
		end
	end

	ftable.properties.y = Helper.viewHeight - ftable:getFullHeight() - menu.borderOffset
end

function menu.sortShipsByClassAndPurpose(a, b)
	local aclass = config.classOrder[a.class] or 0
	local bclass = config.classOrder[b.class] or 0
	if aclass == bclass then
		local apurpose = (a.purpose ~= "") and config.purposeOrder[a.purpose] or 0
		local bpurpose = (b.purpose ~= "") and config.purposeOrder[b.purpose] or 0
		return apurpose < bpurpose
	else
		return aclass < bclass
	end
end

function menu.sortShipsByClassAndPurposeReverse(a, b)
	local apurpose = (a.purpose ~= "") and config.purposeOrder[a.purpose] or 0
	local bpurpose = (b.purpose ~= "") and config.purposeOrder[b.purpose] or 0
	if apurpose == bpurpose then
		local aclass = config.classOrder[a.class] or 0
		local bclass = config.classOrder[b.class] or 0
		return aclass < bclass
	else
		return apurpose > bpurpose
	end
end

function menu.findEntryByShipIcon(array, icon, color)
	for i, entry in ipairs(array) do
		if (entry.icon == icon) and (color == color) then
			return i
		end
	end
end

function menu.createTopLevel(frame)
	if (menu.mode == "hire") or (menu.mode == "selectCV") or (menu.mode == "orderparam_object") then
		local width = 400
		local ftable = frame:addTable(1, {
			tabOrder = 20,
			width = width,
			x = Helper.viewWidth / 2 - width / 2,
			y = Helper.topLevelConfig.y,
			scaling = false,
			reserveScrollBar = false,
			skipTabChange = true,
			backgroundID = "solid",
			backgroundColor = Helper.color.semitransparent,
		})
		local row = ftable:addRow(false, { fixed = true })

		local title = ""
		if menu.mode == "hire" then
			title = (menu.modeparam[3] ~= 0) and ReadText(1001, 3500) or ReadText(1001, 3264)
		elseif menu.mode == "selectCV" then
			title = ReadText(1001, 7942)
		elseif menu.mode == "orderparam_object" then
			title = ReadText(1001, 8325)
		end

		row[1]:createText(title, Helper.titleTextProperties)
	else
		menu.topLevelHeight = Helper.createTopLevelTab(menu, "map", frame, (menu.mode == "tradecontext") and ReadText(1001, 7104) or "", menu.conversationMenu, true)
	end
end

function menu.onTabScroll(direction)
	if direction == "right" then
		Helper.scrollTopLevel(menu, "map", 1)
	elseif direction == "left" then
		Helper.scrollTopLevel(menu, "map", -1)
	end
end

function menu.onInputModeChanged(_, mode)
	menu.refreshMainFrame = true
end

function menu.createNewOrderContext(frame)
	local ftable = frame:addTable(1, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })

	local aipilot = GetComponentData(menu.infoSubmenuObject, "assignedaipilot")
	local adjustedskill = aipilot and math.floor(C.GetEntityCombinedSkill(ConvertIDTo64Bit(aipilot), nil, "aipilot")) or 0

	-- title
	local row = ftable:addRow(false, { fixed = true })
	row[1]:createText(menu.contextMenuData.default and ReadText(1001, 8321) or ReadText(1001, 3238), Helper.headerRowCenteredProperties)

	for category, orderdefs in Helper.orderedPairs(menu.orderdefsbycategory) do
		if category ~= "internal" then
			local header = false
			for _, orderdef in ipairs(orderdefs) do
				if (menu.contextMenuData.default and orderdef.infinite) or ((not menu.contextMenuData.default)) then
					if not header then
						local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
						row[1]:createText(orderdef.categoryname, Helper.headerRowCenteredProperties)
						header = true
					end
			
					local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
					local button = row[1]:createButton({ active = C.IsOrderSelectableFor(orderdef.id, menu.infoSubmenuObject), bgColor = Helper.color.transparent }):setText(orderdef.name)
					if menu.contextMenuData.default then
						local printedSkillReq = math.floor(orderdef.requiredSkill * 5 / 100)
						button.properties.active = button.properties.active and (orderdef.requiredSkill <= adjustedskill)
						button:setText2(string.rep(utf8.char(9733), printedSkillReq) .. string.rep(utf8.char(9734), 5 - printedSkillReq), { font = Helper.starFont, halign = "right", color = Helper.color.brightyellow })
					end
					row[1].handlers.onClick = function () return menu.buttonNewOrder(orderdef.id, menu.contextMenuData.default) end
					row[1].properties.uiTriggerID = orderdef.name
				end
			end
		end
	end
end

function menu.createOrderparamWareContext(frame)
	local param
	if menu.contextMenuData.order == "default" then
		param = menu.infoTableData.defaultorder.params[menu.contextMenuData.param]
	elseif menu.contextMenuData.order == "planneddefault" then
		param = menu.infoTableData.planneddefaultorder.params[menu.contextMenuData.param]
	else
		param = menu.infoTableData.orders[menu.contextMenuData.order].params[menu.contextMenuData.param]
	end

	local ftable = frame:addTable(1, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })

	-- title
	local row = ftable:addRow(false, { fixed = true })
	row[1]:createText(ReadText(1001, 8306), Helper.headerRowCenteredProperties)

	menu.contextMenuData.wares = {}
	
	if param.inputparams.mining then
		local sector = ConvertIDTo64Bit(param.inputparams.mining[1])
		local pos = param.inputparams.mining[2]
		local nummineables = C.GetNumMineablesAtSectorPos(sector, pos)
		local mineables = ffi.new("YieldInfo[?]", nummineables)
		nummineables = C.GetMineablesAtSectorPos(mineables, nummineables, sector, pos)
		for i = 0, nummineables - 1 do
			table.insert(menu.contextMenuData.wares, ffi.string(mineables[i].wareid))
		end
	elseif param.inputparams.cargoof then
		local buf = GetComponentData(param.inputparams.cargoof, "cargo")
		for ware in pairs(buf) do
			table.insert(menu.contextMenuData.wares, ware)
		end
	elseif param.inputparams.soldby then
		local buf = GetComponentData(param.inputparams.soldby, "products")
		for _, ware in ipairs(buf) do
			table.insert(menu.contextMenuData.wares, ware)
		end
	elseif param.inputparams.boughtby then
		local buf = GetComponentData(param.inputparams.boughtby, "allresources")
		for _, ware in ipairs(buf) do
			table.insert(menu.contextMenuData.wares, ware)
		end
	else 
		for name, ware in pairs(menu.economyWares) do
			table.insert(menu.contextMenuData.wares, ware)
		end
	end
	if param.inputparams.cancarry then
		for i = #menu.contextMenuData.wares, 1, -1 do
			local ware = menu.contextMenuData.wares[i]
			if GetWareCapacity(param.inputparams.cancarry, ware, true) == 0 then
				table.remove(menu.contextMenuData.wares, i)
			end
		end
	end

	if (param.type == "list") and param.value then
		for i = #menu.contextMenuData.wares, 1, -1 do
			for _, ware in ipairs(param.value) do
				if ware == menu.contextMenuData.wares[i] then
					table.remove(menu.contextMenuData.wares, i)
					break
				end
			end
		end
	end

	table.sort(menu.contextMenuData.wares, Helper.sortWareName)

	if #menu.contextMenuData.wares > 0 then
		for _, ware in ipairs(menu.contextMenuData.wares) do
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:createButton({ bgColor = Helper.color.transparent, height = config.mapRowHeight }):setText(GetWareData(ware, "name"))
			row[1].handlers.onClick = function () return menu.buttonSetOrderParam(menu.contextMenuData.order, menu.contextMenuData.param, menu.contextMenuData.index, ware) end
		end
	else
		local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
		row[1]:createText("--- " .. ReadText(1001, 32) .. " ---", { halign = "center" })
	end
end

function menu.createOrderparamFormationShapeContext(frame)
	local param
	if menu.contextMenuData.order == "default" then
		param = menu.infoTableData.defaultorder.params[menu.contextMenuData.param]
	elseif menu.contextMenuData.order == "planneddefault" then
		param = menu.infoTableData.planneddefaultorder.params[menu.contextMenuData.param]
	else
		param = menu.infoTableData.orders[menu.contextMenuData.order].params[menu.contextMenuData.param]
	end

	local ftable = frame:addTable(1, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })

	-- title
	local row = ftable:addRow(false, { fixed = true })
	row[1]:createText(ReadText(1001, 8307), Helper.headerRowCenteredProperties)

	menu.contextMenuData.formationshapes = {}
	local n = C.GetNumFormationShapes()
	local buf = ffi.new("UIFormationInfo[?]", n)
	n = C.GetFormationShapes(buf, n)
	for i = 0, n - 1 do
		table.insert(menu.contextMenuData.formationshapes, { name = ffi.string(buf[i].name), shape = ffi.string(buf[i].shape) })
	end

	table.sort(menu.contextMenuData.formationshapes, Helper.sortName)

	for _, formation in ipairs(menu.contextMenuData.formationshapes) do
		local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
		row[1]:createButton({ bgColor = Helper.color.transparent }):setText(formation.name)
		row[1].handlers.onClick = function () return menu.buttonSetOrderParam(menu.contextMenuData.order, menu.contextMenuData.param, menu.contextMenuData.index, formation.shape) end
	end
end

function menu.defaultInteraction(component, posrot, posrotvalid, offsetx, offsety)
	local occupiedship = C.GetPlayerOccupiedShipID()
	if C.IsComponentClass(component, "sector") then
		for id, _ in pairs(menu.selectedcomponents) do
			local selectedcomponent = ConvertStringTo64Bit(id)
			if selectedcomponent ~= occupiedship then
				if GetComponentData(selectedcomponent, "isplayerowned") then
					menu.orderMoveWait(selectedcomponent, component, posrot, false)
				end
			end
		end
	elseif GetComponentData(ConvertStringToLuaID(tostring(component)), "isenemy") then
		for id, _ in pairs(menu.selectedcomponents) do
			local selectedcomponent = ConvertStringTo64Bit(id)
			if selectedcomponent ~= occupiedship then
				if GetComponentData(selectedcomponent, "isplayerowned") then
					menu.orderAttack(selectedcomponent, component, false)
				end
			end
		end
	elseif C.IsComponentClass(component, "station") then
		menu.contextMenuMode = "trade"
		menu.contextMenuData = { component = component, orders = {} }

		local numwarerows, numinforows = menu.initTradeContextData()
		menu.updateTradeContextDimensions(numwarerows, numinforows)

		local width = menu.tradeContext.width
		local height = menu.tradeContext.shipheight + menu.tradeContext.buttonheight + 1 * Helper.borderSize

		if offsetx + width > Helper.viewWidth then
			offsetx = Helper.viewWidth - width - config.contextBorder
		end
		if offsety + height > Helper.viewHeight then
			offsety = Helper.viewHeight - height - config.contextBorder
		end

		menu.createContextFrame(width, height, offsetx, offsety)
	end
	if (menu.infoTableMode == "info") and ((menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced")) then
		menu.refreshInfoFrame()
	elseif (menu.infoTableMode == "mission") then
		menu.refreshIF = getElapsedTime()
	end
end

function menu.getTransportTagsFromString(s)
	local types = {}
	while string.len(s) > 0 do
		local pos = string.find(s, " ", 1, true)
		if not pos then
			types[s] = true
			break
		elseif pos > 1 then
			types[string.sub(s, 1, pos - 1)] = true
		end
		s = string.sub(s, pos + 1)
	end
	return types
end

function menu.getCargoTransportTypes(container)
	local transporttypes = { }
	local n = C.GetNumCargoTransportTypes(container, true)
	local buf = ffi.new("StorageInfo[?]", n)
	n = C.GetCargoTransportTypes(buf, n, container, true, true)

	-- Fill transporttypes list
	for i = 0, n - 1 do
		local tags = menu.getTransportTagsFromString(ffi.string(buf[i].transport))
		local name
		if tags.container and tags.solid and tags.liquid then
			name = ReadText(20109, 801)		-- Universal Storage
		elseif tags.container then
			name = ReadText(20109, 101)		-- Container Storage
		elseif tags.solid then
			name = ReadText(20109, 301)		-- Solid Storage
		elseif tags.liquid then
			name = ReadText(20109, 601)		-- Liquid Storage
		else
			name = ffi.string(buf[i].name)	-- Should never happen
		end
		table.insert(transporttypes, { name = name, tags = tags, initialstored = 0, stored = 0, capacity = buf[i].capacity })
	end
	-- Sort transport types (first container, then solid, then liquid, then universal, then anything else)
	-- NOTE: Universal storage isn't supposed to be mixed with container, solid or liquid storage, but if it is, then the order is important,
	-- so that the storage visualisation doesn't break completely (fill container/solid/liquid storage instead of universal storage)
	table.sort(transporttypes,
		function (a, b)
			if a.tags.liquid ~= b.tags.liquid then
				return not a.tags.liquid
			elseif a.tags.solid ~= b.tags.solid then
				return not a.tags.solid
			elseif a.tags.container ~= b.tags.container then
				return not a.tags.container
			else
				return a.name < b.name
			end
		end)

	-- initialize initialstored
	menu.getTradeContextInitialStorageData(container, transporttypes)

	return transporttypes
end

function menu.initTradeContextData()
	local convertedTradeOfferContainer = ConvertStringToLuaID(tostring(menu.contextMenuData.component))

	-- Ships
	local occupiedship = C.GetPlayerOccupiedShipID()
	menu.contextMenuData.isoccupiedshipdocked = false
	if occupiedship ~= 0 then
		menu.contextMenuData.isoccupiedshipdocked = GetComponentData(ConvertStringTo64Bit(tostring(occupiedship)), "isdocked")
	end
	menu.contextMenuData.ships = menu.getShipList(menu.contextMenuData.isoccupiedshipdocked)
	for i, ship in ipairs(menu.contextMenuData.ships) do
		if ConvertIDTo64Bit(ship.shipid) == menu.contextMenuData.component then
			table.remove(menu.contextMenuData.ships, i)
			break
		end
	end
	local convertedCurrentShip
	if not menu.contextMenuData.currentShip then
		for id, _ in pairs(menu.selectedcomponents) do
			local selectedcomponent = ConvertStringTo64Bit(id)
			if menu.contextMenuData.isoccupiedshipdocked or (selectedcomponent ~= occupiedship) then
				if GetComponentData(selectedcomponent, "isplayerowned") and C.IsComponentClass(selectedcomponent, "ship") then
					menu.contextMenuData.currentShip = selectedcomponent
					convertedCurrentShip = ConvertStringToLuaID(id)
					break
				end
			end
		end
		if not menu.contextMenuData.currentShip then
			if #menu.contextMenuData.ships > 0 then
				if menu.contextMenuData.isoccupiedshipdocked then
					for _, ship in ipairs(menu.contextMenuData.ships) do
						if ConvertIDTo64Bit(ship.shipid) == occupiedship then
							menu.contextMenuData.currentShip = ConvertIDTo64Bit(ship.shipid)
							convertedCurrentShip = ship.shipid
							break
						end
					end
				end
				if not menu.contextMenuData.currentShip then
					menu.contextMenuData.currentShip = ConvertIDTo64Bit(menu.contextMenuData.ships[1].shipid)
					convertedCurrentShip = menu.contextMenuData.ships[1].shipid
				end
			else
				menu.contextMenuData.currentShip = 0
				convertedCurrentShip = nil
			end
		end
	else
		convertedCurrentShip = ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip))
	end

	menu.contextMenuData.immediate = menu.contextMenuData.isoccupiedshipdocked and (menu.contextMenuData.currentShip == occupiedship)
	menu.contextMenuData.playerMoney = GetPlayerMoney()

	-- virtual cargo mode
	if convertedCurrentShip then
		SetVirtualCargoMode(convertedCurrentShip, true, menu.contextMenuData.immediate and C.GetNumTradeComputerOrders(menu.contextMenuData.currentShip) or -1)
	end
	if menu.contextMenuData.wareexchange then
		if C.IsComponentOperational(menu.contextMenuData.component) then
			SetVirtualCargoMode(convertedTradeOfferContainer, true)
			menu.contextMenuData.currentothercargo = GetCargoAfterTradeOrders(convertedTradeOfferContainer)
			menu.contextMenuData.currentotherammo = GetAmmoCountAfterTradeOrders(convertedTradeOfferContainer)
		end
	end

	menu.contextMenuData.currentcargo = convertedCurrentShip and GetCargoAfterTradeOrders(convertedCurrentShip) or {}
	menu.contextMenuData.currentammo = convertedCurrentShip and GetAmmoCountAfterTradeOrders(convertedCurrentShip) or {}

	-- Trade offers
	menu.contextMenuData.buyoffers = {}
	menu.contextMenuData.selloffers = {}
	menu.contextMenuData.buywares = {}
	menu.contextMenuData.sellwares = {}
	menu.contextMenuData.buyammowares = {}
	menu.contextMenuData.sellammowares = {}

	local tradeoffers, nontradeoffers = {}, {}
	if menu.contextMenuData.wareexchange then
		tradeoffers = GetWareExchangeTradeList(convertedCurrentShip, convertedTradeOfferContainer)
		-- Mark any equipment wares as such (only relevant for ware exchange)
		for _, tradedata in pairs(tradeoffers) do
			tradedata.ammotypename = menu.getAmmoTypeNameByWare(tradedata.ware)
		end
	else
		tradeoffers = GetTradeList(convertedTradeOfferContainer, convertedCurrentShip)
		nontradeoffers = GetTradeList(convertedTradeOfferContainer, convertedCurrentShip, false)
	end
	for _, tradedata in pairs(tradeoffers) do
		if (not menu.contextMenuData.shadyOnly) or tradedata.isshady then
			local currentwares = tradedata.ammotypename and menu.contextMenuData.currentammo or menu.contextMenuData.currentcargo
			local currentotherwares = tradedata.ammotypename and menu.contextMenuData.currentotherammo or menu.contextMenuData.currentothercargo	-- may be nil
			local buywares = tradedata.ammotypename and menu.contextMenuData.buyammowares or menu.contextMenuData.buywares
			local sellwares = tradedata.ammotypename and menu.contextMenuData.sellammowares or menu.contextMenuData.sellwares

			if tradedata.isbuyoffer then
				tradedata.active = convertedCurrentShip and currentwares[tradedata.ware] and CanTradeWith(tradedata.id, convertedCurrentShip, tradedata.minamount)
				table.insert(menu.contextMenuData.buyoffers, tradedata)
				buywares[tradedata.ware] = tradedata
				if tradedata.active and currentotherwares then
					currentotherwares[tradedata.ware] = currentotherwares[tradedata.ware] or 0
				end 
			elseif tradedata.isselloffer then
				tradedata.active = convertedCurrentShip and CanTradeWith(tradedata.id, convertedCurrentShip, tradedata.minamount)
				table.insert(menu.contextMenuData.selloffers, tradedata)
				sellwares[tradedata.ware] = tradedata
				if tradedata.active then
					currentwares[tradedata.ware] = currentwares[tradedata.ware] or 0
				end
			end
		end
	end
	for _, tradedata in pairs(nontradeoffers) do
		if (not menu.contextMenuData.shadyOnly) or tradedata.isshady then
			local currentwares = tradedata.ammotypename and menu.contextMenuData.currentammo or menu.contextMenuData.currentcargo
			local currentotherwares = tradedata.ammotypename and menu.contextMenuData.currentotherammo or menu.contextMenuData.currentothercargo	-- may be nil
			local buywares = tradedata.ammotypename and menu.contextMenuData.buyammowares or menu.contextMenuData.buywares
			local sellwares = tradedata.ammotypename and menu.contextMenuData.sellammowares or menu.contextMenuData.sellwares

			if tradedata.isbuyoffer then
				if not buywares[tradedata.ware] then
					tradedata.active = false
					tradedata.stale = true
					table.insert(menu.contextMenuData.buyoffers, tradedata)
					buywares[tradedata.ware] = tradedata
				end
			elseif tradedata.isselloffer then
				if not sellwares[tradedata.ware] then
					tradedata.active = false
					tradedata.stale = true
					table.insert(menu.contextMenuData.selloffers, tradedata)
					sellwares[tradedata.ware] = tradedata
				end
			end
		end
	end

	-- Distribute cargo to transport type capacities
	menu.contextMenuData.transporttypes = (menu.contextMenuData.currentShip ~= 0) and menu.getCargoTransportTypes(menu.contextMenuData.currentShip) or {}
	menu.contextMenuData.othershiptransporttypes = (menu.contextMenuData.wareexchange and menu.contextMenuData.component ~= 0) and menu.getCargoTransportTypes(menu.contextMenuData.component) or {}

	menu.contextMenuData.ammotypes = { }
	if menu.contextMenuData.wareexchange and menu.contextMenuData.component ~= 0 then
		-- ammo is only relevant and visible in ware exchange case
		local missilecapacity1, countermeasurecapacity1, deployablecapacity1 = GetComponentData(convertedCurrentShip, "missilecapacity", "countermeasurecapacity", "deployablecapacity")
		local missilecapacity2, countermeasurecapacity2, deployablecapacity2 = GetComponentData(convertedTradeOfferContainer, "missilecapacity", "countermeasurecapacity", "deployablecapacity")
		local unitcapacity1 = GetUnitStorageData(convertedCurrentShip).capacity
		local unitcapacity2 = GetUnitStorageData(convertedTradeOfferContainer).capacity
		-- missiles
		if missilecapacity1 > 0 or missilecapacity2 > 0 then
			table.insert(menu.contextMenuData.ammotypes, { name = ReadText(1001, 1304), type = "missile", stored = 0, otherstored = 0, capacity = missilecapacity1, othercapacity = missilecapacity2 })
		end
		-- countermeasures
		if countermeasurecapacity1 > 0 or countermeasurecapacity2 > 0 then
			table.insert(menu.contextMenuData.ammotypes, { name = ReadText(1001, 8063), type = "countermeasure", stored = 0, otherstored = 0, capacity = countermeasurecapacity1, othercapacity = countermeasurecapacity2 })
		end
		-- units
		if unitcapacity1 > 0 or unitcapacity2 > 0 then
			table.insert(menu.contextMenuData.ammotypes, { name = ReadText(1001, 8), type = "unit", stored = 0, otherstored = 0, capacity = unitcapacity1, othercapacity = unitcapacity2 })
		end
		-- units
		if deployablecapacity1 > 0 or deployablecapacity2 > 0 then
			table.insert(menu.contextMenuData.ammotypes, { name = ReadText(1001, 8064), type = "deployable", stored = 0, otherstored = 0, capacity = deployablecapacity1, othercapacity = deployablecapacity2 })
		end
	end

	-- cost
	menu.contextMenuData.totalbuyprofit = 0
	menu.contextMenuData.totalsellcost = 0
	menu.contextMenuData.referenceprofit = 0

	-- Merge selloffers and buyoffers into waredatalist
	local waredatatable = {}
	local waredatalist = {}
	for _, tradedata in ipairs(menu.contextMenuData.selloffers) do
		if not menu.contextMenuData.wareexchange then
			AddKnownItem("wares", tradedata.ware)
		end
		local waredata = { ware = tradedata.ware, active = tradedata.active, sell = tradedata, stale = tradedata.stale }
		waredatatable[tradedata.ware] = waredata
		table.insert(waredatalist, waredata)
	end
	for _, tradedata in ipairs(menu.contextMenuData.buyoffers) do
		local waredata = waredatatable[tradedata.ware]
		if not waredata then
			if not menu.contextMenuData.wareexchange then
				AddKnownItem("wares", tradedata.ware)
			end
			waredata = { ware = tradedata.ware }
			waredatatable[tradedata.ware] = waredata
			table.insert(waredatalist, waredata)
		end
		waredata.buy = tradedata
		waredata.active = waredata.active or tradedata.active
		waredata.stale = waredata.stale and tradedata.stale
	end
	-- Sort wares: First by cargo/ammo type, then active before inactive, then sorted by name
	table.sort(waredatalist,
		function (a, b)
			local aidx, bidx = menu.getAmmoDataIdxByWare(a.ware), menu.getAmmoDataIdxByWare(b.ware)
			if aidx ~= bidx then
				return aidx < bidx
			elseif (not a.active) ~= (not b.active) then
				return not b.active
			else
				return Helper.sortWareName(a.ware, b.ware)
			end
		end)

	-- Store waredatalist so we always know how many lines there are in the shiptable
	menu.contextMenuData.waredatalist = waredatalist

	-- If no wares, there is still a line displayed ("No known offers" / "No wares")
	local numwarerows = math.max(1, #menu.contextMenuData.waredatalist)
	local numinforows = math.max(#menu.contextMenuData.transporttypes, #menu.contextMenuData.othershiptransporttypes) + #menu.contextMenuData.ammotypes
	if not menu.contextMenuData.wareexchange and numinforows < 2 then
		numinforows = 2			-- reserve space for "Profits from sales" and "Transaction value"
	end
	return numwarerows, numinforows
end

function menu.sortByActiveAndName(a, b)
	if a.active == b.active then 
		return Helper.sortName(a, b)
	end
	return a.active
end

function menu.sortByActiveAndWareName(a, b)
	if a.active == b.active then 
		return GetWareData(a.ware, "name") < GetWareData(b.ware, "name")
	end
	return a.active
end

function menu.getAmmoTypeNameByWare(ware)
	local transport, macro = GetWareData(ware, "transport", "component")
	if transport == "equipment" and macro ~= "" then
		if IsMacroClass(macro, "missile") then
			return "missile"
		elseif IsMacroClass(macro, "countermeasure") then
			return "countermeasure"
		elseif GetMacroData(macro, "isunit") then
			return "unit"
		elseif GetMacroData(macro, "isdeployable") then
			return "deployable"
		end
	end
	return nil
end

function menu.getAmmoDataIdxByWare(ware)
	local ammotypename = menu.getAmmoTypeNameByWare(ware)
	if ammotypename then
		for idx, equipmentdata in ipairs(menu.contextMenuData.ammotypes) do
			if equipmentdata.type == ammotypename then
				return idx
			end
		end
	end
	return 0
end

function menu.getAmmoDataByWare(ware)
	local idx = menu.getAmmoDataIdxByWare(ware)
	if idx > 0 then
		return menu.contextMenuData.ammotypes[idx]
	end
	return nil
end

function menu.updateTradeCost()
	local convertedCurrentShip = ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip))
	local convertedTradeOfferContainer = ConvertStringToLuaID(tostring(menu.contextMenuData.component))
	local isplayertradeoffercontainer = GetComponentData(convertedTradeOfferContainer, "isplayerowned")

	for _, transporttype in ipairs(menu.contextMenuData.transporttypes) do
		transporttype.stored = 0
	end
	for ware, amount in pairs(menu.contextMenuData.currentcargo) do
		local transport, volume = GetWareData(ware, "transport", "volume")
		for _, transporttype in ipairs(menu.contextMenuData.transporttypes) do
			if transporttype.tags[transport] then
				local orderamount = menu.getCargoOrderAmountByWare(ware)
				transporttype.stored = transporttype.stored + (amount - orderamount) * volume
				break
			end
		end
	end

	for _, ammotype in ipairs(menu.contextMenuData.ammotypes) do
		ammotype.stored = 0
		ammotype.otherstored = 0
	end
	for ware, amount in pairs(menu.contextMenuData.currentammo) do
		local ammotype = menu.getAmmoDataByWare(ware)
		if ammotype then
			ammotype.stored = ammotype.stored + amount - menu.getAmmoOrderAmountByWare(ware)
		end
	end

	if menu.contextMenuData.wareexchange then
		for _, transporttype in ipairs(menu.contextMenuData.othershiptransporttypes) do
			transporttype.stored = transporttype.initialstored
		end
		for ware, amount in pairs(menu.contextMenuData.currentothercargo) do
			local transport, volume = GetWareData(ware, "transport", "volume")
			-- below is done to handle trade partners that have more than one storage module type with a particular storage type (ex: solid and universal)
			local leftover = 0
			local orderamount = menu.getCargoOrderAmountByWare(ware)
			if orderamount ~= 0 then
				for _, transporttype in ipairs(menu.contextMenuData.othershiptransporttypes) do
					--print("init stored: " .. tostring(transporttype.stored))
					if transporttype.tags[transport] then
						local volumechange = orderamount * volume
						if leftover > 0 then
							volumechange = leftover * volume
							--print("1.1 ware: " .. tostring(ware) .. ", volumechange: " .. tostring(volumechange) .. ", transporttype.capacity: " .. tostring(transporttype.capacity))
						end

						--print(tostring(_) .. ": 2.0 ware: " .. tostring(ware) .. ", orderamount: " .. tostring(orderamount) .. ", volumechange: " .. tostring(volumechange) .. ", transporttype.capacity: " .. tostring(transporttype.capacity))
						if (transporttype.stored + volumechange) > transporttype.capacity then
							local evalamount = orderamount
							local evalvolume = transporttype.stored + volumechange
							while evalvolume > transporttype.capacity do
								evalamount = evalamount - 1
								evalvolume = transporttype.stored + evalamount * volume
							end
							transporttype.stored = evalvolume
							leftover = orderamount - evalamount
							--print("2.1 ware: " .. tostring(ware) .. ", leftover volume: " .. tostring(leftover * volume))
						else
							leftover = 0
							transporttype.stored = transporttype.stored + volumechange
							--print("2.2 ware: " .. tostring(ware) .. ", total stored: " .. tostring(transporttype.stored) .. ", capacity: " .. tostring(transporttype.capacity))
							break
						end
					end
				end
			end
		end
		for ware, amount in pairs(menu.contextMenuData.currentotherammo) do
			local ammotype = menu.getAmmoDataByWare(ware)
			if ammotype then
				ammotype.otherstored = ammotype.otherstored + amount + menu.getAmmoOrderAmountByWare(ware)
			end
		end
	end

	menu.contextMenuData.totalbuyprofit = 0
	menu.contextMenuData.totalsellcost = 0
	menu.contextMenuData.referenceprofit = 0
	if not isplayertradeoffercontainer then
		for id, amount in pairs(menu.contextMenuData.orders) do
			local tradeoffer = menu.getTradeOfferByID(ConvertStringToLuaID(tostring(id)))
			local price = tradeoffer and tradeoffer.price or 0
			if amount < 0 then
				-- station sells
				menu.contextMenuData.totalsellcost = menu.contextMenuData.totalsellcost + RoundTotalTradePrice(price * -amount)
			elseif amount > 0 then
				-- station buys
				menu.contextMenuData.totalbuyprofit = menu.contextMenuData.totalbuyprofit + RoundTotalTradePrice(price * amount)
			end
			if price ~= 0 and amount ~= 0 then
				local defaultrefprofit = GetReferenceProfit(convertedCurrentShip, tradeoffer.ware, price, 0) or 0
				local newrefprofit = GetReferenceProfit(convertedCurrentShip, tradeoffer.ware, price, amount) or 0
				menu.contextMenuData.referenceprofit = menu.contextMenuData.referenceprofit + newrefprofit - defaultrefprofit
			end
		end
	end
end

function menu.getCargoOrderAmountByWare(ware)
	local result = 0
	local buyoffer = menu.contextMenuData.buywares[ware]
	if buyoffer then
		result = result + (menu.contextMenuData.orders[ConvertIDTo64Bit(buyoffer.id)] or 0)
	end
	local selloffer = menu.contextMenuData.sellwares[ware]
	if selloffer then
		result = result + (menu.contextMenuData.orders[ConvertIDTo64Bit(selloffer.id)] or 0)
	end
	return result
end

function menu.getAmmoOrderAmountByWare(ware)
	local result = 0
	local buyoffer = menu.contextMenuData.buyammowares[ware]
	if buyoffer then
		result = result + (menu.contextMenuData.orders[ConvertIDTo64Bit(buyoffer.id)] or 0)
	end
	local selloffer = menu.contextMenuData.sellammowares[ware]
	if selloffer then
		result = result + (menu.contextMenuData.orders[ConvertIDTo64Bit(selloffer.id)] or 0)
	end
	return result
end

function menu.getTradeOfferByID(id)
	for _, tradedata in ipairs(menu.contextMenuData.buyoffers) do
		if IsSameTrade(tradedata.id, id) then
			return tradedata
		end
	end
	for _, tradedata in ipairs(menu.contextMenuData.selloffers) do
		if IsSameTrade(tradedata.id, id) then
			return tradedata
		end
	end

	return nil
end

function menu.interpolatePriceColor(ware, price, isselloffer, darkbasecolor)
	-- In case both selloffer and buyoffer exist, we can show both offer amounts, but everything else can be shown only for one offer.
	-- In that case prefer selloffer data (for buying - change to buyoffer when player attempts to sell)
	local avgprice, minprice, maxprice = GetWareData(ware, "avgprice", "minprice", "maxprice")
	-- Get interpolated price color
	local avgcolor = Helper.color.white
	local mincolor = (isselloffer and Helper.color.lightgreen or Helper.color.orange)
	local maxcolor = (isselloffer and Helper.color.orange or Helper.color.lightgreen)
	local color = avgcolor
	local lerpfactor = 0
	if avgprice ~= 0 and minprice < avgprice and maxprice > avgprice and price ~= avgprice then
		price = math.min(maxprice, math.max(minprice, price))
		if price > avgprice then
			color = maxcolor
			lerpfactor = (price - avgprice) / (maxprice - avgprice)
		else
			color = mincolor
			lerpfactor = (price - avgprice) / (minprice - avgprice)
		end
		--print(ware .. " min=" .. minprice .. " avg=" .. avgprice .. " max=" .. maxprice .. " (price=" .. price .. " => lerpfactor " .. lerpfactor .. ")")
	end
	-- Make price color darker if requested
	darkbasecolor = darkbasecolor or Helper.color.white
	return {
		r = (avgcolor.r - lerpfactor * (avgcolor.r - color.r)) * darkbasecolor.r / Helper.color.white.r,
		g = (avgcolor.g - lerpfactor * (avgcolor.g - color.g)) * darkbasecolor.g / Helper.color.white.g,
		b = (avgcolor.b - lerpfactor * (avgcolor.b - color.b)) * darkbasecolor.b / Helper.color.white.b,
		a = (avgcolor.a - lerpfactor * (avgcolor.a - color.a)) * darkbasecolor.a / Helper.color.white.a
	}
end

function menu.getTradeContextStorableAmountAfterTradeOrders(ship, ware, ammotypename)
	if ammotypename == "missile" then
		return C.GetFreeMissileStorageAfterTradeOrders(ship)
	elseif ammotypename == "countermeasure" then
		return C.GetFreeCountermeasureStorageAfterTradeOrders(ship)
	elseif ammotypename == "unit" then
		return GetFreeUnitStorageAfterTradeOrders(ConvertStringToLuaID(tostring(ship)))
	elseif ammotypename == "deployable" then
		return C.GetFreeDeployableStorageAfterTradeOrders(ship)
	end
	return GetFreeCargoAfterTradeOrders(ConvertStringToLuaID(tostring(ship)), ware)
end

function menu.getTradeContextRowContent(waredata)
	local convertedCurrentShip = ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip))
	local convertedTradeOfferContainer = ConvertStringToLuaID(tostring(menu.contextMenuData.component))
	local isplayertradeoffercontainer = GetComponentData(convertedTradeOfferContainer, "isplayerowned")
	local name = GetWareData(waredata.ware, "name")
	local activecolor = (waredata.active and Helper.color.white or Helper.color.grey)
	local color = activecolor
	local mouseovertext = ""

	local numillegalfactions = C.GetNumIllegalToFactions(waredata.ware)
	local buf = ffi.new("const char*[?]", numillegalfactions)
	numillegalfactions = C.GetIllegalToFactions(buf, numillegalfactions, waredata.ware)
	if numillegalfactions > 0 then
		name = "\027[workshop_error]" .. name
		color = waredata.active and Helper.color.orange or Helper.color.darkorange
		local mouseovertextcolor = Helper.color.orange
		mouseovertext = string.format("\027#FF%02x%02x%02x#", mouseovertextcolor.r, mouseovertextcolor.g, mouseovertextcolor.b) .. ReadText(1001, 2437) .. ReadText(1001, 120)
		for i = 0, numillegalfactions - 1 do
			mouseovertext = mouseovertext .. "\n" .. GetFactionData(ffi.string(buf[i]), "name")
		end
	end

	local warnings, optionalsellwarnings, optionalbuywarnings = {}, {}, {}
	local hassellamount, hasbuyamount = false, false

	local selloffer_max, selloffer_maxselect, selloffer_curorder = 0, 0, 0
	if waredata.sell then
		if waredata.sell.amount > 0 then
			hassellamount = true
		end
		selloffer_curorder = math.min(0, menu.contextMenuData.orders[ConvertIDTo64Bit(waredata.sell.id)] or 0)
		local affordableamount = isplayertradeoffercontainer and waredata.sell.amount or GetNumAffordableTradeItems(GetPlayerMoney() - menu.contextMenuData.totalsellcost + RoundTotalTradePrice(-(menu.contextMenuData.orders[ConvertIDTo64Bit(waredata.sell.id)] or 0) * waredata.sell.price), waredata.sell.price)
		local storableamount = (menu.contextMenuData.currentShip ~= 0) and menu.getTradeContextStorableAmountAfterTradeOrders(menu.contextMenuData.currentShip, waredata.ware, waredata.sell.ammotypename) or 0
		-- curorder was already added to virtual cargo, don't count it twice
		storableamount = storableamount - selloffer_curorder
		selloffer_max = waredata.sell.amount
		selloffer_maxselect = math.min(waredata.sell.amount, affordableamount, storableamount)

		if selloffer_maxselect == 0 then
			if storableamount < waredata.sell.amount and storableamount < affordableamount then
				warnings[1] = ReadText(1001, 8337)
			elseif affordableamount < waredata.sell.amount and affordableamount < storableamount then
				warnings[2] = ReadText(1001, 8338)
			end
		else
			if storableamount < waredata.sell.amount and storableamount < affordableamount then
				optionalsellwarnings[1] = ReadText(1001, 8337)
			elseif affordableamount < waredata.sell.amount and affordableamount < storableamount then
				optionalsellwarnings[2] = ReadText(1001, 8338)
			end
		end

		if not waredata.sell.active then
			selloffer_max, selloffer_maxselect, selloffer_curorder = 0, 0, 0
		end
	end

	local buyoffer_max, buyoffer_maxselect, buyoffer_curorder = 0, 0, 0
	if waredata.buy then
		if waredata.buy.amount > 0 then
			hasbuyamount = true
		end
		buyoffer_curorder = math.max(0, menu.contextMenuData.orders[ConvertIDTo64Bit(waredata.buy.id)] or 0)
		local availableamount = (waredata.buy.ammotypename and menu.contextMenuData.currentammo[waredata.ware] or menu.contextMenuData.currentcargo[waredata.ware]) or 0
		buyoffer_maxselect = math.min(waredata.buy.amount, availableamount)
		buyoffer_max = waredata.buy.amount

		local othershipstorableamount
		if menu.contextMenuData.wareexchange then
			othershipstorableamount = menu.getTradeContextStorableAmountAfterTradeOrders(menu.contextMenuData.component, waredata.ware, waredata.buy.ammotypename)
			-- curorder was already added to virtual cargo, don't count it twice
			othershipstorableamount = othershipstorableamount + buyoffer_curorder
			buyoffer_maxselect = math.min(buyoffer_maxselect, othershipstorableamount)
		end
		
		if buyoffer_maxselect == 0 then
			if menu.contextMenuData.wareexchange and othershipstorableamount < waredata.buy.amount and othershipstorableamount < availableamount then
				warnings[3] = ReadText(1001, 8339)
			elseif availableamount < waredata.buy.amount then
				warnings[4] = ReadText(1001, 8340)
			end
		else
			if menu.contextMenuData.wareexchange and othershipstorableamount < waredata.buy.amount and othershipstorableamount < availableamount then
				optionalbuywarnings[3] = ReadText(1001, 8339)
			elseif availableamount < waredata.buy.amount then
				optionalbuywarnings[4] = ReadText(1001, 8340)
			end
		end

		if not waredata.buy.active then
			buyoffer_max, buyoffer_maxselect, buyoffer_curorder = 0, 0, 0
		end
	end

	if (not hassellamount) and (not hasbuyamount) then
		warnings[5] = ReadText(1001, 8341)
	end

	-- In case both selloffer and buyoffer exist, we can show both offer amounts, but all other columns can only show data for one offer.
	-- In that case prefer selloffer data (for buying - change to buyoffer when player attempts to sell)
	local tradedata = buyoffer_curorder ~= 0 and waredata.buy or waredata.sell or waredata.buy

	local avgprice = GetWareData(waredata.ware, "avgprice")
	local adjustment = avgprice ~= 0 and (tradedata.price / avgprice - 1) or 0
	local pricecolor = menu.interpolatePriceColor(waredata.ware, tradedata.price, tradedata == waredata.sell, activecolor)

	local movedamount = -(selloffer_curorder < 0 and selloffer_curorder or buyoffer_curorder)
	local shipamount = (menu.contextMenuData.currentcargo[waredata.ware] or menu.contextMenuData.currentammo[waredata.ware] or 0) + movedamount
	local shipamountcolor = (movedamount > 0 and Helper.color.lightgreen) or (movedamount < 0 and Helper.color.red) or color

	local othershipamount = (menu.contextMenuData.currentothercargo and (menu.contextMenuData.currentothercargo[waredata.ware] or menu.contextMenuData.currentotherammo[waredata.ware]) or 0) - movedamount
	local othershipamountcolor = (movedamount > 0 and Helper.color.red) or (movedamount < 0 and Helper.color.lightgreen) or color

	local scale = {
		--min       = waredata.buy and waredata.buy.ammotypename and -buyoffer_max or -buyoffer_maxselect, -- use real max only for ammo
		min       = -buyoffer_maxselect, --TODO: max
		minselect = -buyoffer_maxselect,
		--max       = waredata.sell and waredata.sell.ammotypename and selloffer_max or selloffer_maxselect, -- use real max only for ammo
		max       = selloffer_maxselect, --TODO: max
		maxselect = selloffer_maxselect,
		start     = movedamount,
		step      = 1,
		suffix    = "",
		fromcenter = true,
		righttoleft = true
	}

	local content = { {}, {}, {}, {}, nil, {}, {}, warnings, optionalsellwarnings, optionalbuywarnings }
	-- name
	content[1].text = name
	content[1].color = color
	content[1].mouseover = mouseovertext
	-- price
	if not menu.contextMenuData.wareexchange then
		content[2].text = (not waredata.stale) and ((isplayertradeoffercontainer and "-" or ConvertMoneyString(Helper.round(tradedata.price, 2), true, true, 0, true)) .. " " .. ReadText(1001, 101)) or ""
		content[2].color = pricecolor
		content[2].mouseover = (not waredata.stale) and (isplayertradeoffercontainer and "" or (Helper.diffpercent(adjustment * 100, tradedata.isbuyoffer) .. ReadText(1001,8304))) or ""
	end
	-- amount
	content[3].text = ConvertIntegerString(shipamount, true, 0, true)
	content[3].color = shipamountcolor
	-- slidercell
	content[4].scale = scale
	content[4].color = color
	if menu.contextMenuData.wareexchange then
		-- other ship amount
		content[6].text = ConvertIntegerString(othershipamount, true, 0, true)
		content[6].color = othershipamountcolor
	else
		-- sell offer
		content[6].text = (waredata.sell and (not waredata.sell.stale)) and ConvertIntegerString(waredata.sell.amount - math.max(movedamount, 0), true, 0, true) or ""
		content[6].color = color
		-- buy offer
		content[7].text = (waredata.buy and (not waredata.buy.stale)) and ConvertIntegerString(waredata.buy.amount - math.max(-movedamount, 0), true, 0, true) or ""
		content[7].color = color
	end
	return content
end

-- Only use this to get initial storage data. If we use this with every virtual storage change, we have to reset virtual cargo every time wares are removed from virtual cargo of othercontainer in the menu. Otherwise, this will result in a mismatch between the storage data in the menu and after the actual trade because each change is treated as a separate trade in virtual cargo.
-- For example: If we add A, add B, then remove A; virtual cargo treats this as three separate transactions and will fill storage accordingly; but the actual trade will only have one transaction: add B.
function menu.getTradeContextInitialStorageData(container, transporttypes)
	local numtransporttypes = C.GetNumCargoTransportTypes(container, true)
	local virtualtransporttypes = ffi.new("StorageInfo[?]", numtransporttypes)
	numtransporttypes = C.GetCargoTransportTypes(virtualtransporttypes, numtransporttypes, container, true, true)

	--typedef struct {
	--	const char* name;
	--	const char* transport;
	--	uint32_t spaceused;
	--	uint32_t capacity;
	--} StorageInfo;

	for _, transporttype in ipairs(transporttypes) do
		for j = 0, numtransporttypes - 1 do
			local tags = menu.getTransportTagsFromString(ffi.string(virtualtransporttypes[j].transport))

			local invalid = false
			for tag, _ in pairs(tags) do
				if not transporttype.tags[tag] then invalid = true; break end
			end
			if not invalid then
				for tag, _ in pairs(transporttype.tags) do
					if not tags[tag] then invalid = true; break end
				end
			end
			if not invalid then
				transporttype.initialstored = virtualtransporttypes[j].spaceused
				break
			end
		end
	end
end

function menu.getTradeContextShipStorageContent(othership)
	local storagecontent = {}

	for i, transporttype in ipairs(othership and menu.contextMenuData.othershiptransporttypes or menu.contextMenuData.transporttypes) do
		if i > menu.tradeContext.numinforows then
			break
		end
		local spaceused = transporttype.stored
		spaceused = math.max(0, math.min(spaceused, transporttype.capacity))
		table.insert(storagecontent, {
			name = transporttype.name,
			color = Helper.color.white,
			scale = {
				min       = 0,
				max       = transporttype.capacity,
				start     = spaceused,
				step      = 1,
				suffix    = ReadText(1001, 110),
				readonly  = true
			}
		})
	end

	-- add empty line if one ship has ammo of a type, but other doesn't
	for _, ammotype in ipairs(menu.contextMenuData.ammotypes) do
		if #storagecontent >= menu.tradeContext.numinforows then
			break
		end
		local spaceused = othership and ammotype.otherstored or ammotype.stored
		local capacity = othership and ammotype.othercapacity or ammotype.capacity
		spaceused = math.max(0, math.min(spaceused, capacity))
		table.insert(storagecontent, {
			name = ammotype.name,
			color = Helper.color.white,
			scale = {
				min       = 0,
				max       = capacity,
				start     = spaceused,
				step      = 1,
				suffix    = "     ",
				readonly  = true
			}
		})
	end

	return storagecontent
end

function menu.createTradeContext(frameData, width, height, xoffset, yoffset)
	menu.skipTradeRowChange = true

	-- Don't remove! - Double declaration intended as the other one could have been already cleaned up at this point (and vice versa)
	menu.emptyFontStringSmall = Helper.createFontString("", false, Helper.standardHalignment, Helper.standardColor.r, Helper.standardColor.g, Helper.standardColor.b, Helper.standardColor.a, Helper.standardFont, 1, false, Helper.headerRow1Offsetx, Helper.headerRow1Offsety, 4)

	if menu.arrowsRegistered then
		UnregisterAddonBindings("ego_detailmonitor", "map_arrows")
		menu.arrowsRegistered = nil
	end
	
	local convertedTradeOfferContainer = ConvertStringToLuaID(tostring(menu.contextMenuData.component))
	local isplayertradeoffercontainer = GetComponentData(convertedTradeOfferContainer, "isplayerowned")

	menu.updateTradeCost()
	local convertedCurrentShip = ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip))

	-- menu setup
	local amountcolumnwidth = 100
	local pricecolumnwidth = 100

	-- ship
	local setup = Helper.createTableSetup(menu)

	local columnwidth_ware   -- calculated below
	local columnwidth_price			= math.floor(width * 12 / 100)
	local columnwidth_shipstorage	= math.floor(width * 12 / 100)
	local columnwidth_sliderleft	= math.floor(width * 15 / 100)
	local columnwidth_sliderright	= math.floor(width * 15 / 100)
	local columnwidth_selloffer		= math.floor(width * 12 / 100)
	local columnwidth_buyoffer		= math.floor(width * 12 / 100)
	local widthcorrection = (menu.tradeContext.numwarerows > menu.tradeContext.warescrollwindowsize) and 0 or -menu.tradeContext.widthcorrection
	if menu.contextMenuData.wareexchange then
		-- nearly symmetrical menu layout in ware exchange case:
		--   price column = only a dummy in this case, always included in colspan.
		--   selloffer column = other ship storage
		--   buyoffer column = unused (almost same width as ware column)
		columnwidth_price = 1
		local remainingwidth = width - 6 * Helper.borderSize
			- columnwidth_price
			- columnwidth_shipstorage
			- columnwidth_sliderleft
			- columnwidth_sliderright
			- columnwidth_selloffer
		-- nearly symmetrical menu layout: 
		columnwidth_ware = math.ceil(remainingwidth / 2)
		columnwidth_buyoffer = remainingwidth - columnwidth_ware + widthcorrection
	else
		-- regular trade case
		columnwidth_ware = width + widthcorrection - 6 * Helper.borderSize
			- columnwidth_price
			- columnwidth_shipstorage
			- columnwidth_sliderleft
			- columnwidth_sliderright
			- columnwidth_selloffer
			- columnwidth_buyoffer
	end

	local name = Helper.unlockInfo(IsInfoUnlockedForPlayer(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), "name"), ffi.string(C.GetComponentName(menu.contextMenuData.component)) .. " (" .. ffi.string(C.GetObjectIDCode(menu.contextMenuData.component)) .. ")")
	local color = Helper.color.white
	if isplayertradeoffercontainer then
		color = Helper.color.green
	end

	--menu.topRows.contextoffertable = nil
	--menu.selectedRows.contextoffertable = nil

	local shipOptions = {}
	local curShipOption = tostring(convertedCurrentShip)

	local sortedShips = {}
	local found = false
	for _, ship in ipairs(menu.contextMenuData.ships) do
		if tostring(ship.shipid) == curShipOption then
			found = true
		end

		local class = ffi.string(C.GetComponentClass(ConvertStringTo64Bit(tostring(ship.shipid))))
		local icon, primarypurpose, hullpercent, shieldpercent, isplayerowned, isenemy = GetComponentData(ship.shipid, "icon", "primarypurpose", "hullpercent", "shieldpercent", "isplayerowned", "isenemy")
		local i = menu.findEntryByShipIcon(sortedShips, icon)
		if i then
			table.insert(sortedShips[i].ships, ship)
		else
			table.insert(sortedShips, { icon = icon, class = class, purpose = primarypurpose, ships = { ship } })
		end
	end
	if (not found) and (menu.contextMenuData.currentShip ~= 0) then
		local ship = { shipid = convertedCurrentShip, name = ffi.string(C.GetComponentName(menu.contextMenuData.currentShip)) }

		local class = ffi.string(C.GetComponentClass(menu.contextMenuData.currentShip))
		local icon, primarypurpose, hullpercent, shieldpercent, isplayerowned, isenemy = GetComponentData(ship.shipid, "icon", "primarypurpose", "hullpercent", "shieldpercent", "isplayerowned", "isenemy")
		local i = menu.findEntryByShipIcon(sortedShips, icon)
		if i then
			table.insert(sortedShips[i].ships, ship)
		else
			table.insert(sortedShips, { icon = icon, class = class, purpose = primarypurpose, ships = { ship } })
		end
	end
	table.sort(sortedShips, menu.sortShipsByClassAndPurposeReverse)

	for _, data in ipairs(sortedShips) do
		table.sort(data.ships, Helper.sortName)
		for _, ship in ipairs(data.ships) do
			table.insert(shipOptions, { id = tostring(ship.shipid), text = "\27[" .. data.icon .. "] " .. GetComponentData(ship.shipid, "name") .. " (" .. ffi.string(C.GetObjectIDCode(ConvertIDTo64Bit(ship.shipid))) .. ")", icon = "", displayremoveoption = false })
		end
	end

	local text = {
		alignment = "center",
		fontname = Helper.headerRow1Font,
		fontsize = Helper.headerRow1FontSize,
		color = Helper.color.green,
		x = 0,
		y = 0,
		override = ""
	}

	local maxnamewidth = columnwidth_sliderright + columnwidth_selloffer + columnwidth_buyoffer + 2 * Helper.borderSize + (Helper.scrollbarWidth - widthcorrection) - (2 * Helper.scaleY(Helper.headerRow1Height))
	setup:addSimpleRow({
		Helper.createDropDown(shipOptions, curShipOption, text, nil, false, true, 0, 0, 0, Helper.headerRow1Height, nil, nil, "", 0, false),
		Helper.createFontString(name, true, "center", color.r, color.g, color.b, color.a, Helper.headerRow1Font, Helper.scaleFont(Helper.headerRow1Font, Helper.headerRow1FontSize), false, Helper.scaleX(Helper.headerRow1Offsetx), Helper.scaleY(Helper.headerRow1Offsety), Helper.scaleY(Helper.headerRow1Height), maxnamewidth)
	}, nil, {4, 3}, false, Helper.defaultTitleBackgroundColor)

	if menu.contextMenuData.wareexchange then
		setup:addHeaderRow({
			ReadText(1001,45),
			Helper.createFontString(ReadText(1001, 5), false, "center"),	-- Ship
			menu.emptyFontStringSmall,
			Helper.createFontString(((C.IsComponentClass(menu.contextMenuData.component, "ship") and ReadText(1001, 5)) or (C.IsComponentClass(menu.contextMenuData.component, "station") and ReadText(1001, 3)) or ReadText(1001, 9426)), false, "center"),	-- Ship, Station, Build
			Helper.emptyFontStringSmall
		}, nil, {2, 1, 2, 1, 1}, false, Helper.color.transparent)
	else
		setup:addHeaderRow({
			ReadText(1001,45),
			Helper.createFontString(ReadText(1001,2808), false, "center"),
			Helper.createFontString(ReadText(1001,5), false, "center"),
			menu.emptyFontStringSmall,
			Helper.createFontString(ReadText(1001,8308), false, "center"),
			Helper.createFontString(ReadText(1001,8309), false, "center"),
		}, nil, {1, 1, 1, 2, 1, 1}, false, Helper.color.transparent)
	end

	-- separator line, height=1
	setup:addHeaderRow({
		Helper.createFontString("", true, nil, nil, nil, nil, nil, nil, nil, false, 0, 0, 1, 1)
	}, nil, {7}, false, Helper.color.grey)

	local warningcontent = {}
	local warningcolor = Helper.color.red

	if #menu.contextMenuData.waredatalist == 0 then
		setup:addSimpleRow({
			menu.contextMenuData.wareexchange and ReadText(1001,8310) or ReadText(1001,8311)
		}, nil, {7}, false, Helper.color.transparent)
	else
		for i, waredata in ipairs(menu.contextMenuData.waredatalist) do
			local content = menu.getTradeContextRowContent(waredata)

			if not menu.selectedTradeWare then
				menu.selectedTradeWare = waredata.ware
			end
			if waredata.ware == menu.selectedTradeWare then
				warningcontent = content[8]
				if waredata.ware == menu.showOptionalWarningWare then
					if content[4].scale.start == content[4].scale.maxselect then
						warningcontent = content[9]
						warningcolor = Helper.color.warningorange
					elseif content[4].scale.start == content[4].scale.minselect then
						warningcontent = content[10]
						warningcolor = Helper.color.warningorange
					else
						menu.showOptionalWarningWare = nil
					end
				end
			end

			if not menu.selectedRows.contextshiptable then
				if (waredata.sell and IsSameTrade(waredata.sell.id, menu.contextMenuData.tradeid)) or (waredata.buy and IsSameTrade(waredata.buy.id, menu.contextMenuData.tradeid)) then
					menu.topRows.contextshiptable = math.min(3 + i, 3 + #menu.contextMenuData.waredatalist - (menu.tradeContext.warescrollwindowsize - 1))
					menu.selectedRows.contextshiptable = 3 + i
				end
			end
			if menu.contextMenuData.wareexchange then
				setup:addSimpleRow({
					Helper.createFontString(content[1].text, true, "left", content[1].color.r, content[1].color.g, content[1].color.b, content[1].color.a, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth)),
					Helper.createFontString(content[3].text, true, "right", content[3].color.r, content[3].color.g, content[3].color.b, content[3].color.a,	Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth)),
					Helper.createSliderCell(Helper.createTextInfo("", "left", Helper.standardFont, Helper.standardFontSize, content[4].color.r, content[4].color.g, content[4].color.b, content[4].color.a, Helper.standardTextOffsetx, Helper.standardTextOffsety), false, 0, 0, 0, Helper.standardTextHeight, nil, Helper.defaultSliderCellValueColor, content[4].scale),
					Helper.createFontString(content[6].text, true, "right", content[6].color.r, content[6].color.g, content[6].color.b, content[6].color.a, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth)),
					menu.emptyFontStringSmall,
				}, waredata.ware, {2, 1, 2, 1, 1}, false, Helper.color.transparent)
			else
				setup:addSimpleRow({
					Helper.createFontString(content[1].text, true, "left", content[1].color.r, content[1].color.g, content[1].color.b, content[1].color.a, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth), content[1].mouseover),
					Helper.createFontString(content[2].text, true, "right", content[2].color.r, content[2].color.g, content[2].color.b, content[2].color.a, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth), content[2].mouseover),
					Helper.createFontString(content[3].text, true, "right", content[3].color.r, content[3].color.g, content[3].color.b, content[3].color.a,	Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth)),
					Helper.createSliderCell(Helper.createTextInfo("", "left", Helper.standardFont, Helper.standardFontSize, content[4].color.r, content[4].color.g, content[4].color.b, content[4].color.a, Helper.standardTextOffsetx, Helper.standardTextOffsety), false, 0, 0, 0, Helper.standardTextHeight, nil, nil, content[4].scale),
					Helper.createFontString(content[6].text, true, "right", content[6].color.r, content[6].color.g, content[6].color.b, content[6].color.a, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth)),
					Helper.createFontString(content[7].text, true, "right", content[7].color.r, content[7].color.g, content[7].color.b, content[7].color.a, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), false, Helper.scaleX(Helper.standardTextOffsetx), Helper.scaleY(Helper.standardTextOffsety), Helper.scaleY(Helper.standardTextHeight), Helper.scaleX(Helper.standardTextWidth)),
				}, waredata.ware, {1, 1, 1, 2, 1, 1}, false, Helper.color.transparent)
			end
		end
	end

	local shipdesc = setup:createCustomWidthTable(
		{
			columnwidth_ware,
			columnwidth_price,
			columnwidth_shipstorage,
			columnwidth_sliderleft,
			columnwidth_sliderright,
			columnwidth_selloffer,
			columnwidth_buyoffer
		},
		false, true, true, 2, 3, xoffset, yoffset, menu.tradeContext.shipheight, false, menu.topRows.contextshiptable, menu.selectedRows.contextshiptable, nil)
	menu.topRows.contextshiptable = nil
	menu.selectedRows.contextshiptable = nil

	-- info and buttons
	setup = Helper.createTableSetup(menu)

	-- the button table is split into left and right side below the "zero" position of the sliders
	local columnwidth_bottomleft		= columnwidth_ware + columnwidth_price + columnwidth_shipstorage + columnwidth_sliderleft + 3 * Helper.borderSize
	local columnwidth_bottomright		= columnwidth_sliderright + columnwidth_selloffer + columnwidth_buyoffer + 2 * Helper.borderSize + (Helper.scrollbarWidth - widthcorrection)
	-- trade menu case:
	-- split bottom right twice: Once into 2/3 + 1/3 for money output, and 1/2 + 1/2 for the buttons
	-- A-----------------------------------------B------------C----D--------E
	-- | Ship storage details  (bottomleft)      | Profits:        | 100 Cr |
	-- +-----------------------------------------+------------+----+--------+
	-- |                                         | LeftButton | RightButton |
	-- +-----------------------------------------+------------+----+--------+
	local columnwidth_br_leftoutput		= math.floor((columnwidth_bottomright - Helper.borderSize) * 2 / 3)			-- BD
	local columnwidth_br_rightoutput	= columnwidth_bottomright - columnwidth_br_leftoutput - Helper.borderSize	-- DE
	local columnwidth_br_leftbutton		= math.floor((columnwidth_bottomright - Helper.borderSize) / 2)				-- BC
	local columnwidth_br_rightbutton	= columnwidth_bottomright - columnwidth_br_leftbutton - Helper.borderSize	-- CE
	local columnwidth_br_bottomoverlap	= columnwidth_bottomright - columnwidth_br_leftbutton - columnwidth_br_rightoutput - 2 * Helper.borderSize			-- CD
	-- ware exchange menu case:
	-- "zero" position is in the center. Split bottom right twice, so that each button occupies ca. 20% of the width (40% together)
	-- A-----------------------------------B-----C------------D-------------E
	-- | Ship storage details (bottomleft) | Other ship storage details     |
	-- +-----------------------------------+-----+------------+-------------+
	-- |                                         | LeftButton | RightButton |
	-- +-----------------------------------+-----+------------+-------------+
	local columnwidth_wx_br_leftbutton	= math.floor((columnwidth_bottomright - 2 * Helper.borderSize) * 2 / 5)		-- CD
	local columnwidth_wx_br_rightbutton	= columnwidth_wx_br_leftbutton												-- DE
	local columnwidth_wx_br_leftspacing	= columnwidth_bottomright - columnwidth_wx_br_leftbutton - columnwidth_wx_br_rightbutton - 2 * Helper.borderSize	-- BC

	-- separator line, height=1
	setup:addHeaderRow({
		Helper.createFontString("", true, nil, nil, nil, nil, nil, nil, nil, false, 0, 0, 1, 1)
	}, nil, {4}, false, Helper.color.grey)

	-- fill info cells before writing to table
	local infocells = {}
	local infocells2 = {}
	for i = 1, menu.tradeContext.numinforows do
		infocells[i] = { menu.emptyFontStringSmall, menu.emptyFontStringSmall, menu.emptyFontStringSmall }
	end
	for i = 1, menu.tradeContext.numwarningrows do
		infocells2[i] = { menu.emptyFontStringSmall, menu.emptyFontStringSmall, menu.emptyFontStringSmall }
	end

	-- storage details
	local storagecontent = menu.getTradeContextShipStorageContent()
	local storageheader = #storagecontent > 0 and ReadText(1001,8312) or ReadText(1001,8313)
	for i, content in ipairs(storagecontent) do
		if i <= menu.tradeContext.numinforows then
			infocells[i][1] = Helper.createSliderCell(Helper.createTextInfo(content.name, "left", Helper.standardFont, Helper.standardFontSize, content.color.r, content.color.g, content.color.b, content.color.a, Helper.standardTextOffsetx, Helper.standardTextOffsety), false, 0, 0, 0, Helper.standardTextHeight, nil, Helper.defaultSliderCellBackgroundColor, content.scale)
		end
	end

	-- warnings
	local i = 0
	for _, content in pairs(warningcontent) do
		i = i + 1
		if i <= menu.tradeContext.numwarningrows then
			infocells2[i][1] = Helper.createFontString(content, false, "left", warningcolor.r, warningcolor.g, warningcolor.b, warningcolor.a)
		end
	end

	local buttondesc
	local confirmbuttonactive = false
	for _, amount in pairs(menu.contextMenuData.orders) do
		if amount ~= 0 then
			confirmbuttonactive = true
			break
		end
	end

	if menu.contextMenuData.wareexchange then
		local otherstoragecontent = menu.getTradeContextShipStorageContent(true)
		local otherstorageheader = #otherstoragecontent > 0 and 
			(
				(C.IsComponentClass(menu.contextMenuData.component, "ship") and ReadText(1001,8312)) 
				or (C.IsComponentClass(menu.contextMenuData.component, "station") and ReadText(1001,8314)) 
				or ReadText(1001,8316)
			) 
			or (
				(C.IsComponentClass(menu.contextMenuData.component, "ship") and ReadText(1001,8313)) 
				or (C.IsComponentClass(menu.contextMenuData.component, "station") and ReadText(1001,8315)) 
				or ReadText(1001,8317)
			)

		-- add info cells to table
		setup:addHeaderRow({
			Helper.createFontString(storageheader, false, "center"),
			Helper.createFontString(otherstorageheader, false, "center"),
		}, nil, {1, 3}, false, Helper.color.transparent)

		for i = 1, menu.tradeContext.numinforows do
			local content = otherstoragecontent[i]
			if content then
				infocells[i][2] = Helper.createSliderCell(Helper.createTextInfo(content.name, "left", Helper.standardFont, Helper.standardFontSize, content.color.r, content.color.g, content.color.b, content.color.a, Helper.standardTextOffsetx, Helper.standardTextOffsety), false, 0, 0, 0, Helper.standardTextHeight, nil, Helper.defaultSliderCellBackgroundColor, content.scale)
			end
			-- ignore [i][3]
			setup:addHeaderRow({ infocells[i][1], infocells[i][2] }, nil, {1, 3}, false, Helper.color.transparent)
		end

		setup:addHeaderRow({
			Helper.createFontString(next(warningcontent) and ReadText(1001, 8342) or "", false, "center")
		}, nil, {1, 3}, false, Helper.color.transparent)

		for i = 1, menu.tradeContext.numwarningrows do
			if i == menu.tradeContext.numwarningrows then
				setup:addSimpleRow({
					infocells2[i][1],
					menu.emptyFontStringSmall,
					Helper.createButton(Helper.createTextInfo(ReadText(1001, 2821), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, confirmbuttonactive, 0, 0, 0, Helper.standardTextHeight),
					Helper.createButton(Helper.createTextInfo(ReadText(1001, 64), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 0, Helper.standardTextHeight)
				}, nil, {1, 1, 1, 1}, false, Helper.color.transparent)
			else
				setup:addHeaderRow({ infocells2[i][1] }, nil, {1, 3}, false, Helper.color.transparent)
			end
		end

		buttondesc = setup:createCustomWidthTable(
			{
				columnwidth_bottomleft,
				columnwidth_wx_br_leftspacing,
				columnwidth_wx_br_leftbutton,
				columnwidth_wx_br_rightbutton,
			},
			false, true, true, 3, menu.tradeContext.numinforows + menu.tradeContext.numwarningrows + 3, xoffset, yoffset + menu.tradeContext.shipheight + 1 * Helper.borderSize, menu.tradeContext.buttonheight, false, nil, nil, nil)
	else
		-- profits from sales
		local profit = menu.contextMenuData.referenceprofit
		local profitcolor = Helper.color.white
		if profit < 0 then
			profitcolor = Helper.color.red
		elseif profit > 0 then
			profitcolor = Helper.color.green
		end
		infocells[#infocells - 1][2] = ReadText(1001,8305) .. ReadText(1001, 120)
		infocells[#infocells - 1][3] = Helper.createFontString(ConvertMoneyString(profit, false, true, nil, true) .. " " .. ReadText(1001, 101), false, "right", profitcolor.r, profitcolor.g, profitcolor.b, profitcolor.a)

		-- transaction value
		local total = menu.contextMenuData.totalbuyprofit - menu.contextMenuData.totalsellcost
		local transactioncolor = Helper.color.white
		if total < 0 then
			transactioncolor = Helper.color.red
		elseif total > 0 then
			transactioncolor = Helper.color.green
		end
		infocells[#infocells][2] = ReadText(1001, 2005) .. ReadText(1001, 120) -- Transaction value, :
		infocells[#infocells][3] = Helper.createFontString(ConvertMoneyString(total, false, true, nil, true) .. " " .. ReadText(1001, 101), false, "right", transactioncolor.r, transactioncolor.g, transactioncolor.b, transactioncolor.a)

		-- add info cells to table
		setup:addHeaderRow({
			Helper.createFontString(storageheader, false, "center"),
			Helper.createFontString(ReadText(1001, 2006), false, "center"),	-- Transaction details
		}, nil, {1, 3}, false, Helper.color.transparent)

		for i = 1, menu.tradeContext.numinforows do
			setup:addHeaderRow(infocells[i], nil, {1, 2, 1}, false, Helper.color.transparent)
		end

		setup:addHeaderRow({
			Helper.createFontString(next(warningcontent) and ReadText(1001, 8342) or "", false, "center")
		}, nil, {1, 3}, false, Helper.color.transparent)

		for i = 1, menu.tradeContext.numwarningrows do
			if i == menu.tradeContext.numwarningrows then				
				-- if no tradeoffers, Confirm -> DockToTrade
				if not GetComponentData(menu.contextMenuData.component, "tradesubscription") then
					setup:addSimpleRow({
						infocells2[i][1],
						Helper.createButton(Helper.createTextInfo(ReadText(1001, 7858), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, (menu.contextMenuData.currentShip ~= 0) and C.IsOrderSelectableFor("Player_DockToTrade", menu.contextMenuData.currentShip), 0, 0, 0, Helper.standardTextHeight),
						Helper.createButton(Helper.createTextInfo(ReadText(1001, 64), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 0, Helper.standardTextHeight)
					}, nil, {1, 1, 2}, false, Helper.color.transparent)
				else
					setup:addSimpleRow({
						infocells2[i][1],
						Helper.createButton(Helper.createTextInfo(ReadText(1001, 2821), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, confirmbuttonactive, 0, 0, 0, Helper.standardTextHeight),
						Helper.createButton(Helper.createTextInfo(ReadText(1001, 64), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 0, Helper.standardTextHeight)
					}, nil, {1, 1, 2}, false, Helper.color.transparent)
				end
			else
				setup:addHeaderRow({ infocells2[i][1] }, nil, {1, 3}, false, Helper.color.transparent)
			end
		end

		buttondesc = setup:createCustomWidthTable(
			{
				columnwidth_bottomleft,
				columnwidth_br_leftbutton,
				columnwidth_br_bottomoverlap,
				columnwidth_br_rightoutput,
			},
			false, true, true, 3, menu.tradeContext.numinforows + menu.tradeContext.numwarningrows + 3, xoffset, yoffset + menu.tradeContext.shipheight + 1 * Helper.borderSize, menu.tradeContext.buttonheight, false, nil, nil, nil)
	end

	Helper.displayFrame(menu, {shipdesc, buttondesc}, false, "solid", "", { close = true }, nil, config.contextFrameLayer, Helper.color.semitransparent, nil, true, nil, true, nil, frameData.width, frameData.height, frameData.x, frameData.y)
end

function menu.setupTradeContextScripts(shiptable, buttontable)
	-- ship
	local nooflines = 1
	Helper.setDropDownScript(menu, nil, shiptable, nooflines, 1, nil, menu.dropdownShip)

	nooflines = nooflines + 3

	if #menu.contextMenuData.waredatalist == 0 then
		nooflines = nooflines + 1
	else
		for _, waredata in ipairs(menu.contextMenuData.waredatalist) do
			local callback = menu.getAmmoTypeNameByWare(waredata.ware) and menu.slidercellShipAmmo or menu.slidercellShipCargo
			if waredata.active then
				Helper.setSliderCellScript(menu, nil, shiptable, nooflines, 4, function (_, value) return callback(waredata.sell and waredata.sell.id, waredata.buy and waredata.buy.id, waredata.ware, 0, value) end, nil, nil, nil, function () return menu.slidercellTradeConfirmed(waredata.ware) end)
			end
			nooflines = nooflines + 1
		end
	end

	-- buttons
	nooflines = menu.tradeContext.numinforows + menu.tradeContext.numwarningrows + 3
	if not menu.contextMenuData.wareexchange and (#menu.contextMenuData.waredatalist == 0) then
		Helper.setButtonScript(menu, nil, buttontable, nooflines, 2, menu.buttonDockToTrade)
	else
		Helper.setButtonScript(menu, "confirmtrade", buttontable, nooflines, menu.contextMenuData.wareexchange and 3 or 2, menu.buttonConfirmTrade)
	end
	Helper.setButtonScript(menu, "canceltrade", buttontable, nooflines, menu.contextMenuData.wareexchange and 4 or 3, menu.buttonCancelTrade)
	nooflines = nooflines + 1
end

function menu.initializeBoardingData(target)
	menu.boardingData = { 
							target = target, ships = {}, shipdata = {}, selectedship = nil,
							marinelevels = {}, casualties = {0, 0, 0},
							currentphase = "setup", phaseindices = {}, phasedata = {}, progresslevels = {},
							risk1 = nil, risk2 = nil, risklevels = {}, riskleveldata = {},
							shipactions = {},
							changed = false, iscapturable = GetComponentData(target, "iscapturable")
						}
	local numtiers = C.GetNumTiersOfRole("marine")
	local tierdata = ffi.new("RoleTierData[?]", numtiers)
	numtiers = C.GetTiersOfRole(tierdata, numtiers, "marine")
	for i = 0, numtiers - 1 do
		table.insert(menu.boardingData.marinelevels, { skilllevel = tierdata[i].skilllevel, text = ffi.string(tierdata[i].name) })
	end

	local numphases = C.GetNumAllBoardingPhases()
	local phases = ffi.new("BoardingPhase[?]", numphases)
	numphases = C.GetAllBoardingPhases(phases, numphases)
	for i = 0, numphases-1 do
		if ffi.string(phases[i].id) ~= "" then
			local phaseid = ffi.string(phases[i].id)
			menu.boardingData.phaseindices[phaseid] = (i+1)
			if phaseid == "approach" or phaseid == "infiltration" or phaseid == "internalfight" then
				table.insert(menu.boardingData.phasedata, { text = ffi.string(phases[i].text), state = "waiting", mouseOverText = "" })
			end
		end
	end
	menu.boardingData.phasedata[1].mouseOverText = ReadText(1026, 8201)		-- Destroy turrets to improve chances of boarding pods arriving safely.
	menu.boardingData.phasedata[2].mouseOverText = ReadText(1026, 8202)		-- Damage hull to reduce the time needed to breach the target.
	menu.boardingData.phasedata[3].mouseOverText = ReadText(1026, 8203)		-- Send more or better marines to improve chances of success.

	menu.boardingData.progresslevels = { waiting = {text = ReadText(1001, 9510), color = Helper.color.red}, started = {text = ReadText(1001, 9511), color = Helper.color.orange}, done = {text = ReadText(1001, 9512), color = Helper.color.green} }		-- Stage not started, Stage in progress, Stage completed

	menu.boardingData.risklevels = { "verylow", "low", "medium", "high", "veryhigh" }
	menu.boardingData.riskleveldata = { verylow = { index = 1, text = ReadText(1037, 3001), textlower = ReadText(1037, 4001), threshold = 20, hulldescription = ReadText(1037, 5001), color = Helper.color.green }, low = { index = 2, text = ReadText(1037, 3002), textlower = ReadText(1037, 4002), threshold = 30, hulldescription = ReadText(1037, 5002), color = Helper.color.yellow }, medium = { index = 3, text = ReadText(1037, 3003), textlower = ReadText(1037, 4003), threshold = 50, hulldescription = ReadText(1037, 5003), color = Helper.color.orange }, high = { index = 4, text = ReadText(1037, 3004), textlower = ReadText(1037, 4004), threshold = 80, hulldescription = ReadText(1037, 5004), color = Helper.color.red }, veryhigh = { index = 5, text = ReadText(1037, 3005), textlower = ReadText(1037, 4005), threshold = 100, hulldescription = ReadText(1037, 5005), color = Helper.color.red }, impossible = { index = 6, text = ReadText(1037, 3006), textlower = ReadText(1037, 4006), threshold = 120, hulldescription = ReadText(1037, 5005), color = Helper.color.red } }
	if not menu.boardingData.risk1 then
		-- Approach risk threshold. default: low
		menu.boardingData.risk1 = menu.boardingData.risklevels[2]
	end
	if not menu.boardingData.risk2 then
		-- Infiltrate risk threshold. default: high (marines don't die while drilling through anymore, but it does increase risk for them in the assault phase since defenders have more time to organize.)
		menu.boardingData.risk2 = menu.boardingData.risklevels[4]
	end

	local numactions = C.GetNumAllBoardingBehaviours()
	local actions = ffi.new("BoardingBehaviour[?]", numactions)
	numactions = C.GetAllBoardingBehaviours(actions, numactions)
	for i = 0, numactions-1 do
		if ffi.string(actions[i].id) ~= "" then
			table.insert(menu.boardingData.shipactions, { id = ffi.string(actions[i].id), text = ffi.string(actions[i].text) })
		end
	end
end

function menu.createBoardingContext(frame, target, boarders)
	if not menu.boardingData or not menu.boardingData.target then
		menu.initializeBoardingData(target)
	end

	local activeop = C.IsDefensibleBeingBoardedBy(target, "player")
	local unknowntext = ReadText(1001, 3210)
	local unknowncolor = Helper.color.red
	local boardingcheatsecrecy = false

	-- if op is already running, add all ships that are already assigned to the boarding operation.
	if activeop then
		-- get risk thresholds
		local rawriskthresholds = ffi.new("BoardingRiskThresholds")
		rawriskthresholds = C.GetBoardingRiskThresholds(target, "player")
		--print("rawrisk1: " .. tostring(rawriskthresholds[0]) .. ", rawrisk2: " .. tostring(rawriskthresholds[1]))
		local found1, found2 = nil
		for _, risklevel in ipairs(menu.boardingData.risklevels) do
			if not found1 and rawriskthresholds.approach <= menu.boardingData.riskleveldata[risklevel].threshold then
				menu.boardingData.risk1 = risklevel
				found1 = true
			end
			if not found2 and rawriskthresholds.insertion <= menu.boardingData.riskleveldata[risklevel].threshold then
				menu.boardingData.risk2 = risklevel
				found2 = true
			end
			if found1 and found2 then
				break
			end
		end
		--print("retrieved risk levels. approach: " .. tostring(menu.boardingData.riskleveldata[menu.boardingData.risk1].text) .. ", insertion: " .. tostring(menu.boardingData.riskleveldata[menu.boardingData.risk2].text))

		local numattackers = C.GetNumAttackersOfBoardingOperation(target, "player")
		local attackers = ffi.new("UniverseID[?]", numattackers)
		numattackers = C.GetAttackersOfBoardingOperation(attackers, numattackers, target, "player")
		--print("num attackers: " .. tostring(numattackers) .. ". attackers: ")
		for i = 0, numattackers-1 do
			local boarder = ConvertStringTo64Bit(tostring(attackers[i]))
			--print(" " .. ffi.string(C.GetComponentName(boarder)))

			if not menu.boardingData.shipdata[boarder] then
				table.insert(menu.boardingData.ships, boarder)
				menu.boardingData.shipdata[boarder] = { assignedmarines = {}, marines = {}, assignedgroupmarines = {}, groupmarines = {}, subordinates = {}, isprimaryboarder = true, issubordinate = false, action = ffi.string(C.GetBoardingActionOfAttacker(target, boarder, "player")) }

				-- only update assignedmarines if shipdata is to be reset.
				local numtiers = #menu.boardingData.marinelevels
				local marinetieramounts = ffi.new("uint32_t[?]", numtiers)
				local marineskilllevellist = ffi.new("uint32_t[?]", numtiers)
				for j, leveldata in ipairs(menu.boardingData.marinelevels) do
					marineskilllevellist[j-1] = leveldata.skilllevel
				end
				C.GetBoardingMarineTierAmountsFromAttacker(marinetieramounts, marineskilllevellist, numtiers, target, boarder, "player")
				for j, leveldata in ipairs(menu.boardingData.marinelevels) do
					menu.boardingData.shipdata[boarder].assignedmarines[leveldata.skilllevel] = marinetieramounts[j-1]
					menu.boardingData.shipdata[boarder].assignedgroupmarines[leveldata.skilllevel] = marinetieramounts[j-1]
					--print("retrieving. index: " .. tostring(j-1) .. ", num marines: " .. tostring(marinetieramounts[j-1]) .. ", skill level: " .. tostring(leveldata.skilllevel))
				end
			end
		end
	end

	-- add all boarders that were passed in and are not yet listed to menu.boardingData.ships and initialize menu.boardingData.shipdata for them.
	for _, ship in ipairs(boarders) do
		if not menu.boardingData.shipdata[ship] then
			--print("adding " .. ffi.string(C.GetComponentName(ship)) .. " to boarding operation.")
			table.insert(menu.boardingData.ships, ship)
			menu.boardingData.shipdata[ship] = { assignedmarines = {}, marines = {}, assignedgroupmarines = {}, groupmarines = {}, subordinates = {}, isprimaryboarder = true, issubordinate = false, action = menu.boardingData.shipactions[2].id }
		end
	end

	-- populate marine and subordinate data for menu.boardingData.ships in menu.boardingData.shipdata
	for _, ship in ipairs(menu.boardingData.ships) do
		local numpeople = C.GetNumAllRoles()
		local peopledata = ffi.new("PeopleInfo[?]", numpeople)
		numpeople = C.GetPeople(peopledata, numpeople, ship)
		local numtiers = #menu.boardingData.marinelevels
		local tierdata = ffi.new("RoleTierData[?]", numtiers)
		numtiers = C.GetRoleTiers(tierdata, numtiers, ship, "marine")
		for i = 0, numtiers - 1 do
			menu.boardingData.shipdata[ship].marines[tierdata[i].skilllevel] = tierdata[i].amount
			menu.boardingData.shipdata[ship].groupmarines[tierdata[i].skilllevel] = tierdata[i].amount
		end

		local subordinates = GetSubordinates(ship, nil, true)
		--print("found " .. tostring(#subordinates) .. " subordinates")
		for _, subordinate in ipairs(subordinates) do
			local subordinate = ConvertIDTo64Bit(subordinate)
			if not C.IsUnit(subordinate) then
				if not menu.boardingData.shipdata[subordinate] then
					menu.boardingData.shipdata[subordinate] = { assignedmarines = {}, marines = {}, assignedgroupmarines = {}, groupmarines = {}, subordinates = {}, isprimaryboarder = false, issubordinate = true, action = menu.boardingData.shipactions[2].id }

					local alreadylisted = false
					for _, evalsubordinate in ipairs(menu.boardingData.shipdata[ship].subordinates) do
						if subordinate == evalsubordinate then
							alreadylisted = true
							break
						end
					end
					if not alreadylisted then
						--print("adding subordinate " .. ffi.string(C.GetComponentName(subordinate)) .. " to boarding operation.")
						table.insert(menu.boardingData.shipdata[ship].subordinates, subordinate)
					end
				else
					menu.boardingData.shipdata[subordinate].issubordinate = true
				end

				if not menu.boardingData.shipdata[subordinate].isprimaryboarder then
					numpeople = C.GetNumAllRoles()
					peopledata = ffi.new("PeopleInfo[?]", numpeople)
					numpeople = C.GetPeople(peopledata, numpeople, subordinate)
					numtiers = #menu.boardingData.marinelevels
					tierdata = ffi.new("RoleTierData[?]", numtiers)
					numtiers = C.GetRoleTiers(tierdata, numtiers, subordinate, "marine")
					for i = 0, numtiers - 1 do
						if tierdata[i].amount > 0 then
							--print("subordinate: " .. ffi.string(C.GetComponentName(subordinate)) .. ": adding " .. tierdata[i].amount .. " marines with skill " .. tostring(tierdata[i].skilllevel) .. " to entry of " .. ffi.string(C.GetComponentName(ship)))
							menu.boardingData.shipdata[subordinate].marines[tierdata[i].skilllevel] = tierdata[i].amount
							menu.boardingData.shipdata[subordinate].groupmarines[tierdata[i].skilllevel] = tierdata[i].amount
							menu.boardingData.shipdata[ship].groupmarines[tierdata[i].skilllevel] = menu.boardingData.shipdata[ship].groupmarines[tierdata[i].skilllevel] + tierdata[i].amount
						end
					end
				end

				for _, tierdata in ipairs(menu.boardingData.marinelevels) do
					if not menu.boardingData.shipdata[subordinate].assignedmarines[tierdata.skilllevel] then
						menu.boardingData.shipdata[subordinate].assignedmarines[tierdata.skilllevel] = 0
					end
					if not menu.boardingData.shipdata[subordinate].assignedgroupmarines[tierdata.skilllevel] then
						menu.boardingData.shipdata[subordinate].assignedgroupmarines[tierdata.skilllevel] = 0
					end
				end
			end
		end
		for _, tierdata in ipairs(menu.boardingData.marinelevels) do
			if not menu.boardingData.shipdata[ship].assignedmarines[tierdata.skilllevel] then
				menu.boardingData.shipdata[ship].assignedmarines[tierdata.skilllevel] = 0
			end
			if not menu.boardingData.shipdata[ship].assignedgroupmarines[tierdata.skilllevel] then
				menu.boardingData.shipdata[ship].assignedgroupmarines[tierdata.skilllevel] = 0
			end
		end
	end

	local targetname, targetowner, hullpercentage = GetComponentData(target, "name", "ownername", "hullpercent")

	local numoperationalturrets = 0
	local numtotalturrets = 0
	local numpotentialturrets = 0
	local numslots = tonumber(C.GetNumUpgradeSlots(target, "", "turret"))
	for i = 1, numslots do
		numpotentialturrets = numpotentialturrets + 1
		local currentcomponent = ConvertStringTo64Bit(tostring(C.GetUpgradeSlotCurrentComponent(target, "turret", i)))
		if currentcomponent and currentcomponent ~= 0 then
			numtotalturrets = numtotalturrets + 1
			if IsComponentOperational(currentcomponent) then
				numoperationalturrets = numoperationalturrets + 1
			end
		end
	end

	local targetcrewcapacity = C.GetPeopleCapacity(target, "", false)

	local currentboardingresistance = GetComponentData(target, "boardingresistance")
	local numdefendingcrew = menu.getNumDefendingCrew(target)

	-- tally total assigned marines and fill in empty marine tier entries.
	local totalassignedmarines = 0
	for _, boarder in ipairs(menu.boardingData.ships) do
		for _, tierdata in ipairs(menu.boardingData.marinelevels) do
			if not menu.boardingData.shipdata[boarder].assignedmarines[tierdata.skilllevel] then
				menu.boardingData.shipdata[boarder].assignedmarines[tierdata.skilllevel] = 0
			end
			if not menu.boardingData.shipdata[boarder].assignedgroupmarines[tierdata.skilllevel] then
				menu.boardingData.shipdata[boarder].assignedgroupmarines[tierdata.skilllevel] = 0
			end
			totalassignedmarines = totalassignedmarines + menu.boardingData.shipdata[boarder].assignedgroupmarines[tierdata.skilllevel]
			--print("assigned marines: adding " .. menu.boardingData.shipdata[boarder].assignedgroupmarines[tierdata.skilllevel] .. " " .. tostring(tierdata.text) .. " marines from " .. ffi.string(C.GetComponentName(boarder)) .. " " .. tostring(boarder) .. " to total tally.\n total: " .. tostring(totalassignedmarines))
		end
	end

	if not menu.boardingData.selectedship or not menu.boardingData.shipdata[menu.boardingData.selectedship] then
		menu.boardingData.selectedship = menu.boardingData.ships[1]
	end

	local boardingstrength = 0
	for i, ship in ipairs(menu.boardingData.ships) do
		local locnumtiers = #menu.boardingData.marinelevels
		local locmarinetieramounts = ffi.new("uint32_t[?]", locnumtiers)
		local locmarineskilllevels = ffi.new("uint32_t[?]", locnumtiers)
		for j, level in ipairs(menu.boardingData.marinelevels) do
			locmarinetieramounts[j-1] = menu.boardingData.shipdata[ship].assignedmarines[level.skilllevel]
			locmarineskilllevels[j-1] = level.skilllevel
			--print("tier: " .. j .. " num tiers: " .. locnumtiers .. " tier amount: " .. tostring(menu.boardingData.shipdata[ship].assignedmarines[level.skilllevel]) .. " skill level: " .. level.skilllevel)
		end
		boardingstrength = boardingstrength + C.GetBoardingStrengthOfControllableTierAmounts(ship, locmarinetieramounts, locmarineskilllevels, locnumtiers)
		if #menu.boardingData.shipdata[ship].subordinates > 0 then
			for _, subordinate in ipairs(menu.boardingData.shipdata[ship].subordinates) do
				for j, level in ipairs(menu.boardingData.marinelevels) do
					locmarinetieramounts[j-1] = menu.boardingData.shipdata[subordinate].assignedmarines[level.skilllevel]
					locmarineskilllevels[j-1] = level.skilllevel
					--print("subordinate. tier: " .. j .. " num tiers: " .. locnumtiers .. " tier amount: " .. tostring(menu.boardingData.shipdata[subordinate].assignedmarines[level.skilllevel]) .. " skill level: " .. level.skilllevel)
				end
				boardingstrength = boardingstrength + C.GetBoardingStrengthOfControllableTierAmounts(subordinate, locmarinetieramounts, locmarineskilllevels, locnumtiers)
			end
		end
		--print("calculating boarding strength. num ships evaluated: " .. i .. " boarding strength: " .. boardingstrength)
	end

	-- max potential boarding resistance: only for comparison with boardingstrength to be expressed as an adjective for crew strength estimate in stage III. always use potential? that would tend to make the approximation safer if very conservative.
	-- we're now using combinedskill to calculate boarding strength, so max potential is max number of crew * maxcombinedskill
	--local maxpotentialboardingresistance = targetcrewcapacity * 100
	local maxpotentialboardingresistance = numdefendingcrew * 100

	-- NB: risk numbers will be updated every time the text widgets that use them are.
	local risk = {}
	-- chance that launched marines will get to target compared to target ship type with maximum loadout
	table.insert(risk, ((numoperationalturrets / math.max(numtotalturrets, 1)) * 100))
	--table.insert(risk, ((numoperationalturrets / numpotentialturrets) * 100))
	-- chance that assaulting marines will survive entry
	table.insert(risk, hullpercentage)
	-- chance that attacking ships will accidentally destroy target
	table.insert(risk, 100 - risk[2])
	-- chance that assaulting marines will defeat opposition within the ship
	table.insert(risk, ((1.0 - math.min((boardingstrength / math.max(currentboardingresistance, 1.0)), 1.0)) * 100))
	--print("risk 1: " .. tostring(risk[1]) .. "\nrisk 2: " .. tostring(risk[2]) .. "\nrisk 3: " .. tostring(risk[3]))

	-- Boarding
	local table_header = frame:addTable(1, { x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })

	local row = table_header:addRow(false, { fixed = true })
	row[1]:createText(ReadText(1001, 9500), Helper.headerRowCenteredProperties)		-- Boarding

	-- Boarding Plan
	local table_bottom = frame:addTable(9, { tabOrder = 5, x = Helper.borderSize, y = menu.contextMenuData.height * 3 / 4 + Helper.borderSize, width = menu.contextMenuData.width, highlightMode = "column" })
	table_bottom:setColWidthPercent(2, 5)
	table_bottom:setColWidthPercent(3, 10)
	table_bottom:setColWidthPercent(5, 5)
	table_bottom:setColWidthPercent(6, 10)
	table_bottom:setColWidthPercent(8, 5)
	table_bottom:setColWidthPercent(9, 10)

	row = table_bottom:addRow(false, { fixed = true })
	row[1]:setColSpan(9):createText(ReadText(1001, 9501), Helper.headerRowCenteredProperties)		-- Boarding Plan

	row = table_bottom:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	for i, phase in ipairs(menu.boardingData.phasedata) do
		row[3*i-2]:setColSpan(3):createText(phase.text, { halign = "center", mouseOverText = phase.mouseOverText })
	end

	if activeop then
		row = table_bottom:addRow(false, { bgColor = Helper.color.transparent })

		for i, phase in ipairs(menu.boardingData.phasedata) do
			row[3*i-2]:createText((ReadText(1001, 9513) .. ReadText(1001, 120)), { mouseOverText = phase.mouseOverText })		-- Progress, :
			row[3*i-1]:setColSpan(2):createText(function()
					if C.IsDefensibleBeingBoardedBy(target, "player") then
						-- get current phase 
						menu.boardingData.currentphase = ffi.string(C.GetCurrentBoardingPhase(target, "player"))
					else
						-- this is for displaying the state of each phase so "succeeded" or "failed" doesn't really matter as long as its index is > that of all of the other phases.
						menu.boardingData.currentphase = "succeeded"
					end

					-- update phase data depending on current phase.
					if i == 1 then
						phase.state = (menu.boardingData.phaseindices[menu.boardingData.currentphase] > menu.boardingData.phaseindices.approach and "done") or "started"
					elseif i == 2 then
						phase.state = (menu.boardingData.phaseindices[menu.boardingData.currentphase] < menu.boardingData.phaseindices.pre_infiltration and "waiting") or (menu.boardingData.phaseindices[menu.boardingData.currentphase] < menu.boardingData.phaseindices.internalfight and "started") or "done"
					elseif i == 3 then
						phase.state = (menu.boardingData.phaseindices[menu.boardingData.currentphase] < menu.boardingData.phaseindices.internalfight and "waiting") or (menu.boardingData.phaseindices[menu.boardingData.currentphase] == menu.boardingData.phaseindices.internalfight and "started") or "done"
					end
					return menu.boardingData.progresslevels[phase.state].text
				end, { halign = "right", color = function() return menu.boardingData.progresslevels[phase.state].color end, mouseOverText = phase.mouseOverText })
		end
	end

	row = table_bottom:addRow(false, { bgColor = Helper.color.transparent })

	row[1]:setColSpan(2):createText((ReadText(1001, 9514) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[1].mouseOverText })		-- Risk, :
	row[3]:createText(function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and menu.boardingData.riskleveldata[menu.boardingData.risk1].text or unknowntext end, { halign = "right", mouseOverText = menu.boardingData.phasedata[1].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and menu.boardingData.riskleveldata[menu.boardingData.risk1].color or unknowncolor end })

	row[4]:setColSpan(2):createText((ReadText(1001, 9515) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[2].mouseOverText })		-- Risk of destroying target, :
	row[6]:createText(function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and menu.boardingData.riskleveldata[menu.boardingData.risklevels[6 - menu.boardingData.riskleveldata[menu.boardingData.risk2].index]].text or unknowntext end, { halign = "right", mouseOverText = menu.boardingData.phasedata[2].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and menu.boardingData.riskleveldata[menu.boardingData.risklevels[6 - menu.boardingData.riskleveldata[menu.boardingData.risk2].index]].color or unknowncolor end })

	row[7]:setColSpan(2):createText((ReadText(1001, 9516) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[3].mouseOverText })		-- Defending crew, :
	row[9]:createText(function() 
			local locnumdefendingcrew = menu.getNumDefendingCrew(target)
			return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and (locnumdefendingcrew .. " / " .. targetcrewcapacity) or unknowntext
		end, { halign = "right", mouseOverText = menu.boardingData.phasedata[3].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and Helper.standardColor or unknowncolor end })

	row = table_bottom:addRow(false, { bgColor = Helper.color.transparent })

	row[1]:setColSpan(2):createText((ReadText(1001, 9517) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 2, mouseOverText = menu.boardingData.phasedata[1].mouseOverText })		-- Target combat effectiveness, :
	row[3]:createText(function()
			local locnumoperationalturrets = menu.getNumOperationalTurrets(target, numtotalturrets)
			risk[1] = ((locnumoperationalturrets / math.max(numtotalturrets, 1)) * 100)
			local risktext = ""
			for i = 1, #menu.boardingData.risklevels do
				if risk[1] <= menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].threshold then
					risktext = menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].hulldescription
					break
				end
			end
			return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and risktext or unknowntext
		end, { halign = "right", mouseOverText = menu.boardingData.phasedata[1].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and Helper.standardColor or unknowncolor end })

	row[4]:setColSpan(2):createText((ReadText(1001, 9518) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[2].mouseOverText })		-- Risk to marines, :
	row[6]:createText(function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and menu.boardingData.riskleveldata[menu.boardingData.risklevels[menu.boardingData.riskleveldata[menu.boardingData.risk2].index]].text or unknowntext end, { halign = "right", mouseOverText = menu.boardingData.phasedata[2].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and menu.boardingData.riskleveldata[menu.boardingData.risklevels[menu.boardingData.riskleveldata[menu.boardingData.risk2].index]].color or unknowncolor end })

	--print("total assigned marines: " .. tostring(totalassignedmarines))
	row[7]:setColSpan(2):createText((ReadText(1001, 9519) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[3].mouseOverText })		-- Attacking marines, :
	row[9]:createText(function()
		local loctotalassignedmarines = 0
		for _, boarder in ipairs(menu.boardingData.ships) do
			for _, tierdata in ipairs(menu.boardingData.marinelevels) do
				if menu.boardingData.shipdata[boarder].assignedgroupmarines[tierdata.skilllevel] then
					loctotalassignedmarines = loctotalassignedmarines + menu.boardingData.shipdata[boarder].assignedgroupmarines[tierdata.skilllevel]
				end
			end
		end
		return loctotalassignedmarines .. " / " .. targetcrewcapacity end, { halign = "right", mouseOverText = menu.boardingData.phasedata[3].mouseOverText })

	row = table_bottom:addRow(false, { bgColor = Helper.color.transparent })

	row[1]:setColSpan(3):createText("", { mouseOverText = menu.boardingData.phasedata[1].mouseOverText })

	row[4]:setColSpan(2):createText((ReadText(1001, 9520) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 2, mouseOverText = menu.boardingData.phasedata[2].mouseOverText })		-- Target hull, :
	row[6]:createText(function()
			risk[2] = GetComponentData(target, "hullpercent")
			local hulldescription = ""
			for i = 1, #menu.boardingData.risklevels do
				if risk[2] <= menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].threshold then
					hulldescription = menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].hulldescription
					break
				end
			end
			return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and hulldescription or unknowntext
		end, { halign = "right", mouseOverText = menu.boardingData.phasedata[2].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and Helper.standardColor or unknowncolor end })

	row[7]:setColSpan(2):createText((ReadText(1001, 9514) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[3].mouseOverText })		-- Risk, :
	row[9]:createText(function()
			local risktext = ""
			local isimpossible = nil
			if menu.boardingData.iscapturable then
				local loccurrentboardingresistance = GetComponentData(target, "boardingresistance")
				risk[4] = ((2.0 - math.min((boardingstrength / math.max(loccurrentboardingresistance, 1.0)), 2.0)) * 100) / 2
				for i = 1, #menu.boardingData.risklevels do
					if risk[4] <= menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].threshold then
						--print("risk: " .. tostring(risk[4]) .. ". strength: " .. tostring(boardingstrength) .. ", resistance: " .. tostring(loccurrentboardingresistance) .. ", current threshold: " .. tostring(menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].threshold))
						risktext = menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].text
						break
					end
				end
			else
				risktext = menu.boardingData.riskleveldata.impossible.text
				isimpossible = true
			end
			return (boardingcheatsecrecy or isimpossible or C.IsInfoUnlockedForPlayer(target, "operator_details")) and risktext or unknowntext
		end, { halign = "right", mouseOverText = menu.boardingData.phasedata[3].mouseOverText, color = function() 
			local riskcolor = nil
			local isimpossible = nil
			if menu.boardingData.iscapturable then
				local loccurrentboardingresistance = GetComponentData(target, "boardingresistance")
				risk[4] = ((2.0 - math.min((boardingstrength / math.max(loccurrentboardingresistance, 1.0)), 2.0)) * 100) / 2
				for i = 1, #menu.boardingData.risklevels do 
					if risk[4] <= menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].threshold then
						riskcolor = menu.boardingData.riskleveldata[menu.boardingData.risklevels[i]].color
						break
					end
				end
			else
				riskcolor = menu.boardingData.riskleveldata.impossible.color
				isimpossible = true
			end
			return (boardingcheatsecrecy or isimpossible or C.IsInfoUnlockedForPlayer(target, "operator_details")) and riskcolor or unknowncolor
		end })

	row = table_bottom:addRow(false, { bgColor = Helper.color.transparent })

	row[1]:setColSpan(3):createText((ReadText(1001, 9521) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[1].mouseOverText })		-- Launch pods at combat effectiveness, :

	row[4]:setColSpan(3):createText((ReadText(1001, 9522) .. ReadText(1001, 120)), { mouseOverText = menu.boardingData.phasedata[2].mouseOverText })		-- Start breaching at hull strength, :

	row[7]:setColSpan(2):createText((ReadText(1001, 1325) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 2, mouseOverText = menu.boardingData.phasedata[3].mouseOverText })		-- Boarding Attack Strength, :
	row[9]:createText(boardingstrength, { halign = "right", mouseOverText = menu.boardingData.phasedata[3].mouseOverText })

	local dropdowndata = {}
	for _, levelid in ipairs(menu.boardingData.risklevels) do
		table.insert(dropdowndata, {id = levelid, text = menu.boardingData.riskleveldata[levelid].hulldescription, icon = "", displayremoveoption = false})
	end
	row = table_bottom:addRow(true, { bgColor = Helper.color.transparent })

	-- TODO: make dropdown being active dependent on current phase (certainly inactive after phase this applies to is done, but also while the phase is currently active?)
	row[1]:setColSpan(3):createDropDown(dropdowndata, {startOption = menu.boardingData.risk1, height = config.mapRowHeight, mouseOverText = menu.boardingData.phasedata[1].mouseOverText, active = not activeop})
	row[1].handlers.onDropDownConfirmed = function(_, newrisklevel) return menu.dropdownBoardingSetRisk(newrisklevel, 1) end
	row[4]:setColSpan(3):createDropDown(dropdowndata, {startOption = menu.boardingData.risk2, height = config.mapRowHeight, mouseOverText = menu.boardingData.phasedata[2].mouseOverText, active = not activeop})
	row[4].handlers.onDropDownConfirmed = function(_, newrisklevel) return menu.dropdownBoardingSetRisk(newrisklevel, 2) end

	row[7]:setColSpan(2):createText((ReadText(1001, 1324) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 2, mouseOverText = menu.boardingData.phasedata[3].mouseOverText })		-- Boarding Resistance, :
	row[9]:createText(function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and tostring(GetComponentData(target, "boardingresistance")) or unknowntext end, { halign = "right", mouseOverText = menu.boardingData.phasedata[3].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and Helper.standardColor or unknowncolor end })
	--[[
	row[7]:setColSpan(2):createText((ReadText(1001, 9523) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 2, mouseOverText = menu.boardingData.phasedata[3].mouseOverText })		-- Crew strength, :
	row[9]:createText(function()
			local loccurrentboardingresistance = GetComponentData(target, "boardingresistance")
			local targetcrewstrength = loccurrentboardingresistance / math.max(maxpotentialboardingresistance, 1.0)
			--print("crewstrength: " .. tostring(targetcrewstrength) .. ", currentboardingresistance: " .. tostring(currentboardingresistance) .. ", maxpotentialboardingresistance: " .. tostring(maxpotentialboardingresistance))
			local crewdescription = ""
			for i = 1, #menu.boardingData.risklevels do
				if targetcrewstrength <= menu.boardingData.riskleveldata[ menu.boardingData.risklevels[i] ].threshold then
					crewdescription = menu.boardingData.riskleveldata[ menu.boardingData.risklevels[i] ].text
					break
				end
			end
			return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and crewdescription or unknowntext
		end, { halign = "right", mouseOverText = menu.boardingData.phasedata[3].mouseOverText, color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and Helper.standardColor or unknowncolor end })
	--]]

	-- Ship Configuration
	local table_left = frame:addTable(2, { tabOrder = 4, x = Helper.borderSize, width = menu.contextMenuData.width / 2 - Helper.borderSize / 2 })

	row = table_left:addRow(false, { fixed = true })
	row[1]:setBackgroundColSpan(2):createText(ReadText(1001, 9502) .. ReadText(1001, 120))		-- Configuring, :
	row[2]:createText(ffi.string(C.GetComponentName(menu.boardingData.selectedship)), { halign = "right" })

	row = table_left:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createText((ReadText(1001, 9524) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 2 })		-- Ship behaviour while engaging the target, :

	local dropdowndata2 = {}
	for _, actiondata in ipairs(menu.boardingData.shipactions) do
		table.insert(dropdowndata2, {id = actiondata.id, text = actiondata.text, icon = "", displayremoveoption = false})
	end

	-- TODO: make dropdown being active dependent on current phase? disable after op has started?
	row = table_left:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createDropDown(dropdowndata2, {startOption = menu.boardingData.shipdata[menu.boardingData.selectedship].action, height = config.mapRowHeight, active = not activeop})
	row[1].handlers.onDropDownConfirmed = function(_, newaction) return menu.dropdownBoardingSetAction(menu.boardingData.selectedship, newaction) end

	row = table_left:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createText((ReadText(1001, 9529) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 3 })	-- Select marines to board with, :

	for _, leveldata in ipairs(menu.boardingData.marinelevels) do
		row = table_left:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		-- TODO: set slider to readOnly depending on phase? will depend on whether or not we allow sending more marines later in the operation to reinforce.
		--print("assigned: " .. tostring(assignedmarines[menu.boardingData.selectedship][leveldata.skilllevel]) .. ", available: " .. tostring(availablemarines[leveldata.skilllevel]))
		--print("start: " .. tostring(menu.boardingData.shipdata[menu.boardingData.selectedship].assignedmarines[leveldata.skilllevel]) .. ", maxSelect: " .. tostring(menu.boardingData.shipdata[menu.boardingData.selectedship].marines[leveldata.skilllevel] > (targetcrewcapacity - totalassignedmarines + menu.boardingData.shipdata[menu.boardingData.selectedship].assignedmarines[leveldata.skilllevel]) and (targetcrewcapacity - totalassignedmarines + menu.boardingData.shipdata[menu.boardingData.selectedship].assignedmarines[leveldata.skilllevel]) or menu.boardingData.shipdata[menu.boardingData.selectedship].marines[leveldata.skilllevel]) .. "\n poss1: " .. tostring(targetcrewcapacity - totalassignedmarines + menu.boardingData.shipdata[menu.boardingData.selectedship].assignedmarines[leveldata.skilllevel]) .. "\n poss2: " .. tostring(menu.boardingData.shipdata[menu.boardingData.selectedship].marines[leveldata.skilllevel]) .. "\ntargetcrewcapacity: " .. tostring(targetcrewcapacity) .. "\ntotalassignedmarines: " .. tostring(totalassignedmarines))
		--print("skilllevel: " .. tostring(leveldata.skilllevel) .. ", groupmarines: " .. tostring(menu.boardingData.shipdata[menu.boardingData.selectedship].groupmarines[leveldata.skilllevel]) .. ", marines: " .. tostring(menu.boardingData.shipdata[menu.boardingData.selectedship].marines[leveldata.skilllevel]) .. ", assignedgroupmarines: " .. tostring(menu.boardingData.shipdata[menu.boardingData.selectedship].assignedgroupmarines[leveldata.skilllevel]) .. ", assignedmarines: " .. tostring(menu.boardingData.shipdata[menu.boardingData.selectedship].assignedmarines[leveldata.skilllevel]))
		row[1]:setColSpan(2):createSliderCell({ start = menu.boardingData.shipdata[menu.boardingData.selectedship].assignedgroupmarines[leveldata.skilllevel], max = menu.boardingData.shipdata[menu.boardingData.selectedship].groupmarines[leveldata.skilllevel], maxSelect = menu.boardingData.shipdata[menu.boardingData.selectedship].groupmarines[leveldata.skilllevel] > (targetcrewcapacity - totalassignedmarines + menu.boardingData.shipdata[menu.boardingData.selectedship].assignedgroupmarines[leveldata.skilllevel]) and (targetcrewcapacity - totalassignedmarines + menu.boardingData.shipdata[menu.boardingData.selectedship].assignedgroupmarines[leveldata.skilllevel]) or menu.boardingData.shipdata[menu.boardingData.selectedship].groupmarines[leveldata.skilllevel], height = config.mapRowHeight, x = Helper.standardTextOffsetx * 4, readOnly = activeop }):setText(leveldata.text)
		row[1].handlers.onSliderCellChanged = function(_, val) return menu.slidercellBoardingAssignedMarines(menu.boardingData.selectedship, leveldata.skilllevel, val) end
		row[1].handlers.onSliderCellConfirm = function() return menu.refreshContextFrame() end
	end

	row = table_left:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createText((ReadText(1001, 9525) .. ReadText(1001, 120)), { x = Helper.standardTextOffsetx * 2 })		-- Boarding strength, :
	row[2]:createText(boardingstrength, { halign = "right" })

	if activeop then
		row = table_left:addRow(false, { fixed = true })
		row[1]:setColSpan(2):createText(ReadText(1001, 9526), { halign = "center" })		-- Total Casualties

		for lvl, leveldata in ipairs(menu.boardingData.marinelevels) do
			row = table_left:addRow(false, { bgColor = Helper.color.transparent })
			row[1]:createText(leveldata.text)
			-- if boarding op had already started but is now finished, print last saved data.
			row[2]:createText(function()
					local locskilllevel = leveldata.skilllevel
					local loclvl = lvl
					--print("skill level: " .. tostring(locskilllevel) .. " lvl: " .. tostring(loclvl))
					if C.IsDefensibleBeingBoardedBy(target, "player") then
						--local oldcasualties = menu.boardingData.casualties[loclvl]
						menu.boardingData.casualties[loclvl] = C.GetBoardingCasualtiesOfTier(locskilllevel, target, "player")
						--if menu.boardingData.casualties[loclvl] ~= oldcasualties then
						--	print("updating casualties of tier: " .. loclvl .. ". from: " .. oldcasualties .. " to: " .. menu.boardingData.casualties[loclvl])
						--end
					end
					return menu.boardingData.casualties[loclvl]
				end, { halign = "right" })
		end
	end

	table_left.properties.y = table_bottom.properties.y - table_header.properties.y - table_left:getVisibleHeight() - Helper.borderSize

	-- name might be confusing. table containing the button for the topleft table, rather than the button on the top-left.
	local table_button_topleft = frame:addTable(1, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = table_left.properties.width })
	row = table_button_topleft:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	-- TODO: activate button when mode boarding_selectplayerobject is implemented. disable depending on phase?
	--row[1]:createButton({ active = false }):setText(ReadText(1001, 9527), { halign = "center" })		-- Add ship to boarding operation
	--row[1].handlers.onClick = function() return menu.buttonBoardingAddShip() end

	-- Ships assigned to boarding operation. has to be initialized after table_bottom because we need that table's y-offset
	menu.boardingtable_shipselection = frame:addTable(3, { tabOrder = 2, x = Helper.borderSize, y = table_header.properties.y + table_header:getVisibleHeight() + Helper.borderSize, width = table_left.properties.width })
	menu.boardingtable_shipselection:setColWidth(2, config.mapRowHeight * 2)
	menu.boardingtable_shipselection:setColWidth(3, Helper.scaleY(config.mapRowHeight), false)

	row = menu.boardingtable_shipselection:addRow(false, { fixed = true })
	row[1]:setColSpan(3):createText(ReadText(1001, 9528))		-- Ships assigned to boarding operation

	for _, shipid in ipairs(menu.boardingData.ships) do
		row = menu.boardingtable_shipselection:addRow({"boardingship", shipid}, { bgColor = Helper.color.transparent })
		local nameappendix = ""
		if #menu.boardingData.shipdata[shipid].subordinates > 0 then
			nameappendix = (" + " .. #menu.boardingData.shipdata[shipid].subordinates .. " " .. ReadText(1001, 1504))		-- subordinates
		end
		row[1]:setBackgroundColSpan(3):createText((ffi.string(C.GetComponentName(shipid)) .. nameappendix))
		--row[1]:setBackgroundColSpan(3):createText((ffi.string(C.GetComponentName(shipid)) .. nameappendix), { x = menu.boardingData.shipdata[shipid].issubordinate and (Helper.standardTextOffsetx + Helper.standardIndentStep) or nil })

		local nummarines = 0
		for _, leveldata in ipairs(menu.boardingData.marinelevels) do
			nummarines = nummarines + menu.boardingData.shipdata[shipid].groupmarines[leveldata.skilllevel]
		end
		row[2]:createText(nummarines, { halign = "right" })
		if not menu.boardingData.shipdata[shipid].issubordinate then
			row[3]:createButton({ height = row[3]:getWidth(), scaling = false }):setText("x", { halign = "center", font = Helper.standardFontBold })
			row[3].handlers.onClick = function() return menu.buttonBoardingRemoveShip(shipid) end
		end

		if menu.boardingData.selectedship == shipid then
			menu.boardingtable_shipselection:setSelectedRow(row.index)
		end
	end

	menu.boardingtable_shipselection.properties.maxVisibleHeight = table_left.properties.y - Helper.scaleY(table_button_topleft:getVisibleHeight()) - Helper.scaleY(table_header:getVisibleHeight()) - Helper.borderSize * 3
	table_button_topleft.properties.y = menu.boardingtable_shipselection.properties.y + menu.boardingtable_shipselection:getVisibleHeight() + Helper.borderSize
	--print("topleft maxvisibleheight: " .. tostring(menu.boardingtable_shipselection.properties.maxVisibleHeight) .. "\n left y offset: " .. tostring(table_left.properties.y) .. "\n buttontopleft height: " .. tostring(table_button_topleft:getVisibleHeight()) .. "\n header height: " .. tostring(table_header:getVisibleHeight()) .. "\n 3 borders: " .. tostring(Helper.borderSize * 3))

	-- Boarding Target
	local table_right = frame:addTable(2, { x = table_left.properties.x + table_left.properties.width + Helper.borderSize, y = menu.boardingtable_shipselection.properties.y, width = table_left.properties.width, height = table_bottom.properties.y - Helper.scaleY(table_header:getVisibleHeight())  - Helper.borderSize * 2 })
	table_right:setColWidthPercent(1, 20)

	row = table_right:addRow(false, { fixed = true })
	row[1]:setColSpan(2):createText(ReadText(1001, 9503), { halign = "center" })	-- Boarding Target

	row = table_right:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:createText(ReadText(1001, 5) .. ReadText(1001, 120))		-- Ship, :
	row[2]:createText(targetname, { halign = "right" })

	row = table_right:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:createText(ReadText(1001, 43) .. ReadText(1001, 120))		-- Faction, :
	row[2]:createText(targetowner, { halign = "right" })

	row = table_right:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createText("")

	row = table_right:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:createText(ReadText(1001, 1319) .. ReadText(1001, 120))		-- Turrets, :
	row[2]:createText(function()
			local locnumoperationalturrets = menu.getNumOperationalTurrets(target, numtotalturrets)
			return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and (locnumoperationalturrets .. " / " .. numtotalturrets) or unknowntext
		end, { halign = "right", color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and Helper.standardColor or unknowncolor end })

	row = table_right:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:createText(ReadText(1001, 1) .. ReadText(1001, 120))		-- Hull, :
	row[2]:createText(function()
			local lochullpercentage = GetComponentData(target, "hullpercent")
			return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and (lochullpercentage .. "%") or unknowntext
		end, { halign = "right", color = function() return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "defence_status")) and Helper.standardColor or unknowncolor end })

	row = table_right:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:createText(ReadText(1001, 80) .. ReadText(1001, 120))		-- Crew, :
	row[2]:createText(function()
			local locnumdefendingcrew = menu.getNumDefendingCrew(target)
			return (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and (locnumdefendingcrew .. " / " .. targetcrewcapacity) or unknowntext
		end, { halign = "right", color = (boardingcheatsecrecy or C.IsInfoUnlockedForPlayer(target, "operator_details")) and Helper.standardColor or unknowncolor })

	local table_button = frame:addTable(3, { tabOrder = 6, x = Helper.borderSize, y = table_bottom.properties.y + table_bottom:getVisibleHeight() + Helper.borderSize, width = menu.contextMenuData.width })
	table_button:setColWidthPercent(2, 15)
	table_button:setColWidthPercent(3, 15)

	row = table_button:addRow(true, { bgColor = Helper.color.transparent, fixed = true })
	-- handler: if no boarding op, create a boarding op with defined specifications. (and refresh menu?)
	-- if op already created, update boarding op data. (changes in ship and marine assignments.)
	-- approachthreshold == menu.boardingData.risk1
	-- insertionthreshold == menu.boardingData.risk2
	-- activate button only if anything was changed (number of marines, thresholds, actions)
	row[2]:createButton({ active = function() return menu.boardingData.iscapturable and menu.boardingData.changed and totalassignedmarines > 0 end }):setText(activeop and ReadText(1001, 9531) or ReadText(1001, 9530), { halign = "center" })		-- Update Operation, Start Operation
	row[2].handlers.onClick = function() return menu.buttonUpdateBoardingOperation(activeop) end
	row[3]:createButton({ active = true }):setText(activeop and ReadText(1001, 8035) or ReadText(1001, 64), { halign = "center" })		-- "Close Menu", "Cancel"
	row[3].handlers.onClick = function() return menu.closeContextMenu() end

	if menu.contexttoprow then
		menu.boardingtable_shipselection:setTopRow(menu.contexttoprow)
		menu.contexttoprow = nil
	end
	if menu.contextselectedrow then
		menu.boardingtable_shipselection:setSelectedRow(menu.contextselectedrow)
		menu.contextselectedrow = nil
	end
end

function menu.createMissionContext(frame)
	local tablespacing = Helper.standardTextHeight
	local maxDescriptionLines = 10
	local maxObjectiveLines = 10

	-- description table
	local desctable = frame:addTable(1, { tabOrder = 3, highlightMode = "off", maxVisibleHeight = menu.contextMenuData.descriptionHeight, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })

	-- title
	local visibleHeight
	local row = desctable:addRow(false, { fixed = true })
	row[1]:createText(menu.contextMenuData.name, Helper.headerRowCenteredProperties)
	-- description
	for linenum, descline in ipairs(menu.contextMenuData.description) do
		local row = desctable:addRow(true, { bgColor = Helper.color.transparent })
		row[1]:createText(descline)
		if linenum == maxDescriptionLines then
			visibleHeight = desctable:getFullHeight()
		end
	end
	if visibleHeight then
		desctable.properties.maxVisibleHeight = visibleHeight
	else
		desctable.properties.maxVisibleHeight = desctable:getFullHeight()
	end

	-- objectives table
	local objectivetable = frame:addTable(2, { tabOrder = 4, highlightMode = "off", x = Helper.borderSize, y = desctable:getVisibleHeight() + tablespacing + Helper.borderSize, maxVisibleHeight = menu.contextMenuData.objectiveHeight, width = menu.contextMenuData.width })
	objectivetable:setColWidth(2, Helper.standardTextHeight)
	objectivetable:setDefaultColSpan(1, 2)

	-- objectives
	local visibleHeight
	if menu.contextMenuData.threadtype ~= "" then
		-- title
		local row = objectivetable:addRow(false, { fixed = true })
		row[1]:createText(ReadText(1001, 3418), Helper.headerRowCenteredProperties)
		if menu.contextMenuData.isoffer then
			if #menu.contextMenuData.briefingmissions > 0 then
				for i, details in ipairs(menu.contextMenuData.briefingmissions) do
					local row = objectivetable:addRow(true, { bgColor = Helper.color.transparent })
					row[1]:setColSpan(1):createText(((menu.contextMenuData.threadtype == "sequential") and (i .. ReadText(1001, 120)) or "·") .. " " .. details.name)
					row[2]:createIcon("missionoffer_" .. details.type .. "_active", { height = Helper.standardTextHeight })
					if i == maxObjectiveLines then
						visibleHeight = objectivetable:getFullHeight()
					end
				end
			else
				local row = objectivetable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:createText("--- " .. ReadText(1001, 3410) .. " ---")
			end
		else
			if #menu.contextMenuData.subMissions > 0 then
				for i, submissionEntry in ipairs(menu.contextMenuData.subMissions) do
					local row = objectivetable:addRow(true, { bgColor = Helper.color.transparent })
					row[1]:setColSpan(1):createText(((menu.contextMenuData.threadtype == "sequential") and (i .. ReadText(1001, 120)) or "·") .. " " .. submissionEntry.name)
					row[2]:createIcon("missionoffer_" .. submissionEntry.type .. "_active", { height = Helper.standardTextHeight })
					if i == maxObjectiveLines then
						visibleHeight = objectivetable:getFullHeight()
					end
				end
			else
				local row = objectivetable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:createText("--- " .. ReadText(1001, 3410) .. " ---")
			end
		end
	else
		-- title
		local row = objectivetable:addRow(false, { fixed = true })
		row[1]:createText(ReadText(1001, 3402), Helper.headerRowCenteredProperties)
		if #menu.contextMenuData.briefingobjectives > 0 then
			for linenum, briefingobjective in ipairs(menu.contextMenuData.briefingobjectives) do
				local row = objectivetable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:createText(briefingobjective.step .. ReadText(1001, 120) .. " " .. briefingobjective.text)
				if linenum == maxObjectiveLines then
					visibleHeight = objectivetable:getFullHeight()
				end
			end
		else
			local row = objectivetable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:createText("--- " .. ReadText(1001, 3410) .. " ---")
		end
	end
	if visibleHeight then
		objectivetable.properties.maxVisibleHeight = visibleHeight
	else
		objectivetable.properties.maxVisibleHeight = objectivetable:getFullHeight()
	end

	-- bottom table (info and buttons)
	local bottomtable = frame:addTable(2, { tabOrder = 2, x = Helper.borderSize, y = objectivetable.properties.y + objectivetable:getVisibleHeight() + tablespacing, width = menu.contextMenuData.width })

	-- faction
	if menu.contextMenuData.factionName then
		local row = bottomtable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:createText(ReadText(1001, 43) .. ReadText(1001, 120))
		row[2]:createText(menu.contextMenuData.factionName, { halign = "right" })
	end
	-- reward
	local rewardtext
	if menu.contextMenuData.rewardmoney ~= 0 then
		rewardtext = ConvertMoneyString(menu.contextMenuData.rewardmoney, false, true, 0, true) .. " " .. ReadText(1001, 101)
		if menu.contextMenuData.rewardtext ~= "" then
			rewardtext = rewardtext .. " " .. menu.contextMenuData.rewardtext
		end
	else
		rewardtext = menu.contextMenuData.rewardtext
	end
	local row = bottomtable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createText(ReadText(1001, 3301) .. ReadText(1001, 120))
	row[2]:createText(rewardtext, { halign = "right" })
	-- difficulty
	if menu.contextMenuData.difficulty ~= 0 then
		local row = bottomtable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:createText(ReadText(1001, 3403) .. ReadText(1001, 120))
		row[2]:createText(ConvertMissionLevelString(menu.contextMenuData.difficulty), { halign = "right" })
	end
	-- time left
	local row = bottomtable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createText(ReadText(1001, 3404) .. ReadText(1001, 120))
	row[2]:createText(menu.getMissionContextTime, { halign = "right" })

	-- buttons
	if menu.contextMenuData.isoffer then
		-- Accept & Briefing
		local row = bottomtable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:createButton({  }):setText(ReadText(1001, 57), { halign = "center" })
		row[1].handlers.onClick = menu.buttonMissionOfferAccept
		row[1].properties.uiTriggerID = "missionofferaccept"
		row[2]:createButton({  }):setText(ReadText(1001, 3326), { halign = "center" })
		row[2].handlers.onClick = menu.buttonMissionOfferBriefing
		row[2].properties.uiTriggerID = "missionofferbriefing"
	else
		-- Abort & Briefing
		local active = menu.contextMenuData.abortable
		local mouseovertext = ""
		if menu.contextMenuData.threadMissionID ~= 0 then
			local details = menu.getMissionIDInfoHelper(menu.contextMenuData.threadMissionID)
			active = details.threadtype ~= "sequential"
			if not active then
				mouseovertext = ReadText(1026, 3405)
			end
		end
		local row = bottomtable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:createButton({ active = active, mouseOverText = mouseovertext }):setText(ReadText(1001, 3407), { halign = "center" })
		row[1].handlers.onClick = menu.buttonMissionAbort
		row[1].properties.uiTriggerID = "missionabort"
		row[2]:createButton({  }):setText(ReadText(1001, 3326), { halign = "center" })
		row[2].handlers.onClick = menu.buttonMissionBriefing
		row[2].properties.uiTriggerID = "missionbriefing"
		if menu.contextMenuData.type ~= "guidance" then
			-- Set active
			local active = menu.contextMenuData.missionid == C.GetActiveMissionID()
			for _, submissionEntry in ipairs(menu.contextMenuData.subMissions) do
				if submissionEntry.active then
					active = true
				end
			end
			local row = bottomtable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
			row[1]:createButton({  }):setText(active and ReadText(1001, 3413) or ReadText(1001, 3406), { halign = "center" })
			row[1].handlers.onClick = menu.buttonMissionActivate
			row[1].properties.uiTriggerID = "missionactivate"
		end
	end

	desctable.properties.nextTable = objectivetable.index
	objectivetable.properties.prevTable = desctable.index

	objectivetable.properties.nextTable = bottomtable.index
	bottomtable.properties.prevTable = objectivetable.index
end

function menu.getMissionContextTime()
	if not menu.contextMenuData.expired then
		if (not menu.contextMenuData.isoffer) and menu.contextMenuData.missionid then
			local missiondetails = C.GetMissionIDDetails(menu.contextMenuData.missionid)
			local timeout = (missiondetails.duration and missiondetails.duration > 0) and missiondetails.duration or (missiondetails.timeLeft or -1)

			return (timeout > 0 and ConvertTimeString(timeout, (timeout > 3600) and "%h:%M:%S" or "%M:%S") or "-")
		else
			return (menu.contextMenuData.timeout > 0 and ConvertTimeString(menu.contextMenuData.timeout, (menu.contextMenuData.timeout > 3600) and "%h:%M:%S" or "%M:%S") or "-")
		end
	else
		return "-"
	end
end

function menu.createInfoActorContext(frame)
	local controllable = menu.contextMenuData.component
	local entity = menu.contextMenuData.entity
	local person = menu.contextMenuData.person
	local personrole = ""
	if not (controllable and (person or entity)) then
		DebugError(string.format("menu.createInfoActorContext called with invalid controllable or invalid actor. controllable: %s, person: %s, entity: %s", tostring(controllable), tostring(person), tostring(entity)))
		return
	end
	if person then
		--print("person: " .. ffi.string(C.GetPersonName(person, controllable)) .. ", combinedskill: " .. C.GetPersonCombinedSkill(controllable, person, nil, nil))
		-- get real NPC if instantiated
		local instance = C.GetInstantiatedPerson(person, controllable)
		entity = (instance ~= 0 and instance or nil)
		personrole = ffi.string(C.GetPersonRole(person, controllable))
	end

	local loctable = frame:addTable(1, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })

	local actorname = ""
	if entity then
		actorname = ffi.string(C.GetComponentName(entity))
	else
		actorname = ffi.string(C.GetPersonName(person, controllable))
	end

	-- title
	local row = loctable:addRow(false, { fixed = true })
	row[1]:createText(actorname, Helper.headerRowCenteredProperties)

	local oldpilot = GetComponentData(controllable, "assignedaipilot")
	if oldpilot then
		oldpilot = ConvertStringTo64Bit(tostring(oldpilot))
	end
	if person and ((personrole == "service") or (personrole == "marine")) then
		local printedtitle = C.IsComponentClass(controllable, "ship_s") and ReadText(1001, 4847) or ReadText(1001, 4848)	-- Pilot, Captain
		row = loctable:addRow("info_person_promote", { fixed = true, bgColor = Helper.color.transparent })
		row[1]:createButton({ bgColor = Helper.color.transparent, height = Helper.standardTextHeight }):setText(ReadText(1001, 9433) .. " " .. printedtitle)	-- Promote to(followed by "captain" or "pilot")
		row[1].handlers.onClick = function () return menu.infoSubmenuReplacePilot(controllable, oldpilot, person, false, true) end
	end
	local conversationactor = ConvertStringTo64Bit(tostring(entity))
	if person and (not entity or C.GetContextByClass(entity, "container", false) ~= C.GetContextByClass(C.GetPlayerID(), "container", false)) then
		-- Talking to person - either not instantiated as a real entity, or the instance is far away.
		-- Note: Only start comms with instantiated NPCs if they are on the player container, otherwise they are likely to get despawned during the conversation.
		conversationactor = { context = ConvertStringTo64Bit(tostring(controllable)), person = ConvertStringTo64Bit(tostring(person)) }
	end
	row = loctable:addRow("info_actor_comm", { fixed = true, bgColor = Helper.color.transparent })
	row[1]:createButton({ bgColor = Helper.color.transparent, height = Helper.standardTextHeight }):setText(ReadText(1001, 3216))	-- (initiate comm)Comm
	row[1].handlers.onClick = function () menu.openCommWithActor(conversationactor) end
end

function menu.createSellShipsContext(frame)
	-- description table
	local ftable = frame:addTable(2, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })
	ftable:setColWidthPercent(1, 60)

	-- title
	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(2):createText(ReadText(1001, 7857), Helper.headerRowCenteredProperties)
	-- ships
	local issellingpossible = false
	menu.contextMenuData.totalprice = 0
	for i, data in ipairs(menu.contextMenuData.ships) do
		local errors, warnings = {}, {}
		local n = C.GetNumOrders(data)
		local buf = ffi.new("Order[?]", n)
		n = C.GetOrders(buf, n, data)
		for i = 0, n - 1 do
			if ffi.string(buf[i].orderdef) == "Equip" then
				errors[1] = ReadText(1001, 3267)
				break
			end
		end
		local hasanymod = GetComponentData(data, "hasanymod")
		if hasanymod then
			warnings[1] = ReadText(1001, 3268)
		end
		menu.contextMenuData.ships[i] = { data, errors }
		local ship = menu.contextMenuData.ships[i][1]
		local price = GetTotalValue(ship, true, menu.contextMenuData.shipyard)

		local color = Helper.color.white
		if #errors > 0 then
			color = Helper.color.grey
		else
			issellingpossible = true
			menu.contextMenuData.totalprice = menu.contextMenuData.totalprice + price
		end

		local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:createText(ffi.string(C.GetComponentName(ship)) .. " (" .. ffi.string(C.GetObjectIDCode(ship)) .. ")", { color = color })
		row[2]:createText(ConvertMoneyString(price, false, true, 0, true) .. " " .. ReadText(1001, 101), { halign = "right", color = color })

		for _, error in ipairs(errors) do
			local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
			row[1]:setColSpan(2):createText(error, { halign = "right", color = Helper.color.red })
		end
		for _, warning in ipairs(warnings) do
			local row = ftable:addRow(false, { fixed = true, bgColor = Helper.color.transparent })
			row[1]:setColSpan(2):createText(warning, { halign = "right", color = Helper.color.orange })
		end
	end
	-- button
	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[2]:createButton({ active = issellingpossible, height = Helper.standardTextHeight }):setText(ReadText(1001, 2917), { halign = "center" })
	row[2].handlers.onClick = menu.buttonSellShips

	if frame.properties.x + menu.contextMenuData.width > Helper.viewWidth then
		frame.properties.x = Helper.viewWidth - menu.contextMenuData.width - config.contextBorder
	end
	local height = frame:getUsedHeight()
	if frame.properties.y + height > Helper.viewHeight then
		frame.properties.y = Helper.viewHeight - height - config.contextBorder
	end
end

function menu.createSelectContext(frame)
	-- description table
	local ftable = frame:addTable(1, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })

	-- title
	local row = ftable:addRow(false, { fixed = true })
	row[1]:createText(Helper.unlockInfo(IsInfoUnlockedForPlayer(menu.contextMenuData.component, "name"), ffi.string(C.GetComponentName(menu.contextMenuData.component))), Helper.headerRowCenteredProperties)

	local row = ftable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	local active = true
	local mouseovertext = ""
	if menu.mode == "selectCV" then
		local playermoney = GetPlayerMoney()
		local fee = tonumber(C.GetBuilderHiringFee())
		if playermoney < fee then
			active = false
			mouseovertext = "\27R" .. ReadText(1026, 3222)
		end
	end
	row[1]:createButton({ active = active, height = Helper.standardTextHeight, mouseOverText = mouseovertext }):setText(ReadText(1001, 3102))
	row[1].handlers.onClick = menu.buttonSelectHandler
	row[1].properties.uiTriggerID = "selectactive"

	if frame.properties.x + menu.contextMenuData.width > Helper.viewWidth then
		frame.properties.x = Helper.viewWidth - menu.contextMenuData.width - config.contextBorder
	end
	local height = frame:getUsedHeight()
	if frame.properties.y + height > Helper.viewHeight then
		frame.properties.y = Helper.viewHeight - height - config.contextBorder
	end
end

function menu.createWeaponConfigContext(frame)
	local ftable = frame:addTable(2, { tabOrder = 3, x = Helper.borderSize, y = Helper.borderSize, width = menu.contextMenuData.width })
	ftable:setColWidth(1, Helper.standardTextHeight)

	-- title
	local row = ftable:addRow(false, { fixed = true })
	row[1]:setColSpan(2):createText(ReadText(1001, 1105), Helper.headerRowCenteredProperties)

	if not menu.contextMenuData.usedefault then
		for _, entry in ipairs(menu.contextMenuData.weaponsystems) do
			if entry.id == "default" then
				local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
				row[1]:createCheckBox(entry.active, { width = config.mapRowHeight, height = config.mapRowHeight })
				row[1].handlers.onClick = function () return menu.checkboxSetWeaponConfig(entry.id, not entry.active) end
				row[2]:createText(entry.id)
				break
			end
		end
	end

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createText("", { fontsize = 1, minRowHeight = 1 })

	if menu.contextMenuData.default then
		menu.contextMenuData.weaponsystems = {}
		local n = C.GetNumAllowedWeaponSystems()
		local buf = ffi.new("WeaponSystemInfo[?]", n)
		n = C.GetAllowedWeaponSystems(buf, n, menu.contextMenuData.component, 0, true)
		for i = 0, n - 1 do
			table.insert(menu.contextMenuData.weaponsystems, { id = ffi.string(buf[i].id), name = ffi.string(buf[i].name), active = buf[i].active })
		end
	end

	for _, entry in ipairs(menu.contextMenuData.weaponsystems) do
		if entry.id ~= "default" then
			local color = Helper.color.white
			if menu.contextMenuData.default then
				color = Helper.color.grey
			end
			local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
			row[1]:createCheckBox(entry.active, { width = config.mapRowHeight, height = config.mapRowHeight })
			row[1].handlers.onClick = function () return menu.checkboxSetWeaponConfig(entry.id, not entry.active) end
			row[2]:createText(entry.name, { color = color })
		end
	end

	local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createButton({ active = not menu.contextMenuData.default }):setText(ReadText(1001, 5706), { halign = "center" })
	row[1].handlers.onClick = menu.buttonClearWeaponConfig

	local row = ftable:addRow(false, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createText("")

	local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createButton():setText(ReadText(1001, 2821), { halign = "center" })
	row[1].handlers.onClick = menu.buttonConfirmWeaponConfig

	local row = ftable:addRow(true, { bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createButton():setText(ReadText(1001, 64), { halign = "center" })
	row[1].handlers.onClick = menu.buttonCancelWeaponConfig
end

-- update
menu.updateInterval = 0.01

function menu.onUpdate()
	if menu.mainFrame then
		menu.mainFrame:update()
	end
	if menu.infoFrame then
		menu.infoFrame:update()
	end
	if menu.contextFrame then
		menu.contextFrame:update()
	end

	if menu.map and menu.holomap ~= 0 then
		local x, y = GetRenderTargetMousePosition(menu.map)
		C.SetMapRelativeMousePosition(menu.holomap, (x and y) ~= nil, x or 0, y or 0)
	end
	
	local curtime = getElapsedTime()
	local refreshing = false
	if menu.refreshIF and (menu.refreshIF < curtime) then
		refreshing = true
		menu.refreshIF = nil
	end
	
	if menu.activatemap then
		-- pass relative screenspace of the holomap rendertarget to the holomap (value range = -1 .. 1)
		local renderX0, renderX1, renderY0, renderY1 = Helper.getRelativeRenderTargetSize(menu, config.mainFrameLayer, menu.map)
		local rendertargetTexture = GetRenderTargetTexture(menu.map)
		if rendertargetTexture then
			menu.holomap = C.AddHoloMap(rendertargetTexture, renderX0, renderX1, renderY0, renderY1, menu.rendertargetWidth / menu.rendertargetHeight, 1)
			if menu.holomap ~= 0 then
				C.ClearSelectedMapComponents(menu.holomap)
				if menu.mode == "selectbuildlocation" then
					C.ShowBuildPlotPlacementMap(menu.holomap, menu.currentsector)
				else
					C.ShowUniverseMap(menu.holomap, true, menu.showzone, menu.mode == "selectCV")
				end
			end

			if menu.focuscomponent then
				C.SetFocusMapComponent(menu.holomap, menu.focuscomponent, true)
			end

			if menu.mapstate then
				C.SetMapState(menu.holomap, menu.mapstate)
				menu.mapstate = nil
			end
			Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.SetMapFilterString(menu.holomap, numtexts, texts) end, "text")
			menu.applyFilterSettings()

			menu.activatemap = false
			if menu.infoTableMode == "objectlist" then
				menu.refreshIF = getElapsedTime()
			end
		end
	end

	if not menu.refreshed then
		if menu.holomap and (menu.holomap ~= 0) then
			if menu.picking ~= menu.pickstate then
				menu.pickstate = menu.picking
				C.SetMapPicking(menu.holomap, menu.pickstate)
			end
		end
	end
	menu.refreshed = nil
	
	if menu.lock and curtime > menu.lock + 0.01 then
		menu.lock = nil
	end
	if menu.over then
		menu.refreshInfoFrame()
		menu.over = nil
		return
	end

	-- evaluate mouse cursor overrides
	if menu.holomap and (menu.holomap ~= 0) then
		menu.updateMouseCursor()
	end

	local range = 100
	if menu.contextMenuData and menu.contextMenuData.mouseOutPos then
		if (GetControllerInfo() ~= "gamepad") or (C.IsMouseEmulationActive()) then
			local curpos = table.pack(GetLocalMousePosition())
			if curpos[1] and ((curpos[1] > menu.contextMenuData.mouseOutPos[1] + range) or (curpos[1] < menu.contextMenuData.mouseOutPos[1] - range)) then
				menu.closeContextMenu()
			elseif curpos[2] and ((curpos[2] > menu.contextMenuData.mouseOutPos[2] + range) or (curpos[2] < menu.contextMenuData.mouseOutPos[2] - range)) then
				menu.closeContextMenu()
			end
		end
	end

	if menu.lastHighlightCheck + 1.0 < curtime then
		menu.lastHighlightCheck = curtime
		if menu.highlightLeftBar["mission"] then
			if C.GetActiveMissionID() == 0 then
				menu.highlightLeftBar["mission"] = nil
				menu.refreshMainFrame = true
			end
		end
	end

	if (menu.infoTableMode == "info") and ((menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced")) then
		local orders = {}
		if menu.isInfoModeValidFor(menu.infoSubmenuObject, "orderqueue") then
			local n = C.GetNumOrders(menu.infoSubmenuObject)
			local buf = ffi.new("Order[?]", n)
			n = C.GetOrders(buf, n, menu.infoSubmenuObject)
			for i = 0, n - 1 do
				local entry = {}
				entry.state = ffi.string(buf[i].state)
				entry.orderdef = ffi.string(buf[i].orderdef)
				entry.actualparams = tonumber(buf[i].actualparams)
				table.insert(orders, entry)
			end
		end

		if #orders ~= #menu.infoTableData.orders then
			refreshing = true
		else
			for i, order in ipairs(orders) do
				local oldorder = menu.infoTableData.orders[i]
				if (order.state ~= oldorder.state) or (order.orderdef ~= oldorder.orderdef) then
					refreshing = true
					break
				end
			end
		end
	end

	if menu.orderdrag and menu.orderdrag.isclick then
		local offset = table.pack(GetLocalMousePosition())
		if (menu.leftdown.time + 0.5 < curtime) or Helper.comparePositions(menu.leftdown.position, offset, 5) then
			menu.orderdrag.isclick = false
			if menu.orderdrag.isintermediate then
				if menu.orderdrag.component ~= C.GetPlayerOccupiedShipID() then
					local posrot = ffi.new("UIPosRot")
					local posrotcomponent = C.GetMapPositionOnEcliptic(menu.holomap, posrot)
					if C.IsOrderSelectableFor("MoveWait", menu.orderdrag.component) then
						local orderidx = C.CreateOrder(menu.orderdrag.component, "MoveWait", false)
						SetOrderParam(ConvertStringToLuaID(tostring(menu.orderdrag.component)), orderidx, 1, nil, { ConvertStringToLuaID(tostring(posrotcomponent)), {posrot.x, posrot.y, posrot.z} })
						C.AdjustOrder(menu.orderdrag.component, orderidx, menu.orderdrag.order.queueidx, menu.orderdrag.order.enabled, false, false)
						if menu.infoTableMode == "mission" then
							menu.refreshIF = getElapsedTime()
						end
					end
				end
			end
		end
	end
	if menu.orderdrag and (not menu.orderdrag.isclick) then
		if menu.orderdrag.component ~= C.GetPlayerOccupiedShipID() then
			local posrot = ffi.new("UIPosRot")
			local posrotcomponent = C.GetMapPositionOnEcliptic(menu.holomap, posrot)
			if posrotcomponent ~= 0 then
				SetOrderParam(ConvertStringToLuaID(tostring(menu.orderdrag.component)), tonumber(menu.orderdrag.order.queueidx), 1, nil, { ConvertStringToLuaID(tostring(posrotcomponent)), {posrot.x, posrot.y, posrot.z} })
			end
		end
	end

	if menu.panningmap and menu.panningmap.isclick then
		local offset = table.pack(GetLocalMousePosition())
		if (menu.leftdown.time + 0.5 < curtime) or Helper.comparePositions(menu.leftdown.position, offset, 5) then
			menu.panningmap.isclick = false
		end
	end

	if menu.lastzoom then
		if not menu.zoom_newdir or menu.zoom_newdir ~= menu.lastzoom.dir then
			if menu.zoom_newdir then
				if menu.sound_zoom then
					StopPlayingSound(menu.sound_zoom)
				end
				menu.sound_zoom = nil
			end

			if menu.lastzoom.dir == "in" then
				menu.sound_zoom = StartPlayingSound("ui_scroll_zoomin")
				menu.zoom_newdir = "in"
			elseif menu.lastzoom.dir == "out" then
				menu.sound_zoom = StartPlayingSound("ui_scroll_zoomout")
				menu.zoom_newdir = "out"
			end
		elseif menu.sound_zoom and menu.lastzoom.time + 0.3 < curtime then
			StopPlayingSound(menu.sound_zoom)
			menu.sound_zoom = nil
			menu.zoom_newdir = nil
			menu.lastzoom = nil
		end
	end

	if menu.leftdown then
		if not menu.leftdown.wasmoved then
			local offset = table.pack(GetLocalMousePosition())
			if Helper.comparePositions(menu.leftdown.position, offset, 5) then
				menu.leftdown.wasmoved = true
			end
		else
			if menu.leftdown.dyntime + 0.5 < curtime then
				menu.leftdown.dyntime = curtime
				if menu.infoTableMode == "objectlist" then
					refreshing = true
				end
			end
		end
		if menu.leftdown.wasmoved and menu.leftdown.time + 0.1 < curtime and not C.IsComponentClass(C.GetPickedMapComponent(menu.holomap), "object") then
			local currentmousepos = table.pack(GetLocalMousePosition())
			if menu.panningmap and Helper.comparePositions(menu.leftdown.dynpos, currentmousepos, 5) then
				if not menu.sound_panmap then
					menu.sound_panmap = StartPlayingSound("ui_scroll_wasd")
				end
				menu.leftdown.dynpos = currentmousepos
			elseif menu.sound_panmap then
				StopPlayingSound(menu.sound_panmap)
				menu.sound_panmap = nil
			end
		end
	end

	if menu.rightdown then
		if not menu.rightdown.wasmoved then
			local offset = table.pack(GetLocalMousePosition())
			if Helper.comparePositions(menu.rightdown.position, offset, 5) then
				menu.rightdown.wasmoved = true
			end
		else
			if menu.rightdown.dyntime + 0.5 < curtime then
				menu.rightdown.dyntime = curtime
				if menu.infoTableMode == "objectlist" then
					refreshing = true
				end
			end
		end
		if menu.rightdown.wasmoved and menu.rightdown.time + 0.1 < curtime and not C.IsComponentClass(C.GetPickedMapComponent(menu.holomap), "object") then
			local currentmousepos = table.pack(GetLocalMousePosition())
			if menu.rotatingmap then
				if currentmousepos[2] > menu.rightdown.dynpos[2] then
					if menu.sound_rotatemap then
						if menu.sound_rotatemap.dir ~= "down" then
							if menu.sound_rotatemap.sound then
								StopPlayingSound(menu.sound_rotatemap.sound)
							end
							menu.sound_rotatemap = { sound = StartPlayingSound("ui_scroll_pitch_down"), dir = "down"}
						end
					else
						menu.sound_rotatemap = { sound = StartPlayingSound("ui_scroll_pitch_down"), dir = "down"}
					end
					menu.rightdown.dynpos = currentmousepos
				elseif currentmousepos[2] < menu.rightdown.dynpos[2] then
					if menu.sound_rotatemap then
						if menu.sound_rotatemap.dir ~= "up" then
							if menu.sound_rotatemap.sound then
								StopPlayingSound(menu.sound_rotatemap.sound)
							end
							menu.sound_rotatemap = { sound = StartPlayingSound("ui_scroll_pitch_up"), dir = "up"}
						end
					else
						menu.sound_rotatemap = { sound = StartPlayingSound("ui_scroll_pitch_up"), dir = "up"}
					end
					menu.rightdown.dynpos = currentmousepos
				elseif menu.rightdown.dynpos[1] ~= currentmousepos[1] then
					if menu.sound_rotatemap then
						if menu.sound_rotatemap.dir ~= "up" then
							if menu.sound_rotatemap.sound then
								StopPlayingSound(menu.sound_rotatemap.sound)
							end
							menu.sound_rotatemap = { sound = StartPlayingSound("ui_scroll_cirle"), dir = "rot"}
						end
					else
						menu.sound_rotatemap = { sound = StartPlayingSound("ui_scroll_cirle"), dir = "rot"}
					end
					menu.rightdown.dynpos = currentmousepos
				elseif menu.sound_rotatemap then
					if menu.sound_rotatemap.sound then
						StopPlayingSound(menu.sound_rotatemap.sound)
					end
					menu.sound_rotatemap = nil
				end
			end
		end
	end

	if menu.lastscrolltime then
		if menu.lastupdatetime + 0.5 < curtime then
			menu.lastupdatetime = curtime
			menu.lastscrolltime = nil
			if menu.infoTableMode == "objectlist" then
				menu.refreshInfoFrame()
				return
			end
		end
	end

	if (menu.infoTableMode == "objectlist") then
		if menu.lastrefresh + 2.0 < curtime then
			refreshing = true
		end
	end

	if refreshing and (not menu.noupdate) then
		menu.lastrefresh = curtime
		menu.refreshInfoFrame()
	end

	if not menu.panningmap then
		if menu.refreshMainFrame then
			if not menu.createMainFrameRunning then
				menu.topRows.filterTable = GetTopRow(menu.searchField)
				menu.selectedRows.filterTable = Helper.currentTableRow[menu.searchField]
				menu.selectedCols.filterTable = Helper.currentTableCol[menu.searchField]

				menu.selectedRows.sideBar = Helper.currentTableRow[menu.sideBar]

				menu.createMainFrame(nil, (menu.contextMenuMode == "trade") and menu.contextMenuData.tradeModeHeight or nil)
				menu.refreshMainFrame = nil
			end
		end
	end

	if menu.contextMenuMode == "trade" then
		if (not menu.tradeSliderLock) then
			local playermoney = GetPlayerMoney()
			if playermoney ~= menu.contextMenuData.playerMoney then
				menu.contextMenuData.playerMoney = playermoney
				menu.queuetradecontextrefresh = true
			end
		end
	end

	if menu.queuecontextrefresh then
		menu.refreshContextFrame()
		menu.queuecontextrefresh = nil
	end

	if menu.queuetradecontextrefresh then
		menu.topRows.contextshiptable = GetTopRow(menu.contextshiptable)
		menu.selectedRows.contextshiptable = Helper.currentTableRow[menu.contextshiptable]
		menu.createContextFrame()
		menu.queuetradecontextrefresh = nil
	end
end

-- row changes
function menu.onRowChanged(row, rowdata, uitable, modified, input)
	if menu.holomap == 0 then
		return
	end
	-- Lock button over updates
	menu.lock = getElapsedTime()

	if (menu.mode == "boardingcontext") and menu.boardingtable_shipselection and (uitable == menu.boardingtable_shipselection.id) and (type(rowdata) == "table") and (rowdata[1] == "boardingship") and C.IsComponentClass(rowdata[2], "defensible") and (menu.boardingData.selectedship ~= rowdata[2]) then
		--print("queueing refresh on next frame. ship: " .. ffi.string(C.GetComponentName(rowdata[2])) .. " " .. tostring(rowdata[2]))
		menu.boardingData.selectedship = rowdata[2]
		menu.queuecontextrefresh = true
	elseif menu.contextMenuMode == "trade" then
		if uitable == menu.contextshiptable then
			if rowdata then
				menu.selectedTradeWare = rowdata
				if (not menu.skipTradeRowChange) and (not menu.tradeSliderLock) then
					menu.queuetradecontextrefresh = true
				end
				menu.skipTradeRowChange = nil
			end
		end
	end

	if (menu.infoTableMode == "info") then
		if uitable == menu.infoTable then
			if menu.infoMode == "objectinfo" then
				menu.setrow = row
				if type(rowdata) == "table" and rowdata[2] == "info_deploy" then
					if not rowdata[4] then
						if GetMacroData(rowdata[3], "islasertower") and (menu.infomacrostolaunch.lasertower ~= rowdata[3]) then
							menu.infomacrostolaunch.lasertower = rowdata[3]
							menu.infomacrostolaunch.mine = nil
							menu.infomacrostolaunch.navbeacon = nil
							menu.infomacrostolaunch.resourceprobe = nil
							menu.infomacrostolaunch.satellite = nil
							menu.over = true
						elseif IsMacroClass(rowdata[3], "mine") and (menu.infomacrostolaunch.mine ~= rowdata[3]) then
							menu.infomacrostolaunch.mine = rowdata[3]
							menu.infomacrostolaunch.navbeacon = nil
							menu.infomacrostolaunch.resourceprobe = nil
							menu.infomacrostolaunch.satellite = nil
							menu.infomacrostolaunch.lasertower = nil
							menu.over = true
						elseif IsMacroClass(rowdata[3], "navbeacon") and (menu.infomacrostolaunch.navbeacon ~= rowdata[3]) then
							menu.infomacrostolaunch.navbeacon = rowdata[3]
							menu.infomacrostolaunch.resourceprobe = nil
							menu.infomacrostolaunch.satellite = nil
							menu.infomacrostolaunch.lasertower = nil
							menu.infomacrostolaunch.mine = nil
							menu.over = true
						elseif IsMacroClass(rowdata[3], "resourceprobe") and (menu.infomacrostolaunch.resourceprobe ~= rowdata[3]) then
							menu.infomacrostolaunch.resourceprobe = rowdata[3]
							menu.infomacrostolaunch.satellite = nil
							menu.infomacrostolaunch.lasertower = nil
							menu.infomacrostolaunch.mine = nil
							menu.infomacrostolaunch.navbeacon = nil
							menu.over = true
						elseif IsMacroClass(rowdata[3], "satellite") and (menu.infomacrostolaunch.satellite ~= rowdata[3]) then
							menu.infomacrostolaunch.satellite = rowdata[3]
							menu.infomacrostolaunch.lasertower = nil
							menu.infomacrostolaunch.mine = nil
							menu.infomacrostolaunch.navbeacon = nil
							menu.infomacrostolaunch.resourceprobe = nil
							menu.over = true
						end
					end
				elseif (rowdata ~= "info_launchmine") and (rowdata ~= "info_launchnavbeacon") and (rowdata ~= "info_launchresourceprobe") and (rowdata ~= "info_launchsatellite") then
					if menu.infomacrostolaunch.mine or menu.infomacrostolaunch.navbeacon or menu.infomacrostolaunch.resourceprobe or menu.infomacrostolaunch.satellite then
						menu.infomacrostolaunch = { mine = nil, navbeacon = nil, resourceprobe = nil, satellite = nil }
						menu.over = true
					end
				end
			elseif (menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced") then
				menu.selectedorder = rowdata
				menu.selectedorder.object = menu.infoSubmenuObject
			end
		end
	elseif (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				local convertedComponent = ConvertIDTo64Bit(rowdata[2])

				if (menu.contextMenuData and (convertedComponent ~= menu.contextMenuData.component)) or (menu.interactMenuComponent ~= convertedComponent) then
					if modified ~= "ctrl" then
						menu.closeContextMenu()
					end
				end
			end
			menu.updateSelectedComponents(modified)
			menu.setSelectedMapComponents()
		end
	elseif menu.infoTableMode == "plots" then
		if menu.plotDoNotUpdate then
			menu.plotDoNotUpdate = nil
		elseif menu.table_plotlist and (uitable == menu.table_plotlist.id) then
			menu.settoprow = GetTopRow(menu.table_plotlist)
			menu.setrow = Helper.currentTableRow[menu.table_plotlist]
			if not rowdata then
				print("rowdata empty. table id: " .. tostring(uitable) .. ", row: " .. tostring(row) .. ", rowdata: " .. tostring(rowdata))
			elseif input == "mouse" then
				--print("table id: " .. tostring(uitable) .. ", row: " .. tostring(row) .. ", rowdata: " .. tostring(rowdata) .. ", menu.table_plotlist.id: " .. tostring(menu.table_plotlist.id) .. ", uitable == menu.table_plotlist.id? " .. tostring(uitable == menu.table_plotlist.id))
				if rowdata == "plots_new" then
					menu.updatePlotData("plots_new", true)
				else
					C.SetFocusMapComponent(menu.holomap, rowdata, true)
				end
				menu.updatePlotData(rowdata)
			end
		end
	elseif (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				local missionid = ConvertStringTo64Bit(rowdata[1])
				menu.missionModeCurrent = rowdata[1]
				C.SetMapRenderMissionGuidance(menu.holomap, missionid)
				if menu.missionDoNotUpdate then
					menu.missionDoNotUpdate = nil
				elseif input == "mouse" then
					if menu.contextMenuData and menu.contextMenuData.missionid and (menu.contextMenuData.missionid == missionid) then
						menu.closeContextMenu()
						menu.missionModeContext = nil
					else
						menu.closeContextMenu()
						menu.showMissionContext(missionid)
						menu.missionModeContext = true
					end
				end
			elseif type(rowdata) == "string" then
				menu.missionModeCurrent = rowdata
				C.SetMapRenderMissionGuidance(menu.holomap, 0)
				if menu.missionDoNotUpdate then
					menu.missionDoNotUpdate = nil
				elseif input == "mouse" then
					menu.closeContextMenu()
					menu.missionModeContext = nil
				end
			end
		end
	end
end

function menu.onRowChangedSound(row, rowdata, uitable, layer, modified, input)
	if (menu.frames[layer] == GetActiveFrame()) and (uitable == GetInteractiveObject(menu.frames[layer])) then
		if (uitable ~= menu.infoTable) or (not menu.sound_rowChangedRow) or (menu.sound_rowChangedRow ~= row) then
			PlaySound((uitable == menu.sideBar) and "ui_positive_hover_side" or "ui_positive_hover_normal")
		end
	end
	if uitable == menu.infoTable then
		menu.sound_rowChangedRow = row
	end
end

function menu.setSelectedMapComponents()
	if menu.holomap and (menu.holomap ~= 0) then
		local numcomponents = 0
		for _, _ in pairs(menu.selectedcomponents) do
			numcomponents = numcomponents + 1
		end
		local components = ffi.new("UniverseID[?]", numcomponents)
		local i = 0
		for id, _ in pairs(menu.selectedcomponents) do
			components[i] = ConvertStringTo64Bit(id)
			i = i + 1
		end
		C.SetSelectedMapComponents(menu.holomap, components, numcomponents)
	end
end

function menu.onSelectElement(uitable, modified, row, isdblclick, input)
	local rowdata = Helper.getCurrentRowData(menu, uitable)
	if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				local convertedRowComponent = ConvertIDTo64Bit(rowdata[2])
				menu.setSelectedMapComponents()

				local isonlineobject, isplayerowned = GetComponentData(rowdata[2], "isonlineobject", "isplayerowned")
				if (isdblclick or (input ~= "mouse")) and (convertedRowComponent ~= nil) and (ffi.string(C.GetComponentClass(convertedRowComponent)) ~= "sector") and (not (isonlineobject and isplayerowned)) then
					C.SetFocusMapComponent(menu.holomap, convertedRowComponent, true)
				end
			end
		end
	elseif menu.infoTableMode == "plots" then
		if menu.plotDoNotUpdate then
			menu.plotDoNotUpdate = nil
		elseif menu.table_plotlist and (uitable == menu.table_plotlist.id) then
			if rowdata == "plots_new" then
				menu.updatePlotData("plots_new", true)
			else
				C.SetFocusMapComponent(menu.holomap, rowdata, true)
			end
			menu.updatePlotData(rowdata)
		end
	elseif (menu.infoTableMode == "missionoffer") or (menu.infoTableMode == "mission") then
		if uitable == menu.infoTable then
			if type(rowdata) == "table" then
				menu.missionModeCurrent = rowdata[1]
				local missionid = ConvertStringTo64Bit(rowdata[1])
				if menu.contextMenuData and menu.contextMenuData.missionid and (menu.contextMenuData.missionid == missionid) then
					menu.closeContextMenu()
					menu.missionModeContext = nil
				else
					menu.closeContextMenu()
					menu.showMissionContext(missionid)
					menu.missionModeContext = true
				end
			elseif type(rowdata) == "string" then
				menu.missionModeCurrent = rowdata
				if menu.missionDoNotUpdate then
					menu.missionDoNotUpdate = nil
				else
					menu.closeContextMenu()
					menu.missionModeContext = nil
				end
			end
		end
	elseif menu.infoTableMode == "info" then
		if uitable == menu.infoTable then
			if menu.infoMode == "objectinfo" then
				if rowdata == "info_name" then
					menu.infoeditname = true
					menu.refreshInfoFrame()
				end
			end
		end
	end
end

-- rendertarget selections
function menu.onRenderTargetSelect(modified)
	local offset = table.pack(GetLocalMousePosition())
	-- Check if the mouse button was down less than 0.5 seconds and the mouse was moved more than a distance of 5px
	if (not menu.leftdown) or ((menu.leftdown.time + 0.5 > getElapsedTime()) and not Helper.comparePositions(menu.leftdown.position, offset, 5)) then
		if menu.mode == "selectbuildlocation" then
			local station = 0
			if menu.plotData.active then
				local offset = ffi.new("UIPosRot")
				local offsetvalid = C.GetBuildMapStationLocation(menu.holomap, offset)
				if offsetvalid then
					AddUITriggeredEvent(menu.name, "plotplaced")
					station = C.ReserveBuildPlot(menu.plotData.sector, "player", menu.plotData.set, offset, menu.plotData.size.x * 1000, menu.plotData.size.y * 1000, menu.plotData.size.z * 1000)
					C.ClearMapBuildPlot(menu.holomap)
					menu.plotData.active = nil
				end
			else
				local pickedcomponent = C.GetPickedMapComponent(menu.holomap)
				local pickedcomponentclass = ffi.string(C.GetRealComponentClass(pickedcomponent))
				if (pickedcomponentclass == "station") and GetComponentData(ConvertStringToLuaID(tostring(pickedcomponent)), "isplayerowned") then
					station = pickedcomponent
				end
			end

			if station ~= 0 then
				for _, row in ipairs(menu.table_plotlist.rows) do
					if row.rowdata == station then
						menu.setplotrow = row.index
						menu.setplottoprow = (row.index - 12) > 1 and (row.index - 12) or 1
						break
					end
				end

				menu.updatePlotData(station, true)
				menu.refreshInfoFrame()
			end
		elseif menu.mode == "orderparam_position" then
			local offset = ffi.new("UIPosRot")
			local offsetcomponent = C.GetMapPositionOnEcliptic(menu.holomap, offset)
			if offsetcomponent ~= 0 then
				local class = ffi.string(C.GetComponentClass(offsetcomponent))
				if (not menu.modeparam[2].inputparams.class) or (class == menu.modeparam[2].inputparams.class) then
					menu.modeparam[1]({ConvertStringToLuaID(tostring(offsetcomponent)), {offset.x, offset.y, offset.z}})
				elseif (menu.modeparam[2].inputparams.class == "zone") and (class == "sector") then
					offsetcomponent = C.GetZoneAt(offsetcomponent, offset)
					menu.modeparam[1]({ConvertStringToLuaID(tostring(offsetcomponent)), {offset.x, offset.y, offset.z}})
				end
			end
		elseif menu.mode == "orderparam_selectenemies" then
			menu.mode = nil
			menu.modeparam = {}
			SetMouseCursorOverride("default")
			menu.removeMouseCursorOverride(3)
		elseif menu.mode == "boardingcontext" then

		else
			local colspan = 1
			if menu.editboxHeight > Helper.scaleY(config.mapRowHeight) then
				colspan = 2
			end
			Helper.confirmEditBoxInput(menu.searchField, 1, colspan + 2)
			menu.closeContextMenu()
			local pickedcomponent = C.GetPickedMapComponent(menu.holomap)
			local pickedorder = ffi.new("Order")
			local isintermediate = ffi.new("bool[1]", 0)
			local pickedordercomponent = C.GetPickedMapOrder(menu.holomap, pickedorder, isintermediate)
			local pickedcomponentclass = ffi.string(C.GetComponentClass(pickedcomponent))
			local ispickedcomponentship = C.IsComponentClass(pickedcomponent, "ship") and not C.IsUnit(pickedcomponent)
			local pickedtradeoffer = C.GetPickedMapTradeOffer(menu.holomap)
			if pickedordercomponent ~= 0 then
				local sectorcontext = C.GetContextByClass(pickedordercomponent, "sector", false)
				if sectorcontext ~= menu.currentsector then
					menu.currentsector = sectorcontext
				end

				menu.createInfoFrame()
			elseif pickedtradeoffer ~= 0 then
				local tradeid = ConvertStringToLuaID(tostring(pickedtradeoffer))
				local tradedata = GetTradeData(tradeid)
				if tradedata.ware then
					local setting = config.layersettings["layer_trade"][1]
					local rawwarelist = menu.getFilterOption(setting.id) or {}
					local found = false
					for i, ware in ipairs(rawwarelist) do
						if ware == tradedata.ware then
							found = i
							break
						end
					end
					AddUITriggeredEvent(menu.name, "filterwareselected", tradedata.isbuyoffer and "buyoffer" or "selloffer")
					if found then
						menu.removeFilterOption(setting, setting.id, found)
					else
						menu.setFilterOption("layer_trade", setting, setting.id, tradedata.ware)
					end
				end
			elseif pickedcomponent ~= 0 then
				if (not menu.sound_selectedelement) or (menu.sound_selectedelement ~= pickedcomponent) or (modified == "ctrl") or (modified == "shift") then
					local isselected = menu.isSelectedComponent(pickedcomponent)
					if (not isselected) and (modified == "shift") then
						PlaySound("ui_positive_multiselect")
					elseif modified == "ctrl" then
						if isselected then
							PlaySound("ui_positive_deselect")
						else
							PlaySound("ui_positive_multiselect")
						end
					elseif (pickedcomponentclass == "sector") then
						PlaySound("ui_positive_deselect")
					else
						PlaySound("ui_positive_select")
					end
				end
				menu.sound_selectedelement = pickedcomponent
				if menu.infoTableMode == "info" then
					if menu.infoMode == "objectinfo" then
						menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(pickedcomponent))
						menu.refreshInfoFrame()
					end
				end

				if pickedcomponentclass == "sector" then
					-- NB: Global standing orders, ship standing orders, and orderqueue all require a controllable to be selected so ignore clicking on sector in those cases.
					if menu.mode ~= "info" or not menu.infoMode or menu.infoMode == "objectinfo" then
						AddUITriggeredEvent(menu.name, "selection_reset")
						menu.clearSelectedComponents()
						if pickedcomponent ~= menu.currentsector then
							menu.currentsector = pickedcomponent
							menu.updateMapAndInfoFrame()
						end
					end
				elseif (#menu.searchtext == 0) or Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.FilterComponentByText(pickedcomponent, numtexts, texts, true) end) then
					local isconstruction = IsComponentConstruction(ConvertStringTo64Bit(tostring(pickedcomponent)))
					if (C.IsComponentOperational(pickedcomponent) and (pickedcomponentclass ~= "player") and (pickedcomponentclass ~= "highwayentrygate") and (pickedcomponentclass ~= "collectablewares") and (not menu.createInfoFrameRunning)) or
						(pickedcomponentclass == "gate") or (pickedcomponentclass == "asteroid") or isconstruction
					then
						local sectorcontext = C.GetContextByClass(pickedcomponent, "sector", false)
						if sectorcontext ~= menu.currentsector then
							menu.currentsector = sectorcontext
						end
						
						if modified == "ctrl" then
							menu.toggleSelectedComponent(pickedcomponent)
						else
							if pickedcomponentclass == "station" then
								AddUITriggeredEvent(menu.name, "selection_station")
							end
							menu.addSelectedComponent(pickedcomponent, not modified)
						end

						if (not isconstruction) and (menu.infoTableMode == "info") then
							if (menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced") or (menu.infoMode == "factionresponses") or (menu.infoMode == "controllableresponses") then
								if not modified then
									menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(pickedcomponent))
									menu.refreshInfoFrame()
								end
							end
						end
					end
				end
			else
				if menu.mode ~= "info" or not menu.infoMode or menu.infoMode == "objectinfo" then
					AddUITriggeredEvent(menu.name, "selection_reset")
					menu.clearSelectedComponents()
				end
			end
		end
	end
	menu.leftdown = nil
end

-- rendertarget doubleclick
function menu.onRenderTargetDoubleClick(modified)
	local pickedcomponent = C.GetPickedMapComponent(menu.holomap)
	if pickedcomponent ~= 0 then
		if not C.IsComponentClass(pickedcomponent, "sector") then
			if modified == "shift" then 
				C.AddSimilarMapComponentsToSelection(menu.holomap, pickedcomponent)
			elseif modified ~= "ctrl" then 
				C.SelectSimilarMapComponents(menu.holomap, pickedcomponent)
				C.SetFocusMapComponent(menu.holomap, pickedcomponent, true)
			end

			local components = {}
			Helper.ffiVLA(components, "UniverseID", C.GetNumMapSelectedComponents, C.GetMapSelectedComponents, menu.holomap)
			if #components > 0 then
				menu.addSelectedComponents(components)
			else
				menu.clearSelectedComponents()
			end
		end
	end
end

-- rendertarget mouse input helper
function menu.onRenderTargetMouseDown(modified)
	if menu.mode ~= "boardingcontext" then
		menu.closeContextMenu()
	end
	menu.leftdown = { time = getElapsedTime(), dyntime = getElapsedTime(), position = table.pack(GetLocalMousePosition()), dynpos = table.pack(GetLocalMousePosition()) }

	local pickedorder = ffi.new("Order")
	local buf = ffi.new("bool[1]", 0)
	local pickedordercomponent = C.GetPickedMapOrder(menu.holomap, pickedorder, buf)
	local isintermediate = buf[0]
	if pickedordercomponent ~= 0 then
		menu.addSelectedComponent(pickedordercomponent, true)
		local orderdef = ffi.new("OrderDefinition")
		if C.GetOrderDefinition(orderdef, pickedorder.orderdef) then
			if isintermediate or (ffi.string(orderdef.id) == "MoveWait") then
				menu.orderdrag = { component = pickedordercomponent, order = pickedorder, orderdef = orderdef, isintermediate = isintermediate, isclick = true }
			end
		end

		if menu.infoTableMode == "info" then
			if (menu.infoMode == "orderqueue") or (menu.infoMode == "orderqueue_advanced") or (menu.infoMode == "factionresponses") or (menu.infoMode == "controllableresponses") then
				if not modified then
					menu.infoSubmenuObject = ConvertStringTo64Bit(tostring(pickedordercomponent))
					menu.refreshInfoFrame()
				end
			end
		end
	else
		if modified == "shift" then
			C.StartMapBoxSelect(menu.holomap, menu.mode == "orderparam_selectenemies")
		else
			C.StartPanMap(menu.holomap)
			menu.panningmap = { isclick = true }
		end
	end
end

function menu.onRenderTargetMouseUp(modified)
	if menu.orderdrag then
		if not menu.orderdrag.isclick then
			if menu.orderdrag.component ~= C.GetPlayerOccupiedShipID() then
				local posrot = ffi.new("UIPosRot")
				local posrotcomponent = C.GetMapPositionOnEcliptic(menu.holomap, posrot)
				if posrotcomponent ~= 0 then
					SetOrderParam(ConvertStringToLuaID(tostring(menu.orderdrag.component)), tonumber(menu.orderdrag.order.queueidx), 1, nil, { ConvertStringToLuaID(tostring(posrotcomponent)), {posrot.x, posrot.y, posrot.z} })
				end
			end
		end
		menu.orderdrag = nil
	elseif menu.panningmap then
		C.StopPanMap(menu.holomap)
		if menu.sound_panmap then
			StopPlayingSound(menu.sound_panmap)
			menu.sound_panmap = nil
		end
		if menu.infoTableMode == "objectlist" then
			if not menu.panningmap.isclick then
				menu.refreshInfoFrame()
			end
		elseif menu.infoTableMode == "plots" and menu.plotData.component then
			if not menu.panningmap.isclick then
				-- update plot position and price
				menu.updatePlotData()
			end
		end
		menu.panningmap = nil
	else
		C.StopMapBoxSelect(menu.holomap)
		local components = {}
		Helper.ffiVLA(components, "UniverseID", C.GetNumMapSelectedComponents, C.GetMapSelectedComponents, menu.holomap)
		if #components > 0 then
			menu.sound_selectedelement = components[i]
			PlaySound("ui_positive_multiselect")
		end
		if menu.mode == "orderparam_selectenemies" then
			for i = #components, 1, -1 do
				local component = components[i]
				if component == menu.modeparam[1] then
					table.remove(components, i)
				elseif (not C.IsComponentClass(component, "ship")) and (not C.IsComponentClass(component, "station")) then
					table.remove(components, i)
				end
			end
			for id, _ in pairs(menu.selectedcomponents) do
				local selectedcomponent = ConvertStringTo64Bit(id)
				if selectedcomponent ~= C.GetPlayerOccupiedShipID() then
					if GetComponentData(selectedcomponent, "isplayerowned") then
						menu.orderAttackMultiple(selectedcomponent, menu.modeparam[1], components, menu.modeparam[2])
					end
				end
			end
			menu.mode = nil
			menu.modeparam = {}
			menu.removeMouseCursorOverride(3)
			menu.refreshInfoFrame()
		else
			if #components > 0 then
				menu.addSelectedComponents(components, false)
			end
		end
	end
end

function menu.onRenderTargetMiddleMouseDown()
	-- nothing yet
end

function menu.onRenderTargetMiddleMouseUp()

end

function menu.onRenderTargetRightMouseDown()
	if menu.mode ~= "boardingcontext" then
		menu.closeContextMenu()
	end
	menu.rightdown = { time = getElapsedTime(), dyntime = getElapsedTime(), position = table.pack(GetLocalMousePosition()) , dynpos = table.pack(GetLocalMousePosition()) }

	C.StartRotateMap(menu.holomap)
	menu.rotatingmap = true
end

function menu.onRenderTargetRightMouseUp(modified)
	local offset = table.pack(GetLocalMousePosition())

	-- Check if the mouse was moved more than a distance of 5px
	if (not Helper.comparePositions(menu.rightdown.position, offset, 5)) and (not menu.rightdown.wasmoved) and menu.mode ~= "boardingcontext" then
		if (menu.mode == "orderparam_position") then
			menu.resetOrderParamMode(menu.modeparam[4])
		elseif menu.mode == "selectbuildlocation" then
			if menu.plotData.active then
				C.ClearMapBuildPlot(menu.holomap)
				menu.plotData.active = nil
			end
		elseif menu.mode == "orderparam_selectenemies" then
			menu.mode = nil
			menu.modeparam = {}
			menu.removeMouseCursorOverride(3)
		else
			local pickedcomponent = C.GetPickedMapComponent(menu.holomap)
			local pickedorder = ffi.new("Order")
			local isintermediate = ffi.new("bool[1]", 0)
			local pickedordercomponent = C.GetPickedMapOrder(menu.holomap, pickedorder, isintermediate)
			local pickedtradeoffer = C.GetPickedMapTradeOffer(menu.holomap)
			local pickedmissionoffer = C.GetPickedMapMissionOffer(menu.holomap)
			local pickedmission = C.GetPickedMapMission(menu.holomap)

			local posrot = ffi.new("UIPosRot")
			local posrotcomponent = C.GetMapPositionOnEcliptic(menu.holomap, posrot)

			if pickedordercomponent ~= 0 then
				if menu.mode == "hire" then
					PlaySound("ui_menu_interact_btn_selectinvalid_core")
				else
					menu.interactMenuComponent = pickedcomponent
					Helper.openInteractMenu(menu, { component = pickedordercomponent, order = pickedorder, offsetcomponent = posrotcomponent, offset = posrot, playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true) })
				end
			elseif pickedmission ~= 0 then
				if menu.mode == "hire" then
					PlaySound("ui_menu_interact_btn_selectinvalid_core")
				else
					Helper.openInteractMenu(menu, { mission = ConvertStringTo64Bit(tostring(pickedmission)), playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true) })
				end
			elseif pickedtradeoffer ~= 0 then
				local tradeid = ConvertStringToLuaID(tostring(pickedtradeoffer))
				local tradedata = GetTradeData(tradeid)

				local tradesubscription = GetComponentData(tradedata.station, "tradesubscription")
				if tradesubscription and (tradedata.amount > 0) then
					menu.contextMenuMode = "trade"
					menu.contextMenuData = { component = ConvertIDTo64Bit(tradedata.station), orders = {}, tradeid = tradeid }

					local numwarerows, numinforows = menu.initTradeContextData()
					menu.updateTradeContextDimensions(numwarerows, numinforows)
					AddUITriggeredEvent(menu.name, "pickedtradeoffer", tradedata.isbuyoffer and "buyoffer" or "selloffer")

					local width = menu.tradeContext.width
					local height = menu.tradeContext.shipheight + menu.tradeContext.buttonheight + 1 * Helper.borderSize

					local offsetx = offset[1] + Helper.viewWidth / 2
					if offsetx + width > Helper.viewWidth then
						offsetx = Helper.viewWidth - width - config.contextBorder
					end
					local offsety = Helper.viewHeight / 2 - offset[2]
					if offsety + height > Helper.viewHeight then
						offsety = Helper.viewHeight - height - config.contextBorder
					end

					menu.createContextFrame(width, height, offsetx, offsety)
				else
					menu.interactMenuComponent = tradedata.station

					local missions = {}
					Helper.ffiVLA(missions, "MissionID", C.GetNumMapComponentMissions, C.GetMapComponentMissions, menu.holomap, ConvertIDTo64Bit(tradedata.station))

					Helper.openInteractMenu(menu, { component = tradedata.station, offsetcomponent = posrotcomponent, offset = posrot, playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true), componentmissions = missions })
				end
			elseif pickedmissionoffer ~= 0 then
				menu.contextMenuMode = "mission"
				local width = 400
				local height = menu.prepareMissionContextData(nil, tostring(pickedmissionoffer), width)

				local offsetx = offset[1] + Helper.viewWidth / 2
				local offsety = Helper.viewHeight / 2 - offset[2]

				if offsetx + width > Helper.viewWidth then
					offsetx = Helper.viewWidth - width - config.contextBorder
				end
				if offsety + height > Helper.viewHeight then
					offsety = Helper.viewHeight - height - config.contextBorder
				end

				menu.createContextFrame(width, height, offsetx, offsety)
			elseif pickedcomponent ~= 0 then
				local convertedComponent = ConvertStringTo64Bit(tostring(pickedcomponent))
				if modified ~= "ctrl" then
					if menu.mode == "hire" then
						if GetComponentData(convertedComponent, "isplayerowned") and C.IsComponentClass(convertedComponent, "controllable") then
							menu.contextMenuData = { component = convertedComponent, xoffset = offset[1] + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - offset[2] }
							menu.contextMenuMode = "select"
							menu.createContextFrame(menu.selectWidth)
						end
					elseif menu.mode == "selectCV" then
						if C.IsComponentClass(pickedcomponent, "ship") and GetComponentData(convertedComponent, "primarypurpose") == "build" then
							menu.contextMenuData = { component = convertedComponent, xoffset = offset[1] + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - offset[2] }
							menu.contextMenuMode = "select"
							menu.createContextFrame(menu.selectWidth)
						end
					elseif menu.mode == "orderparam_object" then
						if C.IsComponentClass(pickedcomponent, "sector") then
							menu.resetOrderParamMode(menu.modeparam[4])
						else
							if menu.checkForOrderParamObject(convertedComponent) then
								menu.contextMenuData = { component = convertedComponent, xoffset = offset[1] + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - offset[2]  }
								menu.contextMenuMode = "select"
								menu.createContextFrame(menu.selectWidth)
							end
						end
					else
						menu.interactMenuComponent = pickedcomponent

						local missions = {}
						Helper.ffiVLA(missions, "MissionID", C.GetNumMapComponentMissions, C.GetMapComponentMissions, menu.holomap, pickedcomponent)

						Helper.openInteractMenu(menu, { component = pickedcomponent, offsetcomponent = posrotcomponent, offset = posrot, playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true), componentmissions = missions })
					end
				else
					local offsetx = offset[1] + Helper.viewWidth / 2
					local offsety = Helper.viewHeight / 2 - offset[2]

					menu.defaultInteraction(pickedcomponent, posrot, posrotcomponent ~= 0, offsetx, offsety)
				end
			end
		end
	end
	menu.rightdown = nil
	if menu.rotatingmap then
		C.StopRotateMap(menu.holomap)
		if menu.sound_rotatemap and menu.sound_rotatemap.sound then
			StopPlayingSound(menu.sound_rotatemap.sound)
			menu.sound_rotatemap = nil
		end
		menu.rotatingmap = nil
		if menu.infoTableMode == "objectlist" then
			menu.refreshInfoFrame()
		end
	end
end

function menu.prepareMissionContextData(missionid, missionofferid, width)
	if missionid then
		local missionid64 = ConvertStringTo64Bit(missionid)
		local missiondetails = C.GetMissionIDDetails(missionid64)
		menu.contextMenuData = {
			isoffer = false,
			missionid = missionid64,
			name = ffi.string(missiondetails.missionName),
			rawdescription = ffi.string(missiondetails.missionDescription),
			difficulty = missiondetails.difficulty,
			rewardmoney = tonumber(missiondetails.reward) / 100,
			rewardtext = ffi.string(missiondetails.rewardText),
			activebriefingstep = missiondetails.activeBriefingStep,
			briefingmissions = {},
			timeout = (missiondetails.duration and missiondetails.duration > 0) and missiondetails.duration or (missiondetails.timeLeft or -1),
			abortable = missiondetails.abortable,
			offeractor = nil,
			expired = false,
			threadtype = ffi.string(missiondetails.threadType),
			threadMissionID = ConvertStringTo64Bit(tostring(missiondetails.threadMissionID)),
			type = ffi.string(missiondetails.mainType),
		}
		menu.contextMenuData.briefingobjectives = {}
		for i = 1, tonumber(missiondetails.numBriefingObjectives) do
			local objective = C.GetMissionObjectiveStep(missionid64, i)
			table.insert(menu.contextMenuData.briefingobjectives, { step = objective.step, text = ffi.string(objective.text) })
		end
		menu.contextMenuData.subMissions = {}
		local buf = {}
		Helper.ffiVLA(buf, "MissionID", C.GetNumMissionThreadSubMissions, C.GetMissionThreadSubMissions, missionid64)
		for _, submission in ipairs(buf) do
			local submissionEntry = menu.getMissionIDInfoHelper(submission)
			table.insert(menu.contextMenuData.subMissions, submissionEntry)
		end
		menu.contextMenuData.description = GetTextLines(menu.contextMenuData.rawdescription, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width - 2 * Helper.scaleX(Helper.standardTextOffsetx))
		local faction = ffi.string(missiondetails.faction)
		if faction ~= "" then
			local factionDetails = C.GetFactionDetails(faction)
			local factionName = ffi.string(factionDetails.factionName)
			if factionName ~= "" then
				menu.contextMenuData.factionName = factionName
			end
		end
	elseif missionofferid then
		local missionofferid64 = ConvertStringTo64Bit(missionofferid)
		local name, description, difficulty, threadtype, maintype, subtype, subtypename, faction, rewardmoney, rewardtext, briefingobjectives, activebriefingstep, briefingmissions, oppfaction, licence, missiontime, duration, abortable, guidancedisabled, associatedcomponent, alertLevel, offeractor, offercomponent = GetMissionOfferDetails(ConvertStringToLuaID(missionofferid))
		menu.contextMenuData = {
			isoffer = true,
			missionid = missionofferid64,
			name = name,
			rawdescription = description,
			difficulty = difficulty,
			rewardmoney = rewardmoney,
			rewardtext = rewardtext,
			briefingobjectives = briefingobjectives,
			activebriefingstep = activebriefingstep,
			briefingmissions = briefingmissions,
			timeout = duration or -1,
			abortable = nil,
			offeractor = offeractor,
			expired = false,
			threadtype = threadtype,
			subMissions = {},
			type = maintype,
		}
		menu.contextMenuData.description = GetTextLines(menu.contextMenuData.rawdescription, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), width - 2 * Helper.scaleX(Helper.standardTextOffsetx))
		if faction then
			local factionDetails = C.GetFactionDetails(faction)
			local factionName = ffi.string(factionDetails.factionName)
			if factionName ~= "" then
				menu.contextMenuData.factionName = factionName
			end
		end
	end

	local minwidth = width - Helper.scrollbarWidth

	-- restrict number of visible lines for both description table and objectives table - if there are more lines, we need a scrollbar
	menu.contextMenuData.descriptionLines = #menu.contextMenuData.description
	menu.contextMenuData.descriptionWidth = width
	if menu.contextMenuData.descriptionLines > 10 then
		menu.contextMenuData.description = GetTextLines(menu.contextMenuData.rawdescription, Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), minwidth - 2 * Helper.scaleX(Helper.standardTextOffsetx))
		menu.contextMenuData.descriptionLines = 10
		menu.contextMenuData.descriptionWidth = minwidth
	end
	if menu.contextMenuData.threadtype ~= "" then
		if menu.contextMenuData.isoffer then
			menu.contextMenuData.objectiveLines = math.max(#menu.contextMenuData.briefingmissions, 1)
		else
			menu.contextMenuData.objectiveLines = math.max(#menu.contextMenuData.subMissions, 1)
		end
	else
		menu.contextMenuData.objectiveLines = math.max(#menu.contextMenuData.briefingobjectives, 1)
	end
	menu.contextMenuData.objectiveWidth = width
	if menu.contextMenuData.objectiveLines > 10 then
		menu.contextMenuData.objectiveLines = 10
		menu.contextMenuData.objectiveWidth = minwidth
	end
	menu.contextMenuData.bottomLines = 3 + (menu.contextMenuData.factionName and 1 or 0) + ((menu.contextMenuData.difficulty ~= 0) and 1 or 0) + (menu.contextMenuData.isoffer and 0 or 1)

	local tablespacing = Helper.standardTextHeight
	local headerHeight = Helper.scaleY(Helper.headerRow1Offsety) + Helper.scaleY(Helper.headerRow1Height - Helper.headerRow1Offsety)
	local textHeight = math.ceil(C.GetTextHeight(" ", Helper.standardFont, Helper.scaleFont(Helper.standardFont, Helper.standardFontSize), 0))
	menu.contextMenuData.descriptionYOffset = Helper.borderSize
	menu.contextMenuData.descriptionHeight = headerHeight + menu.contextMenuData.descriptionLines * (textHeight + Helper.borderSize)
	menu.contextMenuData.objectiveYOffset = menu.contextMenuData.descriptionYOffset + menu.contextMenuData.descriptionHeight + tablespacing
	menu.contextMenuData.objectiveHeight = headerHeight + menu.contextMenuData.objectiveLines * (textHeight + Helper.borderSize)
	menu.contextMenuData.bottomYOffset = menu.contextMenuData.objectiveYOffset + menu.contextMenuData.objectiveHeight + tablespacing
	menu.contextMenuData.bottomHeight = menu.contextMenuData.bottomLines * (textHeight + Helper.borderSize)

	return menu.contextMenuData.bottomYOffset + menu.contextMenuData.bottomHeight + Helper.borderSize
end

function menu.showMissionContext(missionid)
	menu.contextMenuMode = "mission"
	local width = 400
	local height
	if menu.infoTableMode == "mission" then
		height = menu.prepareMissionContextData(missionid, nil, width)
	else
		height = menu.prepareMissionContextData(nil, missionid, width)
	end

	local offsetx = menu.infoTableOffsetX + menu.infoTableWidth + Helper.borderSize + config.contextBorder
	local offsety = menu.infoTableOffsetY

	menu.createContextFrame(width, height, offsetx, offsety)
end

function menu.getSelectedPlayerShips(invert)
	local playerships = {}

	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		if (GetComponentData(selectedcomponent, "isplayerowned") == (not invert)) and C.IsComponentClass(selectedcomponent, "ship") then
			table.insert(playerships, selectedcomponent)
		end
	end

	return playerships
end

function menu.onRenderTargetScrollDown()
	C.ZoomMap(menu.holomap, 1)
	if not menu.lastzoom or menu.lastzoom.dir ~= "out" or menu.lastzoom.time + 1.0 < C.GetCurrentGameTime() then
		menu.lastzoom = { time = getElapsedTime(), dir = "out" }
	end
	menu.lastscrolltime = getElapsedTime()
end

function menu.onRenderTargetScrollUp()
	C.ZoomMap(menu.holomap, -1)
	if not menu.lastzoom or menu.lastzoom.dir ~= "in" or menu.lastzoom.time + 1.0 < C.GetCurrentGameTime() then
		menu.lastzoom = { time = getElapsedTime(), dir = "in" }
	end
	menu.lastscrolltime = getElapsedTime()
end

-- button mouse helper

function menu.onButtonOverSound(uitable, row, col, button, input)
	if not menu.sound_selectedelement or button ~= menu.sound_selectedelement then
		if input == "mouse" then
			if (not menu.sound_buttonOverLock) then
				PlaySound((uitable == menu.sideBar) and "ui_positive_hover_side" or "ui_positive_hover_normal")
				menu.sound_buttonOverLock = true
			end
		end
	end
	menu.sound_selectedelement = button
end

function menu.onButtonDown()
	menu.noupdate = true
	PlaySound("ui_positive_click")
end

function menu.onButtonUp()
	menu.noupdate = false
	--PlaySound("ui_positive_click")
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

function menu.onTableScrollBarDown()
	menu.noupdate = true
	PlaySound("ui_sbar_table_down")
end

function menu.onTableScrollBarUp()
	menu.noupdate = false
end

function menu.onEditboxRightMouseClick()
	if (menu.mode == "orderparam_position") then
		menu.resetOrderParamMode(menu.modeparam[4])
	end
end

function menu.onTableRightMouseClick(uitable, row, posx, posy)
	if (menu.mode == "orderparam_position") then
		menu.resetOrderParamMode(menu.modeparam[4])
	else
		if row > (menu.numFixedRows or 0) then
			local rowdata = menu.rowDataMap[uitable] and menu.rowDataMap[uitable][row]
			if (menu.infoTableMode == "objectlist") or (menu.infoTableMode == "propertyowned") then
				if uitable == menu.infoTable then
					if type(rowdata) == "table" then
						local convertedRowComponent = ConvertIDTo64Bit(rowdata[2])
						if convertedRowComponent ~= 0 then
							local x, y = GetLocalMousePosition()
							if menu.mode == "hire" then
								if GetComponentData(convertedRowComponent, "isplayerowned") and C.IsComponentClass(convertedRowComponent, "controllable") then
									menu.contextMenuData = { component = convertedRowComponent, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
									menu.contextMenuMode = "select"
									menu.createContextFrame(menu.selectWidth)
								end
							elseif menu.mode == "selectCV" then
								menu.contextMenuData = { component = convertedRowComponent, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
								menu.contextMenuMode = "select"
								menu.createContextFrame(menu.selectWidth)
							elseif menu.mode == "orderparam_object" then
								if menu.checkForOrderParamObject(convertedRowComponent) then
									menu.contextMenuData = { component = convertedRowComponent, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
									menu.contextMenuMode = "select"
									menu.createContextFrame(menu.selectWidth)
								end
							else
								local missions = {}
								Helper.ffiVLA(missions, "MissionID", C.GetNumMapComponentMissions, C.GetMapComponentMissions, menu.holomap, convertedRowComponent)

								if rowdata[1] == "construction" then
									menu.interactMenuComponent = convertedRowComponent
									Helper.openInteractMenu(menu, { component = convertedRowComponent, playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true), mouseX = posx, mouseY = posy, construction = rowdata[3], componentmissions = missions })
								else
									menu.interactMenuComponent = convertedRowComponent
									Helper.openInteractMenu(menu, { component = convertedRowComponent, playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true), mouseX = posx, mouseY = posy, componentmissions = missions })
								end
							end
						end
					end
				end
			elseif menu.infoTableMode == "info" then
				-- controllable: rowdata[3], actor: rowdata[2]
				-- actor may be a member of a ship's crew (person) or a ship's pilot, depending on rowdata[1]. actor should never be the player.
				if (type(rowdata) == "table") and (type(rowdata[3]) == "number") and C.IsComponentClass(rowdata[3], "controllable") then
					local controllable = rowdata[3]
					local person, entity
					if (rowdata[1] == "info_crewperson") then
						if GetComponentData(rowdata[3], "isplayerowned") and C.IsPerson(rowdata[2], controllable) then
							person = rowdata[2]
						end
					else
						--print("is station: " .. tostring(C.IsComponentClass(controllable, "station")) .. ", manager: " .. ConvertStringTo64Bit(tostring(GetComponentData(rowdata[3], "tradenpc"))) .. ", shiptrader: " .. ConvertStringTo64Bit(tostring(GetComponentData(rowdata[3], "shiptrader"))) .. ", rowdata[2]: " .. tostring(rowdata[2]) .. ", is player owned: " .. tostring(GetComponentData(rowdata[3], "isplayerowned")) .. ", can comm: " .. tostring(C.CanPlayerCommTarget(rowdata[2])))
						if GetComponentData(rowdata[3], "isplayerowned") or C.CanPlayerCommTarget(rowdata[2]) then
							-- ship captain
							if C.IsComponentClass(controllable, "ship") and ConvertStringTo64Bit(tostring(GetComponentData(rowdata[3], "assignedpilot"))) == rowdata[2] then
								entity = rowdata[2]
							-- station manager or shiptrader
							-- TODO: enable comming shiptrader after fixing ship config menu closing right after menu is launched. (menu triggered as conversation menu and conversation immediately ends)
							elseif C.IsComponentClass(controllable, "station") and (ConvertStringTo64Bit(tostring(GetComponentData(rowdata[3], "tradenpc"))) == rowdata[2]) then
							--elseif C.IsComponentClass(controllable, "station") and (ConvertStringTo64Bit(tostring(GetComponentData(rowdata[3], "tradenpc"))) == rowdata[2] or ConvertStringTo64Bit(tostring(GetComponentData(rowdata[3], "shiptrader"))) == rowdata[2]) then
								entity = rowdata[2]
							end
						end
					end

					if person or entity then
						--print("person: " .. ffi.string(C.GetPersonName(rowdata[2], rowdata[3])) .. ", combinedskill: " .. C.GetPersonCombinedSkill(rowdata[3], rowdata[2], nil, nil))
						local x, y = GetLocalMousePosition()

						menu.contextMenuData = { component = controllable, person = person, entity = entity, xoffset = x + Helper.viewWidth / 2, yoffset = Helper.viewHeight / 2 - y }
						menu.contextMenuMode = "info_actor"
						menu.createContextFrame(menu.selectWidth)
					end
				end
			elseif menu.infoTableMode == "missionoffer" then
				if uitable == menu.infoTable then
					if type(rowdata) == "table" then
						menu.closeContextMenu()

						local missionid = ConvertStringTo64Bit(rowdata[1])
						Helper.openInteractMenu(menu, { missionoffer = missionid, playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true) })
					end
				end
			elseif menu.infoTableMode == "mission" then
				if uitable == menu.infoTable then
					if type(rowdata) == "table" then
						menu.closeContextMenu()

						local missionid = ConvertStringTo64Bit(rowdata[1])
						Helper.openInteractMenu(menu, { mission = missionid, playerships = menu.getSelectedPlayerShips(false), npcships = menu.getSelectedPlayerShips(true) })
					end
				end
			end
		else
			menu.closeContextMenu()
		end
	end
end

function menu.onButtonRightMouseClick()
	if (menu.mode == "orderparam_position") then
		menu.resetOrderParamMode(menu.modeparam[4])
	end
end

function menu.onInteractiveElementChanged(element)
	menu.lastactivetable = element
end

-- close menu handler
function menu.onCloseElement(dueToClose, layer)
	PlaySound("ui_negative_back")
	if (menu.mode == "orderparam_object") or (menu.mode == "orderparam_position") then
		menu.resetOrderParamMode(menu.modeparam[4])
		return
	end

	if menu.closeContextMenu(dueToClose) then
		return
	end

	if menu.mode ~= "hire" then
		if menu.infoTableMode and (dueToClose == "back") then
			menu.deactivateObjectList()
			return
		end
	end

	if (layer == nil) or (layer == config.mainFrameLayer) or (layer == config.infoFrameLayer) then
		if dueToClose == "minimize" then
			if not menu.minimized then
				menu.closeContextMenu()
				Helper.minimizeMenu(menu, ReadText(1001, 3245))
			else
				Helper.restoreMenu(menu)
			end
		else
			C.RemoveHoloMap()
			menu.holomap = 0
			if menu.mode == "selectCV" then
				if dueToClose == "close" then
					C.ReleaseConstructionMapState()
				end
			end
			Helper.closeMenu(menu, dueToClose)
			menu.cleanup()
		end
	elseif layer == config.contextFrameLayer then
		Helper.clearFrame(menu, layer)
	end
end

-- helper functions

function menu.initPlotList()
	if not menu.plots then
		menu.plots = {}
	end

	local playerobjects = GetContainedStationsByOwner("player", nil, true)
	for _, object in ipairs(playerobjects) do
		--print(GetComponentData(object, "name") .. " " .. tostring(object) .. " has " .. tostring(numstationmodules) .. " modules.")
		local object64 = ConvertIDTo64Bit(object)
		local inownedspace = (GetComponentData(GetComponentData(object, "sectorid"), "owner") ~= "ownerless") and (GetComponentData(GetComponentData(object, "sectorid"), "owner") ~= "xenon")
		local size = C.GetBuildPlotSize(object64)
		local boughtrawsize = C.GetPaidBuildPlotSize(object64)
		local paid = (not inownedspace or boughtrawsize.x > 0 or boughtrawsize.y > 0 or boughtrawsize.z > 0) and true or false
		local fullypaid = (not inownedspace or (boughtrawsize.x >= size.x and boughtrawsize.y >= size.y and boughtrawsize.z >= size.z)) and true or false

		local found = false
		for j, plot in ipairs(menu.plots) do
			if plot.station == object64 then
				found = true
				if plot.removed then
					table.remove(menu.plots, j)
				else
					plot.paid = paid
					plot.fullypaid = fullypaid
					plot.permanent = (C.GetNumStationModules(object64, true, true) > 0) and true or false
					-- plot.boughtrawcenteroffset is set at menu.buttonBuyPlot() when a plot is bought.
				end
				break
			end
		end
		if not found then
			table.insert(menu.plots, { station = object64, paid = paid, fullypaid = fullypaid, permanent = (C.GetNumStationModules(object64, true, true) > 0) and true or false, boughtrawcenteroffset = C.GetPaidBuildPlotCenterOffset(object64), removed = nil })
		end
	end
end

function menu.isInfoModeValidFor(object, mode)
	local isonlineobject, isplayerowned = GetComponentData(object, "isonlineobject", "isplayerowned")
	if isplayerowned and isonlineobject then
		return false
	end

	if mode == "objectinfo" then
		if C.IsComponentClass(object, "ship") or C.IsComponentClass(object, "station") or C.IsComponentClass(object, "sector") or C.IsComponentClass(object, "gate") then
			return true
		end
	elseif mode == "factionresponses" then
		return true
	elseif (mode == "controllableresponses") or (mode == "orderqueue") or (mode == "orderqueue_advanced") then
		if isplayerowned and C.IsComponentClass(object, "ship") and not C.IsUnit(object) then
			return true
		end
	else
		DebugError("menu.isInfoModeValidFor called with invalid mode: " .. tostring(mode) .. ". valid modes are 'objectinfo', 'factionresponses', 'controllableresponses', and 'orderqueue'")
	end

	return false
end

function menu.getNumDefendingCrew(objectid)
	local numdefendingcrew = 0
	local numpeople = C.GetNumAllRoles()
	local peopledata = ffi.new("PeopleInfo[?]", numpeople)
	numpeople = C.GetPeople(peopledata, numpeople, objectid)
	local loccounter = 0
	for i = 0, numpeople - 1 do
		if ffi.string(peopledata[i].id) == "marine" or ffi.string(peopledata[i].id) == "service" then
			numdefendingcrew = numdefendingcrew + peopledata[i].amount
			loccounter = loccounter + 1
			if loccounter == 2 then
				loccounter = nil
				break
			end
		end
	end
	return numdefendingcrew
end

function menu.getNumOperationalTurrets(objectid, numtotalturrets)
	numoperationalturrets = 0
	for i = 1, numtotalturrets do
		local currentcomponent = ConvertStringTo64Bit(tostring(C.GetUpgradeSlotCurrentComponent(objectid, "turret", i)))
		if currentcomponent and currentcomponent ~= 0 and IsComponentOperational(currentcomponent) then
			numoperationalturrets = numoperationalturrets + 1
		end
	end
	return numoperationalturrets
end

function menu.infoChangeObjectName(objectid, text, textchanged)
    if textchanged then
		SetComponentName(objectid, text)
	end
    -- UniTrader change: Set Signal Universe/Object instead of actual renaming (whih is handled in MD)
    SignalObject(GetComponentData(objectid, "galaxyid" ) , "Object Name Updated" , ConvertStringToLuaID(tostring(objectid)) , text)
    -- UniTrader Changes end (next line was a if before, but i have some diffrent conditions)

	menu.noupdate = false
	menu.refreshInfoFrame()
end

function menu.infoCombineLoadoutComponents(components)
	local locmacros = {}
	for _, val in ipairs(components) do
		local locmacro = GetComponentData(ConvertStringTo64Bit(tostring(val)), "macro")
		if not locmacros[locmacro] then
			locmacros[locmacro] = 1
		else
			locmacros[locmacro] = locmacros[locmacro] + 1
		end
	end
	return locmacros
end

function menu.infoSetWeaponGroup(objectid, weaponid, primary, group, active)
	--print("setting weapon " .. ffi.string(C.GetComponentName(weaponid)) .. " of object " .. ffi.string(C.GetComponentName(objectid)) .. " for group " .. tostring(group) .. " of set primary? " .. tostring(primary) .. " to " .. tostring(active))
	C.SetWeaponGroup(objectid, weaponid, primary, group, active)
	menu.refreshInfoFrame()
end

function menu.infoUpdatePeople()
	if menu.infoMode == "objectinfo" then
		menu.infoSubmenuPrepareCrewInfo()
		menu.refreshInfoFrame()
	end
end

function menu.isModuleTypeExtended(station, type)
	for i, entry in ipairs(menu.extendedmoduletypes) do
		if IsSameComponent(entry.id, station) then
			return entry.moduletypes[type]
		end
	end
	return false
end

function menu.isSubordinateExtended(name)
	return menu.extendedsubordinates[name] ~= nil
end

function menu.isDockedShipsExtended(name)
	return menu.extendeddockedships[name] ~= nil
end

function menu.isConstructionExtended(name)
	return menu.extendedconstruction[name] ~= nil
end

function menu.isPropertyExtended(name)
	return menu.extendedproperty[name] ~= nil
end

function menu.isOrderExtended(controllable, orderidx)
	for i, entry in ipairs(menu.extendedorders) do
		if entry.id == controllable then
			return entry.orders[orderidx]
		end
	end
	return false
end

function menu.isCommander(component)
	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		local commanderlist = C.IsComponentClass(selectedcomponent, "controllable") and GetAllCommanders(selectedcomponent) or {}
		for i, entry in ipairs(commanderlist) do
			if IsSameComponent(entry, component) then
				return true
			end
		end
	end
	return false
end

function menu.isDockContext(component)
	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		if GetComponentData(selectedcomponent, "isdocked") then
			local containercontext = C.GetContextByClass(selectedcomponent, "container", false)
			while containercontext ~= 0 do
				if containercontext == component then
					return true
				end
				containercontext = C.GetContextByClass(containercontext, "container", false)
			end
		end
	end
	return false
end

function menu.isConstructionContext(component)
	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		if IsComponentConstruction(selectedcomponent) then
			local containercontext = C.GetContextByClass(selectedcomponent, "container", false)
			while containercontext ~= 0 do
				if containercontext == component then
					return true
				end
				containercontext = C.GetContextByClass(containercontext, "container", false)
			end
		end
	end
	return false
end

function menu.extendModuleType(station, type, notoggle)
	local found = false
	for i, entry in ipairs(menu.extendedmoduletypes) do
		if IsSameComponent(entry.id, station) then
			found = true
			if (not notoggle) and entry.moduletypes[type] then
				entry.moduletypes[type] = nil
			else
				entry.moduletypes[type] = true
			end
		end
	end
	if not found then
		table.insert(menu.extendedmoduletypes, {id = station, moduletypes = { [type] = true } })
	end
end

function menu.extendOrder(controllable, orderidx)
	local found = false
	for i, entry in ipairs(menu.extendedorders) do
		if entry.id == controllable then
			found = true
			if entry.orders[orderidx] then
				entry.orders[orderidx] = nil
			else
				entry.orders[orderidx] = true
			end
			break
		end
	end
	if not found then
		table.insert(menu.extendedorders, {id = controllable, orders = { [orderidx] = true } })
	end
end

function menu.swapExtendedOrder(controllable, oldorderidx, neworderidx)
	for i, entry in ipairs(menu.extendedorders) do
		if entry.id == controllable then
			local temp = entry.orders[neworderidx]
			entry.orders[neworderidx] = entry.orders[oldorderidx]
			entry.orders[oldorderidx] = temp
			break
		end
	end
end

function menu.setOrderParamFromMode(controllable, order, param, index, value)
	SetOrderParam(controllable, order, param, index, value)

	menu.resetOrderParamMode(controllable)
end

function menu.resetOrderParamMode(controllable)
	menu.infoTableMode = "info"
	menu.infoMode = menu.currentOrderQueueMode
	menu.settoprow = menu.modeparam[3]
	menu.mode = nil
	menu.modeparam = {}

	menu.removeMouseCursorOverride(3)

	menu.refreshMainFrame = true
	menu.refreshInfoFrame()
end

function menu.onEditBoxActivated()
	menu.noupdate = true
end

function menu.searchTextConfirmed(_, text, textchanged)
	if textchanged then
		AddUITriggeredEvent(menu.name, "searchconfirmed")

		local ware = menu.economyWares[utf8.lower(text)]
		if ware then
			local setting = config.layersettings["layer_trade"][1]
			menu.setFilterOption("layer_trade", setting, setting.id, ware)
		else
			table.insert(menu.searchtext, { text = text })
			Helper.textArrayHelper(menu.searchtext, function (numtexts, texts) return C.SetMapFilterString(menu.holomap, numtexts, texts) end, "text")
		end
		menu.refreshMainFrame = true
	end
	menu.noupdate = false

	menu.refreshInfoFrame()
end

function menu.removeExtendedOrder(controllable, orderidx)
	for i, entry in ipairs(menu.extendedorders) do
		if entry.id == controllable then
			entry.orders[orderidx] = nil
			for i = orderidx + 1, #menu.infoTableData.orders do
				entry.orders[i - 1] = entry.orders[i]
			end
			entry.orders[#menu.infoTableData.orders] = nil
			break
		end
	end
end

function menu.addShipToBoardingOperation(shipid, shipdata)
	--print("ship: " .. ffi.string(C.GetComponentName(shipid)) .. " " .. tostring(shipid) .. ", actionid: " .. tostring(shipdata.action))
	-- NB: actionid also applies to subordinates. explicitly assigned ships that are all subordinates should be in menu.boardingData.shipdata and not in subordinates. assignedmarines are distributed among shipid and all subordinates. assignedmarines starts from shipid, overflow among subordinates in no particular order.
	local actionid = shipdata.action
	local assignedmarines = {}
	local remainingmarines = {}
	local subordinates = shipdata.subordinates

	--print("ship: " .. ffi.string(C.GetComponentName(shipid)) .. ", actionid: " .. tostring(actionid) .. ", num subordinates: " .. tostring(#subordinates))
	for _, leveldata in ipairs(menu.boardingData.marinelevels) do
		if not menu.boardingData.shipdata[shipid].assignedgroupmarines[leveldata.skilllevel] then
			table.insert(assignedmarines, 0)
		else
			table.insert(assignedmarines, menu.boardingData.shipdata[shipid].assignedgroupmarines[leveldata.skilllevel])
		end
	end

	-- get number of marines per tier on shipid
	local numtiers = #menu.boardingData.marinelevels
	local tierdata = ffi.new("RoleTierData[?]", numtiers)
	numtiers = C.GetRoleTiers(tierdata, numtiers, shipid, "marine")

	-- add each ship and subordinate to the boarding operation.
	local marinelist = ffi.new("uint32_t[?]", numtiers)
	local marineskilllevellist = ffi.new("uint32_t[?]", numtiers)
	for i = 0, numtiers - 1 do
		marinelist[i] = math.min(assignedmarines[i+1], tierdata[i].amount)
		marineskilllevellist[i] = menu.boardingData.marinelevels[i+1].skilllevel
		table.insert(remainingmarines, assignedmarines[i+1] - marinelist[i])
		--print("primary attacker. index: " .. tostring(i) .. ", num marines: " .. tostring(marinelist[i]) .. ", skill level: " .. tostring(marineskilllevellist[i]))
	end

	if menu.isShipAlreadyBoarding(shipid) then
		if not C.UpdateAttackerOfBoardingOperation(menu.boardingData.target, shipid, "player", actionid, marinelist, marineskilllevellist, numtiers) then
			DebugError("Failed updating boarding ship " .. ffi.string(C.GetComponentName(shipid)) .. " " .. tostring(shipid))
		end
	else
		if not C.AddAttackerToBoardingOperation(menu.boardingData.target, shipid, "player", actionid, marinelist, marineskilllevellist, numtiers) then
			DebugError("Failed adding " .. ffi.string(C.GetComponentName(shipid)) .. " " .. tostring(shipid) .. " to boarding operation attacking " .. ffi.string(C.GetComponentName(menu.boardingData.target)) .. " " .. tostring(menu.boardingData.target))
		end
	end

	for _, subordinateid in ipairs(subordinates) do
		if not menu.boardingData.shipdata[subordinateid].isprimaryboarder then
			-- get number of marines per tier in subordinateid
			numtiers = C.GetRoleTiers(tierdata, numtiers, subordinateid, "marine")
			for i = 0, numtiers - 1 do
				marinelist[i] = math.min(remainingmarines[i+1], tierdata[i].amount)
				marineskilllevellist[i] = menu.boardingData.marinelevels[i+1].skilllevel
				remainingmarines[i+1] = remainingmarines[i+1] - marinelist[i]
				--print("subordinate. index: " .. tostring(i) .. ", num marines: " .. tostring(marinelist[i]) .. ", skill level: " .. tostring(marineskilllevellist[i]))
			end

			if menu.isShipAlreadyBoarding(subordinateid) then
				if not C.UpdateAttackerOfBoardingOperation(menu.boardingData.target, subordinateid, "player", actionid, marinelist, marineskilllevellist, numtiers) then
					DebugError("Failed updating boarding ship " .. ffi.string(C.GetComponentName(subordinateid)) .. " " .. tostring(subordinateid))
				end
			else
				--print("adding " .. ffi.string(C.GetComponentName(subordinateid)) .. " to boarding operation")
				if not C.AddAttackerToBoardingOperation(menu.boardingData.target, subordinateid, "player", actionid, marinelist, marineskilllevellist, numtiers) then
					DebugError("Failed adding " .. ffi.string(C.GetComponentName(subordinateid)) .. " " .. tostring(subordinateid) .. " to boarding operation attacking " .. ffi.string(C.GetComponentName(menu.boardingData.target)) .. " " .. tostring(menu.boardingData.target))
				end
			end
		end
	end
end

function menu.isShipAlreadyBoarding(shipid)
	local numattackers = C.GetNumAttackersOfBoardingOperation(menu.boardingData.target, "player")
	local attackers = ffi.new("UniverseID[?]", numattackers)
	numattackers = C.GetAttackersOfBoardingOperation(attackers, numattackers, menu.boardingData.target, "player")
	local alreadyboarding = false
	for i = 0, numattackers do
		if shipid == ConvertStringTo64Bit(tostring(attackers[i])) then
			alreadyboarding = true
			break
		end
	end

	return alreadyboarding
end

function menu.updateHolomap()
	if menu.mode ~= "tradecontext" then
		if not menu.lastUpdateHolomapTime then
			menu.lastUpdateHolomapTime = 0
		end
		local curTime = getElapsedTime()
		if menu.lastUpdateHolomapTime < curTime - 5 and not menu.noupdate then
			menu.lastUpdateHolomapTime = curTime
			menu.refreshInfoFrame()
		end
	end
end

function menu.importMenuParameters()
	menu.showzone = menu.param[3] ~= 0

	menu.focuscomponent = ConvertIDTo64Bit(menu.param[4])
	menu.selectfocuscomponent = true
	if not menu.focuscomponent then
		local softtarget = C.GetSofttarget().softtargetID
		if softtarget ~= 0 then
			menu.focuscomponent = softtarget
		else
			menu.focuscomponent = C.GetPlayerObjectID()
			menu.selectfocuscomponent = nil
		end
	end

	menu.currentsector = C.GetContextByClass(menu.focuscomponent, "sector", true)
	menu.mode = menu.param[6]
	menu.modeparam = menu.param[7] or {}
end

function menu.prepareColors()
	local productioncolor, buildcolor, storagecolor, radarcolor, dronedockcolor, efficiencycolor, defencecolor, playercolor, friendcolor, enemycolor, missioncolor, currentplayershipcolor, visitorcolor, lowalertcolor, mediumalertcolor, highalertcolor, gatecolor, highwaygatecolor, missilecolor, superhighwaycolor, highwaycolor = GetHoloMapColors()
	menu.holomapcolor = { productioncolor = productioncolor, buildcolor = buildcolor, storagecolor = storagecolor, radarcolor = radarcolor, dronedockcolor = dronedockcolor, efficiencycolor = efficiencycolor, defencecolor = defencecolor, playercolor = playercolor, friendcolor = friendcolor, enemycolor = enemycolor, missioncolor = missioncolor, currentplayershipcolor = currentplayershipcolor, visitorcolor = visitorcolor, lowalertcolor = lowalertcolor, mediumalertcolor = mediumalertcolor, highalertcolor = highalertcolor, gatecolor = gatecolor, highwaygatecolor = highwaygatecolor, missilecolor = missilecolor, superhighwaycolor = superhighwaycolor, highwaycolor = highwaycolor }
end

function menu.prepareEconomyWares()
	if not menu.economyWares then
		menu.economyWares = {}
		local n = C.GetNumWares("economy", false, "", "")
		local buf = ffi.new("const char*[?]", n)
		n = C.GetWares(buf, n, "economy", false, "", "")
		for i = 0, n - 1 do
			local ware = ffi.string(buf[i])
			menu.economyWares[utf8.lower(GetWareData(ware, "name"))] = ware
		end
	end
end

function menu.checkForOrderParamObject(component)
	local failed
	local inputparams = menu.modeparam[2].inputparams
	local convertedComponent = ConvertStringTo64Bit(tostring(component))

	local unitstoragedata, subordinates, unitstoragedata_defence, unitstoragedata_attack, storagedata, cargo, commander, hascontrolentity, buildermacros, buildingmodule, buildanchor, tradeoffers

	local class = {
		container = C.IsComponentClass(component, "container"),
		controllable = C.IsComponentClass(component, "controllable"),
		defensible = C.IsComponentClass(component, "defensible"),
		buildmodule = C.IsComponentClass(component, "buildmodule"),
		buildprocessor = C.IsComponentClass(component, "buildprocessor"),
	}

	if (not failed) and ((not inputparams.excludeself) and true or (inputparams.excludeself ~= 0)) then
		if IsSameComponent(menu.modeparam[4], convertedComponent) then
			failed = "excludeself"
		end
	end

	if (not failed) and inputparams.isconstruction then
		if IsComponentConstruction(convertedComponent) ~= (inputparams.isconstruction ~= 0) then
			failed = "isconstruction"
		end
	end

	if (not failed) and inputparams.class then
		local correctclass = false
		if type(inputparams.class) == "table" then
			for _, class in ipairs(inputparams.class) do
				if C.IsComponentClass(component, class) then
					correctclass = true
					break
				end
			end
		else
			DebugError("Order parameter '" .. menu.modeparam[2].name .. "' - input parameter class is not a list. [Florian]")
		end
		if not correctclass then
			failed = "class"
		end
	end

	if (not failed) and inputparams.owner then
		if GetComponentData(convertedComponent, "owner") ~= inputparams.owner then
			failed = "owner"
		end
	end

	if (not failed) and inputparams.mining then
		if not C.CanContainerMineTransport(component, inputparams.mining) then
			failed = "mining"
		end
	end

	if (not failed) and inputparams.unitcapacity then
		unitstoragedata = unitstoragedata or (class.defensible and GetUnitStorageData(convertedComponent) or { capacity = 0 })

		if (unitstoragedata.capacity == 0) == (inputparams.unitcapacity ~= 0) then
			failed = "unitcapacity"
		end
	end

	if (not failed) and inputparams.attackcapacity then
		subordinates = subordinates or (class.controllable and GetSubordinates(convertedComponent) or {})
		unitstoragedata_defence = unitstoragedata_defence or (class.defensible and GetUnitStorageData(convertedComponent, "defence") or { capacity = 0 })
		unitstoragedata_attack = unitstoragedata_attack or (class.defensible and GetUnitStorageData(convertedComponent, "attack") or { capacity = 0 })

		local dpstable = ffi.new("DPSData[?]", 6)
		local numquadrants = C.GetDefensibleDPS(dpstable, component, true, true, true, true, true, false, true)
		local hasdps = nil
		for i = 0, numquadrants - 1 do
			if dpstable[i].dps > 0 then
				hasdps = true
				break
			end
		end
		if (hasdps or #subordinates > 0 or unitstoragedata_defence.stored > 0 or unitstoragedata_attack.stored > 0) ~= (inputparams.attackcapacity ~= 0) then
			failed = "attackcapacity"
		end
	end

	if (not failed) and inputparams.cargocapacity then
		if type(inputparams.cargocapacity) == "string" then
			if not C.CanContainerTransport(component, inputparams.cargocapacity) then
				failed = "cargocapacity"
			end
		else
			storagedata = storagedata or GetStorageData(convertedComponent)

			if (not next(storagedata) or storagedata.capacity == 0) == (inputparams.cargocapacity ~= 0) then
				failed = "cargocapacity"
			end
		end
	end

	if (not failed) and inputparams.hascargo then
		cargo = cargo or GetComponentData(convertedComponent, "cargo")

		if type(inputparams.hascargo) == "string" then
			if not cargo[inputparams.hascargo] then
				failed = "hascargo"
			end
		else
			if (not next(cargo)) == (inputparams.hascargo ~= 0) then
				failed = "hascargo"
			end
		end
	end

	if (not failed) and inputparams.issubordinate then
		commander = commander or (class.controllable and GetCommander(convertedComponent) or {})

		if (not commander) == (inputparams.issubordinate ~= 0) then
			failed = "issubordinate"
		end
	end

	if (not failed) and inputparams.canbecommanderof then
		hascontrolentity = hascontrolentity or (#Helper.getSuitableControlEntities(convertedComponent) > 0)
		
		if (not CanBeSubordinateOf(inputparams.canbecommanderof, convertedComponent)) or (not hascontrolentity) then
			failed = "canbecommanderof"
		end
	end

	if (not failed) and inputparams.hascontrolentity then
		hascontrolentity = hascontrolentity or (#Helper.getSuitableControlEntities(convertedComponent) > 0)

		if (not hascontrolentity) == (inputparams.hascontrolentity ~= 0) then
			failed = "hascontrolentity"
		end
	end

	if (not failed) and inputparams.hasorders then
		if (C.GetNumOrders(component) == 0) == (inputparams.hasorders ~= 0) then
			failed = "hasorders"
		end
	end

	if (not failed) and inputparams.hasbuildmodule then
		buildermacros = buildermacros or ((class.container or class.buildmodule) and GetBuilderMacros(convertedComponent) or {})

		if (#buildermacros == 0) == (inputparams.hasbuildmodule ~= 0) then
			failed = "hasbuildmodule"
		end
	end

	if (not failed) and inputparams.hasbuildingmodule then
		buildingmodule = buildingmodule or GetComponentData(convertedComponent, "buildingmodule")

		if (not buildingmodule) == (inputparams.hasbuildingmodule ~= 0) then
			failed = "hasbuildingmodule"
		end
	end

	if (not failed) and inputparams.isbuilding then
		buildanchor = buildanchor or ((class.container or class.buildmodule or class.buildprocessor) and GetBuildAnchor(convertedComponent) or {})

		if (not buildanchor) == (inputparams.isbuilding ~= 0) then
			failed = "isbuilding"
		end
	end

	if (not failed) and inputparams.hasselloffer then
		tradeoffers = tradeoffers or (GetComponentData(convertedComponent, "tradeoffers") or {})

		local found = false
		for _, tradeid in ipairs(tradeoffers) do
			local trade = GetTradeData(tradeid)
			if type(inputparams.hasselloffer) == "string" then
				if trade.isselloffer and (trade.ware == inputparams.hasselloffer) then
					found = true
					break
				end
			else
				if trade.isselloffer then
					if inputparams.hasselloffer ~= 0 then
						found = true
					else
						found = false
					end
					break
				else
					if inputparams.hasselloffer == 0 then
						found = true
					else
						found = false
					end
				end
			end
		end
		
		if not found then
			failed = "hasselloffer"
		end
	end

	if (not failed) and inputparams.hasbuyoffer then
		tradeoffers = tradeoffers or (GetComponentData(convertedComponent, "tradeoffers") or {})

		local found = false
		for _, tradeid in ipairs(tradeoffers) do
			local trade = GetTradeData(tradeid)
			if type(inputparams.hasbuyoffer) == "string" then
				if trade.isbuyoffer and (trade.ware == inputparams.hasbuyoffer) then
					found = true
					break
				end
			else
				if trade.isbuyoffer then
					if inputparams.hasbuyoffer ~= 0 then
						found = true
					else
						found = false
					end
					break
				else
					if inputparams.hasbuyoffer == 0 then
						found = true
					else
						found = false
					end
				end
			end
		end

		if not found then
			failed = "hasbuyoffer"
		end
	end

	if failed then
		-- print("Check failed with inputparam: '" .. failed .. "' (" .. tostring(inputparams[failed]) .. ")")
		return false
	end

	return true
end

function menu.plotCourse(object, offset)
	local convertedObject = ConvertStringToLuaID(tostring(object))
	if menu.mode or (object == C.GetPlayerControlledShipID()) then
		return -- no plot course to playership or when menu.mode is set
	end

	if IsSameComponent(GetActiveGuidanceMissionComponent(), convertedObject) then
		C.EndGuidance()
	else
		if offset == nil then
			offset = ffi.new("UIPosRot", 0)
		elseif C.IsComponentClass(object, "sector") then
			object = C.GetZoneAt(object, offset)
		end
		C.SetGuidance(object, offset)
	end

	menu.settoprow = GetTopRow(menu.selecttable)
	menu.setrow = Helper.currentTableRow[menu.selecttable]
	if not menu.createInfoFrameRunning then
		menu.createInfoFrame()
	end
end

function menu.getParamValue(type, value)
	local result

	if type == "bool" then
		result = (value ~= 0) and ReadText(1001, 2617) or ReadText(1001, 2618)
	elseif type == "length" then
		result = tostring(value) .. " " .. ReadText(1001, 107)
	elseif type == "time" then
		result = tostring(value) .. " " .. ReadText(1001, 100)
	elseif type == "money" then
		result = ConvertMoneyString(value, false, true, 0, true) .. " " .. ReadText(1001, 101)
	elseif type == "object" then
		if IsComponentClass(value, "space") then
			local name, sector, cluster = GetComponentData(value, "name", "sector", "cluster")
			result = ((cluster ~= "") and (cluster .. " / ") or "") .. ((sector ~= "") and (sector .. " / ") or "") .. name
		else
			result = GetComponentData(value, "name")
		end
	elseif type == "ware" then
		result = GetWareData(value, "name")
	elseif type == "macro" then
		result = GetMacroData(value, "name")
	elseif type == "trade_ware" then
		result = (value[1] and ReadText(1001, 2917) or ReadText(1001, 2916)) .. " " .. GetWareData(value[2], "name")
	elseif type == "trade_amount" then
		result = value[1] and (tostring(value[1]) .. " (" .. string.format(ReadText(1001, 3246), tostring(value[2])) .. ")") or ""
	elseif type == "position" then
		local name, sectorid, clusterid = GetComponentData(value[1], "name", "sectorid", "clusterid")
		result = ""
		if clusterid then
			local sectors = GetSectors(clusterid)
			local clustername, systemid = GetComponentData(clusterid, "name", "systemid")
			if (#sectors > 1) or (systemid ~= 0) then
				result = clustername .. "\n"
			end
		end
		result = result .. (sectorid and (GetComponentData(sectorid, "name") .. "\n") or "") .. name
	else
		result = tostring(value)
	end

	return result
end

function menu.closeContextMenu(dueToClose)
	if Helper.closeInteractMenu() then
		return true
	end
	if menu.contextMenuMode then
		if menu.contextMenuMode == "trade" then
			if C.IsComponentOperational(menu.contextMenuData.currentShip) then
				SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.currentShip)), false)
			end
			if menu.contextMenuData.wareexchange then
				if C.IsComponentOperational(menu.contextMenuData.component) then
					SetVirtualCargoMode(ConvertStringToLuaID(tostring(menu.contextMenuData.component)), false)
				end
			end

			if (menu.infoTableMode ~= "info") and (menu.infoTableMode ~= "missionoffer") and (menu.infoTableMode ~= "mission") then
				if not menu.arrowsRegistered then
					RegisterAddonBindings("ego_detailmonitor", "map_arrows")
					menu.arrowsRegistered = true
				end
			end
		elseif menu.contextMenuMode == "mission" then
			if menu.contextMenuData.isoffer then
				UnregisterEvent("missionofferremoved", menu.onMissionOfferRemoved)
			else
				UnregisterEvent("missionremoved", menu.onMissionRemoved)
			end
		elseif menu.contextMenuMode == "boardingcontext" then
			-- restore old mode and old info table mode
			menu.mode = menu.oldmode
			menu.oldmode = nil
			menu.infoTableMode = menu.oldInfoTableMode
			menu.refreshMainFrame = true
			menu.oldInfoTableMode = nil
			menu.boardingData = {}
			menu.contexttoprow = nil
			menu.contextselectedrow = nil
		end
		-- REMOVE this block once the mouse out/over event order is correct -> This should be unnessecary due to the global tablemouseout event reseting the picking
		if menu.currentMouseOverTable and (
			(menu.currentMouseOverTable == menu.contexttable)
			or (menu.currentMouseOverTable == menu.contextshiptable)
			or (menu.currentMouseOverTable == menu.contextbuttontable)
			or (menu.currentMouseOverTable == menu.contextdesctable)
			or (menu.currentMouseOverTable == menu.contextobjectivetable)
			or (menu.currentMouseOverTable == menu.contextbottomtable)
			or (menu.contextMenuMode == "boardingcontext")
		) then
			menu.picking = true
			menu.currentMouseOverTable = nil
		end
		-- END
		menu.contextFrame = nil
		Helper.clearFrame(menu, config.contextFrameLayer)
		menu.contextMenuData = {}
		menu.contextMenuMode = nil
		if menu.mode == "tradecontext" or menu.closemapwithmenu then
			Helper.closeMenu(menu, dueToClose)
			menu.cleanup()
		end
		return true
	end
	return false
end

function menu.onInteractMenuCallback(type, param)
	if type == "attackmultiple" then
		menu.mode = "orderparam_selectenemies"
		menu.modeparam = param
		menu.setMouseCursorOverride("targetred", 3)
	elseif type == "boardingcontext" then
		-- accessing boarding menu from within the map
		local width = Helper.viewWidth * 0.6
		local height = Helper.viewHeight * 0.7
		local xoffset = Helper.viewWidth * 0.2
		local yoffset = Helper.viewHeight * 0.15
		menu.contextMenuMode = "boardingcontext"
		menu.contextMenuData = { target = param[1], boarders = param[2] }
		menu.createContextFrame(width, height, xoffset, yoffset)
	elseif type == "comm" then
		menu.openComm(param)
	elseif type == "info" then
		if param[2] then
			menu.extendedinfo = {}
			for _, loccategory in ipairs(param[2]) do
				menu.extendedinfo[loccategory] = true
			end
		end
		menu.openDetails(param[1])
	elseif type == "mission" then
		menu.infoTableMode = "mission"
		menu.missionMode = param[1]
		menu.missionModeCurrent = tostring(param[2])
		menu.refreshMainFrame = true
		menu.refreshInfoFrame()
		menu.showMissionContext(param[2])
		menu.missionModeContext = true
	elseif type == "missionaccepted" then
		if menu.missionOfferList then
			if menu.missionOfferMode == "guild" then
				for _, data in ipairs(menu.missionOfferList[menu.missionOfferMode] or {}) do
					local found = false
					for _, entry in ipairs(data.missions) do
						if ConvertStringTo64Bit(entry.ID) == param[1] then
							found = true
							entry.accepted = true
							menu.highlightLeftBar["mission"] = true
							menu.refreshMainFrame = true
							break
						end
					end
					if found then
						break
					end
				end
			else
				for i, entry in ipairs(menu.missionOfferList[menu.missionOfferMode] or {}) do
					if ConvertStringTo64Bit(entry.ID) == param[1] then
						entry.accepted = true
						menu.highlightLeftBar["mission"] = true
						menu.refreshMainFrame = true
						break
					end
				end
			end
		end
		menu.refreshIF = getElapsedTime()
	elseif type == "newconversation" then
		Helper.closeMenuForNewConversation(menu, param[1], param[2], param[3])
		menu.cleanup()
	elseif type == "newmenu" then
		Helper.closeMenuAndOpenNewMenu(menu, param[1], param[2])
		menu.cleanup()
	elseif type == "refresh" then
		menu.refreshInfoFrame()
	elseif type == "sellships" then
		menu.contextMenuData = { shipyard = param[1], ships = param[2], xoffset = param[3], yoffset = param[4] }
		menu.contextMenuMode = "sellships"
		menu.createContextFrame(menu.sellShipsWidth)
	elseif type == "standingorders" then
		menu.openStandingOrders(param)
	elseif type == "tradecontext" then
		local mousepos = C.GetCenteredMousePos()
		menu.contextMenuData = { component = param[1], xoffset = mousepos.x + Helper.viewWidth / 2, yoffset = mousepos.y + Helper.viewHeight / 2 }
		menu.buttonContextTrade(param[3])
	end
end

function menu.updateSelectedComponents(modified)
	local components = {}
	local rows, highlightedborderrow = GetSelectedRows(menu.infoTable)

	for _, row in ipairs(rows) do
		local rowdata = menu.rowDataMap[menu.infoTable][row]
		if type(rowdata) == "table" then
			if (rowdata[1] ~= "moduletype") and (rowdata[1] ~= "subordinates") and (rowdata[1] ~= "dockedships") and (rowdata[1] ~= "constructions") then
				if rowdata[1] == "construction" then
					if rowdata[3].component ~= 0 then
						table.insert(components, ConvertStringTo64Bit(tostring(rowdata[3].component)))
					end
				else
					table.insert(components, rowdata[2])
				end
			end
		end
	end

	-- keep gates, satellites, etc. selected even if they don't have their own list entries
	for id in pairs(menu.selectedcomponents) do
		local component = ConvertStringTo64Bit(id)
		if C.IsComponentClass(component, "gate") or C.IsComponentClass(component, "asteroid") or C.IsComponentClass(component, "satellite") or C.IsComponentClass(component, "buildstorage") then
			table.insert(components, component)
		end
	end

	menu.addSelectedComponents(components, modified)

	local rowdata = menu.rowDataMap[menu.infoTable][highlightedborderrow]
	if type(rowdata) == "table" then
		menu.highlightedbordercomponent = rowdata[2]
		if rowdata[1] == "construction" then
			if rowdata[3].component ~= 0 then
				menu.highlightedbordercomponent = ConvertStringTo64Bit(tostring(rowdata[3].component))
			end
		end
		menu.highlightedbordermoduletype = nil
		menu.highlightedplannedmodule = nil
		menu.highlightedconstruction = nil
		if rowdata[1] == "moduletype" then
			menu.highlightedbordermoduletype = rowdata[3]
		elseif rowdata[1] == "module" then
			menu.highlightedbordermoduletype = rowdata[3]
			if rowdata[6] then
				menu.highlightedbordercomponent = rowdata[5]
				menu.highlightedplannedmodule = rowdata[6]
			end
		elseif rowdata[1] == "subordinates" then
			menu.highlightedborderstationcategory = "subordinates"
		elseif rowdata[1] == "dockedships" then
			menu.highlightedborderstationcategory = "dockedships"
		elseif rowdata[1] == "constructions" then
			menu.highlightedborderstationcategory = "constructions"
		elseif rowdata[1] == "construction" then
			menu.highlightedconstruction = rowdata[3]
		end
		menu.highlightedbordersection = nil
	elseif type(rowdata) == "string" then
		menu.highlightedbordercomponent = nil
		menu.highlightedbordermoduletype = nil
		menu.highlightedborderstationcategory = nil
		menu.highlightedconstruction = nil
		menu.highlightedbordersection = rowdata
	end
end

function menu.updateTableSelection(lastcomponent)
	menu.refreshMainFrame = true

	-- check if sections need to be extended - if so we need a refresh
	local refresh = false
	for id in pairs(menu.selectedcomponents) do
		local component = ConvertStringTo64Bit(id)
		local commanderlist = C.IsComponentClass(component, "controllable") and GetAllCommanders(component) or {}
		for i, entry in ipairs(commanderlist) do
			if (not menu.isPropertyExtended(tostring(entry))) then
				menu.extendedproperty[tostring(entry)] = true
				refresh = true
			end
		end
	end
	if refresh then
		menu.refreshInfoFrame()
		return
	end

	if menu.rowDataMap[menu.infoTable] then
		local rows = {}
		local curRow
		for row, rowdata in pairs(menu.rowDataMap[menu.infoTable]) do
			if type(rowdata) == "table" then
				if (rowdata[1] ~= "moduletype") and (rowdata[1] ~= "subordinates") and (rowdata[1] ~= "dockedships") and (rowdata[1] ~= "constructions") and (rowdata[1] ~= "construction") and menu.isSelectedComponent(rowdata[2]) then
					table.insert(rows, row)
					if ConvertStringTo64Bit(tostring(rowdata[2])) == lastcomponent then
						curRow = row
					end
				elseif (rowdata[1] == "construction") and (rowdata[3].component ~= 0) and menu.isSelectedComponent(rowdata[3].component) then
					table.insert(rows, row)
					if ConvertStringTo64Bit(tostring(rowdata[3].component)) == lastcomponent then
						curRow = row
					end
				end
			end
		end
		SetSelectedRows(menu.infoTable, rows, curRow or (Helper.currentTableRow[menu.infoTable] or 0))
	end
	menu.setSelectedMapComponents()
end

function menu.addSelectedComponent(component, clear, noupdate)
	component = ConvertStringTo64Bit(tostring(component))
	if clear ~= false then
		menu.selectedcomponents = {}
	end

	local add = true
	local hasonlynpcs = true
	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		if GetComponentData(selectedcomponent, "isplayerowned") then
			hasonlynpcs = false
			break
		end
	end
	if not GetComponentData(component, "isplayerowned") then
		if hasonlynpcs then
			-- replace
			menu.selectedcomponents = {}
		else
			-- don't add
			add = false
		end
	else
		if hasonlynpcs then
			-- replace
			menu.selectedcomponents = {}
		else
			-- add -> nothing to do
		end
	end

	if add then
		menu.selectedcomponents[tostring(component)] = {}
	end
	if not noupdate then
		menu.updateTableSelection(component)
	end
end

function menu.addSelectedComponents(components, clear)
	if clear ~= false then
		menu.selectedcomponents = {}
	end
	for _, component in ipairs(components) do
		menu.addSelectedComponent(component, false, true)
	end
	menu.updateTableSelection()
end

function menu.removeSelectedComponent(component)
	component = ConvertStringTo64Bit(tostring(component))
	menu.selectedcomponents[tostring(component)] = nil
	menu.updateTableSelection()
end

function menu.toggleSelectedComponent(component)
	if menu.isSelectedComponent(component) then
		menu.removeSelectedComponent(component)
	else
		menu.addSelectedComponent(component, false)
	end
end

function menu.isSelectedComponent(component)
	component = ConvertStringTo64Bit(tostring(component))
	return menu.selectedcomponents[tostring(component)] ~= nil
end

function menu.clearSelectedComponents()
	menu.selectedcomponents = {}
	menu.updateTableSelection()
end

function menu.getNumSelectedComponents()
	local count = 0
	for _, _ in pairs(menu.selectedcomponents) do
		count = count + 1
	end
	return count
end

function menu.getShipList(includePlayerOccupiedShip)
	local ships = GetTradeShipList()
	local playeroccupiedship = ConvertStringToLuaID(tostring(C.GetPlayerOccupiedShipID()))
	for i = #ships, 1, -1 do
		local ship = ships[i]
		local commander = GetCommander(ship.shipid)
		if commander and not IsSameComponent(commander, playeroccupiedship) then
			table.remove(ships, i)
		elseif #GetTransportUnitMacros(GetComponentData(ship.shipid, "macro")) == 0 then
			table.remove(ships, i)
		elseif (not includePlayerOccupiedShip) and IsSameComponent(ship.shipid, playeroccupiedship) then
			table.remove(ships, i)
		end
	end

	return ships
end

function menu.updateTradeContextDimensions(numwarerows, numinforows)
	local warescrollwindowsize = 6
	local numwarningrows = 2

	local rowHeight = math.max(Helper.slidercellMinHeight, Helper.scaleY(Helper.standardTextHeight))

	menu.tradeContext = {
		width = config.tradeContextMenuWidth,			-- ca 800 px in 1920x1080
		widthcorrection = -Helper.scrollbarWidth,
		warescrollwindowsize = warescrollwindowsize,
		numwarerows = numwarerows,
		shipheight = Helper.scaleY(Helper.headerRow1Height) + Helper.borderSize + 1 + (math.min(warescrollwindowsize, numwarerows) + 1) * (Helper.borderSize + rowHeight),
		numinforows = numinforows,
		numwarningrows = numwarningrows,
		buttonheight = 1 + (numinforows + numwarningrows + 2) * (Helper.borderSize + rowHeight),
	}
end

function menu.getFilterTradeWaresOptions(currentList, currentOption)
	local result = {}
	for name, ware in pairs(menu.economyWares) do
		local found = false
		for _, currentware in ipairs(currentList) do
			if (currentware == ware) then
				if (not currentOption) or (currentware ~= currentOption) then
					found = true
				end
				break
			end
		end

		if not found then
			table.insert(result, { id = ware, text = GetWareData(ware, "name"), icon = "", displayremoveoption = false })
		end
	end
	table.sort(result, function (a, b) return a.text < b.text end)

	return result
end

function menu.getFilterTradeVolumeOptions()
	local params = C.GetMapTradeVolumeParameter()
	local icon = "\27[" .. ffi.string(params.icon) .."]"
	local color = { r = params.color.red, g = params.color.green, b = params.color.blue, a = params.color.alpha }

	local result = {
		{ id = 0,				text = ReadText(1001,8359), text2 = "",															icon = "", displayremoveoption = false }, -- None
		{ id = params.volume_s,	text = ReadText(1001,2853), text2 = Helper.convertColorToText(color) .. icon,					icon = "", displayremoveoption = false }, -- Small
		{ id = params.volume_m,	text = ReadText(1001,2854), text2 = Helper.convertColorToText(color) .. icon .. icon,			icon = "", displayremoveoption = false }, -- Medium
		{ id = params.volume_l,	text = ReadText(1001,2855), text2 = Helper.convertColorToText(color) .. icon .. icon .. icon,	icon = "", displayremoveoption = false }, -- Large
	}
	return result
end

function menu.getFilterThinkAlertOptions()
	local result = {
		{ id = 0, text = ReadText(1001,4054), icon = "", displayremoveoption = false }, -- none
		{ id = 3, text = ReadText(1001,4053), icon = "", displayremoveoption = false }, -- high
		{ id = 2, text = ReadText(1001,4052), icon = "", displayremoveoption = false }, -- medium
		{ id = 1, text = ReadText(1001,4051), icon = "", displayremoveoption = false }, -- low
	}
	return result
end

function menu.getFilterOption(id)
	return __CORE_DETAILMONITOR_MAPFILTER[id]
end

function menu.setFilterOption(mode, setting, id, value, index)
	if setting.type == "dropdownlist" then
		__CORE_DETAILMONITOR_MAPFILTER[id] = __CORE_DETAILMONITOR_MAPFILTER[id] or {}
		if index then
			__CORE_DETAILMONITOR_MAPFILTER[id][index] = value
		else
			table.insert(__CORE_DETAILMONITOR_MAPFILTER[id], value)
		end
	elseif setting.type == "checkbox" then
		__CORE_DETAILMONITOR_MAPFILTER[id] = not __CORE_DETAILMONITOR_MAPFILTER[id]
	elseif setting.type == "slidercell" then
		__CORE_DETAILMONITOR_MAPFILTER[id] = value
	elseif setting.type == "dropdown" then
		__CORE_DETAILMONITOR_MAPFILTER[id] = tonumber(value)
	end

	if not __CORE_DETAILMONITOR_MAPFILTER[mode] then
		__CORE_DETAILMONITOR_MAPFILTER[mode] = true
		menu.applyFilterSettings()
	else
		setting.callback(setting)
	end
end

function menu.removeFilterOption(setting, id, index)
	if setting.type == "dropdownlist" then
		__CORE_DETAILMONITOR_MAPFILTER[id] = __CORE_DETAILMONITOR_MAPFILTER[id] or {}
		table.remove(__CORE_DETAILMONITOR_MAPFILTER[id], index)
		setting.callback(setting)
	end
end

function menu.upgradeMapFilterVersion()
	local oldversion = __CORE_DETAILMONITOR_MAPFILTER.version

	if oldversion < 2 then
		__CORE_DETAILMONITOR_MAPFILTER["other_misc_workforce"] = true
		__CORE_DETAILMONITOR_MAPFILTER["other_misc_crew"] = true
	end
	if oldversion < 3 then
		__CORE_DETAILMONITOR_MAPFILTER["other_misc_ecliptic"] = true
	end
	if oldversion < 4 then
		__CORE_DETAILMONITOR_MAPFILTER["other_misc_dockedships"] = true
	end
	if oldversion < 5 then
		__CORE_DETAILMONITOR_MAPFILTER["layer_think"] = true
	end
	if oldversion < 6 then
		__CORE_DETAILMONITOR_MAPFILTER["trade_storage_container"] = true
	end
	if oldversion < 7 then
		__CORE_DETAILMONITOR_MAPFILTER["think_alert"] = 3
	end
	if oldversion < 8 then
		__CORE_DETAILMONITOR_MAPFILTER["mining_resource_display"] = true
		__CORE_DETAILMONITOR_MAPFILTER["other_misc_civilian"] = true
	end
	if oldversion < 9 then
		__CORE_DETAILMONITOR_MAPFILTER["trade_offer_number"] = 3
	end
	if oldversion < 10 then
		__CORE_DETAILMONITOR_MAPFILTER["trade_volume"] = 0
	end

	__CORE_DETAILMONITOR_MAPFILTER.version = config.mapfilterversion
end

function menu.applyFilterSettings()
	for mode, settings in pairs(config.layersettings) do
		local active = menu.getFilterOption(mode) or false
		if settings.callback then
			settings.callback(active)
		end
		if active then
			for _, setting in ipairs(settings) do
				setting.callback(setting)
			end
		end
	end
end

function menu.setMouseCursorOverride(cursor, priority)
	menu.mouseCursorOverrides[priority] = cursor
	menu.setMouseCursor()
end

function menu.removeMouseCursorOverride(priority)
	menu.mouseCursorOverrides[priority] = nil
	menu.setMouseCursor()
end

function menu.clearMouseCursorOverrides()
	menu.mouseCursorOverrides = { [1] = "default" }
	menu.setMouseCursor()
end

function menu.setMouseCursor()
	local highestPriority = table.maxn(menu.mouseCursorOverrides)
	if menu.mouseCursorOverrides[highestPriority] ~= menu.currentMouseCursor then
		menu.currentMouseCursor = menu.mouseCursorOverrides[highestPriority]
		SetMouseCursorOverride(menu.currentMouseCursor)
	end
end

function menu.updateMouseCursor()
	local occupiedship = C.GetPlayerOccupiedShipID()

	local hasplayerselectedship = false
	for id, _ in pairs(menu.selectedcomponents) do
		local selectedcomponent = ConvertStringTo64Bit(id)
		if IsValidComponent(selectedcomponent) then
			if C.IsComponentClass(selectedcomponent, "ship") and GetComponentData(selectedcomponent, "isplayerowned") then
				if selectedcomponent ~= occupiedship then
					hasplayerselectedship = true
				end
			end
		else
			menu.removeSelectedComponent(selectedcomponent)
		end
	end

	local cursor
	if menu.plotData and menu.plotData.active then
		-- plot mode
		local offset = ffi.new("UIPosRot")
		local offsetvalid = C.GetBuildMapStationLocation(menu.holomap, offset)
		if offsetvalid then
			cursor = "cursorplus"
		else
			cursor = "unavailable"
		end
	else
		local shiftpressed = C.IsShiftPressed()
		local controlpressed = C.IsControlPressed()
		local pickedcomponent = C.GetPickedMapComponent(menu.holomap)
		local pickedcomponentclass = ffi.string(C.GetComponentClass(pickedcomponent))
		local pickedorder = ffi.new("Order")
		local buf = ffi.new("bool[1]", 0)
		local pickedordercomponent = C.GetPickedMapOrder(menu.holomap, pickedorder, buf)
		local isintermediate = buf[0]
		local pickedtradeoffer = C.GetPickedMapTradeOffer(menu.holomap)
		local pickedmission = C.GetPickedMapMission(menu.holomap)

		if pickedordercomponent ~= 0 then
			-- orders
			if pickedordercomponent ~= occupiedship then
				if isintermediate then
					cursor = "cursorplus"
				else
					cursor = "cursormove"
				end
			else
				cursor = "cursor"
			end
		elseif pickedmission ~= 0 then
			-- guidance
			cursor = "cursor"
		elseif pickedtradeoffer ~= 0 then
			-- trade offers
			cursor = "trade"
		elseif pickedcomponent ~= 0 then
			if shiftpressed then
				-- changing selection
				if (pickedcomponentclass ~= "player") and (pickedcomponentclass ~= "ship_xs") and (pickedcomponentclass ~= "highwayentrygate") and (pickedcomponentclass ~= "collectablewares") and (pickedcomponentclass ~= "gate") and (pickedcomponentclass ~= "asteroid") and (pickedcomponentclass ~= "sector") then
					if C.IsComponentOperational(pickedcomponent) and GetComponentData(ConvertStringTo64Bit(tostring(pickedcomponent)), "isplayerowned") then
						cursor = "cursorplus"
					end
				end
			elseif controlpressed then
				-- default interactions
				if C.IsComponentClass(pickedcomponent, "sector") then
					if hasplayerselectedship then
						cursor = "movehere"
					end
				elseif GetComponentData(ConvertStringTo64Bit(tostring(pickedcomponent)), "isenemy") then
					if hasplayerselectedship then
						cursor = "targetred"
					end
				elseif C.IsComponentClass(pickedcomponent, "station") then
					cursor = "trade"
				end
			else
				if menu.picking and (pickedcomponentclass ~= "player") then
					local playerships = menu.getSelectedPlayerShips(invert)
					for i = #playerships, 1, -1 do
						local ship = playerships[i]
						if ship == pickedcomponent then
							table.remove(playerships, i)
						end
					end
					if #playerships > 0 then
						if C.IsComponentClass(pickedcomponent, "sector") then
							cursor = "crossarrowsorder"
						else
							cursor = "cursororder"
						end
					end
				end
			end
		end
		-- map pan & rot
		if menu.picking then
			if not cursor then
				if (pickedcomponent == 0) or (not C.IsComponentClass(pickedcomponent, "object")) then
					if shiftpressed then
						cursor = "boxselect"
					else
						cursor = "crossarrows"
					end
				end
			end
		end
	end
	if cursor then
		menu.setMouseCursorOverride(cursor, 2)
	else
		menu.removeMouseCursorOverride(2)
	end
end

function menu.getDropDownTurretModeOption(defensibleorturret, path, group)
	if (path == nil) and (group == nil) then
		return ffi.string(C.GetWeaponMode(defensibleorturret))
	elseif path == "all" then
		local allmode
		for i, turret in ipairs(menu.turrets) do
			local mode = ffi.string(C.GetWeaponMode(turret))
			if allmode == nil then
				allmode = mode
			elseif allmode ~= mode then
				allmode = ""
				break
			end
		end
		for i, group in ipairs(menu.turretgroups) do
			if group.operational > 0 then
				local mode = ffi.string(C.GetTurretGroupMode(defensibleorturret, group.path, group.group))
				if allmode == nil then
					allmode = mode
				elseif allmode ~= mode then
					allmode = ""
					break
				end
			end
		end
		return allmode
	end
	return ffi.string(C.GetTurretGroupMode(defensibleorturret, path, group))
end

function menu.getSlotSizeText(slotsize)
	if slotsize == "extralarge" then
		return ReadText(1001, 48)
	elseif slotsize == "large" then
		return ReadText(1001, 49)
	elseif slotsize == "medium" then
		return ReadText(1001, 50)
	elseif slotsize == "small" then
		return ReadText(1001, 51)
	end

	return ""
end

init()
