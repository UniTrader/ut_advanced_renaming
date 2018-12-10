
-- section == gMain_rename
-- param == { 0, 0, object }

local menu = {
	name = "RenameMenu",
	white = { r = 255, g = 255, b = 255, a = 100 },
	red = { r = 255, g = 0, b = 0, a = 100 }
}

local function init()
	Menus = Menus or { }
	table.insert(Menus, menu)
	if Helper then
		Helper.registerMenu(menu)
	end
end

function menu.cleanup()
	menu.title = nil
	menu.object = nil

	menu.infotable = nil
	menu.selecttable = nil

	menu.renamesubordinates = nil --UniTrader change: add script-local bool to indicate that Subordinates should be renamed rather than the Ship itself
	menu.keymod = nil -- Modifier for Caps and Shift on InGame-Keyboard
end

-- Menu member functions

function menu.editboxUpdateText(_, text, textchanged)
  if menu.editboxisactive then
    -- UniTrader change: Mass renaming function added
    if menu.renamesubordinates then
      if menu.renamesubordinates == "all" then
        SignalObject(GetComponentData(menu.object, "galaxyid" ) , "Subordinates Name Updated" , menu.object , text )
      elseif menu.renamesubordinates == "bigships" then
        SignalObject(GetComponentData(menu.object, "galaxyid" ) , "Subordinates Name Updated - bigships" , menu.object , text )
      elseif menu.renamesubordinates == "smallships" then
        SignalObject(GetComponentData(menu.object, "galaxyid" ) , "Subordinates Name Updated - smallships" , menu.object , text )
      end
    -- Renaming Function - now always renaming to force an update if needed
    elseif menu.controlentity then
      SetNPCBlackboard(menu.controlentity, "$unformatted_object_name" , text)
      SignalObject(GetComponentData(menu.object, "galaxyid" ) , "Object Name Updated" , menu.object )
    -- UniTrader Changes end (next line was a if before, but i have some diffrent conditions)
    elseif textchanged then
      SetComponentName(menu.object, text)
    end
    Helper.closeMenuAndReturn(menu)
    menu.cleanup()
  end
end

function menu.buttonOK()
	Helper.confirmEditBoxInput(menu.selecttable, 1, 1)
end

-- UniTrader new Functions: Mass Rename Subordinates
function menu.buttonRenameSubordinates()
	menu.renamesubordinates = "all"
	Helper.confirmEditBoxInput(menu.selecttable, 1, 1)
end
function menu.buttonRenameSubordinatesBigShips()
	menu.renamesubordinates = "bigships"
	Helper.confirmEditBoxInput(menu.selecttable, 1, 1)
end
function menu.buttonRenameSubordinatesSmallShips()
	menu.renamesubordinates = "smallships"
	Helper.confirmEditBoxInput(menu.selecttable, 1, 1)
end
-- Functions for Keyboard
function menu.TypeText(text)
	local cell = GetCellContent(menu.selecttable, 1, 1)
	if not menu.editboxisactive then
    Helper.activateEditBox(menu.selecttable, 1, 1)
  end
  TypeInEditBox(nil,text)
