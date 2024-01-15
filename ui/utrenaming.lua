local ffi = require("ffi")
local C = ffi.C

local Lib = require("extensions.sn_mod_support_apis.lua_library")

local menu = {}
local utRenaming = {}

local function init()
	-- DebugError("UniTrader Advanced Rename Init")

	menu = Lib.Get_Egosoft_Menu("MapMenu")

	menu.registerCallback("utRenaming_setupInfoSubmenuRows", utRenaming.setupInfoSubmenuRows)
	menu.registerCallback("utRenaming_infoChangeObjectName", utRenaming.infoChangeObjectName)
	menu.registerCallback("utRenaming_createRenameContext", utRenaming.createRenameContext)
	menu.registerCallback("utRenaming_createRenameContextTwo", utRenaming.createRenameContextTwo)
	menu.registerCallback("utRenaming_buttonRenameConfirm", utRenaming.buttonRenameConfirm)
end

function utRenaming.setupInfoSubmenuRows(row, instance, inputobject, objectname)
	row[2]:createText(locrowdata[2], { minRowHeight = config.mapRowHeight, fontsize = config.mapFontSize, font = Helper.standardFont, x = Helper.standardTextOffsetx })
	menu.shipNameEditBox = row[3]:setColSpan(6):createEditBox({ height = config.mapRowHeight, description = locrowdata[2] }):setText(objectname, { halign = "right" })
	row[3].handlers.onEditBoxActivated = function (widget) return utRenaming.unformatText(widget, instance, inputobject, row) end
	row[3].handlers.onEditBoxDeactivated = function(_, text, textchanged) return menu.infoChangeObjectName(inputobject, text, textchanged) end
	menu.shipNameEditBox.properties.text.halign = "left"
end

function utRenaming.unformatText(widget, instance, inputobject, row)
	menu.noupdate = true
	if menu.shipNameEditBox and (widget == menu.shipNameEditBox.id) then
		local editname
		for k,v in pairs(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")) do
			if tostring(k) == "ID: "..tostring(inputobject) then
				editname = v
				break
			end
		end

		if editname then
			C.SetEditBoxText(menu.shipNameEditBox.id, editname)
		end
	end
end

function utRenaming.infoChangeObjectName(objectid, text)
    SignalObject(GetComponentData(objectid, "galaxyid" ) , "Object Name Updated" , ConvertStringToLuaID(tostring(objectid)) , text)
end

function utRenaming.createRenameContext(frame)
	if not menu.contextMenuData.fleetrename then
		for k,v in pairs(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")) do
			if tostring(k) == "ID: "..tostring(menu.contextMenuData.component) then
				startname = v
				break
			end
		end
		return startname
	end
end

function utRenaming.createRenameContextTwo(frame, shiptable)
	if not menu.contextMenuData.fleetrename then
		local row = shiptable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(6):createText(ReadText(5554302,1001), Helper.headerRowCenteredProperties)
		
		local row = shiptable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
		row[1]:setColSpan(2):createButton({  }):setText(ReadText(5554302,1002), { halign = "center" })
		row[1].handlers.onClick = function () return utRenaming.buttonMassRename("Subordinates Name Updated") end
		row[3]:setColSpan(2):createButton({  }):setText(ReadText(5554302,1004), { halign = "center" })
		row[3].handlers.onClick = function () return utRenaming.buttonMassRename("Subordinates Name Updated - bigships") end
		row[5]:setColSpan(2):createButton({  }):setText(ReadText(5554302,1006), { halign = "center" })
		row[5].handlers.onClick = function () return utRenaming.buttonMassRename("Subordinates Name Updated - smallships") end
	end
end

function utRenaming.buttonRenameConfirm()
	SignalObject(GetComponentData(menu.contextMenuData.component, "galaxyid" ) , "Object Name Updated" , ConvertStringToLuaID(tostring(menu.contextMenuData.component)) , menu.contextMenuData.newtext)
end

function utRenaming.buttonMassRename(param)
	if menu.contextMenuData.newtext then
		SignalObject(GetComponentData(menu.contextMenuData.component, "galaxyid" ) , param , ConvertStringToLuaID(tostring(menu.contextMenuData.component)) , menu.contextMenuData.newtext)
		menu.noupdate = false
		menu.refreshInfoFrame()
		menu.closeContextMenu("back")
	end
end

init()