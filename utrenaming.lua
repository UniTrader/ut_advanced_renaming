-- stuff copied from the original file required for function
-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef uint64_t AIOrderID;
	typedef int32_t BlacklistID;
	typedef uint64_t BuildTaskID;
	typedef int32_t FightRuleID;
	typedef uint64_t MissionID;
	typedef uint64_t NPCSeed;
	typedef uint64_t TradeID;
	typedef int32_t TradeRuleID;
	typedef uint64_t UniverseID;

	typedef struct {
		const char* id;
		uint32_t textid;
		uint32_t descriptionid;
		uint32_t value;
		uint32_t relevance;
		const char* ware;
	} SkillInfo;
	typedef struct {
		const char* factionid;
		const char* civiliansetting;
		const char* militarysetting;
	} UIFightRuleSetting;

	typedef struct {
		const char* macro;
		const char* ware;
		uint32_t amount;
		uint32_t capacity;
	} AmmoData;
	typedef struct {
		uint32_t nummacros;
		uint32_t numfactions;
	} BlacklistCounts;
	typedef struct {
		uint32_t id;
		const char* type;
		const char* name;
		bool usemacrowhitelist;
		uint32_t nummacros;
		const char** macros;
		bool usefactionwhitelist;
		uint32_t numfactions;
		const char** factions;
		const char* relation;
		bool hazardous;
	} BlacklistInfo2;
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
		FightRuleID id;
		const char* name;
		uint32_t numfactions;
		UIFightRuleSetting* factions;
	} FightRuleInfo;
	typedef struct {
		UniverseID entity;
		UniverseID personcontrollable;
		NPCSeed personseed;
	} GenericActor;
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
		const char* id;
		const char* name;
		bool possible;
	} DroneModeInfo;
	typedef struct {
		const char* factionID;
		const char* factionName;
		const char* factionIcon;
	} FactionDetails;
	typedef struct {
		const char* icon;
		const char* caption;
	} MissionBriefingIconInfo;
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
		MissionID missionid;
		uint32_t amount;
		uint32_t numskills;
		SkillInfo* skills;
	} MissionNPCInfo;
	typedef struct {
		const char* text;
		const char* actiontext;
		const char* detailtext;
		int step;
		bool failed;
		bool completedoutofsequence;
	} MissionObjectiveStep3;
	typedef struct {
		uint32_t id;
		bool ispin;
		bool ishome;
	} MultiverseMapPickInfo;
	typedef struct {
		NPCSeed seed;
		const char* roleid;
		int32_t tierid;
		const char* name;
		int32_t combinedskill;
	} NPCInfo;
	typedef struct {
		const char* chapter;
		const char* onlineid;
	} OnlineMissionInfo;
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
		size_t queueidx;
		const char* state;
		const char* statename;
		const char* orderdef;
		size_t actualparams;
		bool enabled;
		bool isinfinite;
		bool issyncpointreached;
		bool istemporder;
		bool isoverride;
	} Order2;
	typedef struct {
		uint32_t id;
		AIOrderID orderid;
		const char* orderdef;
		const char* message;
		double timestamp;
		bool wasdefaultorder;
		bool wasinloop;
	} OrderFailure;
	typedef struct {
		const char* id;
		const char* name;
		const char* desc;
		uint32_t amount;
		uint32_t numtiers;
		bool canhire;
	} PeopleInfo;
	typedef struct {
		const char* id;
		const char* name;
	} ProductionMethodInfo;
	typedef struct {
		const char* id;
		const char* name;
		const char* shortname;
		const char* description;
		const char* icon;
	} RaceInfo;
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
		uint32_t descriptionid;
		uint32_t value;
		uint32_t relevance;
	} Skill2;
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
		UniverseID owningcontrollable;
		size_t owningorderidx;
		bool reached;
	} SyncPointInfo2;
	typedef struct {
		const char* reason;
		NPCSeed person;
		NPCSeed partnerperson;
	} UICrewExchangeResult;
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
		const char* wareid;
		uint32_t amount;
	} UIWareAmount;
	typedef struct {
		bool primary;
		uint32_t idx;
	} UIWeaponGroup;
	typedef struct {
		UniverseID contextid;
		const char* path;
		const char* group;
	} UpgradeGroup2;
	typedef struct {
		UniverseID currentcomponent;
		const char* currentmacro;
		const char* slotsize;
		uint32_t count;
		uint32_t operational;
		uint32_t total;
	} UpgradeGroupInfo;
	typedef struct {
		UniverseID reserverid;
		const char* ware;
		uint32_t amount;
		bool isbuyreservation;
		double eta;
		TradeID tradedealid;
		MissionID missionid;
		bool isvirtual;
		bool issupply;
	} WareReservationInfo2;
	typedef struct {
		const char* ware;
		int32_t current;
		int32_t max;
	} WareYield;
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
		UniverseID target;
		UIWareAmount* wares;
		uint32_t numwares;
	} MissionWareDeliveryInfo;
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
	const char* AssignHiredActor(GenericActor actor, UniverseID targetcontrollableid, const char* postid, const char* roleid, bool checkonly);
	bool GetAskToSignalForControllable(const char* signalid, UniverseID controllableid);
	bool GetAskToSignalForFaction(const char* signalid, const char* factionid);
	uint32_t GetAttackersOfBoardingOperation(UniverseID* result, uint32_t resultlen, UniverseID defensibletargetid, const char* boarderfactionid);
	bool CanContainerMineTransport(UniverseID containerid, const char* transportname);
	bool CanContainerTransport(UniverseID containerid, const char* transportname);
	bool CanControllableHaveAnyTrainees(UniverseID controllableid);
	bool CanControllableHaveControlEntity(UniverseID controllableid, const char* postid);
	bool CanPlayerCommTarget(UniverseID componentid);
	void ChangeMapBuildPlot(UniverseID holomapid, float x, float y, float z);
	void CheatDockingTraffic(void);
	void ClearSelectedMapComponents(UniverseID holomapid);
	void ClearMapBuildPlot(UniverseID holomapid);
	void ClearMapObjectFilter(UniverseID holomapid);
	void ClearMapOrderParamObjectFilter(UniverseID holomapid);
	void ClearMapTradeFilterByMinTotalVolume(UniverseID holomapid);
	void ClearMapTradeFilterByPlayerOffer(UniverseID holomapid, bool buysellswitch);
	void ClearMapTradeFilterByWare(UniverseID holomapid);
	void ClearMapTradeFilterByWillingToTradeWithPlayer(UniverseID holomapid);
	bool CreateBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid, uint32_t approachthreshold, uint32_t insertionthreshold);
	uint32_t CreateDeployToStationOrder(UniverseID controllableid);
	UniverseID CreateNPCFromPerson(NPCSeed person, UniverseID controllableid);
	uint32_t CreateOrder(UniverseID controllableid, const char* orderid, bool default);
	uint32_t CreateOrder3(UniverseID controllableid, const char* orderid, bool defaultorder, bool isoverride, bool istemp);
	bool DropCargo(UniverseID containerid, const char* wareid, uint32_t amount);
	void EnableAllCheats(void);
	bool EnableOrder(UniverseID controllableid, size_t idx);
	bool EnablePlannedDefaultOrder(UniverseID controllableid, bool checkonly);
	void EndGuidance(void);
	bool ExtendBuildPlot(UniverseID stationid, Coord3D poschange, Coord3D negchange, bool allowreduction);
	bool FilterComponentByText(UniverseID componentid, uint32_t numtexts, const char** textarray, bool includecontainedobjects);
	bool FilterComponentForDefaultOrderParamObjectMode(UniverseID componentid, UniverseID ordercontrollableid, bool planned, size_t paramidx);
	bool FilterComponentForMapMode(UniverseID componentid, const char** classes, uint32_t numclasses, int32_t playerowned, bool allowentitydeliverymissionobject);
	bool FilterComponentForOrderParamObjectMode(UniverseID componentid, UniverseID ordercontrollableid, size_t orderidx, size_t paramidx);
	uint64_t GetActiveMissionID();
	uint32_t GetAllBlacklists(BlacklistID* result, uint32_t resultlen);
	uint32_t GetAllBoardingBehaviours(BoardingBehaviour* result, uint32_t resultlen);
	uint32_t GetAllBoardingPhases(BoardingPhase* result, uint32_t resultlen);
	uint32_t GetAllControlPosts(ControlPostInfo* result, uint32_t resultlen);
	uint32_t GetAllCountermeasures(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllFightRules(FightRuleID* result, uint32_t resultlen);
	uint32_t GetAllInventoryBombs(AmmoData* result, uint32_t resultlen, UniverseID entityid);
	uint32_t GetAllLaserTowers(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllMines(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllMissiles(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllNavBeacons(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllRaces(RaceInfo* result, uint32_t resultlen);
	uint32_t GetAllResourceProbes(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllSatellites(AmmoData* result, uint32_t resultlen, UniverseID defensibleid);
	uint32_t GetAllModuleSets(UIModuleSet* result, uint32_t resultlen);
	uint32_t GetAllowedWeaponSystems(WeaponSystemInfo* result, uint32_t resultlen, UniverseID defensibleid, size_t orderidx, bool usedefault);
	uint32_t GetAllResponsesToSignal(ResponseInfo* result, uint32_t resultlen, const char* signalid);
	uint32_t GetAllSignals(SignalInfo* result, uint32_t resultlen);
	bool GetBlacklistInfo2(BlacklistInfo2* info, BlacklistID id);
	BlacklistCounts GetBlacklistInfoCounts(BlacklistID id);
	const char* GetBoardingActionOfAttacker(UniverseID defensibletargetid, UniverseID defensibleboarderid, const char* boarderfactionid);
	uint32_t GetBoardingCasualtiesOfTier(int32_t marinetierskilllevel, UniverseID defensibletargetid, const char* boarderfactionid);
	bool GetBoardingMarineTierAmountsFromAttacker(uint32_t* resultmarinetieramounts, int32_t* inputmarinetierskilllevels, uint32_t inputnummarinetiers, UniverseID defensibletargetid, UniverseID defensibleboarderid, const char* boarderfactionid);
	BoardingRiskThresholds GetBoardingRiskThresholds(UniverseID defensibletargetid, const char* boarderfactionid);
	uint32_t GetBoardingStrengthFromOperation(UniverseID defensibletargetid, const char* boarderfactionid);
	uint32_t GetBoardingStrengthOfControllableTierAmounts(UniverseID controllableid, uint32_t* marinetieramounts, int32_t* marinetierskilllevels, uint32_t nummarinetiers);
	int64_t GetBuilderHiringFee(void);
	UniverseID GetBuildMapStationLocation2(UniverseID holomapid, UIPosRot* location);
	double GetBuildProcessorEstimatedTimeLeft(UniverseID buildprocessorid);
	Coord3D GetBuildPlotCenterOffset(UniverseID stationid);
	int64_t GetBuildPlotPayment(UniverseID stationid, bool* positionchanged);
	int64_t GetBuildPlotPrice(UniverseID sectorid, UIPosRot location, float x, float y, float z, const char* factionid);
	Coord3D GetBuildPlotSize(UniverseID stationid);
	double GetBuildTaskDuration(UniverseID containerid, BuildTaskID id);
	uint32_t GetBuildTasks(BuildTaskInfo* result, uint32_t resultlen, UniverseID containerid, UniverseID buildmoduleid, bool isinprogress, bool includeupgrade);
	uint32_t GetCargoTransportTypes(StorageInfo* result, uint32_t resultlen, UniverseID containerid, bool merge, bool aftertradeorders);
	Coord2D GetCenteredMousePos(void);
	UniverseID GetCommonContext(UniverseID componentid, UniverseID othercomponentid, bool includeself, bool includeother, UniverseID limitid, bool includelimit);
	const char* GetComponentClass(UniverseID componentid);
	const char* GetComponentName(UniverseID componentid);
	int GetConfigSetting(const char*const setting);
	const char* GetContainerBuildMethod(UniverseID containerid);
	TradeRuleID GetContainerTradeRuleID(UniverseID containerid, const char* ruletype, const char* wareid);
	uint32_t GetContainerWareReservations2(WareReservationInfo2* result, uint32_t resultlen, UniverseID containerid, bool includevirtual, bool includemission, bool includesupply);
	UniverseID GetContextByClass(UniverseID componentid, const char* classname, bool includeself);
	UniverseID GetContextByRealClass(UniverseID componentid, const char* classname, bool includeself);
	BlacklistID GetControllableBlacklistID(UniverseID controllableid, const char* listtype, const char* defaultgroup);
	FightRuleID GetControllableFightRuleID(UniverseID controllableid, const char* listtype);
	const char* GetCurrentAmmoOfWeapon(UniverseID weaponid);
	const char* GetCurrentBoardingPhase(UniverseID defensibletargetid, const char* boarderfactionid);
	float GetCurrentBuildProgress(UniverseID containerid);
	const char* GetCurrentDroneMode(UniverseID defensibleid, const char* dronetype);
	uint32_t GetCurrentMissionOffers(uint64_t* result, uint32_t resultlen, bool showninbbs);
	UILogo GetCurrentPlayerLogo(void);
	int64_t GetCurrentUTCDataTime(void);
	bool GetDefaultOrder(Order* result, UniverseID controllableid);
	bool GetDefaultOrderFailure(OrderFailure* result, UniverseID controllableid);
	const char* GetDefaultResponseToSignalForControllable(const char* signalid, UniverseID controllableid);
	const char* GetDefaultResponseToSignalForFaction(const char* signalid, const char* factionid);
	uint32_t GetDefensibleActiveWeaponGroup(UniverseID defensibleid, bool primary);
	uint32_t GetDefensibleDPS(DPSData* result, UniverseID defensibleid, bool primary, bool secondary, bool lasers, bool missiles, bool turrets, bool includeheat, bool includeinactive);
	uint32_t GetDefensibleDeployableCapacity(UniverseID defensibleid);
	float GetDefensibleLoadoutLevel(UniverseID defensibleid);
	uint32_t GetDiscoveredSectorResources(WareYield* result, uint32_t resultlen, UniverseID sectorid);
	uint32_t GetDockedShips(UniverseID* result, uint32_t resultlen, UniverseID dockingbayorcontainerid, const char* factionid);
	uint32_t GetDroneModes(DroneModeInfo* result, uint32_t resultlen, UniverseID defensibleid, const char* dronetype);
	int32_t GetEntityCombinedSkill(UniverseID entityid, const char* role, const char* postid);
	FactionDetails GetFactionDetails(const char* factionid);
	const char* GetFleetName(UniverseID controllableid);
	uint32_t GetFormationShapes(UIFormationInfo* result, uint32_t resultlen);
	uint32_t GetFreeCountermeasureStorageAfterTradeOrders(UniverseID defensibleid);
	uint32_t GetFreeDeployableStorageAfterTradeOrders(UniverseID defensibleid);
	uint32_t GetFreeMissileStorageAfterTradeOrders(UniverseID defensibleid);
	uint32_t GetFreePeopleCapacity(UniverseID controllableid);
	uint32_t GetIllegalToFactions(const char** result, uint32_t resultlen, const char* wareid);
	UniverseID GetInstantiatedPerson(NPCSeed person, UniverseID controllableid);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	uint32_t GetMapComponentMissions(MissionID* result, uint32_t resultlen, UniverseID holomapid, UniverseID componentid);
	UniverseID GetMapFocusComponent(UniverseID holomapid);
	UniverseID GetMapPositionOnEcliptic2(UniverseID holomapid, UIPosRot* position, bool adaptiveecliptic, UniverseID eclipticsectorid, UIPosRot eclipticoffset);
	uint32_t GetMapRenderedComponents(UniverseID* result, uint32_t resultlen, UniverseID holomapid);
	uint32_t GetMapSelectedComponents(UniverseID* result, uint32_t resultlen, UniverseID holomapid);
	void GetMapState(UniverseID holomapid, HoloMapState* state);
	UIMapTradeVolumeParameter GetMapTradeVolumeParameter(void);
	uint32_t GetMaxProductionStorage(UIWareAmount* result, uint32_t resultlen, UniverseID containerid);
	uint32_t GetMineablesAtSectorPos(YieldInfo* result, uint32_t resultlen, UniverseID sectorid, Coord3D position);
	Coord3D GetMinimumBuildPlotCenterOffset(UniverseID stationid);
	Coord3D GetMinimumBuildPlotSize(UniverseID stationid);
	MissionBriefingIconInfo GetMissionBriefingIcon(MissionID missionid);
	void GetMissionDeliveryWares(MissionWareDeliveryInfo* result, MissionID missionid);
	MissionGroupDetails GetMissionGroupDetails(MissionID missionid);
	uint32_t GetMissionThreadSubMissions(MissionID* result, uint32_t resultlen, MissionID missionid);
	MissionDetails GetMissionIDDetails(uint64_t missionid);
	MissionObjectiveStep3 GetMissionObjectiveStep3(uint64_t missionid, size_t objectiveIndex);
	OnlineMissionInfo GetMissionOnlineInfo(MissionID missionid);
	uint32_t GetNumAllBlacklists(void);
	uint32_t GetNumAllBoardingBehaviours(void);
	uint32_t GetNumAllBoardingPhases(void);
	uint32_t GetNumAllControlPosts(void);
	uint32_t GetNumAllCountermeasures(UniverseID defensibleid);
	uint32_t GetNumAllFightRules(void);
	uint32_t GetNumAllInventoryBombs(UniverseID entityid);
	uint32_t GetNumAllLaserTowers(UniverseID defensibleid);
	uint32_t GetNumAllMines(UniverseID defensibleid);
	uint32_t GetNumAllMissiles(UniverseID defensibleid);
	uint32_t GetNumAllNavBeacons(UniverseID defensibleid);
	uint32_t GetNumAllResourceProbes(UniverseID defensibleid);
	uint32_t GetNumAllSatellites(UniverseID defensibleid);
	uint32_t GetNumAllModuleSets();
	uint32_t GetNumAllowedWeaponSystems(void);
	uint32_t GetNumAllRaces(void);
	uint32_t GetNumAllResponsesToSignal(const char* signalid);
	uint32_t GetNumAllRoles(void);
	uint32_t GetNumAllSignals(void);
	uint32_t GetNumAttackersOfBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid);
	uint32_t GetNumBoardingMarinesFromOperation(UniverseID defensibletargetid, const char* boarderfactionid);
	uint32_t GetNumBuildTasks(UniverseID containerid, UniverseID buildmoduleid, bool isinprogress, bool includeupgrade);
	uint32_t GetNumCargoTransportTypes(UniverseID containerid, bool merge);
	uint32_t GetNumContainerWareReservations2(UniverseID containerid, bool includevirtual, bool includemission, bool includesupply);
	uint32_t GetNumCurrentMissionOffers(bool showninbbs);
	uint32_t GetNumDiscoveredSectorResources(UniverseID sectorid);
	uint32_t GetNumDockedShips(UniverseID dockingbayorcontainerid, const char* factionid);
	uint32_t GetNumDroneModes(UniverseID defensibleid, const char* dronetype);
	uint32_t GetNumFormationShapes(void);
	uint32_t GetNumIllegalToFactions(const char* wareid);
	uint32_t GetNumMapComponentMissions(UniverseID holomapid, UniverseID componentid);
	uint32_t GetNumMapRenderedComponents(UniverseID holomapid);
	uint32_t GetNumMapSelectedComponents(UniverseID holomapid);
	uint32_t GetNumMaxProductionStorage(UniverseID containerid);
	uint32_t GetNumMineablesAtSectorPos(UniverseID sectorid, Coord3D position);
	uint32_t GetNumMissionDeliveryWares(MissionID missionid);
	uint32_t GetNumMissionThreadSubMissions(MissionID missionid);
	uint32_t GetNumObjectsWithSyncPoint(uint32_t syncid, bool onlyreached);
	uint32_t GetNumOrderDefinitions(void);
	uint32_t GetNumOrderFailures(UniverseID controllableid, bool includelooporders);
	uint32_t GetNumOrderLocationData(UniverseID controllableid, size_t orderidx, bool usedefault);
	uint32_t GetNumOrders(UniverseID controllableid);
	uint32_t GetNumPeopleAfterOrders(UniverseID controllableid, int32_t numorders);
	uint32_t GetNumPersonSuitableControlPosts(UniverseID controllableid, UniverseID personcontrollableid, NPCSeed person, bool free);
	size_t GetNumPlannedStationModules(UniverseID defensibleid, bool includeall);
	uint32_t GetNumPlayerBuildMethods(void);
	uint32_t GetNumPlayerShipBuildTasks(bool isinprogress, bool includeupgrade);
	uint32_t GetNumRequestedMissionNPCs(UniverseID containerid);
	uint32_t GetNumSkills(void);
	uint32_t GetNumShieldGroups(UniverseID defensibleid);
	uint32_t GetNumSoftwareSlots(UniverseID controllableid, const char* macroname);
	uint32_t GetNumStationModules(UniverseID stationid, bool includeconstructions, bool includewrecks);
	uint32_t GetNumStoredUnits(UniverseID defensibleid, const char* cat, bool virtualammo);
	uint32_t GetNumSuitableControlPosts(UniverseID controllableid, UniverseID entityid, bool free);
	uint32_t GetNumTiersOfRole(const char* role);
	size_t GetNumTradeComputerOrders(UniverseID controllableid);
	uint32_t GetNumUpgradeGroups(UniverseID destructibleid, const char* macroname);
	size_t GetNumUpgradeSlots(UniverseID destructibleid, const char* macroname, const char* upgradetypename);
	size_t GetNumVirtualUpgradeSlots(UniverseID objectid, const char* macroname, const char* upgradetypename);
	uint32_t GetNumWareBlueprintOwners(const char* wareid);
	uint32_t GetNumWares(const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	uint32_t GetNumWeaponGroupsByWeapon(UniverseID defensibleid, UniverseID weaponid);
	const char* GetObjectIDCode(UniverseID objectid);
	UIPosRot GetObjectPositionInSector(UniverseID objectid);
	bool GetOrderDefinition(OrderDefinition* result, const char* orderdef);
	uint32_t GetOrderDefinitions(OrderDefinition* result, uint32_t resultlen);
	uint32_t GetOrderFailures(OrderFailure* result, uint32_t resultlen, UniverseID controllableid, bool includelooporders);
	AIOrderID GetOrderID(UniverseID controllableid, size_t orderidx);
	uint32_t GetOrderLocationData(UniverseID* result, uint32_t resultlen, UniverseID controllableid, size_t orderidx, bool usedefault);
	uint32_t GetOrderLoopSkillLimit();
	size_t GetOrderQueueCurrentIdx(UniverseID controllableid);
	size_t GetOrderQueueFirstLoopIdx(UniverseID controllableid, bool* isvalid);
	uint32_t GetOrders(Order* result, uint32_t resultlen, UniverseID controllableid);
	uint32_t GetOrders2(Order2* result, uint32_t resultlen, UniverseID controllableid);
	FactionDetails GetOwnerDetails(UniverseID componentid);
	Coord3D GetPaidBuildPlotCenterOffset(UniverseID stationid);
	Coord3D GetPaidBuildPlotSize(UniverseID stationid);
	UniverseID GetParentComponent(UniverseID componentid);
	uint32_t GetPeople(PeopleInfo* result, uint32_t resultlen, UniverseID controllableid);
	uint32_t GetPeopleAfterOrders(NPCInfo* result, uint32_t resultlen, UniverseID controllableid, int32_t numorders);
	uint32_t GetPeopleCapacity(UniverseID controllableid, const char* macroname, bool includecrew);
	int32_t GetPersonCombinedSkill(UniverseID controllableid, NPCSeed person, const char* role, const char* postid);
	const char* GetPersonName(NPCSeed person, UniverseID controllableid);
	const char* GetPersonRole(NPCSeed person, UniverseID controllableid);
	uint32_t GetPersonSkills3(SkillInfo* result, uint32_t resultlen, NPCSeed person, UniverseID controllableid);
	uint32_t GetPersonSkillsForAssignment(Skill2* result, NPCSeed person, UniverseID controllableid, const char* role, const char* postid);
	uint32_t GetPersonSuitableControlPosts(ControlPostInfo* result, uint32_t resultlen, UniverseID controllableid, UniverseID personcontrollableid, NPCSeed person, bool free);
	int32_t GetPersonTier(NPCSeed npc, const char* role, UniverseID controllableid);
	UniverseID GetPickedMapComponent(UniverseID holomapid);
	MissionID GetPickedMapMission(UniverseID holomapid);
	UniverseID GetPickedMapMissionOffer(UniverseID holomapid);
	UniverseID GetPickedMapOrder(UniverseID holomapid, Order* result, bool* intermediate);
	uint32_t GetPickedMapSyncPoint(UniverseID holomapid);
	UniverseID GetPickedMapSyncPointOwningOrder(UniverseID holomapid, Order* result);
	TradeID GetPickedMapTradeOffer(UniverseID holomapid);
	MultiverseMapPickInfo GetPickedMultiverseMapPlayer(UniverseID holomapid);
	bool GetPlannedDefaultOrder(Order* result, UniverseID controllableid);
	size_t GetPlannedStationModules(UIConstructionPlanEntry* result, uint32_t resultlen, UniverseID defensibleid, bool includeall);
	const char* GetPlayerBuildMethod(void);
	uint32_t GetPlayerBuildMethods(ProductionMethodInfo* result, uint32_t resultlen);
	UniverseID GetPlayerComputerID(void);
	UniverseID GetPlayerContainerID(void);
	UniverseID GetPlayerControlledShipID(void);
	float GetPlayerGlobalLoadoutLevel(void);
	UniverseID GetPlayerID(void);
	UniverseID GetPlayerObjectID(void);
	UniverseID GetPlayerOccupiedShipID(void);
	uint32_t GetPlayerShipBuildTasks(BuildTaskInfo* result, uint32_t resultlen, bool isinprogress, bool includeupgrade);
	UIPosRot GetPlayerTargetOffset(void);
	const char* GetRealComponentClass(UniverseID componentid);
	uint32_t GetRequestedMissionNPCs(MissionNPCInfo* result, uint32_t resultlen, UniverseID containerid);
	uint32_t GetRoleTierNPCs(NPCSeed* result, uint32_t resultlen, UniverseID controllableid, const char* role, int32_t skilllevel);
	uint32_t GetRoleTiers(RoleTierData* result, uint32_t resultlen, UniverseID controllableid, const char* role);
	UniverseID GetSectorControlStation(UniverseID sectorid);
	uint64_t GetSectorPopulation(UniverseID sectorid);
	uint32_t GetShieldGroups(ShieldGroup* result, uint32_t resultlen, UniverseID defensibleid);
	int32_t GetShipCombinedSkill(UniverseID shipid);
	SofttargetDetails GetSofttarget(void);
	uint32_t GetSoftwareSlots(SoftwareSlot* result, uint32_t resultlen, UniverseID controllableid, const char* macroname);
	uint32_t GetStationModules(UniverseID* result, uint32_t resultlen, UniverseID stationid, bool includeconstructions, bool includewrecks);
	const char* GetSubordinateGroupAssignment(UniverseID controllableid, int group);
	uint32_t GetSuitableControlPosts(ControlPostInfo* result, uint32_t resultlen, UniverseID controllableid, UniverseID entityid, bool free);
	bool GetSyncPointAutoRelease(uint32_t syncid, bool checkall);
	bool GetSyncPointAutoReleaseFromOrder(UniverseID controllableid, size_t orderidx, bool checkall);
	bool GetSyncPointInfo2(UniverseID controllableid, size_t orderidx, SyncPointInfo2* result);
	float GetTextHeight(const char*const text, const char*const fontname, const float fontsize, const float wordwrapwidth);
	uint32_t GetTiersOfRole(RoleTierData* result, uint32_t resultlen, const char* role);
	UniverseID GetTopLevelContainer(UniverseID componentid);
	int64_t GetTradeWareBudget(UniverseID containerid);
	const char* GetTurretGroupMode2(UniverseID defensibleid, UniverseID contextid, const char* path, const char* group);
	UpgradeGroupInfo GetUpgradeGroupInfo2(UniverseID destructibleid, const char* macroname, UniverseID contextid, const char* path, const char* group, const char* upgradetypename);
	uint32_t GetUpgradeGroups2(UpgradeGroup2* result, uint32_t resultlen, UniverseID destructibleid, const char* macroname);
	UniverseID GetUpgradeSlotCurrentComponent(UniverseID destructibleid, const char* upgradetypename, size_t slot);
	UpgradeGroup GetUpgradeSlotGroup(UniverseID destructibleid, const char* macroname, const char* upgradetypename, size_t slot);
	const char* GetVirtualUpgradeSlotCurrentMacro(UniverseID defensibleid, const char* upgradetypename, size_t slot);
	uint32_t GetWareBlueprintOwners(const char** result, uint32_t resultlen, const char* wareid);
	uint32_t GetWareReservationsForWare(UniverseID containerid, const char* wareid, bool buy);
	uint32_t GetWares(const char** result, uint32_t resultlen, const char* tags, bool research, const char* licenceownerid, const char* exclusiontags);
	uint32_t GetWeaponGroupsByWeapon(UIWeaponGroup* result, uint32_t resultlen, UniverseID defensibleid, UniverseID weaponid);
	const char* GetWeaponMode(UniverseID weaponid);
	WorkForceInfo GetWorkForceInfo(UniverseID containerid, const char* raceid);
	UniverseID GetZoneAt(UniverseID sectorid, UIPosRot* uioffset);
	bool HasAcceptedOnlineMission(void);
	bool HasContainerOwnTradeRule(UniverseID containerid, const char* ruletype, const char* wareid);
	bool HasControllableAnyOrderFailures(UniverseID controllableid);
	bool HasControllableOwnBlacklist(UniverseID controllableid, const char* listtype);
	bool HasControllableOwnFightRule(UniverseID controllableid, const char* listtype);
	bool HasControllableOwnResponse(UniverseID controllableid, const char* signalid);
	bool HasPersonArrived(UniverseID controllableid, NPCSeed person);
	bool IsAmmoMacroCompatible(const char* weaponmacroname, const char* ammomacroname);
	bool IsBuilderBusy(UniverseID shipid);
	bool IsComponentBlacklisted(UniverseID componentid, const char* listtype, const char* defaultgroup, UniverseID controllableid);
	bool IsComponentClass(UniverseID componentid, const char* classname);
	bool IsComponentOperational(UniverseID componentid);
	bool IsComponentWrecked(UniverseID componentid);
	bool IsContainerTradingWithFactionRescricted(UniverseID containerid, const char* factionid);
	bool IsContestedSector(UniverseID sectorid);
	bool IsControlPressed(void);
	bool IsCurrentBuildMapPlotPositionDiscovered(UniverseID sectorid, UIPosRot location, float x, float y, float z);
	bool IsCurrentBuildMapPlotValid(UniverseID holomapid);
	bool IsCurrentOrderCritical(UniverseID controllableid);
	bool IsDefensibleBeingBoardedBy(UniverseID defensibleid, const char* factionid);
	bool IsDroneTypeArmed(UniverseID defensibleid, const char* dronetype);
	bool IsDroneTypeBlocked(UniverseID defensibleid, const char* dronetype);
	bool IsExternalTargetMode();
	bool IsExternalViewActive();
	bool IsFactionHQ(UniverseID stationid);
	bool IsIconValid(const char* iconid);
	bool IsInfoUnlockedForPlayer(UniverseID componentid, const char* infostring);
	bool IsKnownToPlayer(UniverseID componentid);
	bool IsMasterVersion(void);
	bool IsMissionLimitReached(bool includeupkeep, bool includeguidance, bool includeplot);
	bool IsObjectKnown(const UniverseID componentid);
	bool IsOrderLoopable(const char* orderdefid);
	bool IsOrderSelectableFor(const char* orderdefid, UniverseID controllableid);
	bool IsPerson(NPCSeed person, UniverseID controllableid);
	bool IsPersonTransferScheduled(UniverseID controllableid, NPCSeed person);
	bool IsPlayerBlacklistDefault(BlacklistID id, const char* listtype, const char* defaultgroup);
	bool IsPlayerCameraTargetViewPossible(UniverseID targetid, bool force);
	bool IsPlayerFightRuleDefault(FightRuleID id, const char* listtype);
	bool IsRealComponentClass(UniverseID componentid, const char* classname);
	bool IsShiftPressed(void);
	bool IsShipAtExternalDock(UniverseID shipid);
	bool IsStoryFeatureUnlocked(const char* featureid);
	bool IsTurretGroupArmed(UniverseID defensibleid, UniverseID contextid, const char* path, const char* group);
	bool IsUICoverOverridden(void);
	bool IsUnit(UniverseID controllableid);
	bool IsWeaponArmed(UniverseID weaponid);
	void LaunchLaserTower(UniverseID defensibleid, const char* lasertowermacroname);
	void LaunchMine(UniverseID defensibleid, const char* minemacroname);
	void LaunchNavBeacon(UniverseID defensibleid, const char* navbeaconmacroname);
	void LaunchResourceProbe(UniverseID defensibleid, const char* resourceprobemacroname);
	void LaunchSatellite(UniverseID defensibleid, const char* satellitemacroname);
	void PayBuildPlotSize(UniverseID stationid, Coord3D plotsize, Coord3D plotcenter);
	UICrewExchangeResult PerformCrewExchange(UniverseID controllableid, UniverseID partnercontrollableid, NPCSeed* npcs, uint32_t numnpcs, NPCSeed* partnernpcs, uint32_t numpartnernpcs, NPCSeed captainfromcontainer, NPCSeed captainfrompartner, bool checkonly);
	void ReassignPeople(UniverseID controllableid, CrewTransferContainer* reassignedcrew, uint32_t amount);
	void ReleaseConstructionMapState(void);
	void ReleasePersonFromCrewTransfer(UniverseID controllableid, NPCSeed person);
	void ReleaseOrderSyncPoint(uint32_t syncid);
	void ReleaseOrderSyncPointFromOrder(UniverseID controllableid, size_t idx);
	bool RemoveAllOrders(UniverseID controllableid);
	bool RemoveAttackerFromBoardingOperation(UniverseID defensibleboarderid);
	bool RemoveBuildPlot(UniverseID stationid);
	bool RemoveCommander2(UniverseID controllableid);
	void RemoveDefaultOrderFailure(UniverseID controllableid);
	void RemoveHoloMap(void);
	bool RemoveOrder(UniverseID controllableid, size_t idx, bool playercancelled, bool checkonly);
	void RemoveOrderFailure(UniverseID controllableid, uint32_t id);
	void RemoveOrderSyncPointID(UniverseID controllableid, size_t orderidx);
	void RemovePerson(UniverseID controllableid, NPCSeed person);
	void RemovePlannedDefaultOrder(UniverseID controllableid);
	UniverseID ReserveBuildPlot(UniverseID sectorid, const char* factionid, const char* set, UIPosRot location, float x, float y, float z);
	void ResetOrderLoop(UniverseID controllableid);
	bool ResetResponseToSignalForControllable(const char* signalid, UniverseID controllableid);
	void RevealEncyclopedia(void);
	void RevealMap(void);
	void RevealStations(void);
	bool SetActiveMission(MissionID missionid);
	void SelectSimilarMapComponents(UniverseID holomapid, UniverseID componentid);
	void SellPlayerShip(UniverseID shipid, UniverseID shipyardid);
	void SetAllMissileTurretModes(UniverseID defensibleid, const char* mode);
	void SetAllMissileTurretsArmed(UniverseID defensibleid, bool arm);
	void SetAllNonMissileTurretModes(UniverseID defensibleid, const char* mode);
	void SetAllNonMissileTurretsArmed(UniverseID defensibleid, bool arm);
	void SetAllowedWeaponSystems(UniverseID defensibleid, size_t orderidx, bool usedefault, WeaponSystemInfo* uiweaponsysteminfo, uint32_t numuiweaponsysteminfo);
	void SetAllTurretModes(UniverseID defensibleid, const char* mode);
	void SetAllTurretsArmed(UniverseID defensibleid, bool arm);
	bool SetAmmoOfWeapon(UniverseID weaponid, const char* newammomacro);
	void SetCheckBoxChecked2(const int checkboxid, bool checked, bool update);
	bool SetCommander(UniverseID controllableid, UniverseID commanderid, const char* assignment);
	void SetConfigSetting(const char*const setting, const bool value);
	void SetContainerBuildMethod(UniverseID containerid, const char* buildmethodid);
	void SetContainerTradeRule(UniverseID containerid, TradeRuleID id, const char* ruletype, const char* wareid, bool value);
	void SetControllableBlacklist(UniverseID controllableid, BlacklistID id, const char* listtype, bool value);
	void SetControllableFightRule(UniverseID controllableid, FightRuleID id, const char* listtype, bool value);
	bool SetDefaultResponseToSignalForControllable(const char* newresponse, bool ask, const char* signalid, UniverseID controllableid);
	bool SetDefaultResponseToSignalForFaction(const char* newresponse, bool ask, const char* signalid, const char* factionid);
	void SetDefensibleActiveWeaponGroup(UniverseID defensibleid, bool primary, uint32_t groupidx);
	void SetDefensibleLoadoutLevel(UniverseID defensibleid, float value);
	void SetDroneMode(UniverseID defensibleid, const char* dronetype, const char* mode);
	void SetDroneTypeArmed(UniverseID defensibleid, const char* dronetype, bool arm);
	void SetEditBoxText(const int editboxid, const char* text);
	void SetFleetName(UniverseID controllableid, const char* fleetname);
	void SetFocusMapComponent(UniverseID holomapid, UniverseID componentid, bool resetplayerpan);
	void SetFocusMapOrder(UniverseID holomapid, UniverseID controllableid, size_t orderidx, bool resetplayerpan);
	UIFormationInfo SetFormationShape(UniverseID objectid, const char* formationshape);
	bool SetEntityToPost(UniverseID controllableid, UniverseID entityid, const char* postid);
	void SetGuidance(UniverseID componentid, UIPosRot offset);
	void SetMapDefaultOrderParamObjectFilter(UniverseID holomapid, UniverseID ordercontrollableid, bool planned, size_t paramidx);
	void SetMapFactionRelationColorOption(UniverseID holomapid, bool value);
	void SetMapFilterString(UniverseID holomapid, uint32_t numtexts, const char** textarray);
	void SetMapObjectFilter(UniverseID holomapid, const char** classes, uint32_t numclasses, int32_t playerowned, bool allowentitydeliverymissionobject);
	void SetMapOrderParamObjectFilter(UniverseID holomapid, UniverseID ordercontrollableid, size_t orderidx, size_t paramidx);
	void SetMapPanOffset(UniverseID holomapid, UniverseID offsetcomponentid);
	void SetMapPicking(UniverseID holomapid, bool enable);
	void SetMapRelativeMousePosition(UniverseID holomapid, bool valid, float x, float y);
	void SetMapRenderAllAllyOrderQueues(UniverseID holomapid, bool value);
	void SetMapRenderAllGateConnections(UniverseID holomapid, bool value);
	void SetMapRenderAllOrderQueues(UniverseID holomapid, bool value);
	void SetMapRenderCivilianShips(UniverseID holomapid, bool value);
	void SetMapRenderEclipticLines(UniverseID holomapid, bool value);
	void SetMapRenderMissionGuidance(UniverseID holomapid, MissionID missionid);
	void SetMapRenderMissionOffers(UniverseID holomapid, bool value);
	void SetMapRenderResourceInfo(UniverseID holomapid, bool value);
	void SetMapRenderSatelliteRadarRange(UniverseID holomapid, bool value);
	void SetMapRenderSelectionLines(UniverseID holomapid, bool value);
	void SetMapRenderTradeOffers(UniverseID holomapid, bool value);
	void SetMapRenderWrecks(UniverseID holomapid, bool value);
	void SetMapState(UniverseID holomapid, HoloMapState state);
	void SetMapStationInfoBoxMargin(UniverseID holomapid, const char* margin, uint32_t width);
	void SetMapTargetDistance(UniverseID holomapid, float distance);
	void SetMapTopTradesCount(UniverseID holomapid, uint32_t count);
	void SetMapTradeFilterByMaxPrice(UniverseID holomapid, int64_t price);
	void SetMapTradeFilterByMinTotalVolume(UniverseID holomapid, uint32_t minvolume);
	void SetMapTradeFilterByPlayerOffer(UniverseID holomapid, bool buysellswitch, bool enable);
	void SetMapTradeFilterByWare(UniverseID holomapid, const char** wareids, uint32_t numwareids);
	void SetMapTradeFilterByWareTransport(UniverseID holomapid, const char** transporttypes, uint32_t numtransporttypes);
	void SetMapTradeFilterByWillingToTradeWithPlayer(UniverseID holomapid);
	void SetMapAlertFilter(UniverseID holomapid, uint32_t alertlevel);
	bool SetOrderLoop(UniverseID controllableid, size_t orderidx, bool checkonly);
	bool SetOrderSyncPointID(UniverseID controllableid, size_t orderidx, uint32_t syncid, bool checkonly);
	void SetPlayerCameraCockpitView(bool force);
	void SetPlayerCameraTargetView(UniverseID targetid, bool force);
	void SetSelectedMapComponent(UniverseID holomapid, UniverseID componentid);
	void SetSelectedMapComponents(UniverseID holomapid, UniverseID* componentids, uint32_t numcomponentids);
	bool SetSofttarget(UniverseID componentid, const char*const connectionname);
	void SetSubordinateGroupAssignment(UniverseID controllableid, int group, const char* assignment);
	void SetSubordinateGroupDockAtCommander(UniverseID controllableid, int group, bool value);
	void SetSyncPointAutoRelease(uint32_t syncid, bool all, bool any);
	void SetSyncPointAutoReleaseFromOrder(UniverseID controllableid, size_t orderidx, bool all, bool any);
	void SetTrackedMenuFullscreen(const char* menu, bool fullscreen);
	void SetTurretGroupArmed(UniverseID defensibleid, UniverseID contextid, const char* path, const char* group, bool arm);
	void SetTurretGroupMode2(UniverseID defensibleid, UniverseID contextid, const char* path, const char* group, const char* mode);
	void SetUICoverOverride(bool override);
	void SetWeaponArmed(UniverseID weaponid, bool arm);
	void SetWeaponGroup(UniverseID defensibleid, UniverseID weaponid, bool primary, uint32_t groupidx, bool value);
	void SetWeaponMode(UniverseID weaponid, const char* mode);
	bool ShouldSubordinateGroupDockAtCommander(UniverseID controllableid, int group);
	void ShowBuildPlotPlacementMap(UniverseID holomapid, UniverseID sectorid);
	void ShowMultiverseMap(UniverseID holomapid);
	void ShowUniverseMap2(UniverseID holomapid, bool setoffset, bool showzone, bool forcebuildershipicons, UniverseID startsectorid, UIPosRot startpos);
	void SignalObjectWithNPCSeedAndMissionID(UniverseID objecttosignalid, const char* param, MissionID missionid, NPCSeed person, UniverseID controllableid);
	void SpawnObjectAtPos(const char* macroname, UniverseID sectorid, UIPosRot offset);
	bool StartBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid);
	void StartPanMap(UniverseID holomapid);
	void StartRotateMap(UniverseID holomapid);
	bool StopPanMap(UniverseID holomapid);
	bool StopRotateMap(UniverseID holomapid);
	void ZoomMap(UniverseID holomapid, float zoomstep);
	void StartMapBoxSelect(UniverseID holomapid, bool selectenemies);
	void StopMapBoxSelect(UniverseID holomapid);
	bool ToggleAutoPilot(bool checkonly);
	bool UpdateAttackerOfBoardingOperation(UniverseID defensibletargetid, UniverseID defensibleboarderid, const char* boarderfactionid, const char* actionid, uint32_t* marinetieramounts, int32_t* marinetierskilllevels, uint32_t nummarinetiers);
	bool UpdateBoardingOperation(UniverseID defensibletargetid, const char* boarderfactionid, uint32_t approachthreshold, uint32_t insertionthreshold);
	void UpdateMapBuildPlot(UniverseID holomapid);
]]

local utf8 = require("utf8")

local Lib = require("extensions.sn_mod_support_apis.lua_library")

local orig = {}
local utRenaming = {}


local function init()
	--DebugError("my mod init")
   for _, menu in ipairs(Menus) do
       if menu.name == "MapMenu" then
             orig.menu = menu -- save entire menu, for other helper function access
       	      -- save original function
			orig.setupInfoSubmenuRows=menu.setupInfoSubmenuRows
			menu.setupInfoSubmenuRows=utRenaming.setupInfoSubmenuRows

			 orig.infoChangeObjectName=menu.infoChangeObjectName
			 menu.infoChangeObjectName=utRenaming.infoChangeObjectName
          break
      end
   end
end

function utRenaming.setupInfoSubmenuRows(mode, inputtable, inputobject, instance)
	orig.setupInfoSubmenuRows(mode, inputtable, inputobject, instance)
	if inputtable.rows[4][4] and inputtable.rows[4][4]["type"] == "editbox" then
		--Lib.Print_Table(inputtable.rows[4][4], "1st column")
		if ReadText(5554302, 2) == "yes" then 
			-- Make Editbox bigger - produces some harmless errors
			inputtable.rows[4][2]:setColSpan(1)
			inputtable.rows[4][3]:setColSpan(6):createEditBox({ height = config.mapRowHeight, description = locrowdata[2] }):setText(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or inputtable.rows[4][4].properties.text.text, { halign = "right" })
			inputtable.rows[4][3].handlers.onEditBoxDeactivated = function(_, text, textchanged) return utRenaming.infoChangeObjectName(inputobject, text, textchanged) end
		else
			-- just replace the String if appliable - error free, but smaller text field
			if GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] then
				inputtable.rows[4][4]:setText(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject])
			end
			inputtable.rows[4][4].handlers.onEditBoxDeactivated = function(_, text, textchanged) return utRenaming.infoChangeObjectName(inputobject, text, textchanged) end
		end
		--Lib.Print_Table(inputtable.rows[4][4].properties.text, "4th column")
	end
end


function utRenaming.infoChangeObjectName(objectid, text, textchanged)
    if textchanged then
		SetComponentName(objectid, text)
	end
    -- UniTrader change: Set Signal Universe/Object instead of actual renaming (which is handled in MD)
    SignalObject(GetComponentData(objectid, "galaxyid" ) , "Object Name Updated" , { ConvertStringToLuaID(tostring(objectid)) , objectid } , text)
    -- UniTrader Changes end (next line was a if before, but i have some diffrent conditions)

	orig.menu.noupdate = false
	orig.menu.refreshInfoFrame()
end

init()