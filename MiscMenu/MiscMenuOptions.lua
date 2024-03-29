local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")

--Round number
local function round(num, idp)
	local mult = 10 ^ (idp or 0)
	return math.floor(num * mult + 0.5) / mult
 end

function MM:OptionsToggle(otherMenu)
    if InterfaceOptionsFrame:IsVisible() then
		InterfaceOptionsFrame:Hide()
	elseif otherMenu then
		InterfaceOptionsFrame_OpenToCategory("Menu options")
	else
		InterfaceOptionsFrame_OpenToCategory("MiscMenu")
	end
end

function MiscMenu_OpenOptions()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	MiscMenu_DropDownInitialize()
	UIDropDownMenu_SetText(MiscMenuOptions_TxtSizeMenu, MM.db.txtSize)
	UIDropDownMenu_SetText(MiscMenuOptions_ProfileSelectMenu, MM.db.selectedProfile)
	UIDropDownMenu_SetText(MiscMenuOptions_ProfileSelectMenu2, MM.charDB.currentProfile)

	MM:DeleteEntryScrollFrameUpdate()
end

--Creates the options frame and all its assets

function MM:CreateOptionsUI()
	if InterfaceOptionsFrame:GetWidth() < 850 then InterfaceOptionsFrame:SetWidth(850) end
	self.options = { frame = {} }
		self.options.frame.panel = CreateFrame("FRAME", "MiscMenuOptionsFrame", UIParent, nil)
    	local fstring = self.options.frame.panel:CreateFontString(self.options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("MiscMenu Settings")
		fstring:SetPoint("TOPLEFT", 15, -15)
		self.options.frame.panel.name = "MiscMenu"
		InterfaceOptions_AddCategory(self.options.frame.panel)

	self.options.hideMenu = CreateFrame("CheckButton", "MiscMenuOptionsHideMenu", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMenu:SetPoint("TOPLEFT", 30, -60)
	self.options.hideMenu.Lable = self.options.hideMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMenu.Lable:SetJustifyH("LEFT")
	self.options.hideMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMenu.Lable:SetText("Hide Standalone Button")
	self.options.hideMenu:SetScript("OnClick", function() 
		if self.db.hideMenu then
			self.standaloneButton:Show()
			self.db.hideMenu = false
		else
			self.standaloneButton:Hide()
			self.db.hideMenu = true
		end
	end)

	self.options.hideNoMouseOver = CreateFrame("CheckButton", "MiscMenuOptionsHideNoMouseOver", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideNoMouseOver:SetPoint("TOPLEFT", 30, -95)
	self.options.hideNoMouseOver.Lable = self.options.hideNoMouseOver:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideNoMouseOver.Lable:SetJustifyH("LEFT")
	self.options.hideNoMouseOver.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideNoMouseOver.Lable:SetText("Only Show Standalone Button on Hover")
	self.options.hideNoMouseOver:SetScript("OnClick", function()
		if self.db.hideNoMouseOver then
			MiscMenuOptionsFrame:Show()
			self.db.hideNoMouseOver = false
		else
			MiscMenuOptionsFrame:Hide()
			self.db.hideNoMouseOver = true
		end
	end)

	self.options.hideMinimap = CreateFrame("CheckButton", "MiscMenuOptionsHideMinimap", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.hideMinimap:SetPoint("TOPLEFT", 380, -60)
	self.options.hideMinimap.Lable = self.options.hideMinimap:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.hideMinimap.Lable:SetJustifyH("LEFT")
	self.options.hideMinimap.Lable:SetPoint("LEFT", 30, 0)
	self.options.hideMinimap.Lable:SetText("Hide minimap icon")
	self.options.hideMinimap:SetScript("OnClick", function() self:ToggleMinimap() end)

	self.options.autoDelete = CreateFrame("CheckButton", "MiscMenuOptionsAutoDelete", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.autoDelete:SetPoint("TOPLEFT", 380, -95)
	self.options.autoDelete.Lable = self.options.autoDelete:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoDelete.Lable:SetJustifyH("LEFT")
	self.options.autoDelete.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoDelete.Lable:SetText("Delete vanity items after summoning")
	self.options.autoDelete:SetScript("OnClick", function() self.db.deleteItem = not self.db.deleteItem end)

	self.options.autoMenu = CreateFrame("CheckButton", "MiscMenuOptionsAutoMenu", MiscMenuOptionsFrame, "UICheckButtonTemplate")
	self.options.autoMenu:SetPoint("TOPLEFT", 30, -130)
	self.options.autoMenu.Lable = self.options.autoMenu:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.autoMenu.Lable:SetJustifyH("LEFT")
	self.options.autoMenu.Lable:SetPoint("LEFT", 30, 0)
	self.options.autoMenu.Lable:SetText("Show menu on mouse over")
	self.options.autoMenu:SetScript("OnClick", function() self.db.autoMenu = not self.db.autoMenu end)

	self.options.txtSize = CreateFrame("Button", "MiscMenuOptions_TxtSizeMenu", MiscMenuOptionsFrame, "UIDropDownMenuTemplate")
	self.options.txtSize:SetPoint("TOPLEFT", 15, -170)
	self.options.txtSize.Lable = self.options.txtSize:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.txtSize.Lable:SetJustifyH("LEFT")
	self.options.txtSize.Lable:SetPoint("LEFT", self.options.txtSize, 190, 0)
	self.options.txtSize.Lable:SetText("Menu text size")

	self.options.buttonScale = CreateFrame("Slider", "MiscMenuOptionsButtonScale", MiscMenuOptionsFrame,"OptionsSliderTemplate")
	self.options.buttonScale:SetSize(240,16)
	self.options.buttonScale:SetPoint("TOPLEFT", 380,-150)
	self.options.buttonScale:SetMinMaxValues(0.25, 1.5)
	_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
	_G[self.options.buttonScale:GetName().."Low"]:SetText(0.25)
	_G[self.options.buttonScale:GetName().."High"]:SetText(1.5)
	self.options.buttonScale:SetValueStep(0.01)
	self.options.buttonScale:SetScript("OnShow", function() self.options.buttonScale:SetValue(self.db.buttonScale or 1) end)
    self.options.buttonScale:SetScript("OnValueChanged", function()
		_G[self.options.buttonScale:GetName().."Text"]:SetText("Standalone Button Scale: ".." ("..round(self.options.buttonScale:GetValue(),2)..")")
        self.db.buttonScale = self.options.buttonScale:GetValue()
		if self.standaloneButton then
        	self.standaloneButton:SetScale(self.db.buttonScale)
		end
    end)

	self.options.profileSelect2 = CreateFrame("Button", "MiscMenuOptions_ProfileSelectMenu2", MiscMenuOptionsFrame, "UIDropDownMenuTemplate")
	self.options.profileSelect2:SetPoint("TOPLEFT", 15, -210)
	self.options.profileSelect2.Lable = self.options.profileSelect2:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.profileSelect2.Lable:SetJustifyH("LEFT")
	self.options.profileSelect2.Lable:SetPoint("LEFT", self.options.profileSelect2, 190, 0)
	self.options.profileSelect2.Lable:SetText("Profile selection")

	------------------------------ Profile Settings Panel ------------------------------

	self.options.frame.profilePanel = CreateFrame("FRAME", "MiscMenuAddItemsPanel", UIParent, nil)
		local fstring = self.options.frame.profilePanel:CreateFontString(self.options.frame, "OVERLAY", "GameFontNormal")
		fstring:SetText("Menu options")
		fstring:SetPoint("TOPLEFT", 30, -15)
		self.options.frame.profilePanel.name = "Menu options"
		self.options.frame.profilePanel.parent = "MiscMenu"
		InterfaceOptions_AddCategory(self.options.frame.profilePanel)

	self.options.profileSelect = CreateFrame("Button", "MiscMenuOptions_ProfileSelectMenu", MiscMenuAddItemsPanel, "UIDropDownMenuTemplate")
	self.options.profileSelect:SetPoint("TOPLEFT", 15, -50)
	self.options.profileSelect.Lable = self.options.profileSelect:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.profileSelect.Lable:SetJustifyH("LEFT")
	self.options.profileSelect.Lable:SetPoint("LEFT", self.options.profileSelect, 190, 0)
	self.options.profileSelect.Lable:SetText("Profile selection")

	self.options.addButton = CreateFrame("Button", "MiscMenuOptionsAddButton", MiscMenuAddItemsPanel, "ItemButtonTemplate")
	self.options.addButton:SetPoint("TOPLEFT", 280, -113)
	self.options.addButton.Lable = self.options.addButton:CreateFontString(nil , "BORDER", "GameFontNormal")
	self.options.addButton.Lable:SetJustifyH("LEFT")
	self.options.addButton.Lable:SetPoint("LEFT", self.options.addButton, 0, 37)
	self.options.addButton.Lable:SetText("Add item/spell")
	self.options.addButton:SetScript("OnClick", function()
		self:AddItem()
		self:DeleteEntryScrollFrameUpdate()
	end)
	self.options.addButton:SetScript("OnEnter", function(button)
		GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT", 0, 20)
		GameTooltip:AddLine("Drag and drop a spell or item to add it to list")
		GameTooltip:Show()
	end)
	self.options.addButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

end

MM:CreateOptionsUI()

function MM:AddItem()
	local infoType, ID , bookType = GetCursorInfo()
	local profile = self.db.profileLists[self.db.selectedProfile]
	if not infoType then return end
	if infoType == "item" then
		tinsert(profile, {#profile+1, ID, infoType})
	elseif infoType == "companion" and bookType == "CRITTER" then
		tinsert(profile, {#profile+1, select(3, GetCompanionInfo("CRITTER", ID)), "spell"})
	elseif infoType == "companion" and bookType == "MOUNT" then
		tinsert(profile, {#profile+1, select(3, GetCompanionInfo("MOUNT", ID)), "spell"})
	else
		tinsert(profile, {#profile+1, tonumber(GetSpellLink(ID, "spell"):match("spell:(%d+)")), infoType})
	end
	ClearCursor()
end

function MiscMenu_Options_Profile_Select_Initialize()
	local i, info, selected = 1
	for name, _ in pairs(MM.db.profileLists) do
		if name == MM.db.selectedProfile then
			selected = i
		end
		i = i + 1
		info = {
			text = name;
			func = function()
				MM.db.selectedProfile = name
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(MiscMenuOptions_ProfileSelectMenu, thisID)
				MM:DeleteEntryScrollFrameUpdate()
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetSelectedID(MiscMenuOptions_ProfileSelectMenu, selected)
end

function MiscMenu_Options_Profile_Select2_Initialize()
	local i, info, selected = 1
	for name, _ in pairs(MM.db.profileLists) do
		if name == MM.db.currentProfile then
			selected = i
		end
		i = i + 1
		info = {
			text = name;
			func = function()
				MM.charDB.currentProfile = name
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(MiscMenuOptions_ProfileSelectMenu2, thisID)
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetSelectedID(MiscMenuOptions_ProfileSelectMenu2, selected)
end

function MiscMenu_Options_Menu_Initialize()
	local info
	for i = 10, 25 do
		info = {
			text = i;
			func = function() 
				MM.db.txtSize = i 
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(MiscMenuOptions_TxtSizeMenu, thisID)
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
end

function MiscMenu_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(MiscMenuOptions_TxtSizeMenu, MiscMenu_Options_Menu_Initialize )
	UIDropDownMenu_SetSelectedID(MiscMenuOptions_TxtSizeMenu)
	UIDropDownMenu_SetWidth(MiscMenuOptions_TxtSizeMenu, 150)

	UIDropDownMenu_Initialize(MiscMenuOptions_ProfileSelectMenu2, MiscMenu_Options_Profile_Select2_Initialize )
	UIDropDownMenu_SetSelectedID(MiscMenuOptions_ProfileSelectMenu2)
	UIDropDownMenu_SetWidth(MiscMenuOptions_ProfileSelectMenu2, 150)

	UIDropDownMenu_Initialize(MiscMenuOptions_ProfileSelectMenu, MiscMenu_Options_Profile_Select_Initialize )
	UIDropDownMenu_SetSelectedID(MiscMenuOptions_ProfileSelectMenu)
	UIDropDownMenu_SetWidth(MiscMenuOptions_ProfileSelectMenu, 150)
end

--Hook interface frame show to update options data
InterfaceOptionsFrame:HookScript("OnShow", function()
	if InterfaceOptionsFrame and MiscMenuOptionsFrame:IsVisible() then
		MiscMenu_OpenOptions()
	end
end)

------------------ScrollFrameTooltips---------------------------
function MM:DeleteEntryScrollFrameCreate()

	local function ItemTemplate_OnEnter(self)
		if not self.link then return end
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT", -13, -50)
		GameTooltip:SetHyperlink(self.link)
		GameTooltip:Show()
	end

	local function ItemTemplate_OnLeave()
		GameTooltip:Hide()
	end

	--ScrollFrame

	local ROW_HEIGHT = 16   -- How tall is each row?
	local MAX_ROWS = 18      -- How many rows can be shown at once?

	self.deleteEntryScrollFrame = CreateFrame("Frame", "", MiscMenuAddItemsPanel)
		self.deleteEntryScrollFrame:EnableMouse(true)
		self.deleteEntryScrollFrame:SetSize(230, ROW_HEIGHT * MAX_ROWS + 16)
		self.deleteEntryScrollFrame:SetPoint("TOPLEFT", 30, -112)
		self.deleteEntryScrollFrame:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background", tile = true, tileSize = 16,
			edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16,
			insets = { left = 4, right = 4, top = 4, bottom = 4 },
		})
		self.deleteEntryScrollFrame.lable = self.deleteEntryScrollFrame:CreateFontString(nil , "BORDER", "GameFontNormal")
		self.deleteEntryScrollFrame.lable:SetJustifyH("LEFT")
		self.deleteEntryScrollFrame.lable:SetPoint("TOPLEFT", self.deleteEntryScrollFrame, 2, 25)
		self.deleteEntryScrollFrame.lable:SetText("Click to remove item/spell from list")

	function MM:DeleteEntryScrollFrameUpdate()
		local profile = self.db.profileLists[self.db.selectedProfile]
		local maxValue = #profile
		FauxScrollFrame_Update(self.deleteEntryScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.deleteEntryScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
			self.deleteEntryScrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
			self.deleteEntryScrollFrame.rows[i]:Hide()
			if value <= maxValue then
				local row = self.deleteEntryScrollFrame.rows[i]
				local link = profile[value][3] == "item" and select(2,GetItemInfo(profile[value][2])) or GetSpellLink(profile[value][2])
				row.Text:SetText(link)
				row:SetScript("OnClick", function()
					for num, v in pairs(profile) do
						if v[1] == profile[value][1] then
							if v[1] > profile[value][1] then
								v[1] = v[1] - 1
							end
							tremove(profile, num)
							self:DeleteEntryScrollFrameUpdate()
							break
						end
					end
				end)
				row.link = link
				row:Show()
			end
		end
	end

	self.deleteEntryScrollFrame.scrollBar = CreateFrame("ScrollFrame", "MiscMenuOptionsDeleteFrameScroll", self.deleteEntryScrollFrame, "FauxScrollFrameTemplate")
	self.deleteEntryScrollFrame.scrollBar:SetPoint("TOPLEFT", 0, -8)
	self.deleteEntryScrollFrame.scrollBar:SetPoint("BOTTOMRIGHT", -30, 8)
	self.deleteEntryScrollFrame.scrollBar:SetScript("OnVerticalScroll", function(scroll, offset)
		scroll.offset = math.floor(offset / ROW_HEIGHT + 0.5)
		self:DeleteEntryScrollFrameUpdate()
	end)

	local rows = setmetatable({}, { __index = function(t, i)
		local row = CreateFrame("Button", "$parentRow"..i, self.deleteEntryScrollFrame )
		row:SetSize(190, ROW_HEIGHT)
		row:SetNormalFontObject(GameFontHighlightLeft)
		row.Text = row:CreateFontString("$parentRow"..i.."Text","OVERLAY","GameFontNormal")
		row.Text:SetSize(190, ROW_HEIGHT)
		row.Text:SetPoint("LEFT",row)
		row.Text:SetJustifyH("LEFT")
		row:SetScript("OnShow", function(button)
			if GameTooltip:GetOwner() == button:GetName() then
				ItemTemplate_OnEnter(button)
			end
		end)
		row:SetScript("OnEnter", function(button)
			ItemTemplate_OnEnter(button)
		end)
		row:SetScript("OnLeave", ItemTemplate_OnLeave)
		if i == 1 then
			row:SetPoint("TOPLEFT", self.deleteEntryScrollFrame, 8, -8)
		else
			row:SetPoint("TOPLEFT", self.deleteEntryScrollFrame.rows[i-1], "BOTTOMLEFT")
		end
		rawset(t, i, row)
		return row
	end })

	self.deleteEntryScrollFrame.rows = rows
end

MM:DeleteEntryScrollFrameCreate()