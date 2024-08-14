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
	MM:DeleteEntryScrollFrameUpdate()
end

--Creates the options frame and all its assets

function MM:CreateOptionsUI()

		local Options = {
			AddonName = "MiscMenu",
			TitleText = "Misc Menu Settings",
			{
			Name = "MiscMenu",
			Left = {
				{
					Type = "CheckButton",
					Name = "HideMenu",
					Lable = "Hide Standalone Button",
					OnClick = 	function()
						if self.db.HideMenu then
							self.standaloneButton:Show()
							self.db.HideMenu = false
						else
							self.standaloneButton:Hide()
							self.db.HideMenu = true
						end
					end
				},
				{
					Type = "CheckButton",
					Name = "EnableAutoHide",
					Lable = "Only Show Standalone Button on Hover",
					OnClick = function()
						self.db.EnableAutoHide = not self.db.EnableAutoHide
						self:ToggleMainButton(self.db.EnableAutoHide)
					end
				},
				{
					Type = "CheckButton",
					Name = "AutoMenu",
					Lable = "Open menu on mouse over",
					OnClick = function() self.db.AutoMenu = not self.db.AutoMenu end
				},
			},
			Right = {
				{
					Type = "CheckButton",
					Name = "AutoDeleteItems",
					Lable = "Delete vanity items after summoning",
					OnClick = function() self.db.AutoDeleteItems = not self.db.AutoDeleteItems end
				},
				{
					Type = "CheckButton",
					Name = "Minimap",
					Lable = "Hide minimap icon",
					OnClick = function()
						self.db.Minimap = not self.db.Minimap
						self:ToggleMainButton(self.db.EnableAutoHide)
					end
				},
				{
					Type = "Menu",
					Name = "TxtSize",
					Lable = "Menu text size"
				},
				{
					Type = "Menu",
					Name = "ProfileSelect2",
					Lable = "Profile selection",
				},
				{
					Type = "Slider",
					Name = "ButtonScale",
					Lable = "Standalone Button Scale",
					MinMax = {0.25, 1.5},
					Step = 0.01,
					Size = {240,16},
					OnShow = function() self.options.ButtonScale:SetValue(self.db.buttonScale or 1) end,
					OnValueChanged = function()
						self.db.buttonScale = self.options.ButtonScale:GetValue()
						if self.standaloneButton then
							self.standaloneButton:SetScale(self.db.buttonScale)
						end
					end
				}
			}
			},
			{
			Name = "MenuOptions",
			TitleText = "Menu Options",
			Right = {
			{
				Type = "Menu",
				Name = "ProfileSelect",
				Lable = "Profile selection"
			},
			},
			Left = {
				{
					Type = "Button",
					Name = "AddProfile",
					Lable = "Add Profile",
					Size = {100,25},
					OnClick = function()
						StaticPopup_Show("MISCMENU_ADD_PROFILE")
					end
				},
				{
					Type = "Button",
					Position = "Right",
					Name = "DeleteProflie",
					Lable = "Delete Profile",
					Size = {100,25},
					OnClick = function()
						StaticPopup_Show("MISCMENU_DELETE_PROFILE")
					end
				},
			}
			},
			{
				Name = "ActionBarOptions",
				TitleText = "ActionBar Options",
				Left = {
					{
						Type = "Menu",
						Name = "ActionBarSelect",
						Lable = "Select Actionbar",
					},
					{
						Type = "Menu",
						Name = "SelectActionBarProfile",
						Lable = "Select Profile",
					},
					{
						Type = "Slider",
						Name = "NumberOfActionbarButtons",
						Lable = "Buttons",
						MinMax = {1, 36},
						Step = 1,
						Size = {240,16},
						OnShow = function(slider) slider:SetValue(self.db.actionBarProfiles[self.charDB.actionBar.profile].numButtons) end,
						OnValueChanged = function(slider)
							self.db.actionBarProfiles[self.charDB.actionBar.profile].numButtons = slider:GetValue()
							self:SetActionBarLayout()
						end
					},
					{
						Type = "Slider",
						Name = "NumberOfActionbarRows",
						Lable = "Rows",
						MinMax = {1, (self:GetNumberButtons()/2)},
						Step = 1,
						Size = {240,16},
						OnShow = function(slider) slider:SetValue(self:GetNumberRows()) end,
						OnValueChanged = function(slider)
							local rows = slider:GetValue()
							local numButtons = self:GetNumberButtons()
							if math.floor(numButtons/rows) == numButtons/rows then
								self.db.actionBarProfiles[self.charDB.actionBar.profile].rows = rows
								self:SetActionBarLayout()
							end
						end
					},
					{
						Type = "CheckButton",
						Name = "ShowActionBar",
						Lable = "Show Action Bar",
						OnClick = function()
							self.db.ShowActionBar = not self.db.ShowActionBar
							self:ToggleActionBar()
						end
					},
				}
				}
		}
	self.options = self:CreateOptionsPages(Options, MiscMenuDB)
	------------------------------ Profile Settings Panel ------------------------------
	self.options.addButton = CreateFrame("Button", "MiscMenuOptionsAddButton", MiscMenuOptionsFrame2, "ItemButtonTemplate")
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
	self:DeleteEntryScrollFrameCreate()

		--[[
	StaticPopupDialogs["MISCMENU_ADD_PROFILE"]
	This is shown, if you want too share a wishlist
	]]
	StaticPopupDialogs["MISCMENU_ADD_PROFILE"] = {
		text = "Add New Profile",
		button1 = "Add",
		button2 = "Cancel",
		OnShow = function(self)
			self:SetFrameStrata("TOOLTIP")
		end,
		OnAccept = function()
			local name = _G[this:GetParent():GetName().."EditBox"]:GetText()
			if self.db.profileLists[name] then
				DEFAULT_CHAT_FRAME:AddMessage("Can't add profile as a profile with the name already exists")
			else
				self.db.profileLists[name] = {}
				self.db.selectedProfile = name
				self:DeleteEntryScrollFrameUpdate()
				MiscMenu_DropDownInitialize()
			end
		end,
		hasEditBox = 1,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

			--[[
	StaticPopupDialogs["MISCMENU_ADD_PROFILE"]
	This is shown, if you want too share a wishlist
	]]
	StaticPopupDialogs["MISCMENU_DELETE_PROFILE"] = {
		text = "Delete Selected Profile",
		button1 = "Delete",
		button2 = "Cancel",
		OnShow = function(self)
			self:SetFrameStrata("TOOLTIP")
		end,
		OnAccept = function()
			local name = _G[this:GetParent():GetName().."EditBox"]:GetText()
			if name == "default" then
				DEFAULT_CHAT_FRAME:AddMessage("You can't delete the default profile")
			else
				self.db.profileLists[self.db.selectedProfile] = nil
				if self.charDB.currentProfile == self.db.selectedProfile then self.charDB.currentProfile = "default" end
				self.db.selectedProfile = "default"
				self:DeleteEntryScrollFrameUpdate()
				MiscMenu_DropDownInitialize()
			end
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

end

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
	elseif infoType == "spell" then
		tinsert(profile, {#profile+1, tonumber(GetSpellLink(ID, "spell"):match("spell:(%d+)")), infoType})
	elseif infoType == "macro" then
		tinsert(profile, {#profile+1, GetMacroInfo(ID), infoType})
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
				UIDropDownMenu_SetSelectedID(MiscMenuOptionsProfileSelectMenu, thisID)
				MM:DeleteEntryScrollFrameUpdate()
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(MiscMenuOptionsProfileSelectMenu, 150)
	UIDropDownMenu_SetSelectedID(MiscMenuOptionsProfileSelectMenu, selected)
end

function MiscMenu_Options_Profile_Select2_Initialize()
	local i, info, selected = 1
	for name, _ in pairs(MM.db.profileLists) do
		if name == MM.charDB.currentProfile then
			selected = i
		end
		i = i + 1
		info = {
			text = name;
			func = function()
				MM.charDB.currentProfile = name
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(MiscMenuOptionsProfileSelect2Menu, thisID)
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(MiscMenuOptionsProfileSelect2Menu, 150)
	UIDropDownMenu_SetSelectedID(MiscMenuOptionsProfileSelect2Menu, selected)
end

function MiscMenu_Options_Menu_Initialize()
	local info
	for i = 10, 25 do
		info = {
			text = i;
			func = function() 
				MM.db.TxtSize = i 
				local thisID = this:GetID();
				UIDropDownMenu_SetSelectedID(MiscMenuOptionsTxtSizeMenu, thisID)
			end;
		}
			UIDropDownMenu_AddButton(info)
	end
	UIDropDownMenu_SetWidth(MiscMenuOptionsTxtSizeMenu, 150)
	UIDropDownMenu_SetSelectedID(MiscMenuOptionsTxtSizeMenu, MM.db.TxtSize - 9)
end

function MiscMenu_DropDownInitialize()
	--Setup for Dropdown menus in the settings
	UIDropDownMenu_Initialize(MiscMenuOptionsTxtSizeMenu, MiscMenu_Options_Menu_Initialize )
	UIDropDownMenu_Initialize(MiscMenuOptionsProfileSelect2Menu, MiscMenu_Options_Profile_Select2_Initialize )
	UIDropDownMenu_Initialize(MiscMenuOptionsProfileSelectMenu, MiscMenu_Options_Profile_Select_Initialize )
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

	self.deleteEntryScrollFrame = CreateFrame("Frame", "", MiscMenuOptionsFrame2)
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
				local link = (profile[value][3] == "item") and select(2,self:GetItemInfo(profile[value][2])) or (profile[value][3] == "spell") and GetSpellLink(profile[value][2]) or (profile[value][3] == "macro") and nil
				local text = link or profile[value][2].." (Macro)"
				row.Text:SetText(text)
				row:SetScript("OnClick", function()
					for num, v in pairs(profile) do
						if v[1] == profile[value][1] then
							tremove(profile, num)
							self:DeleteEntryScrollFrameUpdate()
						elseif v[1] > profile[value][1] then
							v[1] = v[1] - 1
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