end
function menu.SetKeyMod(mod)
   if mod == 1 then
    --toggle Shift
    if (menu.keymod == 1) or  (menu.keymod == 3) or (menu.keymod == 5) or (menu.keymod == 7) then
      menu.keymod = menu.keymod - 1
      SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554302, 1201), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25) , 6, 1)
    else
      menu.keymod = menu.keymod + 1
      SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554302, 1202), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25) , 6, 1)
    end
    Helper.setButtonScript(menu, nil, menu.selecttable, 6, 1, function () return menu.SetKeyMod(1) end)
  elseif mod == 2 then
    --toggle Alt
    if (menu.keymod == 2) or (menu.keymod == 3) or (menu.keymod == 6) or (menu.keymod == 7) then
      menu.keymod = menu.keymod - 2
      SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554302, 1203), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25) , 6, 3)
    else
      menu.keymod = menu.keymod + 2
      SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554302, 1204), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25) , 6, 3)
    end
    Helper.setButtonScript(menu, nil, menu.selecttable, 6, 3, function () return menu.SetKeyMod(2) end)
  elseif (mod == 4) then
    --toggle Super
    if (menu.keymod == 4) or (menu.keymod == 5) or (menu.keymod == 6) or (menu.keymod == 7) then
      menu.keymod = menu.keymod - 4
      SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554302, 1206), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25) , 6, 7)
    else
      menu.keymod = menu.keymod + 4
      SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554302, 1207), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25) , 6, 7)
    end
    Helper.setButtonScript(menu, nil, menu.selecttable, 6, 7, function () return menu.SetKeyMod(4) end)
  end
  -- Update displayed Characters
  -- Number Row
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 110+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 110+menu.keymod) and true, 0, 0, 80, 25) , 2, 1)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 1, function () return menu.TypeText(ReadText(5554303, 110+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 120+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 120+menu.keymod) and true, 0, 0, 80, 25) , 2, 2)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 2, function () return menu.TypeText(ReadText(5554303, 120+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 130+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 130+menu.keymod) and true, 0, 0, 80, 25) , 2, 3)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 3, function () return menu.TypeText(ReadText(5554303, 130+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 140+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 140+menu.keymod) and true, 0, 0, 80, 25) , 2, 4)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 4, function () return menu.TypeText(ReadText(5554303, 140+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 150+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 150+menu.keymod) and true, 0, 0, 80, 25) , 2, 5)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 5, function () return menu.TypeText(ReadText(5554303, 150+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 160+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 160+menu.keymod) and true, 0, 0, 80, 25) , 2, 6)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 6, function () return menu.TypeText(ReadText(5554303, 160+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 170+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 170+menu.keymod) and true, 0, 0, 80, 25) , 2, 7)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 7, function () return menu.TypeText(ReadText(5554303, 170+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 180+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 180+menu.keymod) and true, 0, 0, 80, 25) , 2, 8)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 8, function () return menu.TypeText(ReadText(5554303, 180+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 190+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 190+menu.keymod) and true, 0, 0, 80, 25) , 2, 9)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 9, function () return menu.TypeText(ReadText(5554303, 190+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 100+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 100+menu.keymod) and true, 0, 0, 80, 25) , 2, 10)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 10, function () return menu.TypeText(ReadText(5554303, 100+menu.keymod)) end)
  -- Top Row
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 210+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 210+menu.keymod) and true, 0, 0, 80, 25) , 3, 1)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 1, function () return menu.TypeText(ReadText(5554303, 210+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 220+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 220+menu.keymod) and true, 0, 0, 80, 25) , 3, 2)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 2, function () return menu.TypeText(ReadText(5554303, 220+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 230+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 230+menu.keymod) and true, 0, 0, 80, 25) , 3, 3)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 3, function () return menu.TypeText(ReadText(5554303, 230+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 240+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 240+menu.keymod) and true, 0, 0, 80, 25) , 3, 4)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 4, function () return menu.TypeText(ReadText(5554303, 240+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 250+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 250+menu.keymod) and true, 0, 0, 80, 25) , 3, 5)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 5, function () return menu.TypeText(ReadText(5554303, 250+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 260+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 260+menu.keymod) and true, 0, 0, 80, 25) , 3, 6)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 6, function () return menu.TypeText(ReadText(5554303, 260+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 270+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 270+menu.keymod) and true, 0, 0, 80, 25) , 3, 7)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 7, function () return menu.TypeText(ReadText(5554303, 270+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 280+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 280+menu.keymod) and true, 0, 0, 80, 25) , 3, 8)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 8, function () return menu.TypeText(ReadText(5554303, 280+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 290+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 290+menu.keymod) and true, 0, 0, 80, 25) , 3, 9)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 9, function () return menu.TypeText(ReadText(5554303, 290+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 200+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 200+menu.keymod) and true, 0, 0, 80, 25) , 3, 10)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 10, function () return menu.TypeText(ReadText(5554303, 200+menu.keymod)) end)
  -- Middle Row
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 310+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 310+menu.keymod) and true, 0, 0, 80, 25) , 4, 1)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 1, function () return menu.TypeText(ReadText(5554303, 310+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 320+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 320+menu.keymod) and true, 0, 0, 80, 25) , 4, 2)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 2, function () return menu.TypeText(ReadText(5554303, 320+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 330+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 330+menu.keymod) and true, 0, 0, 80, 25) , 4, 3)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 3, function () return menu.TypeText(ReadText(5554303, 330+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 340+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 340+menu.keymod) and true, 0, 0, 80, 25) , 4, 4)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 4, function () return menu.TypeText(ReadText(5554303, 340+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 350+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 350+menu.keymod) and true, 0, 0, 80, 25) , 4, 5)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 5, function () return menu.TypeText(ReadText(5554303, 350+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 360+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 360+menu.keymod) and true, 0, 0, 80, 25) , 4, 6)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 6, function () return menu.TypeText(ReadText(5554303, 360+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 370+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 370+menu.keymod) and true, 0, 0, 80, 25) , 4, 7)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 7, function () return menu.TypeText(ReadText(5554303, 370+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 380+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 380+menu.keymod) and true, 0, 0, 80, 25) , 4, 8)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 8, function () return menu.TypeText(ReadText(5554303, 380+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 390+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 390+menu.keymod) and true, 0, 0, 80, 25) , 4, 9)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 9, function () return menu.TypeText(ReadText(5554303, 390+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 300+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 300+menu.keymod) and true, 0, 0, 80, 25) , 4, 10)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 10, function () return menu.TypeText(ReadText(5554303, 300+menu.keymod)) end)
  -- Bottom Row
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 410+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 410+menu.keymod) and true, 0, 0, 80, 25) , 5, 1)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 1, function () return menu.TypeText(ReadText(5554303, 410+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 420+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 420+menu.keymod) and true, 0, 0, 80, 25) , 5, 2)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 2, function () return menu.TypeText(ReadText(5554303, 420+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 430+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 430+menu.keymod) and true, 0, 0, 80, 25) , 5, 3)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 3, function () return menu.TypeText(ReadText(5554303, 430+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 440+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 440+menu.keymod) and true, 0, 0, 80, 25) , 5, 4)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 4, function () return menu.TypeText(ReadText(5554303, 440+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 450+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 450+menu.keymod) and true, 0, 0, 80, 25) , 5, 5)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 5, function () return menu.TypeText(ReadText(5554303, 450+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 460+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 460+menu.keymod) and true, 0, 0, 80, 25) , 5, 6)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 6, function () return menu.TypeText(ReadText(5554303, 460+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 470+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 470+menu.keymod) and true, 0, 0, 80, 25) , 5, 7)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 7, function () return menu.TypeText(ReadText(5554303, 470+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 480+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 480+menu.keymod) and true, 0, 0, 80, 25) , 5, 8)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 8, function () return menu.TypeText(ReadText(5554303, 480+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 490+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 490+menu.keymod) and true, 0, 0, 80, 25) , 5, 9)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 9, function () return menu.TypeText(ReadText(5554303, 490+menu.keymod)) end)
  SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 400+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 400+menu.keymod) and true, 0, 0, 80, 25) , 5, 10)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 10, function () return menu.TypeText(ReadText(5554303, 400+menu.keymod)) end)
