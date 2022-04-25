-- stuff copied from the original file required for function
local ffi = require("ffi")
local C = ffi.C
local utf8 = require("utf8")


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
		inputtable.rows[4][4]:setColSpan(5):createEditBox({ height = config.mapRowHeight, description = locrowdata[2] }):setText(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")[inputobject] or Helper.unlockInfo(nameinfo, ffi.string(C.GetComponentName(inputobject))), { halign = "right" })
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