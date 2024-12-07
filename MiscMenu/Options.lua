local MM = LibStub("AceAddon-3.0"):GetAddon("MiscMenu")
local WHITE = "|cffFFFFFF"
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
				{
					Type = "Menu",
					Name = "SelfCast",
					Lable = "Self Cast",
					Tooltip = "Cast placeable items/spells on self",
					Menu = function()
						local selections = { "none", "alt", "shift", "ctrl", "always"}
						return selections, self.db.SelfCast
					end,
					Func = function(selection)
						self.db.SelfCast = selection
						self:SetActionBarProfile()
					end,
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
						self:ToggleMinimap()
					end
				},
				{
					Type = "Menu",
					Name = "TxtSize",
					Lable = "Menu text size",
					Menu = {10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25}
				},
				{
					Type = "Menu",
					Name = "ProfileSelect2",
					Lable = "Profile selection",
					Menu = function()
						local selections = {}
						for name, _ in pairs(self.db.menuProfiles) do
							tinsert(selections, name)
						end
						return selections, self.charDB.menuSettings.currentProfile
					end,
					Func = function(selection)
						self.charDB.menuSettings.currentProfile = selection
					end,
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
				Lable = "Profile selection",
				Menu = function()
					local selections = {}
					for name, _ in pairs(self.db.menuProfiles) do
						tinsert(selections, name)
					end
					return selections, self.charDB.menuSettings.currentProfile
				end,
				Func = function(selection)
					self.charDB.menuSettings.currentProfile = selection
					self:DeleteEntryScrollFrameUpdate()
				end,
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
						Menu = function()
							local selections = {}
							for i = 1, self.db.NumberActionBars do
								tinsert(selections, i)
							end
							return selections, self:GetSelectedBar()
						end,
						Func = function(selection)
							self.selectedBar = selection
							self.options.ShowActionBar:SetChecked(self.charDB.actionBars[self.selectedBar].show)
							self.options.SelectActionBarProfile:updateMenu()
							self:SetActionBarProfile()
						end,
					},
					{
						Type = "Menu",
						Name = "SelectActionBarProfile",
						Lable = "Select Profile",
						Menu = function()
							local selections = {}
							for name, _ in pairs(self.db.actionBarProfiles) do
								tinsert(selections, name)
							end
							return selections, self.charDB.actionBars[self:GetSelectedBar()].profile
						end,
						Func = function(selection)
							self.charDB.actionBars[self:GetSelectedBar()].profile = selection
							self:SetActionBarProfile()
						end,
					},
					{
						Type = "Slider",
						Name = "NumberOfActionbarButtons",
						Lable = "Buttons",
						MinMax = {1, 12},
						Step = 1,
						Size = {240,16},
						OnShow = function(slider) slider:SetValue(self.charDB.actionBars[self:GetSelectedBar()].numButtons or 12) end,
						OnValueChanged = function(slider)
							self.charDB.actionBars[self:GetSelectedBar()].numButtons = slider:GetValue()
							self:SetActionBarLayout(self:GetSelectedBar())
						end
					},
					{
						Type = "Slider",
						Name = "NumberOfActionbarRows",
						Lable = "Rows",
						MinMax = {1, 12},
						Step = 1,
						Size = {240,16},
						OnShow = function(slider) slider:SetValue(self:GetNumberRows(self:GetSelectedBar())) end,
						OnValueChanged = function(slider)
							local rows = slider:GetValue()
							local numButtons = self:GetNumberButtons(self:GetSelectedBar())
							if math.floor(numButtons/rows) == numButtons/rows then
								self.charDB.actionBars[self:GetSelectedBar()].rows = rows
								self:SetActionBarLayout(self:GetSelectedBar())
							end
						end
					},
					{
						Type = "CheckButton",
						Name = "ShowActionBar",
						Lable = "Show Action Bar",
						OnClick = function()
							local bar = self:GetSelectedBar()
							self.charDB.actionBars[bar].show = not self.charDB.actionBars[bar].show
							self:ToggleActionBar()
						end,
						OnShow = function(button)
							button:SetChecked(self.charDB.actionBars[self:GetSelectedBar()].show)
						end,
					},
					{
						Type = "Button",
						Name = "ShowHideAuctionBars",
						Lable = "Toggle Action Bar Movers",
						Size = {180,25},
						OnClick = function()
							self:ActionBarUnlockFrame()
						end,
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
			if self.db.menuProfiles[name] then
				DEFAULT_CHAT_FRAME:AddMessage("Can't add profile as a profile with the name already exists")
			else
				self.db.menuProfiles[name] = {}
				self.charDB.menuSettings.currentProfile = name
				self:DeleteEntryScrollFrameUpdate()
				self:UpdateDropDownMenus("MiscMenu")
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
				self.db.menuProfiles[self.charDB.menuSettings.currentProfile] = nil
				self.charDB.menuSettings.currentProfile = "default"
				self:DeleteEntryScrollFrameUpdate()
				self:UpdateDropDownMenus("MiscMenu")
			end
		end,
		timeout = 0,
		whileDead = 1,
		hideOnEscape = 1
	}

end

function MM:AddItem()
	local infoType, ID , bookType = GetCursorInfo()
	local profile = self.db.menuProfiles[self.charDB.menuSettings.currentProfile]
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
		local profile = self.db.menuProfiles[self.charDB.menuSettings.currentProfile]
		local maxValue = #profile
		FauxScrollFrame_Update(self.deleteEntryScrollFrame.scrollBar, maxValue, MAX_ROWS, ROW_HEIGHT)
		local offset = FauxScrollFrame_GetOffset(self.deleteEntryScrollFrame.scrollBar)
		for i = 1, MAX_ROWS do
			local value = i + offset
			self.deleteEntryScrollFrame.rows[i]:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
			self.deleteEntryScrollFrame.rows[i]:Hide()
			if value <= maxValue then
				local row = self.deleteEntryScrollFrame.rows[i]
				local name, link, quality, icon
				if profile[value][3] == "item" then
					local item = {self:GetItemInfo(profile[value][2])}
					name, link, quality, icon = item[1], item[2], item[3], item[10]
					name = select(4,GetItemQualityColor(quality)) .. name
				elseif profile[value][3] == "spell" then
					name, _, icon = GetSpellInfo(profile[value][2])
					name = WHITE..name
					link = GetSpellLink(profile[value][2])
				end

				row.Icon:SetTexture(icon)
				name = name or profile[value][2].." (Macro)"
				row.Text:SetText(name)
				row:SetScript("OnClick", function()
					local removedNumber
					for num, v in pairs(profile) do
						if v[1] == profile[value][1] then
							tremove(profile, num)
							self:DeleteEntryScrollFrameUpdate()
							removedNumber = v[1]
						end
					end
					for _, v in pairs(profile) do
						if v[1] > removedNumber then
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
		row.Text:SetPoint("LEFT", row, 20, 0)
		row.Text:SetJustifyH("LEFT")
		row.Icon = row:CreateTexture(nil, "OVERLAY")
		row.Icon:SetSize(15,15)
		row.Icon:SetPoint("LEFT", row)
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