end
-- UniTrader new Functions: Logo Setting (currently same as Cancel Menu)
function menu.buttonSetLogoFromSuperior()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoCurrent()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_1()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_2()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_3()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_4()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_5()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_6()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_7()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
function menu.buttonSetLogoPlayer_8()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end
-- UniTrader new Functions end

function menu.buttonCancel()
	Helper.cancelEditBoxInput(menu.selecttable, 1, 1)
	Helper.closeMenuAndReturn(menu)
	menu.cleanup()
end

function menu.onShowMenu()
	menu.object = menu.param[3]

	local container = GetContextByClass(menu.object, "container", false)
	local isship = IsComponentClass(menu.object, "ship")
-- UniTrader Change: Split Name Var into displayname (from Object) and (edit)name (from Local Var of Control Entity , fallback to displayname)
    menu.controlentity = GetControlEntity(menu.object, "manager") or GetComponentData(menu.object, "controlentity") or ( ( menu.object == GetPlayerPrimaryShipID() ) and GetPlayerEntityID() ) -- last is for playership
	local displayname, name, objectowner = GetComponentData(menu.object, "name", "name", "owner")
	if menu.controlentity and GetNPCBlackboard(menu.controlentity, "$unformatted_object_name") then
		name = GetNPCBlackboard(menu.controlentity, "$unformatted_object_name")
	end
	if container then
		menu.title = GetComponentData(container, "name") .. " - " .. (name ~= "" and displayname or ReadText(1001, 56))
	else
		menu.title = (name ~= "" and displayname or ReadText(1001, 56))
	end
	
	menu.keymod = 0
