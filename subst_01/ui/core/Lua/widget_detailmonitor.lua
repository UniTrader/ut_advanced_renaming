-- no need for special unlock-handling
-- script is never locked

-- ffi setup
local ffi = require("ffi")
local C = ffi.C
ffi.cdef[[
	typedef struct {
		uint32_t red;
		uint32_t green;
		uint32_t blue;
		uint32_t alpha;
	} Color;
	typedef struct {
		uint32_t width;
		uint32_t height;
		uint32_t xHotspot;
		uint32_t yHotspot;
	} CursorInfo;
	typedef struct {
		const char* name;
		uint32_t size;
	} Font;
	typedef struct {
		double x;
		double y;
	} GraphDataPoint;
	typedef struct {
		uint32_t MarkerType;
		uint32_t MarkerSize;
		Color MarkerColor;
		uint32_t LineType;
		uint32_t LineWidth;
		Color LineColor;
		size_t NumData;
		bool Highlighted;
		const char* MouseOverText;
	} GraphDataRecord;
	typedef struct {
		size_t DataRecordIdx;
		size_t DataIdx;
		const char* IconID;
		const char* MouseOverText;
	} GraphIcon;
	typedef struct {
		const char* text;
		Font font;
		Color color;
	} GraphTextInfo;
	typedef struct {
		GraphTextInfo label;
		double startvalue;
		double endvalue;
		double granularity;
		double offset;
		bool grid;
		Color color;
		Color gridcolor;
	} GraphAxisInfo;
	typedef struct {
		int x;
		int y;
	} Position2D;
	void ActivateDirectInput(void);
	void DeactivateDirectInput(void);
	bool GetCheckBoxColor(const int checkboxid, Color* color);
	int GetConfigSetting(const char*const setting);
	CursorInfo GetCurrentCursorInfo(void);
	bool GetGraphBackgroundColor(const int graphid, Color* color);
	uint32_t GetGraphData(GraphDataPoint* result, uint32_t resultlen, const int graphid, const size_t datarecordidx);
	uint32_t GetGraphDataRecords(GraphDataRecord* result, uint32_t resultlen, int graphid);
	uint32_t GetGraphIcons(GraphIcon* result, uint32_t resultlen, int graphid);
	bool GetGraphTitle(const int graphid, GraphTextInfo* title);
	uint32_t GetGraphType(const int graphid);
	bool GetGraphXAxis(const int graphid, GraphAxisInfo* axis);
	bool GetGraphYAxis(const int graphid, GraphAxisInfo* axis);
	const char* GetLocalizedText(const uint32_t pageid, uint32_t textid, const char*const defaultvalue);
	const char* GetMouseOverText(const int widgetid);
	uint32_t GetNumGraphDataRecords(int graphid);
	uint32_t GetNumGraphIcons(int graphid);
	uint32_t GetRenderTargetAlpha(const int rendertargetid);
	bool HasRemoteControl(void);
	bool IsCheckBoxActive(const int checkboxid);
	bool IsCheckBoxChecked(const int checkboxid);
	bool IsDetailMonitorFullscreenMode(void);
	bool IsExternalViewActive(void);
	bool IsFrameUsingMiniWidgetSystem(const int frameid);
	bool IsVRVersion(void);
	void SetCheckBoxChecked(const int checkboxid, bool checked);
]]

config = config or {}

-- settings for testing
config.inactiveButtonTextColor = { -- color used for inactive button (text and icons)
	r = 128,
	g = 128,
	b = 128
}
config.inactiveButtonColor = { -- color used for inactive button (background color)
	r = 49,
	g = 69,
	b = 83,
	a = 60
}
config.inactiveCheckBoxColor = { -- color used for inactive checkbox (background color)
	r = 49,
	g = 69,
	b = 83,
	a = 60
}
config.normalCheckBoxBBColor = { -- color used for normal checkbox (background_black color)
	r = 0,
	g = 0,
	b = 0,
	a = 100
}
config.highlightCheckBoxBBColor = { -- color used for highlight checkbox (background_black color)
	r = 48,
	g = 48,
	b = 48,
	a = 80
}

-- addon environment specific settings
config.view = {
	viewtype                   = "detailmonitor", -- the view type identifying this view
	enableAnimatedBackground   = true,            -- enables (or disables) the animated background in non-fullscreen-mode (intended for use on the detailmonitor only)
	enableSpecialPDAMode       = true             -- this setting enables the special PDA mode - on 1st-person-platforms the frame is rendered fullscreen, in the cockpit it's rendered on a rendertarget (some other changes apply, too)
}

-- support to realize the specialPDAMode
config.resetOnGamePlanChange      = false -- indicates whether the widget system is reset upon gameplan change (required for detailmonitor view which changes the target display depending on being in cockpit or first person mode)
config.enableBackgroundBorderHack = false -- special hack to (mis-)use the border system for the PDA-mode on 1st-person platforms, specifying a smaller frame but excluding the background images from the specified borders (reference: XT-3146)

if config.view.enableSpecialPDAMode then
	config.resetOnGamePlanChange      = true
	config.enableBackgroundBorderHack = true
end

-- related to background border hack, specifying the borders in px the background images are to be offsetted when the hack is enabled
config.borderTopCompensation    = 25
config.borderBottomCompensation = 25
config.borderLeftCompensation   = 25
config.borderRightCompensation  =  0

-- settings for boxWidth-calculations
-- #StefanLow - rethink this --- we might better read the real value (the one currently stored in the RenderPresentationHelper as NativePresentationWidth)
config.nativePresentationWidth = 880
config.nativePresentationHeight = 585

config.frame = {
	borderleft   = 0,
	bordertop    = 0,
	borderbottom = 0,
	borderright  = 0
}

-- list of valid script handles
config.validScriptHandles = {
	"onButtonDown",
	"onButtonMouseOut",
	"onButtonMouseOver",
	"onButtonSelect",
	"onCheckBoxMouseOut",
	"onCheckBoxMouseOver",
	"onCheckBoxSelect",
	"onClick",
	"onColumnChanged",
	"onDoubleClick",
	"onHide",
	"onInteractiveElementChanged",
	"onMouseDown",
	"onMouseUp",
	"onMiddleMouseDown",
	"onMiddleMouseUp",
	"onRightMouseDown",
	"onRightMouseUp",
	"onRowChanged",
	"onScrollBarDown",
	"onScrollBarOver",
	"onScrollBarUp",
	"onScrollDown",
	"onScrollUp",
	"onTableMouseOut",
	"onTableMouseOver",
	"onUpdateText"
}

config.renderTargetTextureFilename = "ui\\core\\presentations\\widget_detailmonitor\\widget_detailmonitor_recovered\\detail_monitor-rendertarget"

-- general (addon environment independent) settings
-- reenable when XT-2500 is fixed
config.verifyPixelExact = false -- indicates whether subpixel-checks are being performed which will issue warnings, if any element tries to use subpixel-positions which will end up in graphical artifacts (see XT-2174)

config.mouseScrollBarThreshold = 5 -- the threshold when using dragging to move the scrollbar in the table
                                   -- note that we have to use a threshold here - if we weren't we might get two successive position updates which differ just by 1 px which result in the table being scrolled twice
								   -- (first down by one row, then up by a row again or vice versa)
config.mouseSliderThreshold = 2 -- the threshold when using dragging to move the bar in the slider - see mouseScrollBarThreshold for further info

-- element dependent configs
config.frame.closeButtonRightOffset = 10 -- 2 px from the border, 8 px => half the texture width
config.frame.closeButtonUpperOffset = 10 -- 2 px from the border, 8 px => half the texture height

config.button = {
	-- #StefanMed - combine hotkey icon size with editbox-hotkey-icon size
	hotkeyIconSize = 19,          -- the size (in px) of the hotkey icon
	minButtonSize = 4,            -- the minimal button size (border element sizes (2*2) => 4 px)
	maxElements = 100,            -- number of maximal button elements
	scaleElements = {             -- list of button elements which are to be scaled according to the height/width of the button
		"unselectable",
		"gradient",
		"gradient_active",
		"gradient_active_mirror",
		"background",
		"mousepick"
	},
	unselectableDefaultTiling = 12 -- default tiling used for the unselectable button texture (based on a 100*100px button)
}
config.checkbox = {
	minCheckBoxSize = 4,              -- the minimal checkbox size (checkbox element sizes (2*2) => 4 px)
	maxElements = 100,                -- number of maximal checkbox elements
	scaleElements = {                 -- list of checkbox elements which are to be scaled according to the height/width of the checkbox
		{"unselectable", 1},
		{"background", 1},
		{"background_black", 0.65},
		{"mousepick", 1},
		{"detail_monitor_checkbox_dot", 0.7},
		{"gradient_active", 1}
	},
	unselectableDefaultTiling = 12    -- default tiling used for the unselectable checkbox texture (based on a 100*100px checkbox)
}
config.editbox = {
	hotkeyIconSize = 19,          -- the size (in px) of the hotkey icon
	minEditBoxSize = 4,           -- the minimal editbox size (border element sizes (2*2) => 4 px)
	maxElements = 5,			  -- number of maximal editbox elements
	-- #StefanMed - if it stays like this: single scaleElement is better (no array)
	scaleElements = {             -- list of editbox elements which are to be scaled according to the height/width of the button
		"background"
	},
	cursor = "|",
	cursorBlinkInterval = 0.5,
	outlinecolor = {
		r = 255,
		g = 168,
		b = 0,
		a = 100
	},
	upper_left_color = {
		r = 0,
		g = 0,
		b = 0,
		a = 50
	},
	lower_right_color = {
		r = 255,
		g = 255,
		b = 255,
		a = 20
	}
}
config.background = {
	scaleXElements = { -- background elements which should get their x-value be set according to the view width
		"detail_monitor_background",
		"detail_monitor_grain_side",
		"detail_monitor_gradient"
	},
	scaleYElements = { -- background elements which should get their y-value be set according to the view height
		"detail_monitor_background",
		"detail_monitor_grain_side",
		"detail_monitor_gradient"
	}
}
config.graph = {
	maxElements = 1,               -- number of maximal graph elements
	maxTicksPerElement = 40,       -- number of ticks per graph element
	maxDataPointsPerElement = 200, -- number of data points per graph element
	maxIconsPerElement = 5,        -- number of icons per graph element
	axisWidth = 2,                 -- width of the axes
	border = 5,                    -- border between elements of the graph
	iconSize = 20,                 -- size of icons
	dataRecordOffsetZ = -0.004     -- offset between individual datarecords
}
config.icon = {
	maxElements = 100 -- number of maximal icon elements
}
config.miniWidgetsystem = {
	maxTables = 2,
	maxRows = 2
}
config.mouseOverText = {
	maxWidth = 150, -- max width of the mouse over text (so excluding border!)
	offsetX = 5,   -- offset from the mouse cursor
	borderSize = {
		right = 5,
		left = 5,
		top = 2,
		bottom = 3
	},
	fontsize = 9    -- the fontsize in the native presentation size
}
config.progressElement = {
	maxElements = 20 -- number of maximal progress elements
}
config.shapes = {
	rectangle = {
		maxElements = 1000 -- number of maximal rectangles
	},
	circle = {
		maxElements = 100 -- number of maximal circles
	},
	triangle = {
		maxElements = 100 -- number of maximal triangles
	}
}
config.slider = {
	scrollBar = {
		offset = { -- position, where the scrollbar in the slider element starts (upper left corner)
			x = -210,
			y = 1
		},
		width = 420 -- width of background element (460) excluding spacing to the left/right border (20 each)
	},
	-- workaround for http://www.egosoft.com:8282/jira/browse/XT-2172
	-- remove once properly fixed
	minScrollBarWidth = 59, -- scrollbarArrowLeft (12) + scrollbarSliderLeft (12) + scrollbarSliderDot (11) + scrollbarSliderRight (12) + scrollbarArrowRight (12)
	valueCharLimit = 15, -- number of chars which the left/right value text must not exceed
	interval = { -- interval settings (values taken from X3)
		steps = { -- step intervals the slider will be increased when the button/key is held down
			       1,
				   2,
			       5,
			      10,
			      20,
			      50,
			     100,
			     500,
			    1000,
			    5000,
			   10000,
			   50000,
			  100000,
			  500000,
			 1000000,
			 5000000,
			10000000
		},
		initialStepDelay = 1,       -- delay (in s) before the intervalstep will be increased
		stepDelayIncrease = 0.2,	-- delay (in s) each following step increase will delay the next step delay
		maxStepDelay = 2,			-- delay (in s) the step increase will be delayed most
		initialTickDelay = 0.2,     -- delay (in s) at which the slider ticks (while keeping the key pressed down) for the first time
		reoccurrentTickDelay = 0.05 -- delay (in s) at which the slider ticks (while keeping the key pressed down) after having ticked the first time
	}
}
config.tableRows = {
	maxCols = 10, -- when changing this number, update the corresponding value in UI::Widget::WidgetConfig::MaxTableCols as well
	maxRows = 50, -- when changing this number, update the corresponding value in UI::Widget::WidgetConfig::MaxTableRows as well
}
config.table = {
	maxTables = 3, -- the number of max available tables
	bordersize = 5,
	spaceafterheader = 20,
	minScrollBarHeight = 35, -- scrollbarSliderTop (12) + scrollbarSliderBottom (12) + scrollbarSliderDot (11)
	selectedRowColor = { -- color values for selected rows
		r = 255,
		g = 168,
		b = 0,
		a = 60	-- 60% alpha
	},
	selectedIconColor = { -- color values for icons in selected rows
		r = 255,
		g = 168,
		b = 0,
		a = 100 -- 100% alpha
	},
	unselectedRowColor = { -- color values for unselected rows
		r = 81,
		g = 106,
		b = 126,
		a = 100 -- 100% alpha
	}
}
config.timer = {
	maxElements = 20 -- number of maximal timer elements
}
-- #StefanLow - in principle we'd no longer require table.bar.xxx here (it was historically used when we relied on a texture for the cell background using a transparent edge). Ever since
-- we changed it to a plain solid texture, we'd no longer require these values (and the related calculations - if removing these, the scale-factor in the Anark presentation of table_cell.middle needs to
-- be modified as well)
config.texturesizes = {
	button = {
		borderSize = 2, -- thickness of the button's border line elements in px
	},
	checkbox = {
		borderSize = 2, -- thickness of the checkbox's border line elements in px
	},
	editbox = {
		borderSize = 2, -- thickness of the editbox's border line elements in px
	},
	table = {
		scrollBar = {
			borderElementHeight       = 16, -- height of the upper and lower scrollbar border elements
			sliderBorderElementHeight = 12, -- height of the upper and lower border elements in the slider element of the scrollbar
			sliderCenterElementHeight = 12, -- height of the center part of the slider element in the scrollbar
			width                     = 16  -- width of the scrollbar
		}
	},
	slider = {
		scrollBar = {
			arrowElementWidth        = 12, -- width of the left/right arrow elements at the scrollbar
			borderBoundaryLimit      =  2, -- px on the left/right of scrollBar border element which is not usable for the slider element in the scrollbar
			borderElementWidth       = 16, -- width of the left and right scrollbar border elements
			height                   = 16, -- height of the scrollbar
			sliderBorderElementWidth = 12, -- width of the left and right border elements in the slider element of the scrollbar
			sliderCenterElementWidth = 12, -- width of the center part of the slider element in the scrollbar
		}
	},
	progressElement = {
		height = 16, -- height of the progress element texture
		width  = 58  -- width of the progress element texture
	}
}
config.timerRed = 300 -- time (in s) at which the timer will be displayed with a red color

-- TODO: @ Stefan med - add proper localization support for basic UI strings
-- text array containing localized text
local L = {
	["."] = ffi.string(C.GetLocalizedText(1001, 105, ".")),
	[","] = ffi.string(C.GetLocalizedText(1001, 106, ",")),
	["k"] = ffi.string(C.GetLocalizedText(1001, 300, "k")),
	["M"] = ffi.string(C.GetLocalizedText(1001, 301, "M")),
	["time"] = ffi.string(C.GetLocalizedText(1001, 5500, "time"))
}

-- private member data
local private = {
	-- addon-system-related
	updateScripts = {}, -- functions for update scripts
	hotkeyScripts = {}, -- functions for hotkey scripts
	eventScripts  = {	-- functions for event scripts
		-- [eventname] = {
			-- function
		-- }
	},
	widgetEventScripts = { -- functions for widget event scripts
		-- [widget] = {
			-- [eventname] = {
				-- function
			-- }
		-- }
	},

	-- widget related
	contract      = nil, -- the contract element, receiving Anark events
	anchorElement = nil, -- the anchor element
	master = {		-- all the master elements of the VISIBLE Anark elements
		-- background,
		-- backgroundTexture,
		-- icon,
		-- overlayTexture,
		-- progresselement,
		-- renderTarget,
		-- slider,
		-- timer,
		table = {	-- master elements for tables
			-- header,
			-- cell,
			-- scrollBar
		},
		miniWidgetSystem = {	-- master elements for the mini widgetsystem
			table = {},
			-- background,
			-- backgroundTexture,
			-- overlayTexture,
		}
	},
	sceneState = {
		-- widgetsystem     = true|false
		-- shapes           = true|false
		-- miniwidgetsystem = true|false
	},
	element = {		-- the visible Anark elements
		tableRows = {
			-- [row] = { -- the used anark row element [1..config.tableRows.maxRows]
				-- [col] = {
					-- element         = cell element (Anark element: table_cell)
				-- }
			-- }
		},
		table = {
			-- [tableindex] = {
				-- header                  = header element
				-- headerText              = header text element
				-- numCols                 = number of columns
				-- numFixedRows            = number of fixed rows
				-- numRows                 = number of rows (i.e. not necessarily the number of displayed columns)
				-- highlightedRow          = current highlighted row number (starts with 1, nil indicates currently no highlighted row)
				-- curRow                  = current selected row number (starts with 1, 0 indicates no selectable rows at all)
				-- topRow                  = row number of the row visible on top (just below the fixed rows, if any)
				-- bottomRow               = row number of the row visible on bottom
				-- topBottomRow            = visible bottom row when the table is at its top position
				-- height                  = height of the table (i.e. max table height excluding table header)
				-- nonFixedSectionHeihgt   = height of the table section covering the non-fixed rows (equals height, if numFixedRows = 0)
				-- offsety                 = offset where the table cells start (i.e. tableoffset - tableheader height)
				-- borderEnabled           = indicates whether the table has a border or not
				-- wrapAround              = indicates whether the table is wrapping around when going up/down past the last row
				-- granularity             = value each step of the scrollbar the value will be changed
				-- firstSelectableFixedRow = first selectable fixed row in the fixed row section (0, if no selectable fixed row at all or no fixed rows at all)
				-- normalSelectedRow       = the selected row in the normal (aka: non fixed row) section
				-- interactiveRegion       = "normal"|"fixed" - indictes the region the table selection is currently in
				-- interactiveChild = { -- information about the interactive child in the table (if there is one - nil otherwise)
					-- [row]      = the row of the interactive element
					-- [col]      = the column of the interactive element
					-- [element]  = the interactive element (can be nil, if the interactive element is not displayed atm)
					-- [widgetID] = the widgetID of the interactive child
				-- }
				-- cellposx = {
					-- [col] = x cell position offset
				-- }
				-- fixedRowCellposx = {
					-- [col] = x cell position offset
				-- }
				-- columnWidths = {
					-- [col] = column width
				-- }
				-- fixedRowColumnWidths = {
					-- [col] = column width
				-- }
				-- unselectableRows = {
					-- [row] = true -- list of unselectable rows
				-- }
				-- cell = {
					-- [row] = { -- the used anark row element [1..tableElement.displayedRows]
						-- [realRow] = the real table row [1..tableElement.numRows]
						-- [col] = {
							-- element = cell element (Anark element: table_cell)
							-- active  = true|false - indicates whether the cell has been activated
							-- icon    = iconelement in that cell (if any)
							-- button  = {       = button in that cell (if any)
								-- element       = buttonelement
								-- active        = whether the button element is active
								-- color = {     = button color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- iconColor = { = icon color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- iconID        = icon ID
								-- swapIconID    = swap icon ID (if any)
								-- icon2Color = {= icon color value
									-- r         = red color value
									-- g         = green color value
									-- b         = blue color value
									-- a         = alpha value (defaults to 1)
								-- }
								-- icon2ID       = icon ID
								-- swapIcon2ID   = swap icon ID (if any)
								-- buttonState = {
									-- mouseClick       = true|false - indicates whether the mouse is currently clicked on the button
									-- mouseOver        = true|false - indicates whether the mouse is currently hovering over the button
									-- keyboard         = true|false - indicates whether the keyboard/gamepad has currently selected the button
									-- keyboardPress    = true|false - indicates whether the keyboard/gamepad has currently selected the button and is pressing the ENTER/A button
									-- sendInitialState = true|false - indicates whether we need to send the initial button states
								-- }
							-- }
							-- checkbox = {  = checkbox in that cell (if any)
								-- element   = checkboxElement
								-- active    = whether the checkbox element is active
								-- checked   = whether the checkbox element is checked
								-- color = { = checkboc color value
									-- r     = red color value
									-- g     = green color value
									-- b     = blue color value
									-- a     = alpha value (detaults to 1)
								-- }
							-- }
							-- editbox = {              = editbox in that cell (if any)
								-- element              = editboxelement
								-- active               = whether the editbox element is in active input mode
								-- text                 = current editbox text
								-- oldtext              = editbox text before editbox was activated
								-- hotkeyIconActive     = does the editbox display the hotkey icon
								-- color = {            = editbox color value
									-- r                = red color value
									-- g                = green color value
									-- b                = blue color value
									-- a                = alpha value (defaults to 1)
								-- }
								-- cursor               = is the cursor displayed atm
								-- lastcursorupdatetime = real time, cursor was last changed
								-- closeMenuOnBack      = does the "Back" action close the menu or reset the editbox
							-- }
							-- graph = {
								-- element = {           = graph Anark elements
									-- mainElement       = main graph anark element
									-- tickElements      = tick anark elements
									-- dataPointElements = datapoint anark elements
									-- iconElements      = icon anark elements
								-- }
							-- }
							-- progressElement = progressElement in that cell (if any)
							-- timer           = timer element in that cell (if any)
						-- }
					-- }
				-- }
				-- scrollBar = {
					-- element          = scrollbar Anark element
					-- sliderElement    = scrollbar slider Anark element
					-- sliderHeight     = height of the scrollbar (i.e. the moving element, not the entire size of the scrollbar, which equals the table height)
					-- height           = height of the entire scrollbar
					-- active           = indicates whether table has a scrollbar
					-- dragOffset       = the relative y-offset between the position of the mouse-cursor on the scrollbar and the scrollbar's center when the scrollbar was clicked on
					-- previousMousePos = the mouse y-position of the previous update-call for the scrollBar update (nil, on first call)
					-- sliderState = {
						-- mouseClick = true|false - indicates whether the mouse is currently clicked on the slider
						-- mouseOver  = true|false - indicates whether the mouse is currently hovering over the slider
						-- curSlide   = string     - current slide of the scrollBar
						-- }
					-- }
					-- mousePick = {
						-- element          = mousepick Anark element
						-- state = {
							-- mouseOver = {
								-- state = true|false - indicates whether the mouse is currently hovering over the table
								-- original = true|false|nil - stores orignal state when state is updated, to be processed in onUpdate() call
								-- row = integer|nil - stores row the mouse is hovering over, if information was available
							-- }
						-- }
					-- }
				-- }
			-- }
		},
		buttons = {
			-- [buttonindex] = buttonElement
		},
		checkboxes = {
			-- [checkboxindex] = checkboxElement
		},
		editboxes = {
			-- [editboxindex] = editboxElement
		},
		graphs = {
			-- [graphindex] = graphElement
		},
		icons = {
			-- [iconindex] = iconElement
		},
		progressElements = {
			-- [progressindex] = progressElement
		},
		timerElements = {
			-- [timerindex] = timerElement
		},
		renderTarget = {
			-- [element] = renderTarget component element
			-- [textureElement] = renderTarget (texture) element
			-- [textureString]  = renderTarget texture filename
		},
		shapes = {
			rectangleElements = {
				-- [rectangleindex] = rectangleElement
			},
			circleElements = {
				-- [circleindex] = circleElement
			},
			triangleElements = {
				-- [triangleindex] = triangleElement
			}
		},
		-- slider = {
			-- [element] = sliderElement -- the Anark element
			-- [scale] = { -- scale information
				-- [1] = { -- information for the first scale
					-- [left]         = number|nil -- additional offset to be added to the current value on the left side (nil => no display of left hand value)
					-- [right]        = number|nil -- additional offset to be added to the current value on the right side (nil => no display of right hand value)
					-- [center]       = boolean    -- indicates whether the scale value is to be displayed in the center
					-- [minLimit]     = number|nil -- minimal displayed value (nil => no limit)
					-- [maxLimit]     = number|nil -- maximum displayed value (nil => no limit)
					-- [factor]       = number     -- factor with which to mulitply the scale value
					-- [roundingType] = number     -- indicates whether displayed scale values are to be ceiled (0), floored (1), unmodified (2)
					-- [inverted]     = boolean    -- indicates whether scale values are applied inverted (right to left) or normal (left to right)
					-- [valueSuffix]  = string     -- the suffix which is to be printed after each value
				-- }
				-- [2] = {} -- same as [1], nil if slider has only a single scale
			-- }
			-- [scrollBar] = {
				-- [element]           = AnarkElement -- sliderelement
				-- [sliderElement]     = AnarkElement -- the actual movable slider-element
				-- [leftArrowElement]  = AnarkElement -- the left arrow element
				-- [rightArrowElement] = AnarkElement -- the left arrow element
				-- [width]             = number       -- width of the visible/movable slider
				-- [pageStep]          = number       -- value the slider will be scrolled by when performing a page step right/left
			-- }
			-- [curValue]           = number  -- value the slider currently represents
			-- [startValue]         = number  -- value above which the slider displays a ">" (or a "<", if curValue is less)
			-- [zeroValue]          = number  -- value at which the slider corresponds to a value of zero
			-- [fixedValues]        = boolean -- indicates whether values to the right/left of the slider are fixed
			-- [invertedIndicator]  = boolean -- indicates whether the ">"/"<"-indicator is inverted
			-- [minValue]           = number  -- value the slider represents at least
			-- [maxValue]           = number  -- value the slider represents at most
			-- [minSelectableValue] = number  -- minimal value the slider is allowed to be moved to
			-- [maxSelectableValue] = number  -- maximal value the slider is allowed to be moved to
			-- [granularity]        = number  -- value each step of the slider the value will be changed
			-- [valuePerPixel]      = number  -- value each pixel in the slider represents
		-- },
		miniWidgetSystem = { -- elements in the mini widgetsystem
			tableRows = {},
			table = {},
			buttons = {},
			checkboxes = {},
			editboxes = {},
			graphs = {},
			icons = {},
			progressElements = {},
			timerElements = {},
			renderTarget = {},
			slider = {}
		}
	},
	frameBorders = {
		-- [top]    = number -- px of the top border of the current frame
		-- [bottom] = number -- px of the bottom border of the current frame
		-- [left]   = number -- px of the left border of the current frame
		-- [right]  = number -- px of the right border of the current frame
	},
	frame      = nil,   -- the current active frame (if any)
	offsetx    = nil,	-- xoffset of the entire view
	offsety    = nil,	-- yoffset of the entire view
	height     = nil,	-- height of the entire view
	width      = nil,	-- width of the entire view
	fontHeight = {		-- memoized fontheights for fontname/fontsize combinations
		-- [fontname] = {
			-- [fontzise] = fontheight
		-- }
	},
	-- #StefanMed - documetnation is misleading - Anark element -- it's actually the tableElement in case of tablechild (button, editbox, for instance)
	associationList = {	-- association list of widgetIDs (key) with the Anark element
		-- [widgetID] = { -- the actual widget ID
			-- #StefanMed clean this up... (special case for button handling is no good)
			-- element     = associated Anark element (ref of private.element entry) - note in case of buttons, this is the buttonElement (table) with element.element being the Anark element
			-- parentx     = parent offset (x)
			-- parenty     = parent offset (y)
			-- parentwidth = parent width
		-- }
	},
	activeEditBox = nil, -- {
		-- editboxID      = widgetID of the editbox,
		-- editboxElement = reference to table[x].cell[row][col].editbox
	-- },
	activeTimer = {
		-- [timerelement] = timeout (i.e. time, at which the time out is reached)
	},
	nextTickTime = nil,         -- time at which the scrolling will tick next
	nextStepIncreaseTime = nil, -- time at which the scrolling step will be increased next
	scrolling = nil,            -- nil|"left"|"right"
	scrollingElement = nil,     -- the element which is assigned to be scrolled
	curScrollingStep = nil,     -- the step per tick for scrolling
	numStepIncreases = 0,       -- number of step increases for scrolling
	interactiveElement = {      -- the current interactive element, if any
		-- [element]  = reference to private.element entry
		-- [widgetID] = the widgetID of the interactive element
	},
	oldInteractiveElement = {   -- store interactive element, while editbox is active
		-- [element]  = reference to private.element entry
		-- [widgetID] = the widgetID of the previously interactive element
	},
	sliderArrowState = {
		["left"] = {
			["mouseClick"] = false,     -- indicates whether the mouse is clicked on the arrow
			["mouseOver"]  = false,     -- indicates whether the mouse is over the arrow
			["keyboard"]   = false,     -- indicates whether the keyboard key (or gamepad button) is pressed corresponding to the arrow control
			["element"]    = nil,       -- the slider arrow element
			["curSlide"]   = "inactive" -- the current slide, the arrow is displayed in
		},
		["right"] = {
			["mouseClick"] = false,     -- indicates whether the mouse is clicked on the arrow
			["mouseOver"]  = false,     -- indicates whether the mouse is over the arrow
			["keyboard"]   = false,     -- indicates whether the keyboard key (or gamepad button) is pressed corresponding to the arrow control
			["element"]    = nil,       -- the slider arrow element
			["curSlide"]   = "inactive" -- the current slide, the arrow is displayed in
		},
	},
	sliderBarState = {
		["mouseClick"] = false,     -- indicates whether the mouse is clicked on the bar
		["mouseOver"]  = false,     -- indicates whether the mouse is over the arrow
		["curSlide"]   = "inactive" -- the current slide, the bar is displayed in
	},
	-- #StefanMed move to slider
	sliderActive = false,         -- indicates whether the slider is active or not
	-- #StefanMed move to table scrollbar
	scrollBarDrag = nil,          -- the scrollbar which is dragged atm (if any)
	-- #StefanMed move to slider
	sliderDragStartOffset = nil,  -- the offset used for dragging the slider (if any)
	previousSliderMousePos = nil, -- the previous mouse pos while dragging the slider (if any)
	sliderDrag = false,           -- indicates whether the slider is being dragged atm
	backButtonShown = false,      -- indicates whether the back button is shown on the frame
	closeButtonShown = false,     -- indicates whether the close button is shown on the frame
	standardButtonState = {
		["back"] = {
			["mouseClick"] = false, -- indicates whether the mouse is clicked on the button
			["mouseOver"]  = false, -- indicates whether the mouse is over the button
			["curSlide"]   = ""     -- the current slide the button is set to
		},
		["close"] = {
			["mouseClick"] = false, -- indicates whether the mouse is clicked on the button
			["mouseOver"]  = false, -- indicates whether the mouse is over the button
			["curSlide"]   = ""     -- the current slide the button is set to
		}
	},
	onHideRisen = false,               -- indicates whether onHide was already risen
	pendingFrame = nil,                -- the frame which is pending to be dispayed
	animatedBackgroundEnabled = false, -- indicates whether the animated background is used atm (this may differ from whether the actual feature is enabled or not as config.view.enableAnimatedBackground indicates)
	fullscreenMode = false,            -- indicates whether the widgetsystem is in fullscreen mode
	updateWidget = nil,                -- indicates whether the widget has to be updated when the current frame closes (e.g. due to a gameplan change while that frame was displayed)
	mouseOverText = nil,               -- indicates an active mouse over text and stores its properties
	-- {
		-- widgetID                   -- associated widget
		-- count                      -- count nested elements registered for mouse, to we don't hide mouse over text if we leave one of the nested elements
		-- width                      -- the total width of the mouse over text
		-- height                     -- the total height of the mouse over text
		-- cursorinfo = CursorInfo    -- information about the mouse cursor at the time the mouse over text is set up
		-- overrideText               -- current override text used instead of the text associated with the widgetID
	-- }
	mouseOverOverrideText = nil,
	drawnShapes = {
		rectangles = {},              -- list of all drawn rectangles
		circles = {},                 -- list of all drawn circles
		triangles = {}                -- list of all drawn triangles
	},
	shapesActivated = false,
	queuedShapes = {},
	miniWidgetSystemUsed = false,
}

-- addon-system-related
-- note: we encapsulate the addon system related functions, to work around the max 200 local variables limit in Lua (we have more than 200 functions in this file)
local addonSystem = {}

-- widget-system-related
-- note: we encapsulate the widget system related functions, to work around the max 200 local variables limit in Lua (we have more than 200 functions in this file)
-- #StefanMed reorganize config and private settings to be also system dependent
local widgetSystem = {}

---------------------------------
-- Gameface lifetime functions --
---------------------------------
function self:onInitialize()
	-- initialize private data
	private.scene             = getElement("Scene")
	private.contract          = getElement("UIContract", private.scene)
	private.anchorElement     = getElement("Layer.ui_anchor", private.scene)
	private.widgetsystem      = getElement("widgetsystem", private.anchorElement)
	private.miniwidgetsystem  = getElement("miniwidgetsystem", private.anchorElement)
	private.shapes            = getElement("shapes", private.anchorElement)

	widgetSystem.initializeFrameElements()
	widgetSystem.initializeMasterElements()
	widgetSystem.initializeButtonElements()
	widgetSystem.initializeCheckBoxElements()
	widgetSystem.initializeEditBoxElements()
	widgetSystem.initializeGraphElements()
	widgetSystem.initializeIconElements()
	widgetSystem.initializeMiniWidgetSystemElements()
	widgetSystem.initializeShapeElements()
	widgetSystem.initializeSliderElements()
	widgetSystem.initializeProgressElements()
	widgetSystem.initializeRenderTarget()
	widgetSystem.initializeTimerElements()
	widgetSystem.initializeTableElements()
	widgetSystem.initializeTableRowElements()

	-- register for events
	registerForEvent("buttonupdate", private.contract, widgetSystem.onButtonUpdate)
	registerForEvent("back", private.contract, widgetSystem.onBack)
	registerForEvent("checkboxupdate", private.contract, widgetSystem.onCheckBoxUpdate)
	registerForEvent("close", private.contract, widgetSystem.onClose)
	registerForEvent("directtextinput", private.contract, widgetSystem.onDirectTextInput)
	registerForEvent("frameupdate", private.contract, widgetSystem.onFrameUpdate)
	registerForEvent("frameclose", private.contract, widgetSystem.onFrameClose)
	registerForEvent("fontstringupdate", private.contract, widgetSystem.onFontStringUpdate)
	registerForEvent("genericEvent", private.contract, widgetSystem.onEvent)
	registerForEvent("iconupdate", private.contract, widgetSystem.onIconUpdate)
	registerForEvent("startscrollleft", private.contract, widgetSystem.onStartScrollLeft)
	registerForEvent("stopscrollleft", private.contract, widgetSystem.onStopScrollLeft)
	registerForEvent("startscrollright", private.contract, widgetSystem.onStartScrollRight)
	registerForEvent("stopscrollright", private.contract, widgetSystem.onStopScrollRight)
	registerForEvent("movedown", private.contract, widgetSystem.onMoveDown)
	registerForEvent("moveup", private.contract, widgetSystem.onMoveUp)
	registerForEvent("pagedown", private.contract, widgetSystem.onPageDown)
	registerForEvent("pageup", private.contract, widgetSystem.onPageUp)
	registerForEvent("scrolldown", private.contract, widgetSystem.onScrollDown)
	registerForEvent("scrollup", private.contract, widgetSystem.onScrollUp)
	registerForEvent("startselect", private.contract, widgetSystem.onStartSelect)
	registerForEvent("stopselect", private.contract, widgetSystem.onStopSelect)
	registerForEvent("tab", private.contract, widgetSystem.onTabInteractiveElement)
	registerForEvent("tableupdate", private.contract, widgetSystem.onTableUpdate)
	registerForEvent("viewremoved", private.contract, widgetSystem.onViewRemoved)

	registerForEvent("onMouseOver", private.widgetsystem, widgetSystem.onMouseOver)
	registerForEvent("onMouseOut", private.widgetsystem, widgetSystem.onMouseOut)

	-- register events for certain modes
	if config.resetOnGamePlanChange then
		registerForEvent("gameplanchange", private.contract, widgetSystem.onGamePlanChange)
	end

	private.sceneState = {
		["widgetsystem"]     = false,
		["shapes"]           = false,
		["miniwidgetsystem"] = false
	}

	-- initialize frame borders (remove once XT-3146 is fixed)
	private.frameBorders.top    = config.frame.bordertop
	private.frameBorders.bottom = config.frame.borderbottom
	private.frameBorders.left   = config.frame.borderleft
	private.frameBorders.right  = config.frame.borderright

	-- mouse over text config
	private.enableMouseOverText = C.GetConfigSetting("mouseovertext") ~= 0
	registerForEvent("setMouseOverText", private.contract, widgetSystem.onToggleMouseOverText)

	-- initialize fullscreen related settings
	widgetSystem.checkFullscreenMode()

	-- register presentation with widget system
	RegisterWidget(config.view.viewtype, private.frameBorders.left, private.frameBorders.right, private.frameBorders.top, private.frameBorders.bottom)
end

function self:onUpdate()
	-- process pending frame update (cannot be done directly in onFrameUpdate() since we've to activate the widget system first)
	if private.pendingFrame then
		widgetSystem.updateFrame(private.pendingFrame)
		private.pendingFrame = nil
	end

	local curTime -- intent is to get it once per frame only, hence init with nil and set, when required just once
	-- update active editbox if any
	if private.activeEditBox ~= nil then
		curTime = getElapsedTime()
		widgetSystem.updateEditBoxCursor(private.activeEditBox.editboxElement, curTime)
	end

	-- update active timers
	for timerElement, timeout in pairs(private.activeTimer) do
		widgetSystem.setTimer(timerElement, timeout)
	end

	-- perform any scroll updates
	if private.scrolling ~= nil then
		curTime = curTime or getElapsedTime()
		if private.nextTickTime <= curTime then
			private.nextTickTime = curTime + config.slider.interval.reoccurrentTickDelay
			if private.scrolling == "left" then
				widgetSystem.scrollLeft(private.scrollingElement, widgetSystem.getCurrentInterval())
			else -- scrolling == "right"
				widgetSystem.scrollRight(private.scrollingElement, widgetSystem.getCurrentInterval())
			end
		end
	end

	-- perform slider / scrollbar updates
	if private.sliderDrag then
		widgetSystem.updateSliderPos()
	elseif private.scrollBarDrag then
		widgetSystem.updateScrollBarPos(private.scrollBarDrag)
	end

	-- perform table mouse pick updates
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for i, tableElement in ipairs(tableElements) do
		widgetSystem.processTableMousePick(tableElement)
	end

	if private.mouseOverText then
		widgetSystem.setMouseOverPosition()
	end

	if private.shapesActivated then
		widgetSystem.updateShapes()
	end

	-- call addon update scripts
	CallUpdateScripts()
end

--------------------------------------
-- Widget system specific callbacks --
--------------------------------------
function widgetSystem.onButtonUpdate(_, buttonID)
	if not IsValidWidgetElement(buttonID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local buttonentry = private.associationList[buttonID]
	if buttonentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateButton(buttonID, buttonentry.element)
end

function widgetSystem.onBack()
	if private.pendingFrame ~= nil then
		-- #StefanMed - review this part - in principle this might cause that successive eventtriggers are unnecessarily delayed now, because if the event occurred before actually displaying the frame
		-- it is skipped now (aka: pressing ESC multiple times in a row might now react slower than necessary)
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if private.activeEditBox ~= nil and (not private.activeEditBox.editboxElement.closeMenuOnBack) then
		-- clear input
		private.activeEditBox.editboxElement.text = ""
		setAttribute(getElement("Text", private.activeEditBox.editboxElement.element), "textstring", private.activeEditBox.editboxElement.text)
		private.activeEditBox.editboxElement.cursor = false
		widgetSystem.confirmEditBoxInputInternal(private.activeEditBox.editboxID, private.activeEditBox.editboxElement)
	else
		widgetSystem.raiseHideEvent("back")
	end
end

function widgetSystem.onCheckBoxUpdate(_, checkboxID)
	if not IsValidWidgetElement(checkboxID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local checkboxentry = private.associationList[checkboxID]
	if checkboxentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateCheckBox(checkboxID, checkboxentry.element)
end

function widgetSystem.onClose()
	if private.pendingFrame ~= nil then
		-- #StefanLow - review this part - in principle this might cause that successive eventtriggers are unnecessarily delayed now, because if the event occurred before actually displaying the frame
		-- it is skipped now (expected to not be a real issue, since it'd require a close-event in nearly the same frame of a newly displayed frame - aka: ESC + DEL -> unlikely to happen --- player would
		-- in most cases press DEL directly).
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	widgetSystem.raiseHideEvent("close")
end

function widgetSystem.onDirectTextInput(_, char)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if private.activeEditBox ~= nil then
		local editboxElement = private.activeEditBox.editboxElement
		if char == "\8" then
			if string.len(editboxElement.text) > 0 then
				editboxElement.text = string.sub(editboxElement.text, 1, widgetSystem.getUTF8CharacterPrevIndex(editboxElement.text, string.len(editboxElement.text)))
			end
		else
			editboxElement.text = editboxElement.text..tostring(char)
		end
		editboxElement.oldtext = editboxElement.text
		setAttribute(getElement("Text", editboxElement.element), "textstring", editboxElement.text..(editboxElement.cursor and config.editbox.cursor or ""))
	end
end

function widgetSystem.onEvent(_, eventName, arg1)
	-- note: we do not delay dispatching of the event to the addonsystem, since even if we would have a pending frame, the addon system would already be updated correctly and issue the event
	-- onto the correct callbacks

	CallEventScripts(eventName, arg1)
end

function widgetSystem.onFontStringUpdate(_, fontstringID)
	if not IsValidWidgetElement(fontstringID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local textentry = private.associationList[fontstringID]
	if textentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	-- #StefanMed - refactor and store the component in the associationList as well
	widgetSystem.updateFontString(fontstringID, textentry.textComponent, textentry.element, textentry.activeSlide, textentry.inactiveSlide, textentry.curSlide)
end

function widgetSystem.onFrameClose()
	if not private.onHideRisen then
		widgetSystem.raiseHideEvent("auto")
	end
	private.pendingFrame = nil
	private.frame = nil
	widgetSystem.disableAnimatedBackground()
	widgetSystem.hideAllElements()
	-- Fallback cleanup - should be part of widgetSystem.hideAllElements() but that requires the script to add shapes only after the frame was updated (see usage of widgetSystem.hideAllElements() in widgetsystem.updateFrame())
	widgetSystem.hideAllShapes()
	-- IMPORTANT - MUST BE DONE AFTER HIDE ALL ELEMENTS (otherwise the slide-changes for elements won't be executed resulting in ghost-elements, when activating the frame the next time)
	-- note: hiding the entire scene was done to improve the performance, if the widget system environment is disabled completely (since that saves us unnecessarily iterating over all cloned
	-- elements in shapes and in the widget system to check whether there's any active element (which there isn't))
	if private.miniWidgetSystemUsed then
		widgetSystem.setSceneState("miniwidgetsystem", false)
	else
		widgetSystem.setSceneState("widgetsystem", false)
	end

	if private.updateWidget ~= nil then
		widgetSystem.checkFullscreenMode()
		UpdateRegisteredWidget(private.frameBorders.left, private.frameBorders.right, private.frameBorders.top, private.frameBorders.bottom)
		private.updateWidget = nil
	end
end

function widgetSystem.onFrameUpdate(_, frame)
	if not IsValidWidgetElement(frame) then
		return -- can happen if a view is closed before this callback is processed
	end

	if not private.onHideRisen then
		widgetSystem.raiseHideEvent("auto")
	end

	if not IsValidWidgetElement(frame) then
		return -- can happen if a view is closed as a result of the risen Hide-event
	end

	-- activate the widget system
	private.miniWidgetSystemUsed = C.IsFrameUsingMiniWidgetSystem(frame)
	if private.miniWidgetSystemUsed then
		widgetSystem.setSceneState("miniwidgetsystem", true)
	else
		widgetSystem.setSceneState("widgetsystem", true)
	end

	private.pendingFrame = frame

	ForceAnarkUpdate()
end

function widgetSystem.checkFullscreenMode()
	private.fullscreenMode = not config.view.enableSpecialPDAMode or IsFirstPerson() or C.IsDetailMonitorFullscreenMode() or C.IsExternalViewActive() or C.HasRemoteControl()
	private.animatedBackgroundEnabled = not private.fullscreenMode and config.view.enableAnimatedBackground
	
	local worldSpaceMode = private.fullscreenMode and C.IsVRVersion()

	-- no need to alter/reset the frame border values, unless we are modifying them due to the enableBackgroundBorderHack
	if config.enableBackgroundBorderHack then
		if private.fullscreenMode and not worldSpaceMode then
			private.frameBorders.top    = config.borderTopCompensation
			private.frameBorders.bottom = config.borderBottomCompensation
			private.frameBorders.left   = config.borderLeftCompensation
			private.frameBorders.right  = config.borderRightCompensation
		else
			private.frameBorders.top    = config.frame.bordertop
			private.frameBorders.bottom = config.frame.borderbottom
			private.frameBorders.left   = config.frame.borderleft
			private.frameBorders.right  = config.frame.borderright
		end
	end

	-- set anchor scale value correctly based on worldspace mode
	local scale = 1
	if worldSpaceMode then
		-- note: the height must be re-requested upon each swap, since it could change based on the current widget mode (aka: rendertarget vs. non-rendertarget)
		local _, height = getScreenInfo()
		-- calculation based on Florian's approach
		scale = 0.0017 * 1080 / height
	end
	widgetSystem.initScale(private.anchorElement, scale)
end

function widgetSystem.onGamePlanChange(_, mode)
	-- #StefanLow - store current mode and only perform re-registration when the mode really changed between cockpit <-> firstperson
	-- if we are currently displaying a frame delay the update until it's closed
	if not private.frame then
		widgetSystem.checkFullscreenMode()
		UpdateRegisteredWidget(private.frameBorders.left, private.frameBorders.right, private.frameBorders.top, private.frameBorders.bottom)
	else
		private.updateWidget = true
	end
end

function widgetSystem.onIconUpdate(_, iconID)
	if not IsValidWidgetElement(iconID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local iconentry = private.associationList[iconID]
	if iconentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.updateIcon(iconID, iconentry.element, iconentry.parentx, iconentry.parenty, iconentry.parentwidth)
end

function widgetSystem.onMouseClickBackButton(_, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	if private.frame ~= nil then
		-- can be nil, if we closed the frame before the mouse-event got dispatched
		widgetSystem.raiseHideEvent("back")
	end
end

function widgetSystem.onMouseClickButton(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local buttonElement = widgetSystem.getButtonElementByAnarkElement(anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	widgetSystem.swapButtonIcon(buttonID, buttonElement)

	CallWidgetEventScripts(buttonID, "onClick")
end

function widgetSystem.onMouseClickCheckBox(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local checkboxElement = widgetSystem.getCheckBoxElementByAnarkElement(anarkElement)
	if checkboxElement == nil or not checkboxElement.active then
		return -- if the checkbox is not active, there's nothing we've to do
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	widgetSystem.toggleCheckBox(checkboxID, checkboxElement)

	CallWidgetEventScripts(checkboxID, "onClick", checkboxElement.checked)
end

function widgetSystem.onMouseClickCloseButton(_, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	if private.frame ~= nil then
		-- can be nil, if we closed the frame before the mouse-event got dispatched
		widgetSystem.raiseHideEvent("close")
	end
end

function widgetSystem.onMouseClickEditBox(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local editboxElement = widgetSystem.getEditBoxElementByAnarkElement(anarkElement)
	if editboxElement == nil then
		return -- if the editbox is not visible (or no longer valid), there's nothing we've to do
	end

	if not editboxElement.active then
		if private.activeEditBox ~= nil then
			-- we decided to use a consistent editbox behavior --- whenever an editbox is closed, it keeps the current input (i.e. no cancel support)
			-- #StefanMed --- rethink the behavior ---- maybe better go with a per editbox-parameter to define whether a box is to keep its input on close (without ENTER) or revert it to the old text
			widgetSystem.confirmEditBoxInputInternal(private.activeEditBox.editboxID, private.activeEditBox.editboxElement)
		end

		local editboxID = widgetSystem.getWidgetIDByElementEntry(editboxElement)
		widgetSystem.activateEditBoxInternal(editboxID, editboxElement)

		local element, widgetID, row = widgetSystem.getTableElementByAnarkEditboxElement(anarkElement)
		widgetSystem.setInteractiveElement(widgetID)
	end
end

function widgetSystem.onMouseClickPageScroll(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local _, y = GetLocalMouseClickPosition()

	local anarkScrollBarElement = getElement("parent", anarkElement)
	local sliderPosY = widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement)

	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	if y > sliderPosY then
		widgetSystem.scrollPageUp(tableID, tableElement)
	else
		widgetSystem.scrollPageDown(tableID, tableElement)
	end
end

function widgetSystem.onMouseClickRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onClick", modified)
end

function widgetSystem.onMouseDblClickRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onDoubleClick", modified)
end

function widgetSystem.onMouseDownRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onMouseDown", modified)
end

function widgetSystem.onMouseUpRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onMouseUp", modified)
end

function widgetSystem.onMiddleMouseDownRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onMiddleMouseDown", modified)
end

function widgetSystem.onMiddleMouseUpRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onMiddleMouseUp", modified)
end

function widgetSystem.onRightMouseDownRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onRightMouseDown", modified)
end

function widgetSystem.onRightMouseUpRenderTarget(anarkElement, delayed, modified)
	if delayed then
		return -- ignore delayed clicks
	end

	local renderTargetElement = widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(renderTargetElement)

	CallWidgetEventScripts(renderTargetID, "onRightMouseUp", modified)
end

function widgetSystem.scrollDownRenderTarget(renderTargetID)
	CallWidgetEventScripts(renderTargetID, "onScrollDown")
end

function widgetSystem.scrollUpRenderTarget(renderTargetID)
	CallWidgetEventScripts(renderTargetID, "onScrollUp")
end

function widgetSystem.onMouseClickSliderScroll(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local x = GetLocalMouseClickPosition()

	local anarkSliderBarElement = getElement("parent", anarkElement)
	local sliderPosX = widgetSystem.getSliderPosition(anarkSliderBarElement)

	local sliderElement = widgetSystem.getSliderElementByAnarkElement(getElement("parent.parent", anarkSliderBarElement))

	if x > sliderPosX then
		widgetSystem.scrollPageRight(sliderElement)
	else
		widgetSystem.scrollPageLeft(sliderElement)
	end
end

function widgetSystem.onMouseClickTableCell(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement(anarkElement)
	-- check if it's clicked on a table
	if not element then
		-- #StefanMed - refactor so to reset interactive/noninteractive table mouse events --- spares us this check here
		return -- anarkelement isn't a table cell element
	end

	if not IsInteractive(widgetID) then
		return -- clicked on a table element, but the table isn't interactive
	end

	if element.curRow == row then
		-- enter the already selected row
		CallWidgetEventScripts(widgetID, "onClick")
	else
		-- just select the new row
		widgetSystem.selectRow(widgetID, row)
	end
	if private.activeEditBox ~= nil then
		widgetSystem.confirmEditBoxInputInternal(private.activeEditBox.editboxID, private.activeEditBox.editboxElement)
	end
end

function widgetSystem.onMouseDblClickButton(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local buttonElement = widgetSystem.getButtonElementByAnarkElement(anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	CallWidgetEventScripts(buttonID, "onDoubleClick")
end

function widgetSystem.onMouseDblClickCheckBox(anarkElement, delayed)
	if delayed then
		return -- ignore delayed clicks
	end

	local checkboxElement = widgetSystem.getCheckBoxElementByAnarkElement(anarkElement)
	if checkboxElement == nil or not checkboxElement.active then
		return -- if the checkbox is not active, there's nothing we've to do
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	widgetSystem.toggleCheckBox(checkboxID, checkboxElement)

	CallWidgetEventScripts(checkboxID, "onClick", checkboxElement.checked)
end

function widgetSystem.onMouseDownBackButton()
	widgetSystem.setStandardButtonState("back", "mouseClick", true)
end

function widgetSystem.onMouseDownButton(anarkElement)
	local buttonElement = widgetSystem.getButtonElementByAnarkElement(anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end

	widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseClick", true)
end

function widgetSystem.onMouseDownCloseButton()
	widgetSystem.setStandardButtonState("close", "mouseClick", true)
end

function widgetSystem.onMouseOutBackButton()
	widgetSystem.setStandardButtonState("back", "mouseOver", false)
end

function widgetSystem.onMouseOutButton(anarkElement)
	local buttonElement = widgetSystem.getButtonElementByAnarkElement(anarkElement)
	if buttonElement == nil then
		return
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end
	
	if buttonElement.active then
		widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseOver", false)
	end
	
	local element, widgetID, row = widgetSystem.getTableElementByAnarkButtonElement(anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutCheckBox(anarkElement)
	local checkboxElement = widgetSystem.getCheckBoxElementByAnarkElement(anarkElement)
	if checkboxElement == nil then
		return
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	if not IsValidWidgetElement(checkboxID) then
		return -- view might have already been changed
	end
	
	if checkboxElement.active then
		widgetSystem.setCheckBoxElementState(checkboxID, checkboxElement, "mouseOver", false)
	end
	
	local element, widgetID, row = widgetSystem.getTableElementByAnarkCheckBoxElement(anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutCloseButton()
	widgetSystem.setStandardButtonState("close", "mouseOver", false)
end

function widgetSystem.onMouseOutGraphDataPoint(anarkElement)
	local graphElement = widgetSystem.getGraphElementByAnarkElement(anarkElement)
	if graphElement == nil then
		return
	end

	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	private.mouseOverOverrideText = nil
end

function widgetSystem.onMouseOutGraphIcon(anarkElement)
	local graphElement = widgetSystem.getGraphElementByAnarkElement(anarkElement)
	if graphElement == nil then
		return
	end

	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	private.mouseOverOverrideText = nil
end

function widgetSystem.onMouseOutTableScrollBar(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseOver", false, tableID)
end

function widgetSystem.onMouseOutTable(anarkElement)
	local tableElement = widgetSystem.getTableElementByMousePick(anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	
	if element then
		widgetSystem.setTableMousePickState(tableID, tableElement, "mouseOver", false)
	end
end

function widgetSystem.onMouseOutTableCell(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement(anarkElement)
	
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", false, row)
	end
end

function widgetSystem.onMouseOutSliderScrollBar(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderBarState(anarkElement, "mouseOver", false, widgetSystem.getWidgetIDByElementEntry(sliderElement))
end

function widgetSystem.onMouseOutScrollLeft(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "left", "mouseOver", false)
end

function widgetSystem.onMouseOutScrollRight(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "right", "mouseOver", false)
end

function widgetSystem.onMouseOver(_, _, anarkElement)
	if private.enableMouseOverText then
		local rootAnarkElement = widgetSystem.getRootAnarkElement(anarkElement)
		local widgetID = rootAnarkElement and widgetSystem.getWidgetIDByAnarkElementEntry(rootAnarkElement) or nil
		widgetSystem.showMouseOverText(widgetID)
	end
end

function widgetSystem.onMouseOut(_, anarkElement)
	if private.enableMouseOverText then
		local rootAnarkElement = widgetSystem.getRootAnarkElement(anarkElement)
		local widgetID = rootAnarkElement and widgetSystem.getWidgetIDByAnarkElementEntry(rootAnarkElement) or nil
		widgetSystem.hideMouseOverText(widgetID)
	end
end

function widgetSystem.onMouseOverBackButton()
	widgetSystem.setStandardButtonState("back", "mouseOver", true)
end

function widgetSystem.onMouseOverButton(anarkElement)
	local buttonElement = widgetSystem.getButtonElementByAnarkElement(anarkElement)
	if buttonElement == nil then
		return
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end
	
	if buttonElement.active then
		widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseOver", true)
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkButtonElement(anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseOverCheckBox(anarkElement)
	local checkboxElement = widgetSystem.getCheckBoxElementByAnarkElement(anarkElement)
	if checkboxElement == nil then
		return
	end

	local checkboxID = widgetSystem.getWidgetIDByElementEntry(checkboxElement)
	if not IsValidWidgetElement(checkboxID) then
		return -- view might have already been changed
	end
	
	if checkboxElement.active then
		widgetSystem.setCheckBoxElementState(checkboxID, checkboxElement, "mouseOver", true)
	end

	local element, widgetID, row = widgetSystem.getTableElementByAnarkCheckBoxElement(anarkElement)
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseOverCloseButton()
	widgetSystem.setStandardButtonState("close", "mouseOver", true)
end

function widgetSystem.onMouseOverGraphDataPoint(anarkElement)
	local graphElement, data = widgetSystem.getGraphElementByAnarkElement(anarkElement)
	if graphElement == nil then
		return
	end

	local textx = ""
	local int, frac = math.modf(data[2].x)
	textx = ((data[2].x < 0) and "-" or "") .. ConvertIntegerString(math.abs(int), true, 0, true, false)
	if (graphElement.xAxis.label.accuracy + 1) > 0 then
		frac = math.floor(math.abs(frac) * (10 ^ (graphElement.xAxis.label.accuracy + 1)) + 0.5)
		textx = textx .. L["."] .. string.format("%0".. (graphElement.xAxis.label.accuracy + 1) .."d", frac)
	end

	local texty = ""
	int, frac = math.modf(data[2].y)
	texty = ((data[2].y < 0) and "-" or "") .. ConvertIntegerString(math.abs(int), true, 0, true, false)
	if (graphElement.yAxis.label.accuracy + 1) > 0 then
		frac = math.floor(math.abs(frac) * (10 ^ (graphElement.yAxis.label.accuracy + 1)) + 0.5)
		texty = texty .. L["."] .. string.format("%0".. (graphElement.yAxis.label.accuracy + 1) .."d", frac)
	end

	private.mouseOverOverrideText = ((data[1] ~= "") and (data[1] .. " ") or "") .. "(" .. textx .. "; " ..texty .. ")"
end

function widgetSystem.onMouseOverGraphIcon(anarkElement)
	local graphElement, icon = widgetSystem.getGraphElementByAnarkElement(anarkElement)
	if graphElement == nil then
		return
	end

	local graphID = widgetSystem.getWidgetIDByElementEntry(graphElement)
	private.mouseOverOverrideText = icon.mouseOverText
end

function widgetSystem.onMouseOverSliderScrollBar(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderBarState(anarkElement, "mouseOver", true, widgetSystem.getWidgetIDByElementEntry(sliderElement))
end

function widgetSystem.onMouseOverScrollLeft(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "left", "mouseOver", true)
end

function widgetSystem.onMouseOverScrollRight(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "right", "mouseOver", true)
end

function widgetSystem.onMouseOverTableScrollBar(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseOver", true, tableID)
end

function widgetSystem.onMouseOverTable(anarkElement)
	local tableElement = widgetSystem.getTableElementByMousePick(anarkElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	if element then
		widgetSystem.setTableMousePickState(tableID, tableElement, "mouseOver", true)
	end
end

function widgetSystem.onMouseOverTableCell(anarkElement)
	local element, widgetID, row = widgetSystem.getTableElementByAnarkTableCellElement(anarkElement)
	
	if element then
		widgetSystem.setTableMousePickState(widgetID, element, "mouseOver", true, row)
	end
end

function widgetSystem.onMouseStartScrollBarDrag(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	widgetSystem.startScrollBarDrag(tableElement)
	widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseClick", true, tableID)
end

function widgetSystem.onMouseStartScrollLeft(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	if widgetSystem.startScrollLeft(sliderElement) then
		widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "left", "mouseClick", true)
	end
end

function widgetSystem.onMouseStartSliderDrag(anarkElement)
	widgetSystem.startSliderDrag()
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderBarState(anarkElement, "mouseClick", true, widgetSystem.getWidgetIDByElementEntry(sliderElement))
end

function widgetSystem.onMouseStopScrollLeft(anarkElement)
	widgetSystem.stopScroll()
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "left", "mouseClick", false)
end

function widgetSystem.onMouseStartScrollRight(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	if widgetSystem.startScrollRight(sliderElement) then
		widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "right", "mouseClick", true)
	end
end

function widgetSystem.onMouseStopScrollBarDrag(anarkElement)
	local anarkScrollBarElement = getElement("parent", anarkElement)
	local tableElement = widgetSystem.getTableElementByScrollBar(anarkScrollBarElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	widgetSystem.stopScrollBarDrag(tableElement)
	widgetSystem.setScrollBarState(tableElement.scrollBar, "mouseClick", false, tableID)
end

function widgetSystem.onMouseStopScrollRight(anarkElement)
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.stopScroll()
	widgetSystem.setSliderArrowState(widgetSystem.getWidgetIDByElementEntry(sliderElement), "right", "mouseClick", false)
end

function widgetSystem.onMouseStopSliderDrag(anarkElement)
	widgetSystem.stopSliderDrag()
	local anarkSliderElement = getElement("parent.parent.parent", anarkElement)
	local sliderElement = widgetSystem.getSliderElementByAnarkElement(anarkSliderElement)
	widgetSystem.setSliderBarState(anarkElement, "mouseClick", false, widgetSystem.getWidgetIDByElementEntry(sliderElement))
end

function widgetSystem.onMouseUpBackButton()
	widgetSystem.setStandardButtonState("back", "mouseClick", false)
	if private.frame ~= nil then
		-- can be nil, if we closed the frame before the mouse-event got dispatched
		widgetSystem.raiseHideEvent("back")
	end
end

function widgetSystem.onMouseUpButton(anarkElement)
	local buttonElement = widgetSystem.getButtonElementByAnarkElement(anarkElement)
	if buttonElement == nil or not buttonElement.active then
		return -- if the button is not active, there's nothing we've to do
	end

	local buttonID = widgetSystem.getWidgetIDByElementEntry(buttonElement)
	if not IsValidWidgetElement(buttonID) then
		return -- view might have already been changed
	end
	
	widgetSystem.setButtonElementState(buttonID, buttonElement, "mouseClick", false)
end

function widgetSystem.onMouseUpCloseButton()
	widgetSystem.setStandardButtonState("close", "mouseClick", false)
	if private.frame ~= nil then
		-- can be nil, if we closed the frame before the mouse-event got dispatched
		widgetSystem.raiseHideEvent("close")
	end
end

function widgetSystem.onMoveDown(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving down.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	-- #StefanMed - refactor usage of IsType() - get the information once and set it in elemententry (or elemententry.element) so we do not have to query it all the time
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling down is only supported for sliders
	end

	widgetSystem.moveDown(widgetID, elemententry.element)
end

function widgetSystem.onMoveUp(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving up.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register tables for up-scrolling in the Widgetcontroller
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling up is only supported for sliders
	end

	widgetSystem.moveUp(widgetID, elemententry.element)
end

function widgetSystem.onPageDown(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving page down.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling down is only supported for sliders
	end

	widgetSystem.pageDown(widgetID, elemententry.element)
end

function widgetSystem.onPageUp(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for moving page up.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	if not IsType(widgetID, "table") then
		-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
		return -- scrolling down is only supported for sliders
	end

	widgetSystem.pageUp(widgetID, elemententry.element)
end

function widgetSystem.onScrollDown(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for scrolling down.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	-- TODO: @Florian HACK
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(private.element.renderTarget)
	if widgetSystem.getRenderTargetMousePosition(renderTargetID) then
		widgetSystem.scrollDownRenderTarget(renderTargetID)
	elseif IsType(widgetID, "table") then
		widgetSystem.scrollDown(widgetID, elemententry.element, 1)
	end
	
	-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
end

function widgetSystem.onScrollUp(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for scrolling up.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for down-scrolling in the Widgetcontroller
	-- TODO: @Florian HACK
	local renderTargetID = widgetSystem.getWidgetIDByElementEntry(private.element.renderTarget)
	if widgetSystem.getRenderTargetMousePosition(renderTargetID) then
		widgetSystem.scrollUpRenderTarget(renderTargetID)
	elseif IsType(widgetID, "table") then
		widgetSystem.scrollUp(widgetID, elemententry.element, 1)
	end

	-- no error output, since it's a valid call (for instance for sliders which only respond to scrollLeft/Right)
end

function widgetSystem.onStartScrollLeft(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for start scrolling left.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for left-scrolling in the Widgetcontroller
	if IsType(widgetID, "slider") then
		if widgetSystem.startScrollLeft(elemententry.element) then
			widgetSystem.setSliderArrowState(widgetID, "left", "keyboard", true)
		end
	elseif IsType(widgetID, "table") then
		widgetSystem.moveLeft(widgetID, elemententry.element)
	end

	-- no error output, since it's a valid call for any element
end

function widgetSystem.onStopScrollLeft(_, sliderID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(sliderID) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	widgetSystem.stopScroll()
	widgetSystem.setSliderArrowState(sliderID, "left", "keyboard", false)
end

function widgetSystem.onStartScrollRight(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	local elemententry = private.associationList[widgetID]
	if elemententry == nil then
		DebugError("Widget system error. Could not retrieve interactive element for start scrolling right.")
		return
	end

	-- #StefanMed - refactor (no type dependency intended)
	-- #StefanMed - this check could be removed, if we only register sliders for right-scrolling in the Widgetcontroller
	if IsType(widgetID, "slider") then
		if widgetSystem.startScrollRight(elemententry.element) then
			widgetSystem.setSliderArrowState(widgetID, "right", "keyboard", true)
		end
	elseif IsType(widgetID, "table") then
		widgetSystem.moveRight(widgetID, elemententry.element)
	end

	-- no error output, since it's a valid call for any interactive element
end

function widgetSystem.onStopScrollRight(_, sliderID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(sliderID) then
		return -- can happen if a slider/view is closed before this callback is processed
	end

	widgetSystem.stopScroll()
	widgetSystem.setSliderArrowState(sliderID, "right", "keyboard", false)
end

-- widgetID atm is normally the WidgetID of the child of the view (i.e. table, etc.)
-- only for hotkey-handling it's the actual widget element which is assigned the hotkey
-- #StefanMed - make consistent, so the callback is directly pointing to the actual interactive (child) element?
function widgetSystem.onStartSelect(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen, when we process multiple keypresses at once (of which one is hiding/changing the view)
	end

	if IsType(widgetID, "editbox") or private.activeEditBox ~= nil then
		-- just skip the call, if we get an editbox or if we are in active editbox input mode
		return
	end

	-- #StefanMed - tidy up --- quick and dirty --- works only since we only have buttons with hotkey support
	if IsType(widgetID, "button") then
		-- hotkey case --- just change the button state
		local buttonElement = private.associationList[widgetID]
		-- if buttonElement is nil (aka button is not on-screen atm), there's nothing for us to do here
		if buttonElement ~= nil and buttonElement.element.active then
			widgetSystem.setButtonElementState(widgetID, buttonElement.element, "keyboardPress", true)
		end
		return
	end

	if private.interactiveElement == nil or not IsType(private.interactiveElement.widgetID, "table") or private.interactiveElement.element.interactiveChild == nil then
		return -- currently no interactive button we need to set the click-state for
	end

	local interactiveElement = private.interactiveElement.element.interactiveChild.element
	if interactiveElement ~= nil then
		-- #StefanLow - better add interactiveChild.isDisplayed to result in self-explanatiory code
		-- interactiveElement can be nil, if the element is not displayed atm - in this case there's nothing to do for us
		local interactiveWidgetID = private.interactiveElement.element.interactiveChild.widgetID
		if IsType(interactiveWidgetID, "button") then
			widgetSystem.setButtonElementState(interactiveWidgetID, interactiveElement, "keyboardPress", true)
		end
	end
end

-- see widgetSystem.onStartSelect() for widgetID parameter
function widgetSystem.onStopSelect(_, widgetID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(widgetID) then
		return -- can happen, when we process multiple keypresses at once (of which one is hiding/changing the view)
	end

	local editboxElement
	if IsType(widgetID, "editbox") then
		editboxElement = private.associationList[widgetID]
		if editboxElement == nil then
			-- #StefanLow - should we better move the table then to display the assigned box and activate it? --- same with buttons then?
			-- if editboxElement is nil (aka editbox is not on-screen atm), there's nothing for us to do here
			return
		end
		editboxElement = editboxElement.element
	elseif private.activeEditBox ~= nil and IsType(widgetID, "table") then
		-- #StefanMed - remove the IsType-check alongside changing the passed widgetID to be the actual element instead of the table when pressing ENTER with an active editbox/table
		-- check if widget element is table, so button hotkey doesn't trigger editbox confirm
		widgetID       = private.activeEditBox.editboxID
		editboxElement = private.activeEditBox.editboxElement
	end

	if editboxElement then
		if editboxElement.active then
			widgetSystem.confirmEditBoxInputInternal(widgetID, editboxElement)
		else
			if private.activeEditBox ~= nil then
				-- we decided to use a consistent editbox behavior --- whenever an editbox is closed, it keeps the current input (i.e. no cancel support)
				-- #StefanMed --- rethink the behavior ---- maybe better go with a per editbox-parameter to define whether a box is to keep its input on close (without ENTER) or revert it to the old text
				widgetSystem.confirmEditBoxInputInternal(private.activeEditBox.editboxID, private.activeEditBox.editboxElement)
			end
			widgetSystem.activateEditBoxInternal(widgetID, editboxElement)

			local element, widgetID, row = widgetSystem.getTableElementByAnarkEditboxElement(editboxElement.element)
			widgetSystem.setInteractiveElement(widgetID)
		end
		return
	end

	-- #StefanMed - refector the interactiveElement-handling so we do not have a special case for tables here

	-- #StefanMed - tidy up --- quick and dirty --- works only since we only have buttons with hotkey support
	if IsType(widgetID, "button") then
		-- hotkey case
		if IsButtonActive(widgetID) then
			-- only handle the stop-select event, if the button is actually active
			-- #StefanLow --- investigate whether it'd be better to not trigger the events in the first place
			local buttonElement = private.associationList[widgetID]
			-- if buttonElement is nil (aka button is not on-screen atm), there's nothing for us to do here
			if buttonElement ~= nil then
				widgetSystem.setButtonElementState(widgetID, buttonElement.element, "keyboardPress", false)			
			end
			CallWidgetEventScripts(widgetID, "onClick")
		end
		return
	end

	if private.interactiveElement ~= nil then
		local parameter
		local element = private.interactiveElement.element
		widgetID = private.interactiveElement.widgetID
		if IsType(widgetID, "table") and private.interactiveElement.element.interactiveChild ~= nil then
			local interactiveElement = private.interactiveElement.element.interactiveChild.element
			if interactiveElement ~= nil then
				local interactiveWidgetID = private.interactiveElement.element.interactiveChild.widgetID
				if IsType(interactiveWidgetID, "button") then
					-- #StefanLow - better add interactiveChild.isDisplayed to result in self-explanatiory code
					-- buttonElement can be nil, if the element is not displayed atm - in this case there's nothing to do for us
					widgetID = interactiveWidgetID
					widgetSystem.setButtonElementState(interactiveWidgetID, interactiveElement, "keyboardPress", true)
				elseif IsType(interactiveWidgetID, "checkbox") then
					widgetID = interactiveWidgetID
					widgetSystem.toggleCheckBox(interactiveWidgetID, interactiveElement)
					parameter = interactiveElement.checked
				end
			end
		end
		CallWidgetEventScripts(widgetID, "onClick", parameter)
	end
end

function widgetSystem.onTabInteractiveElement()
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if private.interactiveElement == nil then
		return -- view doesn't have any interactive element at all, nothing to do
	end

	if IsType(private.interactiveElement.widgetID, "table") then
		if private.interactiveElement.element.interactiveRegion == "normal" then
			if widgetSystem.swapInteractiveRegion(private.interactiveElement.widgetID, private.interactiveElement.element) then
				return -- swapped from normal to fixed row
			end
		end
	end

	local newWidgetID = SwitchInteractiveObject(private.frame)
	if newWidgetID == nil then
		DebugError("Widget system error. Failed to swap interactive object.")
		return
	end

	-- we must unset the previous interactive element (aka: the button in the previous table) first
	if private.interactiveElement.element.interactiveChild ~= nil then
		widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
	end

	widgetSystem.setInteractiveElement(newWidgetID)
end

function widgetSystem.onTableUpdate(_, tableID)
	if private.pendingFrame ~= nil then
		return -- skip this call, we've got a pending frame which isn't displayed yet and hence shouldn't issue this call in the context of the old frame
	end

	if not IsValidWidgetElement(tableID) then
		return -- can happen if a table/view is closed before this callback is processed
	end

	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		-- element not displayed right now, nothing to do
		return
	end
	widgetSystem.drawTableCells(tableID, tableentry.element, tableentry.element.topRow, tableentry.element.bottomRow, tableentry.element.curRow)
end

function widgetSystem.onToggleMouseOverText(_, value)
	widgetSystem.toggleMouseOverText(value)
end

function widgetSystem.onViewRemoved()
	if private.frame ~= nil then
		DebugError("Widget system error. We got a view removed-event with an active frame. Follow-up errors are expected to occur.")
	end

	RegisterWidget(config.view.viewtype, private.frameBorders.left, private.frameBorders.right, private.frameBorders.top, private.frameBorders.bottom)
end

-------------------------------------
-- Widget system related functions --
-------------------------------------
function widgetSystem.addToAssociationList(widgetID, elementEntry, rootAnarkElement, parentX, parentY, parentWidth, textComponent, activeSlide, inactiveSlide, curSlide)
	private.associationList[widgetID] = {
		["element"]          = elementEntry,
		["rootAnarkElement"] = rootAnarkElement,
		["parentx"]          = parentX,
		["parenty"]          = parentY,
		["parentwidth"]      = parentWidth,
		["textComponent"]    = textComponent,
		["activeSlide"]      = activeSlide,
		["inactiveSlide"]    = inactiveSlide,
		["curSlide"]         = curSlide
	}
end

-- returns the number of rows which need to be moved so that the specified bottom row will be the new bottom row
-- note that a positive number will be returned, if the table is to be moved downwards while a negative value indicates
-- the table to be shifted upwards
function widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, newBottomRow)
	if newBottomRow == tableElement.bottomRow then
		return 0 -- no shifting required, bottomRow is already the requested one
	end

	local curtableheight = 0
	-- ensure that we do not try to display > maxRows number of rows
	local newTopRow = math.max(tableElement.numFixedRows + 1, newBottomRow - tableElement.displayedRows + 1)
	-- calculate row-height starting from new bottomRow to top-row (inverse loop)
	for row = newBottomRow, newTopRow, -1 do
		-- calculate cell scale factor
		local curRowHeight = GetTableRowHeight(tableID, row)

		-- check if we exceed the max table height
		local nextrowheight = curRowHeight
		if row ~= newBottomRow then
			-- add space for border between table rows for rows 2..x
			nextrowheight = nextrowheight + config.table.bordersize
		end

		curtableheight = curtableheight + nextrowheight

		if curtableheight > tableElement.nonFixedSectionHeight then
			-- we would exceed the tableheight if we were to display the row - hence the new topRow is row + 1
			newTopRow = row + 1
			break
		end
	end

	-- note: callers ensure this is only called with topRow ~= nil
	return newTopRow - tableElement.topRow
end

-- takes a table and a number of pixels the table is expected to be shifted up/down and returns the actual number of rows which are to be shifed
-- if pixeldiff < 0 the table is expected to be shifted down (i.e. scroll down)
-- if pixeldiff > 0 the table is expected to be shifted up (i.e. scroll up)
-- the function returns 0, if the pixeldiff is less than half the width of the previous/next row
function widgetSystem.calculateRowsToMoveByPixelDiff(tableID, tableElement, pixeldiff)
	-- note: callers ensure by design, that this is only called if topRow ~= nil (aka: that we do have normal rows)
	-- since this is only called as part of dragging the scrollbar which by design only exists, if we have non-fixed rows
	if pixeldiff == 0 then
		return 0 -- simply case --- no calculation needed at all
	end

	local shiftUp = (pixeldiff > 0)

	local pixelToShift = math.abs(pixeldiff)
	local totalRowHeight = 0
	local rowsToShift = 0
	if shiftUp then
		-- check how many rows we have to shift down
		for row = tableElement.topRow, tableElement.numFixedRows + 1, -1 do
			local curRowHeight = GetTableRowHeight(tableID, row)
			totalRowHeight = totalRowHeight + curRowHeight / 2
			if totalRowHeight > pixelToShift then
				break -- done, next row would be less than half-scrolled, hence do not scroll to that
			end
			rowsToShift = rowsToShift + 1
			totalRowHeight = totalRowHeight + curRowHeight / 2
		end
	else
		-- check how many rows we have to shift up
		for row = tableElement.bottomRow, tableElement.numRows do
			local curRowHeight = GetTableRowHeight(tableID, row)
			totalRowHeight = totalRowHeight + curRowHeight / 2
			if totalRowHeight > pixelToShift then
				break -- done, next row would be less than half-scrolled, hence do not scroll to that
			end
			rowsToShift = rowsToShift + 1
			totalRowHeight = totalRowHeight + curRowHeight / 2
		end
	end

	return rowsToShift
end

-- #StefanMed this can actually be precalculated (aka: set tableElement.lastTopRow during setUpTable())
-- returns the number of rows which need to be moved so that the specified top row will be the new top row
-- note that a positive number will be returned, if the table is to be moved downwards while a negative value indicates
-- the table to be shifted upwards
function widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, newTopRow)
	-- note: callers ensure this is only called if we have non-fixed rows
	if newTopRow == tableElement.topRow then
		return 0 -- no shifting required, topRow is already the requested one
	end

	local curtableheight = 0
	local maxTopRow
	-- calculate the last row we should actually move down to (so that we do not unnecessarily page down too much and end up with only half the last table cells being displayed)
	for row = tableElement.numRows, tableElement.numFixedRows + 1, -1 do
		-- calculate cell scale factor
		local curRowHeight = GetTableRowHeight(tableID, row)

		-- check if we exceed the max table height
		local nextrowheight = curRowHeight
		if row ~= tableElement.numRows then
			-- add space for border between table rows for rows 2..x
			nextrowheight = nextrowheight + config.table.bordersize
		end

		curtableheight = curtableheight + nextrowheight

		if curtableheight > tableElement.nonFixedSectionHeight then
			-- we would exceed the tableheight if we were to display the row - hence the new minTopRow is row + 1
			maxTopRow = row + 1
			break
		end
	end

	local topRow = math.min(maxTopRow, newTopRow)

	return topRow - tableElement.topRow
end

-- return minRowHeight required for the fixed rows
function widgetSystem.calculateFixedRowHeight(tableID, tableElement)
	local numFixedRows = tableElement.numFixedRows
	local minRowHeight = 0
	local numRows      = GetTableNumRows(tableID)

	if numFixedRows > 0 then
		for row = 1, numFixedRows do
			minRowHeight = minRowHeight + GetTableRowHeight(tableID, row)
		end
		local numBorderElements = numFixedRows
		if numRows == numFixedRows then
			numBorderElements = numBorderElements - 1 -- no border element between fixed rows section and normal row section, if all rows are fixed rows
		end
		minRowHeight = minRowHeight + numBorderElements * config.table.bordersize
	end

	return minRowHeight
end

-- calculates the minimal row height which should be ensured to display the interactive/scrollable table
-- that way we ensure that a table always displays a selectable row including its following (unselectable) rows
--     --------------------
--     - selectable row   -  ---
--     - unselectable row -  - <--- ensure that the table's height is large enough so it can display these three rows all together
--     - unselectable row -  ---
--     - selectable row   -
-- 
-- return minRowHeight
function widgetSystem.calculateMinRowHeight(tableID, tableElement)
	local numRows = GetTableNumRows(tableID)

	if numRows == 0 then
		return 0 -- empty table, early out
	end

	local numFixedRows = tableElement.numFixedRows
	if numFixedRows == numRows then
		return 0 -- all rows are fixed rows, so no non-fixed-row section
	end

	local unselectableRows = tableElement.unselectableRows
	local minRowHeight = 0
	local startRow     = tableElement.numFixedRows + 1 -- row where the normal section starts
	local curNumRows   = startRow
	local curHeight    = GetTableRowHeight(tableID, startRow)

	for row = startRow, numRows do
		if not unselectableRows[row] then
			-- got next selectable row, update required height for displaying previous rows
			-- add required height for border elements
			curHeight    = curHeight + (curNumRows-1) * config.table.bordersize
			minRowHeight = math.max(minRowHeight, curHeight)

			-- reset for next row
			curNumRows = 0
			curHeight  = 0
		end

		curNumRows = curNumRows + 1
		curHeight  = curHeight  + GetTableRowHeight(tableID, row)
	end

	-- calculate last row height (in case it's a selectable one, or the only row at all)
	if numRows == startRow or unselectableRows[numRows] then
		curHeight    = curHeight + (curNumRows-1) * config.table.bordersize
		minRowHeight = math.max(minRowHeight, curHeight)
	end

	return minRowHeight
end

-- returns the number of steps the slider should be scrolled by when performing a page left/right scroll
-- singleStepSliderWidth = the width the slider would have if it were to represent a single value (i.e. 1)
-- sliderWidth = the actual width of the slider
-- granularity = the granularity the slider should ensure
function widgetSystem.calculateSliderScrollBarPageStep(singleStepSliderWidth, sliderWidth, granularity)
	local stepValue = sliderWidth / singleStepSliderWidth

	-- ensure that we only step by the granularity
	stepValue = stepValue - (stepValue % granularity)

	local numberOfSteps = stepValue / granularity

	-- ensure that we at least perform a single step (even if the calculated page stepValue was < granularity)
	numberOfSteps = math.max(numberOfSteps, 1)

	return numberOfSteps
end

function widgetSystem.convertAlignment(alignment)
	if alignment == "left" then
		return 0
	elseif alignment == "center" then
		return 1
	else -- right
		return 2
	end
end

-- returns the column width in px (restricted to a precision of 0.01% to prevent float inaccuracy problems)
-- We only ensure a precesion of 0.01% when working with percent values so that we don't run into float precision problems
-- for any tablewidth <= 10,000 px.
-- returns true, iff columns could be converted successfully
--         false, indicating an error (most likely exceeding the max table width)
function widgetSystem.convertColumnWidth(columnWidths, columnWidthsInPercent, tablewidth)
	local unaccountedwidths = {}
	local sumAllColumns = 0

	-- calculate sum of all columns and convert percentage values to px values
	local columnwidth
	local extraPixel = nil
	local substractedPixel = false
	for key, value in ipairs(columnWidths) do
		sumAllColumns = sumAllColumns + value
		if value == 0 then
			table.insert(unaccountedwidths, key)
		elseif columnWidthsInPercent then
			columnwidth = value / 100 * tablewidth
			if extraPixel then
				columnwidth = columnwidth - 1
				extraPixel = nil
				substractedPixel = true -- indicates that we already substracted a pixel --- the next ceil hence will not cause an extra pixel being used
			end
			if columnwidth % 1 ~= 0 then
				-- prevent subpixels
				columnwidth = math.ceil(columnwidth)
				if substractedPixel then
					substractedPixel = false
				else
					extraPixel = key
				end
			end
			columnWidths[key] = columnwidth
		end
	end
	if extraPixel then
		columnWidths[extraPixel] = columnWidths[extraPixel] -1
		extraPixel = nil
	end

	-- ensure the sum of all columns doesn't exceed the available table width (i.e. is not > 100% or > tablewidth)
	if columnWidthsInPercent then
		if sumAllColumns > 100 then
			return false
		end
	else -- column widths in px
		if sumAllColumns > tablewidth then
			return false
		end
	end

	-- calculate auto values up to 100% of the table width
	local widthpercolumn
	if #unaccountedwidths ~= 0 then
		local widthleft
		local lastcolumn
		if columnWidthsInPercent then
			widthleft = 100 - sumAllColumns
			-- flooring the remaining percentage, so we won't exceed the table width due to float-precision issues
			-- i.e. the resulting table width can be anything between 99% and 100%
			widthpercolumn = math.floor(widthleft * 100 / #unaccountedwidths) / 100
			lastcolumn = widthleft - (widthpercolumn * (#unaccountedwidths - 1))
			-- always ceil the last pixel (#StefanLow - unittest to prove that assumption is correct)
			lastcolumn = math.ceil(lastcolumn / 100 * tablewidth)
		else
			widthleft = tablewidth - sumAllColumns
			widthpercolumn = math.floor(widthleft / #unaccountedwidths)
			lastcolumn = widthpercolumn - (widthpercolumn * (#unaccountedwidths - 1))
		end
		columnWidths[table.remove(unaccountedwidths)] = lastcolumn
	end

	-- #StefanLow could be done directly above
	-- convert back to px
	if columnWidthsInPercent then
		for _, value in ipairs(unaccountedwidths) do
			columnwidth = widthpercolumn / 100 * tablewidth
			if extraPixel then
				columnwidth = columnwidth - 1
				extraPixel = nil
				substractedPixel = true -- indicates that we already substracted a pixel --- the next ceil hence will not cause an extra pixel being used
			end
			if columnwidth % 1 ~= 0 then
				-- prevent widths using subpixel
				-- ceil the value and for the next column reduce the cell size by one
				columnwidth = math.ceil(columnwidth)
				if substractedPixel then
					substractedPixel = false
				else
					extraPixel = value
				end
			end
			columnWidths[value] = columnwidth
		end
		if extraPixel then
			-- reduce the last column by one so to ensure we've got the correct table width
			columnWidths[value] = columnWidths[value] - 1
		end
	end

	return true -- done
end

function widgetSystem.disableAnimatedBackground()
	if private.animatedBackgroundEnabled then
		local backgroundElement = private.miniWidgetSystemUsed and private.master.miniWidgetSystem.background or private.master.background
		goToSlide(backgroundElement, "fadeout")
	end
end

-- draws the specified portion of the table
-- returns the current table height
function widgetSystem.drawTableCells(tableID, tableElement, firstRow, lastRow, curRow)
	-- note: caller ensures that firstRow is not null, if we do have non-fixed rows
	-- hide old table cells, so we start anew
	widgetSystem.hideTableCells(tableElement)

	local cellposy       = tableElement.offsety
	local curtableheight = 0
	local displayedRows = 0

	-- first we draw the fixed rows
	if tableElement.numFixedRows > 0 then
		curtableheight, _, displayedRows = widgetSystem.drawTableSection(tableID, tableElement, 1, tableElement.numFixedRows, displayedRows, cellposy, 0, 0, true)
		cellposy = cellposy - curtableheight
	end

	-- next draw the non-fixed rows
	if lastRow > tableElement.numFixedRows then
		if firstRow <= tableElement.numFixedRows then
			firstRow = tableElement.numFixedRows + 1
		end
		tableElement.topRow = firstRow
		curtableheight, lastRow, displayedRows = widgetSystem.drawTableSection(tableID, tableElement, firstRow, lastRow, displayedRows, cellposy, curtableheight, tableElement.numFixedRows, false)
	end

	tableElement.bottomRow = lastRow
	tableElement.displayedRows = displayedRows

	-- only select rows, if the table is interactive
	if IsInteractive(tableID) then
		widgetSystem.selectRowInternal(tableID, tableElement, curRow)
	end

	return curtableheight
end

-- draws the specified table cell section at the specified y-position
-- curtableheight specifies the height of any previous table section (if any - 0 otherwise)
-- cellIndexOffset specifies the offset of the cellindex which is to be used for drawing table cells (so that when drawing certain table sections they don't reuse table cells of previous sections)
-- returns tableheight, lastDrawnRow
function widgetSystem.drawTableSection(tableID, tableElement, firstRow, lastRow, displayedRows, cellposy, curtableheight, cellIndexOffset, isFixedRowSection)
	for row = firstRow, lastRow do
		-- calculate cell scale factor
		local curRowHeight = GetTableRowHeight(tableID, row)

		-- check if we exceed the max table height
		local nextrowheight = curRowHeight
		if curtableheight ~= 0 then
			-- unless for the top row in a table, we need to shift cells down by the bordersize
			nextrowheight = nextrowheight + config.table.bordersize
			cellposy = cellposy - config.table.bordersize
		end
		if curtableheight + nextrowheight > tableElement.height then
			lastRow = row - 1
			break -- skip the following lines
		end

		-- get the tablerow anark elements
		tableElement.cell[row-firstRow+1+cellIndexOffset] = widgetSystem.getElement("tableRows")
		if tableElement.cell[row-firstRow+1+cellIndexOffset] == nil then
			DebugError("Widget system error. No more table rows available. Skipping following rows.")
			lastRow = row - 1
			break
		else
			displayedRows = displayedRows + 1
		end
		curtableheight = curtableheight + nextrowheight

		-- move cellposition down by half the size of the scaled bar texture, so it is positionined correctly at the cellposy
		-- cellposy = cell position for previous row - curRowHeight / 2
		cellposy = cellposy - curRowHeight / 2

		tableElement.cell[row-firstRow+1+cellIndexOffset].realRow = row

		-- create the table row
		for col = 1, tableElement.numCols do
			local colspan = GetTableColumnSpan(tableID, row, col)
			if colspan ~= 0 then
				local cellentry = tableElement.cell[row-firstRow+1+cellIndexOffset][col]
				local colElement = cellentry.element
				cellentry.active = true
				local cellwidth = 0
				for i = 1, colspan do
					if isFixedRowSection then
						cellwidth = cellwidth + tableElement.fixedRowColumnWidths[col+i-1]
					else
						cellwidth = cellwidth + tableElement.columnWidths[col+i-1]
					end
				end
				cellwidth = cellwidth + config.table.bordersize*(colspan-1)
				local noTextSlide = "inactive"
				local textSlide   = "text"
				if tableElement.borderEnabled then
					noTextSlide = "background"
					textSlide = "textback"
					goToSlide(colElement, "background")
					widgetSystem.setElementScale(getElement("middle", colElement), cellwidth / 100, curRowHeight / 100)
				end
				-- position the table_cell-Anark element
				local cellposx = isFixedRowSection and tableElement.fixedRowCellposx[col] or tableElement.cellposx[col]
				widgetSystem.setElementPosition(colElement, cellposx + cellwidth/2, cellposy, (cellwidth % 2 ~= 0), (curRowHeight % 2 ~= 0))

				local childWidgetID = GetCellContent(tableID, row, col)
				if IsType(childWidgetID, "fontstring") then
					local textelement = getElement("Text", colElement)
					widgetSystem.setUpFontString(childWidgetID, colElement, textelement, textSlide, noTextSlide, -cellwidth/2, curRowHeight/2, cellwidth, ((cellposx + cellwidth/2) % 1 ~= 0), (cellposy % 1 ~= 0))
				elseif IsType(childWidgetID, "icon") then
					local iconelement = widgetSystem.getElement("icons")
					if iconelement ~= nil then
						widgetSystem.setUpIcon(childWidgetID, iconelement, colElement, cellposx, cellposy, cellwidth)
						cellentry.icon = iconelement
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No icons available in minimal widget system. Icon in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.icon.maxElements.." icons. Cannot display more. Icon in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "button") then
					local buttonElement = widgetSystem.getElement("buttons")
					if buttonElement ~= nil then
						cellentry.button = {
							["element"] = buttonElement
						}
						local isSelected = false
						if (private.interactiveChild ~= nil) and (private.interactiveElement.widgetID == tableID) then
							isSelected = (tableElement.interactiveChild.widgetID == childWidgetID)
						end
						widgetSystem.setUpButton(childWidgetID, cellentry.button, isSelected, cellposx, cellposy+curRowHeight/2, cellwidth, curRowHeight)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No buttons available in minimal widget system. Button in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.button.maxElements.." buttons. Cannot display more. Button in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "checkbox") then
					local checkboxElement = widgetSystem.getElement("checkboxes")
					if checkboxElement ~= nil then
						cellentry.checkbox = {
							["element"] = checkboxElement
						}
						local isSelected = false
						if (private.interactiveChild ~= nil) and (private.interactiveElement.widgetID == tableID) then
							isSelected = (tableElement.interactiveChild.widgetID == childWidgetID)
						end
						widgetSystem.setUpCheckBox(childWidgetID, cellentry.checkbox, isSelected, cellposx, cellposy+curRowHeight/2, cellwidth, curRowHeight)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No checkboxes available in minimal widget system. Checkbox in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.checkbox.maxElements.." checkboxes. Cannot display more. Checkbox in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "editbox") then
					local editboxElement = widgetSystem.getElement("editboxes")
					if editboxElement ~= nil then
						cellentry.editbox = {
							["element"] = editboxElement
						}
						widgetSystem.setUpEditBox(childWidgetID, cellentry.editbox, cellposx+cellwidth/2, cellposy+curRowHeight/2, cellwidth, curRowHeight)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No editboxes available in minimal widget system. Editbox in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.editbox.maxElements.." editboxes. Cannot display more. Editbox in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "graph") then
					local graphElement = widgetSystem.getElement("graphs")
					if graphElement ~= nil then
						cellentry.graph = {
							["element"] = graphElement
						}
						widgetSystem.setUpGraph(childWidgetID, cellentry.graph, cellposx+cellwidth/2, cellposy+curRowHeight/2, cellwidth, curRowHeight)
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No graphs available in minimal widget system. Graph in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.graph.maxElements.." graphs. Cannot display more. Graph in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "progresselement") then
					local progressElement = widgetSystem.getElement("progressElements")
					if progressElement ~= nil then
						widgetSystem.setUpProgressElement(childWidgetID, progressElement, colElement, cellposx, cellposy+curRowHeight/2, cellwidth, curRowHeight)
						cellentry["progressElement"] = progressElement
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No progress elements available in minimal widget system. Progress element in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.progressElement.maxElements.." progress elements. Cannot display more. Progress element in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				elseif IsType(childWidgetID, "timer") then
					local timerElement = widgetSystem.getElement("timerElements")
					if timerElement ~= nil then
						widgetSystem.setUpTimer(childWidgetID, timerElement, colElement, cellposx, cellposy+curRowHeight/2, cellwidth, curRowHeight)
						cellentry["timer"] = timerElement
					else
						if private.miniWidgetSystemUsed then
							DebugError("Widget system error. No timer elements available in minimal widget system. Timer element in table cell "..row.."/"..col.." will be skipped.")
						else
							DebugError("Widget system error. Already displaying "..config.timer.maxElements.." timer elements. Cannot display more. Timer element in table cell "..row.."/"..col.." will be skipped.")
						end
					end
				else
					DebugError("Widget system error. Table contains unsupported cellcontent. Skipping item in table cell "..row.."/"..col..".")
				end
			end -- if colspan ~= 0
		end -- for col

		-- update the cellposition to the upper position of the next cell (moving the remaining half of the current cell height)
		cellposy = cellposy - curRowHeight/2

		-- set to default color
		widgetSystem.setTableRowColor(tableElement, row, { GetTableRowColor(tableID, row) }, config.table.unselectedRowColor, false)
	end -- for row

	return curtableheight, lastRow, displayedRows
end

function widgetSystem.enableAnimatedBackground(frame)
	if private.animatedBackgroundEnabled then
		local fullwidth = private.width + private.frameBorders.left + private.frameBorders.right
		local fullheight = private.height + private.frameBorders.top + private.frameBorders.bottom

		-- update the background element sizes
		local backgroundElement = private.miniWidgetSystemUsed and private.master.miniWidgetSystem.background or private.master.background
		for _, elementName in ipairs(config.background.scaleXElements) do
			widgetSystem.setElementScale(getElement(elementName, backgroundElement), fullwidth/100)
		end
		for _, elementName in ipairs(config.background.scaleYElements) do
			widgetSystem.setElementScale(getElement(elementName, backgroundElement), nil, fullheight/100)
		end

		if IsFadeEnabled(frame) then
			goToSlide(backgroundElement, "fadein")
		else
			goToSlide(backgroundElement, "idle")
		end
	end
end

-- this function returns a formated number string ensuring that the charLimit is not exceeded
-- values are truncated to K/M as its needed
-- if two values are given, value two is encapsulated in parantheses
-- given suffixes are appended to the values
-- if for any reason the numbers cannot be truncated so much to fit into the char limit, the returned string ends with "..." indicating that some data is missing
function widgetSystem.formatNumber(value1, suffix1, value2, suffix2, charLimit)
	if charLimit ~= nil and charLimit < 3 then
		DebugError("Widget system error. Invalid call to formatNumber(). character limit '"..charLimit.."' is out of bounds (must be nil or >= 3)")
	end

	-- construct value 1 part
	local value1String = widgetSystem.formatSingleNumber(value1)
	local suffix1String = suffix1 or ""
	value1String = value1String..suffix1String

	-- construct value 2 part
	local value2String = widgetSystem.formatSingleNumber(value2)
	local suffix2String = suffix2 or ""
	local value2Prefix = ""
	local value2Suffix = ""
	if value2 then
		value2Prefix = " ("
		value2Suffix = ")"
	end
	value2String = value2Prefix..value2String..suffix2String..value2Suffix

	if charLimit == nil then
		-- no limitation, good, we're done
		return value1String..value2String
	end

	if charLimit >= #(value1String..value2String) then
		-- limit not exceeded - return the entire string
		return value1String..value2String
	end

	-- calculate minimum required number of cahracters for the values
	local requiredChars = #suffix2String + #value2Prefix + #value2Suffix + #suffix1String
	if requiredChars > charLimit then
		return "..." -- static number information already exceed the char limit - there's nothing we can do, hence return default truncation
	end

	local valueTags = { L["k"], L["M"] }
	for i = 1, 2 do
		-- we start truncating value2 (since it's expected to be less important for accuracy loss)
		if value2 ~= nil and value2 > 1000 then
			-- prevent setting to 0 (we do not want to truncate values even like 999 => 1k)
			value2 = math.ceil(value2 / 1000)
			value2String = value2Prefix..widgetSystem.formatSingleNumber(value2)..valueTags[i]..suffix2String..value2Suffix
			requiredChars = #(value1String..value2String)
			if requiredChars <= charLimit then
				return value1String..value2String
			end
		end

		if value1 > 1000 then
			-- prevent setting to 0 (we do not want to truncate values even like 999 => 1k)
			value1 = math.ceil(value1 / 1000)
			value1String = widgetSystem.formatSingleNumber(value1)..valueTags[i]..suffix1String
		end

		requiredChars = #(value1String..value2String)
		if requiredChars <= charLimit then
			return value1String..value2String
		end
	end

	local fullstring = value1String..value2String
	return string.sub(fullstring, 1, charLimit-3).."..." -- no way to fit the entire string into the character limit, truncate ending with "..."
end

-- returns the single formated number (using the configured thousand seperator)
function widgetSystem.formatSingleNumber(value)
	if value == nil then
		return ""	-- supported call --- return empty string
	end

	value = tostring(value)

	-- handle floats
	local floatpart = ""
	local commapos = string.find(value, "%.")
	if commapos then
		floatpart = L["."] .. string.sub(value, commapos + 1)
		value = string.sub(value, 1, commapos - 1)
	end
	
	-- insert thousand separators 
	pos = #value - 3
	while pos > 0 do
		value = string.sub(value, 1, pos)..L[","]..string.sub(value, pos+1)
		pos = pos - 3
	end

	return value .. floatpart
end

-- takes an table entry in private.element and returns the corresponding widget ID
function widgetSystem.getWidgetIDByElementEntry(elementEntry)
	for widgetID, entry in pairs(private.associationList) do
		if entry.element == elementEntry then
			return widgetID
		end
	end

	-- otherwise return nil
end

-- takes an table entry in private.element and returns the corresponding widget ID
function widgetSystem.getWidgetIDByAnarkElementEntry(anarkElementEntry)
	for widgetID, entry in pairs(private.associationList) do
		if entry.rootAnarkElement == anarkElementEntry then
			return widgetID
		end
	end

	-- otherwise return nil
end

function widgetSystem.getRootAnarkElement(anarkElement)
	local originalAnarkElement = anarkElement
	local result = nil
	while anarkElement ~= private.widgetsystem do
		result = anarkElement
		anarkElement = getElement("parent", anarkElement)
	end

	if result == private.master.graph then
		local graphElement = widgetSystem.getGraphElementByAnarkElement(originalAnarkElement)
		if graphElement then
			return graphElement.element.mainElement
		end
	end

	return result
end

function widgetSystem.getCurrentInterval()
	local curTime = getElapsedTime()
	if private.nextStepIncreaseTime == nil then
		-- set for the first time
		private.nextStepIncreaseTime = curTime + config.slider.interval.initialStepDelay
	else
		if private.curScrollingStep >= config.slider.interval.steps[#config.slider.interval.steps] then
			return private.curScrollingStep -- no further step increases
		end
		if private.nextStepIncreaseTime < curTime then
			private.nextStepIncreaseTime = curTime + math.min(config.slider.interval.stepDelayIncrease * private.numStepIncreases + config.slider.interval.initialStepDelay, config.slider.interval.maxStepDelay)
			for _, value in ipairs(config.slider.interval.steps) do
				if value > private.curScrollingStep then
					private.curScrollingStep = value
					break
				end
			end
			private.numStepIncreases = private.numStepIncreases + 1
		end
	end

	return private.curScrollingStep
end

function widgetSystem.getFontHeight(fontname, fontsize)
	-- use memoizing since font/size combinations are quite limited (in most cases we'd only have 1-2 fontname/fontsize combinations within one view
	local fontheightarray = private.fontHeight[fontname]
	if fontheightarray == nil then
		fontheightarray = {}
		private.fontHeight[fontname] = fontheightarray
	end

	local fontheight = fontheightarray[fontsize]
	if fontheight == nil then
		fontheight = GetFontHeight(fontname, fontsize)
		fontheightarray[fontsize] = fontheight
	end

	return fontheight
end

function widgetSystem.getElement(type)
	local elementArray = private.miniWidgetSystemUsed and private.element.miniWidgetSystem or private.element
	if #elementArray[type] == 0 then
		return -- no more unassigned elements
	end

	return table.remove(elementArray[type])
end

function widgetSystem.getShapeElement(type)
	if #private.element.shapes[type] == 0 then
		return -- no more unassigned elements
	end
	
	return table.unpack(table.remove(private.element.shapes[type]))
end

function widgetSystem.getButtonElementByAnarkElement(anarkElement)
	-- check all tables
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		for _, rowentry in ipairs(tableElement.cell) do
			for _, columnentry in ipairs(rowentry) do
				if columnentry.button and columnentry.button.element == anarkElement then
					return columnentry.button
				end
			end
		end
	end
	
	-- otherwise return nil
end

function widgetSystem.getCheckBoxElementByAnarkElement(anarkElement)
	-- check all tables
	for _, tableElement in ipairs(private.element.table) do
		for _, rowentry in ipairs(tableElement.cell) do
			for _, columnentry in ipairs(rowentry) do
				if columnentry.checkbox and columnentry.checkbox.element == anarkElement then
					return columnentry.checkbox
				end
			end
		end
	end
	
	-- otherwise return nil
end

function widgetSystem.getEditBoxElementByAnarkElement(anarkElement)
	-- check all tables
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		for _, rowentry in ipairs(tableElement.cell) do
			for _, columnentry in ipairs(rowentry) do
				if columnentry.editbox and columnentry.editbox.element == anarkElement then
					return columnentry.editbox
				end
			end
		end
	end

	-- otherwise return nil
end

function widgetSystem.getGraphElementByAnarkElement(anarkElement)
	-- check all tables
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		for _, rowentry in ipairs(tableElement.cell) do
			for _, columnentry in ipairs(rowentry) do
				if columnentry.graph then
					if columnentry.graph.element.mainElement == anarkElement then
						return columnentry.graph
					else
						for _, dataPointElement in ipairs(columnentry.graph.element.dataPointElements) do
							if (getElement("marker1", dataPointElement) == anarkElement) or (getElement("marker2", dataPointElement) == anarkElement) then
								return columnentry.graph, widgetSystem.getGraphDataPointByDataPointAnarkElement(columnentry.graph, dataPointElement)
							end
						end
						for _, iconElement in ipairs(columnentry.graph.element.iconElements) do
							if (iconElement == anarkElement) or (getElement("icon", iconElement) == anarkElement) or (getElement("background", iconElement) == anarkElement) then
								return columnentry.graph, widgetSystem.getGraphIconByIconAnarkElement(columnentry.graph, iconElement)
							end
						end
					end
				end
			end
		end
	end
	
	-- otherwise return nil
end

function widgetSystem.getGraphDataPointByDataPointAnarkElement(graphElement, dataPointElement)
	for i, dataRecord in ipairs(graphElement.datarecords) do
		for j, data in ipairs(dataRecord.data) do
			if data.element == dataPointElement then
				return {dataRecord.mouseovertext, data}
			end
		end
	end
end

function widgetSystem.getGraphIconByIconAnarkElement(graphElement, iconElement)
	for i, icon in ipairs(graphElement.icons) do
		if icon.element == iconElement then
			return icon
		end
	end
end

-- return next column which needs to be checked for selectability
function widgetSystem.getNextColumn(startCol, minLimit, maxLimit, step, dir)
	local newCol = startCol + step * dir
	if newCol < minLimit or newCol > maxLimit then
		newCol = nil -- next column is out of limits
	end

	return newCol
end

function widgetSystem.getRenderTargetElementByAnarkElement(anarkElement)
	if anarkElement == private.element.renderTarget.element then
		return private.element.renderTarget
	end

	-- otherwise return nil
end

-- x, y = widgetSystem.getRenderTargetMousePosition(renderTargetID)
-- returns nil, if there's an error or the cursor is not over the rendertarget
-- returns coordinates [-1,1] --- lower left corner being -1/-1
function widgetSystem.getRenderTargetMousePosition(renderTargetID)
	local renderTargetElement = private.associationList[renderTargetID]
	if renderTargetElement == nil then
		return nil, nil, 1, "invalid rendertarget element"
	end

	local posX, posY = GetLocalMousePosition()
	if posX == nil then
		return -- currently not over the presentation at all - valid call, but no mouse position
	end

	local renderTargetX, renderTargetY = GetOffset(renderTargetID)
	local width, height = GetSize(renderTargetID)

	-- transform space into rendertarget space (center is 0/0)
	local centerX = (private.offsetx + width/2 + renderTargetX)
	local centerY = (private.offsety - height/2 - renderTargetY)
	local renderTargetPosX = posX - centerX
	local renderTargetPosY = posY - centerY

	if (math.abs(renderTargetPosX) > width/2) or (math.abs(renderTargetPosY) > height/2) then
		return -- inside the correct presentation but not over the rendertarget - valid call, but no mouse position
	end

	return renderTargetPosX / (width/2), renderTargetPosY / (height/2)
end

-- textureFilename = widgetSystem.getRenderTargetTexture(renderTargetID)
function widgetSystem.getRenderTargetTexture(renderTargetID)
	local renderTargetElement = private.associationList[renderTargetID]
	if renderTargetElement == nil then
		return nil, 1, "invalid rendertarget element"
	end

	return renderTargetElement.element.textureString
end

-- sliderPosY = widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement)
-- anarkScrollBarElement -> Anark element: widgetsystem.table_scrollbar
function widgetSystem.getScrollBarSliderPosition(anarkScrollBarElement)
	local scrollbarPosY = getAttribute(anarkScrollBarElement, "position.y")
	local sliderPosY    = getAttribute(getElement("slider", anarkScrollBarElement), "position.y")

	-- the slider position is actually the slider position PLUS the scrollbar position (since the elements are nested)
	return sliderPosY + scrollbarPosY
end

-- returns widgetID of the element in the cell if col/row is selectable, otherwise nil
function widgetSystem.getSelectableCellElement(tableID, row, col)
	if GetTableColumnSpan(tableID, row, col) ~= 0 then
		local cellElementID = GetCellContent(tableID, row, col)
		if IsSelectable(cellElementID) then
			return cellElementID -- interactive (and selectable) cellelement
		end
	end

	-- otherwise returns nil
end

function widgetSystem.getSliderCenterValue(value, scaleinfo)
	if scaleinfo.roundingType == 0 then
		value = math.ceil(value * scaleinfo.factor)
	elseif scaleinfo.roundingType == 1 then
		value = math.floor(value * scaleinfo.factor)
	else
		value = value * scaleinfo.factor
	end

	value = math.max(value, (scaleinfo.minLimit or value))
	value = math.min(value, (scaleinfo.maxLimit or value))

	return value
end

function widgetSystem.getSliderElementByAnarkElement(anarkElement)
	if anarkElement == private.element.slider.element then
		return private.element.slider
	end

	-- otherwise return nil
end

-- sliderPosX = widgetSystem.getSliderPosition(anarkSliderBarElement)
-- anarkSliderBarElement -> Anark Element: widgetsystem.slider.slider.slider
function widgetSystem.getSliderPosition(anarkSliderBarElement)
	local anarkSliderGroupElement = getElement("parent", anarkSliderBarElement)
	local anarkWholeSliderElement = getElement("parent", anarkSliderGroupElement)

	local sliderPosX         = getAttribute(getElement("slider", anarkSliderBarElement), "position.x")
	local sliderbarPosX      = getAttribute(anarkSliderBarElement, "position.x")
	local sliderGroupPosX    = getAttribute(anarkSliderGroupElement, "position.x")
	local sliderWholeBarPosX = getAttribute(anarkWholeSliderElement, "position.x")
	local sliderPivotX       = getAttribute(anarkWholeSliderElement, "pivot.x")

	-- the slider position is actually the slider position PLUS all the slider's nested elements MINUS the slider pivot
	return sliderPosX + sliderbarPosX + sliderGroupPosX + sliderWholeBarPosX - sliderPivotX
end

function widgetSystem.getSliderSideValue(value, offset, scaleinfo, isFixed)
	if isFixed then
		return offset
	end

	if scaleinfo.roundingType == 0 then
		value = math.ceil(value * scaleinfo.factor)
	elseif scaleinfo.roundingType == 1 then
		value = math.floor(value * scaleinfo.factor)
	else
		value = value * scaleinfo.factor
	end

	if scaleinfo.inverted then
		value = -value
	end

	value = value + offset

	value = math.max(value, (scaleinfo.minLimit or value))
	value = math.min(value, (scaleinfo.maxLimit or value))

	return value
end

-- value1, value2 = getSliderValue(sliderID)
function widgetSystem.getSliderValue(sliderID)
	local sliderElement = private.associationList[sliderID]
	if sliderElement == nil then
		return nil, nil, 1, "invalid slider element"
	end
	local sliderValue = sliderElement.element.curValue - sliderElement.element.zeroValue

	local value1 = widgetSystem.getSliderCenterValue(sliderValue, sliderElement.element.scale[1])
	local value2
	if sliderElement.element.scale[2] then
		value2 = widgetSystem.getSliderCenterValue(sliderValue, sliderElement.element.scale[2])
	end

	return value1, value2
end

function widgetSystem.getTableElementByAnarkTableCellElement(anarkElement)
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		local displayedRows = tableElement.displayedRows or 0
		for row = 1, displayedRows do
			for col = 1, config.tableRows.maxCols do
				if tableElement.cell[row][col].element == anarkElement then
					return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow -- found cell, return information
				end
			end
		end
	end
end

function widgetSystem.getTableElementByAnarkButtonElement(anarkElement)
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		local displayedRows = tableElement.displayedRows or 0
		for row = 1, displayedRows do
			for col = 1, config.tableRows.maxCols do
				if tableElement.cell[row][col].button and tableElement.cell[row][col].button.element == anarkElement then
					return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow -- found cell, return information
				end
			end
		end
	end
end

function widgetSystem.getTableElementByAnarkCheckBoxElement(anarkElement)
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		local displayedRows = tableElement.displayedRows or 0
		for row = 1, displayedRows do
			for col = 1, config.tableRows.maxCols do
				if tableElement.cell[row][col].checkbox and tableElement.cell[row][col].checkbox.element == anarkElement then
					return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow -- found cell, return information
				end
			end
		end
	end
end

function widgetSystem.getTableElementByAnarkEditboxElement(anarkElement)
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		local displayedRows = tableElement.displayedRows or 0
		for row = 1, displayedRows do
			for col = 1, config.tableRows.maxCols do
				if tableElement.cell[row][col].editbox and tableElement.cell[row][col].editbox.element == anarkElement then
					return tableElement, widgetSystem.getWidgetIDByElementEntry(tableElement), tableElement.cell[row].realRow -- found cell, return information
				end
			end
		end
	end
end

function widgetSystem.getTableElementByScrollBar(scrollBarElement)
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		if tableElement.scrollBar.element == scrollBarElement then
			return tableElement
		end
	end

	-- otherwise return nil
end

function widgetSystem.getTableElementByMousePick(mousePickElement)
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for _, tableElement in ipairs(tableElements) do
		if tableElement.mousePick.element == mousePickElement then
			return tableElement
		end
	end

	-- otherwise return nil
end

function widgetSystem.getTopRow(tableID)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end

	if not widgetSystem.hasNonFixedRows(tableentry.element) then
		return nil, 2, "table does not contain normal (non-fixed) rows"
	end

	return tableentry.element.topRow
end

-- returns the usable table width in px
function widgetSystem.getUsableTableWidth(width, offsetx, numColumns, hasScrollBar)
	numColumns = numColumns or 1
	-- #StefanMed - hack... - actually we wouldn't have to pass along the width here but could get it from the actual frame width - however, this is only created once the frame is assigned --- hence needs refactoring
	local usablewidth = width - offsetx - (numColumns - 1)*config.table.bordersize
	if hasScrollBar then
		usablewidth = usablewidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
	end
	return usablewidth
end

-- #StefanMed - replace with Lua UTF8 library
function widgetSystem.getUTF8CharacterPrevIndex(text, pos)
	if pos <= 0 then
		-- invalid call - given index must be positive (>= 1)
		DebugError("Widget system error. Invalid call to getUTF8CharacterPrevIndex(). Index "..tostring(pos).." is negative.")
		return -1
	end

	local byteLength = #text
	if pos > byteLength then
		-- invalid call - requesting an index past the actual string
		DebugError("Widget system error. Cannot retrieve UTF8 previous index. Index "..tostring(pos).." exceeds bytelength of given text: '"..tostring(text).."' - max valid index is: "..tostring(byteLength)..".")
		return -1
	end

	while pos > 1 do
		if bit.band(string.byte(text, pos), 0xC0) ~= 0x80 then
			-- found control character
			return pos - 1
		end
		pos = pos - 1
	end

	-- no control character found, hence there is no previous character
	return 0
end

function widgetSystem.hasNonFixedRows(tableElement)
	return tableElement.topRow ~= nil
end

function widgetSystem.hideAllElements()
	-- clear association list first, so that successive call to widgetSystem.hideTable() does not unnecessarily remove one entry after another
	private.associationList = {}
	private.interactiveElement = nil

	if private.mouseOverText then
		widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
	end

	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	for index in ipairs(tableElements) do
		widgetSystem.hideTable(index)
	end

	-- hide background textures
	local backgroundTexture = private.miniWidgetSystemUsed and private.master.miniWidgetSystem.backgroundTexture or private.master.backgroundTexture
	local overlayTexture = private.miniWidgetSystemUsed and private.master.miniWidgetSystem.overlayTexture or private.master.overlayTexture
	goToSlide(backgroundTexture, "inactive")
	goToSlide(overlayTexture, "inactive")

	if not private.miniWidgetSystemUsed then
		widgetSystem.hideSlider(private.element.slider)
		widgetSystem.hideRenderTarget(private.element.renderTarget)

		widgetSystem.hideStandardButtons()
	end
end

function widgetSystem.hideButton(buttonElement, iconActive, icon2Active, textActive, hotkeyIconActive)
	goToSlide(buttonElement.element, "inactive")
	if iconActive then
		local iconElement = getElement("Icon", buttonElement.element)
		widgetSystem.setElementPosition(iconElement, 0, 0)
		goToSlide(iconElement, "inactive")
	end
	if icon2Active then
		local iconElement = getElement("Icon2", buttonElement.element)
		widgetSystem.setElementPosition(iconElement, 0, 0)
		goToSlide(iconElement, "inactive")
	end
	if textActive then
		setAttribute(getElement("Text", buttonElement.element), "textstring", "")
	end
	if hotkeyIconActive then
		goToSlide(getElement("Hotkey", buttonElement.element), "inactive")
	end
	table.insert(private.element.buttons, buttonElement.element)
	widgetSystem.removeFromAssociationList(buttonElement)
end

function widgetSystem.hideCheckBox(checkboxElement)
	goToSlide(checkboxElement.element, "inactive")
	table.insert(private.element.checkboxes, checkboxElement.element)
	widgetSystem.removeFromAssociationList(checkboxElement)
end

function widgetSystem.hideEditBox(editboxElement, hotkeyIconActive)
	if editboxElement.active then
		widgetSystem.deactivateEditBox(editboxElement)
	end
	goToSlide(editboxElement.element, "inactive")
	setAttribute(getElement("Text", editboxElement.element), "textstring", "")
	if hotkeyIconActive then
		goToSlide(getElement("Hotkey", editboxElement.element), "inactive")
	end
	table.insert(private.element.editboxes, editboxElement.element)
	widgetSystem.removeFromAssociationList(editboxElement)
end

function widgetSystem.hideGraph(graphElement)
	goToSlide(graphElement.element.mainElement, "inactive")
	for _, tickElement in ipairs(graphElement.element.tickElements) do
		goToSlide(tickElement, "inactive")
	end
	for _, dataPointElement in ipairs(graphElement.element.dataPointElements) do
		goToSlide(dataPointElement, "inactive")
	end
	for _, iconElement in ipairs(graphElement.element.iconElements) do
		goToSlide(iconElement, "inactive")
	end
	table.insert(private.element.graphs, graphElement.element)
	widgetSystem.removeFromAssociationList(graphElement)
end

function widgetSystem.hideHorizontalScrollBar(scrollbar)
	goToSlide(scrollbar.element, "inactive")
	goToSlide(scrollbar.sliderElement, "inactive")
	goToSlide(scrollbar.leftArrowElement, "inactive")
	goToSlide(scrollbar.rightArrowElement, "inactive")
	scrollbar.width    = nil
	scrollbar.pageStep = nil
end

function widgetSystem.hideIcon(iconelement)
	goToSlide(iconelement, "inactive")
	table.insert(private.element.icons, iconelement)
	widgetSystem.removeFromAssociationList(iconelement)
end

function widgetSystem.hideProgressElement(progressElement)
	goToSlide(getElement("bar", progressElement), "inactive")
	goToSlide(progressElement, "inactive")
	table.insert(private.element.progressElements, progressElement)
	widgetSystem.removeFromAssociationList(progressElement)
end

function widgetSystem.hideRenderTarget(renderTarget)
	goToSlide(renderTarget.element, "inactive")
	widgetSystem.removeFromAssociationList(renderTarget)
end

function widgetSystem.hideSlider(sliderElement)
	widgetSystem.hideHorizontalScrollBar(sliderElement.scrollBar)

	goToSlide(sliderElement.element, "inactive")
	sliderElement.curValue           = nil
	sliderElement.startValue         = nil
	sliderElement.zeroValue          = nil
	sliderElement.minValue           = nil
	sliderElement.maxValue           = nil
	sliderElement.granularity        = nil
	sliderElement.valuePerPixel      = nil
	sliderElement.minSelectableValue = nil
	sliderElement.maxSelectableValue = nil
	sliderElement.fixedValues        = nil
	sliderElement.invertedIndicator  = nil
	sliderElement.scale              = nil
	-- implicitly stop scrolling, since we invalided the element, which was set to be scrolled (if any)
	widgetSystem.stopScroll()
	widgetSystem.removeFromAssociationList(sliderElement)

	private.sliderActive = false
end

function widgetSystem.hideStandardButtons()
	private.backButtonShown = false
	private.closeButtonShown = false
	widgetSystem.updateStandardButtonState("close")
	widgetSystem.updateStandardButtonState("back")
end

function widgetSystem.hideTable(tableindex)
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	local tableElement = tableElements[tableindex]

	-- hide header
	goToSlide(tableElement.header, "inactive")
	goToSlide(tableElement.mousePick.element, "inactive")

	widgetSystem.hideVerticalScrollBar(tableElement.scrollBar)

	widgetSystem.hideTableCells(tableElement)

	-- reset members
	tableElement.borderEnabled           = nil
	tableElement.bottomRow               = nil
	tableElement.cellposx                = nil
	tableElement.displayedRows           = nil
	tableElement.fixedRowCellposx        = nil
	tableElement.columnWidths            = nil
	tableElement.fixedRowColumnWidths    = nil
	tableElement.curRow                  = nil
	tableElement.highlightedRow          = nil
	tableElement.height                  = nil
	tableElement.nonFixedSectionHeight   = nil
	tableElement.numCols                 = nil
	tableElement.numFixedRows            = nil
	tableElement.numRows                 = nil
	tableElement.offsety                 = nil
	tableElement.topBottomRow            = nil
	tableElement.topRow                  = nil
	tableElement.unselectableRows        = nil
	tableElement.interactiveRegion       = nil
	tableElement.normalSelectedRow       = nil
	tableElement.firstSelectableFixedRow = nil
	tableElement.interactiveChild        = nil
	-- icons are cleared in widgetSystem.hideTableCells()
	-- buttons are cleared in widgetSystem.hideTableCells()

	widgetSystem.removeFromAssociationList(tableElement)
end

function widgetSystem.hideTableCells(tableElement)
	local displayedRows = tableElement.displayedRows or 0
	for row = 1, displayedRows do
		local rowarray = tableElement.cell[row]
		rowarray.realRow = nil

		-- hide middle column elements
		for col = 1, config.tableRows.maxCols do
			local cellelement = rowarray[col].element
			textelement = getElement("Text", cellelement)
			if rowarray[col].active then
				goToSlide(cellelement, "inactive")
				rowarray[col].active = false
			end
			widgetSystem.removeFromAssociationList(textelement)

			-- hide icon
			if rowarray[col].icon ~= nil then
				widgetSystem.hideIcon(rowarray[col].icon)
				rowarray[col].icon = nil
			end

			-- hide button
			if rowarray[col].button ~= nil then
				local buttonElement = rowarray[col].button
				widgetSystem.hideButton(buttonElement, rowarray[col].button.iconActive, rowarray[col].button.icon2Active, rowarray[col].button.textActive, rowarray[col].button.hotkeyIconActive)
				rowarray[col].button = nil
			end

			if rowarray[col].checkbox ~= nil then
				local checkboxElement = rowarray[col].checkbox
				widgetSystem.hideCheckBox(checkboxElement)
				rowarray[col].checkbox = nil
			end

			-- hide editbox
			if rowarray[col].editbox ~= nil then
				local editboxElement = rowarray[col].editbox
				widgetSystem.hideEditBox(editboxElement, rowarray[col].editbox.hotkeyIconActive)
				rowarray[col].editbox = nil
			end

			-- hide graph
			if rowarray[col].graph ~= nil then
				local graphElement = rowarray[col].graph
				widgetSystem.hideGraph(graphElement)
				rowarray[col].graph = nil
			end

			-- hide progressElement
			local progressElement = rowarray[col].progressElement
			if progressElement ~= nil then
				widgetSystem.hideProgressElement(progressElement)
				rowarray[col].progressElement = nil
			end

			-- hide timers
			local timerElement = rowarray[col].timer
			if timerElement ~= nil then
				widgetSystem.hideTimer(timerElement)
				rowarray[col].timer = nil
			end
		end

		local tableRowElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.tableRows or private.element.tableRows
		table.insert(tableRowElements, rowarray)
		tableElement.cell[row] = nil
	end
end

function widgetSystem.hideTimer(timerElement)
	goToSlide(timerElement, "inactive")
	table.insert(private.element.timerElements, timerElement)
	private.activeTimer[timerElement] = nil
	widgetSystem.removeFromAssociationList(timerElement)
end

function widgetSystem.hideVerticalScrollBar(scrollbar)
	goToSlide(scrollbar.element, "inactive")
	goToSlide(scrollbar.sliderElement, "inactive")
	scrollbar.height           = nil
	scrollbar.sliderHeight     = nil
	scrollbar.active           = nil
	scrollbar.dragOffset       = nil
	scrollbar.previousMousePos = nil
	scrollbar.valuePerPixel    = nil
end

function widgetSystem.highlightTableRow(tableElement, row)
	-- note: caller ensures that this is only called, if we have non-fixed rows

	-- do not highlight fixed rows
	if row < tableElement.topRow or row > tableElement.bottomRow then
		return -- row not displayed, no highlight to set
	end

	widgetSystem.setTableRowColor(tableElement, row, { config.table.selectedRowColor.r, config.table.selectedRowColor.g, config.table.selectedRowColor.b, config.table.selectedRowColor.a }, config.table.selectedIconColor, true)
	tableElement.highlightedRow = row
end

function widgetSystem.initializeMasterElements()
	local layerElement = private.widgetsystem

	-- #StefanMed - shouldn't we also use the master elements themselves as the first element (i.e. one less clone per element type)?

	-- get general elements
	private.master.background            = getElement("background", layerElement)
	private.master.backgroundTexture     = getElement("backgroundTexture", layerElement)
	private.master.button                = getElement("button", layerElement)
	private.master.checkbox              = getElement("checkbox", layerElement)
	private.master.editbox               = getElement("editbox", layerElement)
	private.master.graph                 = getElement("graph", layerElement)
	private.master.graphTick             = getElement("graph.tick", layerElement)
	private.master.graphDataPoint        = getElement("graph.datapoint", layerElement)
	private.master.graphIcon             = getElement("graph.icon", layerElement)
	private.master.icon                  = getElement("icon", layerElement)
	private.master.overlayTexture        = getElement("overlayTexture", layerElement)
	private.master.progressElement       = getElement("progress", layerElement)
	private.master.renderTarget          = getElement("rendertarget", layerElement)
	private.master.slider                = getElement("slider", layerElement)
	private.master.timer                 = getElement("timer", layerElement)

	-- get table elements
	local tablearray = private.master.table
	tablearray.header    = getElement("table_header", layerElement)
	tablearray.cell      = getElement("table_cell", layerElement)
	tablearray.scrollBar = getElement("table_scrollbar", layerElement)
	tablearray.mousePick = getElement("table_mousepick", layerElement)

	-- get shapes
	private.master.shapeRectangle        = getElement("rectangle", private.shapes)
	private.master.shapeCircle           = getElement("circle", private.shapes)
	private.master.shapeTriangle         = getElement("triangle", private.shapes)

	-- mini widgetsystem
	private.master.miniWidgetSystem.background            = getElement("background", private.miniwidgetsystem)
	private.master.miniWidgetSystem.backgroundTexture     = getElement("backgroundTexture", private.miniwidgetsystem)
	private.master.miniWidgetSystem.overlayTexture        = getElement("overlayTexture", private.miniwidgetsystem)
	local minitablearray = private.master.miniWidgetSystem.table
	minitablearray.header    = getElement("table_header", private.miniwidgetsystem)
	minitablearray.cell      = getElement("table_cell", private.miniwidgetsystem)
	minitablearray.scrollBar = getElement("table_scrollbar", private.miniwidgetsystem)
	minitablearray.mousePick = getElement("table_mousepick", private.miniwidgetsystem)
end

function widgetSystem.initializeRenderTarget()
	-- we work directly with the rendertarget
	private.element.renderTarget = {
		["element"] = private.master.renderTarget,
		["textureElement"]  = getElement("rendertarget", private.master.renderTarget),
		["textureString"]   = config.renderTargetTextureFilename
	}

	local renderTargetElement = private.element.renderTarget.element
	registerForEvent("onMouseClick",       renderTargetElement, widgetSystem.onMouseClickRenderTarget)
	registerForEvent("onMouseDblClick",    renderTargetElement, widgetSystem.onMouseDblClickRenderTarget)
	registerForEvent("onMouseDown",        renderTargetElement, widgetSystem.onMouseDownRenderTarget)
	registerForEvent("onMouseUp",          renderTargetElement, widgetSystem.onMouseUpRenderTarget)
	registerForEvent("onMiddleMouseDown",  renderTargetElement, widgetSystem.onMiddleMouseDownRenderTarget)
	registerForEvent("onMiddleMouseUp",    renderTargetElement, widgetSystem.onMiddleMouseUpRenderTarget)
	registerForEvent("onRightMouseDown",   renderTargetElement, widgetSystem.onRightMouseDownRenderTarget)
	registerForEvent("onRightMouseUp",     renderTargetElement, widgetSystem.onRightMouseUpRenderTarget)
	RegisterMouseInteractions(renderTargetElement)

	PrepareRenderTarget(config.renderTargetTextureFilename)
end

function widgetSystem.initializeSliderElements()
	-- we work directly with the slider
	-- #StefanLow - update this code to support multiple sliders
	private.element.slider = {
		["element"] = private.master.slider,
		["scrollBar"]  = {
			["element"]           = getElement("slider.slider", private.master.slider),
			["sliderElement"]     = getElement("slider.slider.slider", private.master.slider),
			["leftArrowElement"]  = getElement("slider.slider.arrow_left", private.master.slider),
			["rightArrowElement"] = getElement("slider.slider.arrow_right", private.master.slider)
		}
	}
	private.sliderArrowState["left"]["element"] = private.element.slider.scrollBar.leftArrowElement
	private.sliderArrowState["right"]["element"] = private.element.slider.scrollBar.rightArrowElement

	-- initialize for mouse interactions
	local leftarrow  = private.element.slider.scrollBar.leftArrowElement
	local rightarrow = private.element.slider.scrollBar.rightArrowElement
	local backgroundSliderBar = getElement("background",  private.element.slider.scrollBar.element)
	local sliderBar = private.element.slider.scrollBar.sliderElement

	registerForEvent("onMouseClick",       backgroundSliderBar, widgetSystem.onMouseClickSliderScroll)
	registerForEvent("onMouseDblClick",    backgroundSliderBar, widgetSystem.onMouseClickSliderScroll)
	registerForEvent("onMouseDown",        leftarrow,           widgetSystem.onMouseStartScrollLeft)
	registerForEvent("onMouseDown",        rightarrow,          widgetSystem.onMouseStartScrollRight)
	registerForEvent("onMouseDown",        sliderBar,           widgetSystem.onMouseStartSliderDrag)
	registerForEvent("onMouseUp",          leftarrow,           widgetSystem.onMouseStopScrollLeft)
	registerForEvent("onMouseUp",          rightarrow,          widgetSystem.onMouseStopScrollRight)
	registerForEvent("onMouseUp",          sliderBar,           widgetSystem.onMouseStopSliderDrag)
	registerForEvent("onGroupedMouseOver", leftarrow,           widgetSystem.onMouseOverScrollLeft)
	registerForEvent("onGroupedMouseOver", rightarrow,          widgetSystem.onMouseOverScrollRight)
	registerForEvent("onGroupedMouseOver", sliderBar,           widgetSystem.onMouseOverSliderScrollBar)
	registerForEvent("onGroupedMouseOut",  leftarrow,           widgetSystem.onMouseOutScrollLeft)
	registerForEvent("onGroupedMouseOut",  rightarrow,          widgetSystem.onMouseOutScrollRight)
	registerForEvent("onGroupedMouseOut",  sliderBar,           widgetSystem.onMouseOutSliderScrollBar)

	-- register the complete slider for mouse over text
	RegisterMouseInteractions(private.master.slider)
	RegisterMouseInteractions(backgroundSliderBar)
	-- note the slider must not only be registered for mouse interactions for draggin/dropping support, but rather also so it obstructs clicks on the backgroundSliderBar behind the slider
	RegisterMouseInteractions(sliderBar)
	RegisterMouseInteractions(leftarrow)
	RegisterMouseInteractions(rightarrow)
end

function widgetSystem.initializeTableElements()
	for tableindex = 1, config.table.maxTables do
		private.element.table[tableindex] = {}
		local tableElement = private.element.table[tableindex]
		tableElement.header = clone(private.master.table.header, "table"..tableindex.."header")
		tableElement.headerText = getElement("Text", tableElement.header)
		tableElement.scrollBar = {
			["sliderState"] = {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["curSlide"]   = "inactive"
			}
		}
		tableElement.scrollBar.element = clone(private.master.table.scrollBar, "table"..tableindex.."scrollbar")
		tableElement.scrollBar.sliderElement = getElement("slider", tableElement.scrollBar.element)
		tableElement.mousePick = {
			["state"] = {
				["mouseOver"]  = {
					["state"] = false,
					-- ["original"] = nil,
					-- ["row"] = nil
				}
			}
		}
		tableElement.mousePick.element = clone(private.master.table.mousePick, "table"..tableindex.."mousepick")
		tableElement.cell = {}

		-- initialize for mouse interactions
		local backgroundSliderBar = getElement("background", tableElement.scrollBar.element)
		local sliderBar = tableElement.scrollBar.sliderElement
		local mousePick = tableElement.mousePick.element
		registerForEvent("onMouseClick",       backgroundSliderBar, widgetSystem.onMouseClickPageScroll)
		registerForEvent("onMouseDblClick",    backgroundSliderBar, widgetSystem.onMouseClickPageScroll)
		registerForEvent("onMouseDown",        sliderBar,           widgetSystem.onMouseStartScrollBarDrag)
		registerForEvent("onMouseUp",          sliderBar,           widgetSystem.onMouseStopScrollBarDrag)
		registerForEvent("onGroupedMouseOver", sliderBar,           widgetSystem.onMouseOverTableScrollBar)
		registerForEvent("onGroupedMouseOut",  sliderBar,           widgetSystem.onMouseOutTableScrollBar)
		registerForEvent("onGroupedMouseOver", mousePick,           widgetSystem.onMouseOverTable)
		registerForEvent("onGroupedMouseOut",  mousePick,           widgetSystem.onMouseOutTable)
		RegisterMouseInteractions(backgroundSliderBar)
		-- note the slider must not only be registered for mouse interactions for draggin/dropping support, but rather also so it obstructs clicks on the backgroundSliderBar behind the slider
		RegisterMouseInteractions(sliderBar)
		RegisterMouseInteractions(mousePick)
	end
end

function widgetSystem.initializeTableRowElements()
	for rowIndex = 1, config.tableRows.maxRows do
		private.element.tableRows[rowIndex] = {}
		for colIndex = 1, config.tableRows.maxCols do 
			local cellelement = clone(private.master.table.cell, "row"..rowIndex.."col"..colIndex)
			private.element.tableRows[rowIndex][colIndex] = {
				["element"] = cellelement
			}
			registerForEvent("onMouseClick",       cellelement, widgetSystem.onMouseClickTableCell)
			registerForEvent("onMouseDblClick",    cellelement, widgetSystem.onMouseClickTableCell)
			registerForEvent("onGroupedMouseOver", cellelement, widgetSystem.onMouseOverTableCell)
			registerForEvent("onGroupedMouseOut",  cellelement, widgetSystem.onMouseOutTableCell)
			RegisterMouseInteractions(cellelement)
		end
	end
end

function widgetSystem.initScale(anchorElement, scale)
	setAttribute(anchorElement, "scale.x", scale)
	setAttribute(anchorElement, "scale.y", scale)
	setAttribute(anchorElement, "scale.z", scale)
end

function widgetSystem.processTableMousePick(tableElement)
	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)

	-- if the state changed, fire the events
	for state, value in pairs(tableElement.mousePick.state) do
		if (value.original ~= nil) and (value.original ~= value.state) then
			if state == "mouseOver" then
				if value.state then
					CallWidgetEventScripts(tableID, "onTableMouseOver", value.row)
				else
					CallWidgetEventScripts(tableID, "onTableMouseOut", value.row)
				end
			end
		end
		tableElement.mousePick.state[state].original = nil
	end
end

function widgetSystem.setButtonElementState(button, buttonElement, state, value)
	-- if the state changed, fire the events
	if buttonElement.buttonState[state] ~= value then
		local event
		if state == "mouseOver" then
			if value then
				CallWidgetEventScripts(button, "onButtonMouseOver")
			else
				CallWidgetEventScripts(button, "onButtonMouseOut")
			end
		elseif value then
			if state == "keyboard" then
				CallWidgetEventScripts(button, "onButtonSelect")
			elseif state == "mouseClick" or state == "keyboardPress" then
				-- this is the only case where we could in principle change from a non-click to a click-state, check if we actually changed
				local wasClicked = (buttonElement.buttonState["mouseClick"] or buttonElement.buttonState["keyboardPress"])
				if not wasClicked then
					CallWidgetEventScripts(button, "onButtonDown")
				end
			end
		end
	end

	buttonElement.buttonState[state] = value
	widgetSystem.updateButtonState(button, buttonElement)
end

function widgetSystem.setCheckBoxElementState(checkbox, checkboxElement, state, value)
	-- if the state changed, fire the events
	if checkboxElement.checkboxState[state] ~= value then
		local event
		if state == "mouseOver" then
			if value then
				CallWidgetEventScripts(checkbox, "onCheckBoxMouseOver")
			else
				CallWidgetEventScripts(checkbox, "onCheckBoxMouseOut")
			end
		elseif value then
			if state == "keyboard" then
				CallWidgetEventScripts(checkbox, "onCheckBoxSelect")
			end
		end
	end

	checkboxElement.checkboxState[state] = value
	widgetSystem.updateCheckBoxState(checkbox, checkboxElement)
end

-- #StefanLow - split up into setElementPosX/setElementPosY (removes need for x ~= nil / y ~= nil checks)
-- xUseHalfPixel - indicates whether the x-position is to use half-pixel-positioning on even frame widths (otherwise, it's the other way around)
-- yUseHalfPixel - indicates whether the y-position is to use half-pixel-positioning on even frame heights (otherwise, it's the other way around)
function widgetSystem.setElementPosition(anarkElement, x, y, xUseHalfPixel, yUseHalfPixel)
	if config.verifyPixelExact then
		local testx = x
		if testx and ((xUseHalfPixel and (private.offsetx % 1 == 0)) or (not xUseHalfPixel and (private.offsetx % 1 ~= 0))) then
			testx = testx + 0.5
		end
		local testy = y
		if testy and ((yUseHalfPixel and (private.offsety % 1 == 0)) or (not yUseHalfPixel and (private.offsety % 1 ~= 0))) then
			testy = testy + 0.5
		end
		if (testx ~= nil and testx % 1 ~= 0) or (testy ~= nil and testy % 1 ~= 0) then
			DebugError("Widget system warning. Given position for element "..tostring(anarkElement).." uses subpixels. This will lead to graphical issues. x/y: "..tostring(x).." / "..tostring(y).." - using halfpixels (x/y): "..tostring(xUseHalfPixel).." / "..tostring(yUseHalfPixel))
		end
	end

	widgetSystem.setElementPositionUnchecked(anarkElement, x, y)
end

-- sets the element position directly without performing subpixel-positioning checks
function widgetSystem.setElementPositionUnchecked(anarkElement, x, y)
	if x ~= nil then
		setAttribute(anarkElement, "position.x", x)
	end
	if y ~= nil then
		setAttribute(anarkElement, "position.y", y)
	end
end

-- #StefanLow - split up into setElementScaleX/setElementScaleY (removes need for x ~= nil / y ~= nil checks)
function widgetSystem.setElementScale(anarkElement, x, y, z)
	-- #StefanHigh - reenable (See XT-2498)
	--[[if config.verifyPixelExact then
		if (x ~= nil and (x*100) % 1 ~= 0) or (y ~= nil and (y*100) % 1 ~= 0) then
			DebugError("Widget system warning. Given scale for element "..tostring(anarkElement).." uses subpixels. This will lead to graphical issues. x/y: "..tostring(x).." / "..tostring(y))
		end
	end]]

	if x ~= nil then
		setAttribute(anarkElement, "scale.x", x)
	end
	if y ~= nil then
		setAttribute(anarkElement, "scale.y", y)
	end
	if z ~= nil then
		setAttribute(anarkElement, "scale.z", z)
	end
end

function widgetSystem.setElementRotation(anarkElement, angle)
	if angle ~= nil then
		setAttribute(anarkElement, "rotation.z", angle)
	end
end

function widgetSystem.setInteractiveElement(widgetID)
	private.interactiveElement = {
		["element"]  = private.associationList[widgetID].element,
		["widgetID"] = widgetID
	}

	-- swap fixed regions to normal regions (if possible), when a table becomes the interactive element
	local swappedRegion = false
	if IsType(widgetID, "table") then
		if private.interactiveElement.element.interactiveRegion == "fixed" then
			widgetSystem.swapInteractiveRegion(private.interactiveElement.widgetID, private.interactiveElement.element)
			swappedRegion = true
		end
	end

	-- set the new interactive child element, if required
	if not swappedRegion and private.interactiveElement.element.interactiveChild ~= nil then
		widgetSystem.setInteractiveChildElement(private.interactiveElement.widgetID, private.interactiveElement.element, private.interactiveElement.element.interactiveChild.row, private.interactiveElement.element.interactiveChild.col, private.interactiveElement.element.interactiveChild.widgetID, private.interactiveElement.element.interactiveChild.element)
	end

	CallWidgetEventScripts(private.frame, "onInteractiveElementChanged", widgetID)
end

-- tableID           - the widgetID of the table containing the child
-- tableElement      - the table element entry of the table containing the child
-- childWidgetID     - the widgetID of the interactive child
-- childTableElement - the table entry of the element of the child
function widgetSystem.setInteractiveChildElement(tableID, tableElement, row, col, childWidgetID, childTableElement)
	tableElement.interactiveChild = {
		["row"]      = row,
		["col"]      = col,
		["element"]  = childTableElement,
		["widgetID"] = childWidgetID
	}
	-- only update the state if the interactive element is visible (it can be scrolled out of view, in which case it's not currently associated with an element)
	-- and only if we are the interactive element (in case of multiple tables, only one table is the interactive element for example)
	if childTableElement ~= nil and private.interactiveElement ~= nil and private.interactiveElement.widgetID == tableID then
		if IsType(childWidgetID, "button") then
			widgetSystem.setButtonElementState(childWidgetID, childTableElement, "keyboard", true)
		elseif IsType(childWidgetID, "checkbox") then
			widgetSystem.setCheckBoxElementState(childWidgetID, childTableElement, "keyboard", true)
		end
		-- for other interactive elements, there's nothing to do
	end
end

function widgetSystem.setSliderArrowState(sliderID, leftRight, state, value)
	local stateEntry = private.sliderArrowState[leftRight]
	stateEntry[state] = value

	local targetSlide = "inactive"
	if private.sliderActive then
		-- only activate the arrows, if the slider is actually active
		if stateEntry.keyboard or stateEntry.mouseClick then
			targetSlide = "click"
		elseif stateEntry.mouseOver then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	end
	if stateEntry.curSlide ~= targetSlide then
		local leftRightText = "Right"
		if leftRight == "left" then
			leftRightText = "Left"
		end
		if targetSlide == "click" then
			CallWidgetEventScripts(sliderElement, "onScrollBar"..leftRightText.."Down")
		elseif targetSlide == "highlight" then
			CallWidgetEventScripts(sliderElement, "onScrollBar"..leftRightText.."Over")
		end
		goToSlide(stateEntry.element, targetSlide)
		stateEntry.curSlide = targetSlide
	end
end

function widgetSystem.setScrollBarState(scrollBarElement, state, value, callbackElement)
	local stateEntry = scrollBarElement.sliderState
	stateEntry[state] = value

	local targetSlide = "inactive"
	-- #StefanLow --- this function doesn't need to be designed with inactive scrollbars --- it'll never be called...
	if scrollBarElement.active then
		-- only activate the bar if the scrollbar is actually visible
		if stateEntry.mouseClick then
			targetSlide = "click"
		elseif stateEntry.mouseOver then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	end

	if stateEntry.curSlide ~= targetSlide then
		if stateEntry.curSlide == "click" then
			-- if the previous state was "click" and the current isn't (aka: curSlide ~= targetSlide) -> issue a onScrollBarUp-event
			CallWidgetEventScripts(callbackElement, "onScrollBarUp")
		end
		if targetSlide == "click" then
			CallWidgetEventScripts(callbackElement, "onScrollBarDown")
		elseif targetSlide == "highlight" then
			CallWidgetEventScripts(callbackElement, "onScrollBarOver")
		end
		goToSlide(scrollBarElement.sliderElement, targetSlide)
		stateEntry.curSlide = targetSlide
	end
end

-- #StefanMed - review the last parameter --- shouldn't that be better become the first (same for setScrollBarState)
function widgetSystem.setSliderBarState(anarkElement, state, value, callbackElement)
	local stateEntry = private.sliderBarState
	stateEntry[state] = value
	
	local targetSlide = "inactive"
	-- #StefanLow --- this function doesn't need to be designed with inactive scrollbars --- it'll never be called...
	if private.sliderActive then
		-- only activate the bar, if the slider is actually active
		if stateEntry.mouseClick then
			targetSlide = "click"
		elseif stateEntry.mouseOver then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	end

	if stateEntry.curSlide ~= targetSlide then
		if stateEntry.curSlide == "click" then
			-- if the previous state was "click" and the current isn't (aka: curSlide ~= targetSlide) -> issue a onScrollBarUp-event
			CallWidgetEventScripts(callbackElement, "onScrollBarUp")
		end
		if targetSlide == "click" then
			CallWidgetEventScripts(callbackElement, "onScrollBarDown")
		elseif targetSlide == "highlight" then
			CallWidgetEventScripts(callbackElement, "onScrollBarOver")
		end
		goToSlide(anarkElement, targetSlide)
		stateEntry.curSlide = targetSlide
	end
end

function widgetSystem.setStandardButtonState(button, state, value)
	private.standardButtonState[button][state] = value
	widgetSystem.updateStandardButtonState(button)
end

function widgetSystem.setTableMousePickState(table, tableElement, state, value, row)
	if tableElement.mousePick.state[state].original == nil then
		tableElement.mousePick.state[state].original = tableElement.mousePick.state[state].state
	end

	tableElement.mousePick.state[state].state = value
	tableElement.mousePick.state[state].row = row
end

-- useRowColor indicates whether the rowcolor should be used to color all elements
function widgetSystem.setTableRowColor(tableElement, row, rowcolor, iconcolor, useRowColor)
	if not tableElement.borderEnabled then
		return -- nothing to do without borders being enabled
	end

	local realRow
	if row <= tableElement.numFixedRows then
		realRow = row
	else
		-- note: callers ensure this is only called with row > numFixedRows, if we actually do have non-fixed rows
		realRow = row - tableElement.topRow + 1 + tableElement.numFixedRows
	end

	-- set color of the table background elements
	local columns = tableElement.cell[realRow]
	for _, cell in ipairs(columns) do
		local element = getElement("middle.material", cell.element)
		SetDiffuseColor(element, rowcolor[1], rowcolor[2], rowcolor[3])
		setAttribute(element, "opacity", rowcolor[4])

		-- set button color
		if cell.button ~= nil then
			local material = getElement("background.Material753", cell.button.element)
			local r, g, b, a
			if useRowColor then
				r = rowcolor[1]
				g = rowcolor[2]
				b = rowcolor[3]
				-- #StefanMed - review --- why should the transparency for buttons change between selected and unselected rows?
				a = rowcolor[4]
			else
				if cell.button.active then
					r = cell.button.color.r
					g = cell.button.color.g
					b = cell.button.color.b
					a = cell.button.color.a
				else -- inactive button
					r = config.inactiveButtonColor.r
					g = config.inactiveButtonColor.g
					b = config.inactiveButtonColor.b
				end				
			end
			if not cell.button.active then
				-- inactive buttons have to use the unchanged alpha value
				a = config.inactiveButtonColor.a
			end 
			SetDiffuseColor(material, r, g, b)
			setAttribute(material, "opacity", a)
		end

		-- set editbox color
		if cell.editbox ~= nil then
			local material = getElement("background.Material689", cell.editbox.element)
			local r, g, b, a
			if useRowColor then
				-- #StefanMed --- investigate and maybe change highlighting behavior to a gray-scale element rather than using colors --- problem is that blending the yellow color twice will result in a brighter yellow color than the one we have for normal table cells.
				-- current solution is that in the highlighted case we simply ignore the editbox-color altogether (by hardcoding the alpha to 0)
				r = rowcolor[1]
				g = rowcolor[2]
				b = rowcolor[3]
				-- #StefanMed - review the case when setting to ~= 0 --- why should the transparency for editboxes change between selected and unselected rows?
				a = 0 --rowcolor[4] <- old value - reenable or remove
			else
				r = cell.editbox.color.r
				g = cell.editbox.color.g
				b = cell.editbox.color.b
				a = cell.editbox.color.a				
			end
			SetDiffuseColor(material, r, g, b)
			setAttribute(material, "opacity", a)
		end

		-- set color for progressElement
		if cell.progressElement ~= nil then
			local material = getElement("bar.bar.material", cell.progressElement)
			SetDiffuseColor(material, iconcolor.r, iconcolor.g, iconcolor.b)
			setAttribute(material, "opacity", iconcolor.a)
			material = getElement("bar.border.material", cell.progressElement)
			SetDiffuseColor(material, iconcolor.r, iconcolor.g, iconcolor.b)
			setAttribute(material, "opacity", iconcolor.a)
		end
	end
end

function widgetSystem.toggleMouseOverText(value)
	if (private.mouseOverText ~= nil) then
		widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
	end
	if private.enableMouseOverText ~= (value ~= 0) then
		private.enableMouseOverText = value ~= 0
	end
end

function widgetSystem.initializeButtonElements()
	for count = 1, config.button.maxElements do
		local buttonElement = clone(private.master.button, "button"..count)
		table.insert(private.element.buttons, buttonElement)

		-- register for mouse interactions
		registerForEvent("onMouseClick",       buttonElement, widgetSystem.onMouseClickButton)
		registerForEvent("onMouseDblClick",    buttonElement, widgetSystem.onMouseDblClickButton)
		registerForEvent("onMouseDown",        buttonElement, widgetSystem.onMouseDownButton)
		registerForEvent("onMouseUp",          buttonElement, widgetSystem.onMouseUpButton)
		registerForEvent("onGroupedMouseOver", buttonElement, widgetSystem.onMouseOverButton)
		registerForEvent("onGroupedMouseOut",  buttonElement, widgetSystem.onMouseOutButton)
		RegisterMouseInteractions(buttonElement)
	end
end

function widgetSystem.initializeCheckBoxElements()
	for count = 1, config.checkbox.maxElements do
		local checkboxElement = clone(private.master.checkbox, "checkbox"..count)
		table.insert(private.element.checkboxes, checkboxElement)

		-- register for mouse interactions
		registerForEvent("onMouseClick",       checkboxElement, widgetSystem.onMouseClickCheckBox)
		registerForEvent("onMouseDblClick",    checkboxElement, widgetSystem.onMouseDblClickCheckBox)
		registerForEvent("onGroupedMouseOver", checkboxElement, widgetSystem.onMouseOverCheckBox)
		registerForEvent("onGroupedMouseOut",  checkboxElement, widgetSystem.onMouseOutCheckBox)
		RegisterMouseInteractions(checkboxElement)
	end
end

function widgetSystem.initializeEditBoxElements()
	for count = 1, config.editbox.maxElements do
		local editboxElement = clone(private.master.editbox, "editbox"..count)
		table.insert(private.element.editboxes, editboxElement)

		-- register for mouse interactions
		registerForEvent("onMouseClick", editboxElement, widgetSystem.onMouseClickEditBox)
		RegisterMouseInteractions(editboxElement)
	end
end

function widgetSystem.initializeFrameElements()
	local backElement = getElement("standardbuttons.back", private.widgetsystem)
	local closeElement = getElement("standardbuttons.close", private.widgetsystem)

	registerForEvent("onMouseClick",       backElement, widgetSystem.onMouseClickBackButton)
	registerForEvent("onMouseDown",        backElement, widgetSystem.onMouseDownBackButton)
	registerForEvent("onMouseUp",          backElement, widgetSystem.onMouseUpBackButton)
	registerForEvent("onGroupedMouseOver", backElement, widgetSystem.onMouseOverBackButton)
	registerForEvent("onGroupedMouseOut",  backElement, widgetSystem.onMouseOutBackButton)
	registerForEvent("onMouseClick",       closeElement, widgetSystem.onMouseClickCloseButton)
	registerForEvent("onMouseDown",        closeElement, widgetSystem.onMouseDownCloseButton)
	registerForEvent("onMouseUp",          closeElement, widgetSystem.onMouseUpCloseButton)
	registerForEvent("onGroupedMouseOver", closeElement, widgetSystem.onMouseOverCloseButton)
	registerForEvent("onGroupedMouseOut",  closeElement, widgetSystem.onMouseOutCloseButton)

	RegisterMouseInteractions(backElement)
	RegisterMouseInteractions(closeElement)
end

function widgetSystem.initializeGraphElements()
	for count = 1, config.graph.maxElements do
		local graphElement = {}
		graphElement["mainElement"] = clone(private.master.graph, "graph"..count)
		RegisterMouseInteractions(graphElement.mainElement)
		graphElement["tickElements"] = {}
		for tickCount = 1, config.graph.maxTicksPerElement do
			table.insert(graphElement["tickElements"], clone(private.master.graphTick, "graphTick"..tickCount))
		end
		graphElement["dataPointElements"] = {}
		for datapointCount = 1, config.graph.maxDataPointsPerElement do
			local dataPointElement = clone(private.master.graphDataPoint, "graphDataPoint"..datapointCount)
			table.insert(graphElement["dataPointElements"], dataPointElement)

			local marker1 = getElement("marker1", dataPointElement)
			local marker2 = getElement("marker2", dataPointElement)

			registerForEvent("onGroupedMouseOver", marker1, widgetSystem.onMouseOverGraphDataPoint)
			registerForEvent("onGroupedMouseOut",  marker1, widgetSystem.onMouseOutGraphDataPoint)
			registerForEvent("onGroupedMouseOver", marker2, widgetSystem.onMouseOverGraphDataPoint)
			registerForEvent("onGroupedMouseOut",  marker2, widgetSystem.onMouseOutGraphDataPoint)

			RegisterMouseInteractions(marker1)
			RegisterMouseInteractions(marker2)
		end
		graphElement["iconElements"] = {}
		for iconCount = 1, config.graph.maxIconsPerElement do
			local iconElement = clone(private.master.graphIcon, "graphIcon"..iconCount)
			table.insert(graphElement["iconElements"], iconElement)

			registerForEvent("onGroupedMouseOver", iconElement, widgetSystem.onMouseOverGraphIcon)
			registerForEvent("onGroupedMouseOut",  iconElement, widgetSystem.onMouseOutGraphIcon)

			RegisterMouseInteractions(iconElement)
		end
		table.insert(private.element.graphs, graphElement)
	end
end

function widgetSystem.initializeIconElements()
	for count = 1, config.icon.maxElements do
		table.insert(private.element.icons, clone(private.master.icon, "icon"..count))
	end
end

function widgetSystem.initializeMiniWidgetSystemElements()
	for tableindex = 1, config.miniWidgetsystem.maxTables do
		private.element.miniWidgetSystem.table[tableindex] = {}
		local tableElement = private.element.miniWidgetSystem.table[tableindex]
		tableElement.header = clone(private.master.miniWidgetSystem.table.header, "table"..tableindex.."header")
		tableElement.headerText = getElement("Text", tableElement.header)
		tableElement.scrollBar = {
			["sliderState"] = {
				["mouseClick"] = false,
				["mouseOver"]  = false,
				["curSlide"]   = "inactive"
			}
		}
		tableElement.scrollBar.element = clone(private.master.miniWidgetSystem.table.scrollBar, "table"..tableindex.."scrollbar")
		tableElement.scrollBar.sliderElement = getElement("slider", tableElement.scrollBar.element)
		tableElement.mousePick = {
			["state"] = {
				["mouseOver"]  = {
					["state"] = false,
					-- ["original"] = nil,
					-- ["row"] = nil
				}
			}
		}
		tableElement.mousePick.element = clone(private.master.miniWidgetSystem.table.mousePick, "table"..tableindex.."mousepick")
		tableElement.cell = {}

		-- initialize for mouse interactions
		local backgroundSliderBar = getElement("background", tableElement.scrollBar.element)
		local sliderBar = tableElement.scrollBar.sliderElement
		local mousePick = tableElement.mousePick.element
		registerForEvent("onMouseClick",       backgroundSliderBar, widgetSystem.onMouseClickPageScroll)
		registerForEvent("onMouseDblClick",    backgroundSliderBar, widgetSystem.onMouseClickPageScroll)
		registerForEvent("onMouseDown",        sliderBar,           widgetSystem.onMouseStartScrollBarDrag)
		registerForEvent("onMouseUp",          sliderBar,           widgetSystem.onMouseStopScrollBarDrag)
		registerForEvent("onGroupedMouseOver", sliderBar,           widgetSystem.onMouseOverTableScrollBar)
		registerForEvent("onGroupedMouseOut",  sliderBar,           widgetSystem.onMouseOutTableScrollBar)
		registerForEvent("onGroupedMouseOver", mousePick,           widgetSystem.onMouseOverTable)
		registerForEvent("onGroupedMouseOut",  mousePick,           widgetSystem.onMouseOutTable)
		RegisterMouseInteractions(backgroundSliderBar)
		-- note the slider must not only be registered for mouse interactions for draggin/dropping support, but rather also so it obstructs clicks on the backgroundSliderBar behind the slider
		RegisterMouseInteractions(sliderBar)
		RegisterMouseInteractions(mousePick)
	end

	for rowIndex = 1, config.miniWidgetsystem.maxRows do
		private.element.miniWidgetSystem.tableRows[rowIndex] = {}
		for colIndex = 1, config.tableRows.maxCols do 
			local cellelement = clone(private.master.miniWidgetSystem.table.cell, "row"..rowIndex.."col"..colIndex)
			private.element.miniWidgetSystem.tableRows[rowIndex][colIndex] = {
				["element"] = cellelement
			}
			registerForEvent("onMouseClick",       cellelement, widgetSystem.onMouseClickTableCell)
			registerForEvent("onMouseDblClick",    cellelement, widgetSystem.onMouseClickTableCell)
			registerForEvent("onGroupedMouseOver", cellelement, widgetSystem.onMouseOverTableCell)
			registerForEvent("onGroupedMouseOut",  cellelement, widgetSystem.onMouseOutTableCell)
			RegisterMouseInteractions(cellelement)
		end
	end
end

function widgetSystem.initializeProgressElements()
	for count = 1, config.progressElement.maxElements do
		table.insert(private.element.progressElements, clone(private.master.progressElement, "progressElement"..count))
	end
end

function widgetSystem.initializeShapeElements()
	for count = 1, config.shapes.rectangle.maxElements do
		table.insert(private.element.shapes.rectangleElements, {count, clone(private.master.shapeRectangle, "shapeRectangle"..count)})
	end

	for count = 1, config.shapes.circle.maxElements do
		table.insert(private.element.shapes.circleElements, {count, clone(private.master.shapeCircle, "shapeCircle"..count)})
	end

	for count = 1, config.shapes.triangle.maxElements do
		table.insert(private.element.shapes.triangleElements, {count, clone(private.master.shapeTriangle, "shapeTriangle"..count)})
	end
end

function widgetSystem.initializeTimerElements()
	for count = 1, config.timer.maxElements do
		table.insert(private.element.timerElements, clone(private.master.timer, "timer"..count))
	end
end

function widgetSystem.invertColor(r, g, b)
	return 255 - r, 255 - g, 255 - b
end

function widgetSystem.moveDown(tableID, tableElement, newCurRow)
	-- #StefanMed - this should be stored in the tableelement rather than recalculating every time
	-- get the last selectable row
	local lastSelectableRow = tableElement.numRows
	while tableElement.unselectableRows[lastSelectableRow] ~= nil do
		lastSelectableRow = lastSelectableRow - 1
	end
	-- note: lastSelectableRow will be 0 here, if there are no selectable rows at all

	if (not tableElement.wrapAround) and (tableElement.curRow == lastSelectableRow) and (tableElement.bottomRow == tableElement.numRows) then
		return -- table should not wrap around and we are already at last element and the bottom part of the table is displayed
	end

	-- find the first selectable row after the given new cur row or the current row (can become numRows + 1, if no rows past curRow are selectable)
	local curRow = newCurRow
	if curRow == nil then
		curRow = tableElement.curRow + 1
	end
	while tableElement.unselectableRows[curRow] ~= nil do
		curRow = curRow + 1
	end

	-- reset curRow to last selectable row (in case we were either given a cur row past the last selectable row or we were already at the last selectable row, in which case curRow would now point to numRows + 1)
	if curRow > tableElement.numRows then
		-- only wrap around the table, if newCurRow is not specified (otherwise we'd end up calling moveUp() again resulting in no wrapping around)
		-- also no wrapping around yet, if we do not display the bottom row yet (cause otherwise we could generate valid tables which never display their (unselectable) bottom row)
		if tableElement.wrapAround and (tableElement.bottomRow == tableElement.numRows) and (newCurRow == nil) then
			-- wrapping around by moving up to the top row
			widgetSystem.moveUp(tableID, tableElement, 1)
			return
		end

		curRow = lastSelectableRow
	end

	-- calculate how many rows we have to shift
	local shiftRows = 0
	if widgetSystem.hasNonFixedRows(tableElement) then
		-- shifting rows is only required, if we have regular rows
		if (tableElement.bottomRow ~= tableElement.numRows) or (tableElement.curRow < tableElement.topRow) then
			-- shifting is only required, if we are not showing the bottom row already and the current row is visible (aka: current row not scrolled-out)

			-- determine the new bottomRow which is either the next selectable row after the one we move to (so that the user can see the next row
			-- which will be selected when further scrolling down and the entire content in-between the nextRow and newBottomRow is displayed)
			-- or numRows, if we are at the last selectable row
			local newBottomRow
			if curRow == lastSelectableRow then
				newBottomRow = tableElement.numRows
			else
				newBottomRow = curRow + 1
				while tableElement.unselectableRows[newBottomRow] ~= nil do
					newBottomRow = newBottomRow + 1
				end
				-- note: we know for sure that there is a following selectable row after curRow, since otherwise curRow would equal lastSelectableRow --- hence no further check required here
			end

			if newBottomRow > tableElement.bottomRow then
				-- make sure we shift the table so much that we display the correct bottomRow
				shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, newBottomRow)
			elseif tableElement.curRow < tableElement.topRow then
				-- we do not display the current row atm (aka: table scrolled out) - hence shift the table, so that the previous row (aka curRow) is the new topRow
				-- we use the curRow here rather than the new curRow (aka: nextRow) since we want to always display a row before the current selected one so the player can see the row which
				-- is going to be selected, if he moves up again afterwards
				shiftRows = tableElement.curRow - tableElement.topRow
			end
		end
	end

	widgetSystem.updateTable(tableID, tableElement, shiftRows, curRow)

	if tableElement.curRow == lastSelectableRow and tableElement.bottomRow ~= tableElement.numRows then
		DebugError("Widget system error. Invalid table setup. We've got a table which doesn't specify a selectable row we could scroll to in order to display the bottom row.")
	end
end

function widgetSystem.moveLeft(tableID, tableElement)
	if tableElement.interactiveChild == nil then
		return -- no interactive entry atm, nothing to do
	end

	local startcolumn = math.max(1, tableElement.interactiveChild.col - 1)
	widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.interactiveChild.row, startcolumn, tableElement.interactiveChild.col, "left")
end

function widgetSystem.moveRight(tableID, tableElement)
	if tableElement.interactiveChild == nil then
		return -- no interactive entry atm, nothing to do
	end

	widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.interactiveChild.row, tableElement.interactiveChild.col + 1, tableElement.interactiveChild.col, "right")
end

function widgetSystem.moveUp(tableID, tableElement, newCurRow)
	-- #coreUIMed - add a check for curRow == firstSelectableRow || firstSelectableFixedRow so to speed up the handling (O(n) -> O(1))
	if (not tableElement.wrapAround) and (tableElement.curRow <= 1) then
		return -- already at first element
	end

	-- find the first selectable row before the current row (or the one which we got passed)
	local curRow = newCurRow
	if curRow == nil then
		curRow = tableElement.curRow - 1
	end
	while tableElement.unselectableRows[curRow] ~= nil do
		curRow = curRow - 1
	end

	-- ensure we don't pass the first row (can happen, when calling moveUp with curRow being set to 1)
	if curRow < 1 then
		-- only wrap around the table, if newCurRow is not specified (otherwise we'd end up calling moveUp() again resulting in no wrapping around)
		-- also no wrapping around yet, if we do not display the top row yet (cause otherwise we could generate valid tables which never display their (unselectable) top row)
		if tableElement.wrapAround and (tableElement.topRow == tableElement.numFixedRows + 1) and (newCurRow == nil) then
			-- wrapping around by moving down to the bottom row
			widgetSystem.moveDown(tableID, tableElement, tableElement.numRows)
			return
		end

		-- get the first selectable row
		-- #coreUIMed - speed up by storing the firstSelectableRow upon table creation, so it doesn't have to be recalculated always...
		curRow = 1
		while tableElement.unselectableRows[curRow] ~= nil do
			curRow = curRow + 1
		end
	end

	-- we must calculate the new top row now - we need to move either to the top row (if the curRow is the first selectable normal row)
	-- or to the selectable row before the new selected row (so that the user sees the row before the current selected one -- aka: when going up one more step)
	local newTopRow = curRow - 1
	while tableElement.unselectableRows[newTopRow] ~= nil do
		newTopRow = newTopRow - 1
	end
	newTopRow = math.max(newTopRow, tableElement.numFixedRows + 1) -- ensure we don't pass the first (normal) row (can happen, when calling moveUp with curRow being set to the second selectable row)

	local shiftRows = 0
	if widgetSystem.hasNonFixedRows(tableElement) then
		-- shifting is only required, if we have regular rows
		if newTopRow > tableElement.bottomRow then
			-- we moved upwards a row without that one being on screen atm, shift the entire table so that the current selected row is the new bottom row
			shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.curRow)
		elseif newTopRow < tableElement.topRow then
			-- the new row is currently not displayed, so shift the entire table to at least the new row
			shiftRows = newTopRow - tableElement.topRow
		end
	end

	widgetSystem.updateTable(tableID, tableElement, shiftRows, curRow)
end

function widgetSystem.pageDown(tableID, tableElement)
	if not widgetSystem.hasNonFixedRows(tableElement) then
		return -- table only contains fixed-rows - nothing to page-down to
	end

	if tableElement.curRow > tableElement.bottomRow then
		-- current selected row is not visible - hence simply select the current bottomRow without shifting the table
		widgetSystem.updateTable(tableID, tableElement, 0, tableElement.bottomRow)
		return
	end

	-- calculate the last row which we can move to
	local lastSelectableRow = tableElement.numRows
	while tableElement.unselectableRows[lastSelectableRow] ~= nil do
		lastSelectableRow = lastSelectableRow - 1
	end

	if tableElement.curRow == lastSelectableRow and tableElement.bottomRow == tableElement.numRows then
		return -- already at last element
	end

	-- calculate the last selectable row on the current page
	local lastSelectableCurRow = tableElement.bottomRow
	while tableElement.unselectableRows[lastSelectableCurRow] ~= nil do
		lastSelectableCurRow = lastSelectableCurRow - 1
	end

	local shiftRows = 0
	-- pressing pageDown for the first time just moves the selection to the bottom row (really the bottom row --- in contrast to one selectable row above the bottom row as in moveDown)
	if tableElement.curRow == lastSelectableCurRow then
		-- we are at the bottom-row --- so scroll the entire table by one page and select the bottom row again
		shiftRows = widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, tableElement.bottomRow+1)
	end

	-- first we shift the table (if required)
	widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.topRow + shiftRows)

	-- after the table was shifted we know the bottom-row and select the bottom most one we can select
	for row = tableElement.bottomRow, tableElement.topRow, -1 do
		if tableElement.unselectableRows[row] == nil then
			-- update the table selection to the bottomRow
			widgetSystem.updateTable(tableID, tableElement, 0, row)
			return
		end
	end

	DebugError("Widget system error. PageDown failed to calculate a selectable row. PageDown will be ignored.")
end

function widgetSystem.pageUp(tableID, tableElement)
	-- #StefanLow - investigate if the check could be combined with the numFixedRows-check below
	if not widgetSystem.hasNonFixedRows(tableElement) then
		return -- table only contains fixed-rows - nothing to page-up to
	end

	if tableElement.curRow < tableElement.topRow then
		-- current selected row is not visible - hence simply select the current topRow without shifting the table
		widgetSystem.updateTable(tableID, tableElement, 0, tableElement.topRow)
		return
	end

	if tableElement.curRow <= tableElement.numFixedRows then
		return -- already at first element
	end

	local curSelectableTopRow = tableElement.topRow
	while tableElement.unselectableRows[curSelectableTopRow] ~= nil do
		curSelectableTopRow = curSelectableTopRow + 1
	end

	local shiftRows = 0
	-- pressing pageUp for the first time just moves the selection to the top row (really the top row and not the first selectable row below the topRow like moveUp would do)
	if tableElement.curRow == curSelectableTopRow then
		-- we are at the top-row --- so scroll the entire table by one page and select the top row again
		shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.topRow - 1)
	end

	-- first we shift the table (if required)
	widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.topRow + shiftRows)

	-- after the table was shifted we know the top-row and select the upper most one we can select
	for row = tableElement.topRow, tableElement.bottomRow do
		if tableElement.unselectableRows[row] == nil then
			-- update the table selection to the topRow
			widgetSystem.updateTable(tableID, tableElement, 0, row)
			return
		end
	end

	DebugError("Widget system error. PageUp failed to calculate a selectable row. PageUp will be ignored.")
end

function widgetSystem.raiseHideEvent(type)
	CallWidgetEventScripts(private.frame, "onHide", type)
	private.onHideRisen = true
end

-- removes the given element from the association list (element being the associated Anark element)
function widgetSystem.removeFromAssociationList(element)
	for widgetID, entry in pairs(private.associationList) do
		if entry.element == element then
			private.associationList[widgetID] = nil
			return -- done (we've found and removed the element)
		end
	end
end

function widgetSystem.removeHighlightTableRow(tableID, tableElement)
	-- note: caller ensures that this is only called, if we have non-fixed rows

	local row = tableElement.highlightedRow
	tableElement.highlightedRow = nil

	if row == nil then
		return -- row not displayed, no highlight to remove
	end

	if row < tableElement.topRow or row > tableElement.bottomRow then
		return -- row not displayed, no highlight to remove
	end

	widgetSystem.setTableRowColor(tableElement, row, { GetTableRowColor(tableID, row) }, config.table.unselectedRowColor, false)
end

function widgetSystem.scrollDown(tableID, tableElement, step)
	-- note: explicit check for not hasNonFixedRows() not required, since this is implicitly checked by bottomRow == numRows
	-- (aka: we are showing the last row (which is the last fixed row) otherwise the table set-up would have been rejected)
	if tableElement.bottomRow == tableElement.numRows then
		return -- bottom row already shown
	end

	-- prevent scrolling down too much
	if tableElement.bottomRow + step > tableElement.numRows then
		step = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.numRows)
	end

	-- scroll the table down without changing the selected row
	widgetSystem.updateTable(tableID, tableElement, step, tableElement.curRow)
end

function widgetSystem.scrollLeft(sliderElement, steps)
	if sliderElement.minSelectableValue == sliderElement.curValue then
		return -- already at left corner
	end

	local stepValue = steps * sliderElement.granularity

	if sliderElement.curValue - stepValue < sliderElement.minSelectableValue then
		-- going the whole step would mean preceding the minimum selectable value
		-- hence just go to the minimal valid value (without breaking the specified granularity)
		stepValue = math.abs(sliderElement.minSelectableValue - sliderElement.curValue)
		stepValue = stepValue - (stepValue % sliderElement.granularity)
	end
	sliderElement.curValue = sliderElement.curValue - stepValue

	widgetSystem.updateSlider(sliderElement)
end

function widgetSystem.scrollPageDown(tableID, tableElement)
	-- note: explicit check for not hasNonFixedRows() not required, since this is implicitly checked by bottomRow == numRows
	-- (aka: we are showing the last row (which is the last fixed row) otherwise the table set-up would have been rejected)
	if tableElement.bottomRow == tableElement.numRows then
		return -- already at the bottom of the table
	end

	-- scroll the entire table by one page but do not alter the current selected row
	local shiftRows = widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, tableElement.bottomRow+1)

	-- scroll the table without altering the selected row
	widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.curRow)
end

function widgetSystem.scrollPageLeft(sliderElement)
	widgetSystem.scrollLeft(sliderElement, sliderElement.scrollBar.pageStep)
end

function widgetSystem.scrollPageRight(sliderElement)
	widgetSystem.scrollRight(sliderElement, sliderElement.scrollBar.pageStep)
end

function widgetSystem.scrollPageUp(tableID, tableElement)
	-- caller ensures that topRow is never nil
	if tableElement.topRow == (tableElement.numFixedRows + 1) then
		return -- already at top of the table
	end

	-- scroll the entire table by one page but do not alter the current selected row
	local shiftRows = widgetSystem.calculateRowsToMoveByBottomRow(tableID, tableElement, tableElement.topRow - 1)

	-- scroll the table without altering the selected row
	widgetSystem.updateTable(tableID, tableElement, shiftRows, tableElement.curRow)
end

function widgetSystem.scrollRight(sliderElement, steps)
	if sliderElement.maxSelectableValue == sliderElement.curValue then
		return -- already at right corner
	end

	local stepValue = steps * sliderElement.granularity

	if sliderElement.curValue + stepValue > sliderElement.maxSelectableValue then
		-- going the whole step would mean exceeding the maximum selectable value
		-- hence just go to the maximum valid value (without breaking the specified granularity)
		stepValue = sliderElement.maxSelectableValue - sliderElement.curValue
		stepValue = stepValue - (stepValue % sliderElement.granularity)
	end
	sliderElement.curValue = sliderElement.curValue + stepValue

	widgetSystem.updateSlider(sliderElement)
end

function widgetSystem.scrollUp(tableID, tableElement, step)
	if not widgetSystem.hasNonFixedRows(tableElement) or tableElement.topRow <= (tableElement.numFixedRows + 1) then
		return -- top row already shown (or no non-fixed rows at all)
	end

	-- prevent scrolling up too much
	if tableElement.topRow - step <= tableElement.numFixedRows then
		step = math.abs(widgetSystem.calculateRowsToMoveByTopRow(tableID, tableElement, 1))
	end

	-- scroll the table up without changing the selected row
	widgetSystem.updateTable(tableID, tableElement, -step, tableElement.curRow)
end

-- column | (nil, errorcode, errormessage) = SelectColumn(tableID, column)
-- the table is not scrolled, if the row is not visible atm
function widgetSystem.selectColumn(tableID, column)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	if column <= 0 then
		return nil, 2, "column is out of bounds (< 1)"
	end

	if column > tableElement.numCols then
		return nil, 3, "column is out of bounds (exceeds number of columns: "..tableElement.numCols..")"
	end

	if GetTableColumnSpan(tableID, tableElement.curRow, column) == 0 then
		return nil, 4, "column cannot be selected since it is a spanned column"
	end

	local childWidgetID = GetCellContent(tableID, tableElement.curRow, column)

	if not IsSelectable(childWidgetID) then
		return nil, 5, "specified column contains a non-selectable element and hence cannot be selected"
	end

	widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.curRow, column, nil, "right")
	return column
end

-- determines the interactive element at the given row/col moving towards the given direction and selects it
-- tableID      - the widget ID of the table in which to select the interactive element
-- tableElement - the table representation (entry in private.element)
-- row          - the row in which to select the interactive element
-- col          - the column where to start looking for the interactive element
-- alternateCol - if we failed to determine an interactive element starting from col, select the interactive element at this column
-- direction    - the direction into which to iterate the interactive elements in the row ("left", "right", "rightLeft")
function widgetSystem.selectInteractiveElement(tableID, tableElement, row, col, alternateCol, direction)
	-- #StefanMed - optimize --- should be stored here in Lua upon table set-up
	local step = 0
	local enableDirectionSwap = false
	local dir = 1
	if direction == "left" then
		dir = -1
	elseif direction == "rightLeft" then
		enableDirectionSwap = true
	-- otherwise direction is "right"
	end

	local oldRow
	local oldCol
	local oldElement
	local oldChildWidgetID
	if tableElement.interactiveChild then
		oldRow           = tableElement.interactiveChild.row
		oldCol           = tableElement.interactiveChild.col
		oldElement       = tableElement.interactiveChild.element
		oldChildWidgetID = tableElement.interactiveChild.widgetID
	end

	local childWidgetID
	local curCol
	-- find the selectable column (if any) using the col|direction setting
	repeat
		-- first get the next column
		curCol = widgetSystem.getNextColumn(col, 1, tableElement.numCols, step, dir)
		if curCol == nil then
			-- no further columns in that direction, check if we are allowed to swap directions
			if enableDirectionSwap then
				dir = dir * -1
				enableDirectionSwap = false -- stop swapping directions, since in the other one there's no further suitable column to check
				curCol = widgetSystem.getNextColumn(col, 1, tableElement.numCols, step, dir)
			end
		end

		if curCol ~= nil then
			childWidgetID = widgetSystem.getSelectableCellElement(tableID, row, curCol)
			if childWidgetID ~= nil then
				break -- we found the next selectable column
			end

			-- it's a column but it's not selectable, swap directions, or increase the step
			if not enableDirectionSwap then
				step = step + 1
			elseif dir == -1 then
				dir = 1 -- swap directions from left to right and increase step
				step = step + 1
			else -- dir == 1 and enableDirectionSwap is true
				dir = -1 -- swap directions from right to left
			end
		end
	until curCol == nil

	if curCol == nil then
		-- we didn't find any suitable column, use the alternate column
		curCol = alternateCol
		if curCol ~= nil then
			childWidgetID = widgetSystem.getSelectableCellElement(tableID, row, curCol)
		end
	end

	-- unset the previous element, if necessary (aka: if it's visible)
	-- note: There's no need to unset the interactive element, if it was reset to a different AnarkElement (aka: childTableElement changed)
	-- since that is already handled by hiding the button (implicit resetting of element states like button slides)
	if oldElement ~= nil and oldChildWidgetID ~= childWidgetID then
		local associationListEntry = private.associationList[oldChildWidgetID]
		local childTableElement
		if associationListEntry ~= nil then
			childTableElement = associationListEntry.element
		end
		-- can be nil, when scrolled out of view
		if childTableElement ~= nil then
			-- unset the previous element, if the element changed
			widgetSystem.unsetInteractiveChildElement(oldChildWidgetID, childTableElement)
		end
	end

	-- set the new element, if necessary (aka: if we have a new element and it's visible)
	if childWidgetID ~= nil then
		-- associationListEntry can be nil, if the currently selected row is out of view (i.e. scrolled out with mouse-scrolling)
		local associationListEntry = private.associationList[childWidgetID]
		local childTableElement
		if associationListEntry ~= nil then
			childTableElement = associationListEntry.element
		end
		-- set the new element, if the element changed
		-- Note: This must be done regardless of whether the row/col changed, since selectInteractiveElement is also used to update the interactive element entry
		-- even if it just redrew a table section (in which case row/col/widgetID are the same, but the AnarkElement representing the widget element likely changed)
		-- this must then also update the interactive entry (namely the childTableElement.element-data) to the new one
		-- If we would not, this would cause problems whenever we use childTableElement.element to determine the anarkElement for a button for example - this caused XR-40.
		widgetSystem.setInteractiveChildElement(tableID, tableElement, row, curCol, childWidgetID, childTableElement)
	end

	-- trigger column changed callbacks and reset interactive entry (do this, after we updated our own states - aka: after we called (set/unset)InteractiveElement(),
	-- so that any potential changes the callback performs will be done with us having set the states correctly)
	if childWidgetID ~= nil then
		-- we found a cellelement which will become the new selected element
		if oldRow == nil or oldRow ~= row or oldCol ~= curCol then
			CallWidgetEventScripts(tableID, "onColumnChanged", curCol)
		end
	else
		-- couldn't find any slectable interactive element
		if oldRow ~= nil and oldRow ~= row then
			CallWidgetEventScripts(tableID, "onColumnChanged", nil)
		end

		-- if we ended up here, we didn't find a new (or existing column --- can happen upon row-changes - unset the interactive entry)
		tableElement.interactiveChild = nil
	end
end

-- row | (nil, errorcode, errormessage) = SelectRow(tableID, row)
-- the table is not scrolled, if the row is not visible atm
function widgetSystem.selectRow(tableID, row)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	-- try to convert row parameter to number (in case it isn't already)
	local convertedRow = tonumber(row)
	if convertedRow == nil then
		return nil, 2, "row '"..tostring(row).."' is not a number"
	end

	if convertedRow <= 0 then
		return nil, 3, "row is out of bounds (< 1)"
	end

	if convertedRow > tableElement.numRows then
		return nil, 4, "row is out of bounds (exceeds number of rows: "..tableElement.numRows..")"
	end

	if tableElement.unselectableRows[convertedRow] ~= nil then
		return nil, 5, "specified row "..convertedRow.." is unselectable"
	end

	widgetSystem.selectRowInternal(tableID, tableElement, convertedRow)
	return convertedRow
end

function widgetSystem.selectRowInternal(tableID, tableElement, row)
	-- enforce highlight updates all the time, so that even if the table is only shifted, the proper row is highlighted
	-- remove highlight from previous row and highlight new one (but only if current row can be selected)

	local curCol = 1
	local direction = "right"
	if tableElement.interactiveChild ~= nil then
		curCol = tableElement.interactiveChild.col
		direction = "rightLeft"
	end

	if tableElement.unselectableRows[row] == nil then
		if tableElement.curRow ~= row then
			if tableElement.curRow > tableElement.numFixedRows and row <= tableElement.numFixedRows then
				-- switching from non-fixed-region to fixed region
				tableElement.interactiveRegion = "fixed"
				tableElement.normalSelectedRow = tableElement.curRow
			elseif tableElement.curRow <= tableElement.numFixedRows and row > tableElement.numFixedRows then
				-- switching from fixed region to non-fixed-region
				tableElement.interactiveRegion = "normal"
				tableElement.normalSelectedRow = nil
			end
			tableElement.curRow = row
			CallWidgetEventScripts(tableID, "onRowChanged", row) 
		end
	end

	local isNormalRegion = (row > tableElement.numFixedRows)

	if isNormalRegion then
		widgetSystem.removeHighlightTableRow(tableID, tableElement)
	end

	-- no highlighting of new row, curRow is 0 - check is required here for interactive tables which are fully displayed but do not have any selectable row (valid case, but nothing to highlight)
	if tableElement.curRow == 0 then
		return
	end

	-- only highlight rows in the non-fixed area --- if only fixed rows are used, there's nothing to highlight
	if isNormalRegion then
		widgetSystem.highlightTableRow(tableElement, tableElement.curRow)
	end

	-- check the new row for an interactive element and select that
	widgetSystem.selectInteractiveElement(tableID, tableElement, tableElement.curRow, curCol, nil, direction)
end

function widgetSystem.setTimer(timerElement, timeout)
	local curTime = GetCurTime()
	local timeleft = timeout - curTime
	timeleft = math.max(timeleft, 0) -- crop at 0

	local red, green, blue = 255, 255, 255
	if timeleft < config.timerRed then
		green, blue = 0, 0	-- set to red
	end

	local timeElement = getElement("time", timerElement)

	local hoursLeft = math.floor(timeleft / 3600)
	local minutesLeft = math.floor((timeleft % 3600) / 60)
	local secondsLeft = math.floor(timeleft % 60)

	local timeelement1 = 0
	local timeelement2 = 0
	if hoursLeft > 0 then
		timeelement1 = hoursLeft
		timeelement2 = minutesLeft
	else
		timeelement1 = minutesLeft
		timeelement2 = secondsLeft
	end

	-- convert xx:y to xx:0y
	if timeelement2 < 10 then
		timeelement2 = "0"..timeelement2
	end

	setAttribute(timeElement, "textcolor.r", red)
	setAttribute(timeElement, "textcolor.g", green)
	setAttribute(timeElement, "textcolor.b", blue)
	-- no need to set opacity here - it's always 100%
	setAttribute(timeElement, "textstring", timeelement1..":"..timeelement2)
end

-- row | (nil, errorcode, errormessage) = widgetSystem.setTopRow(tableID, row)
function widgetSystem.setTopRow(tableID, row)
	local tableentry = private.associationList[tableID]
	if tableentry == nil then
		return nil, 1, "invalid table element"
	end
	local tableElement = tableentry.element

	if row <= 0 then
		return nil, 2, "row is out of bounds (< 1)"
	end

	if row > tableElement.numRows then
		return nil, 3, "row is out of bounds (exceeds number of rows: "..tableElement.numRows..")"
	end

	if row <= tableElement.numFixedRows then
		return nil, 4, "top row cannot be set to a fixed row"
	end

	if not widgetSystem.hasNonFixedRows(tableElement) then
		return nil, 5, "cannot set top row in table not containing normal (non-fixed) rows"
	end

	if row > tableElement.topRow then
		widgetSystem.scrollDown(tableID, tableElement, row - tableElement.topRow)
	elseif row < tableElement.topRow then
		widgetSystem.scrollUp(tableID, tableElement, tableElement.topRow - row)
	end
	-- row == tableentry.topRow - nothing to do

	return tableElement.topRow
end

-- isSelected = indicates whether the button is the current selected one
-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpButton(buttonID, buttonElement, isSelected, parentx, parenty, parentwidth, parentheight)
	buttonElement.active = IsButtonActive(buttonID)
	buttonElement.buttonState = {
		["mouseClick"]       = false,
		["keyboard"]         = isSelected,
		["keyboardPress"]    = false,
		["mouseOver"]        = false,
		["sendInitialState"] = buttonElement.active -- send initial states only for active buttons
	}

	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(buttonID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	local showHotkey, hotkeyIconID, hotkeyOffsetX, hotkeyOffsetY = GetButtonHotkeyDetails(buttonID)
	-- zero nil-values, so we do not have to check for nil in following calculations
	hotkeyOffsetX = hotkeyOffsetX or 0
	hotkeyOffsetY = hotkeyOffsetY or 0

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in Button::SetWidth/SetHeight
	local minSize = config.button.minButtonSize
	if showHotkey then
		minSize = minSize + config.button.hotkeyIconSize
	end
	if height < minSize or width < minSize then
		DebugError("Widget system error. Dimensions for button are too small. Button elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this button is "..tostring(minSize).." px")
		-- still display the garbled button so we can see which button is set-up incorrectly
	end

	-- position button
	local x, y = GetOffset(buttonID)
	local offsetx = x + parentx + width/2
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(buttonElement.element, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	-- scale button
	for _, elementName in ipairs(config.button.scaleElements) do
		widgetSystem.setElementScale(getElement(elementName, buttonElement.element), width / 100, height / 100)
	end

	-- position border elements
	-- the button (see call above) is already positioned pixel-exact - that means that the following elements must all be positioned >on< non-subpixel-positions (hence no checking at all)
	widgetSystem.setElementPositionUnchecked(getElement("left",  buttonElement.element), -(width/2 - config.texturesizes.button.borderSize/2), (height-2*config.texturesizes.button.borderSize)/2)
	widgetSystem.setElementPositionUnchecked(getElement("right", buttonElement.element), width/2 - config.texturesizes.button.borderSize/2, (height-2*config.texturesizes.button.borderSize)/2, (config.texturesizes.button.borderSize % 2 ~= 0), (height % 2 ~= 0))
	widgetSystem.setElementPositionUnchecked(getElement("upper", buttonElement.element), -width/2, height/2 - config.texturesizes.button.borderSize/2, (width % 2 ~= 0), (config.texturesizes.button.borderSize % 2 ~= 0))
	widgetSystem.setElementPositionUnchecked(getElement("lower", buttonElement.element), -width/2, -(height/2 - config.texturesizes.button.borderSize/2), (width % 2 ~= 0), (config.texturesizes.button.borderSize % 2 ~= 0))

	-- scale border elements
	widgetSystem.setElementScale(getElement("left", buttonElement.element), nil, (height-2*config.texturesizes.button.borderSize) / 100)
	widgetSystem.setElementScale(getElement("right", buttonElement.element), nil, (height-2*config.texturesizes.button.borderSize) / 100)
	widgetSystem.setElementScale(getElement("upper", buttonElement.element), width / 100)
	widgetSystem.setElementScale(getElement("lower", buttonElement.element), width / 100)

	-- u/v tiling for unselectable
	setAttribute(getElement("unselectable.Material515.unselectable", buttonElement.element), "scaleu", config.button.unselectableDefaultTiling*width/100)
	setAttribute(getElement("unselectable.Material515.unselectable", buttonElement.element), "scalev", config.button.unselectableDefaultTiling*height/100)

	if not buttonElement.active then-- inactive button
		local material = getElement("background.Material753", buttonElement.element)
		SetDiffuseColor(material, config.inactiveButtonColor.r, config.inactiveButtonColor.g, config.inactiveButtonColor.b)
		setAttribute(material, "opacity", config.inactiveButtonColor.a)
	end

	-- set the button state first, so elements are activated in-time
	widgetSystem.updateButtonState(buttonID, buttonElement)

	-- hotkey
	if showHotkey then
		buttonElement.hotkeyIconActive = true
		local hotkeyElement = getElement("Hotkey", buttonElement.element)
		goToSlide(hotkeyElement, "active")
		widgetSystem.setElementPosition(hotkeyElement, -width/2 + hotkeyOffsetX + config.button.hotkeyIconSize/2 + config.texturesizes.button.borderSize, height/2 - hotkeyOffsetY - config.button.hotkeyIconSize/2 - config.texturesizes.button.borderSize)
		SetIcon(getElement("Icon.material.Icon", hotkeyElement), hotkeyIconID, nil, nil, nil, false, config.button.hotkeyIconSize, config.button.hotkeyIconSize)
	end

	-- icon
	local iconID = GetButtonIcon(buttonID)
	if iconID ~= nil then
		buttonElement.iconActive = true
		local iconElement = getElement("Icon", buttonElement.element)
		goToSlide(iconElement, "active")
		r, g, b, a = GetButtonIconColor(buttonID)
		if not buttonElement.active then
			r, g, b = widgetSystem.invertColor(r, g, b)
		end
		buttonElement.iconID = iconID
		buttonElement.swapIconID = GetButtonSwapIcon(buttonID)
		buttonElement.iconColor = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a
		}
		local iconWidth, iconHeight = GetButtonIconSize(buttonID)
		if iconWidth ~= 0 and iconHeight ~= 0 then
			-- icon offsets only apply, if we do not have a full-sized icon (aka: iconWidth and/or iconHeight is != 0)
			local iconOffsetX, iconOffsetY = GetButtonIconOffset(buttonID)
			iconOffsetX = iconOffsetX - width/2 + iconWidth / 2
			iconOffsetY = - iconOffsetY + height/2 - iconHeight / 2
			widgetSystem.setElementPosition(iconElement, iconOffsetX, iconOffsetY)
		else
			iconWidth  = width  - 2*config.texturesizes.button.borderSize
			iconHeight = height - 2*config.texturesizes.button.borderSize
		end
		buttonElement.iconWidth  = iconWidth
		buttonElement.iconHeight = iconHeight
		-- set icon
		material = getElement("Icon.Icon.Material423", buttonElement.element)
		SetIcon(getElement("Icon", material), iconID, r, g, b, true, iconWidth, iconHeight)
		setAttribute(material, "opacity", a)
	end

	-- icon2
	local icon2ID = GetButtonIcon2(buttonID)
	if icon2ID ~= nil then
		buttonElement.icon2Active = true
		local iconElement = getElement("Icon2", buttonElement.element)
		goToSlide(iconElement, "active")
		r, g, b, a = GetButtonIcon2Color(buttonID)
		if not buttonElement.active then
			r, g, b = widgetSystem.invertColor(r, g, b)
		end
		buttonElement.icon2ID = icon2ID
		buttonElement.swapIcon2ID = GetButtonSwapIcon2(buttonID)
		buttonElement.icon2Color = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a
		}
		local iconWidth, iconHeight = GetButtonIcon2Size(buttonID)
		if iconWidth ~= 0 and iconHeight ~= 0 then
			-- icon offsets only apply, if we do not have a full-sized icon (aka: iconWidth and/or iconHeight is != 0)
			local iconOffsetX, iconOffsetY = GetButtonIcon2Offset(buttonID)
			iconOffsetX = iconOffsetX - width/2 + iconWidth / 2
			iconOffsetY = - iconOffsetY + height/2 - iconHeight / 2
			widgetSystem.setElementPosition(iconElement, iconOffsetX, iconOffsetY)
		else
			iconWidth  = width  - 2*config.texturesizes.button.borderSize
			iconHeight = height - 2*config.texturesizes.button.borderSize
		end
		buttonElement.icon2Width  = iconWidth
		buttonElement.icon2Height = iconHeight
		-- set icon2
		material = getElement("Icon2.Icon2.Imaterial_icon2", buttonElement.element)
		SetIcon(getElement("Icon2", material), icon2ID, r, g, b, true, iconWidth, iconHeight)
		setAttribute(material, "opacity", a)
	end

	local text = GetButtonText(buttonID)
	if text ~= "" then
		buttonElement.textActive = true
		-- button text
		local alignment = GetButtonTextAlignment(buttonID)
		-- calculate horizontal offset for proper alignment
		local textOffsetX, textOffsetY = GetButtonTextOffset(buttonID)
		if alignment == "left" then
			textOffsetX = textOffsetX - width/2 + config.texturesizes.button.borderSize
		elseif alignment == "center" then
			-- nothing to do
		else -- right
			textOffsetX = -textOffsetX + width/2 - config.texturesizes.button.borderSize
		end
		local textelement = getElement("Text", buttonElement.element)
		widgetSystem.setElementPosition(textelement, textOffsetX, textOffsetY)
		setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(alignment))
		-- text font
		local font, size = GetButtonFont(buttonID)
		setAttribute(textelement, "font", font)
		setAttribute(textelement, "size", size)
		-- text color is done in widgetSystem.updateButtonState()
	end

	widgetSystem.addToAssociationList(buttonID, buttonElement, buttonElement.element, parentx, parenty, parentwidth)
	widgetSystem.updateButton(buttonID, buttonElement)
end

-- isSelected = indicates whether the checkbox is the current selected one
-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpCheckBox(checkboxID, checkboxElement, isSelected, parentx, parenty, parentwidth, parentheight)
	checkboxElement.active = C.IsCheckBoxActive(checkboxID)
	checkboxElement.checked = C.IsCheckBoxChecked(checkboxID)
	checkboxElement.checkboxState = {
		["mouseClick"]       = false,
		["keyboard"]         = isSelected,
		["keyboardPress"]    = false,
		["mouseOver"]        = false,
		["sendInitialState"] = checkboxElement.active -- send initial states only for active buttons
	}

	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(checkboxID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in CheckBox::SetWidth/SetHeight
	local minSize = config.checkbox.minCheckBoxSize
	if height < minSize or width < minSize then
		DebugError("Widget system error. Dimensions for checkbox are too small. Checkbox elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this checkbox is "..tostring(minSize).." px")
		-- still display the garbled button so we can see which button is set-up incorrectly
	end

	-- position checkbox
	local x, y = GetOffset(checkboxID)
	local offsetx = x + parentx + width/2
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(checkboxElement.element, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	-- scale checkbox
	for _, element in ipairs(config.checkbox.scaleElements) do
		widgetSystem.setElementScale(getElement(element[1], checkboxElement.element), width / 100 * element[2], height / 100 * element[2])
	end

	-- position border elements
	-- the button (see call above) is already positioned pixel-exact - that means that the following elements must all be positioned >on< non-subpixel-positions (hence no checking at all)
	widgetSystem.setElementPositionUnchecked(getElement("left",  checkboxElement.element), -(width / 2 - config.texturesizes.checkbox.borderSize / 2), (height-2*config.texturesizes.checkbox.borderSize) / 2)
	widgetSystem.setElementPositionUnchecked(getElement("right", checkboxElement.element), width / 2 - config.texturesizes.checkbox.borderSize / 2, (height-2*config.texturesizes.checkbox.borderSize) / 2, (config.texturesizes.checkbox.borderSize % 2 ~= 0), (height % 2 ~= 0))
	widgetSystem.setElementPositionUnchecked(getElement("upper", checkboxElement.element), -width / 2, height/2 - config.texturesizes.checkbox.borderSize / 2, (width % 2 ~= 0), (config.texturesizes.checkbox.borderSize % 2 ~= 0))
	widgetSystem.setElementPositionUnchecked(getElement("lower", checkboxElement.element), -width / 2, -(height/2 - config.texturesizes.checkbox.borderSize / 2), (width % 2 ~= 0), (config.texturesizes.checkbox.borderSize % 2 ~= 0))

	-- scale border elements
	widgetSystem.setElementScale(getElement("left", checkboxElement.element), nil, (height - 2 * config.texturesizes.checkbox.borderSize) / 100)
	widgetSystem.setElementScale(getElement("right", checkboxElement.element), nil, (height - 2 * config.texturesizes.checkbox.borderSize) / 100)
	widgetSystem.setElementScale(getElement("upper", checkboxElement.element), width / 100)
	widgetSystem.setElementScale(getElement("lower", checkboxElement.element), width / 100)

	-- u/v tiling for unselectable
	setAttribute(getElement("unselectable.Material515.unselectable", checkboxElement.element), "scaleu", config.checkbox.unselectableDefaultTiling * width/100)
	setAttribute(getElement("unselectable.Material515.unselectable", checkboxElement.element), "scalev", config.checkbox.unselectableDefaultTiling * height/100)

	if not checkboxElement.active then-- inactive checkbox
		local material = getElement("background.Material753", checkboxElement.element)
		SetDiffuseColor(material, config.inactiveCheckBoxColor.r, config.inactiveCheckBoxColor.g, config.inactiveCheckBoxColor.b)
		setAttribute(material, "opacity", config.inactiveCheckBoxColor.a)
	end

	-- set the checkbox state first, so elements are activated in-time
	widgetSystem.updateCheckBoxState(checkboxID, checkboxElement)

	widgetSystem.addToAssociationList(checkboxID, checkboxElement, checkboxElement.element, parentx, parenty, parentwidth)
	widgetSystem.updateCheckBox(checkboxID, checkboxElement)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent (anchor element)
-- parentheight = height of the parent (anchor element)
function widgetSystem.setUpEditBox(editboxID, editboxElement, parentx, parenty, parentwidth, parentheight)
	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(editboxID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	local showHotkey, hotkeyIconID, hotkeyOffsetX, hotkeyOffsetY = GetEditBoxHotkeyDetails(editboxID)
	-- zero nil-values, so we do not have to check for nil in following calculations
	hotkeyOffsetX = hotkeyOffsetX or 0
	hotkeyOffsetY = hotkeyOffsetY or 0

	-- #StefanMed - this check really doesn't belong here - either perform the check during setUpTable() or refactor the width/height calculation and perform the checks in EditBox::SetWidth/SetHeight
	local minSize = config.editbox.minEditBoxSize
	if showHotkey then
		minSize = minSize + config.editbox.hotkeyIconSize
	end
	if height < minSize or width < minSize then
		DebugError("Widget system error. Dimensions for editbox are too small. Editbox elements will overlap eachother. Dimensions are: width("..tostring(width).." px) height("..tostring(height).." px) - minimum dimensions for this editbox is "..tostring(minSize).." px")
		-- still display the garbled editbox so we can see which editbox is set-up incorrectly
	end

	-- position editbox
	local x, y = GetOffset(editboxID)
	local offsetx = x + parentx
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(editboxElement.element, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	-- scale editbox
	for _, elementName in ipairs(config.editbox.scaleElements) do
		widgetSystem.setElementScale(getElement(elementName, editboxElement.element), width / 100, height / 100)
	end

	-- position border elements
	-- the editbox (see call above) is already positioned pixel-exact - that means that the following elements must all be positioned >on< non-subpixel-positions (hence no checking at all)
	widgetSystem.setElementPositionUnchecked(getElement("left",  editboxElement.element), -(width/2 - config.texturesizes.editbox.borderSize/2), 0)
	widgetSystem.setElementPositionUnchecked(getElement("right", editboxElement.element), width/2 - config.texturesizes.editbox.borderSize/2, 0, (config.texturesizes.editbox.borderSize % 2 ~= 0), (height % 2 ~= 0))
	widgetSystem.setElementPositionUnchecked(getElement("upper", editboxElement.element), 0, height/2 - config.texturesizes.editbox.borderSize/2, (width % 2 ~= 0), (config.texturesizes.editbox.borderSize % 2 ~= 0))
	widgetSystem.setElementPositionUnchecked(getElement("lower", editboxElement.element), 0, -(height/2 - config.texturesizes.editbox.borderSize/2), (width % 2 ~= 0), (config.texturesizes.editbox.borderSize % 2 ~= 0))

	-- scale border elements
	widgetSystem.setElementScale(getElement("left", editboxElement.element), (height-2*config.texturesizes.editbox.borderSize) / 100)
	widgetSystem.setElementScale(getElement("right", editboxElement.element), (height-2*config.texturesizes.editbox.borderSize) / 100)
	widgetSystem.setElementScale(getElement("upper", editboxElement.element), width / 100)
	widgetSystem.setElementScale(getElement("lower", editboxElement.element), width / 100)

	-- editbox color
	local r, g, b, a = GetEditBoxColor(editboxID)
	editboxElement.color = {
		["r"] = r,
		["g"] = g,
		["b"] = b,
		["a"] = a
	}
	local material = getElement("background.Material689", editboxElement.element)

	SetDiffuseColor(material, r, g, b)
	setAttribute(material, "opacity", a)

	-- set the editbox text color
	r, g, b, a = GetEditBoxTextColor(editboxID)
	local textelement = getElement("Text", editboxElement.element)
	setAttribute(textelement, "textcolor.r", r)
	setAttribute(textelement, "textcolor.g", g)
	setAttribute(textelement, "textcolor.b", b)
	setAttribute(textelement, "opacity", a)

	-- hotkey
	if showHotkey then
		editboxElement.hotkeyIconActive = true
		local hotkeyElement = getElement("Hotkey", editboxElement.element)
		goToSlide(hotkeyElement, "active")
		widgetSystem.setElementPosition(hotkeyElement, -width/2 + hotkeyOffsetX + config.editbox.hotkeyIconSize/2 + config.texturesizes.editbox.borderSize, height/2 - hotkeyOffsetY - config.editbox.hotkeyIconSize/2 - config.texturesizes.editbox.borderSize)
		SetIcon(getElement("Icon.material.Icon", hotkeyElement), hotkeyIconID, nil, nil, nil, false, config.editbox.hotkeyIconSize, config.editbox.hotkeyIconSize)
	end

	-- editbox text
	local alignment = GetEditBoxTextAlignment(editboxID)
	-- calculate horizontal offset for proper alignment
	local textoffset
	if alignment == "left" then
		textoffset = -width/2 + config.texturesizes.editbox.borderSize
	elseif alignment == "center" then
		textoffset = 0
	else -- right
		textoffset = width/2 - config.texturesizes.editbox.borderSize
	end
	local textelement = getElement("Text", editboxElement.element)
	widgetSystem.setElementPosition(textelement, textoffset, nil)
	setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(alignment))
	-- text font
	local font, size = GetEditBoxFont(editboxID)
	setAttribute(textelement, "font", font)
	setAttribute(textelement, "size", size)

	-- closemenuonback option
	editboxElement.closeMenuOnBack = GetEditBoxCloseMenuOption(editboxID)
	
	-- activate the editbox
	goToSlide(editboxElement.element, "active")

	widgetSystem.addToAssociationList(editboxID, editboxElement, editboxElement.element, parentx, parenty, parentwidth)
	editboxElement.text = GetEditBoxText(editboxID)
	setAttribute(getElement("Text", editboxElement.element), "textstring", editboxElement.text)
end

-- fontstringID = the widgetID of the fontstring
-- textcomponent = the text component element to be activated/deactivated
-- textelement = the text element to be set according to the fonstring
-- activeSlide   = the slidename to go to, when the text is to be activated
-- inactiveSlide = the slidename to go to, when the text is to be deactivated
-- parentx / parenty = position of the text's parent (i.e. anchor position)
-- parentwidth = width of the parent element (i.e. the anchor)
-- parentXSubpixel / parentYSubpixel = indicates, whether the parent of the text element uses subpixel-positions for x/y
-- returns
--    int - the fontstringheight
--    text - the displayed text
function widgetSystem.setUpFontString(fontstringID, textcomponent, textelement, activeSlide, inactiveSlide, parentx, parenty, parentwidth, parentXSubpixel, parentYSubpixel)
	-- get the data
	local alignment     = GetAlignment(fontstringID)
	local wordwrap      = GetWordWrap(fontstringID)
	local width, height = GetSize(fontstringID)
	local x, y          = GetOffset(fontstringID)
	local offsety       = parenty - y

	-- propagate parent width
	SetWidth(fontstringID, (width ~= 0) and math.min(width, parentwidth - x) or (parentwidth - x))

	-- calculate horizontal offset for proper alignment
	local offsetx
	if alignment == "left" then
		offsetx = parentx + x
	elseif alignment == "center" then
		offsetx = parentwidth / 2 + parentx + x / 2
		if offsetx % 1 ~= 0 then
			-- parentwidth or x can be odd - when dividing by 2 (and hence finding the center position)
			-- we must make sure that this doesn't end on a subpixel/halfpixel
			offsetx = offsetx - 0.5
		end
	else -- right
		offsetx = parentwidth + parentx - x
	end

	-- set the element's attributes
	widgetSystem.setElementPosition(textelement, offsetx, offsety, parentXSubpixel, parentYSubpixel)
	setAttribute(textelement, "horzalign", widgetSystem.convertAlignment(alignment))
	setAttribute(textelement, "wordwrap", wordwrap)
	
	widgetSystem.addToAssociationList(fontstringID, textelement, textcomponent, parentx, parenty, parentwidth - x, textcomponent, activeSlide, inactiveSlide, "inactive")
	local fontheight, text = widgetSystem.updateFontString(fontstringID, textcomponent, textelement, activeSlide, inactiveSlide, "inactive")
	return fontheight + y, text
end

function widgetSystem.setUpGraph(graphID, graphElement, parentx, parenty, parentwidth, parentheight)
	-- propagate parent height/width, unless specified explicitly
	local width, height = GetSize(graphID)
	if width == 0 then
		width = parentwidth
	end
	if height == 0 then
		height = parentheight
	end

	-- position graph
	local x, y = GetOffset(graphID)
	local offsetx = x + parentx
	local offsety = parenty - y - height/2
	widgetSystem.setElementPosition(graphElement.element.mainElement, offsetx, offsety, (width % 2 ~= 0), (height % 2 ~= 0))

	-- scale background
	widgetSystem.setElementScale(getElement("background", graphElement.element.mainElement), width / 100, height / 100)
	
	-- background color
	local bgcolor = ffi.new("Color")
	if C.GetGraphBackgroundColor(graphID, bgcolor) then
		local material = getElement("background.Material713", graphElement.element.mainElement)
		SetDiffuseColor(material, bgcolor.red, bgcolor.green, bgcolor.blue)
		setAttribute(material, "opacity", bgcolor.alpha)
	end

	-- title
	local hasTitle = false
	local textElement = getElement("Text", graphElement.element.mainElement)
	local title = ffi.new("GraphTextInfo")
	if C.GetGraphTitle(graphID, title) then
		graphElement.title = {}
		graphElement.title.text = ffi.string(title.text)
		if graphElement.title.text ~= "" then
			hasTitle = true
			-- title text
			setAttribute(textElement, "textstring", graphElement.title.text)
			-- title font
			graphElement.title.fontname = ffi.string(title.font.name)
			graphElement.title.fontsize = title.font.size
			setAttribute(textElement, "font", graphElement.title.fontname)
			setAttribute(textElement, "size", graphElement.title.fontsize)
			-- title color
			setAttribute(textElement, "textcolor.r", title.color.red)
			setAttribute(textElement, "textcolor.g", title.color.green)
			setAttribute(textElement, "textcolor.b", title.color.blue)
			setAttribute(textElement, "opacity", title.color.alpha)
		end
	end
	if hasTitle then
		-- position title
		graphElement.title.titleheight = GetTextHeightExact(graphElement.title.text, graphElement.title.fontname, graphElement.title.fontsize, width, false)
		widgetSystem.setElementPosition(textElement, 0, height / 2 - graphElement.title.titleheight / 2 - config.graph.border)
	end

	-- xAxis (1/2)
	graphElement.xAxis = {}
	local xAxisElement = getElement("axis", graphElement.element.mainElement)
	widgetSystem.setUpGraphAxis(graphID, xAxisElement, C.GetGraphXAxis, width, nil, graphElement.xAxis)

	-- yAxis (1/2)
	graphElement.yAxis = {}
	local yAxisElement = getElement("axis2", graphElement.element.mainElement)
	widgetSystem.setUpGraphAxis(graphID, yAxisElement, C.GetGraphYAxis, nil, height, graphElement.yAxis)

	-- label dependent offsets
	local xAxisOffsetY = graphElement.xAxis.hasLabel and (graphElement.xAxis.label.labelheight + graphElement.xAxis.label.maxTickHeight + config.graph.border) or 0
	local yAxisOffsetX = graphElement.yAxis.hasLabel and (graphElement.yAxis.label.labelheight + graphElement.yAxis.label.maxTickWidth + config.graph.border) or 0
	local titleOffsetY = hasTitle and (graphElement.title.titleheight + config.graph.border) or 0
	local tickOffsetXRight = 0
	local tickOffsetXLeft = 0
	if graphElement.xAxis.hasLabel then
		tickOffsetXRight = graphElement.xAxis.label.maxTickWidth / 2
		tickOffsetXLeft = graphElement.yAxis.hasLabel and 0 or graphElement.xAxis.label.maxTickWidth / 2
	end
	local tickOffsetYUpper = 0
	local tickOffsetYLower = 0
	if graphElement.yAxis.hasLabel then
		tickOffsetYUpper = hasTitle and 0 or graphElement.yAxis.label.maxTickHeight / 2
		tickOffsetYLower = graphElement.xAxis.hasLabel and 0 or graphElement.yAxis.label.maxTickHeight / 2
	end

	-- xAxis (2/2)
	local axis1Element = getElement("axis1", xAxisElement)
	local axis2Element = getElement("axis2", xAxisElement)
	-- scale
	local xAxisWidth = width - 2 * config.graph.border - yAxisOffsetX - tickOffsetXRight - tickOffsetXLeft
	local xAxisHeight = config.graph.axisWidth
	widgetSystem.setElementScale(axis1Element, xAxisWidth / 100, xAxisHeight / 100)
	widgetSystem.setElementScale(axis2Element, xAxisWidth / 100, xAxisHeight / 100)
	-- position
	local offsetX = yAxisOffsetX / 2 - (tickOffsetXRight - tickOffsetXLeft) / 2
	local offsetY1 = -height / 2 + config.graph.border + xAxisOffsetY + tickOffsetYLower
	local offsetY2 = height / 2 - titleOffsetY - config.graph.border - tickOffsetYUpper
	widgetSystem.setElementPosition(axis1Element, offsetX, offsetY1, (xAxisWidth % 2 ~= 0), (xAxisHeight % 2 ~= 0))
	widgetSystem.setElementPosition(axis2Element, offsetX, offsetY2, (xAxisWidth % 2 ~= 0), (xAxisHeight % 2 ~= 0))
	-- label position
	if graphElement.xAxis.hasLabel then
		widgetSystem.setElementPosition(getElement("Text", xAxisElement), offsetX, -height / 2 + graphElement.xAxis.label.labelheight / 2 + config.graph.border)
	end
	-- activate
	goToSlide(xAxisElement, graphElement.xAxis.hasLabel and "label" or "nolabel")

	-- yAxis (2/2)
	axis1Element = getElement("axis1", yAxisElement)
	axis2Element = getElement("axis2", yAxisElement)
	-- scale
	local yAxisWidth = config.graph.axisWidth
	local yAxisHeight = height - 2 * config.graph.border - titleOffsetY - xAxisOffsetY - tickOffsetYUpper - tickOffsetYLower
	widgetSystem.setElementScale(axis1Element, yAxisWidth / 100, yAxisHeight / 100)
	widgetSystem.setElementScale(axis2Element, yAxisWidth / 100, yAxisHeight / 100)
	-- position
	local offsetX1 = - width / 2 + config.graph.border + yAxisOffsetX + tickOffsetXLeft
	local offsetX2 = width / 2 - config.graph.border - tickOffsetXRight
	local offsetY = xAxisOffsetY / 2 - titleOffsetY / 2 - tickOffsetYUpper / 2 + tickOffsetYLower / 2
	widgetSystem.setElementPosition(axis1Element, offsetX1, offsetY, (yAxisWidth % 2 ~= 0), (yAxisHeight % 2 ~= 0))
	widgetSystem.setElementPosition(axis2Element, offsetX2, offsetY, (yAxisWidth % 2 ~= 0), (yAxisHeight % 2 ~= 0))
	-- label position
	if graphElement.yAxis.hasLabel then
		widgetSystem.setElementPosition(getElement("Text", yAxisElement), - width / 2 + graphElement.yAxis.label.labelheight / 2 + config.graph.border, offsetY)
	end
	-- activate
	goToSlide(yAxisElement, graphElement.yAxis.hasLabel and "label" or "nolabel")

	-- ticks
	-- xAxis
	local xAxisRange = graphElement.xAxis.endvalue - graphElement.xAxis.startvalue
	local xAxisNoOfTicks = xAxisRange / graphElement.xAxis.granularity
	local tickstep = xAxisWidth / xAxisNoOfTicks
	local _, remainder = math.modf(xAxisNoOfTicks)
	xAxisNoOfTicks = math.ceil(xAxisNoOfTicks) + ((remainder == 0) and 1 or 0)
	local xAxisTickOffset = graphElement.xAxis.offset * xAxisWidth / xAxisRange

	if xAxisNoOfTicks > config.graph.maxTicksPerElement then
		DebugError("Widget system error. X axis of graph requests " .. xAxisNoOfTicks .. " ticks, but only " .. tostring(config.graph.maxTicksPerElement) .. " are available. Skipping ticks and labels for this axis.")
		xAxisNoOfTicks = 0
	else
		local tickHeight
		-- for scripter intution the grid composed from x-Axis ticks is enabled in the y Axis
		if graphElement.yAxis.grid then
			tickHeight = yAxisHeight
		else
			tickHeight = 3 * config.graph.axisWidth
		end
		local tickOffsetY = offsety + offsetY1 + 1.5 * config.graph.axisWidth
		for i = 1, xAxisNoOfTicks do
			local tickElement = graphElement.element.tickElements[i]
			-- color
			local material = getElement("tick.Material740", tickElement)
			SetDiffuseColor(material, graphElement.xAxis.color.r, graphElement.xAxis.color.g, graphElement.xAxis.color.b)
			setAttribute(material, "opacity", graphElement.xAxis.color.a)
			-- scale
			widgetSystem.setElementScale(getElement("tick", tickElement), config.graph.axisWidth / 100, tickHeight / 100)
			-- position
			widgetSystem.setElementPosition(tickElement, offsetx + offsetX1 + xAxisTickOffset + tickstep * (i - 1), tickOffsetY)
			if graphElement.yAxis.grid then
				SetDiffuseColor(material, graphElement.yAxis.gridcolor.r, graphElement.yAxis.gridcolor.g, graphElement.yAxis.gridcolor.b)
				setAttribute(material, "opacity", graphElement.yAxis.gridcolor.a)
				widgetSystem.setElementPosition(getElement("tick", tickElement), 0, tickHeight / 2 - 1.5 * config.graph.axisWidth)
			end
			-- text
			if graphElement.xAxis.hasLabel then
				local textElement = getElement("Text", tickElement)
				-- text text
				local text = graphElement.xAxis.label.tickTexts[i]
				setAttribute(textElement, "textstring", text)
				-- text font
				setAttribute(textElement, "font", graphElement.xAxis.label.fontname)
				setAttribute(textElement, "size", graphElement.xAxis.label.fontsize)
				-- text color
				setAttribute(textElement, "textcolor.r", graphElement.xAxis.label.color.r)
				setAttribute(textElement, "textcolor.g", graphElement.xAxis.label.color.g)
				setAttribute(textElement, "textcolor.b", graphElement.xAxis.label.color.b)
				setAttribute(textElement, "opacity", graphElement.xAxis.label.color.a)
				-- alignment
				setAttribute(textElement, "horzalign", 1)
				-- text position
				local textheight = GetTextHeightExact(text, graphElement.xAxis.label.fontname, graphElement.xAxis.label.fontsize, width, false)
				widgetSystem.setElementPosition(textElement, 0, -textheight)
			end
			local state
			if graphElement.xAxis.hasLabel then
				state = "both"
			else
				state = "tick"
			end
			goToSlide(tickElement, state)
		end
	end

	-- yAxis
	local yAxisRange = graphElement.yAxis.endvalue - graphElement.yAxis.startvalue
	local yAxisNoOfTicks = yAxisRange / graphElement.yAxis.granularity
	tickstep = yAxisHeight / yAxisNoOfTicks
	_, remainder = math.modf(yAxisNoOfTicks)
	yAxisNoOfTicks = math.ceil(yAxisNoOfTicks) + ((remainder == 0) and 1 or 0)
	local yAxisTickOffset = graphElement.yAxis.offset * yAxisWidth / yAxisRange

	if yAxisNoOfTicks > (config.graph.maxTicksPerElement - xAxisNoOfTicks) then
		DebugError("Widget system error. Y axis of graph requests " .. yAxisNoOfTicks .. " ticks, but only " .. tostring(config.graph.maxTicksPerElement - xAxisNoOfTicks) .. " are available. Skipping ticks and labels for this axis.")
		yAxisNoOfTicks = 0
	else
		local tickWidth
		-- for scripter intution the grid composed from y-Axis ticks is enabled in the x Axis
		if graphElement.xAxis.grid then
			tickWidth = xAxisWidth
		else
			tickWidth = 3 * config.graph.axisWidth
		end
		local tickOffsetX = offsetx + offsetX1 + 1.5 * config.graph.axisWidth
		for i = 1, yAxisNoOfTicks do
			local tickElement = graphElement.element.tickElements[xAxisNoOfTicks + i]
			-- color
			local material = getElement("tick.Material740", tickElement)
			SetDiffuseColor(material, graphElement.yAxis.color.r, graphElement.yAxis.color.g, graphElement.yAxis.color.b)
			setAttribute(material, "opacity", graphElement.yAxis.color.a)
			-- scale
			widgetSystem.setElementScale(getElement("tick", tickElement), tickWidth / 100, config.graph.axisWidth / 100)
			-- position
			widgetSystem.setElementPosition(tickElement, tickOffsetX, offsety + offsetY1 + yAxisTickOffset + tickstep * (i - 1))
			if graphElement.xAxis.grid then
				SetDiffuseColor(material, graphElement.xAxis.gridcolor.r, graphElement.xAxis.gridcolor.g, graphElement.xAxis.gridcolor.b)
				setAttribute(material, "opacity", graphElement.xAxis.gridcolor.a)
				widgetSystem.setElementPosition(getElement("tick", tickElement), tickWidth / 2 - 1.5 * config.graph.axisWidth, 0)
			end
			-- text
			if graphElement.yAxis.hasLabel then
				local textElement = getElement("Text", tickElement)
				-- text text
				local text = graphElement.yAxis.label.tickTexts[i]
				setAttribute(textElement, "textstring", text)
				-- text font
				setAttribute(textElement, "font", graphElement.yAxis.label.fontname)
				setAttribute(textElement, "size", graphElement.yAxis.label.fontsize)
				-- text color
				setAttribute(textElement, "textcolor.r", graphElement.yAxis.label.color.r)
				setAttribute(textElement, "textcolor.g", graphElement.yAxis.label.color.g)
				setAttribute(textElement, "textcolor.b", graphElement.yAxis.label.color.b)
				setAttribute(textElement, "opacity", graphElement.yAxis.label.color.a)
				-- alignment
				setAttribute(textElement, "horzalign", 2)
				-- text position
				local textwidth = GetTextWidth(text, graphElement.yAxis.label.fontname, graphElement.yAxis.label.fontsize)
				widgetSystem.setElementPosition(textElement, -config.graph.border - 1.5 * config.graph.axisWidth, 0)
			end
			local state
			if graphElement.yAxis.hasLabel then
				state = "both"
			else
				state = "tick"
			end
			goToSlide(tickElement, state)
		end
	end

	-- data
	graphElement.datarecords = {}
	local n = C.GetNumGraphDataRecords(graphID)
	local buf = ffi.new("GraphDataRecord[?]", n)
	n = C.GetGraphDataRecords(buf, n, graphID)
	for i = 0, n - 1 do
		local record = {}

		record.markerType = "none"
		if buf[i].MarkerType == 1 then
			record.markerType = "square"
		elseif buf[i].MarkerType == 2 then
			record.markerType = "diamond"
		elseif buf[i].MarkerType == 3 then
			record.markerType = "circle"
		end
		record.markerSize = buf[i].MarkerSize
		record.markerColor = buf[i].MarkerColor

		record.lineType = "none"
		if buf[i].LineType == 1 then
			record.lineType = "normal"
		elseif buf[i].LineType == 2 then
			record.lineType = "dotted"
		end
		record.lineWidth = buf[i].LineWidth
		record.lineColor = buf[i].LineColor

		record.highlighted = buf[i].Highlighted
		record.mouseovertext = ffi.string(buf[i].MouseOverText)

		record.data = {}
		local buf2 = ffi.new("GraphDataPoint[?]", buf[i].NumData)
		local m = C.GetGraphData(buf2, buf[i].NumData, graphID, i + 1)
		for j = 0, m - 1 do
			table.insert(record.data, { x = buf2[j].x, y = buf2[j].y })
		end

		table.insert(graphElement.datarecords, record)
	end

	local usedDataPoints = 0
	local minX = offsetx + offsetX1
	local maxX = minX + xAxisWidth
	local minY = offsety + offsetY1
	local maxY = minY + yAxisHeight
	for i, dataRecord in ipairs(graphElement.datarecords) do
		local state = "inactive"
		if dataRecord.lineType == "none" then
			if (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
				state = "square"
			elseif dataRecord.markerType == "circle" then
				state = "circle"
			end
		else
			if dataRecord.markerType == "none" then
				state = "line"
			elseif (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
				state = "squareline"
			elseif dataRecord.markerType == "circle" then
				state = "circleline"
			end
		end

		if state ~= "inactive" then
			if #dataRecord.data > (config.graph.maxDataPointsPerElement - usedDataPoints) then
				DebugError("Widget system error. Data record " .. i .. " of graph requests " .. #dataRecord.data .. " data points, but only " .. tostring(config.graph.maxDataPointsPerElement - usedDataPoints) .. " are available. Skipping this data record.")
			else
				local lastX, lastY
				for j, data in ipairs(dataRecord.data) do
					local datastate = state
					local dataPointElement = graphElement.element.dataPointElements[usedDataPoints + j]
					data.element = dataPointElement
					-- different z layers for different data records
					setAttribute(dataPointElement, "position.z", config.graph.dataRecordOffsetZ * i)
					-- current data point position
					local curX = math.floor(minX + (data.x - graphElement.xAxis.startvalue) / xAxisRange * xAxisWidth)
					local curY = math.floor(minY + (data.y - graphElement.yAxis.startvalue) / yAxisRange * yAxisHeight)
					-- check whether new data point is visible
					if (curX < minX - 1) or (curX > maxX + 1) or (curY < minY - 1) or (curY > maxY + 1) then
						if dataRecord.lineType ~= "none" then
							if (lastX ~= nil) and (lastY ~= nil) then
								-- find first visible point on line
								local clampedLastX = math.max(minX, math.min(maxX, lastX))
								local clampedLastY = math.max(minY, math.min(maxY, lastY))
								local lambdaX, lambdaY
								if curX == lastX then
									lambdaX = 1
								else
									lambdaX = (clampedLastX - lastX) / (curX - lastX)
								end
								if curY == lastY then
									lambdaY = 1
								else
									lambdaY = (clampedLastY - lastY) / (curY - lastY)
								end
								-- check whether the first visible point even lies on the current line segment
								if (lambdaX < 0) or (lambdaX > 1) or (lambdaY < 0) or (lambdaY > 1) then
									usedDataPoints = usedDataPoints - 1
								else
									clampedLastX = lastX + math.max(lambdaX, lambdaY) * (curX - lastX)
									clampedLastY = lastY + math.max(lambdaX, lambdaY) * (curY - lastY)
									-- find last visible point on line
									local newX = math.max(minX, math.min(maxX, curX))
									local newY = math.max(minY, math.min(maxY, curY))
									lambdaX = (newX - clampedLastX) / (curX - clampedLastX)
									lambdaY = (newY - clampedLastY) / (curY - clampedLastY)
									local diffX = math.min(lambdaX, lambdaY) * (curX - clampedLastX)
									local diffY = math.min(lambdaX, lambdaY) * (curY - clampedLastY)
									-- icon position
									data.iconX = clampedLastX + diffX / 2
									data.iconY = clampedLastY + diffY / 2
									-- prepare dataPoint position
									widgetSystem.setElementPosition(dataPointElement, clampedLastX + diffX, clampedLastY + diffY)
									-- set up line
									widgetSystem.setUpDataPointLine(dataRecord, data, dataPointElement, diffX, diffY)
									-- activate dataPoint
									goToSlide(dataPointElement, "line")
								end
							end
						else
							-- didn't use the dataPointElement, re use on next iteration
							usedDataPoints = usedDataPoints - 1
						end
					else
						-- position
						widgetSystem.setElementPosition(dataPointElement, curX, curY)
						if dataRecord.lineType ~= "none" then
							if (lastX ~= nil) and (lastY ~= nil) then
								-- find first visible point on line
								local clampedLastX = math.max(minX, math.min(maxX, lastX))
								local clampedLastY = math.max(minY, math.min(maxY, lastY))
								local lambdaX, lambdaY
								if curX == lastX then
									lambdaX = 1
								else
									lambdaX = (curX - clampedLastX) / (curX - lastX)
								end
								if curY == lastY then
									lambdaY = 1
								else
									lambdaY = (curY - clampedLastY) / (curY - lastY)
								end
								local diffX = math.min(lambdaX, lambdaY) * (curX - lastX)
								local diffY = math.min(lambdaX, lambdaY) * (curY - lastY)
								-- icon position
								data.iconX = curX - diffX / 2
								data.iconY = curY - diffY / 2
								-- set up line
								widgetSystem.setUpDataPointLine(dataRecord, data, dataPointElement, diffX, diffY)
							else
								if datastate == "line" then
									datastate = "inactive"
								elseif datastate == "squareline" then
									datastate = "square"
								elseif datastate == "circleline" then
									datastate = "circle"
								end
								-- icon position
								data.iconX = curX
								data.iconY = curY
							end
						end
						-- set up marker
						widgetSystem.setUpDataPointMarker(dataRecord, dataPointElement)
						-- state
						goToSlide(dataPointElement, datastate)
					end
					-- store previous data point position
					lastX = curX
					lastY = curY
				end
				usedDataPoints = usedDataPoints + #dataRecord.data
			end
		end
	end

	-- icons
	graphElement.icons = {}
	local n = C.GetNumGraphIcons(graphID)
	local buf = ffi.new("GraphIcon[?]", n)
	n = C.GetGraphIcons(buf, n, graphID)
	for i = 0, n - 1 do
		local icon = {}

		icon.dataRecordIdx = tonumber(buf[i].DataRecordIdx);
		icon.dataIdx = tonumber(buf[i].DataIdx);
		icon.ID = ffi.string(buf[i].IconID);
		icon.mouseOverText = ffi.string(buf[i].MouseOverText);

		table.insert(graphElement.icons, icon)
	end

	for i, icon in ipairs(graphElement.icons) do
		if i > config.graph.maxIconsPerElement then
			DebugError("Widget system error. Graph requests " .. #graphElement.icons .. " icons, but only " .. config.graph.maxIconsPerElement .. " are available. Skipping extra icons.")
			break
		end
		local iconElement = graphElement.element.iconElements[i]
		icon.element = iconElement

		-- scale
		widgetSystem.setElementScale(getElement("background", iconElement), config.graph.iconSize / 100, config.graph.iconSize / 100)
		-- position
		local data = graphElement.datarecords[icon.dataRecordIdx].data[icon.dataIdx]
		local angle = (data.iconAngle or math.rad(-45)) + math.rad(90)
		if angle < math.rad(-90) or angle > math.rad(90) then
			angle = angle + math.pi
		end
		widgetSystem.setElementPosition(iconElement, data.iconX + config.graph.iconSize * math.cos(angle), data.iconY + config.graph.iconSize * math.sin(angle))
		setAttribute(iconElement, "position.z", config.graph.dataRecordOffsetZ * icon.dataRecordIdx)

		-- icon
		local material = getElement("icon.icon", iconElement)
		SetIcon(getElement("icon", material), icon.ID, nil, nil, nil, true, config.graph.iconSize, config.graph.iconSize)

		goToSlide(iconElement, "active")
	end

	-- activate the graph
	goToSlide(graphElement.element.mainElement, hasTitle and "title" or "notitle")

	widgetSystem.addToAssociationList(graphID, graphElement, graphElement.element.mainElement, parentx, parenty, parentwidth)
end

function widgetSystem.setUpDataPointLine(dataRecord, data, dataPointElement, diffX, diffY)
	-- scale
	local lineHeight = math.sqrt(diffX * diffX + diffY * diffY)
	widgetSystem.setElementScale(getElement("line", dataPointElement), lineHeight / 100, dataRecord.lineWidth / 100)
	-- position
	widgetSystem.setElementPosition(getElement("line", dataPointElement), -diffX / 2, -diffY / 2)
	-- rotation
	data.iconAngle = math.atan2(diffY, diffX)
	widgetSystem.setElementRotation(getElement("line", dataPointElement), data.iconAngle)
	-- color
	local material = getElement("line.Material772", dataPointElement)
	SetDiffuseColor(material, dataRecord.lineColor.red, dataRecord.lineColor.green, dataRecord.lineColor.blue)
	setAttribute(material, "opacity", dataRecord.lineColor.alpha)
end

function widgetSystem.setUpDataPointMarker(dataRecord, dataPointElement)
	-- scale
	if (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
		widgetSystem.setElementScale(getElement("marker1", dataPointElement), dataRecord.markerSize / 100, dataRecord.markerSize / 100)
	elseif dataRecord.markerType == "circle" then
		widgetSystem.setElementScale(getElement("marker2", dataPointElement), dataRecord.markerSize / 100, nil, dataRecord.markerSize / 100)
	end
	-- rotation
	if dataRecord.markerType == "diamond" then
		widgetSystem.setElementRotation(getElement("marker1", dataPointElement), math.rad(45))
	end
	-- color
	local material
	if (dataRecord.markerType == "square") or (dataRecord.markerType == "diamond") then
		material = getElement("marker1.Material755", dataPointElement)
		SetDiffuseColor(material, dataRecord.markerColor.red, dataRecord.markerColor.green, dataRecord.markerColor.blue)
		setAttribute(material, "opacity", dataRecord.markerColor.alpha)
	elseif dataRecord.markerType == "circle" then
		material = getElement("marker2.Material766", dataPointElement)
		SetDiffuseColor(material, dataRecord.markerColor.red, dataRecord.markerColor.green, dataRecord.markerColor.blue)
		setAttribute(material, "opacity", dataRecord.markerColor.alpha)
	end
end

function widgetSystem.setUpGraphAxis(graphID, axisElement, accessor, width, height, axisData)
	local axisLabelElement = getElement("Text", axisElement)
	local axis1Element = getElement("axis1", axisElement)
	local axis2Element = getElement("axis2", axisElement)

	local axis = ffi.new("GraphAxisInfo")
	if accessor(graphID, axis) then
		axisData.label = {}
		axisData.label.text = ffi.string(axis.label.text)
		if axisData.label.text ~= "" then
			axisData.hasLabel = true
			-- label text
			setAttribute(axisLabelElement, "textstring", axisData.label.text)
			-- title font
			axisData.label.fontname = ffi.string(axis.label.font.name)
			axisData.label.fontsize = axis.label.font.size
			setAttribute(axisLabelElement, "font", axisData.label.fontname)
			setAttribute(axisLabelElement, "size", axisData.label.fontsize)
			-- label color
			axisData.label.color = { r = axis.label.color.red, g = axis.label.color.green, b = axis.label.color.blue, a = axis.label.color.alpha }
			setAttribute(axisLabelElement, "textcolor.r", axis.label.color.red)
			setAttribute(axisLabelElement, "textcolor.g", axis.label.color.green)
			setAttribute(axisLabelElement, "textcolor.b", axis.label.color.blue)
			setAttribute(axisLabelElement, "opacity", axis.label.color.alpha)
			-- label height
			axisData.label.labelheight = GetTextHeightExact(axisData.label.text, axisData.label.fontname, axisData.label.fontsize, width or height, false)
		end
		-- axis color
		axisData.color = { r = axis.color.red, g = axis.color.green, b = axis.color.blue, a = axis.color.alpha }
		local material = getElement("Material723", axis1Element)
		SetDiffuseColor(material, axis.color.red, axis.color.green, axis.color.blue)
		setAttribute(material, "opacity", axis.color.alpha)
		material = getElement("Material723", axis2Element)
		SetDiffuseColor(material, axis.color.red, axis.color.green, axis.color.blue)
		setAttribute(material, "opacity", axis.color.alpha)
		-- axis startvalue
		axisData.startvalue = axis.startvalue
		-- axis endvalue
		axisData.endvalue = axis.endvalue
		-- axis granularity
		axisData.granularity = axis.granularity
		-- axis granularity
		axisData.offset = axis.offset % axis.granularity
		-- axis grid
		axisData.grid = axis.grid
		-- axis grid color
		axisData.gridcolor = { r = axis.gridcolor.red, g = axis.gridcolor.green, b = axis.gridcolor.blue, a = axis.gridcolor.alpha }

		if axisData.hasLabel then
			local axisNoOfTicks = (axisData.endvalue - axisData.startvalue) / axisData.granularity
			local _, remainder = math.modf(axisNoOfTicks)
			axisNoOfTicks = math.ceil(axisNoOfTicks) + ((remainder == 0) and 1 or 0)

			-- get the accuracy from the granularity
			axisData.label.accuracy = 0
			local int, frac = math.modf(axisData.granularity)
			-- getting rid of float inaccuracy
			frac = math.floor(frac * math.pow(10, 6) + 0.5)
			if frac > 0 then
				frac = string.gsub(frac, "0+$", "")
				axisData.label.accuracy = #frac
			elseif axisData.granularity >= 10 then
				axisData.label.accuracy = -1
			else
				axisData.label.accuracy = 0
			end

			axisData.label.maxTickWidth = 0
			axisData.label.maxTickHeight = 0
			axisData.label.tickTexts = {}
			for i = 1, axisNoOfTicks do
				local text = ""
				local number = axisData.startvalue + axisData.offset + (i - 1) * axisData.granularity
				local int, frac = math.modf(number)
				int = math.abs(int)
				frac = math.abs(frac)
				text = ((number < 0) and "-" or "") .. ConvertIntegerString(int, true, 0, true, false)
				if axisData.label.accuracy > 0 then
					frac = math.floor(frac * (10 ^ axisData.label.accuracy) + 0.5)
					text = text .. L["."] .. string.format("%0".. axisData.label.accuracy .."d", frac)
				end

				axisData.label.tickTexts[i] = text
				axisData.label.maxTickWidth = math.max(axisData.label.maxTickWidth, GetTextWidth(text, axisData.label.fontname, axisData.label.fontsize))
				axisData.label.maxTickHeight = math.max(axisData.label.maxTickHeight, GetTextHeightExact(text, axisData.label.fontname, axisData.label.fontsize, width or height, false))
			end
		end
	end
end

-- scrollBar          = the scrollbar to setup
-- posx               = x-position of the scrollbar's upper left corner
-- posy               = y-position of the scrollbar's upper left corner
-- scrollbarWidth     = the width the entire scrollbar can use
-- fullScrollbarWidth = the (virtual) width the scrollbar represents (i.e. equals scrollbarWidth, if the represented element is fully visible)
-- #StefanLow -- add generic scrollbar and reuse for table as well as slider
function widgetSystem.setUpHorizontalScrollBar(scrollBar, posx, posy, scrollbarWidth, fullScrollbarWidth, granularity)
	-- set values for entire scrollbar
	local scrollBarElement = scrollBar.element
	goToSlide(scrollBarElement, "active")
	goToSlide(scrollBar.sliderElement, "normal")
	goToSlide(scrollBar.leftArrowElement, "normal")
	goToSlide(scrollBar.rightArrowElement, "normal")
    -- set y-position for the entire component, since only x-positions of elements have to be positioned separately
	widgetSystem.setElementPosition(scrollBarElement, nil, posy - config.texturesizes.slider.scrollBar.height / 2)

	-- set background element
	local background  = getElement("background.center", scrollBarElement)
	local leftBorder  = getElement("background.left", scrollBarElement)
	local rightBorder = getElement("background.right", scrollBarElement)
	-- the scrollbar width we require for the center part of the scrollbar's background element is x - the avialable width of the left/right textures for the background scrollbar - the width of the arrow elements
	-- which at the time of writing is 16 for each border (left and right) hence and 12 for each arrow (left and right): 2 * 16 + 2 * 12 = 60 px
	local centerElementBackgroundWidth = scrollbarWidth - 2 * config.texturesizes.slider.scrollBar.borderElementWidth - 2 * config.texturesizes.slider.scrollBar.arrowElementWidth
	local scalefactor = centerElementBackgroundWidth / 100
	-- center element starts right to the left edge of the left-background-socrollbar-element (i.e. +28 at the time of writing)
	widgetSystem.setElementPosition(background, posx + centerElementBackgroundWidth / 2 + config.texturesizes.slider.scrollBar.borderElementWidth + config.texturesizes.slider.scrollBar.arrowElementWidth)
	widgetSystem.setElementScale(background, scalefactor)

	-- set the fixed left/right elements on left/right of the scrollbar
	-- position left arrow element
	widgetSystem.setElementPosition(scrollBar.leftArrowElement, posx + config.texturesizes.slider.scrollBar.arrowElementWidth / 2)
	-- position left elemen
	widgetSystem.setElementPosition(leftBorder, posx + config.texturesizes.slider.scrollBar.borderElementWidth / 2 + config.texturesizes.slider.scrollBar.arrowElementWidth)
	-- position right element
	widgetSystem.setElementPosition(rightBorder, posx + centerElementBackgroundWidth + config.texturesizes.slider.scrollBar.borderElementWidth * 1.5 + config.texturesizes.slider.scrollBar.arrowElementWidth)
	-- position right arrow element
	widgetSystem.setElementPosition(scrollBar.rightArrowElement, posx + centerElementBackgroundWidth + config.texturesizes.slider.scrollBar.borderElementWidth * 2 + config.texturesizes.slider.scrollBar.arrowElementWidth * 1.5)

	-- calculate scrollbar width
	local usableSliderWidth = scrollbarWidth - 2 * config.texturesizes.slider.scrollBar.borderBoundaryLimit - 2 * config.texturesizes.slider.scrollBar.arrowElementWidth
	local sliderWidth = scrollbarWidth / fullScrollbarWidth * usableSliderWidth -- note this is hacky, but correct --- #StefanLow --- change this so the calculation is easier to understand
	sliderWidth = math.max(sliderWidth, config.slider.minScrollBarWidth)

	-- scale center slider element
	local centerSliderElement = getElement("center.scale", scrollBar.sliderElement)
	local leftSliderElement   = getElement("left", scrollBar.sliderElement)
	local rightSliderElement  = getElement("right", scrollBar.sliderElement)
	local centerElementWidth  = sliderWidth - config.texturesizes.slider.scrollBar.sliderBorderElementWidth * 2
	centerElementWidth = math.ceil(centerElementWidth)
	if centerElementWidth % 2 ~= 0 then
		centerElementWidth = centerElementWidth + 1
	end
	-- the actual calculation is like this: centerElementWidth in AnarkPx (i.e. centerElementWidth/100) /  AnarkElementResolution (which is textureSizeWidthOfBorderElement/100)
	-- this can be reduced to the following formular
	-- scalefactor = centerElementWidth / 100 / (config.texturesizes.slider.scrollBar.sliderCenterElementWidth / 100)
	scalefactor = centerElementWidth / config.texturesizes.slider.scrollBar.sliderCenterElementWidth
	widgetSystem.setElementScale(centerSliderElement, scalefactor)
	-- note: left/right are positioned relative to the center element (hence no posx used here)
	-- position left slider element
	widgetSystem.setElementPosition(leftSliderElement, -(centerElementWidth + config.texturesizes.slider.scrollBar.sliderBorderElementWidth) / 2)
	-- position right slider element
	widgetSystem.setElementPosition(rightSliderElement, (centerElementWidth + config.texturesizes.slider.scrollBar.sliderBorderElementWidth) / 2)

	-- calculate values required for initializing scrollbar values
	local numSteps              = fullScrollbarWidth / scrollbarWidth
	local singleStepSliderWidth = usableSliderWidth / numSteps

	-- initialize scrollbar values
	scrollBar.width    = sliderWidth
	scrollBar.pageStep = widgetSystem.calculateSliderScrollBarPageStep(singleStepSliderWidth, sliderWidth, granularity)
	scrollBar.minPos   = -usableSliderWidth/2 + sliderWidth/2 + posx
	scrollBar.maxPos   =  usableSliderWidth/2 - sliderWidth/2 + posx

	-- move scrollbar to start position
	widgetSystem.updateHorizontalScrollBar(scrollBar, posx, usableSliderWidth, 0)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpIcon(iconID, iconelement, cellelement, parentx, parenty, parentwidth)
	goToSlide(iconelement, "active")

	widgetSystem.addToAssociationList(iconID, iconelement, cellelement, parentx, parenty, parentwidth)
	widgetSystem.updateIcon(iconID, iconelement, parentx, parenty, parentwidth)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent element (i.e. the anchor)
-- parentheight = height of the parent element (i.e. the anchor)
function widgetSystem.setUpProgressElement(progressElementID, progressElement, cellElement, parentx, parenty, parentwidth, parentheight)
	local x, y = GetOffset(progressElementID)
	-- an icon is positioned relative to the icon's center --- hence we've to substract half the icon's extents to properly position it according to the icon's upper left corner
	x = parentx + x
	y = parenty - y

	goToSlide(progressElement, "active")
	widgetSystem.setElementPosition(progressElement, x, y)
	widgetSystem.setElementPosition(getElement("Text", progressElement), parentwidth / 2) -- position at the center of the element
	widgetSystem.setElementPosition(getElement("bar", progressElement), parentwidth / 2, -parentheight + config.texturesizes.progressElement.height/2) -- center the bar element and move to bottom
	widgetSystem.setElementScale(getElement("bar", progressElement), parentwidth / config.texturesizes.progressElement.width) -- scale to full width
	goToSlide(getElement("bar", progressElement), "active")

	widgetSystem.addToAssociationList(progressElementID, progressElement, cellElement, parentx, parenty, parentwidth)
	widgetSystem.updateProgressElement(progressElementID, progressElement)
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpRenderTarget(renderTargetID, parentx, parenty, parentwidth)
	local x, y          = GetOffset(renderTargetID)
	local width, height = GetSize(renderTargetID)
	x = parentx + x
	y = parenty + y

	local renderTargetElement = private.element.renderTarget
	widgetSystem.hideRenderTarget(renderTargetElement) -- if we show a rendertarget after another, we need to clear the previous one first

	-- set pos x/y
	local offsetx = private.offsetx + x + width / 2
	local offsety = private.offsety - y - height / 2
	widgetSystem.setElementPosition(renderTargetElement.element, offsetx, offsety)

	local alpha = C.GetRenderTargetAlpha(renderTargetID)
	local material = getElement("rendertarget.material", renderTargetElement.element)
	setAttribute(material, "opacity", alpha)

	-- set scale/size
	widgetSystem.setElementScale(renderTargetElement.textureElement, width / 100, height / 100)
	SetRenderTargetSize(renderTargetElement.textureString, width, height)

	goToSlide(renderTargetElement.element, "active")

	widgetSystem.addToAssociationList(renderTargetID, renderTargetElement, renderTargetElement.element, parentx, parenty, parentwidth)
end

function widgetSystem.setUpStandardButtons(frame, upperBorder, rightBorder)
	local buttons = GetStandardButtons(frame)
	if buttons == nil then
		return -- no standard buttons
	end

	-- move the button to the correct position
	widgetSystem.setElementPosition(getElement("standardbuttons", private.widgetsystem), rightBorder - config.frame.closeButtonRightOffset, upperBorder - config.frame.closeButtonUpperOffset)

	if buttons == "back" or buttons == "both" then
		private.backButtonShown = true
		widgetSystem.updateStandardButtonState("back")
	end

	if buttons == "close" or buttons == "both" then
		private.closeButtonShown = true
		widgetSystem.updateStandardButtonState("close")
	end
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpSlider(sliderID, parentx, parenty, parentwidth)
	local x, y = GetOffset(sliderID)
	x = parentx + x
	y = parenty + y

	local sliderElement = private.element.slider
	widgetSystem.hideSlider(sliderElement) -- if we show a slider after another, we need to clear the previous one first

	-- set pos x/y
	local offsetx = private.offsetx + x
	local offsety = private.offsety - y
	widgetSystem.setElementPosition(sliderElement.element, offsetx, offsety)

	-- set up static (non dynamic) text elements
	local captionLeft, captionCenter, captionRight = GetSliderText(sliderID)
	setAttribute(getElement("slider.text elements.caption_left", sliderElement.element), "textstring", captionLeft)
	setAttribute(getElement("slider.text elements.caption_center", sliderElement.element), "textstring", captionCenter)
	setAttribute(getElement("slider.text elements.caption_right", sliderElement.element), "textstring", captionRight)

	-- initialize slider members
	local scale1 = {}
	local scale2 = {}
	scale1.valueSuffix, scale2.valueSuffix     = GetSliderValueSuffix(sliderID)
	scale1.displayCenter, scale2.displayCenter = IsSliderCenterValueDisplayed(sliderID)
	scale1.inverted, scale2.inverted           = IsSliderScaleInverted(sliderID)
	local startValue, zeroValue, minValue, maxValue, minSelectableValue, maxSelectableValue
	startValue, zeroValue, minValue, maxValue, minSelectableValue, maxSelectableValue, scale1.left, scale1.right, scale1.minLimit, scale1.maxLimit, scale1.factor, scale1.roundingType, scale2.left, scale2.right, scale2.minLimit, scale2.maxLimit, scale2.factor, scale2.roundingType = GetSliderValues2(sliderID)

	sliderElement.scale = {
		[1] = scale1
	}
	if HasSliderTwoScales(sliderID) then
		sliderElement.scale[2] = scale2
	end

	-- calculate the range for the slider
	local granularity = GetSliderGranularity(sliderID)
	local range       = maxValue - minValue
	local numberSteps = range / granularity
	-- we must increase the number of steps by 1 to include the minValue itself
	-- For instance assume a slider from 0-2 with a granularity of 2.
	-- In this case we need the slider to have two steps. One to select 0 and another to select 2 (since the granularity is 2).
	-- max-min = 2-0 = 2
	-- (max-min)/granularity = 2/2 = 1
	numberSteps = numberSteps + 1

	-- set slider members
	sliderElement.curValue           = startValue
	sliderElement.startValue         = startValue
	sliderElement.zeroValue          = zeroValue
	sliderElement.minValue           = minValue
	sliderElement.maxValue           = maxValue
	sliderElement.fixedValues        = AreSliderValuesFixed(sliderID)
	sliderElement.invertedIndicator  = IsSliderIndicatorInverted(sliderID)
	sliderElement.minSelectableValue = minSelectableValue
	sliderElement.maxSelectableValue = maxSelectableValue
	sliderElement.granularity        = granularity
	sliderElement.valuePerPixel      = (numberSteps*granularity) / (config.slider.scrollBar.width - 2*(config.texturesizes.slider.scrollBar.borderBoundaryLimit + config.texturesizes.slider.scrollBar.arrowElementWidth))

	-- initialize the scrollbar (calculate width)
	widgetSystem.setUpHorizontalScrollBar(sliderElement.scrollBar, config.slider.scrollBar.offset.x, config.slider.scrollBar.offset.y, config.slider.scrollBar.width, config.slider.scrollBar.width*numberSteps, granularity)

	goToSlide(sliderElement.element, "active")

	widgetSystem.addToAssociationList(sliderID, sliderElement, sliderElement.element, parentx, parenty, parentwidth)
	widgetSystem.updateSlider(sliderElement)
	private.sliderActive = true
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth = width of the parent (anchor element)
function widgetSystem.setUpTable(tableID, tableindex, parentx, parenty, parentwidth)
	if tableindex > config.table.maxTables then
		DebugError("Widget system error. Retrieved view with too many tables. Maximum number of tables is "..tostring(config.table.maxTables).." - table will be skipped.")
		return
	end

	local x, y = GetOffset(tableID)
	x = parentx + x
	y = parenty + y

	-- get table height/width and ensure it does not exceed the frame border
	local _, maxtableheight = GetSize(tableID)
	if maxtableheight == 0 then
		-- if no table height is specified, use entire available height
		maxtableheight = private.height - y
	end
	maxtableheight = math.min(maxtableheight, private.height-y)
	if maxtableheight <= 0 then
		DebugError("Widget system error. No vertical space left to display the table. Skipping table.")
		return
	end

	widgetSystem.hideTable(tableindex) -- if we show a table after another, we need to clear the previous one first
	local tableElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.table or private.element.table
	local tableElement = tableElements[tableindex]

	local numRows = GetTableNumRows(tableID)

	-- set unselectable rows
	tableElement.unselectableRows = {}
	for row = 1, numRows do
		if not IsTableRowSelectable(tableID, row) then
			tableElement["unselectableRows"][row] = true
		end
	end

	-- set fixed row data
	tableElement["numFixedRows"] = GetTableNumFixedRows(tableID)

	-- check whether or not the table should display a scrollbar
	local fullrowheight          = GetTableFullHeight(tableID)
	local requiredRowHeight      = fullrowheight + (numRows-1) * config.table.bordersize
	-- #StefanLow - isn't requiredTableHeight a more suitable name
	requiredRowHeight            = math.max(requiredRowHeight, 0) -- empty tables result in a calculated height of -config.table.bordersize, hence set that to 0
	local fixedRowHeight         = widgetSystem.calculateFixedRowHeight(tableID, tableElement)
	local minNormalRowHeight     = widgetSystem.calculateMinRowHeight(tableID, tableElement)
	local minHeightWithScrollBar = math.max(minNormalRowHeight, config.table.minScrollBarHeight) + fixedRowHeight
	-- show scrollbar, if table is interactive and the available height does not suffice to show the entire content
	-- however, do not try to display a scrollbar, if the height doesn't suffice and the size required to show a scrollbar would be larger than the size required to display the actual table content
	local tableRowElements = private.miniWidgetSystemUsed and private.element.miniWidgetSystem.tableRows or private.element.tableRows
	local scrollBar = IsInteractive(tableID) and ((maxtableheight < requiredRowHeight and requiredRowHeight > minHeightWithScrollBar) or numRows > #tableRowElements)
	local mintableheight
	if scrollBar then
		mintableheight = minHeightWithScrollBar
	else
		-- if no scrollbar is displayed, we must display the entire content
		mintableheight = requiredRowHeight
	end

	-- calculate frame offsets
	local tableoffsetx = private.offsetx + x
	local tableoffsety = private.offsety - y
	
	-- init displayedRows, will be filled correctly in drawTableCells()
	tableElement["displayedRows"] = 0
	-- calculate table extends
	local columnWidths = { GetTableColumnWidths(tableID) }
	local numCols = #columnWidths
	tableElement["numCols"] = numCols
	-- maxtablewidth specifies the maximal available width for the table (for tables which are < 100% in width, this is not the same as the real table width!)
	local maxtablewidth = private.width - x
	if scrollBar then
		-- reserve enough space for the scrollbar, if it's displayed
		maxtablewidth = maxtablewidth - config.texturesizes.table.scrollBar.width - config.table.bordersize
	end
	-- substract the size required to display borders (i.e. spaces between the columns) -- the number of required borders is numCols - 1 (i.e. |column1 | column2 | column3| --- 2 border elements on each side of column2)
	local maxtablewidthexcludingborders = maxtablewidth - (numCols - 1) * config.table.bordersize
	local columnsInPercent = IsTableColumnWidthPercentage(tableID)
	local success = widgetSystem.convertColumnWidth(columnWidths, columnsInPercent, maxtablewidthexcludingborders)
	-- #StefanMed XT-2500
	local tablewidth = widgetSystem.summarize(columnWidths) / maxtablewidthexcludingborders * maxtablewidth
	if not success then
		DebugError("Widget system error. Given/Required column width "..tablewidth.." exceeds the max table width of "..maxtablewidth..". Skipping table.")
		return
	end
	tableElement["columnWidths"] = columnWidths

	-- fixedrow area
	local fixedRowColumnWidths = {}
	for k, v in pairs(columnWidths) do
		fixedRowColumnWidths[k] = v
	end
	if scrollBar then
		fixedRowColumnWidths[#fixedRowColumnWidths] = fixedRowColumnWidths[#fixedRowColumnWidths] + config.texturesizes.table.scrollBar.width + config.table.bordersize
	end
	tableElement["fixedRowColumnWidths"] = fixedRowColumnWidths

	-- set up table heading
	local header = GetHeader(tableID)
	local headerheight, headertext = widgetSystem.setUpFontString(header, tableElement.header, tableElement.headerText, "active", "inactive", tableoffsetx, tableoffsety, tablewidth)

	-- empty table? simple case, we're done
	if numRows == 0 then
		return
	end

	-- move tableoffset to after the header
	if headertext ~= "" then
		-- only move table further down, if the header is specified
		tableoffsety = tableoffsety - headerheight - config.table.spaceafterheader
		maxtableheight = maxtableheight - headerheight - config.table.spaceafterheader
		if maxtableheight < mintableheight then
			DebugError("Widget system error. No vertical space left to display the table content. Only table header is displayed. Skipping table content.")
			return
		end
	elseif mintableheight > maxtableheight then
		-- if we don't display a header and do not have enough space left to display the table content properly, issue an error and do not display anything
		-- since we cannot properly handle scrolling right and/or would display an unscrollable table only half
		-- if we'd not abort here, we'd set the max table height to the min table height to ensure that scrolling is always working (i.e. the mintableheight is calculated to ensure that we can move up/down to
		-- each selectable row and still display the selected row) this will then result in the table being drawn beneath the frame border (since mintableheight in this case is > maxavailabletableheight)
		DebugError("Widget system error. Vertical space left ("..tostring(maxtableheight)..") doesn't suffice to display the requested table (calculated required min height: "..tostring(mintableheight).."). Table will not be displayed.")
		return
	end
	tableElement.height = maxtableheight -- must be set, since it's used for drawing the table initially (after which the height is updated to the real table height-value)
	tableElement.nonFixedSectionHeight = tableElement.height - fixedRowHeight -- same as with tableElement.height --- must be set here
	tableElement.offsety = tableoffsety

	-- calculate cell x positions
	local cellposx = {
		[1] = tableoffsetx
	}
	for col = 2, numCols do
		table.insert(cellposx, cellposx[col-1] + columnWidths[col-1] + config.table.bordersize)
	end
	tableElement["cellposx"] = cellposx

	-- calculate cell x positions
	local fixedRowCellposx = {
		[1] = tableoffsetx
	}
	for col = 2, numCols do
		table.insert(fixedRowCellposx, fixedRowCellposx[col-1] + fixedRowColumnWidths[col-1] + config.table.bordersize)
	end
	tableElement["fixedRowCellposx"] = fixedRowCellposx

	-- get the first selectable row in the fixed rows
	local firstSelectableFixedRow = 0
	for row = 1, tableElement.numFixedRows do
		if not tableElement["unselectableRows"][row] then
			firstSelectableFixedRow = row
			break
		end
	end

	-- set tableElement data
	tableElement["borderEnabled"]           = IsBorderEnabled(tableID)
	tableElement["curRow"]                  = 0 -- initialized here, so that widgetSystem.selectRow() works right (must be 0, so that selectRow issues a row-selected event)
	tableElement["numRows"]                 = numRows
	-- #coreUILow - not used atm - combine slider/tablescrollbar scrolling code to be consistent and reduce code redundancy?
	tableElement["granularity"]             = 1 -- table scroll granularity is always 1
	tableElement["firstSelectableFixedRow"] = firstSelectableFixedRow
	tableElement["wrapAround"]              = IsTableWrapAround(tableID)

	-- get the first selectable row in the normal row section
	-- first go through the list of non-fixed-rows to find a selectable one, and only if there is none start with the first fixed row
	local firstSelectableRow = firstSelectableFixedRow
	for row = tableElement.numFixedRows + 1, numRows do
		if not tableElement["unselectableRows"][row] then
			firstSelectableRow = row
			break
		end
	end

	-- fill and create table cells
	local curtableheight = widgetSystem.drawTableCells(tableID, tableElement, tableElement.numFixedRows + 1, numRows, firstSelectableRow)
	tableElement.topBottomRow = tableElement.bottomRow

	-- set the tableheight to the current height, so the height of the table is not being changed after initial setup
	-- note: this handles the case where we have a scrollable table with rows of different sizes, so we do not vary the scrollbar height while we scroll up/down, but rather keep the
	-- table height maxed at the initial value
	tableElement.height = math.max(curtableheight, mintableheight)
	tableElement.nonFixedSectionHeight = tableElement.height - fixedRowHeight

	if scrollBar then
		widgetSystem.setUpVerticalScrollBar(tableElement.scrollBar, tableoffsetx + tablewidth + config.table.bordersize, tableoffsety - fixedRowHeight, tableElement.nonFixedSectionHeight, requiredRowHeight)
	end

	-- mouse pick element
	tableElement.mousePick.state = {
		["mouseOver"]  = {
			["state"] = false,
			["original"] = nil,
			["row"] = nil
		}
	}
	goToSlide(tableElement.mousePick.element, "active")
	widgetSystem.setElementPosition(tableElement.mousePick.element, tableoffsetx + tablewidth / 2, tableoffsety - tableElement.height / 2)
	widgetSystem.setElementScale(tableElement.mousePick.element, tablewidth / 100, tableElement.height / 100)

	-- must be done before altering the top/selected row (functions access the element via the association list)
	widgetSystem.addToAssociationList(tableID, tableElement, nil, parentx, parenty, parentwidth)

	-- #StefanLow - this could be combined with the code above, so we spare us resetting the table after initially drawing it
	-- apply initial values
	local newTopRow         = GetTableInitialTopRow(tableID)
	local newSelectedRow    = GetTableInitialSelectedRow(tableID)
	local newSelectedColumn = GetTableInitialSelectedColumn(tableID)
	if newTopRow then
		local _, _, error = widgetSystem.setTopRow(tableID, newTopRow)
		if error ~= nil then
			DebugError("Widget system error. Failed to set initial top row. Top-row will not be changed. Error: "..tostring(error))
		end
	end
	if newSelectedRow then
		local _, _, error = widgetSystem.selectRow(tableID, newSelectedRow)
		if error ~= nil then
			DebugError("Widget system error. Failed to set initial selected row. Selected-row will not be changed. Error: "..tostring(error))
		end
	end
	if newSelectedColumn then
		local _, _, error = widgetSystem.selectColumn(tableID, newSelectedColumn)
		if error ~= nil then
			DebugError("Widget system error. Failed to set initial selected column. Selected-column will not be changed. Error: "..tostring(error))
		end
	end

	if tableElement.interactiveChild == nil then
		-- no interactive entry in the current table row, issue an event, once
		CallWidgetEventScripts(tableID, "onColumnChanged", nil)
	end
end

-- parentx = x offset of the parent (anchor element)
-- parenty = y offset of the parent (anchor element)
-- parentwidth  = width of the parent element (i.e. the anchor)
-- parentheight = height of the parent element (i.e. the anchor)
function widgetSystem.setUpTimer(timerID, timerElement, cellElement, parentx, parenty, parentwidth, parentheight)
	local x, y = GetOffset(timerID)
	x = parentx + x + parentwidth / 2 -- position text elements at the center of the parent
	y = parenty - y

	-- activate the timer first
	goToSlide(timerElement, "active")

	widgetSystem.setElementPosition(timerElement, x, y)

	-- move time to bottom
	-- center the bar element (valignment is set to bottom, for ease of positioning --- aka: no need to calculate the fontheight)
	widgetSystem.setElementPosition(getElement("time", timerElement), nil, -parentheight)

	widgetSystem.addToAssociationList(timerID, timerElement, cellElement, parentx, parenty, parentwidth)

	-- activate timer
	local curtime = GetCurTime()
	private.activeTimer[timerElement] = curtime + GetTimeLeft(timerID)
	setAttribute(getElement("Text", timerElement), "textstring", L["time"])
	widgetSystem.setTimer(timerElement, private.activeTimer[timerElement])
end

-- scrollBar           = the scrollbar to setup
-- posx                = x-position of the scrollbar's upper left corner
-- posy                = y-position of the scrollbar's upper left corner
-- scrollbarHeight     = the height the entire scrollbar can use
-- fullScrollbarHeight = the (virtual) height the scrollbar represents (i.e. equals scrollbarHeight, if the represented element is fully visible)
function widgetSystem.setUpVerticalScrollBar(scrollBar, posx, posy, scrollbarHeight, fullScrollbarHeight)
	-- store relevant scrollbar infor
	scrollBar.height = scrollbarHeight

	-- set values for entire scrollbar
	local scrollBarElement = scrollBar.element
	goToSlide(scrollBarElement, "active")
	goToSlide(scrollBar.sliderElement, "normal")
	-- set x- and y-positions for the entire component - y-positions will be set relative to the center of the scrollbar
	widgetSystem.setElementPosition(scrollBarElement, posx + config.texturesizes.table.scrollBar.width / 2, posy - scrollbarHeight/2)

	-- set background element
	local background  = getElement("background.center", scrollBarElement)
	local upperBorder = getElement("background.top",    scrollBarElement)
	local lowerBorder = getElement("background.bottom", scrollBarElement)
	-- the scrollbar height we require for the center part of the scrollbar's background element is x - the available height of the upper/lower textures for the background scrollbar
	-- which, at the time of writing, is 16 for each (top and bottom) hence: 2 * 16 = 32px
	local centerElementBackgroundHeight = scrollbarHeight - 2 * config.texturesizes.table.scrollBar.borderElementHeight
	local scalefactor = centerElementBackgroundHeight / 100
	widgetSystem.setElementScale(background, nil, scalefactor)

	-- set the fixed top/bottom elements on top/bottom of the scrollbar
	-- position upper element
	widgetSystem.setElementPosition(upperBorder, nil, centerElementBackgroundHeight / 2 + config.texturesizes.table.scrollBar.borderElementHeight / 2)
	-- position lower element
	widgetSystem.setElementPosition(lowerBorder, nil, -centerElementBackgroundHeight / 2 - config.texturesizes.table.scrollBar.borderElementHeight / 2)

	-- calculate slider height
	local sliderHeight = scrollbarHeight / fullScrollbarHeight * scrollbarHeight
	sliderHeight = math.max(sliderHeight, config.table.minScrollBarHeight)

	-- scale center slider element
	local centerSliderElement = getElement("center.scale", scrollBar.sliderElement)
	local upperSliderElement  = getElement("top", scrollBar.sliderElement)
	local lowerSliderElement  = getElement("bottom", scrollBar.sliderElement)
	local centerElementHeight = sliderHeight - config.texturesizes.table.scrollBar.sliderBorderElementHeight * 2
	-- the actual calculation is like this: centerElementHeight in AnarkPx (i.e. centerElementHeight/100) / AnarkElementResolution (which is textureSizeHeightOfBorderElement/100)
	-- this can be reduced to the following formular
	--scalefactor = centerElementHeight / 100 / (config.texturesizes.table.scrollBar.sliderCenterElementHeight / 100)
	scalefactor = centerElementHeight / config.texturesizes.table.scrollBar.sliderCenterElementHeight
	widgetSystem.setElementScale(centerSliderElement, nil, scalefactor)
	-- note: upper/lower are positioned relative to the center element (hence no posy used here)
	-- position upper slider element
	widgetSystem.setElementPosition(upperSliderElement, nil, (centerElementHeight + config.texturesizes.table.scrollBar.sliderBorderElementHeight) / 2)
	-- position lower slider element
	widgetSystem.setElementPosition(lowerSliderElement, nil, -(centerElementHeight + config.texturesizes.table.scrollBar.sliderBorderElementHeight) / 2)

	-- initialize scrollbar values
	scrollBar.active = true
	scrollBar.sliderHeight = sliderHeight
	scrollBar.valuePerPixel = fullScrollbarHeight / scrollbarHeight

	-- move scrollbar to start position
	widgetSystem.updateVerticalScrollBar(scrollBar, 0)
end

function widgetSystem.startScrollBarDrag(tableElement)
	private.scrollBarDrag = tableElement
	local sliderPosY = widgetSystem.getScrollBarSliderPosition(tableElement.scrollBar.element)
	local _, mouseY = GetLocalMousePosition()
	tableElement.scrollBar.dragOffset = mouseY - sliderPosY
	widgetSystem.updateScrollBarPos(tableElement)
end

function widgetSystem.startScrollLeft(scrollingElement)
	if private.scrolling ~= nil then
		return false -- skip call, if any scroll action is already active
	end

	private.nextTickTime     = getElapsedTime() + config.slider.interval.initialTickDelay
	private.scrolling        = "left"
	private.scrollingElement = scrollingElement
	private.curScrollingStep = 1
	widgetSystem.scrollLeft(scrollingElement, widgetSystem.getCurrentInterval())
	return true
end

function widgetSystem.startScrollRight(scrollingElement)
	if private.scrolling ~= nil then
		return false -- skip call, if any scroll action is already active
	end

	private.nextTickTime     = getElapsedTime() + config.slider.interval.initialTickDelay
	private.scrolling        = "right"
	private.scrollingElement = scrollingElement
	private.curScrollingStep = 1
	widgetSystem.scrollRight(scrollingElement, widgetSystem.getCurrentInterval())
	return true
end

function widgetSystem.startSliderDrag()
	private.sliderDrag = true
	local sliderPosX = widgetSystem.getSliderPosition(private.element.slider.scrollBar.element)
	private.sliderDragStartOffset = sliderPosX - GetLocalMousePosition()
	private.previousSliderMousePos = nil
	widgetSystem.updateSliderPos()
end

function widgetSystem.stopScroll()
	private.nextStepIncreaseTime = nil
	private.nextTickTime         = nil
	private.scrolling            = nil
	private.scrollingElement     = nil
	private.numStepIncreases     = 0
	private.curScrollingStep     = nil
end

function widgetSystem.stopScrollBarDrag(tableElement)
	private.scrollBarDrag                   = nil
	tableElement.scrollBar.dragOffset       = nil
	tableElement.scrollBar.previousMousePos = nil
end

function widgetSystem.stopSliderDrag()
	private.sliderDrag = false
end

function widgetSystem.summarize(array)
	local sum = 0
	for _, value in ipairs(array) do
		sum = sum + value
	end
	return sum
end

function widgetSystem.swapButtonIcon(button, buttonElement)
	if buttonElement.swapIconID == nil then
		return -- no icon to swap
	end

	local newIcon = buttonElement.swapIconID
	buttonElement.swapIconID = buttonElement.iconID
	buttonElement.iconID = newIcon
	
	local material = getElement("Icon.Icon.Material423", buttonElement.element)
	if buttonElement.iconColor ~= nil then
		SetIcon(getElement("Icon", material), newIcon, buttonElement.iconColor.r, buttonElement.iconColor.g, buttonElement.iconColor.b, true, buttonElement.iconWidth, buttonElement.iconHeight)
		setAttribute(material, "opacity", buttonElement.iconColor.a)
	else
		SetIcon(getElement("Icon", material), newIcon, nil, nil, nil, false, buttonElement.iconWidth, buttonElement.iconHeight)
	end
end

function widgetSystem.swapButtonIcon2(button, buttonElement)
	if buttonElement.swapIcon2ID == nil then
		return -- no icon to swap
	end

	local newIcon = buttonElement.swapIcon2ID
	buttonElement.swapIcon2ID = buttonElement.icon2ID
	buttonElement.icon2ID = newIcon
	
	local material = getElement("Icon2.Icon2.Imaterial_icon2", buttonElement.element)
	if buttonElement.icon2Color ~= nil then
		SetIcon(getElement("Icon", material), newIcon, buttonElement.icon2Color.r, buttonElement.icon2Color.g, buttonElement.icon2Color.b, true, buttonElement.icon2Width, buttonElement.icon2Height)
		setAttribute(material, "opacity", buttonElement.icon2Color.a)
	else
		SetIcon(getElement("Icon2", material), newIcon, nil, nil, nil, false, buttonElement.icon2Width, buttonElement.icon2Height)
	end
end

function widgetSystem.swapInteractiveRegion(tableID, tableElement)
	if tableElement.firstSelectableFixedRow == 0 then
		return false -- no fixed rows at all or no selectable row in the fixed row section => nothing to swap
	end

	if tableElement.interactiveRegion == "fixed" then
		widgetSystem.selectRowInternal(tableID, tableElement, tableElement.normalSelectedRow)
	else -- tableElement.interactiveRegion == "normal"
		widgetSystem.selectRowInternal(tableID, tableElement, tableElement.firstSelectableFixedRow)
	end
	return true
end

-- childWidgetID     - the widgetID of the interactive child
-- childTableElement - the table entry of the element of the child
function widgetSystem.unsetInteractiveChildElement(childWidgetID, childTableElement)
	if childTableElement ~= nil then
		-- note: other than for the setIntearctiveElement() we do not check whether the given child is in the current interactive table, since we are unsetting the
		-- element (and that does not cause any damage, if we do so for the non-interactive element)
		-- #StefanLow - revise this reasoning --- sounds not too convincing...
		if  IsType(childWidgetID, "button") then
			widgetSystem.setButtonElementState(childWidgetID, childTableElement, "keyboard", false)
		elseif  IsType(childWidgetID, "checkbox") then
			widgetSystem.setCheckBoxElementState(childWidgetID, childTableElement, "keyboard", false)
		end
		-- for other interactive elements, there's nothing to do
	end
end

function widgetSystem.updateButton(button, buttonElement)
	local text = GetButtonText(button)
	setAttribute(getElement("Text", buttonElement.element), "textstring", text)

	-- update button color for active button (inactive buttons have a fixed color and therefore can never change their initially set-up color)
	if buttonElement.active then
		local r, g, b, a = GetButtonColor(button)
		buttonElement.color = {
			["r"] = r,
			["g"] = g,
			["b"] = b,
			["a"] = a
		}

		local material = getElement("background.Material753", buttonElement.element)
		SetDiffuseColor(material, r, g, b)
		setAttribute(material, "opacity", a)
	end
end

function widgetSystem.updateButtonColor(button, buttonElement, colorMode)
	if buttonElement.iconID then
		-- icon button
		local r, g, b, a = GetButtonIconColor(button)
		if colorMode == "inverse" then
			r, g, b = widgetSystem.invertColor(r, g, b)
		elseif colorMode == "gray" then
			r = config.inactiveButtonTextColor.r
			g = config.inactiveButtonTextColor.g
			b = config.inactiveButtonTextColor.b
		-- else, it's "normal" and uses the original color
		end
		local material = getElement("Icon.Icon.Material423", buttonElement.element)
		SetDiffuseColor(material, r, g, b)
		setAttribute(material, "opacity", a)
	end
	if buttonElement.icon2ID then
		-- icon button
		local r, g, b, a = GetButtonIcon2Color(button)
		if colorMode == "inverse" then
			r, g, b = widgetSystem.invertColor(r, g, b)
		elseif colorMode == "gray" then
			r = config.inactiveButtonTextColor.r
			g = config.inactiveButtonTextColor.g
			b = config.inactiveButtonTextColor.b
		-- else, it's "normal" and uses the original color
		end
		local material = getElement("Icon2.Icon2.Imaterial_icon2", buttonElement.element)
		SetDiffuseColor(material, r, g, b)
		setAttribute(material, "opacity", a)
	end

	local r, g, b, a = GetButtonTextColor(button)
	if colorMode == "inverse" then
		r, g, b = widgetSystem.invertColor(r, g, b)
	elseif colorMode == "gray" then
		r = config.inactiveButtonTextColor.r
		g = config.inactiveButtonTextColor.g
		b = config.inactiveButtonTextColor.b
	-- else, it's "normal" and uses the original color
	end
	local textelement = getElement("Text", buttonElement.element)
	setAttribute(textelement, "textcolor.r", r)
	setAttribute(textelement, "textcolor.g", g)
	setAttribute(textelement, "textcolor.b", b)
	setAttribute(textelement, "opacity", a)
end

function widgetSystem.updateButtonState(button, buttonElement)
	local stateEntry = buttonElement.buttonState
	local targetSlide
	-- only activate the arrows, if the button is actually active
	if buttonElement.active then
		if stateEntry.mouseClick or stateEntry.keyboardPress then
			targetSlide = "click"
		elseif stateEntry.mouseOver or stateEntry.keyboard then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	else
		targetSlide = "unselect"
	end

	-- fire initial states first, so that we get the onButtonDown event after a possible onButtonSelect/onButtonMouseOver event (consitent event order)
	if stateEntry.sendInitialState then
		if stateEntry.mouseOver then
			CallWidgetEventScripts(button, "onButtonMouseOver")
		end
		if stateEntry.keyboard then
			CallWidgetEventScripts(button, "onButtonSelect")
		end

		if targetSlide == "click" then
			CallWidgetEventScripts(button, "onButtonDown")
		end

		stateEntry.sendInitialState = false
	end

	-- #StefanMed - store the button state, so we only need to change the slide, if the current one isn't up-to-date already
	-- Note: We must update the slide always, since we could schedule two slide-updates within a single frame. Example:
	-- highlight button first:
	--    curSlide reports "normal" ->
	--    goToSlide() schedules highlight change
	-- normal state change
	--    curSlide reports "normal" ->
	--    slide change would be missing
	-- This caused XT-2632
	goToSlide(buttonElement.element, targetSlide)

	local colorMode = "normal"
	if targetSlide == "unselect" then
		colorMode = "gray"
	elseif targetSlide == "click" then
		colorMode = "inverse"
	end
	widgetSystem.updateButtonColor(button, buttonElement, colorMode)
end

function widgetSystem.updateCheckBox(checkbox, checkboxElement)
	-- update button color for active button (inactive buttons have a fixed color and therefore can never change their initially set-up color)
	local color = ffi.new("Color")
	if C.GetCheckBoxColor(checkbox, color) then
		checkboxElement.color = {
			["r"] = color.red,
			["g"] = color.green,
			["b"] = color.blue,
			["a"] = color.alpha
		}

		local material = getElement("background.Material753", checkboxElement.element)
		SetDiffuseColor(material, checkboxElement.color.r, checkboxElement.color.g, checkboxElement.color.b)
		setAttribute(material, "opacity", checkboxElement.color.a)
	end
end

function widgetSystem.updateCheckBoxColor(checkbox, checkboxElement, colorMode)
	local color = config.normalCheckBoxBBColor
	if checkboxElement.active and (colorMode == "highlight") then
		color = config.highlightCheckBoxBBColor
	end
	local material = getElement("background_black.Material753", checkboxElement.element)
	SetDiffuseColor(material, color.r, color.g, color.b)
	setAttribute(material, "opacity", color.a)
end

function widgetSystem.updateCheckBoxState(checkbox, checkboxElement)
	local stateEntry = checkboxElement.checkboxState
	local targetSlide
	-- only activate the arrows, if the button is actually active
	if checkboxElement.active then
		if stateEntry.mouseOver or stateEntry.keyboard then
			if checkboxElement.checked then
				targetSlide = "highlightcheck"
			else
				targetSlide = "highlightuncheck"
			end
		else
			if checkboxElement.checked then
				targetSlide = "check"
			else
				targetSlide = "uncheck"
			end
		end
	else
		targetSlide = "unselect"
	end

	-- fire initial states first
	if stateEntry.sendInitialState then
		if stateEntry.mouseOver then
			CallWidgetEventScripts(checkbox, "onCheckBoxMouseOver")
		end
		if stateEntry.keyboard then
			CallWidgetEventScripts(checkbox, "onCheckBoxSelect")
		end

		stateEntry.sendInitialState = false
	end

	-- #StefanMed - store the checkbox state, so we only need to change the slide, if the current one isn't up-to-date already
	-- Note: We must update the slide always, since we could schedule two slide-updates within a single frame. Example:
	-- highlight button first:
	--    curSlide reports "normal" ->
	--    goToSlide() schedules highlight change
	-- normal state change
	--    curSlide reports "normal" ->
	--    slide change would be missing
	-- This caused XT-2632
	goToSlide(checkboxElement.element, targetSlide)

	local colorMode = "normal"
	if (targetSlide == "highlightcheck") or (targetSlide == "highlightuncheck") then
		colorMode = "highlight"
	end
	widgetSystem.updateCheckBoxColor(checkbox, checkboxElement, colorMode)
end

function widgetSystem.setSceneState(state, value)
	private.sceneState[state] = value
	widgetSystem.updateSceneState()
end

function widgetSystem.updateSceneState()
	local targetSlide
	if private.sceneState.widgetsystem and private.sceneState.shapes then
		targetSlide = "both"
	elseif private.sceneState.miniwidgetsystem and private.sceneState.shapes then
		private.miniWidgetSystemUsed = false
		private.sceneState.miniwidgetsystem = false
		private.sceneState.widgetsystem = true
		targetSlide = "both"
	elseif private.sceneState.miniwidgetsystem and private.sceneState.widgetsystem then
		private.miniWidgetSystemUsed = false
		private.sceneState.miniwidgetsystem = false
		targetSlide = "widgetsystem"
	elseif private.sceneState.miniwidgetsystem then
		targetSlide = "miniwidgetsystem"
	elseif private.sceneState.widgetsystem then
		targetSlide = "widgetsystem"
	elseif private.sceneState.shapes then
		targetSlide = "shapes"
	else
		targetSlide = "inactive"
	end
	goToSlide(private.scene, targetSlide)
end

function widgetSystem.toggleCheckBox(checkboxID, checkboxElement)
	checkboxElement.checked = not checkboxElement.checked
	C.SetCheckBoxChecked(checkboxID, checkboxElement.checked)

	widgetSystem.updateCheckBoxState(checkboxID, checkboxElement)
end

function widgetSystem.activateEditBox(editboxID)
	local editboxentry = private.associationList[editboxID]
	if editboxentry == nil then
		return false, 1, "invalid editbox element"
	end

	widgetSystem.activateEditBoxInternal(editboxID, editboxentry.element)

	local element, widgetID, row = widgetSystem.getTableElementByAnarkEditboxElement(editboxentry.element.element)
	widgetSystem.setInteractiveElement(widgetID)
end

function widgetSystem.showMouseOverText(widgetID)
	if (widgetID == nil) or (not IsValidWidgetElement(widgetID)) then
		return -- no widget, skip call
	end

	local count = 1
	if (private.mouseOverText ~= nil) and (private.mouseOverText.widgetID == widgetID)then
		-- increase the counter
		private.mouseOverText.count = private.mouseOverText.count + 1
		-- if text did not change, nothing to do
		if private.mouseOverText.overrideText == private.mouseOverOverrideText then
			return
		else
			count = private.mouseOverText.count
		end
	end

	local text = private.mouseOverOverrideText or ffi.string(C.GetMouseOverText(widgetID))
	if text == "" then
		if (private.mouseOverText ~= nil) then
			private.mouseOverText.count = private.mouseOverText.count - 1
		end
		return -- nothing to display
	end

	-- elements
	local mouseOverElement = getElement("popupmenu", private.widgetsystem)
	local bgElement = getElement("Rectangle", mouseOverElement)
	local textElement = getElement("Text", mouseOverElement)

	-- properties
	local viewwidth, viewheight = GetViewSize()
	local cursorX, cursorY = GetLocalMousePosition()
	local fontname = getAttribute(textElement, "font")

	local fontsize = config.mouseOverText.fontsize
	local maxWidth = config.mouseOverText.maxWidth
	if not private.fullscreenMode then
		fontsize = GetBestFontSize(fontname, fontsize * viewheight / config.nativePresentationHeight)
		maxWidth = math.floor(maxWidth * viewwidth / config.nativePresentationWidth + 0.5)
	end
	
	local numlines, textwidth = GetTextNumLines(text, fontname, fontsize, maxWidth)
	textwidth = textwidth or maxWidth
	local width = textwidth + config.mouseOverText.borderSize.right + config.mouseOverText.borderSize.left
	local textheight = GetTextHeightExact(text, fontname, fontsize, textwidth, true)
	local height = textheight + config.mouseOverText.borderSize.top + config.mouseOverText.borderSize.bottom

	private.mouseOverText = {
		widgetID = widgetID,
		count = count,
		width = width,
		height = height,
		cursorinfo = C.GetCurrentCursorInfo(),
		overrideText = private.mouseOverOverrideText
	}

	-- activate slide
	goToSlide(mouseOverElement, "active")

	-- scaling
	widgetSystem.setElementScale(bgElement, width / 100, height / 100)

	-- position
	widgetSystem.setElementPosition(textElement, -textwidth / 2, textheight / 2 + config.mouseOverText.borderSize.top)
	widgetSystem.setMouseOverPosition()

	-- text
	setAttribute(textElement, "size", fontsize)
	setAttribute(textElement, "boxwidth", textwidth / config.nativePresentationWidth)
	setAttribute(textElement, "textstring", text)
end

function widgetSystem.hideMouseOverText(widgetID)
	if private.mouseOverText == nil then
		return -- nothing to do
	end

	if private.mouseOverText.widgetID == widgetID then
		-- decrease counter
		private.mouseOverText.count = private.mouseOverText.count - 1
		if private.mouseOverText.count > 0 then
			return
		end
	end

	goToSlide(getElement("popupmenu", private.widgetsystem), "inactive")
	private.mouseOverText = nil
end

function widgetSystem.setMouseOverPosition()
	if private.mouseOverText == nil then
		return -- nothing to do
	end
	
	local viewwidth, viewheight = GetViewSize()
	local posX, posY = GetLocalMousePosition()
	if posX == nil then
		widgetSystem.hideMouseOverText(private.mouseOverText.widgetID)
		return
	end

	local width = private.mouseOverText.width
	local height = private.mouseOverText.height

	local offsetx = posX + private.mouseOverText.cursorinfo.width - private.mouseOverText.cursorinfo.xHotspot + config.mouseOverText.offsetX + width / 2
	local offsety = posY - height / 2
	if viewwidth / 2 - offsetx < width / 2 then
		offsetx = posX - private.mouseOverText.cursorinfo.xHotspot - config.mouseOverText.offsetX - width / 2
	end
	if viewheight / 2 + offsety < height / 2 then
		offsety = -viewheight / 2 + height / 2
	end
	widgetSystem.setElementPosition(getElement("popupmenu", private.widgetsystem), offsetx, offsety)
end

function widgetSystem.updateFrame(frame)
	-- hide old items (support for frame updates replacing a previous frame)
	widgetSystem.hideAllElements()

	private.offsetx, private.offsety = GetFramePosition(frame)
	private.width, private.height    = GetSize(frame)
	private.frame                    = frame
	private.onHideRisen              = false

	-- correctly take a potential frame border into account (aka: config.enableBackgroundBorderHack = true, for instance)
	local fullwidth  = private.width  + private.frameBorders.left + private.frameBorders.right
	local fullheight = private.height + private.frameBorders.top  + private.frameBorders.bottom
	local backgroundXOffset = private.offsetx + fullwidth/2  - private.frameBorders.left
	local backgroundYOffset = private.offsety - fullheight/2 + private.frameBorders.top

	-- set background/overlay
	-- private.offset is the coordinates in Anark space (aka: -view.width/2 / view.height/2) so that offset.x/offset.y represents the upper left corner of the view
	-- hence the proper position calculation for the background images (which are aligned in the texture's center) is:
	-- A + B + C
	-- A = offset (the upper left corner of the frame)
	-- B = (frame.width - view.width) / 2 (calculate the center position of the frame background - x = 400 => frame center = 200 - and calculate the offset relative to the Anark presentation's center -
	--     x-AnarkWidth/2 => 200-615 => -415 => the coordinate in the Anark presentation where the frame would have to be positioned
	-- C = view.width/2 - this is to compensate for the fact that private.offset (i.e. frame position) already contains -AnarkWidth/2 so that 0/0 corresponds to -AnarkWidth/2 // AnarkHeight/2
	-- offset + (frame.width - view.width)/2 + view.width/2
	-- => offset + frame.width/2
	local backgroundTexture = private.miniWidgetSystemUsed and private.master.miniWidgetSystem.backgroundTexture or private.master.backgroundTexture
	local background = GetFrameBackgroundID(frame)
	if background ~= nil then
		goToSlide(backgroundTexture, "active")
		SetIcon(getElement("backgroundTexture.Material642.backgroundTexture", backgroundTexture), background, nil, nil, nil, false, fullwidth, fullheight)
		widgetSystem.setElementPosition(backgroundTexture, backgroundXOffset, backgroundYOffset)
	else
		goToSlide(backgroundTexture, "inactive")
	end
	local overlayTexture = private.miniWidgetSystemUsed and private.master.miniWidgetSystem.overlayTexture or private.master.overlayTexture
	local overlay = GetFrameOverlayID(frame)
	if overlay ~= nil then
		goToSlide(overlayTexture, "active")
		SetIcon(getElement("overlayTexture.Material642.overlayTexture", overlayTexture), overlay, nil, nil, nil, false, fullwidth, fullheight)
		widgetSystem.setElementPosition(overlayTexture, backgroundXOffset, backgroundYOffset)
	else
		goToSlide(overlayTexture, "inactive")
	end

	-- #StefanMed - check how we could enable the following syntax with Anark/Widgets
	-- local content = { frame:GetChildren() }
	local content = { GetChildren(frame) }
	local tablecount = 0
	for _, child in ipairs(content) do
		if IsType(child, "table") then
			tablecount = tablecount + 1
			widgetSystem.setUpTable(child, tablecount, 0, 0, private.width)
		elseif IsType(child, "slider") then
			widgetSystem.setUpSlider(child, 0, 0, private.width)
		elseif IsType(child, "rendertarget") then
			widgetSystem.setUpRenderTarget(child, 0, 0, private.width)
		else
			DebugError("Widget system error. Specified object type is unsupported.")
		end
	end

	widgetSystem.enableAnimatedBackground(frame)

	widgetSystem.setUpStandardButtons(frame, private.offsety, private.offsetx + private.width)

	-- initialize the interactive object
	local interactiveWidgetID = GetInteractiveObject(frame)
	if interactiveWidgetID ~= nil then
		-- can be nil, if frame has no interactive object at all
		widgetSystem.setInteractiveElement(interactiveWidgetID)
	end
end

function widgetSystem.activateEditBoxInternal(editboxID, editboxElement)
	private.activeEditBox = {
		["editboxID"]      = editboxID,
		["editboxElement"] = editboxElement
	}
	if private.interactiveElement ~= nil then
		private.oldInteractiveElement = private.interactiveElement
		if private.interactiveElement.element.interactiveChild ~= nil then
			widgetSystem.unsetInteractiveChildElement(private.interactiveElement.element.interactiveChild.widgetID, private.associationList[private.interactiveElement.element.interactiveChild.widgetID].element)
		end
		private.interactiveElement = nil
	end

	if editboxElement.hotkeyIconActive then
		-- no unnecessary goToSlide()-call if the hotkey icon is inactive anyway
		local hotkeyElement = getElement("Hotkey", editboxElement.element)
		goToSlide(hotkeyElement, "inactive")
	end

	-- enable outline
	SetDiffuseColor(getElement("upper.Material701", editboxElement.element), config.editbox.outlinecolor.r, config.editbox.outlinecolor.g, config.editbox.outlinecolor.b)
	setAttribute(getElement("upper", editboxElement.element), "opacity", config.editbox.outlinecolor.a)
	SetDiffuseColor(getElement("left.Material701", editboxElement.element), config.editbox.outlinecolor.r, config.editbox.outlinecolor.g, config.editbox.outlinecolor.b)
	setAttribute(getElement("left", editboxElement.element), "opacity", config.editbox.outlinecolor.a)
	
	SetDiffuseColor(getElement("lower.Material701", editboxElement.element), config.editbox.outlinecolor.r, config.editbox.outlinecolor.g, config.editbox.outlinecolor.b)
	setAttribute(getElement("lower", editboxElement.element), "opacity", config.editbox.outlinecolor.a)
	SetDiffuseColor(getElement("right.Material701", editboxElement.element), config.editbox.outlinecolor.r, config.editbox.outlinecolor.g, config.editbox.outlinecolor.b)
	setAttribute(getElement("right", editboxElement.element), "opacity", config.editbox.outlinecolor.a)

	editboxElement.active = true
	editboxElement.oldtext = editboxElement.text
	editboxElement.cursor = false
	editboxElement.lastcursorupdatetime = getElapsedTime() - config.editbox.cursorBlinkInterval - 1

	C.ActivateDirectInput()
end

function widgetSystem.deactivateEditBox(editboxElement)
	C.DeactivateDirectInput()

	editboxElement.active = false
	editboxElement.oldtext = ""
	if editboxElement.cursor then
		setAttribute(getElement("Text", editboxElement.element), "textstring", editboxElement.text)
	end
	editboxElement.cursor = false

	-- disable outline
	SetDiffuseColor(getElement("upper.Material701", editboxElement.element), config.editbox.upper_left_color.r, config.editbox.upper_left_color.g, config.editbox.upper_left_color.b)
	setAttribute(getElement("upper", editboxElement.element), "opacity", config.editbox.upper_left_color.a)
	SetDiffuseColor(getElement("left.Material701", editboxElement.element), config.editbox.upper_left_color.r, config.editbox.upper_left_color.g, config.editbox.upper_left_color.b)
	setAttribute(getElement("left", editboxElement.element), "opacity", config.editbox.upper_left_color.a)
	
	SetDiffuseColor(getElement("lower.Material701", editboxElement.element), config.editbox.lower_right_color.r, config.editbox.lower_right_color.g, config.editbox.lower_right_color.b)
	setAttribute(getElement("lower", editboxElement.element), "opacity", config.editbox.lower_right_color.a)
	SetDiffuseColor(getElement("right.Material701", editboxElement.element), config.editbox.lower_right_color.r, config.editbox.lower_right_color.g, config.editbox.lower_right_color.b)
	setAttribute(getElement("right", editboxElement.element), "opacity", config.editbox.lower_right_color.a)

	if editboxElement.hotkeyIconActive then
		local hotkeyElement = getElement("Hotkey", editboxElement.element)
		goToSlide(hotkeyElement, "active")
	end

	if private.oldInteractiveElement ~= nil then
		if private.oldInteractiveElement.element.interactiveChild ~= nil then
			local entry = private.associationList[private.oldInteractiveElement.element.interactiveChild.widgetID]
			if entry then
				widgetSystem.setInteractiveChildElement(private.oldInteractiveElement.widgetID, private.oldInteractiveElement.element, private.oldInteractiveElement.element.interactiveChild.row, private.oldInteractiveElement.element.interactiveChild.col, private.oldInteractiveElement.element.interactiveChild.widgetID, entry.element)
			end
		end
		private.interactiveElement = private.oldInteractiveElement
		private.oldInteractiveElement = nil
	end
	private.activeEditBox = nil
end

function widgetSystem.confirmEditBoxInputInternal(editboxID, editboxElement)
	CallWidgetEventScripts(editboxID, "onUpdateText", editboxElement.text, editboxElement.text ~= editboxElement.oldtext)
	widgetSystem.deactivateEditBox(editboxElement)
end

function widgetSystem.confirmEditBoxInput(editboxID)
	local editboxentry = private.associationList[editboxID]
	if editboxentry == nil then
		return false, 1, "invalid editbox element"
	end
	local editboxElement = editboxentry.element

	if not editboxElement.active then
		return false, 2, "editbox is not active"
	end

	 widgetSystem.confirmEditBoxInputInternal(editboxID, editboxElement)

	return true
end

function widgetSystem.cancelEditBoxInputInternal(editboxElement)
	if editboxElement.text ~= editboxElement.oldtext then
		editboxElement.text = editboxElement.oldtext
		setAttribute(getElement("Text", editboxElement.element), "textstring", editboxElement.text)
		editboxElement.cursor = false
	end
	widgetSystem.deactivateEditBox(editboxElement)
end

function widgetSystem.cancelEditBoxInput(editboxID)
	local editboxentry = private.associationList[editboxID]
	if editboxentry == nil then
		return false, 1, "invalid editbox element"
	end
	local editboxElement = editboxentry.element

	if not editboxElement.active then
		return false, 2, "editbox is not active"
	end

	 widgetSystem.cancelEditBoxInputInternal(editboxElement)

	return true
end

function widgetSystem.updateEditBoxCursor(editboxElement, curTime)
	if editboxElement.lastcursorupdatetime + config.editbox.cursorBlinkInterval < curTime then
		editboxElement.lastcursorupdatetime = curTime
		editboxElement.cursor = not editboxElement.cursor
		setAttribute(getElement("Text", editboxElement.element), "textstring", editboxElement.text..(editboxElement.cursor and config.editbox.cursor or ""))
	end
end

function widgetSystem.updateFontString(fontstringID, textcomponent, textelement, activeSlide, inactiveSlide, curSlide)
	local text       = GetText(fontstringID)
	local font, size = GetFont(fontstringID)
	local fontheight = widgetSystem.getFontHeight(font, size)

	if text == "" then
		if curSlide ~= inactiveSlide then
			goToSlide(textcomponent, inactiveSlide)
		end
		return fontheight, text -- no need to set anything here, if no text is displayed
	end

	if curSlide ~= activeSlide then
		goToSlide(textcomponent, activeSlide)
	end

	local red, green, blue, alpha = GetColor(fontstringID)
	local textwidth               = GetSize(fontstringID)

	setAttribute(textelement, "textstring", text)
	setAttribute(textelement, "font", font)
	setAttribute(textelement, "size", size)
	setAttribute(textelement, "textcolor.r", red)
	setAttribute(textelement, "textcolor.g", green)
	setAttribute(textelement, "textcolor.b", blue)
	setAttribute(textelement, "opacity", alpha)
	setAttribute(textelement, "boxwidth", textwidth / config.nativePresentationWidth)

	return fontheight, text
end

function widgetSystem.updateIcon(icon, iconelement, parentx, parenty, parentwidth)
	local x, y = GetOffset(icon)
	local width, height = GetSize(icon)
	-- an icon is positioned relative to the icon's center --- hence we've to substract half the icon's extents to properly position it according to the icon's upper left corner
	x = parentx + x + width/2
	y = parenty - y

	widgetSystem.setElementPosition(iconelement, x, y, width % 2 ~= 0, height % 2 ~= 0)

	local texturename, red, green, blue, alpha = GetIconDetails(icon)
	-- use overlay color for icons which specify a color value implicitly (otherwise we use the multiply color mode)
	-- reasoning: if we set a texture/icon to use its own colors, we want to use the color values as they are and not overlay them with some
	-- color values --- this is achieved by SetIcon() using a white color value in combination with the multiply color mode which in effect
	-- will result in using the color values from the texture
	local useOverlayColor = true
	if red == nil then
		-- no custom color - use the texture as is (aka: multiply color with white)
		useOverlayColor = false
		red   = 255
		blue  = 255
		green = 255
		alpha = 100
	end

	if parentwidth < width then
		DebugError("Widget system error. The given icon width for icon '"..tostring(texturename).."' exceeds the maximum available width ("..tostring(width)..") of the parent ("..tostring(parentwidth).."). The icon will overlap the parent.")
	end

	local material = getElement("icon.icon", iconelement)
	SetIcon(getElement("icon", material), texturename, red, green, blue, useOverlayColor, width, height)
	-- #StefanLow --- better add support to SetIcon() to set the alpha too
	setAttribute(material, "opacity", alpha)
end

-- scrollBar   = the scrollbar element
-- posx        = the x position of the entire scrollbar (left corner)
-- width       = width the entire scrollbar can use
-- relativePos = relative position of the represented element (0..1)
function widgetSystem.updateHorizontalScrollBar(scrollBar, posx, width, relativePos)
	-- calculate the position where the slider inside the scrollbar would start (left edge slider position)
	local scrollBarSliderOffset = posx + config.texturesizes.slider.scrollBar.borderBoundaryLimit + config.texturesizes.slider.scrollBar.arrowElementWidth + scrollBar.width / 2

	-- calculate the range we can move the scrollbar (which is width minus width of the scroll bar itself)
	local range = width - scrollBar.width

	-- relative pos specifies a value between 0 and 1, defining the position relative to the start, where the scrollbar is to be positioned
	local scrollBarPos = scrollBarSliderOffset + range * relativePos

	-- finally make sure we do not use sub-pixel-positioning (which would end up in texture artifects at the edges of the three separate elements of the slider)
	scrollBarPos = math.ceil(scrollBarPos)

	widgetSystem.setElementPosition(scrollBar.sliderElement, scrollBarPos)
end

function widgetSystem.updateProgressElement(myProgressElement, progressElement)
	local name, value = GetProgressElementDetails(myProgressElement)

	setAttribute(getElement("Text", progressElement), "textstring", name)
	goToTime(getElement("bar", progressElement), value)
end

-- moves the scrollbar to the new center pos (which is the current mouse position minus the drag start offset pos)
-- #StefanLow - might actually be a good idea to combine with slider-scrolling behavior (see XT-2184)
function widgetSystem.updateScrollBarPos(tableElement)
	local _, y = GetLocalMousePosition()
	if y == nil then
		return -- outside the widget frame
	end

	-- check whether the mouse cursor was moved by a relevant factor
	if tableElement.scrollBar.previousMousePos ~= nil and math.abs(tableElement.scrollBar.previousMousePos - y) < config.mouseScrollBarThreshold then
		return -- mouse hasn't been moved between previous and current call - no mouse change => nothing to do
	end
	
	-- Note: we must take into account whether the mouse was moved up or down here, since we actually do not perform pixel-exact scrolling of the slider.
	-- That means: The slider position always represents the current position of the table and we scroll the table already as if we'd have dragged the slider half way to the previous/next row.
	-- At that point the slider would jump and the drag position might be above/below the current mouse position. If we'd just compare the difference of the drag position the next time the mouse is moved up/down
	-- we could end up with incorrectly determining that we'd moved the bar down/up -> results in inversed scrollbar movement (was cause of XT-3967)
	local moveDown = tableElement.scrollBar.previousMousePos ~= nil and tableElement.scrollBar.previousMousePos > y

	tableElement.scrollBar.previousMousePos = y

	local newSliderPos = y - tableElement.scrollBar.dragOffset
	local curSliderPos = widgetSystem.getScrollBarSliderPosition(tableElement.scrollBar.element)
	local valueDiff = newSliderPos - curSliderPos
	local pixelsInTableToScroll = tableElement.scrollBar.valuePerPixel * valueDiff

	local tableID = widgetSystem.getWidgetIDByElementEntry(tableElement)
	local stepsToScroll = widgetSystem.calculateRowsToMoveByPixelDiff(tableID, tableElement, pixelsInTableToScroll)

	if stepsToScroll > 0 then
		if valueDiff > 0 then
			if not moveDown then
				widgetSystem.scrollUp(tableID, tableElement, stepsToScroll)
			end
		elseif valueDiff < 0 then
			if moveDown then
				widgetSystem.scrollDown(tableID, tableElement, stepsToScroll)
			end
		end
	end
end

function widgetSystem.updateSlider(sliderElement)
	local sliderValue = sliderElement.curValue - sliderElement.zeroValue
	-- set current values
	-- left value
	local leftValue = ""
	if sliderElement.scale[1].left ~= nil and sliderElement.scale[2] ~= nil and sliderElement.scale[2].left ~= nil then
		local leftScale1Value = widgetSystem.getSliderSideValue(-sliderValue, sliderElement.scale[1].left, sliderElement.scale[1], sliderElement.fixedValues)
		local leftScale2Value = widgetSystem.getSliderSideValue(-sliderValue, sliderElement.scale[2].left, sliderElement.scale[2], sliderElement.fixedValues)
		leftValue = widgetSystem.formatNumber(leftScale1Value, sliderElement.scale[1].valueSuffix, leftScale2Value, sliderElement.scale[2].valueSuffix, config.slider.valueCharLimit)
	elseif sliderElement.scale[1].left ~= nil then
		local leftScale1Value = widgetSystem.getSliderSideValue(-sliderValue, sliderElement.scale[1].left, sliderElement.scale[1], sliderElement.fixedValues)
		leftValue = widgetSystem.formatNumber(leftScale1Value, sliderElement.scale[1].valueSuffix, nil, nil, config.slider.valueCharLimit)
	elseif sliderElement.scale[2] ~= nil and sliderElement.scale[2].left ~= nil then
		local leftScale2Value = widgetSystem.getSliderSideValue(-sliderValue, sliderElement.scale[2].left, sliderElement.scale[2], sliderElement.fixedValues)
		leftValue = widgetSystem.formatNumber(leftScale2Value, sliderElement.scale[2].valueSuffix, nil, nil, config.slider.valueCharLimit)
	end
	setAttribute(getElement("slider.text elements.value_left", sliderElement.element), "textstring", leftValue)

	-- center value
	local centerValue = ""
	if sliderElement.scale[1].displayCenter and sliderElement.scale[2] ~= nil and sliderElement.scale[2].displayCenter then
		centerValue = widgetSystem.formatNumber(math.abs(widgetSystem.getSliderCenterValue(sliderValue, sliderElement.scale[1])), sliderElement.scale[1].valueSuffix, math.abs(widgetSystem.getSliderCenterValue(sliderValue, sliderElement.scale[2])), sliderElement.scale[2].valueSuffix)
	elseif sliderElement.scale[1].displayCenter then
		centerValue = widgetSystem.formatNumber(math.abs(widgetSystem.getSliderCenterValue(sliderValue, sliderElement.scale[1])), sliderElement.scale[1].valueSuffix)
	elseif sliderElement.scale[2] and sliderElement.scale[2].displayCenter then
		centerValue = widgetSystem.formatNumber(math.abs(widgetSystem.getSliderCenterValue(sliderValue, sliderElement.scale[2])), sliderElement.scale[2].valueSuffix)
	end
	if centerValue ~= "" then
		if sliderElement.curValue < sliderElement.startValue then
			if not sliderElement.invertedIndicator then
				centerValue = centerValue.." <"
			else
				centerValue = centerValue.." >"
			end
		elseif sliderElement.curValue > sliderElement.startValue then
			if not sliderElement.invertedIndicator then
				centerValue = centerValue.." >"
			else
				centerValue = centerValue.." <"
			end
		end
	end
	setAttribute(getElement("slider.text elements.value_center", sliderElement.element), "textstring", centerValue)

	-- right value
	local rightValue = ""
	if sliderElement.scale[1].right ~= nil and sliderElement.scale[2] ~= nil and sliderElement.scale[2].right ~= nil then
		local rightScale1Value = widgetSystem.getSliderSideValue(sliderValue, sliderElement.scale[1].right, sliderElement.scale[1], sliderElement.fixedValues)
		local rightScale2Value = widgetSystem.getSliderSideValue(sliderValue, sliderElement.scale[2].right, sliderElement.scale[2], sliderElement.fixedValues)
		rightValue = widgetSystem.formatNumber(rightScale1Value, sliderElement.scale[1].valueSuffix, rightScale2Value, sliderElement.scale[2].valueSuffix, config.slider.valueCharLimit)
	elseif sliderElement.scale[1].right ~= nil then
		local rightScale1Value = widgetSystem.getSliderSideValue(sliderValue, sliderElement.scale[1].right, sliderElement.scale[1], sliderElement.fixedValues)
		rightValue = widgetSystem.formatNumber(rightScale1Value, sliderElement.scale[1].valueSuffix, nil, nil, config.slider.valueCharLimit)
	elseif sliderElement.scale[2] ~= nil and sliderElement.scale[2].right ~= nil then
		local rightScale2Value = widgetSystem.getSliderSideValue(sliderValue, sliderElement.scale[2].right, sliderElement.scale[2], sliderElement.fixedValues)
		rightValue = widgetSystem.formatNumber(rightScale2Value, sliderElement.scale[2].valueSuffix, nil, nil, config.slider.valueCharLimit)
	end
	setAttribute(getElement("slider.text elements.value_right", sliderElement.element), "textstring", rightValue)

	-- update the slider position (scroll bar)
	local relativePos = (sliderElement.curValue-sliderElement.minValue) / (sliderElement.maxValue-sliderElement.minValue)
	widgetSystem.updateHorizontalScrollBar(sliderElement.scrollBar, config.slider.scrollBar.offset.x, config.slider.scrollBar.width-config.texturesizes.slider.scrollBar.arrowElementWidth*2-config.texturesizes.slider.scrollBar.borderBoundaryLimit*2, relativePos)
end

-- moves the slider to the new center pos (which is the current mouse position minus the drag start offset pos)
function widgetSystem.updateSliderPos()
	local x = GetLocalMousePosition()
	if x == nil then
		return -- outside the game window
	end

	-- check whether the mouse cursor was moved by a relevant factor
	if private.previousSliderMousePos ~= nil and math.abs(private.previousSliderMousePos - x) < config.mouseSliderThreshold then
		return -- mouse hasn't been moved between previous and current call - no mouse change => nothing to do
	end
	private.previousSliderMousePos = x

	local newSliderPos = x + private.sliderDragStartOffset

	local curSliderPos = widgetSystem.getSliderPosition(private.element.slider.scrollBar.element)
	local valueDiff = newSliderPos - curSliderPos
	local sliderChangeValue = math.abs(private.element.slider.valuePerPixel * valueDiff)
	local granularity = private.element.slider.granularity
	-- make sure we take granularity into account
	local sliderChangeNumSteps = (sliderChangeValue - (sliderChangeValue % granularity)) / granularity
	-- and make sure we at least try to move by one (granularity) if we are to the edge of the right/left side (otherwise don't try to move, since we didn't move the slider far enough to account for the specified
	-- granularity yet)
	if sliderChangeNumSteps == 0 then
		if valueDiff > 0 then
			if newSliderPos >= private.element.slider.scrollBar.maxPos and curSliderPos < private.element.slider.scrollBar.maxPos then
				sliderChangeNumSteps = 1
			end
		elseif valueDiff < 0 then
			if newSliderPos <= private.element.slider.scrollBar.minPos and curSliderPos > private.element.slider.scrollBar.minPos then
				sliderChangeNumSteps = 1
			end
		end
	end

	if valueDiff > 0 then
		widgetSystem.scrollRight(private.element.slider, sliderChangeNumSteps)
	elseif valueDiff < 0 then
		widgetSystem.scrollLeft(private.element.slider, sliderChangeNumSteps)
	end
end

-- #StefanMed combine with generic button-state-handling?
function widgetSystem.updateStandardButtonState(button)
	local stateEntry = private.standardButtonState[button]
	local buttonActive
	local element
	if button == "back" then
		element = getElement("standardbuttons.back", private.widgetsystem)
		buttonActive = private.backButtonShown
	else -- button == "close"
		element = getElement("standardbuttons.close", private.widgetsystem)
		buttonActive = private.closeButtonShown
	end

	local targetSlide = "inactive"
	if buttonActive then
		-- only activate the button, if the button is actually active
		if stateEntry.mouseClick then
			targetSlide = "click"
		elseif stateEntry.mouseOver then
			targetSlide = "highlight"
		else
			targetSlide = "normal"
		end
	end

	if stateEntry.curSlide ~= targetSlide then
		local buttonName = "Close"
		if button == "back" then
			buttonName = "Back"
		end
		if targetSlide == "click" then
			CallWidgetEventScripts(private.frame, "on"..buttonName.."ButtonDown")
		elseif targetSlide == "highlight" then
			CallWidgetEventScripts(private.frame, "on"..buttonName.."ButtonOver")
		end
		goToSlide(element, targetSlide)
		stateEntry.curSlide = targetSlide
	end
end

function widgetSystem.updateTable(tableID, tableElement, shiftRows, newRow)
	if shiftRows ~= 0 then
		-- redraw shifted table
		widgetSystem.drawTableCells(tableID, tableElement, tableElement.topRow + shiftRows, tableElement.numRows, newRow)

		-- #StefanLow --- move the scrollbar according to table row height, not table row number
		local range   = tableElement.numRows - tableElement.topBottomRow
		local percent = (tableElement.bottomRow - tableElement.topBottomRow) / range
		percent = math.max(0, percent)
		widgetSystem.updateVerticalScrollBar(tableElement.scrollBar, percent)
	else
		-- we do not need to redraw the entire table, but we still need to update the selected row
		widgetSystem.selectRowInternal(tableID, tableElement, newRow)
	end
end

-- scrollBar   = the scrollbar element
-- relativePos = relative position of the represented element (0..1)
function widgetSystem.updateVerticalScrollBar(scrollBar, relativePos)
	if not scrollBar.active then
		return	-- scrollbar inactive, nothing to update
	end

	-- calculate the range we can move the scrollbar (which is scrollbar height minus height of the scroll bar itself)
	local range = scrollBar.height - scrollBar.sliderHeight
	-- relative pos specifies a value between 0 and 1, defining the position relative to the start, where the scrollbar is to be positioned
	local scrollBarPos = range * relativePos

	-- position slider element
	widgetSystem.setElementPosition(scrollBar.sliderElement, nil, -scrollBarPos - scrollBar.sliderHeight / 2 + scrollBar.height / 2)
end

function widgetSystem.queueShapeDraw(type, ...)
	if not private.shapesActivated then
		widgetSystem.setSceneState("shapes", true)
		private.shapesActivated = true
	end

	-- get circle element
	local id, anarkElement
	if type == "circle" then
		id, anarkElement = widgetSystem.getShapeElement("circleElements")
		if anarkElement == nil then
			DebugError("Widget system error. Already displaying "..config.shapes.circle.maxElements.." circle elements. Cannot display more. Circle will be skipped.")
			return
		end
		private.drawnShapes.circles[id] = anarkElement
	elseif type == "rectangle" then
		id, anarkElement = widgetSystem.getShapeElement("rectangleElements")
		if anarkElement == nil then
			DebugError("Widget system error. Already displaying "..config.shapes.rectangle.maxElements.." rectangle elements. Cannot display more. Rectangle will be skipped.")
			return
		end
		private.drawnShapes.rectangles[id] = anarkElement
	elseif type == "triangle" then
		id, anarkElement = widgetSystem.getShapeElement("triangleElements")
		if anarkElement == nil then
			DebugError("Widget system error. Already displaying "..config.shapes.triangle.maxElements.." triangle elements. Cannot display more. Triangle will be skipped.")
			return
		end
		private.drawnShapes.triangles[id] = anarkElement
	else
		DebugError("Widget system error. Unknown shape type, shape will be skipped.")
		return
	end

	table.insert(private.queuedShapes, { type = type, id = id, params = table.pack(...) })

	return id
end

function widgetSystem.updateShapes()
	for _, queuedShape in ipairs(private.queuedShapes) do
		if queuedShape.type == "circle" then
			widgetSystem.drawCircle(queuedShape.id, table.unpack(queuedShape.params))
		elseif queuedShape.type == "rectangle" then
			widgetSystem.drawRect(queuedShape.id, table.unpack(queuedShape.params))
		elseif queuedShape.type == "triangle" then
			widgetSystem.drawTriangle(queuedShape.id, table.unpack(queuedShape.params))
		end
	end
	private.queuedShapes = {}

	if not next(private.drawnShapes.circles) and not next(private.drawnShapes.rectangles) and not next(private.drawnShapes.triangles) then
		if private.shapesActivated then
			widgetSystem.setSceneState("shapes", false)
			private.shapesActivated = false
		end
	end
end

function widgetSystem.drawCircle(id, radiusx, radiusy, centerx, centery, z, color)
	local anarkElement = private.drawnShapes.circles[id]

	centerx = centerx + private.frameBorders.left / 2
	-- position, scale and rotation
	widgetSystem.setElementPosition(anarkElement, centerx, centery)
	setAttribute(anarkElement, "position.z", z)
	-- scale is cross-section, so we get an additional factor 2
	widgetSystem.setElementScale(anarkElement, radiusx / 50, radiusy / 50)

	-- color
	local element = getElement("Cylinder.Material425", anarkElement)
	SetDiffuseColor(element, color.r, color.g, color.b)
	setAttribute(element, "opacity", color.a)

	-- display
	goToSlide(anarkElement, "active")
end

function widgetSystem.drawRect(id, width, height, offsetx, offsety, angle, z, color)
	local anarkElement = private.drawnShapes.rectangles[id]

	offsetx = offsetx + width / 2 + private.frameBorders.left / 2
	offsety = offsety - height / 2

	-- position, scale and rotation
	widgetSystem.setElementPosition(anarkElement, offsetx, offsety)
	setAttribute(anarkElement, "position.z", z)
	widgetSystem.setElementScale(anarkElement, width / 100, height / 100)
	widgetSystem.setElementRotation(anarkElement, angle)

	-- color
	local element = getElement("Rectangle.Material1946", anarkElement)
	SetDiffuseColor(element, color.r, color.g, color.b)
	setAttribute(element, "opacity", color.a)

	-- display
	goToSlide(anarkElement, "active")
end

function widgetSystem.drawTriangle(id, width, height, offsetx, offsety, angle, z, color)
	local anarkElement = private.drawnShapes.triangles[id]

	offsetx = offsetx + width / 2 + private.frameBorders.left / 2
	offsety = offsety - height

	-- position, scale and rotation
	widgetSystem.setElementPosition(anarkElement, offsetx, offsety)
	setAttribute(anarkElement, "position.z", z)
	widgetSystem.setElementScale(anarkElement, width / 100, height / 100)
	widgetSystem.setElementRotation(anarkElement, angle)

	-- color
	local element = getElement("Cone.Material481", anarkElement)
	SetDiffuseColor(element, color.r, color.g, color.b)
	setAttribute(element, "opacity", color.a)

	-- display
	goToSlide(anarkElement, "active")
end

function widgetSystem.hideCircle(id)
	local element = private.drawnShapes.circles[id]
	if element ~= nil then
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.circleElements, {id, element})
		private.drawnShapes.circles[id] = nil
	else
		DebugError("Widget system error. Cannot find circle with id " .. id)
	end
end

function widgetSystem.hideRect(id)
	local element = private.drawnShapes.rectangles[id]
	if element ~= nil then
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.rectangleElements, {id, element})
		private.drawnShapes.circles[id] = nil
	else
		DebugError("Widget system error. Cannot find rectangle with id " .. id)
	end
end

function widgetSystem.hideTriangle(id)
	local element = private.drawnShapes.triangles[id]
	if element ~= nil then
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.triangleElements, {id, element})
		private.drawnShapes.circles[id] = nil
	else
		DebugError("Widget system error. Cannot find triangle with id " .. id)
	end
end

function widgetSystem.hideAllShapes()
	if private.shapesActivated then
		widgetSystem.hideCircles()
		widgetSystem.hideRects()
		widgetSystem.hideTriangles()
	
		widgetSystem.setSceneState("shapes", false)
		private.shapesActivated = false
	end
end

function widgetSystem.hideCircles()
	for id, element in pairs(private.drawnShapes.circles) do
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.circleElements, {id, element})
	end
	
	private.drawnShapes.circles = {}
end

function widgetSystem.hideRects()
	for id, element in pairs(private.drawnShapes.rectangles) do
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.rectangleElements, {id, element})
	end
	
	private.drawnShapes.rectangles = {}
end

function widgetSystem.hideTriangles()
	for id, element in pairs(private.drawnShapes.triangles) do
		goToSlide(element, "inactive")
		table.insert(private.element.shapes.triangleElements, {id, element})
	end
	
	private.drawnShapes.triangles = {}
end

function widgetSystem.isFullscreenMode()
	return private.fullscreenMode
end

-- global access
GetTopRow                    = widgetSystem.getTopRow
SelectColumn                 = widgetSystem.selectColumn
SelectRow                    = widgetSystem.selectRow
SetTopRow                    = widgetSystem.setTopRow
GetSliderValue               = widgetSystem.getSliderValue
GetRenderTargetTexture       = widgetSystem.getRenderTargetTexture
GetRenderTargetMousePosition = widgetSystem.getRenderTargetMousePosition
GetUsableTableWidth          = widgetSystem.getUsableTableWidth
ConfirmEditBoxInput          = widgetSystem.confirmEditBoxInput
CancelEditBoxInput           = widgetSystem.cancelEditBoxInput
ActivateEditBox              = widgetSystem.activateEditBox
TypeInEditBox                = widgetSystem.onDirectTextInput
ActivateDirectInput          = C.ActivateDirectInput
DeactivateDirectInput        = C.DeactivateDirectInput
DrawRect                     = function (...) return widgetSystem.queueShapeDraw("rectangle", ...) end
HideRect                     = widgetSystem.hideRect
HideAllRects                 = widgetSystem.hideRects
DrawCircle                   = function (...) return widgetSystem.queueShapeDraw("circle", ...) end
HideCircle                   = widgetSystem.hideCircle
HideAllCircles               = widgetSystem.hideCircles
DrawTriangle                 = function (...) return widgetSystem.queueShapeDraw("triangle", ...) end
HideTriangle                 = widgetSystem.hideTriangle
HideAllTriangles             = widgetSystem.hideTriangles
HideAllShapes                = widgetSystem.hideAllShapes
IsFullscreenWidgetSystem     = widgetSystem.isFullscreenMode

------------------------------------
-- Addon-System related functions --
------------------------------------
-- global function definitions
-- SetScript([widget, ]handleType, function)
function SetScript(widget, handle, scriptFunction)
	-- shift parameter one element to the right, if we are working with two argument (i.e. SetScript(handle, scriptFunction))
	if scriptFunction == nil then
		scriptFunction = handle
		handle = widget
		widget = nil
	end

	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to SetScript(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(handle) ~= "string" then
		DebugError("Invalid call to SetScript(). Given handle must be a string but is '"..type(handle).."'")
		return
	end

	if handle == "onUpdate" then
		if not addonSystem.insertUpdateScript(scriptFunction) then
			DebugError("Invalid call to SetScript(). Given onUpdate-function already registered.")
		end
		return
	elseif handle == "onHotkey" then
		if not addonSystem.insertHotkeyScript(scriptFunction) then
			DebugError("Invalid call to SetScript(). Given onHotkey-function already registered.")
		end
		return
	elseif widget ~= nil then
		addonSystem.setWidgetScript(widget, handle, scriptFunction)
		return
	end

	DebugError("Invalid call to SetScript(). Invalid specified handle '"..tostring(handle).."'.")
end

-- RemoveScript([widget, ]handleType, function)
function RemoveScript(widget, handle, scriptFunction)
	-- shift parameter one element to the right, if we are working with two argument (i.e. RemoveScript(handle, scriptFunction))
	if scriptFunction == nil then
		scriptFunction = handle
		handle = widget
		widget = nil
	end

	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to RemoveScript(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(handle) ~= "string" then
		DebugError("Invalid call to RemoveScript(). Given handle must be a string but is '"..type(handle).."'")
		return
	end

	if handle == "onUpdate" then
		if not addonSystem.removeUpdateScript(scriptFunction) then
			DebugError("Invalid call to RemoveScript(). Given onUpdate-function is not registered.")
		end
		return
	elseif handle == "onHotkey" then
		if not addonSystem.removeHotkeyScript(scriptFunction) then
			DebugError("Invalid call to RemoveScript(). Given onHotkey-function already registered.")
		end
		return
	elseif widget ~= nil then
		addonSystem.removeWidgetScript(widget, handle, scriptFunction)
		return
	end
	-- intended to future support (for instance onInitialize, onEvent?, onMouseButtonClick?, etc.)

	DebugError("Invalid call to RemoveScript(). Invalid specified handle '"..tostring(handle).."'.")
end

-- RegisterEvent(eventName, function)
function RegisterEvent(eventName, scriptFunction)
	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to RegisterEvent(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(eventName) ~= "string" then
		DebugError("Invalid call to RegisterEvent(). Given event name must be a string but is '"..type(eventName).."'")
		return
	end

	if not addonSystem.insertEventScript(eventName, scriptFunction) then
		DebugError("Invalid call to RegisterEvent(). Given function already registered for the event: '"..eventName.."'")
	end
end

-- UnregisterEvent(eventName, function)
function UnregisterEvent(eventName, scriptFunction)
	if type(scriptFunction) ~= "function" then
		DebugError("Invalid call to UnregisterEvent(). Given script function must be a function but is '"..type(scriptFunction).."'")
		return
	end

	if type(eventName) ~= "string" then
		DebugError("Invalid call to UnregisterEvent(). Given event name must be a string but is '"..type(eventName).."'")
		return
	end

	if not addonSystem.removeEventScript(eventName, scriptFunction) then
		DebugError("Invalid call to UnregisterEvent(). Given function not registered for event: '"..eventName.."'")
	end
end

-- function hooks
-- functions meant to be used internally (private functions)
function CallEventScripts(eventName, argument1)
	local scriptTable = private.eventScripts[eventName]
	if scriptTable == nil then
		return -- no registered scripts, nothing to do
	end

	local success, errorMessage
	for _, curFunction in ipairs(scriptTable) do
		success, errorMessage = pcall(curFunction, eventName, argument1)
		if not success then
			DebugError("Error while executing onEvent script for event: "..eventName..".\nErrormessage: "..tostring(errorMessage))
		end
	end
end

function CallHotkeyScripts(action)
	local success, errorMessage
	for _, curFunction in ipairs(private.hotkeyScripts) do
		success, errorMessage = pcall(curFunction, action)
		if not success then
			DebugError("Error while executing onHotkey script for action: '"..tostring(action).."'.\nErrormessage: "..tostring(errorMessage))
		end
	end
end

function CallUpdateScripts()
	local success, errorMessage
	for _, curFunction in ipairs(private.updateScripts) do
		success, errorMessage = pcall(curFunction)
		if not success then
			DebugError("Error while executing onUpdate script.\nErrormessage: "..tostring(errorMessage))
		end
	end
end

function CallWidgetEventScripts(widget, eventName, ...)
	local widgetScriptTable = private.widgetEventScripts[widget]
	if widgetScriptTable == nil then
		return -- no registered scripts, nothing to do
	end

	local scriptTable = widgetScriptTable[eventName]
	if scriptTable == nil then
		return -- no registered scripts, nothing to do
	end

	local success, errorMessage
	for _, curFunction in ipairs(scriptTable) do
		success, errorMessage = pcall(curFunction, widget, ...)
		if not success then
			DebugError("Error while executing onEvent script for event: "..eventName..".\nErrormessage: "..tostring(errorMessage))
		end
	end
end

-- addonSystem function definitions
function addonSystem.isValidWidgetScriptHandle(handle)
	for _, entry in ipairs(config.validScriptHandles) do
		if entry == handle then
			return true
		end
	end

	return false
end

function addonSystem.insertEventScript(eventName, scriptFunction)
	if private.eventScripts[eventName] == nil then
		private.eventScripts[eventName] = {}
	end

	local scriptTable = private.eventScripts[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(scriptTable, scriptFunction)

	return true
end

function addonSystem.insertHotkeyScript(scriptFunction)
	-- search for duplicates
	for key, curFunction in ipairs(private.hotkeyScripts) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(private.hotkeyScripts, scriptFunction)

	return true
end

function addonSystem.insertUpdateScript(scriptFunction)
	-- search for duplicates
	for key, curFunction in ipairs(private.updateScripts) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(private.updateScripts, scriptFunction)

	return true
end

function addonSystem.insertWidgetEventScript(widget, eventName, scriptFunction)
	if private.widgetEventScripts[widget] == nil then
		private.widgetEventScripts[widget] = {}
	end

	local widgetScriptTable = private.widgetEventScripts[widget]
	if widgetScriptTable[eventName] == nil then
		widgetScriptTable[eventName] = {}
	end

	local scriptTable = widgetScriptTable[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			return false -- entry already exists
		end
	end

	table.insert(scriptTable, scriptFunction)

	return true
end

function addonSystem.removeEventScript(eventName, scriptFunction)
	if private.eventScripts[eventName] == nil then
		return false -- no scripts registered for specified name at all
	end

	local scriptTable = private.eventScripts[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			table.remove(scriptTable, key)
			if #scriptTable == 0 then
				private.eventScripts[eventName] = nil -- clear the entire table, if last entry was removed
			end
			return true
		end
	end

	return false
end

function addonSystem.removeHotkeyScript(scriptFunction)
	-- search the entry
	for key, curFunction in ipairs(private.hotkeyScripts) do
		if curFunction == scriptFunction then
			table.remove(private.hotkeyScripts, key)
			return true
		end
	end

	return false
end

function addonSystem.removeUpdateScript(scriptFunction)
	-- search the entry
	for key, curFunction in ipairs(private.updateScripts) do
		if curFunction == scriptFunction then
			table.remove(private.updateScripts, key)
			return true
		end
	end

	return false
end

function addonSystem.removeWidgetEventScript(widget, eventName, scriptFunction)
	if private.widgetEventScripts[widget] == nil then
		return true -- no scripts registered for specified widget at all, considered already removed
	end

	local widgetScriptTable = private.widgetEventScripts[widget]

	if widgetScriptTable[eventName] == nil then
		return true -- no scripts registered for specified name at all, considered already removed
	end

	local scriptTable = widgetScriptTable[eventName]
	-- search for duplicates
	for key, curFunction in ipairs(scriptTable) do
		if curFunction == scriptFunction then
			table.remove(scriptTable, key)
			if #scriptTable == 0 then
				widgetScriptTable[eventName] = nil -- clear the entire script table, if last entry was removed
				if next(widgetScriptTable) == nil then
					private.widgetEventScripts[widget] = nil -- clear the entire widget table, if last entry was removed
				end
			end
			return true
		end
	end

	return true -- was not found in the list, so considered already removed
end

function addonSystem.removeWidgetScript(widget, handle, scriptFunction)
	if type(widget) ~= "number" then
		DebugError("Invalid call to RemoveScript(). Given handle '"..tostring(handle).."' is not recognized or given widget '"..tostring(widget).."' is invalid.")
		return
	end

	if not addonSystem.isValidWidgetScriptHandle(handle) then
		DebugError("Invalid call to RemoveScript(). Invalid specified handle '"..tostring(handle).."'.")
		return
	end

	if not addonSystem.removeWidgetEventScript(widget, handle, scriptFunction) then
		DebugError("Failure to remove '"..tostring(handle).."' for widget '"..tostring(widget).."' .")
	end
end

function addonSystem.setWidgetScript(widget, handle, scriptFunction)
	if type(widget) ~= "number" or not IsValidWidgetElement(widget) then
		DebugError("Invalid call to SetScript(). Given handle '"..tostring(handle).."' is not recognized or given widget '"..tostring(widget).."' is invalid.")
		return
	end

	if not addonSystem.isValidWidgetScriptHandle(handle) then
		DebugError("Invalid call to SetScript(). Invalid specified handle '"..tostring(handle).."'.")
		return
	end

	if not addonSystem.insertWidgetEventScript(widget, handle, scriptFunction) then
		DebugError("Invalid call to SetScript(). Given function for event '"..tostring(handle).."' already registered on widget '"..tostring(widget).."' .")
	end
end
