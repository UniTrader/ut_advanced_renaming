local ffi = require("ffi")
local C = ffi.C


local menu = {}
local utRenaming = {}

local function init()
	-- DebugError("UniTrader Advanced Rename Init")
	menu = Helper.getMenu("MapMenu")
	menu.registerCallback("utRenaming_setupInfoSubmenuRows_on_end", utRenaming.setupInfoSubmenuRows_on_end)
	menu.registerCallback("utRenaming_infoChangeObjectName", utRenaming.infoChangeObjectName)
	menu.registerCallback("utRenaming_createRenameContext_get_startname", utRenaming.createRenameContext_get_startname)
	menu.registerCallback("utRenaming_createRenameContext_on_after_confirm_button", utRenaming.createRenameContext_on_after_confirm_button)
	menu.registerCallback("utRenaming_buttonRenameConfirm", utRenaming.buttonRenameConfirm)
end

function utRenaming.setupInfoSubmenuRows_on_end(mode, inputtable, inputobject, instance)
	if inputtable.rows[4][4] and inputtable.rows[4][4]["type"] == "editbox" then
		--Helper.debugText_forced(inputtable.rows[4][4], "1st column")
		
		-- needs to be done the complicated way, because lua...
		--Helper.debugText_forced(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names"), "Name Table")
		local editname
		for k,v in pairs(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")) do
			--DebugError(tostring(k))
			--DebugError("ID: "..tostring(inputobject))
			if tostring(k) == "ID: "..tostring(inputobject) then
				editname = v
				--DebugError(editname)
				break
			end
		end
		if ReadText(5554302, 2) == "yes" then 
			-- Make Editbox bigger - produces some harmless errors
			inputtable.rows[4][2]:setColSpan(1)
			inputtable.rows[4][3]:setColSpan(6):createEditBox({ height = config.mapRowHeight, description = locrowdata[2] }):setText(editname or inputtable.rows[4][4].properties.text.text, { halign = "right" })
			inputtable.rows[4][3].handlers.onEditBoxDeactivated = function(_, text, textchanged)
				return menu.infoChangeObjectName(inputobject, text, textchanged)
			end
		else
			-- just replace the String if appliable - error free, but smaller text field
			if editname then
				inputtable.rows[4][4]:setText(editname)
			end
			inputtable.rows[4][4].handlers.onEditBoxDeactivated = function(_, text, textchanged)
				return menu.infoChangeObjectName(inputobject, text, textchanged)
			end
		end
	end
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

function utRenaming.createRenameContext_get_startname(frame)
	local startname
	if not menu.contextMenuData.fleetrename then
		for k,v in pairs(GetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())) , "$unformatted_names")) do
			if tostring(k) == "ID: "..tostring(menu.contextMenuData.component) then
				startname = v
				break
			end
		end
	end
	return startname
end

function utRenaming.createRenameContext_on_after_confirm_button(frame, shiptable)
	local row = shiptable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createText(ReadText(5554302,1001), Helper.headerRowCenteredProperties)

	local row = shiptable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createButton({  }):setText(ReadText(5554302,1002), { halign = "center" })
	row[1].handlers.onClick = function () return utRenaming.buttonMassRename("Subordinates Name Updated") end

	local row = shiptable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createButton({  }):setText(ReadText(5554302,1004), { halign = "center" })
	row[1].handlers.onClick = function () return utRenaming.buttonMassRename("Subordinates Name Updated - bigships") end

	local row = shiptable:addRow(true, { fixed = true, bgColor = Helper.color.transparent })
	row[1]:setColSpan(2):createButton({  }):setText(ReadText(5554302,1006), { halign = "center" })
	row[1].handlers.onClick = function () return utRenaming.buttonMassRename("Subordinates Name Updated - smallships") end
end

function utRenaming.buttonRenameConfirm()
	if menu.contextMenuData.uix_multiRename_objects and #menu.contextMenuData.uix_multiRename_objects > 0 then
		-- kuertee start: uix multi-rename
		local multirenamedobjects = {}
		for _, object in ipairs(menu.contextMenuData.uix_multiRename_objects) do
			multirenamedobjects[ConvertStringToLuaID(tostring(object))] = menu.contextMenuData.newtext
		end
		SetNPCBlackboard(ConvertStringTo64Bit(tostring(C.GetPlayerID())), "$multirenamedobjects", multirenamedobjects)
		SignalObject(GetComponentData(menu.contextMenuData.component, "galaxyid" ) , "multirename")
		-- kuertee end: uix multi-rename
	else
		SignalObject(GetComponentData(menu.contextMenuData.component, "galaxyid" ) , "Object Name Updated" , ConvertStringToLuaID(tostring(menu.contextMenuData.component)) , menu.contextMenuData.newtext)
	end
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