-- UniTrader Change end

	-- Title line as one TableView
	local setup = Helper.createTableSetup(menu)	
	
	local isplayer, reveal = GetComponentData(menu.object, "isplayerowned", "revealpercent")
	setup:addSimpleRow({
		Helper.createFontString(menu.title .. (isplayer and "" or " (" .. reveal .. " %)"), false, "left", 255, 255, 255, 100, Helper.headerRow1Font, Helper.headerRow1FontSize, false, Helper.headerRow1Offsetx, Helper.headerRow1Offsety, Helper.headerRow1Height, Helper.headerRow1Width, isship and ReadText(1026, 1117) or nil)
	}, nil, nil, false, Helper.defaultTitleBackgroundColor)
	setup:addTitleRow({
		Helper.getEmptyCellDescriptor()
	})
	
	local infodesc = setup:createCustomWidthTable({ 0 }, false, false, true, 3, 1)

	setup = Helper.createTableSetup(menu)

	setup:addSimpleRow({ 
		Helper.createEditBox(Helper.createButtonText(name, "left", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), false, 0, 0, 820, 24, nil, nil, false, isship and ReadText(1026, 1118) or nil)
	}, nil, {10}, false, menu.transparent)

	-- Keyboard
	-- Numbeer Row
	setup:addSimpleRow({ 
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 110), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 120), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 130), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 140), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 150), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 160), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 170), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 180), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 190), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 100), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25)
	}, nil, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, false, menu.transparent)
	-- Top Row
	setup:addSimpleRow({ 
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 210), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 220), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 230), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 240), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 250), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 260), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 270), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 280), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 290), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 200), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25)
	}, nil, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, false, menu.transparent)
	-- Middle Row
	setup:addSimpleRow({ 
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 310), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 320), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 330), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 340), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 350), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 360), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 370), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 380), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 390), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 300), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25)
	}, nil, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, false, menu.transparent)
	-- Bottom Row
	setup:addSimpleRow({ 
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 410), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 420), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 430), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 440), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 450), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 460), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 470), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 480), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 490), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554303, 400), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 80, 25)
	}, nil, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, false, menu.transparent)
	-- Function Row
	setup:addSimpleRow({ 
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1201), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1203), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1205), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1206), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1208), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
	}, nil, {2,2,2,2,2}, false, menu.transparent)
	--setup:addSimpleRow({Helper.getEmptyCellDescriptor()}, nil, {10})
	
	-- Colors
	--setup:addSimpleRow({ 
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2001)..ReadText(5554301, 2000), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2003)..ReadText(5554301, 2002), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2005)..ReadText(5554301, 2004), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2007)..ReadText(5554301, 2006), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2009)..ReadText(5554301, 2008), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2011)..ReadText(5554301, 2010), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2013)..ReadText(5554301, 2012), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2015)..ReadText(5554301, 2014), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2017)..ReadText(5554301, 2016), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2019)..ReadText(5554301, 2018), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25)
	--}, nil, {1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, false, menu.transparent)
	--setup:addSimpleRow({ 
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2021)..ReadText(5554301, 2020), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2025).."0"..ReadText(5554301, 2022), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554302, 2024), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
    --Helper.getEmptyCellDescriptor(),
    --Helper.getEmptyCellDescriptor(),
    --Helper.getEmptyCellDescriptor(),
    --Helper.getEmptyCellDescriptor(),
    --Helper.getEmptyCellDescriptor(),
    --Helper.getEmptyCellDescriptor(),
    --Helper.getEmptyCellDescriptor()
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2027)..ReadText(5554301, 2026), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2029)..ReadText(5554301, 2028), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2011)..ReadText(5554301, 2010), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2013)..ReadText(5554301, 2012), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2015)..ReadText(5554301, 2014), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2017)..ReadText(5554301, 2016), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25),
		--Helper.createButton(Helper.createButtonText(ReadText(5554301, 2019)..ReadText(5554301, 2018), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25)
	--}, nil, {1, 1, 2, 1, 1, 1, 1, 1, 1}, false, menu.transparent)
	
	local selectdesc = setup:createCustomWidthTable({80, 80, 80, 80, 80, 80, 80, 80, 80, 80}, false, false, true, 1, 0, 0, Helper.tableOffsety, nil, nil, nil, 1)

	setup = Helper.createTableSetup(menu)
	setup:addSimpleRow({ 
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1001, 14), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_Y", true), nil, isship and ReadText(1026, 1119) or nil),
		Helper.getEmptyCellDescriptor(),
		Helper.createButton(Helper.createButtonText(ReadText(1001, 64), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25, nil, Helper.createButtonHotkey("INPUT_STATE_DETAILMONITOR_BACK", true), nil, isship and ReadText(1026, 1120) or nil),
		Helper.getEmptyCellDescriptor()
	}, nil, {2, 2, 2, 2, 2}, false, menu.transparent)
	
	-- Mass Renaming Functions
	setup:addSimpleRow({ReadText(5554302, 1001),Helper.getEmptyCellDescriptor()}, nil, {3, 2})
	setup:addSimpleRow({ 
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1002), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25, nil, nil, nil, ReadText(5554302, 1003)),
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1004), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25, nil, nil, nil, ReadText(5554302, 1005)),
		Helper.createButton(Helper.createButtonText(ReadText(5554302, 1006), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 160, 25, nil, nil, nil, ReadText(5554302, 1007)),
		Helper.getEmptyCellDescriptor(),
		Helper.getEmptyCellDescriptor()
	}, nil, {2, 2, 2, 2, 2}, false, menu.transparent)
	
	-- Expressions Help - Static Info Text
	if ( ReadText(5554302, 6) == "All" ) or ( ReadText(5554302, 6) == "Static" ) then
		setup:addSimpleRow({Helper.getEmptyCellDescriptor()}, nil, {10})
		setup:addHeaderRow({ReadText(5554302, 1100)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1101)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1102)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1103)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1104)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1105)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1106)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1107)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1108)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1109)}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1110)}, nil, {10})
	end
	-- Expressions Help - Script-Defined Expressions Overview
	local namereplacement =  GetNPCBlackboard(menu.controlentity, "$namereplacement")
	if ( ( ReadText(5554302, 6) == "All" ) and namereplacement ) or ( ReadText(5554302, 6) == "Script" ) then
		setup:addSimpleRow({Helper.getEmptyCellDescriptor()}, nil, {10})
		setup:addSimpleRow({ReadText(5554302, 1111),ReadText(5554302, 1112)}, nil, {3,2})
		if namereplacement and table.getn(namereplacement) then
			local key1 = nil
			local value1 = nil
			local key2 = nil
			local value2 = nil
			for key,value in pairs(namereplacement) do
				if key1 and key2 then
					setup:addSimpleRow({Helper.createButton(Helper.createButtonText("$"..key1, "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 266, 25, nil, nil, nil, value1),Helper.createButton(Helper.createButtonText("$"..key2, "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 106, 0, 266, 25, nil, nil, nil, value2),Helper.createButton(Helper.createButtonText("$"..key, "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 212, 0, 266, 25, nil, nil, nil, value)}, nil, {1,1,3})
					key1 = nil
					value1 = nil
					key2 = nil
					value2 = nil
				elseif key1 then
					key2 = key
					value2 = value
				else
					key1 = key
					value1 = value
				end
			end
			if key1 and key2 then
				setup:addSimpleRow({Helper.createButton(Helper.createButtonText("$"..key1, "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 266, 25, nil, nil, nil, value1),Helper.createButton(Helper.createButtonText("$"..key2, "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 106, 0, 266, 25, nil, nil, nil, value2),Helper.getEmptyCellDescriptor()}, nil, {1,1,3})
				key1 = nil
				value1 = nil
				key2 = nil
				value2 = nil
			elseif key1 then
				setup:addSimpleRow({Helper.createButton(Helper.createButtonText("$"..key1, "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, true, 0, 0, 266, 25, nil, nil, nil, value1),Helper.getEmptyCellDescriptor()}, nil, {1,4})
				key1 = nil
				value1 = nil
			end
		end
	end
	
	-- Experimental Faction Icons, not intended to be useable yet..
	local extensionSettings = GetAllExtensionSettings()
	if false and ( extensionSettings["utfactionlogos"].enabled or extensionSettings["ws_329415910"].enabled ) and extensionSettings["utcac_ext_advanced_renaming_user"].enabled then
		setup:addHeaderRow({ReadText(5554302, 1008)}, nil, {10})
		setup:addSimpleRow({ 
			-- Display Superior or Default Logo as first Item in this Row (selectable if Logo is useable)
			Helper.createButton(nil, Helper.createButtonIcon("faction_player"  , nil, 255, 255, 255, 100), false, true, 16, 0, 128, 128, nil, nil, nil, ReadText(5554302, 1009)),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_1", nil, 255, 255, 255, 100), false, true, 16, 0, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon"),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_2", nil, 255, 255, 255, 100), false, true, 16, 0, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon"),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_3", nil, 255, 255, 255, 100), false, true, 16, 0, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon"),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_4", nil, 255, 255, 255, 100), false, true, 16, 0, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon")
		}, nil, {1, 1, 1, 1, 1}, false, menu.transparent)
		setup:addSimpleRow({
			-- Display current Logo as first Item in this Row (not selectable)
			Helper.createButton(nil, Helper.createButtonIcon("faction_player"  , nil, 255, 255, 255, 100), false, true, 16, 32, 128, 128, nil, nil, nil, ReadText(5554302, 1010)),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_5", nil, 255, 255, 255, 100), false, true, 16, 32, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon"),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_6", nil, 255, 255, 255, 100), false, true, 16, 32, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon"),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_7", nil, 255, 255, 255, 100), false, true, 16, 32, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon"),
			Helper.createButton(nil, Helper.createButtonIcon("faction_player_8", nil, 255, 255, 255, 100), false, true, 16, 32, 128, 128, nil, nil, nil, "NOT IMPLEMENTED YET - Set Icon")
		}, nil, {1, 1, 1, 1, 1}, false, menu.transparent)
	end
	
	local buttondesc = setup:createCustomWidthTable({80, 80, 80, 80, 80, 80, 80, 80, 80, 80}, false, false, false, 2, 1, 0, 300)

	-- create tableview
	menu.infotable, menu.selecttable, menu.buttontable = Helper.displayThreeTableView(menu, infodesc, selectdesc, buttondesc, false)

	-- set scripts
	Helper.setEditBoxScript(menu, nil, menu.selecttable, 1, 1, menu.editboxUpdateText)
	-- Keyboard Buttons
	--  Number Row
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 1, function () return menu.TypeText(ReadText(5554303, 110+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 2, function () return menu.TypeText(ReadText(5554303, 120+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 3, function () return menu.TypeText(ReadText(5554303, 130+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 4, function () return menu.TypeText(ReadText(5554303, 140+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 5, function () return menu.TypeText(ReadText(5554303, 150+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 6, function () return menu.TypeText(ReadText(5554303, 160+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 7, function () return menu.TypeText(ReadText(5554303, 170+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 8, function () return menu.TypeText(ReadText(5554303, 180+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 9, function () return menu.TypeText(ReadText(5554303, 190+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 2, 10, function () return menu.TypeText(ReadText(5554303, 100+menu.keymod)) end)
	--  Top Row
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 1, function () return menu.TypeText(ReadText(5554303, 210+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 2, function () return menu.TypeText(ReadText(5554303, 220+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 3, function () return menu.TypeText(ReadText(5554303, 230+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 4, function () return menu.TypeText(ReadText(5554303, 240+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 5, function () return menu.TypeText(ReadText(5554303, 250+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 6, function () return menu.TypeText(ReadText(5554303, 260+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 7, function () return menu.TypeText(ReadText(5554303, 270+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 8, function () return menu.TypeText(ReadText(5554303, 280+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 9, function () return menu.TypeText(ReadText(5554303, 290+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 3, 10, function () return menu.TypeText(ReadText(5554303, 200+menu.keymod)) end)
	--  Middle Row
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 1, function () return menu.TypeText(ReadText(5554303, 310+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 2, function () return menu.TypeText(ReadText(5554303, 320+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 3, function () return menu.TypeText(ReadText(5554303, 330+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 4, function () return menu.TypeText(ReadText(5554303, 340+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 5, function () return menu.TypeText(ReadText(5554303, 350+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 6, function () return menu.TypeText(ReadText(5554303, 360+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 7, function () return menu.TypeText(ReadText(5554303, 370+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 8, function () return menu.TypeText(ReadText(5554303, 380+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 9, function () return menu.TypeText(ReadText(5554303, 390+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 4, 10, function () return menu.TypeText(ReadText(5554303, 300+menu.keymod)) end)
	--  Bottom Row
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 1, function () return menu.TypeText(ReadText(5554303, 410+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 2, function () return menu.TypeText(ReadText(5554303, 420+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 3, function () return menu.TypeText(ReadText(5554303, 430+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 4, function () return menu.TypeText(ReadText(5554303, 440+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 5, function () return menu.TypeText(ReadText(5554303, 450+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 6, function () return menu.TypeText(ReadText(5554303, 460+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 7, function () return menu.TypeText(ReadText(5554303, 470+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 8, function () return menu.TypeText(ReadText(5554303, 480+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 9, function () return menu.TypeText(ReadText(5554303, 490+menu.keymod)) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 5, 10, function () return menu.TypeText(ReadText(5554303, 400+menu.keymod)) end)
	--  Function Row
	Helper.setButtonScript(menu, nil, menu.selecttable, 6, 1, function () return menu.SetKeyMod(1) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 6, 3, function () return menu.SetKeyMod(2) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 6, 5, function () return menu.TypeText(" ") end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 6, 7, function () return menu.SetKeyMod(4) end)
	Helper.setButtonScript(menu, nil, menu.selecttable, 6, 9, function () return menu.TypeText("\8")end)
	-- Color Buttons
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 1, function () return menu.TypeText(ReadText(5554301, 2001)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 2, function () return menu.TypeText(ReadText(5554301, 2003)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 3, function () return menu.TypeText(ReadText(5554301, 2005)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 4, function () return menu.TypeText(ReadText(5554301, 2007)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 5, function () return menu.TypeText(ReadText(5554301, 2009)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 6, function () return menu.TypeText(ReadText(5554301, 2011)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 7, function () return menu.TypeText(ReadText(5554301, 2013)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 8, function () return menu.TypeText(ReadText(5554301, 2015)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 9, function () return menu.TypeText(ReadText(5554301, 2017)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 11, 10, function () return menu.TypeText(ReadText(5554301, 2019)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 12, 1, function () return menu.TypeText(ReadText(5554301, 2021)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 12, 2, function () return menu.TypeText(ReadText(5554301, 2025).."0") end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 12, 3, function () return menu.TypeText(ReadText(5554301, 2024)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 12, 3, function () return menu.TypeText(ReadText(5554301, 2015)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 12, 4, function () return menu.TypeText(ReadText(5554301, 2017)) end)
	--Helper.setButtonScript(menu, nil, menu.selecttable, 12, 5, function () return menu.TypeText(ReadText(5554301, 2019)) end)
	

	Helper.setButtonScript(menu, nil, menu.buttontable, 1, 3, menu.buttonOK)
	Helper.setButtonScript(menu, nil, menu.buttontable, 1, 7, menu.buttonCancel)
  -- New Buttons by UniTrader
	Helper.setButtonScript(menu, nil, menu.buttontable, 3, 1, menu.buttonRenameSubordinates)
	Helper.setButtonScript(menu, nil, menu.buttontable, 3, 3, menu.buttonRenameSubordinatesBigShips)
	Helper.setButtonScript(menu, nil, menu.buttontable, 3, 5, menu.buttonRenameSubordinatesSmallShips)

	
  
	if false and ( extensionSettings["utfactionlogos"].enabled or extensionSettings["ws_329415910"].enabled ) and extensionSettings["utcac_ext_advanced_renaming_user"].enabled then
		Helper.setButtonScript(menu, nil, menu.buttontable, 4, 1, menu.buttonSetLogoFromSuperior)
		Helper.setButtonScript(menu, nil, menu.buttontable, 5, 1, menu.buttonSetLogoCurrent)
		Helper.setButtonScript(menu, nil, menu.buttontable, 4, 2, menu.buttonSetLogoPlayer_1)
		Helper.setButtonScript(menu, nil, menu.buttontable, 4, 3, menu.buttonSetLogoPlayer_2)
		Helper.setButtonScript(menu, nil, menu.buttontable, 4, 4, menu.buttonSetLogoPlayer_3)
		Helper.setButtonScript(menu, nil, menu.buttontable, 4, 5, menu.buttonSetLogoPlayer_4)
		Helper.setButtonScript(menu, nil, menu.buttontable, 5, 2, menu.buttonSetLogoPlayer_5)
		Helper.setButtonScript(menu, nil, menu.buttontable, 5, 3, menu.buttonSetLogoPlayer_6)
		Helper.setButtonScript(menu, nil, menu.buttontable, 5, 4, menu.buttonSetLogoPlayer_7)
		Helper.setButtonScript(menu, nil, menu.buttontable, 5, 5, menu.buttonSetLogoPlayer_8)
	end
	menu.editboxisactive = true
	-- End New Buttons by UniTrader
	
	menu.activateEditBox = true

	-- clear descriptors again
	Helper.releaseDescriptors()
end

menu.updateInterval = 1.0

function menu.onUpdate()
	if menu.activateEditBox then
		menu.activateEditBox = nil
		Helper.activateEditBox(menu.selecttable, 1, 1)
  end
  if Helper.currentDefaultTableRow == 1 and not menu.editboxisactive then
    menu.editboxisactive = true
		Helper.activateEditBox(menu.selecttable, 1, 1)
  elseif Helper.currentDefaultTableRow ~= 1 and menu.editboxisactive then
    menu.editboxisactive = false
    DeactivateDirectInput()
    --SetCellContent(menu.selecttable,Helper.createButton(Helper.createButtonText(ReadText(5554303, 110+menu.keymod or "***"), "center", Helper.standardFont, Helper.standardFontSize, 255, 255, 255, 100), nil, false, ReadText(5554303, 110+menu.keymod) and true, 0, 0, 80, 25) , 2, 1)
	end
end

-- function menu.onRowChanged(row, rowdata)
-- end

function menu.onSelectElement()
end

function menu.onCloseElement(dueToClose)
	if dueToClose == "close" then
		Helper.closeMenuAndCancel(menu)
		menu.cleanup()
	else
		Helper.closeMenuAndReturn(menu)
		menu.cleanup()
	end
end

init()
